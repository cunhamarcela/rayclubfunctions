// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/models/user.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

// Criando mocks para os testes
class MockAuthRepository extends Mock implements IAuthRepository {}
class MockSupabaseUser extends Mock implements supabase.User {}
class MockSession extends Mock implements supabase.Session {}

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepository mockRepository;
  late MockSupabaseUser mockSupabaseUser;
  late MockSession mockSession;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockSupabaseUser = MockSupabaseUser();
    mockSession = MockSession();
    
    // Configure mock user com todos os campos necessários
    when(() => mockSupabaseUser.id).thenReturn('test-id');
    when(() => mockSupabaseUser.email).thenReturn('test@example.com');
    when(() => mockSupabaseUser.userMetadata).thenReturn({
      'name': 'Test User',
      'avatar_url': 'https://example.com/avatar.jpg',
    });
    when(() => mockSupabaseUser.appMetadata).thenReturn({
      'is_admin': false,
    });
    when(() => mockSupabaseUser.createdAt).thenReturn('2024-03-21T00:00:00.000Z');
    when(() => mockSupabaseUser.emailConfirmedAt).thenReturn('2024-03-21T00:00:00.000Z');
    when(() => mockSupabaseUser.updatedAt).thenReturn('2024-03-21T00:00:00.000Z');
    
    // Criar o viewModel com checkAuthOnInit=false para não chamar checkAuthStatus no construtor
    viewModel = AuthViewModel(
      repository: mockRepository,
      checkAuthOnInit: false, // Evitar chamada automática de checkAuthStatus
    );
  });

  group('checkAuthStatus', () {
    test('should update state to authenticated when user is logged in', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => mockSupabaseUser);

      // Act
      await viewModel.checkAuthStatus();

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            authenticated: (user) => user.id == 'test-id',
            orElse: () => false,
          ),
          'state is authenticated with correct user',
          true,
        ),
      );
    });

    test('should update state to unauthenticated when no user is logged in', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser()).thenAnswer((_) async => null);

      // Act
      await viewModel.checkAuthStatus();

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            unauthenticated: () => true,
            orElse: () => false,
          ),
          'state is unauthenticated',
          true,
        ),
      );
    });

    test('should update state to error when getCurrentUser throws', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser())
          .thenThrow(AuthException(message: 'Test error'));

      // Act
      await viewModel.checkAuthStatus();

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            error: (message) => message == 'Test error',
            orElse: () => false,
          ),
          'state is error with correct message',
          true,
        ),
      );
    });
  });

  group('signIn', () {
    test('should update state to authenticated when login succeeds', () async {
      // Arrange
      when(() => mockRepository.signIn('test@example.com', 'password123'))
          .thenAnswer((_) async => mockSupabaseUser);

      // Act
      await viewModel.signIn('test@example.com', 'password123');

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            authenticated: (user) => user.id == 'test-id' && user.email == 'test@example.com',
            orElse: () => false,
          ),
          'state is authenticated with correct user',
          true,
        ),
      );
    });

    test('should update state to error when login fails', () async {
      // Arrange
      when(() => mockRepository.signIn('test@example.com', 'password123'))
          .thenThrow(AuthException(message: 'Invalid credentials'));

      // Act
      await viewModel.signIn('test@example.com', 'password123');

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            error: (message) => message == 'Invalid credentials',
            orElse: () => false,
          ),
          'state is error with correct message',
          true,
        ),
      );
    });
  });

  group('signUp', () {
    test('should update state to authenticated when registration succeeds', () async {
      // Arrange
      when(() => mockRepository.signUp('test@example.com', 'password123', 'Test User'))
          .thenAnswer((_) async => mockSupabaseUser);

      // Act
      await viewModel.signUp('test@example.com', 'password123', 'Test User');

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            authenticated: (user) => user.id == 'test-id' && user.email == 'test@example.com',
            orElse: () => false,
          ),
          'state is authenticated with correct user',
          true,
        ),
      );
    });

    test('should update state to error when registration fails', () async {
      // Arrange
      when(() => mockRepository.signUp('test@example.com', 'password123', 'Test User'))
          .thenThrow(AuthException(message: 'Email already registered'));

      // Act
      await viewModel.signUp('test@example.com', 'password123', 'Test User');

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            error: (message) => message == 'Email already registered',
            orElse: () => false,
          ),
          'state is error with correct message',
          true,
        ),
      );
    });
  });

  group('signOut', () {
    test('should update state to unauthenticated when signOut succeeds', () async {
      // Arrange
      when(() => mockRepository.signOut()).thenAnswer((_) async => {});

      // Act
      await viewModel.signOut();

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            unauthenticated: () => true,
            orElse: () => false,
          ),
          'state is unauthenticated',
          true,
        ),
      );
    });

    test('should update state to error when signOut fails', () async {
      // Arrange
      when(() => mockRepository.signOut())
          .thenThrow(AuthException(message: 'Error signing out'));

      // Act
      await viewModel.signOut();

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            error: (message) => message == 'Error signing out',
            orElse: () => false,
          ),
          'state is error with correct message',
          true,
        ),
      );
    });
  });

  group('resetPassword', () {
    test('should update state to success when password reset succeeds', () async {
      // Arrange
      when(() => mockRepository.resetPassword('test@example.com'))
          .thenAnswer((_) async => {});

      // Act
      await viewModel.resetPassword('test@example.com');

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            success: (message) => message.contains('Email de redefinição'),
            orElse: () => false,
          ),
          'state is success with correct message',
          true,
        ),
      );
    });

    test('should update state to error when password reset fails', () async {
      // Arrange
      when(() => mockRepository.resetPassword('test@example.com'))
          .thenThrow(AuthException(message: 'Invalid email'));

      // Act
      await viewModel.resetPassword('test@example.com');

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            error: (message) => message == 'Invalid email',
            orElse: () => false,
          ),
          'state is error with correct message',
          true,
        ),
      );
    });
  });

  group('signInWithGoogle', () {
    test('should update state to authenticated when Google login succeeds', () async {
      // Arrange
      when(() => mockRepository.signInWithGoogle())
          .thenAnswer((_) async => mockSession);
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => mockSupabaseUser);

      // Act
      await viewModel.signInWithGoogle();

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            authenticated: (user) => user.id == 'test-id' && user.email == 'test@example.com',
            orElse: () => false,
          ),
          'state is authenticated with correct user',
          true,
        ),
      );
    });

    test('should update state to error when Google login fails', () async {
      // Arrange
      when(() => mockRepository.signInWithGoogle())
          .thenThrow(AuthException(message: 'Google sign in failed'));

      // Act
      await viewModel.signInWithGoogle();

      // Assert
      expect(
        viewModel.state,
        isA<AuthState>().having(
          (state) => state.maybeWhen(
            error: (message) => message == 'Google sign in failed',
            orElse: () => false,
          ),
          'state is error with correct message',
          true,
        ),
      );
    });
  });

  group('redirect functionality', () {
    test('setRedirectPath should update redirectPath', () {
      // Act
      viewModel.setRedirectPath('/dashboard');
      
      // Assert
      expect(viewModel.redirectPath, equals('/dashboard'));
    });
    
    test('clearRedirectPath should reset redirectPath to null', () {
      // Arrange
      viewModel.setRedirectPath('/dashboard');
      
      // Act
      viewModel.clearRedirectPath();
      
      // Assert
      expect(viewModel.redirectPath, isNull);
    });
  });
}
