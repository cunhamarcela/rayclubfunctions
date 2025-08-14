// Dart imports:
import 'dart:io';
import 'dart:math' as math;

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/config/auth_config.dart';

/// Interface for authentication-related operations
abstract class IAuthRepository {
  /// Gets the currently authenticated user
  /// Returns null if no user is authenticated
  Future<supabase.User?> getCurrentUser();

  /// Gets the currently authenticated user's ID
  /// Returns empty string if no user is authenticated
  Future<String> getCurrentUserId();

  /// Checks if an email is already registered
  /// Returns true if the email exists in the database
  Future<bool> isEmailRegistered(String email);

  /// Signs up a new user with email and password
  /// Throws [ValidationException] if email or password is invalid
  /// Throws [AuthException] if signup fails
  Future<supabase.User> signUp(String email, String password, String name);

  /// Signs in a user with email and password
  /// Throws [ValidationException] if email or password is invalid
  /// Throws [AuthException] if credentials are incorrect
  Future<supabase.User> signIn(String email, String password);

  /// Signs out the current user
  /// Throws [AuthException] if signout fails
  Future<void> signOut();

  /// Resets the password for the given email
  /// Throws [ValidationException] if email is invalid
  /// Throws [AuthException] if reset fails
  Future<void> resetPassword(String email);

  /// Updates the current user's profile
  /// Throws [AuthException] if user is not authenticated
  /// Throws [ValidationException] if data is invalid
  Future<void> updateProfile({
    String? name, 
    String? photoUrl,
    bool? onboardingSeen,
  });

  /// Sign in with Google OAuth
  /// Throws [AuthException] if sign in fails
  Future<supabase.Session?> signInWithGoogle();

  /// Sign in with Apple OAuth
  /// Throws [AuthException] if sign in fails
  Future<supabase.Session?> signInWithApple();

  /// Obtém a sessão atual se existir
  supabase.Session? getCurrentSession();
  
  /// Obtém o perfil do usuário atual
  /// Throws [AuthException] se o usuário não estiver autenticado
  Future<supabase.User?> getUserProfile();

  /// Renova a sessão do usuário atual
  /// Throws [AuthException] se houver erro na renovação
  Future<void> refreshSession();
  
  /// Reenvia o email de verificação para o endereço de email fornecido
  /// Throws [ValidationException] se o email for inválido
  /// Throws [AuthException] se o envio falhar
  Future<void> resendVerificationEmail(String email, String redirectUrl);
}

/// Implementation of [IAuthRepository] using Supabase
class AuthRepository implements IAuthRepository {
  final supabase.SupabaseClient _supabaseClient;
  final GoogleSignIn _googleSignIn;

  AuthRepository(this._supabaseClient) 
    : _googleSignIn = GoogleSignIn() {
    // IMPORTANTE: GoogleSignIn() SEM parâmetros usa automaticamente
    // a configuração do Info.plist, evitando conflitos e crashes
    
    print('');
    print('🏗️ ========== INICIALIZANDO AUTH REPOSITORY ==========');
    print('🏗️ AuthRepository construído em: ${DateTime.now().toIso8601String()}');
    print('🏗️ GoogleSignIn configurado usando Info.plist (SEGURO)');
    print('🏗️ OAuth configurado para usar browser externo temporariamente');
    
    // Validar configuração sem forçar nada
    try {
      AuthConfig.validateConfiguration();
      print('✅ Configuração validada com sucesso');
    } catch (e) {
      print('⚠️ Aviso de configuração: $e');
      // NÃO lançar exceção aqui para não quebrar o app
    }
    
    print('🏗️ ===================================================');
    print('');
  }

  @override
  Future<supabase.User?> getCurrentUser() async {
    try {
      return _supabaseClient.auth.currentUser;
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to get current user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<String> getCurrentUserId() async {
    try {
      final user = await getCurrentUser();
      if (user != null) {
        return user.id;
      } else {
        throw AppAuthException(message: 'No user is authenticated');
      }
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to get current user ID',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<bool> isEmailRegistered(String email) async {
    print('');
    print('🔍 ========== VERIFICAÇÃO DE EMAIL ==========');
    print('🔍 AuthRepository.isEmailRegistered() iniciado');
    print('🔍 Email: $email');
    print('🔍 Timestamp: ${DateTime.now().toIso8601String()}');
    
    try {
      print('🔍 Verificando acesso à tabela profiles...');
      
      // Primeiro verificar se a tabela 'profiles' existe
      try {
        // Tentativa inicial simples para verificar se a tabela existe
        final tableCheck = await _supabaseClient
            .from('profiles')
            .select('count')
            .limit(1);
        
        print('✅ Tabela profiles existe e está acessível');
        print('🔍 Table check result: $tableCheck');
      } catch (tableError) {
        print('⚠️ Erro ao acessar tabela profiles: $tableError');
        
        // Se houver erro ao acessar a tabela, assumir que o email não existe
        // mas logar para investigação
        if (tableError is supabase.PostgrestException) {
          print('⚠️ Código de erro Postgrest: ${tableError.code}');
          print('⚠️ Mensagem de erro: ${tableError.message}');
          print('⚠️ Details: ${tableError.details}');
          print('⚠️ Hint: ${tableError.hint}');
        }
        
        print('⚠️ Assumindo que email não existe devido a erro de tabela');
        print('🔍 ========== FIM VERIFICAÇÃO EMAIL (ERROR) ==========');
        // Para efeitos de login existente, vamos assumir que o email não existe
        // se a tabela não estiver acessível
        return false;
      }
      
      print('🔄 Executando query para verificar email...');
      // Se a tabela existe, verificar o email
      final result = await _supabaseClient
          .from('profiles')
          .select('email')
          .eq('email', email)
          .limit(1)
          .maybeSingle(); // Usa maybeSingle ao invés de single para evitar exceções
      
      print('🔍 Query result: $result');
      
      // Se encontrou resultado, o email existe
      final exists = result != null;
      print('🔍 Email ${email} ${exists ? "EXISTE" : "NÃO EXISTE"} na base de dados');
      print('🔍 ========== FIM VERIFICAÇÃO EMAIL ==========');
      return exists;
      
    } catch (e) {
      // Logar o erro para diagnóstico
      print('⚠️ Erro ao verificar email: $e');
      
      // Se for erro de "não encontrado", retorna false
      if (e is supabase.PostgrestException) {
        print('⚠️ Código de erro Postgrest: ${e.code}');
        print('⚠️ Mensagem: ${e.message}');
        print('⚠️ Details: ${e.details}');
        print('⚠️ Hint: ${e.hint}');
        
        if (e.code == 'PGRST116') {
          print('📝 Erro de não encontrado, o email não existe');
          print('🔍 ========== FIM VERIFICAÇÃO EMAIL (NOT FOUND) ==========');
          return false;
        }
      }
      
      // Durante o login com credenciais existentes, vamos assumir que o email existe
      // para permitir a tentativa de login (better safe than sorry)
      // Durante o cadastro, assumir que não existe pode levar a duplicação de contas
      print('⚠️ Erro genérico, assumindo que o email existe por precaução');
      print('🔍 ========== FIM VERIFICAÇÃO EMAIL (ERROR - ASSUME EXISTS) ==========');
      return true;
    }
  }

  @override
  Future<supabase.User> signUp(
      String email, String password, String name) async {
    print('');
    print('📝 ========== INÍCIO SIGNUP ==========');
    print('📝 AuthRepository.signUp() iniciado');
    print('📝 Email: $email');
    print('📝 Nome: $name');
    print('📝 Device: ${_getPlatform()}');
    print('📝 Timestamp: ${DateTime.now().toIso8601String()}');
    
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      print('❌ AuthRepository.signUp(): Validação falhou - campos obrigatórios vazios');
      throw ValidationException(message: 'Email, password and name are required');
    }

    // Validação adicional para iPad
    if (email.length < 3 || !email.contains('@')) {
      print('❌ AuthRepository.signUp(): Email inválido');
      throw ValidationException(message: 'Por favor, insira um email válido');
    }

    if (password.length < 6) {
      print('❌ AuthRepository.signUp(): Senha muito curta');
      throw ValidationException(message: 'A senha deve ter pelo menos 6 caracteres');
    }

    try {
      print('🔍 AuthRepository.signUp(): Verificando se email já existe...');
      
      // Verificar primeiro se o email já está registrado com timeout
      bool emailExists = false;
      try {
        emailExists = await isEmailRegistered(email).timeout(
          const Duration(seconds: 10),
        );
      } catch (timeoutError) {
        print('⚠️ AuthRepository.signUp(): Timeout na verificação de email, continuando...');
        // Se der timeout, assumir que o email não existe e tentar cadastrar
        emailExists = false;
      }
      
      print('🔍 AuthRepository.signUp(): Email existe? $emailExists');
      
      if (emailExists) {
        print('❌ AuthRepository.signUp(): Email já cadastrado: $email');
        throw AppAuthException(
          message: 'Este email já está cadastrado. Por favor, faça login.',
          code: 'email_already_exists',
        );
      }

      // URL para redirecionamento após verificação de email
      final String redirectUrl = AuthConfig.getConfirmEmailUrl();
      
      // Log detalhado do cadastro
      AuthConfig.logSignUp(email, redirectUrl);
      
      print('🔄 AuthRepository.signUp(): Chamando Supabase Auth...');
      
      // Prosseguir com o registro se o email não existir
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'full_name': name,
          'device_type': _getPlatform(),
          'signup_timestamp': DateTime.now().toIso8601String(),
        },
        emailRedirectTo: redirectUrl, // URL para redirecionamento após verificação
      ).timeout(const Duration(seconds: 30)); // Timeout de 30 segundos

      print('🔍 AuthRepository.signUp(): Response do Supabase recebido');
      print('🔍 User: ${response.user?.id ?? "null"}');
      print('🔍 Session: ${response.session?.accessToken != null ? "presente" : "null"}');

      if (response.user == null) {
        print('❌ AuthRepository.signUp(): Nenhum usuário retornado pelo Supabase');
        throw AppAuthException(
          message: 'Falha no cadastro. Tente novamente em alguns instantes.',
          code: 'signup_failed'
        );
      }
      
      // Verificar se o email precisa ser confirmado
      final needsEmailConfirmation = response.session == null;
      print("🔍 AuthRepository.signUp(): Email verificado: ${!needsEmailConfirmation}");
      print("🔍 AuthRepository.signUp(): Precisa confirmação: $needsEmailConfirmation");
      
      if (needsEmailConfirmation) {
        print("📧 AuthRepository.signUp(): Email de confirmação enviado para $email");
        // Retornar o usuário, mas sem sessão ativa (precisa verificar email)
        // O ViewModel vai tratar essa condição especial
        return response.user!;
      }

      print("✅ AuthRepository.signUp(): Usuário criado e autenticado com sucesso");
      
      // Aguardar um pouco para garantir que o trigger do database execute
      print('⏳ Aguardando criação do perfil...');
      await Future.delayed(const Duration(seconds: 2));
      
      // NOVA FUNCIONALIDADE: Verificar se existe nível pendente para este email
      try {
        print("🔍 AuthRepository.signUp(): Verificando nível de acesso pendente...");
        await _checkPendingUserLevel(response.user!.id, email);
      } catch (e) {
        print("⚠️ AuthRepository.signUp(): Erro ao verificar nível pendente: $e");
        // Não falhar o cadastro por causa disso, apenas logar
      }
      
      print('📝 ========== FIM SIGNUP SUCCESS ==========');
      return response.user!;
      
    } on AppAuthException {
      print('❌ AuthRepository.signUp(): Re-lançando AppAuthException');
      // Re-lançar exceções AuthException já tratadas (como email já existente)
      rethrow;
    } on ValidationException {
      print('❌ AuthRepository.signUp(): Re-lançando ValidationException');
      // Re-lançar exceções de validação
      rethrow;
    } on supabase.AuthException catch (e, stackTrace) {
      print('❌ AuthRepository.signUp(): AuthException capturada');
      print('❌ Code: ${e.statusCode}');
      print('❌ Message: ${e.message}');
      print('❌ StackTrace: $stackTrace');
      
      // Melhor tratamento de erros do Supabase
      String message = 'Erro no cadastro. Tente novamente.';
      
      // Mensagens mais amigáveis para erros comuns
      if (e.message.toLowerCase().contains('already registered') || 
          e.message.toLowerCase().contains('already exists')) {
        message = 'Este email já está cadastrado. Por favor, faça login.';
      } else if (e.message.toLowerCase().contains('weak password')) {
        message = 'A senha é muito fraca. Use pelo menos 6 caracteres com letras e números.';
      } else if (e.message.toLowerCase().contains('invalid email')) {
        message = 'O email fornecido é inválido.';
      } else if (e.message.toLowerCase().contains('rate limit')) {
        message = 'Muitas tentativas de cadastro. Aguarde alguns minutos e tente novamente.';
      } else if (e.message.toLowerCase().contains('network') || 
                 e.message.toLowerCase().contains('connection')) {
        message = 'Erro de conexão. Verifique sua internet e tente novamente.';
      } else if (e.message.toLowerCase().contains('timeout')) {
        message = 'Tempo esgotado. Verifique sua conexão e tente novamente.';
      }
      
      throw AppAuthException(
        message: message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      print('❌ AuthRepository.signUp(): Exceção genérica capturada');
      print('❌ Error: $e');
      print('❌ StackTrace: $stackTrace');
      print('📝 ========== FIM SIGNUP ERROR ==========');
      
      String message = 'Falha ao registrar usuário. Tente novamente.';
      
      // Verificar se é erro de rede ou timeout
      if (e.toString().toLowerCase().contains('network') || 
          e.toString().toLowerCase().contains('connection')) {
        message = 'Erro de conexão. Verifique sua internet e tente novamente.';
      } else if (e.toString().toLowerCase().contains('timeout')) {
        message = 'Tempo esgotado. Verifique sua conexão e tente novamente.';
      }
      
      throw DatabaseException(
        message: message,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<supabase.User> signIn(String email, String password) async {
    print('');
    print('🔐 ========== INÍCIO LOGIN ==========');
    print('🔐 AuthRepository.signIn() iniciado');
    print('🔐 Email: $email');
    print('🔐 Timestamp: ${DateTime.now().toIso8601String()}');
    
    if (email.isEmpty || password.isEmpty) {
      print('❌ AuthRepository.signIn(): Validação falhou - email ou senha vazios');
      throw ValidationException(message: 'Email and password are required');
    }

    try {
      print('🔍 AuthRepository.signIn(): Verificando se email existe...');
      // Antes de tentar login, verificar se o email existe
      final emailExists = await isEmailRegistered(email);
      print('🔍 AuthRepository.signIn(): Email existe? $emailExists');
      
      if (!emailExists) {
        print('❌ AuthRepository.signIn(): Email não encontrado: $email');
        throw AppAuthException(
          message: 'Conta não encontrada. Verifique seu email ou crie uma nova conta.',
          code: 'user_not_found',
        );
      }

      print('🔄 AuthRepository.signIn(): Tentando login com Supabase...');
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('🔍 AuthRepository.signIn(): Response do Supabase recebido');
      print('🔍 User: ${response.user?.id ?? "null"}');
      print('🔍 Session: ${response.session?.accessToken != null ? "presente" : "null"}');
      print('🔍 Email confirmed: ${response.user?.emailConfirmedAt != null}');

      if (response.user == null) {
        print('❌ AuthRepository.signIn(): Nenhum usuário retornado pelo Supabase');
        throw AppAuthException(message: 'Sign in failed: no user returned');
      }

      print('✅ AuthRepository.signIn(): Login realizado com sucesso');
      print('🔐 ========== FIM LOGIN SUCCESS ==========');
      return response.user!;
    } on AppAuthException {
      print('❌ AuthRepository.signIn(): Re-lançando AppAuthException');
      // Re-lançar exceções AuthException já tratadas
      rethrow;
    } on supabase.AuthException catch (e, stackTrace) {
      print('❌ AuthRepository.signIn(): AuthException capturada');
      print('❌ Code: ${e.statusCode}');
      print('❌ Message: ${e.message}');
      print('❌ StackTrace: $stackTrace');
      
      String message = e.message;
      
      // Mensagens mais amigáveis para erros comuns
      if (message.toLowerCase().contains('invalid login')) {
        message = 'Email ou senha incorretos. Por favor, tente novamente.';
      } else if (message.toLowerCase().contains('not confirmed')) {
        message = 'Seu email ainda não foi confirmado. Por favor, verifique sua caixa de entrada.';
      } else if (message.toLowerCase().contains('too many requests')) {
        message = 'Muitas tentativas de login. Por favor, tente novamente mais tarde.';
      } else if (message.toLowerCase().contains('not found') || message.toLowerCase().contains('no user')) {
        message = 'Conta não encontrada. Verifique seu email ou crie uma nova conta.';
      }
      
      throw AppAuthException(
        message: message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      print('❌ AuthRepository.signIn(): Exceção genérica capturada');
      print('❌ Error: $e');
      print('❌ StackTrace: $stackTrace');
      print('🔐 ========== FIM LOGIN ERROR ==========');
      
      throw DatabaseException(
        message: 'Falha ao realizar login: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } on supabase.AuthException catch (e, stackTrace) {
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to sign out user',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    print('');
    print('🔑 ========== INÍCIO RESET SENHA ==========');
    print('🔑 AuthRepository.resetPassword() iniciado');
    print('🔑 Email: $email');
    print('🔑 Timestamp: ${DateTime.now().toIso8601String()}');
    
    if (email.isEmpty) {
      print('❌ AuthRepository.resetPassword(): Email vazio');
      throw ValidationException(message: 'Email is required');
    }

    try {
      // URL para redirecionamento após redefinição de senha - usar sempre a mesma para consistência
      final String redirectUrl = AuthConfig.getResetPasswordUrl();
      
      // Log detalhado do reset de senha
      AuthConfig.logPasswordReset(email, redirectUrl);
      
      print('🔄 AuthRepository.resetPassword(): Chamando Supabase resetPasswordForEmail...');
      await _supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectUrl,
      );
      
      print("✅ AuthRepository.resetPassword(): Email de reset enviado com sucesso");
      print('🔑 ========== FIM RESET SENHA SUCCESS ==========');
      
    } on supabase.AuthException catch (e, stackTrace) {
      print('❌ AuthRepository.resetPassword(): AuthException capturada');
      print('❌ Code: ${e.statusCode}');
      print('❌ Message: ${e.message}');
      print('❌ StackTrace: $stackTrace');
      
      String userMessage = e.message;
      if (e.message.toLowerCase().contains('rate limit')) {
        userMessage = 'Muitas tentativas de reset. Aguarde alguns minutos antes de tentar novamente.';
      } else if (e.message.toLowerCase().contains('not found')) {
        userMessage = 'Email não encontrado. Verifique se você digitou corretamente.';
      } else if (e.message.toLowerCase().contains('invalid email')) {
        userMessage = 'Email inválido. Por favor, digite um email válido.';
      }
      
      throw AppAuthException(
        message: userMessage,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      print('❌ AuthRepository.resetPassword(): Exceção genérica capturada');
      print('❌ Error: $e');
      print('❌ StackTrace: $stackTrace');
      print('🔑 ========== FIM RESET SENHA ERROR ==========');
      
      throw DatabaseException(
        message: 'Failed to reset password',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateProfile({
    String? name, 
    String? photoUrl,
    bool? onboardingSeen,
  }) async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      throw AppAuthException(message: 'User is not authenticated');
    }

    try {
      // Atualizando atributos do usuário
      if (name != null || photoUrl != null) {
        await _supabaseClient.auth.updateUser(
          supabase.UserAttributes(
            data: {
              if (name != null) 'name': name,
              if (photoUrl != null) 'avatar_url': photoUrl,
            },
          ),
        );
      }
      
      // Atualizando campos extras na tabela de perfis
      if (onboardingSeen != null) {
        await _supabaseClient
          .from('profiles')
          .update({'onboarding_seen': onboardingSeen})
          .eq('id', currentUser.id);
      }
    } on supabase.AuthException catch (e, stackTrace) {
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DatabaseException(
        message: 'Failed to update profile',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  @override
  Future<supabase.Session?> signInWithGoogle() async {
    print('');
    print('🔐 ========== INÍCIO GOOGLE OAUTH ==========');
    print('🔐 AuthRepository.signInWithGoogle() iniciado');
    print('🔐 Timestamp: ${DateTime.now().toIso8601String()}');
    
    try {
      // VERIFICAÇÃO DE SEGURANÇA: Testar se GoogleSignIn está configurado
      try {
        print('🔍 Verificando configuração do GoogleSignIn...');
        // Apenas verificar se o GoogleSignIn está acessível
        final isConfigured = _googleSignIn != null;
        print('✅ GoogleSignIn está ${isConfigured ? "configurado" : "NÃO configurado"}');
        
        if (!isConfigured) {
          print('❌ GoogleSignIn não está configurado corretamente');
          throw AppAuthException(
            message: 'Google Sign In não está configurado. Verifique o Info.plist.',
            code: 'google_signin_not_configured'
          );
        }
      } catch (e) {
        print('⚠️ Erro ao verificar GoogleSignIn: $e');
        // Se houver qualquer erro, usar apenas OAuth web
        print('🔄 Fallback para OAuth web apenas');
      }
      
      final platform = _getPlatform();
      print('🔐 Platform detectada: $platform');
      
      // IMPORTANTE: Usar deep link nativo para iOS/Android
      final String redirectUrl = (platform == 'ios' || platform == 'android')
          ? 'rayclub://login-callback/'
          : 'https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback';
      
      print('');
      print('🔍 ========== CONFIGURAÇÃO DE REDIRECIONAMENTO ==========');
      print('🔍 Platform: $platform');
      print('🔍 Redirect URL escolhida: $redirectUrl');
      print('🔍 Tipo de redirect: ${redirectUrl.startsWith('rayclub://') ? "Deep Link Nativo" : "URL HTTPS"}');
      print('🔍 ===================================================');
      print('');
      
      // Log detalhado da tentativa OAuth
      AuthConfig.logOAuthAttempt('Google', platform, redirectUrl);
      
      print('🔄 ========== INICIANDO OAUTH ==========');
      
      try {
        // Para mobile, vamos usar uma estratégia mais robusta
        if (platform == 'ios' || platform == 'android') {
          print('📱 Tentando OAuth com configurações mobile...');
          
          // DIAGNÓSTICO: Imprimir estado atual do Supabase
          print('');
          print('🔍 ========== ESTADO SUPABASE ==========');
          print('🔍 Sessão atual: ${_supabaseClient.auth.currentSession != null ? "presente" : "null"}');
          print('🔍 Usuário atual: ${_supabaseClient.auth.currentUser?.email ?? "não autenticado"}');
          print('🔍 ====================================');
          print('');
          
          // Tentar sem especificar authScreenLaunchMode (como na versão antiga)
          print('🔄 Tentando OAuth sem especificar authScreenLaunchMode...');
          
          final response = await _supabaseClient.auth.signInWithOAuth(
            supabase.OAuthProvider.google,
            redirectTo: redirectUrl,
            // Não especificar authScreenLaunchMode - deixar o Supabase decidir
          );
          
          print('🔍 AuthRepository.signInWithGoogle(): OAuth response: $response');
          
          if (!response) {
            throw AppAuthException(message: 'OAuth falhou - usuário pode ter cancelado');
          }
          
          // Aguardar sessão com timeout (como na versão antiga)
          print('📱 AuthRepository.signInWithGoogle(): Aguardando sessão para mobile...');
          
          int attempts = 0;
          const maxAttempts = 30; // 30 segundos como na versão antiga
          
          while (attempts < maxAttempts) {
            await Future.delayed(const Duration(seconds: 1));
            
            final session = getCurrentSession();
            if (session != null) {
              print('✅ AuthRepository.signInWithGoogle(): Sessão obtida após ${attempts} segundos');
              print('🔐 ========== FIM GOOGLE OAUTH SUCCESS ==========');
              return session;
            }
            
            attempts++;
            print('⏳ OAuth - Aguardando sessão... Tentativa $attempts/$maxAttempts');
          }
          
          print('⚠️ AuthRepository.signInWithGoogle(): Timeout aguardando sessão OAuth');
          throw AppAuthException(message: 'Tempo esgotado aguardando pela sessão do Google');
          
        } else {
          // Para web, usar configuração padrão
          print('🌐 AuthRepository.signInWithGoogle(): OAuth web iniciado');
          
          final response = await _supabaseClient.auth.signInWithOAuth(
            supabase.OAuthProvider.google,
            redirectTo: 'https://rayclub.vercel.app/auth/callback',
          );
          
          if (!response) {
            throw AppAuthException(message: 'OAuth falhou');
          }
          
          return getCurrentSession();
        }
        
      } catch (webError) {
        print('❌ AuthRepository.signInWithGoogle(): Erro no OAuth: $webError');
        
        // DIAGNÓSTICO: Analisar o erro em detalhes
        print('');
        print('🔍 ========== ANÁLISE DO ERRO ==========');
        print('🔍 Tipo do erro: ${webError.runtimeType}');
        print('🔍 Mensagem: $webError');
        if (webError is supabase.AuthException) {
          print('🔍 AuthException Code: ${webError.statusCode}');
          print('🔍 AuthException Message: ${webError.message}');
        }
        print('🔍 =====================================');
        print('');
        
        throw AppAuthException(message: 'Falha no OAuth: $webError');
      }
      
    } catch (e) {
      print('❌ AuthRepository.signInWithGoogle(): Erro geral: $e');
      print('❌ StackTrace: ${StackTrace.current}');
      print('🔐 =====================================');
      print('');
      
      throw AppAuthException(message: 'Falha no login com Google: ${e.toString()}');
    }
  }
  
  @override
  Future<supabase.Session?> signInWithApple() async {
    print('');
    print('🍎 ========== INÍCIO APPLE SIGN IN NATIVO ==========');
    print('🍎 AuthRepository.signInWithApple() iniciado');
    print('🍎 Timestamp: ${DateTime.now().toIso8601String()}');
    
    try {
      final platform = _getPlatform();
      print('🍎 Platform detectada: $platform');
      
      // Verificar se está no iOS/iPadOS
      if (platform != 'ios') {
        throw AppAuthException(
          message: 'Sign in with Apple só está disponível no iOS/iPadOS',
          code: 'platform_not_supported'
        );
      }
      
      print('🍎 Iniciando Sign In with Apple 100% nativo...');
      
      // 1. Verificar se o Sign in with Apple está disponível
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw AppAuthException(
          message: 'Sign in with Apple não está disponível neste dispositivo',
          code: 'apple_signin_not_available'
        );
      }
      
      print('✅ Sign in with Apple está disponível');
      
      // 2. Obter credenciais do Apple usando o pacote nativo SEM nonce
      // O nonce será gerado automaticamente pelo Supabase
      print('🔄 Solicitando credenciais Apple...');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // NÃO especificar nonce - deixar o Supabase gerenciar
      );
      
      print('✅ Credenciais Apple obtidas com sucesso');
      print('🔍 User ID: ${credential.userIdentifier}');
      print('🔍 Email: ${credential.email ?? "não fornecido"}');
      print('🔍 Nome: ${credential.givenName ?? ""} ${credential.familyName ?? ""}');
      print('🔍 Identity Token presente: ${credential.identityToken != null}');
      print('🔍 Authorization Code presente: ${credential.authorizationCode != null}');
      
      // 3. Verificar se temos os tokens necessários
      if (credential.identityToken == null) {
        throw AppAuthException(
          message: 'Token de identidade do Apple não foi fornecido',
          code: 'missing_identity_token'
        );
      }
      
      print('✅ Identity token obtido');
      
      print('🔄 Autenticando no Supabase com credenciais Apple...');
      
      // 4. Autenticar no Supabase usando as credenciais nativas SEM nonce customizado
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.apple,
        idToken: credential.identityToken!,
        // NÃO especificar nonce - deixar o Supabase validar automaticamente
      );
      
      print('🔍 Response do Supabase:');
      print('  - Session presente: ${response.session != null}');
      print('  - User presente: ${response.user != null}');
      
      if (response.session == null) {
        throw AppAuthException(
          message: 'Falha na autenticação: sessão não criada pelo Supabase',
          code: 'session_creation_failed'
        );
      }
      
      if (response.user == null) {
        throw AppAuthException(
          message: 'Falha na autenticação: usuário não criado pelo Supabase', 
          code: 'user_creation_failed'
        );
      }
      
      // 5. Aguardar um pouco para garantir que o trigger do database execute
      print('⏳ Aguardando criação do perfil...');
      await Future.delayed(const Duration(seconds: 2));
      
      // 6. Verificar se o perfil foi criado corretamente
      try {
        await _ensureUserProfile(response.user!);
        print('✅ Perfil verificado/criado com sucesso');
      } catch (e) {
        print('⚠️ Erro ao criar/verificar perfil: $e');
        // Não falhar o login por causa do perfil, mas logar o erro
      }
      
      print('✅ Autenticação Apple concluída com sucesso!');
      print('🔍 User ID: ${response.user!.id}');
      print('🔍 Email: ${response.user!.email ?? "não fornecido"}');
      print('🔍 Provider: ${response.user!.appMetadata['provider'] ?? "não informado"}');
      print('🍎 ========== FIM APPLE SIGN IN SUCCESS ==========');
      
      return response.session;
      
    } on SignInWithAppleAuthorizationException catch (e) {
      print('❌ SignInWithAppleAuthorizationException: $e');
      print('🍎 ========== FIM APPLE SIGN IN ERROR ==========');
      
      // Identificar o tipo de erro específico
      String userMessage;
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          userMessage = 'Login cancelado pelo usuário';
          break;
        case AuthorizationErrorCode.failed:
          userMessage = 'Falha na autenticação com Apple. Verifique sua conexão e tente novamente.';
          break;
        case AuthorizationErrorCode.invalidResponse:
          userMessage = 'Resposta inválida do Apple. Tente novamente em alguns instantes.';
          break;
        case AuthorizationErrorCode.notHandled:
          userMessage = 'Login com Apple não está disponível neste dispositivo.';
          break;
        case AuthorizationErrorCode.unknown:
        default:
          // Para erro 1000, tentar novamente pode resolver
          userMessage = 'Erro temporário no Apple Sign In. Tente novamente em alguns instantes.';
          break;
      }
      
      throw AppAuthException(
        message: userMessage,
        code: e.code.toString(),
        originalError: e,
      );
      
    } on supabase.AuthException catch (e) {
      print('❌ AuthException durante Apple Sign In:');
      print('❌ Code: ${e.statusCode}');
      print('❌ Message: ${e.message}');
      print('🍎 ========== FIM APPLE SIGN IN ERROR ==========');
      
      String userMessage = 'Erro na autenticação. Tente novamente.';
      
      // Mensagens mais específicas baseadas no erro
      if (e.message.toLowerCase().contains('invalid_client')) {
        userMessage = 'Configuração do Apple Sign In inválida. Entre em contato com o suporte.';
      } else if (e.message.toLowerCase().contains('invalid_grant')) {
        userMessage = 'Token do Apple expirou. Tente fazer login novamente.';
      } else if (e.message.toLowerCase().contains('unauthorized')) {
        userMessage = 'Acesso não autorizado. Verifique suas configurações de Apple ID.';
      } else if (e.message.toLowerCase().contains('database error')) {
        userMessage = 'Erro interno do servidor. Tente novamente em alguns instantes.';
      } else if (e.message.toLowerCase().contains('network')) {
        userMessage = 'Erro de conexão. Verifique sua internet e tente novamente.';
      } else if (e.message.toLowerCase().contains('nonces mismatch')) {
        userMessage = 'Erro de sincronização. Tente fazer login novamente.';
      }
      
      throw AppAuthException(
        message: userMessage,
        code: e.statusCode?.toString(),
        originalError: e,
      );
      
    } catch (e, stackTrace) {
      print('❌ Erro geral durante Apple Sign In: $e');
      print('🍎 StackTrace: $stackTrace');
      print('🍎 ========== FIM APPLE SIGN IN ERROR ==========');
      
      String userMessage = 'Erro inesperado no login com Apple. Tente novamente ou use email/senha.';
      
      // Verificar se é erro de rede
      if (e.toString().toLowerCase().contains('network') || 
          e.toString().toLowerCase().contains('connection')) {
        userMessage = 'Erro de conexão. Verifique sua internet e tente novamente.';
      }
      
      throw AppAuthException(
        message: userMessage,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Garante que o perfil do usuário existe após autenticação
  Future<void> _ensureUserProfile(supabase.User user) async {
    try {
      // Verificar se o perfil já existe
      final existingProfile = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      if (existingProfile == null) {
        // Criar perfil se não existir COM account_type = 'basic'
        await _supabaseClient.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'name': user.userMetadata?['full_name'] ?? 
                  user.userMetadata?['name'] ?? 
                  user.email?.split('@').first ?? 
                  'Usuário',
          'account_type': 'basic',  // ✅ CAMPO ADICIONADO PARA GARANTIR BASIC
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        
        print('✅ Perfil criado para usuário ${user.id}');
      } else {
        print('✅ Perfil já existe para usuário ${user.id}');
      }
    } catch (e) {
      print('❌ Erro ao criar/verificar perfil: $e');
      rethrow;
    }
  }

  String _getPlatform() {
    if (identical(0, 0.0)) {
      return 'web';
    }
    
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    
    return 'unknown';
  }

  /// Obtém a sessão atual se existir
  supabase.Session? getCurrentSession() {
    final session = _supabaseClient.auth.currentSession;
    print('');
    print('📋 ========== STATUS SESSÃO ATUAL ==========');
    print('📋 AuthRepository.getCurrentSession() chamado');
    print('📋 Timestamp: ${DateTime.now().toIso8601String()}');
    
    if (session != null) {
      print('✅ Sessão ATIVA encontrada');
      print('📋 User ID: ${session.user.id}');
      print('📋 Email: ${session.user.email ?? "não informado"}');
      print('📋 Access Token presente: ${session.accessToken.isNotEmpty}');
      print('📋 Refresh Token presente: ${session.refreshToken?.isNotEmpty ?? false}');
      print('📋 Expires At: ${session.expiresAt != null ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000) : "não definido"}');
      print('📋 Provider: ${session.user.appMetadata['provider'] ?? "não informado"}');
    } else {
      print('❌ NENHUMA sessão ativa encontrada');
    }
    
    print('📋 ==========================================');
    print('');
    return session;
  }
  
  /// Obtém o perfil do usuário atual
  @override
  Future<supabase.User?> getUserProfile() async {
    print('');
    print('👤 ========== GET USER PROFILE ==========');
    print('👤 AuthRepository.getUserProfile() iniciado');
    print('👤 Timestamp: ${DateTime.now().toIso8601String()}');
    
    try {
      // Apenas retorna o usuário atual do Supabase
      final user = _supabaseClient.auth.currentUser;
      
      if (user != null) {
        print('✅ Usuário atual encontrado');
        print('👤 User ID: ${user.id}');
        print('👤 Email: ${user.email ?? "não informado"}');
        print('👤 Email confirmado: ${user.emailConfirmedAt != null}');
        print('👤 Criado em: ${user.createdAt}');
        print('👤 Última atualização: ${user.updatedAt}');
        print('👤 Provider: ${user.appMetadata['provider'] ?? "email"}');
        print('👤 Role: ${user.role ?? "não definido"}');
      } else {
        print('❌ Nenhum usuário atual encontrado');
      }
      
      print('👤 =======================================');
      print('');
      return user;
    } catch (e, stackTrace) {
      print('❌ Erro ao obter perfil do usuário: $e');
      print('❌ StackTrace: $stackTrace');
      print('👤 =======================================');
      print('');
      
      throw AppAuthException(
        message: 'Falha ao obter perfil do usuário',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Renova a sessão do usuário atual
  @override
  Future<void> refreshSession() async {
    try {
      await _supabaseClient.auth.refreshSession();
    } catch (e, stackTrace) {
      throw AppAuthException(
        message: 'Erro ao renovar sessão',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Reenvia o email de verificação
  @override
  Future<void> resendVerificationEmail(String email, String redirectUrl) async {
    if (email.isEmpty) {
      throw ValidationException(message: 'Email is required');
    }

    try {
      debugPrint("🔍 AuthRepository: Reenviando email de verificação para: $email");
      
      // Se o redirectUrl fornecido estiver vazio, usar o padrão
      String finalRedirectUrl = redirectUrl.isNotEmpty 
          ? redirectUrl 
          : (_getPlatform() == 'web' ? 'https://rayclub.com.br/confirm/' : 'rayclub://login');
      
      debugPrint("🔍 AuthRepository: Usando URL de redirecionamento: $finalRedirectUrl");
      
      // Usar o método Supabase para reenviar o email de verificação
      await _supabaseClient.auth.resend(
        type: supabase.OtpType.signup,
        email: email,
        emailRedirectTo: finalRedirectUrl,
      );
      
      debugPrint("✅ AuthRepository: Email de verificação reenviado com sucesso");
    } on supabase.AuthException catch (e, stackTrace) {
      debugPrint("❌ AuthRepository: Erro AuthException ao reenviar email: ${e.message}");
      throw AppAuthException(
        message: e.message,
        code: e.statusCode?.toString(),
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      debugPrint("❌ AuthRepository: Erro genérico ao reenviar email: $e");
      throw DatabaseException(
        message: 'Falha ao reenviar email de verificação: ${e.toString()}',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Método privado para verificar e aplicar nível pendente
  Future<void> _checkPendingUserLevel(String userId, String email) async {
    try {
      print("🔍 Verificando nível pendente para usuário: $userId, email: $email");
      
      final response = await _supabaseClient.rpc('apply_pending_user_level', 
        params: {
          'user_id_param': userId,
          'email_param': email,
        }
      );
      
      if (response != null) {
        print("✅ Resposta da verificação de nível pendente: $response");
        
        // Log do resultado
        final success = response['success'] ?? false;
        final levelApplied = response['level_applied'] ?? 'basic';
        final message = response['message'] ?? 'Sem mensagem';
        
        print("📊 Nível aplicado: $levelApplied");
        print("📝 Resultado: $message");
        
        if (success && levelApplied != 'basic') {
          print("🎉 Nível premium aplicado com sucesso ao usuário!");
        }
      }
    } catch (e) {
      print("❌ Erro ao verificar nível pendente: $e");
      // Não propagar o erro para não afetar o cadastro
    }
  }
} 
