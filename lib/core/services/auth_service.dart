import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/models/user.dart'; // Importar o modelo AppUser

/// Modelo do usuário autenticado com informações básicas
class AuthUser {
  final String id;
  final String? email;
  final String? name;
  final String? photoUrl;
  final bool isAdmin;

  AuthUser({
    required this.id,
    this.email,
    this.name,
    this.photoUrl,
    this.isAdmin = false,
  });

  factory AuthUser.fromSupabaseUser(User user, {bool? isAdmin}) {
    final userMetadata = user.userMetadata;
    return AuthUser(
      id: user.id,
      email: user.email,
      name: userMetadata?['name'] as String? ?? user.email?.split('@').first,
      photoUrl: userMetadata?['avatar_url'] as String?,
      isAdmin: isAdmin ?? false,
    );
  }
}

/// Provider para o serviço de autenticação
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Extensão para adicionar propriedades de compatibilidade ao AppUser
extension AppUserCompat on AppUser {
  String? get displayName => name;
  String? get photoURL => photoUrl;
}

/// Serviço responsável pela autenticação e gerenciamento de sessão
class AuthService {
  // Cliente Supabase para operações de autenticação
  final _supabase = Supabase.instance.client;
  
  /// Retorna o usuário atualmente autenticado
  AppUser? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AppUser.fromSupabaseUser(user);
  }
  
  /// Verifica se há um usuário autenticado
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  
  /// Login com email e senha
  Future<AppUser> signInWithEmailPassword(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    
    if (response.user == null) {
      throw Exception('Falha na autenticação');
    }
    
    // Verificar se o usuário é admin
    final userDataResponse = await _supabase
        .from('users')
        .select('is_admin')
        .eq('id', response.user!.id)
        .single();
    
    final isAdmin = (userDataResponse['is_admin'] as bool?) ?? false;
    
    // Criar o AppUser com a flag isAdmin
    return AppUser.fromSupabaseUser(response.user!).copyWith(isAdmin: isAdmin);
  }
  
  /// Cadastro com email e senha
  Future<AppUser> signUpWithEmailPassword(String email, String password, String name) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    
    if (response.user == null) {
      throw Exception('Falha no cadastro');
    }
    
    // Criar entrada na tabela users
    await _supabase.from('users').insert({
      'id': response.user!.id,
      'email': email,
      'name': name,
      'is_admin': false,
    });
    
    return AppUser.fromSupabaseUser(response.user!);
  }
  
  /// Logout
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
  
  /// Recuperação de senha
  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
  
  /// Atualiza a senha do usuário
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
} 