// Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'cache_service.dart';

/// Provider para o serviço de cache inteligente
final smartCacheServiceProvider = Provider<SmartCacheService>((ref) {
  throw UnimplementedError('Precisa ser inicializado com init()');
});

/// Provider para inicialização do serviço de cache inteligente
final smartCacheServiceInitProvider = FutureProvider<SmartCacheService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final smartCache = SmartCacheService(prefs);
  await smartCache.initialize();
  return smartCache;
});

/// Serviço de cache inteligente com suporte a diferentes tipos de dados
/// e estratégias de armazenamento
class SmartCacheService implements CacheService {
  final SharedPreferences _prefs;
  
  /// Cache em memória para acesso mais rápido
  final Map<String, _CacheItem> _memoryCache = {};
  
  /// Diretório para armazenamento de arquivos de cache
  Directory? _cacheDirectory;
  
  /// Tamanho máximo do cache em memória (bytes)
  static const int _MAX_MEMORY_CACHE_SIZE = 10 * 1024 * 1024; // 10 MB
  
  /// Tamanho atual do cache em memória
  int _currentMemoryCacheSize = 0;
  
  /// Lista de chaves ordenadas por último acesso (LRU)
  final List<String> _lruKeys = [];
  
  /// Inicializado?
  bool _isInitialized = false;
  
  /// Construtor
  SmartCacheService(this._prefs);
  
  /// Inicializa o serviço de cache
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        // Inicializa o diretório de cache
        _cacheDirectory = await getTemporaryDirectory();
        
        // Limpa caches antigos
        await _cleanExpiredCache();
        
        _isInitialized = true;
      } catch (e) {
        throw AppException(
          message: 'Erro ao inicializar o cache: $e',
          originalError: e,
        );
      }
    }
  }
  
  @override
  Future<dynamic> get(String key) async {
    // Atualiza a posição da chave na lista LRU
    _updateLRU(key);
    
    // Verifica primeiro no cache em memória (mais rápido)
    if (_memoryCache.containsKey(key)) {
      final item = _memoryCache[key]!;
      
      // Verifica se o item expirou
      if (item.expiresAt != null && item.expiresAt!.isBefore(DateTime.now())) {
        // Remove o item expirado
        await remove(key);
        return null;
      }
      
      return item.value;
    }
    
    // Se não estiver em memória, verifica em disco
    return await _getFromDisk(key);
  }
  
  @override
  Future<bool> set(String key, dynamic value, {Duration? expiry}) async {
    try {
      // Calcula o tempo de expiração
      final DateTime? expiresAt = expiry != null 
          ? DateTime.now().add(expiry) 
          : null;
      
      // Estima o tamanho do valor
      final int valueSize = _estimateValueSize(value);
      
      // Cria o item de cache
      final cacheItem = _CacheItem(
        value: value,
        expiresAt: expiresAt,
        size: valueSize,
      );
      
      // Verifica se precisa liberar espaço no cache em memória
      if (_currentMemoryCacheSize + valueSize > _MAX_MEMORY_CACHE_SIZE) {
        await _freeMemoryCache(valueSize);
      }
      
      // Atualiza o tamanho do cache
      _currentMemoryCacheSize += valueSize;
      
      // Armazena em memória
      _memoryCache[key] = cacheItem;
      
      // Atualiza a lista LRU
      _updateLRU(key);
      
      // Armazena em disco de forma assíncrona
      _saveToDisk(key, cacheItem);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> remove(String key) async {
    try {
      // Remove da memória
      if (_memoryCache.containsKey(key)) {
        final item = _memoryCache.remove(key);
        _currentMemoryCacheSize -= item!.size;
      }
      
      // Remove do LRU
      _lruKeys.remove(key);
      
      // Remove de disco
      await _removeFromDisk(key);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> clear() async {
    try {
      // Limpa a memória
      _memoryCache.clear();
      _currentMemoryCacheSize = 0;
      _lruKeys.clear();
      
      // Limpa dados de cache do SharedPreferences
      final keys = _prefs.getKeys().where((key) => key.startsWith('cache_')).toList();
      for (final key in keys) {
        await _prefs.remove(key);
      }
      
      // Limpa arquivos de cache
      if (_cacheDirectory != null) {
        final cacheDir = Directory('${_cacheDirectory!.path}/app_cache');
        if (await cacheDir.exists()) {
          await cacheDir.delete(recursive: true);
          await cacheDir.create();
        }
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<bool> isExpired(String key) async {
    // Verifica primeiro na memória
    if (_memoryCache.containsKey(key)) {
      final item = _memoryCache[key]!;
      return item.expiresAt != null && item.expiresAt!.isBefore(DateTime.now());
    }
    
    // Verifica nos metadados em disco
    final expiry = await _getExpiryFromDisk(key);
    if (expiry == null) {
      return true; // Se não encontrar, considera expirado
    }
    
    return expiry.isBefore(DateTime.now());
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
      throw AppException(
        message: 'Erro ao salvar lista de objetos no cache: $e',
        originalError: e,
      );
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
      return null;
    }
  }
  
  @override
  Future<bool> hasCacheValid(String key) async {
    // Se estiver em memória e não expirado, está válido
    if (_memoryCache.containsKey(key)) {
      final item = _memoryCache[key]!;
      if (item.expiresAt == null || item.expiresAt!.isAfter(DateTime.now())) {
        return true;
      }
    }
    
    // Verifica se existe em disco e não está expirado
    return !await isExpired(key);
  }
  
  @override
  Future<DateTime?> getLastCacheUpdate(String key) async {
    final updateTimeStr = _prefs.getString('cache_update_$key');
    if (updateTimeStr == null) {
      return null;
    }
    
    try {
      return DateTime.parse(updateTimeStr);
    } catch (e) {
      return null;
    }
  }
  
  /// Atualiza a posição da chave na lista LRU
  void _updateLRU(String key) {
    _lruKeys.remove(key);
    _lruKeys.add(key);
  }
  
  /// Libera espaço no cache em memória
  Future<void> _freeMemoryCache(int neededSpace) async {
    // Remove itens menos usados até liberar o espaço necessário
    int freedSpace = 0;
    
    while (freedSpace < neededSpace && _lruKeys.isNotEmpty) {
      final oldestKey = _lruKeys.removeAt(0); // Remove o mais antigo (início da lista)
      
      if (_memoryCache.containsKey(oldestKey)) {
        final item = _memoryCache.remove(oldestKey)!;
        freedSpace += item.size;
        _currentMemoryCacheSize -= item.size;
      }
    }
  }
  
  /// Estima o tamanho em bytes de um valor
  int _estimateValueSize(dynamic value) {
    if (value == null) return 0;
    
    if (value is String) {
      return value.length * 2; // Aproximadamente 2 bytes por caractere
    } else if (value is int) {
      return 8;
    } else if (value is double) {
      return 8;
    } else if (value is bool) {
      return 1;
    } else if (value is List) {
      return value.fold(0, (sum, item) => sum + _estimateValueSize(item));
    } else if (value is Map) {
      return value.entries.fold(0, 
        (sum, entry) => sum + _estimateValueSize(entry.key) + _estimateValueSize(entry.value)
      );
    } else if (value is Uint8List) {
      return value.length;
    } else {
      // Para outros tipos, tenta converter para JSON e calcular
      try {
        final jsonStr = jsonEncode(value);
        return jsonStr.length * 2;
      } catch (e) {
        return 100; // Valor arbitrário se não puder estimar
      }
    }
  }
  
  /// Recupera um valor do armazenamento em disco
  Future<dynamic> _getFromDisk(String key) async {
    try {
      // Verifica primeiro se temos metadados sobre o item
      final metaKey = 'cache_meta_$key';
      final metaData = _prefs.getString(metaKey);
      
      if (metaData == null) {
        return null; // Não há metadados, não existe em cache
      }
      
      final meta = jsonDecode(metaData) as Map<String, dynamic>;
      
      // Verifica se expirou
      if (meta.containsKey('expires_at') && meta['expires_at'] != null) {
        final expiresAt = DateTime.parse(meta['expires_at']);
        if (expiresAt.isBefore(DateTime.now())) {
          // Remove o item expirado
          await _removeFromDisk(key);
          return null;
        }
      }
      
      // Determina onde o valor está armazenado
      final storageType = meta['storage_type'] as String;
      
      if (storageType == 'prefs') {
        // Valor pequeno, armazenado no SharedPreferences
        final dataKey = 'cache_data_$key';
        final data = _prefs.getString(dataKey);
        
        if (data == null) {
          return null;
        }
        
        // Decodifica conforme o tipo
        final valueType = meta['value_type'] as String;
        return _decodeValue(data, valueType);
      } else if (storageType == 'file') {
        // Valor grande, armazenado em arquivo
        final fileName = meta['file_name'] as String;
        final valueType = meta['value_type'] as String;
        
        final file = File('${_cacheDirectory!.path}/app_cache/$fileName');
        if (!await file.exists()) {
          return null;
        }
        
        final data = await file.readAsString();
        final decoded = _decodeValue(data, valueType);
        
        // Coloca no cache em memória para acesso mais rápido
        final size = _estimateValueSize(decoded);
        
        // Verifica se há espaço
        if (_currentMemoryCacheSize + size > _MAX_MEMORY_CACHE_SIZE) {
          await _freeMemoryCache(size);
        }
        
        // Armazena em memória
        _memoryCache[key] = _CacheItem(
          value: decoded,
          expiresAt: meta.containsKey('expires_at') && meta['expires_at'] != null
              ? DateTime.parse(meta['expires_at'])
              : null,
          size: size,
        );
        
        // Atualiza o tamanho do cache e a lista LRU
        _currentMemoryCacheSize += size;
        _updateLRU(key);
        
        return decoded;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Salva um valor no armazenamento em disco
  Future<void> _saveToDisk(String key, _CacheItem item) async {
    try {
      // Determina o tipo do valor
      final valueType = _getValueType(item.value);
      
      // Metadados comuns
      final meta = <String, dynamic>{
        'key': key,
        'value_type': valueType,
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': item.expiresAt?.toIso8601String(),
      };
      
      // Determina onde armazenar com base no tamanho
      if (item.size < 1024 * 50) { // Menos de 50KB, usa SharedPreferences
        // Codifica o valor
        final encodedValue = _encodeValue(item.value);
        
        // Salva no SharedPreferences
        await _prefs.setString('cache_data_$key', encodedValue);
        
        // Adiciona metadados
        meta['storage_type'] = 'prefs';
        await _prefs.setString('cache_meta_$key', jsonEncode(meta));
      } else {
        // Valor grande, armazena em arquivo
        if (_cacheDirectory == null) {
          throw Exception('Diretório de cache não inicializado');
        }
        
        // Cria diretório de cache se não existir
        final cacheDirPath = '${_cacheDirectory!.path}/app_cache';
        final cacheDir = Directory(cacheDirPath);
        if (!await cacheDir.exists()) {
          await cacheDir.create(recursive: true);
        }
        
        // Gera nome de arquivo único
        final fileName = '${key}_${DateTime.now().millisecondsSinceEpoch}';
        
        // Codifica o valor
        final encodedValue = _encodeValue(item.value);
        
        // Salva em arquivo
        final file = File('$cacheDirPath/$fileName');
        await file.writeAsString(encodedValue);
        
        // Adiciona metadados
        meta['storage_type'] = 'file';
        meta['file_name'] = fileName;
        await _prefs.setString('cache_meta_$key', jsonEncode(meta));
      }
      
      // Registra a data da atualização
      await _prefs.setString('cache_update_$key', DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Erro ao salvar em disco: $e');
    }
  }
  
  /// Remove um valor do armazenamento em disco
  Future<void> _removeFromDisk(String key) async {
    try {
      // Remove metadados
      final metaKey = 'cache_meta_$key';
      final metaData = _prefs.getString(metaKey);
      
      if (metaData != null) {
        final meta = jsonDecode(metaData) as Map<String, dynamic>;
        
        // Se estiver em arquivo, remove o arquivo
        if (meta['storage_type'] == 'file') {
          final fileName = meta['file_name'] as String;
          final file = File('${_cacheDirectory!.path}/app_cache/$fileName');
          if (await file.exists()) {
            await file.delete();
          }
        }
        
        // Remove dados do SharedPreferences
        await _prefs.remove('cache_data_$key');
        await _prefs.remove(metaKey);
      }
      
      // Remove registro de atualização
      await _prefs.remove('cache_update_$key');
    } catch (e) {
      debugPrint('Erro ao remover do disco: $e');
    }
  }
  
  /// Obtém a data de expiração de um item de cache
  Future<DateTime?> _getExpiryFromDisk(String key) async {
    final metaKey = 'cache_meta_$key';
    final metaData = _prefs.getString(metaKey);
    
    if (metaData == null) {
      return null;
    }
    
    try {
      final meta = jsonDecode(metaData) as Map<String, dynamic>;
      
      if (meta.containsKey('expires_at') && meta['expires_at'] != null) {
        return DateTime.parse(meta['expires_at']);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
  
  /// Limpa caches expirados
  Future<void> _cleanExpiredCache() async {
    try {
      // Busca todos os metadados de cache
      final metaKeys = _prefs.getKeys()
          .where((key) => key.startsWith('cache_meta_'))
          .toList();
      
      for (final metaKey in metaKeys) {
        try {
          final metaData = _prefs.getString(metaKey);
          if (metaData == null) continue;
          
          final meta = jsonDecode(metaData) as Map<String, dynamic>;
          final key = meta['key'] as String;
          
          // Verifica se expirou
          if (meta.containsKey('expires_at') && meta['expires_at'] != null) {
            final expiresAt = DateTime.parse(meta['expires_at']);
            if (expiresAt.isBefore(DateTime.now())) {
              await remove(key);
            }
          }
        } catch (e) {
          // Ignora erros em itens individuais
          continue;
        }
      }
    } catch (e) {
      debugPrint('Erro ao limpar cache expirado: $e');
    }
  }
  
  /// Obtém o tipo do valor
  String _getValueType(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return 'string';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is bool) return 'bool';
    if (value is List) return 'list';
    if (value is Map) return 'map';
    return 'json';
  }
  
  /// Codifica um valor para armazenamento
  String _encodeValue(dynamic value) {
    if (value is String) return value;
    try {
      return jsonEncode(value);
    } catch (e) {
      return value.toString();
    }
  }
  
  /// Decodifica um valor conforme seu tipo
  dynamic _decodeValue(String data, String type) {
    switch (type) {
      case 'string':
        return data;
      case 'int':
        return int.tryParse(data);
      case 'double':
        return double.tryParse(data);
      case 'bool':
        return data == 'true';
      case 'list':
      case 'map':
      case 'json':
        try {
          return jsonDecode(data);
        } catch (e) {
          return data;
        }
      default:
        return data;
    }
  }
}

/// Classe interna para representar um item de cache
class _CacheItem {
  final dynamic value;
  final DateTime? expiresAt;
  final int size;
  
  _CacheItem({
    required this.value,
    this.expiresAt,
    required this.size,
  });
} 