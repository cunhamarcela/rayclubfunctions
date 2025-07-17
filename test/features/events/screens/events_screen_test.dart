// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:ray_club_app/features/events/models/event.dart';
import 'package:ray_club_app/features/events/repositories/event_repository.dart';
import 'package:ray_club_app/features/events/screens/events_screen.dart';
import 'package:ray_club_app/features/events/viewmodels/event_view_model.dart';

// Mocks
class MockEventRepository extends Mock implements IEventRepository {}

void main() {
  late MockEventRepository mockRepository;

  setUp(() {
    mockRepository = MockEventRepository();
  });

  /// Cria um widget testável com providers mockados
  Widget createTestableWidget({
    List<Event>? events,
    bool isLoading = false,
    String? errorMessage,
  }) {
    return ProviderScope(
      overrides: [
        eventRepositoryProvider.overrideWithValue(mockRepository),
        eventViewModelProvider.overrideWith((ref) {
          final viewModel = EventViewModel(
            repository: mockRepository,
            authRepository: ref.watch(authRepositoryProvider),
          );
          
          // Configurar estado inicial
          if (events != null) {
            viewModel.state = EventsState(
              events: events,
              isLoading: isLoading,
              errorMessage: errorMessage,
            );
          }
          
          return viewModel;
        }),
      ],
      child: MaterialApp(
        home: const EventsScreen(),
      ),
    );
  }

  group('EventsScreen', () {
    testWidgets('deve exibir título "Eventos" na AppBar', (tester) async {
      // Arrange
      when(() => mockRepository.getEvents()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestableWidget(events: []));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Eventos'), findsOneWidget);
    });

    testWidgets('deve exibir imagem de destaque dos eventos', (tester) async {
      // Arrange
      when(() => mockRepository.getEvents()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestableWidget(events: []));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Image), findsAtLeastNWidgets(1));
    });

    testWidgets('deve exibir indicador de carregamento quando isLoading é true', (tester) async {
      // Arrange
      when(() => mockRepository.getEvents()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestableWidget(
        events: [],
        isLoading: true,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve exibir mensagem de erro quando há erro', (tester) async {
      // Arrange
      const errorMessage = 'Erro ao carregar eventos';
      when(() => mockRepository.getEvents()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestableWidget(
        events: [],
        errorMessage: errorMessage,
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Ops! Algo deu errado'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);
    });

    testWidgets('deve exibir mensagem quando não há eventos', (tester) async {
      // Arrange
      when(() => mockRepository.getEvents()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestableWidget(events: []));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Nenhum evento encontrado'), findsOneWidget);
      expect(find.text('Em breve teremos eventos incríveis para você!'), findsOneWidget);
    });

    testWidgets('deve exibir lista de eventos quando há eventos disponíveis', (tester) async {
      // Arrange
      final events = [
        Event(
          id: '1',
          title: 'Evento Teste 1',
          description: 'Descrição do evento teste 1',
          startDate: DateTime.now().add(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 2)),
          location: 'Local Teste 1',
          organizerId: 'organizer-1',
          maxAttendees: 50,
          currentAttendees: 10,
        ),
        Event(
          id: '2',
          title: 'Evento Teste 2',
          description: 'Descrição do evento teste 2',
          startDate: DateTime.now().add(const Duration(days: 3)),
          endDate: DateTime.now().add(const Duration(days: 4)),
          location: 'Local Teste 2',
          organizerId: 'organizer-2',
          maxAttendees: 30,
          currentAttendees: 5,
        ),
      ];

      when(() => mockRepository.getEvents()).thenAnswer((_) async => events);

      // Act
      await tester.pumpWidget(createTestableWidget(events: events));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Evento Teste 1'), findsOneWidget);
      expect(find.text('Evento Teste 2'), findsOneWidget);
      expect(find.text('Descrição do evento teste 1'), findsOneWidget);
      expect(find.text('Descrição do evento teste 2'), findsOneWidget);
    });

    testWidgets('deve exibir botão de filtro na AppBar', (tester) async {
      // Arrange
      when(() => mockRepository.getEvents()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestableWidget(events: []));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('deve abrir modal de filtros ao tocar no botão de filtro', (tester) async {
      // Arrange
      when(() => mockRepository.getEvents()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestableWidget(events: []));
      await tester.pumpAndSettle();

      // Tocar no botão de filtro
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Filtrar Eventos'), findsOneWidget);
      expect(find.text('Todos os eventos'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.text('Bem-estar'), findsOneWidget);
      expect(find.text('Esportes'), findsOneWidget);
    });

    testWidgets('deve permitir pull-to-refresh', (tester) async {
      // Arrange
      when(() => mockRepository.getEvents()).thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestableWidget(events: []));
      await tester.pumpAndSettle();

      // Simular pull-to-refresh
      await tester.fling(find.byType(CustomScrollView), const Offset(0, 300), 1000);
      await tester.pump();

      // Assert
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
} 