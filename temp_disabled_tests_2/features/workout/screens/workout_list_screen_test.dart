// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/models/exercise.dart';
import 'package:ray_club_app/features/workout/models/workout_section_model.dart';
import 'package:ray_club_app/features/workout/repositories/workout_repository.dart';
import 'package:ray_club_app/features/workout/screens/workout_list_screen.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';
import 'package:ray_club_app/features/workout/widgets/workout_card.dart';
import 'package:ray_club_app/core/components/app_loading.dart';
import 'package:ray_club_app/core/components/app_error_widget.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';

// Test imports:
import '../../../test_config.dart';

// --- Configuração para testes ---
class MockWorkoutViewModel extends Mock implements WorkoutViewModel {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseAuth extends Mock implements GotrueClient {}
class MockSupabasePostgrest extends Mock implements PostgrestClient {}

// Use esta função para inicializar o Supabase para testes
Future<void> initializeSupabaseForTests() async {
  await TestConfig.init();
  
  if (!TestConfig.hasValidSupabaseCredentials) {
    print('Credenciais do Supabase inválidas ou não configuradas.');
    print('Configure suas credenciais no arquivo .env ou .env.test:');
    print('SUPABASE_URL=https://seu-projeto-id.supabase.co');
    print('SUPABASE_ANON_KEY=sua-anon-key');
    return;
  }
  
  // Inicialize o Supabase
  try {
    await Supabase.initialize(
      url: TestConfig.supabaseUrl,
      anonKey: TestConfig.supabaseAnonKey,
      debug: true,
    );
  } catch (e) {
    // Se já estiver inicializado, continue
    print('Supabase já inicializado ou erro: $e');
  }
}

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Tente inicializar o Supabase - pode ser necessário desabilitar isto para execuções na CI
    try {
      await initializeSupabaseForTests();
    } catch (e) {
      print('AVISO: Falha ao inicializar Supabase: $e');
      print('Os testes com integração real serão ignorados.');
    }
  });

  // Teste com SupabaseWorkoutRepository real
  group('WorkoutListScreen com Supabase real', () {
    testWidgets(
      'carrega e exibe treinos do Supabase',
      (WidgetTester tester) async {
        // Verifica se o Supabase está disponível para o teste
        bool supabaseInitialized = false;
        try {
          // Isso lançará exceção se o Supabase não estiver inicializado
          Supabase.instance.client;
          supabaseInitialized = true;
        } catch (e) {
          print('Supabase não está inicializado, pulando teste de integração');
        }
        
        // Pular teste se o Supabase não estiver disponível
        if (!supabaseInitialized) {
          return;
        }
        
        // Instancie o app com um ProviderScope real
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: WorkoutListScreen()),
          ),
        );
        
        // Inicialmente deve mostrar carregamento
        expect(find.byType(AppLoading), findsOneWidget);
        
        // Aguarde o carregamento dos dados - pode precisar de mais tempo dependendo da sua conexão
        await tester.pumpAndSettle(const Duration(seconds: 5));
        
        // Depois de carregar, deve mostrar pelo menos 1 workout card
        // ou uma mensagem de nenhum treino encontrado
        final hasCards = tester.any(find.byType(WorkoutCard));
        final hasEmptyState = tester.any(find.text('Nenhum treino encontrado'));
        
        // Espera-se ou treinos ou mensagem vazia, não ambos
        expect(hasCards || hasEmptyState, true);
        
        // Verifique se existe um campo de pesquisa
        expect(find.widgetWithIcon(TextField, Icons.search), findsOneWidget);
      },
      // Deixar habilitado, pois agora decidimos no próprio teste se ele será executado
      skip: false,
    );
  });
  
  // --- Mock Tests (antigos) ---
  group('WorkoutListScreen com mocks', () {
    late MockWorkoutViewModel mockViewModel;

    // Helper to pump the widget with overridden provider
    Future<void> pumpWorkoutListScreen(WidgetTester tester, WorkoutState initialState) async {
      // Re-initialize mock for each test to ensure clean state
      mockViewModel = MockWorkoutViewModel();
      // Stub the state getter to return the desired initial state
      when(() => mockViewModel.state).thenReturn(initialState);
      // Stub methods that might be called by the widget's build or interaction
      when(() => mockViewModel.loadWorkouts()).thenAnswer((_) async {});
      when(() => mockViewModel.resetFilters()).thenAnswer((_) {});
      when(() => mockViewModel.filterByCategory(any())).thenAnswer((_) {});
      when(() => mockViewModel.filterByDuration(any())).thenAnswer((_) {});
      when(() => mockViewModel.filterByDifficulty(any())).thenAnswer((_) {});
      when(() => mockViewModel.selectWorkout(any())).thenAnswer((_) async {});
      when(() => mockViewModel.clearSelection()).thenAnswer((_) {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutViewModelProvider.overrideWith((_) => mockViewModel),
          ],
          child: const MaterialApp(home: WorkoutListScreen()),
        ),
      );
    }

    // Mock Data
    final testWorkout1 = Workout(
      id: '1',
      title: 'Treino HIIT Test',
      description: 'Test Desc 1',
      type: 'Cardio', durationMinutes: 30, difficulty: 'Avançado',
      equipment: [], sections: [], creatorId: 'test', createdAt: DateTime.now(),
    );
    final testWorkout2 = Workout(
      id: '2',
      title: 'Treino Força Test',
      description: 'Test Desc 2',
      type: 'Força', durationMinutes: 45, difficulty: 'Intermediário',
      equipment: [], sections: [], creatorId: 'test', createdAt: DateTime.now(),
    );

    testWidgets('shows loading indicator when state is loading', (WidgetTester tester) async {
      // Arrange
      final loadingState = WorkoutState.loading();

      // Act
      await pumpWorkoutListScreen(tester, loadingState);

      // Assert
      expect(find.byType(AppLoading), findsOneWidget);
      expect(find.byType(WorkoutCard), findsNothing);
    });

    testWidgets('shows error message when state is error', (WidgetTester tester) async {
      // Arrange
      final errorState = WorkoutState.error('Falha ao carregar');

      // Act
      await pumpWorkoutListScreen(tester, errorState);
      await tester.pumpAndSettle(); // Allow error widget to build

      // Assert
      expect(find.byType(AppErrorWidget), findsOneWidget);
      expect(find.text('Falha ao carregar'), findsOneWidget);
      expect(find.text('Tentar Novamente'), findsOneWidget); // Check for retry button text
      expect(find.byType(WorkoutCard), findsNothing);
    });

    testWidgets('shows empty state when loaded with no workouts', (WidgetTester tester) async {
      // Arrange
      final emptyState = WorkoutState.loaded(
        workouts: [],
        filteredWorkouts: [],
        categories: [],
        filter: const WorkoutFilter(),
      );

      // Act
      await pumpWorkoutListScreen(tester, emptyState);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nenhum treino encontrado'), findsOneWidget);
      expect(find.byType(WorkoutCard), findsNothing);
      expect(find.byType(AppLoading), findsNothing);
      expect(find.byType(AppErrorWidget), findsNothing);
    });

    testWidgets('renders workout list when data is available', (WidgetTester tester) async {
      // Arrange
      final loadedState = WorkoutState.loaded(
        workouts: [testWorkout1, testWorkout2],
        filteredWorkouts: [testWorkout1, testWorkout2], // Initially show all
        categories: ['Cardio', 'Força'],
        filter: const WorkoutFilter(),
      );

      // Act
      await pumpWorkoutListScreen(tester, loadedState);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(WorkoutCard), findsNWidgets(2));
      expect(find.text(testWorkout1.title), findsOneWidget);
      expect(find.text(testWorkout2.title), findsOneWidget);
      expect(find.byType(AppLoading), findsNothing);
      expect(find.byType(AppErrorWidget), findsNothing);
      expect(find.text('Nenhum treino encontrado'), findsNothing);
      // Check for filter elements (e.g., search bar, category chips)
      expect(find.widgetWithIcon(TextField, Icons.search), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Todos'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Cardio'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Força'), findsOneWidget);
    });

    // Add more tests for interactions like filtering, searching, tapping cards etc.
    // Example: Test filtering
    testWidgets('filters workouts when category chip is tapped', (WidgetTester tester) async {
      // Arrange: Start with loaded state
      final loadedState = WorkoutState.loaded(
        workouts: [testWorkout1, testWorkout2],
        filteredWorkouts: [testWorkout1, testWorkout2],
        categories: ['Cardio', 'Força'],
        filter: const WorkoutFilter(),
      );
      await pumpWorkoutListScreen(tester, loadedState);
      await tester.pumpAndSettle();

      // Arrange: Stub the filterByCategory method call on the mock
      when(() => mockViewModel.filterByCategory('Cardio')).thenAnswer((_) {
        // Simular estado após a filtragem
        final filteredState = WorkoutState.loaded(
          workouts: [testWorkout1, testWorkout2],
          filteredWorkouts: [testWorkout1], // Somente o workout de Cardio
          categories: ['Cardio', 'Força'],
          filter: const WorkoutFilter(category: 'Cardio'),
        );
        when(() => mockViewModel.state).thenReturn(filteredState); // Update the mock's state
      });

      // Act: Tap the 'Cardio' filter chip
      await tester.tap(find.widgetWithText(FilterChip, 'Cardio'));
      await tester.pumpAndSettle(); // Rebuild with the new state

      // Assert: Only the Cardio workout card should be visible
      expect(find.byType(WorkoutCard), findsOneWidget);
      expect(find.text(testWorkout1.title), findsOneWidget);
      expect(find.text(testWorkout2.title), findsNothing);
      verify(() => mockViewModel.filterByCategory('Cardio')).called(1);
    });
  });
} 
