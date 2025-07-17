// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:ray_club_app/features/auth/models/user.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
class MockEventRepository extends Mock implements EventRepository {}
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late EventViewModel viewModel;
  late MockEventRepository mockRepository;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockRepository = MockEventRepository();
    mockAuthRepository = MockAuthRepository();
    
    // Setup default auth user
    when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => 
      User(
        id: 'test-user-id',
        email: 'test@example.com',
        name: 'Test User',
      )
    );
    
    viewModel = EventViewModel(
      repository: mockRepository,
      authRepository: mockAuthRepository,
    );
  });

  // group('EventViewModel', () {
    // test('initial state is correct', () {
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.events, isEmpty);
      expect(viewModel.state.errorMessage, isNull);
    });

    // group('loadEvents', () {
      // test('loads events successfully', () async {
        // Arrange
        final events = [
          Event(
            id: 'event-1',
            title: 'Evento 1',
            description: 'Descrição do evento 1',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 1)),
            location: 'Local 1',
            organizerId: 'test-user-id',
            maxAttendees: 50,
            currentAttendees: 10,
          ),
          Event(
            id: 'event-2',
            title: 'Evento 2',
            description: 'Descrição do evento 2',
            startDate: DateTime.now().add(const Duration(days: 2)),
            endDate: DateTime.now().add(const Duration(days: 3)),
            location: 'Local 2',
            organizerId: 'other-user-id',
            maxAttendees: 30,
            currentAttendees: 5,
          ),
        ];
        
        when(() => mockRepository.getEvents())
            .thenAnswer((_) async => events);
        
        // Act
        await viewModel.loadEvents();
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.events.length, 2);
        expect(viewModel.state.events[0].id, 'event-1');
        expect(viewModel.state.events[1].id, 'event-2');
        expect(viewModel.state.errorMessage, isNull);
        
        verify(() => mockRepository.getEvents()).called(1);
      });
      
      // test('handles error when loading events fails', () async {
        // Arrange
        when(() => mockRepository.getEvents())
            .thenThrow(Exception('Falha ao carregar eventos'));
        
        // Act
        await viewModel.loadEvents();
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.events, isEmpty);
        expect(viewModel.state.errorMessage, contains('Falha ao carregar eventos'));
        
        verify(() => mockRepository.getEvents()).called(1);
      });
    });
    
    // group('createEvent', () {
      // test('creates event successfully', () async {
        // Arrange
        final newEvent = Event(
          id: '',
          title: 'Novo Evento',
          description: 'Descrição do novo evento',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          location: 'Local do evento',
          organizerId: 'test-user-id',
          maxAttendees: 100,
          currentAttendees: 0,
        );
        
        final createdEvent = newEvent.copyWith(id: 'new-event-id');
        
        when(() => mockRepository.createEvent(any))
            .thenAnswer((_) async => createdEvent);
        
        // Act
        final result = await viewModel.createEvent(newEvent);
        
        // Assert
        expect(result, isNotNull);
        expect(result.id, 'new-event-id');
        expect(viewModel.state.successMessage, contains('Evento criado com sucesso'));
        
        verify(() => mockRepository.createEvent(any)).called(1);
      });
      
      // test('handles error when creating event fails', () async {
        // Arrange
        final newEvent = Event(
          id: '',
          title: 'Novo Evento',
          description: 'Descrição do novo evento',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          location: 'Local do evento',
          organizerId: 'test-user-id',
          maxAttendees: 100,
          currentAttendees: 0,
        );
        
        when(() => mockRepository.createEvent(any))
            .thenThrow(Exception('Falha ao criar evento'));
        
        // Act & Assert
        expect(() => viewModel.createEvent(newEvent), throwsException);
        
        verify(() => mockRepository.createEvent(any)).called(1);
      });
    });
    
    // group('getEventById', () {
      // test('gets event by id successfully', () async {
        // Arrange
        final eventId = 'event-1';
        final event = Event(
          id: eventId,
          title: 'Evento 1',
          description: 'Descrição do evento 1',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          location: 'Local 1',
          organizerId: 'test-user-id',
          maxAttendees: 50,
          currentAttendees: 10,
        );
        
        when(() => mockRepository.getEventById(eventId))
            .thenAnswer((_) async => event);
        
        // Act
        final result = await viewModel.getEventById(eventId);
        
        // Assert
        expect(result, isNotNull);
        expect(result.id, eventId);
        expect(viewModel.state.selectedEvent, isNotNull);
        expect(viewModel.state.selectedEvent?.id, eventId);
        
        verify(() => mockRepository.getEventById(eventId)).called(1);
      });
      
      // test('handles error when getting event by id fails', () async {
        // Arrange
        final eventId = 'non-existent-id';
        
        when(() => mockRepository.getEventById(eventId))
            .thenThrow(Exception('Evento não encontrado'));
        
        // Act & Assert
        expect(() => viewModel.getEventById(eventId), throwsException);
        
        verify(() => mockRepository.getEventById(eventId)).called(1);
      });
    });
    
    // group('registerForEvent', () {
      // test('registers user for event successfully', () async {
        // Arrange
        final eventId = 'event-1';
        
        when(() => mockRepository.registerForEvent(
          eventId: eventId,
          userId: 'test-user-id',
        )).thenAnswer((_) async {});
        
        // Act
        await viewModel.registerForEvent(eventId: eventId);
        
        // Assert
        expect(viewModel.state.successMessage, contains('Inscrição realizada com sucesso'));
        
        verify(() => mockRepository.registerForEvent(
          eventId: eventId,
          userId: 'test-user-id',
        )).called(1);
      });
      
      // test('handles error when registration fails', () async {
        // Arrange
        final eventId = 'event-1';
        
        when(() => mockRepository.registerForEvent(
          eventId: eventId,
          userId: 'test-user-id',
        )).thenThrow(Exception('Evento lotado'));
        
        // Act & Assert
        expect(() => viewModel.registerForEvent(eventId: eventId), throwsException);
        
        verify(() => mockRepository.registerForEvent(
          eventId: eventId,
          userId: 'test-user-id',
        )).called(1);
      });
    });
    
    // group('cancelRegistration', () {
      // test('cancels registration successfully', () async {
        // Arrange
        final eventId = 'event-1';
        
        when(() => mockRepository.cancelRegistration(
          eventId: eventId,
          userId: 'test-user-id',
        )).thenAnswer((_) async {});
        
        // Act
        await viewModel.cancelRegistration(eventId: eventId);
        
        // Assert
        expect(viewModel.state.successMessage, contains('Inscrição cancelada com sucesso'));
        
        verify(() => mockRepository.cancelRegistration(
          eventId: eventId,
          userId: 'test-user-id',
        )).called(1);
      });
    });
    
    // group('filterEvents', () {
      // test('filters events by type successfully', () async {
        // Arrange
        final events = [
          Event(
            id: 'event-1',
            title: 'Corrida',
            description: 'Descrição do evento 1',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 1)),
            location: 'Local 1',
            organizerId: 'test-user-id',
            maxAttendees: 50,
            currentAttendees: 10,
            type: 'running',
          ),
          Event(
            id: 'event-2',
            title: 'Yoga',
            description: 'Descrição do evento 2',
            startDate: DateTime.now().add(const Duration(days: 2)),
            endDate: DateTime.now().add(const Duration(days: 3)),
            location: 'Local 2',
            organizerId: 'other-user-id',
            maxAttendees: 30,
            currentAttendees: 5,
            type: 'yoga',
          ),
        ];
        
        when(() => mockRepository.getEvents(filters: any(named: 'filters')))
            .thenAnswer((_) async => events.where((e) => e.type == 'running').toList());
        
        // Act
        await viewModel.filterEvents(type: 'running');
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.events.length, 1);
        expect(viewModel.state.events[0].id, 'event-1');
        expect(viewModel.state.events[0].type, 'running');
        
        verify(() => mockRepository.getEvents(filters: {'type': 'running'})).called(1);
      });
    });
    
    // group('getUserEvents', () {
      // test('gets user registered events successfully', () async {
        // Arrange
        final events = [
          Event(
            id: 'event-1',
            title: 'Evento 1',
            description: 'Descrição do evento 1',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 1)),
            location: 'Local 1',
            organizerId: 'other-user-id',
            maxAttendees: 50,
            currentAttendees: 10,
            attendees: ['test-user-id'],
          ),
        ];
        
        when(() => mockRepository.getUserEvents('test-user-id'))
            .thenAnswer((_) async => events);
        
        // Act
        await viewModel.getUserEvents();
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.userEvents.length, 1);
        expect(viewModel.state.userEvents[0].id, 'event-1');
        
        verify(() => mockRepository.getUserEvents('test-user-id')).called(1);
      });
    });
  });
} 