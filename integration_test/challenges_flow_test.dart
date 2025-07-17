import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ray_club_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Desafios - Testes de Integração', () {
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

    testWidgets('Visualização da lista de desafios', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de desafios
      await tester.tap(find.text('Desafios'));
      await tester.pumpAndSettle();

      // Verificar exibição da lista de desafios
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Participar de um desafio', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de desafios
      await tester.tap(find.text('Desafios'));
      await tester.pumpAndSettle();

      // Selecionar um desafio
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verificar detalhes do desafio
      expect(find.text('Detalhes do Desafio'), findsOneWidget);

      // Participar do desafio
      await tester.tap(find.text('Participar'));
      await tester.pumpAndSettle();

      // Verificar confirmação de participação
      expect(
        find.text('Você está participando') | find.text('Participando'),
        findsOneWidget,
      );
    });

    testWidgets('Registrar progresso em um desafio', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de desafios
      await tester.tap(find.text('Desafios'));
      await tester.pumpAndSettle();

      // Navegar para desafios ativos
      await tester.tap(find.text('Meus Desafios'));
      await tester.pumpAndSettle();

      // Selecionar um desafio ativo
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Registrar progresso
      await tester.tap(find.text('Registrar Progresso'));
      await tester.pumpAndSettle();

      // Preencher dados de progresso
      await tester.enterText(
        find.byType(TextField).first,
        '5',
      );

      // Enviar progresso
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      // Verificar confirmação
      expect(find.text('Progresso registrado com sucesso'), findsOneWidget);
    });

    testWidgets('Verificar ranking de um desafio', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de desafios
      await tester.tap(find.text('Desafios'));
      await tester.pumpAndSettle();

      // Selecionar um desafio
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Navegar para o ranking
      await tester.tap(find.text('Ranking'));
      await tester.pumpAndSettle();

      // Verificar exibição do ranking
      expect(find.text('Ranking'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });
  });
} 