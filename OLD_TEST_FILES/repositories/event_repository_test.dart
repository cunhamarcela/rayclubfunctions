// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/models/event.dart';
import 'package:ray_club_app/repositories/event_repository.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {
  @override
  SupabaseQueryBuilder from(String table) => MockSupabaseQueryBuilder();
}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

void main() {
  group('EventRepository Tests', () {
    late MockSupabaseClient mockSupabaseClient;
    late EventRepository eventRepository;
    late MockSupabaseQueryBuilder mockQueryBuilder;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      eventRepository = EventRepository(mockSupabaseClient);
    });

    test('getEvents should return list of events', () async {
      final testEvents = [
        {
          'id': 'event1',
          'title': 'Test Event 1',
          'description': 'Description 1',
          'start_date': '2024-01-01T00:00:00.000Z',
          'end_date': '2024-01-01T02:00:00.000Z',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'organizer_id': 'org123',
        },
        {
          'id': 'event2',
          'title': 'Test Event 2',
          'description': 'Description 2',
          'start_date': '2024-01-02T00:00:00.000Z',
          'end_date': '2024-01-02T02:00:00.000Z',
          'created_at': '2024-01-01T00:00:00.000Z',
          'updated_at': '2024-01-01T00:00:00.000Z',
          'organizer_id': 'org123',
        },
      ];

      when(mockSupabaseClient.from('events')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenAnswer((_) async => testEvents);

      final events = await eventRepository.getEvents();

      expect(events.length, 2);
      expect(events[0].id, 'event1');
      expect(events[1].id, 'event2');
      verify(mockSupabaseClient.from('events')).called(1);
      verify(mockQueryBuilder.select()).called(1);
    });

    test('getEvent should return single event', () async {
      final testEvent = {
        'id': 'event1',
        'title': 'Test Event',
        'description': 'Description',
        'start_date': '2024-01-01T00:00:00.000Z',
        'end_date': '2024-01-01T02:00:00.000Z',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
        'organizer_id': 'org123',
      };

      when(mockSupabaseClient.from('events')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenAnswer((_) async => [testEvent]);

      final event = await eventRepository.getEvent('event1');

      expect(event.id, 'event1');
      expect(event.title, 'Test Event');
      verify(mockSupabaseClient.from('events')).called(1);
      verify(mockQueryBuilder.select()).called(1);
    });

    test('createEvent should return created event', () async {
      final newEvent = Event(
        id: 'event1',
        title: 'New Event',
        description: 'Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        organizerId: 'org123',
      );

      final testResponse = {
        'id': 'event1',
        'title': 'New Event',
        'description': 'Description',
        'start_date': '2024-01-01T00:00:00.000Z',
        'end_date': '2024-01-01T02:00:00.000Z',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
        'organizer_id': 'org123',
      };

      when(mockSupabaseClient.from('events')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.insert(any))
          .thenAnswer((_) async => [testResponse]);

      final createdEvent = await eventRepository.createEvent(newEvent);

      expect(createdEvent.id, 'event1');
      expect(createdEvent.title, 'New Event');
      verify(mockSupabaseClient.from('events')).called(1);
      verify(mockQueryBuilder.insert(any)).called(1);
    });

    test('updateEvent should return updated event', () async {
      final updatedEvent = Event(
        id: 'event1',
        title: 'Updated Event',
        description: 'Updated Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 2)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        organizerId: 'org123',
      );

      final testResponse = {
        'id': 'event1',
        'title': 'Updated Event',
        'description': 'Updated Description',
        'start_date': '2024-01-01T00:00:00.000Z',
        'end_date': '2024-01-01T02:00:00.000Z',
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
        'organizer_id': 'org123',
      };

      when(mockSupabaseClient.from('events')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.update(any))
          .thenAnswer((_) async => [testResponse]);

      final result = await eventRepository.updateEvent(updatedEvent);

      expect(result.id, 'event1');
      expect(result.title, 'Updated Event');
      expect(result.description, 'Updated Description');
      verify(mockSupabaseClient.from('events')).called(1);
      verify(mockQueryBuilder.update(any)).called(1);
    });

    test('deleteEvent should return success', () async {
      when(mockSupabaseClient.from('events')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.delete()).thenAnswer((_) async => null);

      final result = await eventRepository.deleteEvent('event1');

      expect(result, true);
      verify(mockSupabaseClient.from('events')).called(1);
      verify(mockQueryBuilder.delete()).called(1);
    });

    test('getEvents should handle errors', () async {
      when(mockSupabaseClient.from('events')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenThrow(Exception('Database error'));

      expect(
        () => eventRepository.getEvents(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
