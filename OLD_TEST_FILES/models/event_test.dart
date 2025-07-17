// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/models/event.dart';

void main() {
  group('Event Model Tests', () {
    final testDate = DateTime(2024);
    final testJson = {
      'id': 'event123',
      'title': 'Test Event',
      'description': 'Test Description',
      'location': 'Test Location',
      'imageUrl': 'https://example.com/event.jpg',
      'startDate': '2024-01-01T00:00:00.000Z',
      'endDate': '2024-01-02T00:00:00.000Z',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'updatedAt': '2024-01-01T00:00:00.000Z',
      'capacity': 100,
      'price': 29.99,
      'status': 'active',
      'organizerId': 'org123',
      'metadata': {'key': 'value'},
    };

    test('should create Event from json', () {
      final event = Event.fromJson(testJson);

      expect(event.id, 'event123');
      expect(event.title, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.location, 'Test Location');
      expect(event.imageUrl, 'https://example.com/event.jpg');
      expect(event.startDate, isA<DateTime>());
      expect(event.endDate, isA<DateTime>());
      expect(event.createdAt, isA<DateTime>());
      expect(event.updatedAt, isA<DateTime>());
      expect(event.capacity, 100);
      expect(event.price, 29.99);
      expect(event.status, 'active');
      expect(event.organizerId, 'org123');
      expect(event.metadata?['key'], 'value');
    });

    test('should convert Event to json', () {
      final event = Event(
        id: 'event123',
        title: 'Test Event',
        description: 'Test Description',
        location: 'Test Location',
        imageUrl: 'https://example.com/event.jpg',
        startDate: testDate,
        endDate: testDate.add(const Duration(days: 1)),
        createdAt: testDate,
        updatedAt: testDate,
        capacity: 100,
        price: 29.99,
        status: 'active',
        organizerId: 'org123',
        metadata: {'key': 'value'},
      );

      final json = event.toJson();

      expect(json['id'], 'event123');
      expect(json['title'], 'Test Event');
      expect(json['description'], 'Test Description');
      expect(json['location'], 'Test Location');
      expect(json['imageUrl'], 'https://example.com/event.jpg');
      expect(json['startDate'], isA<String>());
      expect(json['endDate'], isA<String>());
      expect(json['createdAt'], isA<String>());
      expect(json['updatedAt'], isA<String>());
      expect(json['capacity'], 100);
      expect(json['price'], 29.99);
      expect(json['status'], 'active');
      expect(json['organizerId'], 'org123');
      expect(json['metadata']['key'], 'value');
    });

    test('should copy Event with new values', () {
      final event = Event(
        id: 'event123',
        title: 'Test Event',
        description: 'Test Description',
        startDate: testDate,
        endDate: testDate.add(const Duration(days: 1)),
        createdAt: testDate,
        updatedAt: testDate,
        organizerId: 'org123',
      );

      final updatedEvent = event.copyWith(
        title: 'New Title',
        description: 'New Description',
        capacity: 200,
      );

      expect(updatedEvent.id, event.id);
      expect(updatedEvent.title, 'New Title');
      expect(updatedEvent.description, 'New Description');
      expect(updatedEvent.capacity, 200);
      expect(updatedEvent.startDate, event.startDate);
      expect(updatedEvent.organizerId, event.organizerId);
    });

    test('should implement equality', () {
      final event1 = Event(
        id: 'event123',
        title: 'Test Event',
        description: 'Test Description',
        startDate: testDate,
        endDate: testDate.add(const Duration(days: 1)),
        createdAt: testDate,
        updatedAt: testDate,
        organizerId: 'org123',
      );

      final event2 = Event(
        id: 'event123',
        title: 'Test Event',
        description: 'Test Description',
        startDate: testDate,
        endDate: testDate.add(const Duration(days: 1)),
        createdAt: testDate,
        updatedAt: testDate,
        organizerId: 'org123',
      );

      final event3 = Event(
        id: 'event456',
        title: 'Test Event',
        description: 'Test Description',
        startDate: testDate,
        endDate: testDate.add(const Duration(days: 1)),
        createdAt: testDate,
        updatedAt: testDate,
        organizerId: 'org123',
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
      expect(event1.hashCode, equals(event2.hashCode));
      expect(event1.hashCode, isNot(equals(event3.hashCode)));
    });
  });
}
