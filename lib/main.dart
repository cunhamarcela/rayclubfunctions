// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

// Project imports:
import 'package:ray_club_app/utils/performance_monitor.dart';
import 'package:ray_club_app/utils/db_field_utils.dart';
import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/config/production_config.dart';
import 'core/constants/app_colors.dart';
import 'core/di/service_locator.dart';
import 'core/errors/error_handler.dart';
import 'core/providers/service_providers.dart';
import 'core/router/app_router.dart';
import 'core/router/deep_link_handler.dart';
import 'core/services/cache_service.dart';
import 'services/deep_link_service.dart';
import 'core/config/theme.dart';
import 'services/database_verification_service.dart';
import 'core/utils/env_validator.dart';
import 'utils/timezone_checker.dart';
import 'core/app_startup.dart';

// Adicionar no topo do arquivo, após os imports existentes
import 'dart:async';

/// Entry point of the application
void main() async {
  // Run the app with centralized error handling via Sentry
  await ErrorHandler.initializeSentry(
    appRunner: () async {
      try {
        await _initializeApp();
      } catch (e, stackTrace) {
        debugPrint('Fatal error during initialization: $e\n$stackTrace');
        runApp(const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text(
                'Erro ao inicializar o aplicativo.\nPor favor, tente novamente.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
        
        // Capture the initialization error in Sentry
        await Sentry.captureException(e, stackTrace: stackTrace);
      }
    },
    tracesSampleRate: 1.0,
    profilesSampleRate: 1.0,
  );
}

/// Função principal de inicialização que será encapsulada com tratamento de erros
Future<void> _initializeApp() async {
  debugPrint('🟢 MAIN ATUAL EXECUTADA');
  
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for locales
  await initializeDateFormatting('pt_BR', null);
  Intl.defaultLocale = 'pt_BR';

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Carregar variáveis de ambiente
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ Arquivo .env carregado com sucesso');
  } catch (e) {
    debugPrint('⚠️ Arquivo .env não encontrado: $e');
    
    // Em modo release, usar configurações de produção hardcoded
    if (kReleaseMode) {
      debugPrint('🔧 Carregando configurações de produção...');
      await ProductionConfig.initialize();
    } else {
      // Em desenvolvimento, o .env é obrigatório
      debugPrint('❌ ERRO: Arquivo .env é obrigatório em desenvolvimento');
      debugPrint('💡 Crie um arquivo .env na raiz do projeto com as configurações necessárias');
      // Continuar mesmo assim para permitir debug
    }
  }

  // Validar variáveis de ambiente
  final isEnvValid = EnvValidator.validateEnvironment();
  if (!isEnvValid) {
    debugPrint('⚠️ AVISO: Ambiente não configurado corretamente!');
    // Em modo de desenvolvimento, registrar as variáveis disponíveis
    if (kDebugMode) {
      EnvValidator.logEnvironment();
    }
  }

  // Initialize app configuration
  await AppConfig.initialize();
  
  // Validar se o ambiente está configurado corretamente
  try {
    if (!EnvironmentManager.validateEnvironment()) {
      throw ConfigurationException('Configuração de ambiente incompleta!');
    }
    debugPrint('✅ Ambiente validado com sucesso');
  } catch (e) {
    debugPrint('⚠️ ERRO DE CONFIGURAÇÃO: $e');
    // Continuar a execução com valores padrão se possível
    // ou exibir uma tela de erro se as configurações forem críticas
  }
  
  debugPrint('✅ AppConfig inicializado (Ambiente: ${EnvironmentManager.current})');

  // Initialize Supabase client
  await Supabase.initialize(
    url: EnvironmentManager.supabaseUrl,
    anonKey: EnvironmentManager.supabaseAnonKey,
    debug: EnvironmentManager.debugMode,
  );
  debugPrint('✅ Supabase inicializado');

  // Inicializar utilitário de compatibilidade
  await DbFieldUtils.initialize();
  debugPrint('✅ DbFieldUtils inicializado');

  // Adicionar verificação de tabelas necessárias usando o serviço dedicado
  try {
    debugPrint('🔍 Verificando integridade do banco de dados Supabase');
    final dbVerificationService = DatabaseVerificationService(Supabase.instance.client);
    await dbVerificationService.printDiagnostics();
  } catch (e) {
    debugPrint('⚠️ Erro ao verificar integridade do banco de dados: $e');
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Check and print the current value of has_seen_intro
  final hasSeenIntro = prefs.getBool('has_seen_intro');
  debugPrint('🔍 Current has_seen_intro value: $hasSeenIntro');
  
  // FORCE RESET the has_seen_intro flag to false for testing
  // This ensures the intro screen is always shown first
  await prefs.setBool('has_seen_intro', false);
  debugPrint('⚠️ FORCED RESET: has_seen_intro flag set to false for testing');
  
  // DO NOT mark has_seen_intro as true during initialization
  // It should only be marked after the user actually sees the intro
  
  debugPrint('✅ SharedPreferences inicializado');

  // Initialize dependencies
  await initializeDependencies();
  debugPrint('✅ Dependências inicializadas');
  
  // Cria um observador que será configurado após a criação do container
  final appObserver = AppProviderObserver();
  
  // Criar o CacheService que será usado no container
  final cacheService = SharedPrefsCacheService(prefs);
  
  // Criar o container para os providers com os overrides necessários
  final container = ProviderContainer(
    observers: [appObserver],
    overrides: [
      // Sobrescrever o provider do CacheService com uma instância já inicializada
      cacheServiceProvider.overrideWithValue(cacheService),
      // Sobrescrever o provider do SharedPreferences com a instância já inicializada
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );
  
  // Agora que o container existe, configuramos o observador com ele
  appObserver.setContainer(container);
  
  // Configurar o PerformanceMonitor para monitorar operações críticas
  PerformanceMonitor.setRemoteLoggingService(container.read(remoteLoggingServiceProvider));

  // Configurar deferred loading para otimização do tamanho do aplicativo
  if (kReleaseMode) {
    // Pré-carregar bibliotecas principais
    await _preloadCoreLibraries();
  }

  // Pré-carregamento de fontes para evitar problemas com o Impeller
  await precacheFontFamilies();

  // Executar o aplicativo com o container configurado
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
  debugPrint('🚀 App inicializado e rodando');

  // Adicionar diagnóstico de Deep Link após inicialização
  WidgetsBinding.instance.addPostFrameCallback((_) {
    // Iniciar o serviço de deep links para toda a aplicação
    final deepLinkService = getIt<DeepLinkService>();
    deepLinkService.initializeDeepLinks();
    
    if (kDebugMode) {
      deepLinkService.printDeepLinkInfo();
    }
  });

  // Testar timezone para debug
  await TimezoneChecker.testTimezone();
  final timezoneInfo = TimezoneChecker.getTimezoneInfo();
  debugPrint('🕒 Timezone do dispositivo: ${timezoneInfo['timezone_offset_hours']}h');
  debugPrint('🕒 É timezone de Brasília (UTC-3)? ${timezoneInfo['is_brasilia_timezone'] ? 'Sim' : 'Não'}');
}

/// Carrega bibliotecas principais de forma otimizada
Future<void> _preloadCoreLibraries() async {
  // Implementar lazy loading para features menos usadas
  unawaited(_initializeDeferredLibraries());
}

/// Inicializa bibliotecas sob demanda para reduzir o tamanho inicial do app
Future<void> _initializeDeferredLibraries() async {
  // Esta função será chamada após o app iniciar
  // Carregar bibliotecas em segundo plano para melhorar o tempo de inicialização
  
  // Exemplo de uso:
  // await DeferredFeature.ensureInitialized();
}

/// Pré-carrega fontes utilizadas na aplicação para evitar problemas de renderização com o Impeller
Future<void> precacheFontFamilies() async {
  // Skip loading Poppins fonts as they appear to be empty files
  
  // Carrega as fontes Century Gothic
  final fontLoaderCentury = FontLoader('CenturyGothic');
  fontLoaderCentury.addFont(rootBundle.load('assets/fonts/Century-Gothic.ttf'));
  fontLoaderCentury.addFont(rootBundle.load('assets/fonts/Century-Gothic-Bold.TTF')); // Note the uppercase TTF
  
  // Carrega as fontes Stinger
  final fontLoaderStinger = FontLoader('Stinger');
  fontLoaderStinger.addFont(rootBundle.load('assets/fonts/Stinger-Regular.ttf'));
  fontLoaderStinger.addFont(rootBundle.load('assets/fonts/Stinger-Bold.ttf'));
  
  // Aguarda o carregamento de todas as fontes
  await Future.wait([
    fontLoaderCentury.load(),
    fontLoaderStinger.load(),
  ]);
}

/// Main application widget
class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    
    // Inicializar listeners e componentes após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Inicializar listeners globais do app
      await initializeAppListeners(ref);
      
      // Configurar listener para mudanças de autenticação
      setupAuthStateChangeListener(ref);
      
      // Inicializar o handler de deep links (o próprio handler configura os listeners)
      ref.read(deepLinkHandlerProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔍 Building MyApp');
    return Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(appRouterProvider);
        debugPrint('🔍 Configurando router - rota inicial: ${AppRoutes.intro}');
        
        return MaterialApp.router(
          title: 'Ray Club',
          theme: AppTheme.lightTheme,
          routerConfig: router.config(),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('pt', 'BR'),
          ],
        );
      },
    );
  }
}

/// Global navigator key for use throughout the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
