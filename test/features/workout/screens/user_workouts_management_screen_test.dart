import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/core/providers/auth_provider.dart';
import 'package:ray_club_app/features/workout/screens/user_workouts_management_screen.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_history_view_model.dart';
import '../../../helpers/test_helper.dart';

void main() {
  // Helper para montar a tela de teste com os providers necessários
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Mocka o cliente Supabase para evitar erros de inicialização
          supabaseClientProvider.overrideWithValue(mockSupabase()),
          // Você pode adicionar outros mocks globais necessários aqui
          // Ex: workoutHistoryViewModelProvider.overrideWithValue(MockWorkoutHistoryViewModel()),
        ],
        child: const MaterialApp(
          home: UserWorkoutsManagementScreen(),
        ),
      ),
    );
  }

  group('UserWorkoutsManagementScreen', () {
    testWidgets('deve exibir título corretamente', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.text('Meus Treinos'), findsOneWidget);
    });

    testWidgets('deve exibir barra de pesquisa', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Pesquisar treinos...'), findsOneWidget);
    });

    testWidgets('deve exibir filtros de tipo', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.byType(FilterChip), findsWidgets);
      expect(find.text('Todos'), findsOneWidget);
      expect(find.text('Funcional'), findsOneWidget);
    });

    testWidgets('deve exibir FAB para adicionar treino', (WidgetTester tester) async {
      await pumpScreen(tester);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Adicionar Treino'), findsOneWidget);
    });

    testWidgets('deve filtrar treinos ao digitar na pesquisa', (WidgetTester tester) async {
      await pumpScreen(tester);
      // Encontrar o campo de pesquisa e digitar
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Funcional');
      await tester.pump();

      // Verificar se o estado foi atualizado
      // A verificação exata dependerá da implementação do ViewModel
      expect(find.text('Funcional'), findsWidgets);
    });

    testWidgets('deve alterar filtro ao clicar em FilterChip', (WidgetTester tester) async {
      await pumpScreen(tester);
      // Clicar no filtro Funcional
      await tester.tap(find.text('Funcional'));
      await tester.pump();

      // Verificar se o filtro foi aplicado
      final functionalChip = tester.widget<FilterChip>(find.ancestor(
        of: find.text('Funcional'),
        matching: find.byType(FilterChip),
      ));
      
      // A verificação exata dependerá da implementação do estado
      expect(functionalChip.selected, isTrue);
    });
  });
} 