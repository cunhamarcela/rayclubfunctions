// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/models/dashboard_period.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_fitness_view_model.dart';
import 'package:ray_club_app/features/dashboard/repositories/dashboard_fitness_repository.dart';
import 'package:ray_club_app/features/dashboard/widgets/period_fitness_selector_widget.dart';

// Generate mocks
@GenerateMocks([DashboardFitnessRepository])
import 'dashboard_fitness_filters_test.mocks.dart';

void main() {
  group('Dashboard Fitness Filters', () {
    late MockDashboardFitnessRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockDashboardFitnessRepository();
      container = ProviderContainer(
        overrides: [
          dashboardFitnessRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('DashboardFitnessViewModel', () {
      test('deve ter período padrão como thisMonth', () {
        final viewModel = container.read(dashboardFitnessViewModelProvider.notifier);
        
        expect(viewModel.selectedPeriod, DashboardPeriod.thisMonth);
        expect(viewModel.customRange, isNull);
        expect(viewModel.isCustomPeriod, isFalse);
      });

      test('deve retornar lista completa de períodos disponíveis', () {
        final viewModel = container.read(dashboardFitnessViewModelProvider.notifier);
        final periods = viewModel.availablePeriods;
        
        expect(periods, contains(DashboardPeriod.thisWeek));
        expect(periods, contains(DashboardPeriod.lastWeek));
        expect(periods, contains(DashboardPeriod.thisMonth));
        expect(periods, contains(DashboardPeriod.lastMonth));
        expect(periods, contains(DashboardPeriod.last30Days));
        expect(periods, contains(DashboardPeriod.last3Months));
        expect(periods, contains(DashboardPeriod.thisYear));
        expect(periods, contains(DashboardPeriod.custom));
      });

      test('deve atualizar período corretamente', () async {
        final viewModel = container.read(dashboardFitnessViewModelProvider.notifier);
        
        // Simular dados do repositório
        when(mockRepository.getDashboardFitnessData(
          period: any(named: 'period'),
          customRange: any(named: 'customRange'),
        )).thenAnswer((_) async => _createMockDashboardData());
        
        await viewModel.updatePeriod(DashboardPeriod.lastWeek);
        
        expect(viewModel.selectedPeriod, DashboardPeriod.lastWeek);
        expect(viewModel.isCustomPeriod, isFalse);
        
        // Verificar se o repositório foi chamado com os parâmetros corretos
        verify(mockRepository.getDashboardFitnessData(
          period: DashboardPeriod.lastWeek,
          customRange: null,
        )).called(1);
      });

      test('deve configurar período custom corretamente', () async {
        final viewModel = container.read(dashboardFitnessViewModelProvider.notifier);
        final customRange = DateRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 1, 15),
        );
        
        // Simular dados do repositório
        when(mockRepository.getDashboardFitnessData(
          period: any(named: 'period'),
          customRange: any(named: 'customRange'),
        )).thenAnswer((_) async => _createMockDashboardData());
        
        await viewModel.updatePeriod(DashboardPeriod.custom, customRange);
        
        expect(viewModel.selectedPeriod, DashboardPeriod.custom);
        expect(viewModel.customRange, customRange);
        expect(viewModel.isCustomPeriod, isTrue);
        expect(viewModel.currentPeriodDescription, customRange.formattedRange);
      });

      test('deve verificar se data está no período atual', () {
        final viewModel = container.read(dashboardFitnessViewModelProvider.notifier);
        final testDate = DateTime.now();
        
        // Para período thisMonth, deve retornar true para data atual
        final isInPeriod = viewModel.isInCurrentPeriod(testDate);
        expect(isInPeriod, isTrue);
      });
    });

    group('PeriodFitnessSelectorWidget', () {
      testWidgets('deve exibir dropdown com períodos disponíveis', (WidgetTester tester) async {
        // Simular dados do repositório
        when(mockRepository.getDashboardFitnessData(
          period: any(named: 'period'),
          customRange: any(named: 'customRange'),
        )).thenAnswer((_) async => _createMockDashboardData());
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              dashboardFitnessRepositoryProvider.overrideWithValue(mockRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: PeriodFitnessSelectorWidget(),
              ),
            ),
          ),
        );

        // Verificar se o widget é renderizado
        expect(find.text('Período de visualização'), findsOneWidget);
        expect(find.text('✨ Fitness'), findsOneWidget);
        
        // Verificar se o dropdown está presente
        expect(find.byType(DropdownButton<DashboardPeriod>), findsOneWidget);
      });

      testWidgets('deve mostrar descrição do período selecionado', (WidgetTester tester) async {
        // Simular dados do repositório
        when(mockRepository.getDashboardFitnessData(
          period: any(named: 'period'),
          customRange: any(named: 'customRange'),
        )).thenAnswer((_) async => _createMockDashboardData());
        
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              dashboardFitnessRepositoryProvider.overrideWithValue(mockRepository),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: PeriodFitnessSelectorWidget(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verificar se a descrição do período padrão é mostrada
        expect(find.textContaining('Este mês'), findsOneWidget);
      });
    });
  });
}

/// Cria dados mock para os testes
DashboardFitnessData _createMockDashboardData() {
  return const DashboardFitnessData(
    calendar: CalendarData(
      month: 1,
      year: 2025,
      days: [],
    ),
    progress: ProgressData(
      week: WeekProgress(
        workouts: 3,
        minutes: 90,
        types: 2,
        days: 3,
      ),
      month: MonthProgress(
        workouts: 12,
        minutes: 360,
        days: 10,
        typesDistribution: {},
      ),
      total: TotalProgress(
        workouts: 50,
        workoutsCompleted: 45,
        points: 1500,
        duration: 1800,
        daysTrainedThisMonth: 10,
        level: 3,
        challengesCompleted: 2,
      ),
      streak: StreakData(
        current: 5,
        longest: 12,
      ),
    ),
    awards: AwardsData(
      totalPoints: 1500,
      achievements: [],
      badges: [],
      level: 3,
    ),
    lastUpdated: DateTime.now(),
  );
} 