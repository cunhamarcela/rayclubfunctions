// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/screens/login_screen.dart';
import 'package:ray_club_app/view_models/auth_view_model.dart';
import '../mocks/mock_service.mocks.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthService mockAuthService;
    late MockStorageService mockStorageService;
    late AuthViewModel authViewModel;

    setUp(() {
      mockAuthService = MockAuthService();
      mockStorageService = MockStorageService();
      authViewModel = AuthViewModel(
        authService: mockAuthService,
        storageService: mockStorageService,
      );
    });

    testWidgets('should show login form', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authViewModelProvider.overrideWith((ref) => authViewModel),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify form elements are present
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should show error on invalid credentials',
        (WidgetTester tester) async {
      when(mockAuthService.signIn(
        email: 'test@example.com',
        password: 'wrong_password',
      )).thenThrow(Exception('Invalid credentials'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authViewModelProvider.overrideWith((ref) => authViewModel),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrong_password',
      );

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify error is shown
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should navigate on successful login',
        (WidgetTester tester) async {
      final testUser = User(
        id: 'user123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
      );

      when(mockAuthService.signIn(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => testUser);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authViewModelProvider.overrideWith((ref) => authViewModel),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('should show loading indicator during login',
        (WidgetTester tester) async {
      when(mockAuthService.signIn(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return User(
          id: 'user123',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.now(),
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authViewModelProvider.overrideWith((ref) => authViewModel),
          ],
          child: const MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify loading indicator is shown
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for login to complete
      await tester.pumpAndSettle();

      // Verify loading indicator is gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
