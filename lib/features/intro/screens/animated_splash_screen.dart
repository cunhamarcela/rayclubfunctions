// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/providers/user_profile_provider.dart';

/// View Model para gerenciar o estado da tela de splash
final splashViewModelProvider = Provider<SplashViewModel>((ref) {
  return SplashViewModel(ref);
});

/// View Model para a tela de splash
class SplashViewModel {
  final ProviderRef _ref;
  
  SplashViewModel(this._ref);

  /// Verifica se o usuário já viu a introdução de forma robusta
  Future<bool> _hasSeenIntro() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Método 1: Verificar boolean direto
      final boolValue = prefs.getBool('has_seen_intro');
      if (boolValue == true) {
        debugPrint('🔍 SplashViewModel: Flag has_seen_intro encontrada como boolean: true');
        return true;
      }
      
      // Método 2: Verificar valor como string
      final stringValue = prefs.getString('has_seen_intro_str');
      if (stringValue == 'true') {
        debugPrint('🔍 SplashViewModel: Flag has_seen_intro_str encontrada como string: true');
        // Atualizar o valor boolean para consistência
        await prefs.setBool('has_seen_intro', true);
        return true;
      }
      
      // Método 3: Verificar backup
      final backupValue = prefs.getString('intro_seen_backup');
      if (backupValue != null) {
        debugPrint('🔍 SplashViewModel: Flag intro_seen_backup encontrada: $backupValue');
        // Atualizar o valor boolean para consistência
        await prefs.setBool('has_seen_intro', true);
        return true;
      }
      
      // Nenhum método encontrou a flag
      debugPrint('🔍 SplashViewModel: Nenhuma flag de intro_seen encontrada');
      return false;
    } catch (e) {
      debugPrint('❌ SplashViewModel: Erro ao verificar has_seen_intro: $e');
      return false;
    }
  }

  /// Navega para a próxima tela após o tempo de exibição do splash
  void navigateToNextScreen(BuildContext context) {
    Future.delayed(const Duration(seconds: 4), () async {
      if (context.mounted) {
        debugPrint('🔄 SplashViewModel: Iniciando decisão de navegação após splash');
        
        try {
          // Verificar se o usuário está autenticado
          final authViewModel = _ref.read(authViewModelProvider.notifier);
          // Forçar verificação de autenticação para garantir estado atualizado
          await authViewModel.checkAuthStatus();
          
          final authState = _ref.read(authViewModelProvider);
          final isAuthenticated = authState.maybeWhen(
            authenticated: (_) => true,
            orElse: () => false,
          );
          
          // ✅ Se autenticado, pré-carregar perfil do usuário (incluindo accountType)
          if (isAuthenticated) {
            debugPrint('🔄 SplashViewModel: Usuário autenticado, pré-carregando perfil...');
            try {
              final userProfile = await _ref.read(userProfileProvider.future);
              debugPrint('✅ SplashViewModel: Perfil carregado - accountType: ${userProfile?.accountType}');
            } catch (e) {
              debugPrint('⚠️ SplashViewModel: Erro ao carregar perfil: $e');
            }
          }
          
          // Verificar se o usuário já viu a introdução usando método robusto
          final hasSeenIntro = await _hasSeenIntro();
          
          debugPrint('🔄 SplashViewModel: Status - Autenticado: $isAuthenticated, Viu intro: $hasSeenIntro');
          
          // Decidir para qual rota navegar
          if (!isAuthenticated && !hasSeenIntro) {
            // PRIORIDADE 1: Se não está autenticado e nunca viu a intro, mostrar intro primeiro
            debugPrint('🔄 SplashViewModel: Usuário não autenticado e não viu intro, indo para intro');
            if (context.mounted) context.router.replace(const IntroRoute());
          } else if (isAuthenticated) {
            // PRIORIDADE 2: Se está autenticado, ir direto para home
            debugPrint('🔄 SplashViewModel: Usuário autenticado, indo para home');
            if (context.mounted) context.router.replace(const HomeRoute());
          } else {
            // PRIORIDADE 3: Se não está autenticado mas já viu intro, ir para login
            debugPrint('🔄 SplashViewModel: Usuário não autenticado mas já viu intro, indo para login');
            if (context.mounted) context.router.replaceNamed(AppRoutes.login);
          }
        } catch (e) {
          // Em caso de erro na verificação, ir para intro como fallback seguro
          debugPrint('❌ SplashViewModel: Erro ao verificar estado: $e');
          debugPrint('🔄 SplashViewModel: Indo para intro como fallback');
          if (context.mounted) context.router.replace(const IntroRoute());
        }
      }
    });
  }
}

/// Tela de splash animada que reproduz um vídeo
@RoutePage()
class AnimatedSplashScreen extends ConsumerStatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  ConsumerState<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends ConsumerState<AnimatedSplashScreen> with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _useStaticImage = false;
  Timer? _fallbackTimer;
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controlador de animação para fade
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController!);
    
    // Tentar carregar o vídeo primeiro
    _loadVideo();
    
    // Timer de segurança para garantir que navegamos independente do status do vídeo
    // Reduzido para 5 segundos para não ficar muito tempo na tela caso o vídeo falhe
    _fallbackTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        debugPrint('🕒 Fallback timer acionado: navegando para próxima tela');
        final viewModel = ref.read(splashViewModelProvider);
        viewModel.navigateToNextScreen(context);
      }
    });
  }

  Future<void> _loadVideo() async {
    try {
      debugPrint('🎬 Tentando carregar vídeo: assets/images/logos/app/IMG_2426.MOV');
      
      // Inicializar o controlador com o vídeo MOV
      _videoController = VideoPlayerController.asset('assets/images/logos/app/IMG_2426.MOV');
      
      // Inicializar vídeo com timeout para evitar ficar preso
      bool videoInitialized = false;
      
      // Tenta inicializar com timeout para não ficar preso
      try {
        await Future.any([
          _videoController!.initialize().then((_) {
            videoInitialized = true;
          }),
          Future.delayed(const Duration(seconds: 3)).then((_) {
            if (!videoInitialized) {
              throw TimeoutException('Timeout ao inicializar vídeo');
            }
          })
        ]);
      } catch (e) {
        debugPrint('⚠️ Erro ou timeout ao inicializar vídeo: $e');
        _fallbackToStaticImage();
        return;
      }
      
      if (!mounted) return;
      
      debugPrint('✅ Vídeo inicializado: ${_videoController!.value.isInitialized}');
      debugPrint('📏 Tamanho do vídeo: ${_videoController!.value.size.width}x${_videoController!.value.size.height}');
      debugPrint('⏱️ Duração do vídeo: ${_videoController!.value.duration.inMilliseconds}ms');
      
      // Se o vídeo não inicializou corretamente ou tem duração zero, use imagem estática
      if (!_videoController!.value.isInitialized || 
          _videoController!.value.duration.inMilliseconds == 0 ||
          _videoController!.value.size.width == 0) {
        debugPrint('⚠️ Vídeo inicializado incorretamente ou com tamanho/duração zero');
        _fallbackToStaticImage();
        return;
      }
      
      // Configurar para navegação automática ao fim do vídeo
      _videoController!.addListener(() {
        if (!mounted) return;
        
        final position = _videoController!.value.position;
        final duration = _videoController!.value.duration;
        
        // Se o vídeo tem um erro ou a posição "pular" para o final 
        // de repente (o que pode acontecer com formatos problemáticos)
        if (_videoController!.value.hasError) {
          debugPrint('❌ Erro detectado durante reprodução do vídeo');
          _fallbackToStaticImage();
          return;
        }
        
        // Verificar se estamos perto do final do vídeo (90% concluído)
        if (_videoController!.value.isInitialized && 
            position.inMilliseconds >= (duration.inMilliseconds * 0.9) &&
            mounted) {
          debugPrint('✅ Vídeo de splash concluído (${position.inMilliseconds}/${duration.inMilliseconds}), navegando');
          _navigateToNextScreen();
        }
      });
      
      // Atualizar estado e iniciar reprodução
      setState(() {
        _isInitialized = true;
      });
      
      // Configurar reprodução
      _videoController!.setLooping(false);
      _videoController!.setVolume(1.0);
      
      // Iniciar animação de fade
      _fadeController!.forward();
      
      // Reproduzir vídeo
      await _videoController!.play();
      
      debugPrint('▶️ Vídeo iniciado com sucesso');
      
    } catch (e) {
      debugPrint('❌ Erro ao inicializar vídeo: $e');
      _fallbackToStaticImage();
    }
  }
  
  void _fallbackToStaticImage() {
    debugPrint('🖼️ Usando imagem estática como fallback');
    
    // Limpar recursos de vídeo se existirem
    _videoController?.dispose();
    _videoController = null;
    
    if (mounted) {
      setState(() {
        _useStaticImage = true;
        _isInitialized = false;
      });
      
      // Mostrar a imagem com fade in
      _fadeController!.forward();
      
      // Navegar após um curto período
      Future.delayed(const Duration(seconds: 2), () {
        _navigateToNextScreen();
      });
    }
  }
  
  void _navigateToNextScreen() {
    if (mounted && _fallbackTimer != null && !_fallbackTimer!.isActive) {
      // Evitar múltiplas chamadas
      return;
    }
    
    if (mounted && _fallbackTimer != null) {
      _fallbackTimer!.cancel();
      final viewModel = ref.read(splashViewModelProvider);
      viewModel.navigateToNextScreen(context);
    }
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _videoController?.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: _buildContent(),
    );
  }
  
  Widget _buildContent() {
    // Se definido para usar imagem estática ou há erro, mostrar a imagem
    if (_useStaticImage || _hasError) {
      return FadeTransition(
        opacity: _fadeAnimation!,
        child: Container(
          color: AppColors.primary,
          child: Center(
            child: Image.asset(
              'assets/images/logos/app/check.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    
    // Mostrar indicador de carregamento enquanto o vídeo inicializa
    if (!_isInitialized || _videoController == null) {
      return Container(
        color: AppColors.primary,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }
    
    // Se chegou aqui, tenta mostrar o vídeo
    try {
      final screenSize = MediaQuery.of(context).size;
      
      return FadeTransition(
        opacity: _fadeAnimation!,
        child: Container(
          width: screenSize.width,
          height: screenSize.height,
          color: AppColors.primary,
          child: Center(
            child: AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('❌ Erro ao renderizar vídeo: $e');
      // Em caso de erro na renderização, fallback para imagem
      _fallbackToStaticImage();
      return Container(
        color: AppColors.primary,
        child: Center(
          child: Image.asset(
            'assets/images/logos/app/check.png',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
        ),
      );
    }
  }
}