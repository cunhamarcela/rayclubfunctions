// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../core/exceptions/repository_exception.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'states/auth_state.dart';

// Providers
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  throw UnimplementedError('AuthRepository must be initialized');
});

final authViewModelProvider =
    StateNotifierProvider<AuthViewModel, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository: repository);
});

/// ViewModel responsible for handling authentication-related operations.
class AuthViewModel extends StateNotifier<AuthState> {
  final IAuthRepository _repository;
  final bool _checkAuthOnInit;

  AuthViewModel({
    required IAuthRepository repository,
    bool checkAuthOnInit = true,
  })  : _repository = repository,
        _checkAuthOnInit = checkAuthOnInit,
        super(const AuthState.initial()) {
    if (_checkAuthOnInit) {
      checkAuthStatus();
    }
  }

  /// Extracts the error message from an exception
  String _getErrorMessage(dynamic error) {
    if (error is RepositoryException) {
      return error.message;
    }
    return error.toString();
  }

  /// Checks the current authentication status
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(
          user: AppUser.fromSupabaseUser(user),
        );
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Signs in the user with email and password
  Future<void> signIn(String email, String password) async {
    try {
      state = const AuthState.loading();
      final user = await _repository.signIn(email, password);
      state = AuthState.authenticated(
        user: AppUser.fromSupabaseUser(user),
      );
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Signs up a new user
  Future<void> signUp(String email, String password, String name) async {
    try {
      state = const AuthState.loading();
      final user = await _repository.signUp(email, password, name);
      state = AuthState.authenticated(
        user: AppUser.fromSupabaseUser(user),
      );
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      state = const AuthState.loading();
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Resets the password for the given email
  Future<void> resetPassword(String email) async {
    try {
      state = const AuthState.loading();
      await _repository.resetPassword(email);
      state = const AuthState.success(message: 'Password reset email sent');
    } catch (e) {
      state = AuthState.error(message: _getErrorMessage(e));
    }
  }

  /// Updates the user's profile information
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

      // Update the current user state if authenticated
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
}
