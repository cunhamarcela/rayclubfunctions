import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ray_club_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Treinos - Testes de Integração', () {
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

    testWidgets('Visualização da lista de treinos', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de treinos
      await tester.tap(find.text('Treinos'));
      await tester.pumpAndSettle();

      // Verificar exibição da lista de treinos
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Visualizar detalhes de um treino', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de treinos
      await tester.tap(find.text('Treinos'));
      await tester.pumpAndSettle();

      // Selecionar um treino
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Verificar detalhes do treino
      expect(find.text('Detalhes do Treino'), findsOneWidget);
      expect(find.text('Começar Treino'), findsOneWidget);
    });

    testWidgets('Iniciar e completar um treino', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de treinos
      await tester.tap(find.text('Treinos'));
      await tester.pumpAndSettle();

      // Selecionar um treino
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Iniciar treino
      await tester.tap(find.text('Começar Treino'));
      await tester.pumpAndSettle();

      // Verificar tela de treino em andamento
      expect(find.text('Treino em Andamento'), findsOneWidget);

      // Navegar através dos exercícios (simular conclusão)
      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Próximo'));
      await tester.pumpAndSettle();
      
      // Concluir treino
      await tester.tap(find.text('Finalizar'));
      await tester.pumpAndSettle();

      // Verificar tela de conclusão
      expect(find.text('Treino Concluído'), findsOneWidget);
      
      // Avaliar o treino
      await tester.tap(find.byType(IconButton).at(3)); // 4 estrelas
      
      // Salvar avaliação
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      
      // Verificar retorno à lista de treinos
      expect(find.text('Treinos'), findsOneWidget);
    });

    testWidgets('Filtrar treinos por categoria', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      await fazerLogin(tester);

      // Navegar para a seção de treinos
      await tester.tap(find.text('Treinos'));
      await tester.pumpAndSettle();

      // Abrir filtros
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Selecionar categoria
      await tester.tap(find.text('Cardio'));
      await tester.pumpAndSettle();

      // Aplicar filtro
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();

      // Verificar que a lista foi filtrada
      expect(find.byType(Card), findsWidgets);
      // Não testamos o número exato pois depende dos dados
    });
  });
} 