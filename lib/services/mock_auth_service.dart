// Project imports:
import '../core/di/base_service.dart';
import '../models/user.dart';
import 'auth_service.dart';

/// Implementação mockada de AuthService para desenvolvimento
class MockAuthService implements AuthService {
  bool _initialized = false;
  final AppUser _mockUser = AppUser(
    id: 'mock-user-id-123',
    email: 'usuario.teste@exemplo.com',
    name: 'Usuário Teste',
    avatarUrl: null,
    createdAt: DateTime.now(),
    isEmailVerified: true,
    displayName: 'Usuário Teste',
  );

  @override
  bool get isInitialized => _initialized;

  @override
  Future<AppUser?> getCurrentUser() async {
    // Simula um pequeno atraso de rede
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUser;
  }

  @override
  Future<void> initialize() async {
    _initialized = true;
  }

  @override
  Future<bool> isAuthenticated() async {
    // Sempre retorna true para fins de desenvolvimento
    return true;
  }

  @override
  Future<void> resetPassword(String email) async {
    // Não faz nada em desenvolvimento
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<AppUser?> signInWithEmail({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUser;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<AppUser?> signUpWithEmail({required String email, required String password, String? name}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUser;
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
} 