// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/providers.dart';
import '../../../core/router/app_router.dart';
import '../models/auth_state.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';

/// Constante que define o intervalo de verificação periódica em segundo plano (em minutos)
const int BACKGROUND_AUTH_CHECK_INTERVAL_MINUTES = 30;

/// Provider global para o AuthViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository: repository);
});

/// Provider para o repositório de autenticação
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRepository(supabaseClient);
});

/// ViewModel responsável por gerenciar operações relacionadas à autenticação.
class AuthViewModel extends StateNotifier<AuthState> {
  final IAuthRepository _repository;
  String? _redirectPath;
  Timer? _backgroundAuthCheckTimer;

  AuthViewModel({
    required IAuthRepository repository,
    bool checkAuthOnInit = true,
  })  : _repository = repository,
        super(const AuthState.initial()) {
    if (checkAuthOnInit) {
      checkAuthStatus();
    }
    
    // Iniciar verificação periódica em segundo plano
    _startBackgroundAuthCheck();
  }

  /// Inicia a verificação periódica de autenticação em segundo plano
  void _startBackgroundAuthCheck() {
    // Cancele qualquer timer existente
    _backgroundAuthCheckTimer?.cancel();
    
    // Crie um novo timer para verificação periódica
    _backgroundAuthCheckTimer = Timer.periodic(
      Duration(minutes: BACKGROUND_AUTH_CHECK_INTERVAL_MINUTES),
      (_) => _performBackgroundAuthCheck()
    );
    
    debugPrint('🔄 AuthViewModel: Iniciado verificador periódico de autenticação a cada $BACKGROUND_AUTH_CHECK_INTERVAL_MINUTES minutos');
  }
  
  /// Realiza a verificação de autenticação em segundo plano
  /// Esta verificação é silenciosa e não altera o estado para loading
  Future<void> _performBackgroundAuthCheck() async {
    debugPrint('🔄 AuthViewModel: Realizando verificação periódica de autenticação em segundo plano');
    
    try {
      // Verificar se há um usuário autenticado no estado atual
      final isCurrentlyAuthenticated = state.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      
      // Se não estiver autenticado, não precisamos verificar
      if (!isCurrentlyAuthenticated) {
        debugPrint('🔄 AuthViewModel: Estado atual não é autenticado, pulando verificação em segundo plano');
        return;
      }
      
      // Verificar e renovar a sessão se necessário, sem alterar o estado para loading
      await verifyAndRenewSession(silent: true);
      
    } catch (e) {
      // Apenas log, sem alterar o estado
      debugPrint('⚠️ AuthViewModel: Erro em verificação de autenticação em segundo plano: $e');
    }
  }

  @override
  void dispose() {
    // Cancelar o timer quando o ViewModel for descartado
    _backgroundAuthCheckTimer?.cancel();
    super.dispose();
  }

  /// Obtém o caminho para redirecionamento (se existir)
  String? get redirectPath => _redirectPath;

  /// Define o caminho para redirecionamento após login
  void setRedirectPath(String path) {
    _redirectPath = path;
  }

  /// Limpa o caminho de redirecionamento
  void clearRedirectPath() {
    _redirectPath = null;
  }

  /// Extrai a mensagem de erro de uma exceção
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return error.toString();
  }

  /// Verifica o status atual de autenticação
  Future<void> checkAuthStatus() async {
    // Não mudar para loading se já estiver autenticado
    // Isso evita flickering de UI desnecessário
    final isCurrentlyAuthenticated = state.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    // Se não estiver autenticado, mostrar loading
    if (!isCurrentlyAuthenticated) {
      state = const AuthState.loading();
    }
    
    try {
      // Verificar e renovar a sessão se necessário
      final isSessionValid = await verifyAndRenewSession();
      
      // Se já tratamos a sessão e atualizamos o estado, não precisamos fazer mais nada
      if (isSessionValid) {
        return;
      }
      
      // Caso contrário, verificar se há um usuário autenticado
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(
          user: AppUser.fromSupabaseUser(user),
        );
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      // Log de erro, mas não alterar estado para erro
      // Isso evita que um erro de verificação de sessão bloqueie o app
      print("Erro ao verificar status de autenticação: ${e.toString()}");
      // Em caso de erro, considerar como não autenticado
      state = const AuthState.unauthenticated();
    }
  }

  /// Verifica se um email já está registrado
  Future<bool> isEmailRegistered(String email) async {
    try {
      return await _repository.isEmailRegistered(email);
    } catch (e) {
      // Em caso de erro, assumir que o email já existe por precaução
      print("Erro ao verificar email: ${e.toString()}");
      return true;
    }
  }

  /// Marca que o usuário já viu a introdução
  Future<void> _markIntroAsSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      debugPrint('💡 AuthViewModel: Marcando que o usuário já viu a introdução');
      
      // Salvar na SharedPreferences
      final result = await prefs.setBool('has_seen_intro', true);
      if (result) {
        debugPrint('✅ AuthViewModel: Marcado com sucesso que o usuário já viu a introdução (SharedPreferences)');
      } else {
        debugPrint('⚠️ AuthViewModel: Falha ao marcar que o usuário já viu a introdução');
        // Tentar novamente para garantir
        await prefs.setBool('has_seen_intro', true);
      }
      
      // Salvar também no Supabase para garantir persistência entre dispositivos
      try {
        final user = await _repository.getCurrentUser();
        
        if (user != null) {
          await _repository.updateProfile(onboardingSeen: true);
          debugPrint('✅ AuthViewModel: Marcado com sucesso que o usuário já viu a introdução (Supabase)');
        }
      } catch (e) {
        debugPrint('⚠️ AuthViewModel: Erro ao atualizar onboarding_seen no Supabase: $e');
      }
    } catch (e) {
      debugPrint('❌ AuthViewModel: Erro ao marcar introdução como vista: $e');
    }
  }

  /// Realiza login com email e senha
  Future<void> signIn(String email, String password) async {
    try {
      state = const AuthState.loading();
      
      // Verificar formato básico de email
      if (!_isValidEmail(email)) {
        state = const AuthState.error(message: "Por favor, insira um email válido");
        return;
      }
      
      // Verificar senha mínima
      if (password.length < 6) {
        state = const AuthState.error(message: "A senha deve ter pelo menos 6 caracteres");
        return;
      }
      
      debugPrint("🔍 AuthViewModel: Iniciando login com email: $email");
      
      // Tentativa de login sem verificação prévia de email
      try {
      final user = await _repository.signIn(email, password);
        
        debugPrint("✅ AuthViewModel: Login bem-sucedido: ${user.email}");
      
      // Marcar que o usuário já viu a introdução ao logar com sucesso
      await _markIntroAsSeen();
      
        // Atualiza o estado com o usuário autenticado
      state = AuthState.authenticated(
        user: AppUser.fromSupabaseUser(user),
      );
      } catch (loginError) {
        debugPrint("❌ AuthViewModel: Erro no login: $loginError");
        
        // Verificar o tipo de erro para dar feedback apropriado
        final errorMsg = _getErrorMessage(loginError);
        
      if (errorMsg.toLowerCase().contains("invalid login credentials") || 
          errorMsg.toLowerCase().contains("email ou senha incorretos")) {
        state = const AuthState.error(message: "Email ou senha incorretos");
        } else if (errorMsg.toLowerCase().contains("user not found") || 
                  errorMsg.toLowerCase().contains("conta não encontrada")) {
          state = const AuthState.error(message: "Conta não encontrada. Verifique seu email ou crie uma nova conta.");
      } else if (errorMsg.toLowerCase().contains("network")) {
        state = const AuthState.error(message: "Erro de conexão. Verifique sua internet e tente novamente");
      } else {
        state = AuthState.error(message: errorMsg);
      }
      }
    } catch (e) {
      debugPrint("❌ AuthViewModel: Erro geral no processo de login: $e");
      final errorMsg = _getErrorMessage(e);
      state = AuthState.error(message: errorMsg);
    }
  }

  /// Registra um novo usuário
  Future<void> signUp(String email, String password, String name) async {
    try {
      state = const AuthState.loading();
      
      // Validações de dados
      if (!_isValidEmail(email)) {
        state = const AuthState.error(message: "Por favor, insira um email válido");
        return;
      }
      
      if (password.length < 6) {
        state = const AuthState.error(message: "A senha deve ter pelo menos 6 caracteres");
        return;
      }
      
      if (name.isEmpty) {
        state = const AuthState.error(message: "Por favor, insira seu nome");
        return;
      }
      
      // Verificar se o email já está registrado antes de tentar o cadastro
      final emailExists = await isEmailRegistered(email);
      if (emailExists) {
        state = const AuthState.error(message: "Este email já está cadastrado. Por favor, faça login.");
        return;
      }
      
      final user = await _repository.signUp(email, password, name);
      
      // Verificar se há uma sessão ativa (email já verificado ou verificação desabilitada)
      final session = _repository.getCurrentSession();
      
      if (session != null) {
        // Usuário autenticado automaticamente (verificação de email desabilitada)
        debugPrint("✅ AuthViewModel: Usuário cadastrado e autenticado automaticamente: ${user.email}");
        state = AuthState.authenticated(
          user: AppUser.fromSupabaseUser(user),
        );
      } else {
        // Usuário precisa verificar o email antes de logar
        debugPrint("🔍 AuthViewModel: Cadastro realizado, mas verificação de email pendente para: ${user.email}");
        state = AuthState.pendingEmailVerification(
          email: email,
          userId: user.id,
        );
      }
    } catch (e) {
      final errorMsg = _getErrorMessage(e);
      // Melhorar mensagens de erro para o usuário
      if (errorMsg.toLowerCase().contains("already registered") || 
          errorMsg.toLowerCase().contains("já está cadastrado")) {
        state = const AuthState.error(message: "Este email já está cadastrado. Por favor, faça login");
      } else if (errorMsg.toLowerCase().contains("network")) {
        state = const AuthState.error(message: "Erro de conexão. Verifique sua internet e tente novamente");
      } else {
        state = AuthState.error(message: errorMsg);
      }
    }
  }

  /// Reenvia o email de verificação para o email fornecido
  Future<void> resendVerificationEmail(String email) async {
    try {
      state = const AuthState.loading();
      
      if (!_isValidEmail(email)) {
        state = const AuthState.error(message: "Por favor, insira um email válido");
        return;
      }
      
      // Obter a URL de redirecionamento baseada na plataforma
      final String redirectUrl = identical(0, 0.0) 
          ? 'https://rayclub.vercel.app/auth/callback'
          : 'rayclub://login-callback/';
      
      debugPrint("🔍 AuthViewModel: Reenviando email de verificação para: $email");
      
      // Usar o método do Supabase para reenviar email de verificação
      await _repository.resendVerificationEmail(email, redirectUrl);
      
      state = AuthState.pendingEmailVerification(
        email: email,
      );
    } catch (e) {
      debugPrint("❌ AuthViewModel: Erro ao reenviar email de verificação: $e");
      final errorMsg = _getErrorMessage(e);
      state = AuthState.error(message: errorMsg);
    }
  }

  // Validador simples de formato de email
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  /// Realiza logout
  Future<void> signOut() async {
    try {
      state = const AuthState.loading();
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Solicita redefinição de senha para o email
  Future<void> resetPassword(String email) async {
    try {
      state = const AuthState.loading();
      await _repository.resetPassword(email);
      state = const AuthState.success(message: 'Email de redefinição de senha enviado');
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Atualiza o perfil do usuário
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
  }) async {
    try {
      state = const AuthState.loading();
      await _repository.updateProfile(
        name: name,
        photoUrl: photoUrl,
      );

      // Atualiza o estado do usuário atual se autenticado
      state.maybeWhen(
        authenticated: (user) {
          state = AuthState.authenticated(
            user: user.copyWith(
              name: name ?? user.name,
              photoUrl: photoUrl ?? user.photoUrl,
            ),
          );
        },
        orElse: () {},
      );
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }
  
  /// Realiza login com Google
  Future<void> signInWithGoogle() async {
    try {
      state = const AuthState.loading();
      
      debugPrint("🔍 AuthViewModel: Iniciando login com Google");
      
      try {
      // Tenta obter a sessão usando o método de signin do repositório
      final session = await _repository.signInWithGoogle();
      
      debugPrint("🔍 AuthViewModel: Resultado da chamada signInWithGoogle: ${session != null ? 'Sessão obtida' : 'Sessão não obtida'}");
      
        // Se chegou aqui sem exceção, o login foi iniciado corretamente
        // Aguardar um tempo reduzido
        await Future.delayed(const Duration(milliseconds: 500));
      
      // Verifica se foi possível obter uma sessão válida
      if (session != null) {
        debugPrint("✅ AuthViewModel: Sessão obtida com sucesso: ${session.user?.email}");
        
        // Tenta obter o usuário atual
        final user = await _repository.getCurrentUser();
        
        if (user != null) {
          // Login bem-sucedido, usuário autenticado
          debugPrint("✅ AuthViewModel: Usuário encontrado: ${user.email}");
          
          // Marcar que o usuário já viu a introdução ao logar com sucesso
          await _markIntroAsSeen();
          
          state = AuthState.authenticated(
            user: AppUser.fromSupabaseUser(user),
          );
            return; // Sair da função, login bem-sucedido
        } else {
            // Tentar novamente com um intervalo curto
          debugPrint("⚠️ AuthViewModel: Sessão existe mas usuário não encontrado, tentando novamente...");
            await Future.delayed(const Duration(milliseconds: 500));
          final retryUser = await _repository.getCurrentUser();
          
          if (retryUser != null) {
            debugPrint("✅ AuthViewModel: Usuário encontrado na segunda tentativa: ${retryUser.email}");
            
            // Marcar que o usuário já viu a introdução ao logar com sucesso
            await _markIntroAsSeen();
            
            state = AuthState.authenticated(
              user: AppUser.fromSupabaseUser(retryUser),
            );
              return; // Sair da função, login bem-sucedido
            }
          }
        }
        
        // Se chegou aqui sem retornar, houve algum problema no processo de autenticação
        debugPrint("⚠️ AuthViewModel: Processo de autenticação Google não completado");
        
        // Verificar a sessão atual como último recurso
        final currentUser = await _repository.getCurrentUser();
        if (currentUser != null) {
          debugPrint("✅ AuthViewModel: Usuário encontrado na verificação final: ${currentUser.email}");
          
          await _markIntroAsSeen();
          
          state = AuthState.authenticated(
            user: AppUser.fromSupabaseUser(currentUser),
          );
          return; // Autenticação bem-sucedida
        }
        
        // Se ainda não retornou, não foi possível obter uma sessão
        debugPrint("❌ AuthViewModel: Não foi possível completar o login com Google");
        state = const AuthState.error(
          message: 'Não foi possível completar o login. Por favor, tente novamente.',
        );
      } catch (loginError) {
        debugPrint("❌ AuthViewModel: Erro específico no login com Google: $loginError");
        final errorMsg = _getErrorMessage(loginError);
        
        if (errorMsg.toLowerCase().contains("canceled") || 
            errorMsg.toLowerCase().contains("cancelado")) {
          state = const AuthState.error(message: "Login cancelado pelo usuário");
        } else if (errorMsg.toLowerCase().contains("network") || 
                  errorMsg.toLowerCase().contains("conexão")) {
          state = const AuthState.error(message: "Erro de conexão. Verifique sua internet e tente novamente");
        } else {
          state = AuthState.error(message: "Erro no login com Google: $errorMsg");
        }
      }
    } catch (e) {
      // Erros gerais durante o processo de login
      debugPrint("❌ AuthViewModel: Erro geral durante login com Google: $e");
      final errorMsg = _getErrorMessage(e);
      state = AuthState.error(message: "Falha no login com Google: $errorMsg");
    }
  }

  /// Realiza login com Apple
  Future<void> signInWithApple() async {
    try {
      state = const AuthState.loading();
      
      debugPrint("🔍 AuthViewModel: Iniciando login com Apple");
      
      try {
      // Tenta obter a sessão usando o método de signin do repositório
      final session = await _repository.signInWithApple();
      
      debugPrint("🔍 AuthViewModel: Resultado da chamada signInWithApple: ${session != null ? 'Sessão obtida' : 'Sessão não obtida'}");
      
        // Aguarda por um curto período para garantir que a sessão seja processada
        await Future.delayed(const Duration(milliseconds: 500));
      
      // Verifica se foi possível obter uma sessão válida
      if (session != null) {
        debugPrint("✅ AuthViewModel: Sessão obtida com sucesso: ${session.user?.email}");
        
        // Tenta obter o usuário atual
        final user = await _repository.getCurrentUser();
        
        if (user != null) {
          // Login bem-sucedido, usuário autenticado
          debugPrint("✅ AuthViewModel: Usuário encontrado: ${user.email}");
          
          // Marcar que o usuário já viu a introdução ao logar com sucesso
          await _markIntroAsSeen();
          
          state = AuthState.authenticated(
            user: AppUser.fromSupabaseUser(user),
          );
            return; // Sair da função, login bem-sucedido
        } else {
            // Tentar novamente com um intervalo curto
          debugPrint("⚠️ AuthViewModel: Sessão existe mas usuário não encontrado, tentando novamente...");
            await Future.delayed(const Duration(milliseconds: 500));
          final retryUser = await _repository.getCurrentUser();
          
          if (retryUser != null) {
            debugPrint("✅ AuthViewModel: Usuário encontrado na segunda tentativa: ${retryUser.email}");
            
            // Marcar que o usuário já viu a introdução ao logar com sucesso
            await _markIntroAsSeen();
            
            state = AuthState.authenticated(
              user: AppUser.fromSupabaseUser(retryUser),
            );
              return; // Sair da função, login bem-sucedido
            }
          }
        }
        
        // Se chegou aqui sem retornar, houve algum problema no processo de autenticação
        debugPrint("⚠️ AuthViewModel: Processo de autenticação Apple não completado");
        
        // Verificar a sessão atual como último recurso
        final currentUser = await _repository.getCurrentUser();
        if (currentUser != null) {
          debugPrint("✅ AuthViewModel: Usuário encontrado na verificação final: ${currentUser.email}");
          
          await _markIntroAsSeen();
          
          state = AuthState.authenticated(
            user: AppUser.fromSupabaseUser(currentUser),
          );
          return; // Autenticação bem-sucedida
        }
        
        // Se ainda não retornou, não foi possível obter uma sessão
        debugPrint("❌ AuthViewModel: Não foi possível completar o login com Apple");
        state = const AuthState.error(
          message: 'Não foi possível completar o login. Por favor, tente novamente.',
        );
      } catch (loginError) {
        debugPrint("❌ AuthViewModel: Erro específico no login com Apple: $loginError");
        final errorMsg = _getErrorMessage(loginError);
        
        if (errorMsg.toLowerCase().contains("canceled") || 
            errorMsg.toLowerCase().contains("cancelado")) {
          state = const AuthState.error(message: "Login cancelado pelo usuário");
        } else if (errorMsg.toLowerCase().contains("network") || 
                  errorMsg.toLowerCase().contains("conexão")) {
          state = const AuthState.error(message: "Erro de conexão. Verifique sua internet e tente novamente");
        } else {
          state = AuthState.error(message: "Erro no login com Apple: $errorMsg");
        }
      }
    } catch (e) {
      // Erros gerais durante o processo de login
      debugPrint("❌ AuthViewModel: Erro geral durante login com Apple: $e");
      final errorMsg = _getErrorMessage(e);
      state = AuthState.error(message: "Falha no login com Apple: $errorMsg");
    }
  }

  /// Verifica se existe uma sessão ativa e atualiza o estado
  Future<bool> checkAndUpdateSession() async {
    try {
      // Verificação otimizada para dispositivos mais rápidos (iPhone 14)
      final session = _repository.getCurrentSession();
      
      if (session != null) {
        // Log mínimo para reduzir overhead
        debugPrint("✅ Sessão ativa: ${session.user.email?.split('@').first ?? 'desconhecido'}");
        
        // Verificar se o user já existe no estado atual antes de buscar
        bool hasValidUser = false;
        state.maybeWhen(
          authenticated: (user) => hasValidUser = user.id.isNotEmpty,
          orElse: () => hasValidUser = false,
        );
        
        // Se já temos um usuário no estado, não precisamos buscar novamente
        if (hasValidUser) {
          return true;
        }
        
        // Caso contrário, buscar o perfil
        final user = await _repository.getUserProfile();
        if (user != null) {
          state = AuthState.authenticated(
            user: AppUser.fromSupabaseUser(user),
          );
          return true;
        } else {
          // Log reduzido
          debugPrint("❌ Falha ao obter perfil para sessão ativa");
        }
      }
      return false;
    } catch (e) {
      // Log mínimo para erros
      debugPrint('❌ Erro de sessão: ${e.toString().split('\n').first}');
      return false;
    }
  }
  
  /// Verifica se a sessão atual é válida e renova se necessário
  /// Se silent for true, não atualiza o estado para loading
  Future<bool> verifyAndRenewSession({bool silent = false}) async {
    try {
      final session = _repository.getCurrentSession();
      if (session == null) {
        if (!silent) state = const AuthState.unauthenticated();
        return false;
      }
      
      // Verificar se o token está perto de expirar (menos de 1 hora)
      final expiresAt = session.expiresAt;
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      final oneHour = 60 * 60;
      
      if (expiresAt != null && (expiresAt - now) < oneHour) {
        debugPrint("🔄 AuthViewModel: Token próximo de expirar, renovando sessão");
        // Tentar renovar a sessão
        await _repository.refreshSession();
        
        // Verificar se a renovação foi bem-sucedida
        final updatedSession = _repository.getCurrentSession();
        if (updatedSession != null) {
          debugPrint("✅ AuthViewModel: Sessão renovada com sucesso, expira em: ${updatedSession.expiresAt}");
          
          // Atualizar estado com usuário atual
          final user = await _repository.getCurrentUser();
          if (user != null) {
            state = AuthState.authenticated(
              user: AppUser.fromSupabaseUser(user),
            );
          }
        } else {
          debugPrint("❌ AuthViewModel: Falha ao renovar sessão");
          if (!silent) state = const AuthState.unauthenticated();
          return false;
        }
      }
      
      return true;
    } catch (e) {
      debugPrint('❌ AuthViewModel: Erro ao verificar/renovar sessão: ${e.toString()}');
      if (!silent) state = const AuthState.unauthenticated();
      return false;
    }
  }

  /// Navega para a tela inicial após autenticação bem-sucedida
  void _navigateToHomeAfterAuth(BuildContext? context) {
    if (context != null) {
      debugPrint('🔄 AuthViewModel: Navegando para a tela inicial após autenticação');
      debugPrint('🔄 Context mounted: ${context.mounted}');
      debugPrint('🔄 RedirectPath atual: $_redirectPath');
      
      // Usar navegação mais segura para evitar conflitos entre navegadores
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Verificar se o contexto ainda é válido antes de navegar
        if (context.mounted) {
          try {
            debugPrint('🔄 AuthViewModel: Executando navegação...');
            
            // Verificar se há um caminho para redirecionamento
            if (_redirectPath != null && _redirectPath!.isNotEmpty) {
              debugPrint('🔄 AuthViewModel: Redirecionando para: $_redirectPath');
              // Limpar o caminho de redirecionamento e navegar para ele
              final targetPath = _redirectPath!;
              clearRedirectPath();
              context.router.replaceNamed(targetPath);
            } else {
              debugPrint('🔄 AuthViewModel: Navegando para home (padrão)');
              // Navegar para home (rota inicial do app após login)
              context.router.replaceNamed(AppRoutes.home);
            }
            
            debugPrint('✅ AuthViewModel: Navegação executada com sucesso');
          } catch (e) {
            debugPrint('❌ AuthViewModel: Erro na navegação: $e');
            // Fallback: tentar navegar para challenges como segunda opção
            try {
              context.router.replaceNamed(AppRoutes.challenges);
              debugPrint('✅ AuthViewModel: Navegação fallback para challenges executada');
            } catch (fallbackError) {
              debugPrint('❌ AuthViewModel: Erro no fallback de navegação: $fallbackError');
            }
          }
        } else {
          debugPrint('❌ AuthViewModel: Context desmontado, não é possível navegar');
        }
      });
    } else {
      debugPrint('❌ AuthViewModel: Context é null, não é possível navegar');
    }
  }

  /// Método público para navegar para a tela inicial após autenticação
  void navigateToHomeAfterAuth(BuildContext context) {
    _navigateToHomeAfterAuth(context);
  }
  
  /// Método para diagnosticar problemas de autenticação, especialmente em iPads
  Future<Map<String, dynamic>> diagnoseAuthState() async {
    final diagnosticData = <String, dynamic>{};
    try {
      // Verificar estado atual
      diagnosticData['current_state'] = state.runtimeType.toString();
      
      // Verificar sessão
      final session = _repository.getCurrentSession();
      diagnosticData['has_session'] = session != null;
      
      if (session != null) {
        diagnosticData['session_expires_at'] = session.expiresAt;
        diagnosticData['user_email'] = session.user.email;
        diagnosticData['user_id'] = session.user.id;
        
        // Testar obtenção do usuário
        final user = await _repository.getCurrentUser();
        diagnosticData['get_current_user_success'] = user != null;
        
        if (user != null) {
          diagnosticData['user_data'] = {
            'id': user.id,
            'email': user.email,
            'created_at': user.createdAt,
          };
        }
      }
      
      return diagnosticData;
    } catch (e) {
      return {'error': e.toString()};
    }
  }
} 
