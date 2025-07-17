// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Project imports:
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/screens/login_screen.dart';
import 'package:ray_club_app/features/auth/services/auth_service.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

// Mocks
class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockAuthService extends Mock implements AuthService {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockAuthViewModel mockViewModel;
  late MockAuthService mockAuthService;
  late MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    mockViewModel = MockAuthViewModel();
    mockAuthService = MockAuthService();
    mockNavigatorObserver = MockNavigatorObserver();

    // Registrar chamadas que serão esperadas
    registerFallbackValue(const Route<dynamic>(settings: RouteSettings()));
  });

  Widget createTestWidget() {
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
        home: const LoginScreen(),
      ),
    );
  }

  group('LoginScreen Tests', () {
    testWidgets('should display email and password fields',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockViewModel.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
    });

    testWidgets('should show error when login fails',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockViewModel.state)
          .thenReturn(const AuthState.unauthenticated());
      when(() => mockViewModel.loginWithEmail(any(), any()))
          .thenThrow(AuthException('Credenciais inválidas'));

      // Act
      await tester.pumpWidget(createTestWidget());

      // Preencher campos e submeter
      await tester.enterText(
          find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Tap no botão de login
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Assert - verificar se o SnackBar com erro é exibido
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Erro: Credenciais inválidas'), findsOneWidget);
    });

    testWidgets('should call loginWithGoogle when Google button is tapped',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockViewModel.state)
          .thenReturn(const AuthState.unauthenticated());
      when(() => mockViewModel.loginWithGoogle()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget());

      // Encontrar e tocar no botão Google
      final googleButton = find.byKey(const ValueKey('google_sign_in_button'));
      expect(googleButton, findsOneWidget);

      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockViewModel.loginWithGoogle()).called(1);
    });

    testWidgets('should validate email field', (WidgetTester tester) async {
      // Arrange
      when(() => mockViewModel.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Preencher com email inválido
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');

      // Remover foco para disparar validação
      await tester.tap(find.byType(TextFormField).last);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email inválido'), findsOneWidget);
    });

    testWidgets('should navigate when auth state changes to authenticated',
        (WidgetTester tester) async {
      // Arrange - começa não autenticado
      when(() => mockViewModel.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createTestWidget());

      // Mudar estado para autenticado
      when(() => mockViewModel.state)
          .thenReturn(const AuthState.authenticated('user-123'));

      // Re-renderizar para processar mudança de estado
      await tester.pumpAndSettle();

      // Assert - verificar se tentou navegar para home
      verify(() => mockNavigatorObserver.didPush(any(), any()))
          .called(greaterThan(0));
    });
  });
}
