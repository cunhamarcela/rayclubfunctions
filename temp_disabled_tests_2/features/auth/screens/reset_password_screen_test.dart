// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/screens/reset_password_screen.dart';
import 'package:ray_club_app/features/auth/services/auth_service.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

// Mock para NaviagtorObserver para testar navegação
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

// Mock para AuthViewModel
class MockAuthViewModel extends StateNotifier<AuthState> with Mock implements AuthViewModel {
  MockAuthViewModel() : super(const AuthState.initial());
}

// Mock para ProviderScope
class MockAuthViewModelProvider extends StateNotifierProvider<AuthViewModel, AuthState> {
  MockAuthViewModelProvider(AuthViewModel Function(StateNotifierProviderRef<AuthViewModel, AuthState>) create)
      : super(create);
}

// Mock da classe Supabase para testar a verificação de sessão
class MockSupabase extends Mock implements SupabaseClient {
  MockSupabase();
  
  @override
  AuthClass get auth => MockAuthClass();
}

class MockAuthClass extends Mock implements AuthClass {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSession extends Mock implements Session {
  @override
  bool get isExpired => false;
}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockNavigatorObserver mockNavigatorObserver;
  final mockProvider = StateNotifierProvider<AuthViewModel, AuthState>(
    (ref) => mockAuthViewModel,
  );

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockNavigatorObserver = MockNavigatorObserver();
    
    // Configuração para permitir navigateToHome/navigateToLogin
    AppRouter.navigateToHome = (context) {
      Navigator.of(context).pushReplacementNamed('/home');
    };
    
    AppRouter.navigateToLogin = (context) {
      Navigator.of(context).pushReplacementNamed('/login');
    };
    
    // Configurar sessão mock válida
    final mockSession = MockSession();
    final mockGoTrueClient = MockGoTrueClient();
    final mockAuthClass = MockAuthClass();
    
    when(() => mockAuthClass.currentSession).thenReturn(mockSession);
    
    // Mock do Supabase para que o _checkSession() encontre uma sessão válida
    Supabase.initialize = (
      {required String url, 
      required String anonKey, 
      String? authCallbackUrlHostname, 
      bool debug = false}) async {
      // Não implementar para o teste
    };
    
    Supabase.instance = Supabase();
    final mockSupabase = MockSupabase();
    Supabase.instance.client = mockSupabase;
    
    // Mock da resposta do update password
    when(() => mockAuthViewModel.updatePassword(any())).thenAnswer((_) async {
      return Future.value();
    });
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.overrideWith((_) => mockAuthViewModel),
      ],
      child: MaterialApp(
        home: const ResetPasswordScreen(),
        navigatorObservers: [mockNavigatorObserver],
        routes: {
          '/home': (context) => const Scaffold(body: Text('Home Screen')),
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
        },
      ),
    );
  }

  group('ResetPasswordScreen', () {
    testWidgets('renderiza campos de senha, confirmação e botão', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Aguarda o check de sessão completar
      await tester.pumpAndSettle();
      
      // Verifica se os elementos principais estão na tela
      expect(find.text('Redefinir Senha'), findsOneWidget);
      expect(find.text('Crie uma nova senha'), findsOneWidget);
      expect(find.text('Sua senha deve ter pelo menos 6 caracteres'), findsOneWidget);
      
      // Verifica os campos de senha
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
      expect(find.text('Nova senha'), findsOneWidget);
      expect(find.text('Confirmar senha'), findsOneWidget);
      
      // Verifica o botão de atualizar
      expect(find.text('Atualizar Senha'), findsOneWidget);
    });
    
    testWidgets('valida senha e confirmação diferentes', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      // Preenche senhas diferentes
      await tester.enterText(find.byType(TextFormField).at(0), 'senha123');
      await tester.enterText(find.byType(TextFormField).at(1), 'senha456');
      
      // Clica no botão de atualizar
      await tester.tap(find.text('Atualizar Senha'));
      await tester.pump();
      
      // Verifica se a validação exibe a mensagem de erro
      expect(find.text('As senhas não coincidem'), findsOneWidget);
    });
    
    testWidgets('valida senha muito curta', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      // Preenche senha muito curta
      await tester.enterText(find.byType(TextFormField).at(0), '123');
      await tester.tap(find.text('Atualizar Senha'));
      await tester.pump();
      
      // Verifica se a validação exibe a mensagem de erro
      expect(find.text('A senha deve ter pelo menos 6 caracteres'), findsOneWidget);
    });
    
    testWidgets('chama updatePassword e navega para home com sucesso', (WidgetTester tester) async {
      when(() => mockAuthViewModel.state).thenReturn(const AuthState.authenticated('user-id'));
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      // Preenche as senhas iguais
      await tester.enterText(find.byType(TextFormField).at(0), 'senha123');
      await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
      
      // Submete o formulário
      await tester.tap(find.text('Atualizar Senha'));
      await tester.pump();
      
      // Verifica se o método updatePassword foi chamado com a senha correta
      verify(() => mockAuthViewModel.updatePassword('senha123')).called(1);
      
      // Verifica o SnackBar de sucesso
      expect(find.text('Senha atualizada com sucesso!'), findsOneWidget);
      
      // Avança para permitir a navegação acontecer
      await tester.pumpAndSettle();
      
      // Verifica se redirecionou para a tela inicial
      expect(find.text('Home Screen'), findsOneWidget);
    });
    
    testWidgets('exibe erro se falhar ao atualizar senha', (WidgetTester tester) async {
      // Configura o mock para lançar uma exceção
      when(() => mockAuthViewModel.updatePassword(any())).thenThrow(
        AuthException('Falha ao atualizar senha')
      );
      
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();
      
      // Preenche as senhas iguais
      await tester.enterText(find.byType(TextFormField).at(0), 'senha123');
      await tester.enterText(find.byType(TextFormField).at(1), 'senha123');
      
      // Submete o formulário
      await tester.tap(find.text('Atualizar Senha'));
      await tester.pump();
      
      // Verifica se o método updatePassword foi chamado com a senha correta
      verify(() => mockAuthViewModel.updatePassword('senha123')).called(1);
      
      // Verifica o SnackBar de erro
      expect(find.text('Falha ao atualizar senha'), findsOneWidget);
      
      // Não deve ter navegado para a tela inicial
      expect(find.text('Home Screen'), findsNothing);
    });
    
    testWidgets('redireciona para login se sessão inválida', (WidgetTester tester) async {
      // Reconfigura para sessão inválida
      final mockAuthClass = MockAuthClass();
      when(() => mockAuthClass.currentSession).thenReturn(null);
      
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Antes da verificação de sessão concluir, deve mostrar loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Avança para permitir a navegação acontecer
      await tester.pumpAndSettle();
      
      // Verifica se redirecionou para o login
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
} 
