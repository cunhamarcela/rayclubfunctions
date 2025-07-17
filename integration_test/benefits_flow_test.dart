import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ray_club_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Benefícios - Testes de Integração', () {
    // Helper para fazer login antes de cada teste
    Future<void> fazerLogin(WidgetTester tester) async {
      // Verificar se inicia na tela de introdução ou login
      if (find.text('Começar', skipOffstage: false).evaluate().isNotEmpty) {
        // Navegar pelo fluxo de introdução se necessário
        await tester.tap(find.text('Começar'));
        await tester.pumpAndSettle();
      }

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
    }

    testWidgets('Visualização da lista de benefícios', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de benefícios (pode estar em um tab ou menu)
      await tester.tap(find.text('Benefícios'));
      await tester.pumpAndSettle();

      // Verificar exibição da lista de benefícios
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Visualizar detalhes de um benefício', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de benefícios
      await tester.tap(find.text('Benefícios'));
      await tester.pumpAndSettle();

      // Selecionar um benefício
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verificar detalhes do benefício
      expect(find.text('Detalhes do Benefício'), findsOneWidget);
      expect(find.text('Resgatar'), findsOneWidget);
    });

    testWidgets('Resgatar um benefício', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de benefícios
      await tester.tap(find.text('Benefícios'));
      await tester.pumpAndSettle();

      // Selecionar um benefício
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Resgatar benefício
      await tester.tap(find.text('Resgatar'));
      await tester.pumpAndSettle();

      // Confirmar resgate
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      // Verificar confirmação de resgate
      expect(
        find.text('Benefício resgatado com sucesso'),
        findsOneWidget,
      );
    });

    testWidgets('Visualizar histórico de benefícios resgatados', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de benefícios
      await tester.tap(find.text('Benefícios'));
      await tester.pumpAndSettle();

      // Navegar para o histórico de benefícios
      await tester.tap(find.text('Meus Benefícios'));
      await tester.pumpAndSettle();

      // Verificar exibição do histórico
      expect(find.text('Benefícios Resgatados'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Usar um benefício resgatado', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de benefícios
      await tester.tap(find.text('Benefícios'));
      await tester.pumpAndSettle();

      // Navegar para o histórico de benefícios
      await tester.tap(find.text('Meus Benefícios'));
      await tester.pumpAndSettle();

      // Selecionar um benefício resgatado
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Usar o benefício
      await tester.tap(find.text('Usar'));
      await tester.pumpAndSettle();

      // Verificar exibição do código/QR
      expect(
        find.text('Apresente este código') | find.byType(Image),
        findsWidgets,
      );
    });
  });
} 