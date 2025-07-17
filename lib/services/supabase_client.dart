// Flutter imports:
import 'package:flutter/material.dart';

// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:supabase_flutter/supabase_flutter.dart' as gotrue show AuthException;
import 'package:connectivity_plus/connectivity_plus.dart';

// Project imports:
import '../core/errors/app_exception.dart';
import '../utils/log_utils.dart';

export 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;

/// Provider global para o cliente Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Status de conexão com o Supabase
enum SupabaseConnectionStatus {
  /// Conectado e funcionando normalmente
  connected,
  
  /// Desconectado (sem internet)
  disconnected,
  
  /// Conectividade limitada (responde lentamente)
  limited,
  
  /// Status desconhecido
  unknown
}

/// Provider para monitorar o status de conexão do Supabase
final supabaseConnectionStatusProvider = StateProvider<SupabaseConnectionStatus>((ref) {
  return SupabaseConnectionStatus.unknown;
});

/// Observador de mudanças de conexão
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Inicializa o Supabase com as credenciais do .env
Future<void> initializeSupabase() async {
  try {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Credenciais do Supabase não encontradas no .env');
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
    
    LogUtils.info('Supabase inicializado com sucesso', tag: 'Supabase');
  } catch (e, stackTrace) {
    LogUtils.error(
      'Erro ao inicializar Supabase',
      error: e,
      stackTrace: stackTrace,
      tag: 'Supabase',
    );
    rethrow;
  }
}

/// Variáveis globais para controle de conectividade
bool _isOnline = true;
StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

/// Extensão para o SupabaseClient com métodos utilitários adicionais
extension SupabaseClientExtension on SupabaseClient {
  /// Executa uma operação com tratamento de erro padronizado
  Future<T> executeWithErrorHandling<T>({
    required Future<T> Function() operation,
    required String errorMessage,
    bool retryOnNetworkError = false,
    int maxRetries = 2,
  }) async {
    int attempts = 0;
    while (true) {
      try {
        attempts++;
        return await operation();
      } catch (e, stackTrace) {
        // Se atingiu o número máximo de tentativas ou não deve tentar novamente
        if (attempts > maxRetries || !retryOnNetworkError) {
          if (e is PostgrestException) {
            throw AppStorageException(
              message: e.message ?? errorMessage,
              code: e.code,
              originalError: e,
              stackTrace: stackTrace,
            );
          } else if (e is gotrue.AuthException) {
            throw AppAuthException(
              message: e.message,
              code: e.statusCode.toString(),
              originalError: e,
              stackTrace: stackTrace,
            );
          } else if (e is AppStorageException) {
            rethrow;
          } else {
            final connectivityResults = await Connectivity().checkConnectivity();
            final hasConnection = connectivityResults.any((result) => result != ConnectivityResult.none);
            if (!hasConnection) {
              throw NetworkException(
                message: 'Sem conexão com a internet',
                originalError: e,
                stackTrace: stackTrace,
              );
            }
            
            throw AppException(
              message: errorMessage,
              originalError: e,
              stackTrace: stackTrace,
            );
          }
        }
        
        // Aguarda um pouco antes de tentar novamente
        await Future.delayed(Duration(milliseconds: 500 * attempts));
        LogUtils.warning(
          'Tentando novamente operação Supabase (tentativa $attempts)',
          tag: 'Supabase',
        );
      }
    }
  }
}

/// Verifica conectividade com a internet
Future<bool> _hasInternetConnection() async {
  try {
    final connectivityResults = await Connectivity().checkConnectivity();
    // Verifica se há pelo menos uma conexão que não seja 'none'
    return connectivityResults.any((result) => result != ConnectivityResult.none);
  } catch (e) {
    debugPrint('Erro ao verificar conectividade: $e');
    return false;
  }
}

/// Monitor contínuo de conectividade
void _startConnectivityMonitoring() {
  _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
    (results) {
      final isConnected = results.any((result) => result != ConnectivityResult.none);
      _isOnline = isConnected;
      debugPrint('Conectividade alterada: ${isConnected ? 'online' : 'offline'}');
    },
  );
} 