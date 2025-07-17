// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Classes simuladas para teste

// Interface do repositório de autenticação
abstract class IAuthRepository {
  Future<supabase.User?> getCurrentUser();
  Future<supabase.Session?> signInWithGoogle();
  Future<void> signOut();
}

// Estados de autenticação
abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated({required this.user});
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}

// Modelo de usuário simplificado
class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  
  AppUser({
    required this.id, 
    required this.email, 
    this.name, 
    this.photoUrl,
  });
  
  factory AppUser.fromSupabaseUser(supabase.User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }
}

// ViewModel de autenticação simplificado
class AuthViewModel {
  AuthState _state = AuthInitial();
  AuthState get state => _state;
  
  final IAuthRepository _repository;
  
  AuthViewModel({required IAuthRepository repository}) : _repository = repository;
  
  Future<void> signInWithGoogle() async {
    _state = AuthLoading();
    
    try {
      final session = await _repository.signInWithGoogle();
      final user = await _repository.getCurrentUser();
      
      if (user != null) {
        _state = AuthAuthenticated(user: AppUser.fromSupabaseUser(user));
      } else {
        _state = AuthError(message: 'Login failed');
      }
    } catch (e) {
      _state = AuthError(message: e.toString());
    }
  }
  
  Future<void> signOut() async {
    _state = AuthLoading();
    
    try {
      await _repository.signOut();
      _state = AuthUnauthenticated();
    } catch (e) {
      _state = AuthError(message: e.toString());
    }
  }
}

// Mock manual do repositório
class FakeAuthRepository implements IAuthRepository {
  final supabase.User _mockUser = supabase.User(
    id: '123',
    email: 'test@example.com',
    appMetadata: {},
    userMetadata: {
      'name': 'Test User',
      'avatar_url': 'https://example.com/avatar.png'
    },
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );
  
  bool isAuthenticated = false;
  bool shouldThrowError = false;
  
  @override
  Future<supabase.User?> getCurrentUser() async {
    if (shouldThrowError) {
      throw Exception('Erro ao obter usuário atual');
    }
    return isAuthenticated ? _mockUser : null;
  }
  
  @override
  Future<supabase.Session?> signInWithGoogle() async {
    if (shouldThrowError) {
      throw Exception('Erro ao fazer login com Google');
    }
    isAuthenticated = true;
    return supabase.Session(
      accessToken: 'fake-token',
      refreshToken: 'fake-refresh-token',
      user: _mockUser,
      expiresIn: 3600,
      tokenType: 'bearer',
    );
  }
  
  @override
  Future<void> signOut() async {
    if (shouldThrowError) {
      throw Exception('Erro ao fazer logout');
    }
    isAuthenticated = false;
  }
}

void main() {
  late FakeAuthRepository fakeRepository;
  late AuthViewModel viewModel;

  setUp(() {
    fakeRepository = FakeAuthRepository();
    viewModel = AuthViewModel(repository: fakeRepository);
  });

  group('AuthViewModel', () {
    test('Inicialmente o estado deve estar como Initial', () {
      expect(viewModel.state, isA<AuthInitial>());
    });
    
    test('signInWithGoogle com sucesso altera o estado para Authenticated', () async {
      await viewModel.signInWithGoogle();
      
      expect(viewModel.state, isA<AuthAuthenticated>());
      final authState = viewModel.state as AuthAuthenticated;
      expect(authState.user.id, equals('123'));
      expect(authState.user.email, equals('test@example.com'));
    });
    
    test('signOut com sucesso altera o estado para Unauthenticated', () async {
      // Primeiro autenticar
      await viewModel.signInWithGoogle();
      
      // Depois deslogar
      await viewModel.signOut();
      
      expect(viewModel.state, isA<AuthUnauthenticated>());
    });
    
    test('signInWithGoogle com erro altera o estado para Error', () async {
      fakeRepository.shouldThrowError = true;
      
      await viewModel.signInWithGoogle();
      
      expect(viewModel.state, isA<AuthError>());
      final errorState = viewModel.state as AuthError;
      expect(errorState.message, contains('Erro ao fazer login'));
    });
    
    test('signOut com erro altera o estado para Error', () async {
      // Primeiro autenticar
      await viewModel.signInWithGoogle();
      
      // Configurar para lançar erro no logout
      fakeRepository.shouldThrowError = true;
      
      // Tentar deslogar
      await viewModel.signOut();
      
      expect(viewModel.state, isA<AuthError>());
      final errorState = viewModel.state as AuthError;
      expect(errorState.message, contains('Erro ao fazer logout'));
    });
  });
} 
