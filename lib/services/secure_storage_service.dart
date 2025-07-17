// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Project imports:
import 'package:ray_club_app/core/di/base_service.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/utils/log_utils.dart';

/// Chaves comuns para armazenamento seguro
class SecureStorageKeys {
  /// Token de autenticação
  static const String authToken = 'auth_token';
  
  /// Token de atualização
  static const String refreshToken = 'refresh_token';
  
  /// ID do usuário atual
  static const String userId = 'user_id';
  
  /// Email do usuário
  static const String userEmail = 'user_email';
  
  /// Senha antiga para verificação
  static const String lastPassword = 'last_password';
  
  /// Consentimento de dados
  static const String dataConsent = 'data_consent';
  
  /// Preferências de notificação
  static const String notificationPrefs = 'notification_prefs';
  
  /// Chave de API para serviços
  static const String apiKey = 'api_key';
  
  /// Sessão atual
  static const String session = 'session';
  
  /// Credenciais biométricas
  static const String biometricAllowed = 'biometric_allowed';
  
  /// Consentimento de localização
  static const String locationConsent = 'location_consent';
  
  static const String prefix = 'ray_club_';
}

/// Exceção específica para falhas de armazenamento seguro
class SecureStorageException extends StorageException {
  SecureStorageException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Serviço para armazenamento seguro de dados sensíveis
class SecureStorageService implements BaseService {
  final FlutterSecureStorage _secureStorage;
  final String _prefix;
  bool _initialized = false;
  
  /// Cria uma instância do serviço de armazenamento seguro
  SecureStorageService({
    FlutterSecureStorage? secureStorage,
    String prefix = SecureStorageKeys.prefix,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
          ),
        _prefix = prefix;
  
  @override
  bool get isInitialized => _initialized;
  
  /// Inicializa o serviço de armazenamento seguro
  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    
    try {
      // Não é necessário reatribuir _secureStorage aqui, já foi inicializado no construtor
      
      // Em ambiente de desenvolvimento, adicionar alguns dados de teste
      if (kDebugMode) {
        final bool hasTestData = await containsKey('test_data_initialized');
        if (!hasTestData) {
          // Encriptar valor de teste antes de salvar
          final testData = {'initialized': true, 'timestamp': DateTime.now().toIso8601String()};
          await writeObject('test_data_initialized', testData);
          
          LogUtils.debug(
            'Dados de teste inicializados no armazenamento seguro',
            tag: 'SecureStorageService',
          );
        }
      }
      
      _initialized = true;
      LogUtils.info(
        'Serviço de armazenamento seguro inicializado',
        tag: 'SecureStorageService',
      );
    } catch (e, stackTrace) {
      final error = SecureStorageException(
        message: 'Erro ao inicializar serviço de armazenamento seguro',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Falha ao inicializar o serviço de armazenamento seguro',
        error: error,
        stackTrace: stackTrace,
        tag: 'SecureStorageService',
      );
      throw error;
    }
  }
  
  /// Salva um valor no armazenamento seguro
  Future<void> writeString(String key, String value) async {
    _ensureInitialized();
    final prefixedKey = _getPrefixedKey(key);
    
    try {
      await _secureStorage.write(key: prefixedKey, value: value);
      LogUtils.debug(
        'Valor salvo no armazenamento seguro',
        tag: 'SecureStorageService',
        data: {'key': key},
      );
    } catch (e, stackTrace) {
      final error = SecureStorageException(
        message: 'Erro ao salvar valor no armazenamento seguro',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Erro ao salvar valor seguro',
        error: error,
        stackTrace: stackTrace,
        tag: 'SecureStorageService',
      );
      throw error;
    }
  }
  
  /// Lê um valor do armazenamento seguro
  Future<String?> readString(String key) async {
    _ensureInitialized();
    final prefixedKey = _getPrefixedKey(key);
    
    try {
      final value = await _secureStorage.read(key: prefixedKey);
      LogUtils.debug(
        'Valor lido do armazenamento seguro',
        tag: 'SecureStorageService',
        data: {'key': key, 'found': value != null},
      );
      return value;
    } catch (e, stackTrace) {
      final error = SecureStorageException(
        message: 'Erro ao ler valor do armazenamento seguro',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Erro ao ler valor seguro',
        error: error,
        stackTrace: stackTrace,
        tag: 'SecureStorageService',
      );
      throw error;
    }
  }
  
  /// Salva um valor booleano no armazenamento seguro
  Future<void> writeBool(String key, bool value) async {
    await writeString(key, value.toString());
  }
  
  /// Lê um valor booleano do armazenamento seguro
  Future<bool?> readBool(String key) async {
    final value = await readString(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }
  
  /// Salva um objeto no armazenamento seguro como JSON
  Future<void> writeObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await writeString(key, jsonString);
  }
  
  /// Lê um objeto do armazenamento seguro como JSON
  Future<Map<String, dynamic>?> readObject(String key) async {
    final jsonString = await readString(key);
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e, stackTrace) {
      LogUtils.warning(
        'Erro ao decodificar JSON do armazenamento seguro',
        tag: 'SecureStorageService',
        data: {'key': key, 'error': e.toString()},
      );
      return null;
    }
  }
  
  /// Verifica se uma chave existe no armazenamento seguro
  Future<bool> containsKey(String key) async {
    _ensureInitialized();
    final prefixedKey = _getPrefixedKey(key);
    
    try {
      final containsKey = await _secureStorage.containsKey(key: prefixedKey);
      return containsKey;
    } catch (e) {
      LogUtils.warning(
        'Erro ao verificar existência de chave no armazenamento seguro',
        tag: 'SecureStorageService',
        data: {'key': key, 'error': e.toString()},
      );
      return false;
    }
  }
  
  /// Remove um valor do armazenamento seguro
  Future<void> deleteValue(String key) async {
    _ensureInitialized();
    final prefixedKey = _getPrefixedKey(key);
    
    try {
      await _secureStorage.delete(key: prefixedKey);
      LogUtils.debug(
        'Valor removido do armazenamento seguro',
        tag: 'SecureStorageService',
        data: {'key': key},
      );
    } catch (e, stackTrace) {
      final error = SecureStorageException(
        message: 'Erro ao remover valor do armazenamento seguro',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Erro ao excluir valor seguro',
        error: error,
        stackTrace: stackTrace,
        tag: 'SecureStorageService',
      );
      throw error;
    }
  }
  
  /// Remove todos os valores do armazenamento seguro
  Future<void> deleteAll() async {
    _ensureInitialized();
    
    try {
      await _secureStorage.deleteAll();
      LogUtils.info(
        'Todos os valores removidos do armazenamento seguro',
        tag: 'SecureStorageService',
      );
    } catch (e, stackTrace) {
      final error = SecureStorageException(
        message: 'Erro ao remover todos os valores do armazenamento seguro',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Falha ao remover todos os valores do armazenamento seguro',
        error: error,
        stackTrace: stackTrace,
        tag: 'SecureStorageService',
      );
      throw error;
    }
  }
  
  /// Obtém todas as chaves do armazenamento seguro
  Future<Map<String, String>> readAll() async {
    _ensureInitialized();
    
    try {
      final allValues = await _secureStorage.readAll();
      
      // Filtrar apenas as chaves com o prefixo e remover o prefixo para o resultado
      final filteredValues = <String, String>{};
      allValues.forEach((key, value) {
        if (key.startsWith(_prefix)) {
          final unprefixedKey = key.substring(_prefix.length);
          filteredValues[unprefixedKey] = value;
        }
      });
      
      LogUtils.debug(
        'Todos os valores lidos do armazenamento seguro',
        tag: 'SecureStorageService',
        data: {'count': filteredValues.length},
      );
      
      return filteredValues;
    } catch (e, stackTrace) {
      final error = SecureStorageException(
        message: 'Erro ao ler todos os valores do armazenamento seguro',
        originalError: e,
        stackTrace: stackTrace,
      );
      LogUtils.error(
        'Falha ao ler todos os valores do armazenamento seguro',
        error: error,
        stackTrace: stackTrace,
        tag: 'SecureStorageService',
      );
      throw error;
    }
  }
  
  @override
  Future<void> dispose() async {
    _initialized = false;
    LogUtils.info('Serviço de armazenamento seguro encerrado', tag: 'SecureStorageService');
  }
  
  /// Verifica se o serviço está inicializado
  void _ensureInitialized() {
    if (!_initialized) {
      throw SecureStorageException(
        message: 'Serviço de armazenamento seguro não inicializado',
        code: 'service_not_initialized',
      );
    }
  }
  
  /// Obtém a chave com prefixo para garantir espaço de nomes isolado
  String _getPrefixedKey(String key) {
    return '$_prefix$key';
  }
} 
