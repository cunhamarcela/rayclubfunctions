import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ray_club_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Autenticação - Testes de Integração', () {
    testWidgets('Fluxo completo de login', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar se inicia na tela de introdução ou login
      if (find.text('Começar', skipOffstage: false).evaluate().isNotEmpty) {
        // Navegar pelo fluxo de introdução se necessário
        await tester.tap(find.text('Começar'));
        await tester.pumpAndSettle();
      }

      // Deve estar na tela de login
      expect(find.text('Login'), findsOneWidget);

      // Inserir credenciais
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tocar no botão de login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Deve navegar para a tela inicial
      expect(find.text('Bem-vindo'), findsOneWidget);
    });

    testWidgets('Fluxo de registro de conta', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar se inicia na tela de introdução ou login
      if (find.text('Começar', skipOffstage: false).evaluate().isNotEmpty) {
        // Navegar pelo fluxo de introdução se necessário
        await tester.tap(find.text('Começar'));
        await tester.pumpAndSettle();
      }

      // Navegar para a tela de registro
      await tester.tap(find.text('Registrar'));
      await tester.pumpAndSettle();

      // Inserir dados de registro
      await tester.enterText(
        find.byKey(const Key('name_field')),
        'Usuário Teste',
      );
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'novo_usuario@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'senha123',
      );
      await tester.enterText(
        find.byKey(const Key('confirm_password_field')),
        'senha123',
      );

      // Tocar no botão de registro
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Deve navegar para a tela inicial ou confirmação de email
      expect(
        find.text('Bem-vindo') | find.text('Confirme seu email'),
        findsOneWidget,
      );
    });

    testWidgets('Fluxo de redefinição de senha', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verificar se inicia na tela de introdução ou login
      if (find.text('Começar', skipOffstage: false).evaluate().isNotEmpty) {
        // Navegar pelo fluxo de introdução se necessário
        await tester.tap(find.text('Começar'));
        await tester.pumpAndSettle();
      }

      // Navegar para a tela de esqueceu a senha
      await tester.tap(find.text('Esqueceu a senha?'));
      await tester.pumpAndSettle();

      // Inserir email para recuperação
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );

      // Tocar no botão de enviar
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Deve mostrar mensagem de confirmação
      expect(find.text('Enviamos um link para seu email'), findsOneWidget);
    });
  });
} 