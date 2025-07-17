// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/models/event.dart';
import 'package:ray_club_app/view_models/event_view_model.dart';
import '../mocks/mock_service.mocks.dart';

void main() {
  group('EventViewModel Tests', () {
    late MockStorageService mockStorageService;
    late EventViewModel eventViewModel;

    setUp(() {
      mockStorageService = MockStorageService();
      eventViewModel = EventViewModel(
        storageService: mockStorageService,
      );
    });

    test('initial state should be empty', () {
      expect(eventViewModel.events, isEmpty);
      expect(eventViewModel.isLoading, false);
      expect(eventViewModel.selectedEvent, null);
    });

    test('fetchEvents should update state with events', () async {
      final testEvents = [
        Event(
          id: 'event1',
          title: 'Test Event 1',
          description: 'Description 1',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          organizerId: 'org123',
        ),
        Event(
          id: 'event2',
          title: 'Test Event 2',
          description: 'Description 2',
          startDate: DateTime.now().add(const Duration(days: 1)),
          endDate: DateTime.now().add(const Duration(days: 1, hours: 2)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          organizerId: 'org123',
        ),
      ];

      when(mockStorageService.getEvents()).thenAnswer((_) async => testEvents);

      expect(eventViewModel.isLoading, false);

      await eventViewModel.fetchEvents();

      expect(eventViewModel.events, equals(testEvents));
      expect(eventViewModel.isLoading, false);

      verify(mockStorageService.getEvents()).called(1);
    });

    test('fetchEvents should handle errors', () async {
      when(mockStorageService.getEvents())
          .thenThrow(Exception('Failed to fetch events'));

      expect(eventViewModel.isLoading, false);

      await eventViewModel.fetchEvents();

      expect(eventViewModel.events, isEmpty);
      expect(eventViewModel.isLoading, false);
      expect(eventViewModel.error, isNotNull);

      verify(mockStorageService.getEvents()).called(1);
    });

    test('selectEvent should update selected event', () async {
      final testEvent = Event(
        id: 'event1',
        title: 'Test Event',
        description: 'Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        organizerId: 'org123',
      );

      when(mockStorageService.getEvent('event1'))
          .thenAnswer((_) async => testEvent);

      expect(eventViewModel.selectedEvent, null);

      await eventViewModel.selectEvent('event1');

      expect(eventViewModel.selectedEvent, equals(testEvent));
      expect(eventViewModel.isLoading, false);

      verify(mockStorageService.getEvent('event1')).called(1);
    });

    test('createEvent should add new event to list', () async {
      final newEvent = Event(
        id: 'event1',
        title: 'New Event',
        description: 'New Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        organizerId: 'org123',
      );

      when(mockStorageService.createEvent(any))
          .thenAnswer((_) async => newEvent);

      expect(eventViewModel.events, isEmpty);

      final result = await eventViewModel.createEvent(newEvent);

      expect(result, true);
      expect(eventViewModel.events, contains(newEvent));
      expect(eventViewModel.isLoading, false);

      verify(mockStorageService.createEvent(any)).called(1);
    });

    test('updateEvent should modify existing event', () async {
      final originalEvent = Event(
        id: 'event1',
        title: 'Original Event',
        description: 'Original Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        organizerId: 'org123',
      );

      final updatedEvent = originalEvent.copyWith(
        title: 'Updated Event',
        description: 'Updated Description',
      );

      // Add original event to list
      when(mockStorageService.createEvent(any))
          .thenAnswer((_) async => originalEvent);
      await eventViewModel.createEvent(originalEvent);

      // Setup update mock
      when(mockStorageService.updateEvent(any))
          .thenAnswer((_) async => updatedEvent);

      final result = await eventViewModel.updateEvent(updatedEvent);

      expect(result, true);
      expect(eventViewModel.events.first.title, 'Updated Event');
      expect(eventViewModel.events.first.description, 'Updated Description');
      expect(eventViewModel.isLoading, false);

      verify(mockStorageService.updateEvent(any)).called(1);
    });

    test('deleteEvent should remove event from list', () async {
      final eventToDelete = Event(
        id: 'event1',
        title: 'Event to Delete',
        description: 'Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        organizerId: 'org123',
      );

      // Add event to list
      when(mockStorageService.createEvent(any))
          .thenAnswer((_) async => eventToDelete);
      await eventViewModel.createEvent(eventToDelete);

      // Setup delete mock
      when(mockStorageService.deleteEvent('event1'))
          .thenAnswer((_) async => true);

      expect(eventViewModel.events, contains(eventToDelete));

      final result = await eventViewModel.deleteEvent('event1');

      expect(result, true);
      expect(eventViewModel.events, isEmpty);
      expect(eventViewModel.isLoading, false);

      verify(mockStorageService.deleteEvent('event1')).called(1);
    });
  });
}
