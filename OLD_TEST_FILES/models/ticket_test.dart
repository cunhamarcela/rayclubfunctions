// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/models/ticket.dart';

void main() {
  group('Ticket Model Tests', () {
    final testDate = DateTime(2024);
    final testJson = {
      'id': 'ticket123',
      'eventId': 'event123',
      'userId': 'user123',
      'status': 'valid',
      'purchaseDate': '2024-01-01T00:00:00.000Z',
      'price': 29.99,
      'ticketNumber': 'TKT-001',
      'metadata': {'key': 'value'},
    };

    test('should create Ticket from json', () {
      final ticket = Ticket.fromJson(testJson);

      expect(ticket.id, 'ticket123');
      expect(ticket.eventId, 'event123');
      expect(ticket.userId, 'user123');
      expect(ticket.status, 'valid');
      expect(ticket.purchaseDate, isA<DateTime>());
      expect(ticket.price, 29.99);
      expect(ticket.ticketNumber, 'TKT-001');
      expect(ticket.metadata?['key'], 'value');
    });

    test('should convert Ticket to json', () {
      final ticket = Ticket(
        id: 'ticket123',
        eventId: 'event123',
        userId: 'user123',
        status: 'valid',
        purchaseDate: testDate,
        price: 29.99,
        ticketNumber: 'TKT-001',
        metadata: {'key': 'value'},
      );

      final json = ticket.toJson();

      expect(json['id'], 'ticket123');
      expect(json['eventId'], 'event123');
      expect(json['userId'], 'user123');
      expect(json['status'], 'valid');
      expect(json['purchaseDate'], isA<String>());
      expect(json['price'], 29.99);
      expect(json['ticketNumber'], 'TKT-001');
      expect(json['metadata']['key'], 'value');
    });

    test('should copy Ticket with new values', () {
      final ticket = Ticket(
        id: 'ticket123',
        eventId: 'event123',
        userId: 'user123',
        status: 'valid',
        purchaseDate: testDate,
        price: 29.99,
        ticketNumber: 'TKT-001',
      );

      final updatedTicket = ticket.copyWith(
        status: 'used',
        metadata: {'used_at': '2024-01-02T00:00:00.000Z'},
      );

      expect(updatedTicket.id, ticket.id);
      expect(updatedTicket.eventId, ticket.eventId);
      expect(updatedTicket.userId, ticket.userId);
      expect(updatedTicket.status, 'used');
      expect(updatedTicket.metadata?['used_at'], '2024-01-02T00:00:00.000Z');
      expect(updatedTicket.purchaseDate, ticket.purchaseDate);
      expect(updatedTicket.price, ticket.price);
      expect(updatedTicket.ticketNumber, ticket.ticketNumber);
    });

    test('should implement equality', () {
      final ticket1 = Ticket(
        id: 'ticket123',
        eventId: 'event123',
        userId: 'user123',
        status: 'valid',
        purchaseDate: testDate,
        price: 29.99,
        ticketNumber: 'TKT-001',
      );

      final ticket2 = Ticket(
        id: 'ticket123',
        eventId: 'event123',
        userId: 'user123',
        status: 'valid',
        purchaseDate: testDate,
        price: 29.99,
        ticketNumber: 'TKT-001',
      );

      final ticket3 = Ticket(
        id: 'ticket456',
        eventId: 'event123',
        userId: 'user123',
        status: 'valid',
        purchaseDate: testDate,
        price: 29.99,
        ticketNumber: 'TKT-002',
      );

      expect(ticket1, equals(ticket2));
      expect(ticket1, isNot(equals(ticket3)));
      expect(ticket1.hashCode, equals(ticket2.hashCode));
      expect(ticket1.hashCode, isNot(equals(ticket3.hashCode)));
    });
  });
}
