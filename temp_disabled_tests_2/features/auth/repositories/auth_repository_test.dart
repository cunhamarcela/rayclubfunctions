// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gotrue/gotrue.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';

class MockSupabaseClient extends Mock implements supabase.SupabaseClient {}

class MockGoTrueClient extends Mock implements supabase.GoTrueClient {}

class MockUser extends Mock implements supabase.User {}

class MockUserResponse extends Mock implements UserResponse {
  final supabase.User? _user;

  MockUserResponse(this._user);

  @override
  supabase.User? get user => _user;
}

class MockAuthResponse extends Mock implements AuthResponse {
  final supabase.User? _user;

  MockAuthResponse(this._user);

  @override
  supabase.User? get user => _user;
}

class FakeUserAttributes extends Fake implements supabase.UserAttributes {}

void main() {
  late supabase.SupabaseClient mockClient;
  late supabase.GoTrueClient mockAuthClient;
  late AuthRepository authRepository;
  late supabase.User mockUser;

  setUpAll(() {
    registerFallbackValue(FakeUserAttributes());
  });

  setUp(() {
    mockClient = MockSupabaseClient();
    mockAuthClient = MockGoTrueClient();
    mockUser = MockUser();
    authRepository = AuthRepository(mockClient);

    when(() => mockClient.auth).thenReturn(mockAuthClient);
    when(() => mockUser.id).thenReturn('1');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.userMetadata).thenReturn({'name': 'Test User'});
    when(() => mockUser.createdAt).thenReturn('2024-03-21T00:00:00.000Z');
    when(() => mockUser.emailConfirmedAt)
        .thenReturn('2024-03-21T00:00:00.000Z');
  });

  group('getCurrentUser', () {
    test('returns current user when authenticated', () async {
      when(() => mockAuthClient.currentUser).thenReturn(mockUser);

      final user = await authRepository.getCurrentUser();

      expect(user, equals(mockUser));
      verify(() => mockAuthClient.currentUser).called(1);
    });

    test('returns null when not authenticated', () async {
      when(() => mockAuthClient.currentUser).thenReturn(null);

      final user = await authRepository.getCurrentUser();

      expect(user, isNull);
      verify(() => mockAuthClient.currentUser).called(1);
    });

    test('throws DatabaseException when client throws', () async {
      when(() => mockAuthClient.currentUser)
          .thenThrow(Exception('Database error'));

      expect(
        () => authRepository.getCurrentUser(),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('signIn', () {
    test('returns user on successful sign in', () async {
      final mockAuthResponse = MockAuthResponse(mockUser);
      when(() => mockAuthClient.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockAuthResponse);

      final user = await authRepository.signIn('test@example.com', 'password');

      expect(user, equals(mockUser));
      verify(() => mockAuthClient.signInWithPassword(
            email: 'test@example.com',
            password: 'password',
          )).called(1);
    });

    test('throws ValidationException when email or password is empty',
        () async {
      // Empty email
      expect(
        () => authRepository.signIn('', 'password'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'Email and password are required',
        )),
      );

      // Empty password
      expect(
        () => authRepository.signIn('test@example.com', ''),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'Email and password are required',
        )),
      );

      verifyNever(() => mockAuthClient.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });

    test('throws AuthenticationException when sign in fails', () async {
      when(() => mockAuthClient.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(AuthException('Invalid credentials'));

      expect(
        () => authRepository.signIn('test@example.com', 'wrong-password'),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });

  group('signUp', () {
    test('returns user on successful sign up', () async {
      final mockAuthResponse = MockAuthResponse(mockUser);
      when(() => mockAuthClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenAnswer((_) async => mockAuthResponse);

      final user = await authRepository.signUp(
          'test@example.com', 'password', 'Test User');

      expect(user, equals(mockUser));
      verify(() => mockAuthClient.signUp(
            email: 'test@example.com',
            password: 'password',
            data: {'name': 'Test User'},
          )).called(1);
    });

    test('throws ValidationException when required fields are empty', () async {
      // Empty email
      expect(
        () => authRepository.signUp('', 'password', 'name'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'Email, password and name are required',
        )),
      );

      // Empty password
      expect(
        () => authRepository.signUp('test@example.com', '', 'name'),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'Email, password and name are required',
        )),
      );

      // Empty name
      expect(
        () => authRepository.signUp('test@example.com', 'password', ''),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'Email, password and name are required',
        )),
      );

      verifyNever(() => mockAuthClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          ));
    });

    test('throws AuthenticationException when sign up fails', () async {
      when(() => mockAuthClient.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            data: any(named: 'data'),
          )).thenThrow(AuthException('Email already exists'));

      expect(
        () =>
            authRepository.signUp('test@example.com', 'password', 'Test User'),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });

  group('signOut', () {
    test('signs out successfully', () async {
      when(() => mockAuthClient.signOut()).thenAnswer((_) async {});

      await authRepository.signOut();

      verify(() => mockAuthClient.signOut()).called(1);
    });

    test('throws AuthenticationException when sign out fails', () async {
      when(() => mockAuthClient.signOut())
          .thenThrow(AuthException('Sign out failed'));

      expect(
        () => authRepository.signOut(),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });

  group('resetPassword', () {
    test('resets password successfully', () async {
      when(() => mockAuthClient.resetPasswordForEmail(any()))
          .thenAnswer((_) async {});

      await authRepository.resetPassword('test@example.com');

      verify(() => mockAuthClient.resetPasswordForEmail('test@example.com'))
          .called(1);
    });

    test('throws ValidationException when email is empty', () async {
      expect(
        () => authRepository.resetPassword(''),
        throwsA(isA<ValidationException>().having(
          (e) => e.message,
          'message',
          'Email is required',
        )),
      );

      verifyNever(() => mockAuthClient.resetPasswordForEmail(any()));
    });

    test('throws AuthenticationException when reset fails', () async {
      when(() => mockAuthClient.resetPasswordForEmail(any()))
          .thenThrow(AuthException('Reset failed'));

      expect(
        () => authRepository.resetPassword('test@example.com'),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });

  group('updateProfile', () {
    test('updates profile successfully', () async {
      when(() => mockAuthClient.currentUser).thenReturn(mockUser);
      final mockUserResponse = MockUserResponse(mockUser);
      when(() => mockAuthClient.updateUser(any()))
          .thenAnswer((_) async => mockUserResponse);

      await authRepository.updateProfile(name: 'John Doe');

      verify(() => mockAuthClient.updateUser(
            supabase.UserAttributes(data: {'name': 'John Doe'}),
          )).called(1);
    });

    test('throws AuthenticationException when user is not authenticated',
        () async {
      when(() => mockAuthClient.currentUser).thenReturn(null);

      expect(
        () => authRepository.updateProfile(name: 'New Name'),
        throwsA(isA<AuthenticationException>().having(
          (e) => e.message,
          'message',
          'User is not authenticated',
        )),
      );

      verifyNever(() => mockAuthClient.updateUser(any()));
    });

    test('throws AuthenticationException when update fails', () async {
      when(() => mockAuthClient.currentUser).thenReturn(mockUser);
      when(() => mockAuthClient.updateUser(any()))
          .thenThrow(AuthException('Update failed'));

      expect(
        () => authRepository.updateProfile(name: 'John Doe'),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });
}
