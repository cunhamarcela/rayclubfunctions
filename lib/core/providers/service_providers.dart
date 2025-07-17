// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
// Anteriormente comentado - agora vamos usar a implementação completa
import 'package:ray_club_app/services/remote_logging_service.dart';
import 'package:ray_club_app/services/secure_storage_service.dart';
import 'package:ray_club_app/services/storage_service.dart';
import 'package:ray_club_app/services/supabase_storage_service.dart';
import 'package:ray_club_app/services/deep_link_service.dart';
import '../services/cache_service.dart';
import '../services/logging_service.dart';
import '../offline/offline_operation_queue.dart';
import '../offline/offline_repository_helper.dart';
import '../services/connectivity_service.dart';
import 'dio_provider.dart';
import 'environment_provider.dart';
import '../../services/qr_service.dart';
// Reexportando o provider de conectividade do arquivo específico
export '../services/connectivity_service.dart' show connectivityServiceProvider;

/// Provider para o serviço de logging remoto
final remoteLoggingServiceProvider = Provider<LoggingService>((ref) {
  final dio = ref.watch(dioProvider);
  
  // Criamos uma instância da implementação completa que agora implementa LoggingService
  final service = RemoteLoggingService(dio: dio);
  
  // Inicializamos o serviço
  service.initialize();
  
  // Garantir que o serviço seja disposto quando o provider for destruído
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});

/// Provider para o serviço de armazenamento
final storageServiceProvider = Provider<StorageService>((ref) {
  // Obter o cliente Supabase através da configuração
  final supabase = Supabase.instance.client;
  
  // Criar uma instância do serviço de armazenamento Supabase
  final service = SupabaseStorageService(supabaseClient: supabase);
  
  // Inicializar o serviço durante a criação
  service.initialize();
  
  // Garantir que o serviço seja descartado quando o provider for destruído
  ref.onDispose(() {
    // Chamada de dispose segura
    try {
      service.dispose();
    } catch (e) {
      // Ignora erros durante o dispose para evitar crashes na finalização
    }
  });
  
  return service;
});

/// Provider para o serviço de armazenamento seguro
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Provider para o serviço de deep links
final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  final deepLinkService = DeepLinkService();
  // Inicializar o serviço
  deepLinkService.initialize();
  
  // Garantir a liberação de recursos ao destruir o provider
  ref.onDispose(() {
    deepLinkService.dispose();
  });
  
  return deepLinkService;
});

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('This provider should be overridden with an instance in main.dart');
});

/// Provider para o serviço de geração de QR Code
final qrServiceProvider = Provider<QRService>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return QRService(
    secureStorage: secureStorage,
    connectivityService: connectivityService,
  );
});

/// Provider para o OfflineRepositoryHelper
final offlineRepositoryHelperProvider = Provider<OfflineRepositoryHelper>((ref) {
  final operationQueue = ref.watch(offlineOperationQueueProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return OfflineRepositoryHelper(
    operationQueue: operationQueue,
    connectivityService: connectivityService,
  );
}); 
