// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ray_club_app/utils/log_utils.dart';

/// Interface para serviço de cache
abstract class CacheService {
  /// Armazena um valor no cache
  Future<bool> set(String key, dynamic value, {Duration? expiry});
  
  /// Recupera um valor do cache
  Future<dynamic> get(String key);
  
  /// Remove um valor do cache
  Future<bool> remove(String key);
  
  /// Limpa todo o cache
  Future<bool> clear();
  
  /// Verifica se um valor no cache está expirado
  Future<bool> isExpired(String key);
  
  /// Método para salvar lista de objetos serializados em cache
  Future<void> setObjectList<T>(
    String key, 
    List<T> objects, 
    {
      required T Function(Map<String, dynamic> json) fromJson,
      required Map<String, dynamic> Function(T object) toJson,
      Duration? expiryDuration,
    }
  );
  
  /// Método para recuperar lista de objetos do cache
  Future<List<T>?> getObjectList<T>(
    String key,
    {
      required T Function(Map<String, dynamic> json) fromJson,
      bool ignoreExpiry = false,
    }
  );
  
  /// Método para verificar se um cache específico está disponível e não expirado
  Future<bool> hasCacheValid(String key);
  
  /// Método para verificar quando um cache específico foi atualizado pela última vez
  Future<DateTime?> getLastCacheUpdate(String key);
}

/// Serviço para gerenciar cache temporário de dados na aplicação
class AppCacheService implements CacheService {
  // Singleton
  static final AppCacheService _instance = AppCacheService._internal();
  factory AppCacheService() => _instance;
  AppCacheService._internal();

  // Cache em memória para acesso mais rápido
  final Map<String, _CacheEntry> _memoryCache = {};

  /// Recupera um valor do cache
  @override
  Future<dynamic> get(String key) async {
    // Primeiro verifica se está no cache em memória
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      
      // Verifica se o cache ainda é válido
      if (entry.expiresAt == null || entry.expiresAt!.isAfter(DateTime.now())) {
        return entry.value;
      } else {
        // Remove da memória se expirou
        _memoryCache.remove(key);
      }
    }
    
    // Se não estiver na memória, tenta recuperar do armazenamento persistente
    return await _getFromStorage(key);
  }

  /// Armazena um valor no cache
  @override
  Future<bool> set(
    String key, 
    dynamic value, {
    Duration? expiry,
  }) async {
    try {
      // Calcula a data de expiração
      final DateTime? expiresAt = 
          expiry != null ? DateTime.now().add(expiry) : null;
      
      // Armazena na memória
      _memoryCache[key] = _CacheEntry(
        value: value,
        expiresAt: expiresAt,
      );
      
      // Armazena também no disco
      await _saveToStorage(key, value, expiresAt);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove um valor do cache
  @override
  Future<bool> remove(String key) async {
    try {
      _memoryCache.remove(key);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cache_$key');
      await prefs.remove('cache_exp_$key');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Limpa todo o cache
  @override
  Future<bool> clear() async {
    try {
      _memoryCache.clear();
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('cache_')).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> isExpired(String key) async {
    // Verifica se está no cache em memória
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      
      // Se não tiver data de expiração, nunca expira
      if (entry.expiresAt == null) {
        return false;
      }
      
      // Verifica se já expirou
      return entry.expiresAt!.isBefore(DateTime.now());
    }
    
    // Verifica no armazenamento persistente
    final prefs = await SharedPreferences.getInstance();
    final expiryStr = prefs.getString('cache_exp_$key');
    
    if (expiryStr == null) {
      // Se não tiver data de expiração, verifica se o valor existe
      return !prefs.containsKey('cache_$key');
    }
    
    try {
      final expiryDate = DateTime.parse(expiryStr);
      return expiryDate.isBefore(DateTime.now());
    } catch (e) {
      return true; // Considera expirado se a data for inválida
    }
  }
  
  @override
  Future<void> setObjectList<T>(
    String key, 
    List<T> objects, 
    {
      required T Function(Map<String, dynamic> json) fromJson,
      required Map<String, dynamic> Function(T object) toJson,
      Duration? expiryDuration,
    }
  ) async {
    final List<Map<String, dynamic>> jsonList = objects.map(toJson).toList();
    await set(key, jsonList, expiry: expiryDuration);
  }
  
  @override
  Future<List<T>?> getObjectList<T>(
    String key,
    {
      required T Function(Map<String, dynamic> json) fromJson,
      bool ignoreExpiry = false,
    }
  ) async {
    if (!ignoreExpiry && await isExpired(key)) {
      return null;
    }
    
    final dynamic data = await get(key);
    if (data == null || data is! List) {
      return null;
    }
    
    try {
      return data
          .cast<Map<String, dynamic>>()
          .map((map) => fromJson(map))
          .toList();
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<bool> hasCacheValid(String key) async {
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (entry.expiresAt == null || entry.expiresAt!.isAfter(DateTime.now())) {
        return true;
      }
    }
    
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('cache_$key')) {
      return false;
    }
    
    return !(await isExpired(key));
  }
  
  @override
  Future<DateTime?> getLastCacheUpdate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final updateTimeStr = prefs.getString('cache_update_$key');
    if (updateTimeStr == null) {
      return null;
    }
    
    try {
      return DateTime.parse(updateTimeStr);
    } catch (e) {
      return null;
    }
  }

  /// Recupera um valor do armazenamento persistente
  Future<dynamic> _getFromStorage(String key) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Verifica se existe no armazenamento
    if (!prefs.containsKey('cache_$key')) {
      return null;
    }
    
    // Verifica se está expirado
    final expirationString = prefs.getString('cache_exp_$key');
    if (expirationString != null) {
      final expiresAt = DateTime.parse(expirationString);
      if (expiresAt.isBefore(DateTime.now())) {
        // Remove se expirou
        await prefs.remove('cache_$key');
        await prefs.remove('cache_exp_$key');
        return null;
      }
    }
    
    // Recupera o valor
    final cachedString = prefs.getString('cache_$key');
    if (cachedString == null) {
      return null;
    }
    
    try {
      // Tenta converter de volta para o formato original
      final decoded = jsonDecode(cachedString);
      
      // Atualiza o cache em memória
      _memoryCache[key] = _CacheEntry(
        value: decoded,
        expiresAt: expirationString != null 
            ? DateTime.parse(expirationString) 
            : null,
      );
      
      return decoded;
    } catch (e) {
      // Se falhar, retorna a string bruta
      return cachedString;
    }
  }

  /// Salva um valor no armazenamento persistente
  Future<void> _saveToStorage(
    String key, 
    dynamic value,
    DateTime? expiresAt,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Converte o valor para string usando JSON
    String valueString;
    try {
      valueString = jsonEncode(value);
    } catch (e) {
      // Se falhar, utiliza .toString()
      valueString = value.toString();
      LogUtils.warning('CacheService: Falha ao codificar valor para $key. Usando toString()');
    }
    
    // Salva o valor
    await prefs.setString('cache_$key', valueString);
    
    // Salva a data de expiração, se houver
    if (expiresAt != null) {
      await prefs.setString('cache_exp_$key', expiresAt.toIso8601String());
    } else {
      await prefs.remove('cache_exp_$key');
    }
    
    // Registra a data da atualização
    await prefs.setString('cache_update_$key', DateTime.now().toIso8601String());
  }
}

/// Classe interna para representar uma entrada no cache
class _CacheEntry {
  final dynamic value;
  final DateTime? expiresAt;
  
  _CacheEntry({
    required this.value,
    this.expiresAt,
  });
}

/// Provider para o serviço de cache
final cacheServiceProvider = Provider<CacheService>((ref) {
  // Retorna a implementação de SharedPrefs com SharedPreferences injetado 
  // através de um override no ProviderContainer em main.dart
  throw UnimplementedError(
    'Este provider deve ser sobrescrito com uma instância de SharedPrefsCacheService no main.dart'
  );
});

/// Implementação do CacheService usando SharedPreferences
class SharedPrefsCacheService implements CacheService {
  final SharedPreferences _prefs;

  /// Construtor
  SharedPrefsCacheService(this._prefs);

  @override
  Future<bool> set(String key, dynamic value, {Duration? expiry}) async {
    try {
      // Calcula a data de expiração
      final DateTime? expiresAt = 
          expiry != null ? DateTime.now().add(expiry) : null;
      
      // Converte o valor para string usando JSON
      String valueString;
      try {
        valueString = jsonEncode(value);
      } catch (e) {
        // Se falhar, utiliza .toString()
        valueString = value.toString();
        LogUtils.warning('CacheService: Falha ao codificar valor para $key. Usando toString()');
      }
      
      // Salva o valor
      await _prefs.setString('cache_$key', valueString);
      
      // Salva a data de expiração, se houver
      if (expiresAt != null) {
        await _prefs.setString('cache_exp_$key', expiresAt.toIso8601String());
      } else {
        await _prefs.remove('cache_exp_$key');
      }
      
      // Registra a data da atualização
      await _prefs.setString('cache_update_$key', DateTime.now().toIso8601String());
      
      return true;
    } catch (e) {
      LogUtils.error('CacheService: Erro ao salvar valor para $key: $e');
      return false;
    }
  }

  @override
  Future<dynamic> get(String key) async {
    try {
      // Verifica se o cache expirou
      if (await isExpired(key)) {
        return null;
      }
      
      // Recupera o valor
      final valueString = _prefs.getString('cache_$key');
      if (valueString == null) {
        return null;
      }
      
      // Tenta desserializar o JSON
      try {
        return jsonDecode(valueString);
      } catch (e) {
        // Se não for JSON, retorna a string
        return valueString;
      }
    } catch (e) {
      LogUtils.error('CacheService: Erro ao recuperar valor para $key: $e');
      return null;
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      await _prefs.remove('cache_$key');
      await _prefs.remove('cache_exp_$key');
      await _prefs.remove('cache_update_$key');
      return true;
    } catch (e) {
      LogUtils.error('CacheService: Erro ao remover valor para $key: $e');
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    try {
      // Remove todas as entradas de cache
      final keys = _prefs.getKeys().where((k) => 
        k.startsWith('cache_') || 
        k.startsWith('cache_exp_') || 
        k.startsWith('cache_update_')
      ).toList();
      
      for (final key in keys) {
        await _prefs.remove(key);
      }
      
      return true;
    } catch (e) {
      LogUtils.error('CacheService: Erro ao limpar cache: $e');
      return false;
    }
  }

  @override
  Future<bool> isExpired(String key) async {
    // Verifica se existe um prazo de expiração para a chave
    final expiryStr = _prefs.getString('cache_exp_$key');
    if (expiryStr == null) {
      // Se não tiver data de expiração, verifica se o valor existe
      return !_prefs.containsKey('cache_$key');
    }
    
    try {
      // Converte a data de expiração
      final expiryDate = DateTime.parse(expiryStr);
      
      // Verifica se a data atual é posterior à data de expiração
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      LogUtils.error('CacheService: Erro ao verificar expiração para $key: $e');
      return true; // Considera expirado se houver erro
    }
  }

  @override
  Future<void> setObjectList<T>(
    String key, 
    List<T> objects, 
    {
      required T Function(Map<String, dynamic> json) fromJson,
      required Map<String, dynamic> Function(T object) toJson,
      Duration? expiryDuration,
    }
  ) async {
    try {
      final List<Map<String, dynamic>> jsonList = objects.map(toJson).toList();
      await set(key, jsonList, expiry: expiryDuration);
    } catch (e) {
      LogUtils.error('CacheService: Erro ao salvar lista para $key: $e');
      throw Exception('Erro ao salvar lista de objetos no cache: $e');
    }
  }

  @override
  Future<List<T>?> getObjectList<T>(
    String key,
    {
      required T Function(Map<String, dynamic> json) fromJson,
      bool ignoreExpiry = false,
    }
  ) async {
    try {
      if (!ignoreExpiry && await isExpired(key)) {
        return null;
      }
      
      final dynamic data = await get(key);
      if (data == null || data is! List) {
        return null;
      }
      
      return data
          .cast<Map<String, dynamic>>()
          .map((map) => fromJson(map))
          .toList();
    } catch (e) {
      LogUtils.error('CacheService: Erro ao recuperar lista para $key: $e');
      return null;
    }
  }

  @override
  Future<bool> hasCacheValid(String key) async {
    try {
      // Verifica se o valor existe e não está expirado
      if (!_prefs.containsKey('cache_$key')) {
        return false;
      }
      
      return !(await isExpired(key));
    } catch (e) {
      LogUtils.error('CacheService: Erro ao verificar validade do cache para $key: $e');
      return false;
    }
  }

  @override
  Future<DateTime?> getLastCacheUpdate(String key) async {
    try {
      final updateTimeStr = _prefs.getString('cache_update_$key');
      if (updateTimeStr == null) {
        return null;
      }
      
      return DateTime.parse(updateTimeStr);
    } catch (e) {
      LogUtils.error('CacheService: Erro ao obter data de atualização para $key: $e');
      return null;
    }
  }
} 
