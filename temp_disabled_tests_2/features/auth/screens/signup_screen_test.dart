// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Project imports:
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/features/auth/screens/signup_screen.dart';

// Mock para o AuthViewModel
class MockAuthViewModel extends Mock {
  void signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? instagram,
    DateTime? birthdate,
    String? gender,
  });
}

// Mock para o AuthViewModelNotifier
class MockAuthViewModelNotifier extends Mock {
  void signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    String? instagram,
    DateTime? birthdate,
    String? gender,
  });
}

void main() {
  late MockAuthViewModelNotifier mockAuthViewModelNotifier;

  setUp(() {
    mockAuthViewModelNotifier = MockAuthViewModelNotifier();
  });

  // Helper function para envolver o widget de teste com os providers necessários
  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authViewModelProvider.notifier.overrideWith((ref) => mockAuthViewModelNotifier)
      ],
      child: const MaterialApp(
        home: SignupScreen(),
      ),
    );
  }

  group('SignupScreen', () {
    testWidgets('deve renderizar todos os campos do formulário', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Act - nada a fazer aqui, apenas verificar se os widgets estão presentes
      
      // Assert
      expect(find.text('Nova Conta'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(6)); // nome, insta, email, senha, confirmar senha
      expect(find.text('Data de nascimento'), findsOneWidget);
      expect(find.text('Gênero'), findsOneWidget);
      expect(find.text('Criar conta'), findsOneWidget);
    });

    testWidgets('deve mostrar erro quando o nome está em branco', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Act - preencher todos os campos menos o nome e tentar cadastrar
      await tester.enterText(find.byType(TextFormField).at(1), 'usuario_teste');
      await tester.enterText(find.byType(TextFormField).at(2), 'teste@gmail.com');
      await tester.enterText(find.byType(TextFormField).at(3), 'Senha123');
      await tester.enterText(find.byType(TextFormField).at(4), 'Senha123');
      
      // Tocar no botão criar conta
      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();
      
      // Assert - verificar mensagem de erro
      expect(find.text('Por favor, insira seu nome'), findsOneWidget);
      
      // Verificar que o método signUp não foi chamado
      verifyNever(() => mockAuthViewModelNotifier.signUp(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        confirmPassword: any(named: 'confirmPassword'),
        instagram: any(named: 'instagram'),
        birthdate: any(named: 'birthdate'),
        gender: any(named: 'gender'),
      ));
    });
    
    testWidgets('deve mostrar erro quando o email é inválido', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Act - preencher campos com email inválido
      await tester.enterText(find.byType(TextFormField).at(0), 'Usuário Teste');
      await tester.enterText(find.byType(TextFormField).at(1), 'usuario_teste');
      await tester.enterText(find.byType(TextFormField).at(2), 'email_invalido');
      await tester.enterText(find.byType(TextFormField).at(3), 'Senha123');
      await tester.enterText(find.byType(TextFormField).at(4), 'Senha123');
      
      // Tocar no botão criar conta
      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();
      
      // Assert - verificar mensagem de erro
      expect(find.text('Por favor, insira um email válido'), findsOneWidget);
      
      // Verificar que o método signUp não foi chamado
      verifyNever(() => mockAuthViewModelNotifier.signUp(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        confirmPassword: any(named: 'confirmPassword'),
        instagram: any(named: 'instagram'),
        birthdate: any(named: 'birthdate'),
        gender: any(named: 'gender'),
      ));
    });
    
    testWidgets('deve mostrar erro quando as senhas não coincidem', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createWidgetUnderTest());
      
      // Act - preencher campos com senhas diferentes
      await tester.enterText(find.byType(TextFormField).at(0), 'Usuário Teste');
      await tester.enterText(find.byType(TextFormField).at(1), 'usuario_teste');
      await tester.enterText(find.byType(TextFormField).at(2), 'teste@gmail.com');
      await tester.enterText(find.byType(TextFormField).at(3), 'Senha123');
      await tester.enterText(find.byType(TextFormField).at(4), 'Senha456');
      
      // Tocar no botão criar conta
      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();
      
      // Assert - verificar mensagem de erro
      expect(find.text('As senhas não coincidem'), findsOneWidget);
      
      // Verificar que o método signUp não foi chamado
      verifyNever(() => mockAuthViewModelNotifier.signUp(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
        confirmPassword: any(named: 'confirmPassword'),
        instagram: any(named: 'instagram'),
        birthdate: any(named: 'birthdate'),
        gender: any(named: 'gender'),
      ));
    });

    // Teste de um caso de sucesso não pode ser feito completamente sem
    // simular toda a navegação, já que o componente faz navegação após o sucesso
  });
} 
