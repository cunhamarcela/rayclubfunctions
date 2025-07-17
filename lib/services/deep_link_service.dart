import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

// Project imports:
import '../core/di/base_service.dart';

/// Serviço para gerenciar deep links no aplicativo
class DeepLinkService implements BaseService {
  // Singleton instance
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  // AppLinks instance
  final _appLinks = AppLinks();

  // Stream controller para enviar eventos de deep link
  final _deepLinkStreamController = StreamController<Uri?>.broadcast();
  
  // Stream para ouvir eventos de deep link
  Stream<Uri?> get deepLinkStream => _deepLinkStreamController.stream;
  
  // Stream subscription para o listener de links
  StreamSubscription? _linkSubscription;
  
  bool _initialized = false;
  
  @override
  bool get isInitialized => _initialized;
  
  /// Inicializa o serviço e começa a ouvir deep links
  @override
  Future<void> initialize() async {
    if (_initialized) return;
    
    debugPrint("🔍 DeepLinkService: Inicializando serviço de deep links");
    
    // Inicialização em duas etapas - primeiro configurar listeners, depois processar inicial
    await _configureListeners();
    await _processInitialLink();
    
    // Marca como inicializado apenas se chegou até aqui sem erros
    _initialized = true;
    debugPrint("✅ DeepLinkService: Serviço inicializado com sucesso");
    
    // Diagnóstico de configuração
    printDeepLinkInfo();
  }
  
  /// Configurar os listeners para links
  Future<void> _configureListeners() async {
    try {
      // Configura listener para URIs usando app_links
      _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
        debugPrint("🔍 DeepLinkService: Evento de link recebido (URI): $uri");
        _processIncomingUri(uri);
      }, onError: (e) {
        debugPrint('❌ DeepLinkService: Erro no stream de URIs: $e');
      });
      
      debugPrint("✅ DeepLinkService: Listener de URIs configurado com sucesso");
    } catch (e) {
      debugPrint('❌ DeepLinkService: Erro ao configurar listener: $e');
    }
  }
  
  /// Processa o link inicial que pode ter aberto o app
  Future<void> _processInitialLink() async {
    try {
      // Obtém o link inicial usando app_links
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint("🔍 DeepLinkService: Link inicial detectado: $initialUri");
        _processIncomingUri(initialUri);
        return;
      }
      
      debugPrint("🔍 DeepLinkService: Nenhum link inicial detectado");
    } catch (e) {
      debugPrint('❌ DeepLinkService: Erro ao obter link inicial: $e');
    }
  }
  
  /// Processa um URI recebido
  void _processIncomingUri(Uri uri) {
    try {
      debugPrint("✅ DeepLinkService: Processando URI: ${uri.toString()}");
      debugPrint("✅ DeepLinkService: Esquema: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}");
            
      // Emite o evento
      _deepLinkStreamController.add(uri);
            
      // Processa especificamente para autenticação
      if (isAuthLink(uri)) {
        debugPrint("🔑 DeepLinkService: Detectado link de autenticação!");
        
        // Determina qual tipo de link de autenticação 
        if (uri.host == 'reset-password') {
          debugPrint("🔑 DeepLinkService: Link de redefinição de senha");
        } else if (uri.host == 'login' || uri.host == 'login-callback') {
          debugPrint("🔑 DeepLinkService: Link de login/callback");
        }
              
        // Log detalhado para diagnóstico
        if (uri.fragment.isNotEmpty) {
          debugPrint("🔑 DeepLinkService: Informações no fragmento: ${uri.fragment}");
        }
              
        if (uri.queryParameters.isNotEmpty) {
          debugPrint("🔑 DeepLinkService: Parâmetros de consulta: ${uri.queryParameters}");
        }
      }
    } catch (e) {
      debugPrint('❌ DeepLinkService: Erro ao processar URI recebido: $e');
    }
  }
  
  /// Força a captura manual de um link
  void processLink(String link) {
    try {
      debugPrint('🔍 DeepLinkService: Processando link manualmente: $link');
      final uri = Uri.parse(link);
      _deepLinkStreamController.add(uri);
      debugPrint('✅ DeepLinkService: Link manual processado com sucesso');
    } catch (e) {
      debugPrint('❌ DeepLinkService: Erro ao processar link manualmente: $e');
    }
  }
  
  /// Encerra o serviço, cancelando os listeners
  @override
  Future<void> dispose() async {
    if (!_initialized) return;
    
    debugPrint("🔍 DeepLinkService: Encerrando serviço de deep links");
    await _linkSubscription?.cancel();
    await _deepLinkStreamController.close();
    _initialized = false;
  }
  
  /// Verifica se um link é um link de autenticação
  bool isAuthLink(Uri uri) {
    // Esquema padrão para deep linking no app
    final isRayClubScheme = uri.scheme == 'rayclub';
    
    // Verifica todos os caminhos de autenticação suportados
    final isLoginPath = uri.host == 'login' || uri.host == 'login-callback';
    final isResetPasswordPath = uri.host == 'reset-password';
    
    final isAuth = isRayClubScheme && (isLoginPath || isResetPasswordPath);
    
    debugPrint('🔍 DeepLinkService: Verificando link $uri');
    debugPrint('🔍 DeepLinkService: Esquema: ${uri.scheme} (esperado: rayclub) - Match: $isRayClubScheme');
    debugPrint('🔍 DeepLinkService: Host: ${uri.host}');
    debugPrint('🔍 DeepLinkService: É link de autenticação: $isAuth');
    
    return isAuth;
  }
  
  /// Método para exibir informações sobre a configuração do deep link
  void printDeepLinkInfo() {
    debugPrint('🔍 ----- INFORMAÇÕES DE DEEP LINKING -----');
    debugPrint('🔍 DeepLinkService inicializado: $_initialized');
    debugPrint('🔍 Formatos esperados de URL:'); 
    debugPrint('🔍   - rayclub://login-callback/ (OAuth callback)');
    debugPrint('🔍   - rayclub://login (confirmação de email)');
    debugPrint('🔍   - rayclub://reset-password (redefinição de senha)');
    debugPrint('🔍 Configuração necessária:');
    debugPrint('🔍   - Android: <data android:scheme="rayclub" />');
    debugPrint('🔍   - iOS: CFBundleURLSchemes array com <string>rayclub</string>');
    debugPrint('🔍   - iOS: FlutterDeepLinkingEnabled key com <true/>');
    debugPrint('🔍   - Supabase: URLs de redirecionamento:');
    debugPrint('🔍       - https://rayclub.com.br/confirm/');
    debugPrint('🔍       - https://rayclub.com.br/reset-password/');
    debugPrint('🔍       - https://rayclub.com.br/auth/callback/');
    
    // Testar reconhecimento com links de exemplo
    final testUri1 = Uri.parse('rayclub://login-callback/');
    final testUri2 = Uri.parse('rayclub://login');
    final testUri3 = Uri.parse('rayclub://reset-password');
    
    debugPrint('🔍 Teste URI 1: $testUri1 => isAuthLink: ${isAuthLink(testUri1)}');
    debugPrint('🔍 Teste URI 2: $testUri2 => isAuthLink: ${isAuthLink(testUri2)}');
    debugPrint('🔍 Teste URI 3: $testUri3 => isAuthLink: ${isAuthLink(testUri3)}');
    debugPrint('🔍 ----- FIM DAS INFORMAÇÕES DE DEEP LINKING -----');
  }

  /// Inicializa os listeners de deep links para toda a aplicação
  void initializeDeepLinks() async {
    debugPrint('🔗 Inicializando serviço de deep links');
    
    try {
      // Configurar listener para links recebidos quando o app já está aberto
      _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
        if (uri != null) {
          debugPrint('🔗 Deep link recebido com app aberto: $uri');
          processLink(uri.toString());
          _deepLinkStreamController.add(uri);
        }
      }, onError: (error) {
        debugPrint('❌ Erro no listener de deep links: $error');
      });
      
      // Verificar se o app foi aberto por um link
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        debugPrint('🔗 App aberto por deep link: $initialUri');
        processLink(initialUri.toString());
        _deepLinkStreamController.add(initialUri);
      }
      
      debugPrint('✅ Serviço de deep links inicializado com sucesso');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar deep links: $e');
    }
  }
} 