// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Project imports:
import '../../services/supabase_client.dart';
import '../config/app_config.dart';
import '../offline/offline_operation_queue.dart';

/// Provider global para o cliente Supabase
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider para o status de conexão do Supabase
final supabaseConnectionProvider = StateNotifierProvider<SupabaseConnectionNotifier, SupabaseConnectionStatus>((ref) {
  final connectivityStream = ref.watch(connectivityStreamProvider.stream);
  return SupabaseConnectionNotifier(connectivityStream);
});

/// Notifier para gerenciar o status de conexão com o Supabase
class SupabaseConnectionNotifier extends StateNotifier<SupabaseConnectionStatus> {
  SupabaseConnectionNotifier(Stream<List<ConnectivityResult>> connectivityStream) : super(SupabaseConnectionStatus.unknown) {
    // Verificar conexão inicial
    _checkConnectionStatus();
    
    // Ouvir mudanças de conectividade
    _listenToConnectivityChanges(connectivityStream);
  }
  
  void _listenToConnectivityChanges(Stream<List<ConnectivityResult>> connectivityStream) {
    connectivityStream.listen((results) {
      final hasConnection = results.any((result) => result != ConnectivityResult.none);
      if (!hasConnection) {
        state = SupabaseConnectionStatus.disconnected;
      } else {
        // Ao recuperar a conexão, verifica o status do Supabase
        _checkConnectionStatus();
      }
    });
  }
  
  Future<void> _checkConnectionStatus() async {
    try {
      // Realiza uma operação simples para testar a conexão
      final startTime = DateTime.now();
      await Supabase.instance.client.from('profiles').select('id').limit(1);
      final endTime = DateTime.now();
      
      // Verifica a latência
      final latencyMs = endTime.difference(startTime).inMilliseconds;
      
      if (latencyMs > 2000) {
        state = SupabaseConnectionStatus.limited;
      } else {
        state = SupabaseConnectionStatus.connected;
      }
    } catch (e) {
      state = SupabaseConnectionStatus.disconnected;
    }
  }
}

/// Provider para saber se o app está online com Supabase
final isSupabaseOnlineProvider = Provider<bool>((ref) {
  final connectionStatus = ref.watch(supabaseConnectionProvider);
  return connectionStatus == SupabaseConnectionStatus.connected || 
         connectionStatus == SupabaseConnectionStatus.limited;
});

/// Provider para a fila de operações offline
final offlineOperationQueueProvider = Provider<OfflineOperationQueue>((ref) {
  return OfflineOperationQueue();
});

/// Provider para inicialização do Supabase
final supabaseInitProvider = FutureProvider<SupabaseClient>((ref) async {
  final supabase = await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
  return supabase.client;
}); 
