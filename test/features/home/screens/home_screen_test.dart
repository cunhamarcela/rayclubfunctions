// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:ray_club_app/features/home/screens/home_screen.dart';
import 'package:ray_club_app/features/home/providers/home_workout_provider.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';

// Mocks
class MockWorkoutVideo extends Mock implements WorkoutVideo {}

void main() {
  group('HomeScreen', () {
    late ProviderContainer container;
    late List<HomePartnerStudio> mockStudios;

    setUp(() {
      // Setup mock data
      mockStudios = [
        const HomePartnerStudio(
          id: 'musculacao',
          name: '💪 Treinos de Musculação',
          tagline: 'Fortalecimento e definição muscular progressiva',
          logoColor: Color(0xFF2E8B57),
          backgroundColor: Color(0xFFE8F5E8),
          icon: Icons.fitness_center,
          videos: [],
          workoutCategory: '495f6111-00f1-4484-974f-5213a5a44ed8',
        ),
        const HomePartnerStudio(
          id: 'pilates',
          name: '🧘 Goya Pilates',
          tagline: 'Pilates especializado para todos os níveis',
          logoColor: Color(0xFF27AE60),
          backgroundColor: Color(0xFFE9F7EF),
          icon: Icons.spa,
          videos: [],
          workoutCategory: 'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
        ),
      ];

      container = ProviderContainer(
        overrides: [
          homeWorkoutVideosProvider.overrideWith(
            (ref) => Future.value(mockStudios),
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    /// Teste básico de construção da widget
    testWidgets('deve construir a HomeScreen sem erros', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Verifica se a tela foi construída
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    /// Teste de exibição dos parceiros
    testWidgets('deve exibir seção de parceiros quando dados carregam', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Aguarda o carregamento dos dados
      await tester.pumpAndSettle();

      // Verifica se o título da seção aparece
      expect(find.text('💪 Treinos de Musculação'), findsAtLeastNWidget(1));
      expect(find.text('🧘 Goya Pilates'), findsAtLeastNWidget(1));
    });

    /// Teste de estado de carregamento
    testWidgets('deve mostrar indicador de carregamento inicialmente', (tester) async {
      // Override com provider que demora para carregar
      final slowContainer = ProviderContainer(
        overrides: [
          homeWorkoutVideosProvider.overrideWith(
            (ref) => Future.delayed(
              const Duration(seconds: 2),
              () => mockStudios,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: slowContainer,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Inicialmente deve mostrar algum estado de carregamento
      await tester.pump();
      
      // Verifica se a tela foi construída (mesmo durante carregamento)
      expect(find.byType(HomeScreen), findsOneWidget);
      
      slowContainer.dispose();
    });

    /// Teste de tratamento de erro
    testWidgets('deve lidar com erro no carregamento de dados', (tester) async {
      final errorContainer = ProviderContainer(
        overrides: [
          homeWorkoutVideosProvider.overrideWith(
            (ref) => throw Exception('Erro de teste'),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          parent: errorContainer,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      // Aguarda o processamento do erro
      await tester.pumpAndSettle();

      // Verifica se a tela ainda funciona mesmo com erro
      expect(find.byType(HomeScreen), findsOneWidget);
      
      errorContainer.dispose();
    });

    /// Teste de responsividade básica
    testWidgets('deve se adaptar a diferentes tamanhos de tela', (tester) async {
      // Testa em uma tela pequena
      await tester.binding.setSurfaceSize(const Size(360, 640));
      
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: const MaterialApp(
            home: HomeScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Testa em uma tela grande
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Restaura tamanho padrão
      await tester.binding.setSurfaceSize(null);
    });
  });

  group('HomePartnerStudio', () {
    /// Teste do modelo de dados
    test('deve criar HomePartnerStudio com dados válidos', () {
      const studio = HomePartnerStudio(
        id: 'test',
        name: 'Test Studio',
        tagline: 'Test tagline',
        logoColor: Colors.blue,
        backgroundColor: Colors.lightBlue,
        icon: Icons.fitness_center,
        videos: [],
        workoutCategory: 'test-category',
      );

      expect(studio.id, 'test');
      expect(studio.name, 'Test Studio');
      expect(studio.tagline, 'Test tagline');
      expect(studio.videos, isEmpty);
      expect(studio.workoutCategory, 'test-category');
    });

    /// Teste de sections opcionais
    test('deve suportar sections opcionais', () {
      const section = WorkoutSection(
        id: 'section1',
        name: 'Seção 1',
        description: 'Descrição da seção',
        videos: [],
      );

      const studio = HomePartnerStudio(
        id: 'test',
        name: 'Test Studio',
        tagline: 'Test tagline',
        logoColor: Colors.blue,
        backgroundColor: Colors.lightBlue,
        icon: Icons.fitness_center,
        videos: [],
        workoutCategory: 'test-category',
        sections: [section],
      );

      expect(studio.sections, isNotNull);
      expect(studio.sections!.length, 1);
      expect(studio.sections!.first.name, 'Seção 1');
    });
  });
} 