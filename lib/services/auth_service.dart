// Dart imports:
import 'dart:async';

// Package imports:
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Project imports:
import '../core/di/base_service.dart';
import '../core/errors/app_exception.dart';
import '../models/user.dart';
import 'package:ray_club_app/core/config/auth_config.dart';

class AuthService implements BaseService {
  final supabase.SupabaseClient _supabaseClient;
  final SharedPreferences _prefs;
  final GoogleSignIn _googleSignIn;
  bool _initialized = false;

  AuthService({
    required supabase.SupabaseClient supabaseClient,
    required SharedPreferences prefs,
  })  : _supabaseClient = supabaseClient,
        _prefs = prefs,
        _googleSignIn = GoogleSignIn(
          clientId: AuthConfig.googleWebClientId,
        ) {
    print('⚠️ AuthService: GoogleSignIn configurado com Web Client ID: ${AuthConfig.googleWebClientId}');
    print('⚠️ IMPORTANTE: Usando mesma configuração do AuthRepository para evitar conflitos');
  }

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  Future<AppUser?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        final user = await _syncUserProfile(response.user!);
        await _saveSession(response.session!);
        return user;
      }
      return null;
    } catch (e) {
      throw AppAuthException(
        message: _getErrorMessage(e),
        originalError: e,
      );
    }
  }

  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        throw AppAuthException(
          message: 'Não foi possível obter o token de autenticação do Google',
        );
      }
      
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null && response.session != null) {
        final user = await _syncUserProfile(response.user!);
        await _saveSession(response.session!);
        return user;
      }
      return null;
    } catch (e) {
      throw AppAuthException(
        message: _getErrorMessage(e),
        originalError: e,
      );
    }
  }

  Future<AppUser?> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        final user = AppUser(
          id: response.user!.id,
          email: email,
          name: name,
          createdAt: DateTime.now(),
          isEmailVerified: response.user!.emailConfirmedAt != null,
        );

        await _supabaseClient.from('users').insert(user.toJson());
        
        if (response.session != null) {
          await _saveSession(response.session!);
        }
        
        return user;
      }
      return null;
    } catch (e) {
      throw AppAuthException(
        message: _getErrorMessage(e),
        originalError: e,
      );
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _supabaseClient.auth.signOut(),
        _prefs.clear(),
      ]);
    } catch (e) {
      throw AppAuthException(
        message: 'Erro ao fazer logout',
        originalError: e,
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AppAuthException(
        message: 'Erro ao solicitar redefinição de senha',
        originalError: e,
      );
    }
  }

  Future<bool> isAuthenticated() async {
    final session = _supabaseClient.auth.currentSession;
    return session != null && !session.isExpired;
  }

  /// Obtém o usuário atual autenticado
  Future<AppUser?> getCurrentUser() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;
      
      return _syncUserProfile(user);
    } catch (e) {
      throw AppAuthException(
        message: 'Erro ao obter usuário atual',
        originalError: e,
      );
    }
  }

  Future<void> _saveSession(supabase.Session session) async {
    await _prefs.setString('access_token', session.accessToken);
    await _prefs.setString('refresh_token', session.refreshToken ?? '');
  }

  Future<AppUser> _syncUserProfile(supabase.User user) async {
    try {
      final userData = await _supabaseClient
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      if (userData == null) {
        final email = user.email;
        if (email == null) {
          throw AppAuthException(
            message: 'Email do usuário não disponível',
          );
        }
        
        final newUser = AppUser(
          id: user.id,
          email: email,
          name: user.userMetadata?['name'] ?? user.userMetadata?['full_name'],
          avatarUrl: user.userMetadata?['avatar_url'],
          createdAt: DateTime.now(),
          isEmailVerified: user.emailConfirmedAt != null,
        );

        await _supabaseClient.from('users').insert(newUser.toJson());
        return newUser;
      }

      return AppUser.fromJson(userData);
    } catch (e) {
      throw AppAuthException(
        message: 'Erro ao sincronizar perfil',
        originalError: e,
      );
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is supabase.AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email ou senha inválidos';
        case 'Email not confirmed':
          return 'Por favor, confirme seu email';
        default:
          return error.message;
      }
    }
    return 'Ocorreu um erro na autenticação';
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
}
