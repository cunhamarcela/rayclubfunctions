// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Project imports:
import 'package:ray_club_app/core/widgets/auth_gate.dart';
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

// Mocks
class MockAuthViewModel extends StateNotifier<AuthState>
    with Mock
    implements AuthViewModel {
  MockAuthViewModel(super.state);
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockAuthViewModel mockViewModel;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockViewModel = MockAuthViewModel(const AuthState.initial());
    mockNavigatorObserver = MockNavigatorObserver();

    // Registrar chamadas que serão esperadas
    registerFallbackValue(const Route<dynamic>(settings: RouteSettings()));
  });

  Widget createTestWidget({required AuthState initialState}) {
    mockViewModel = MockAuthViewModel(initialState);

    // Override do provider para usar nosso mock
    final authViewModelProvider =
        StateNotifierProvider<AuthViewModel, AuthState>((ref) {
      return mockViewModel;
    });

    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith((ref) => mockViewModel),
      ],
      child: MaterialApp(
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
          '/home': (context) => const Scaffold(body: Text('Home Screen')),
        },
        home: const AuthGate(),
      ),
    );
  }

  group('AuthGate Tests', () {
    testWidgets('should show loading indicator when in initial state',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
          createTestWidget(initialState: const AuthState.initial()));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show loading indicator when in loading state',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
          createTestWidget(initialState: const AuthState.loading()));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should navigate to /home when authenticated',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(
          initialState: const AuthState.authenticated('user-123')));

      // Act - pump para processar navegação
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNavigatorObserver.didPush(any(), any()))
          .called(greaterThan(0));
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('should navigate to /login when unauthenticated',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
          createTestWidget(initialState: const AuthState.unauthenticated()));

      // Act
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNavigatorObserver.didPush(any(), any()))
          .called(greaterThan(0));
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('should navigate to /login and show error when in error state',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(
          initialState: const AuthState.error('Authentication error')));

      // Act
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockNavigatorObserver.didPush(any(), any()))
          .called(greaterThan(0));
      expect(find.text('Login Screen'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Erro: Authentication error'), findsOneWidget);
    });
  });
}
