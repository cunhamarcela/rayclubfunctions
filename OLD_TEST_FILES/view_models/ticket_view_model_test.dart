// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/models/ticket.dart';
import 'package:ray_club_app/view_models/ticket_view_model.dart';
import '../mocks/mock_service.mocks.dart';

void main() {
  group('TicketViewModel Tests', () {
    late MockStorageService mockStorageService;
    late TicketViewModel ticketViewModel;

    setUp(() {
      mockStorageService = MockStorageService();
      ticketViewModel = TicketViewModel(
        storageService: mockStorageService,
      );
    });

    test('initial state should be empty', () {
      expect(ticketViewModel.tickets, isEmpty);
      expect(ticketViewModel.isLoading, false);
      expect(ticketViewModel.selectedTicket, null);
    });

    test('fetchTickets should update state with tickets', () async {
      final testTickets = [
        Ticket(
          id: 'ticket1',
          eventId: 'event1',
          userId: 'user1',
          status: 'valid',
          purchaseDate: DateTime.now(),
          price: 29.99,
          ticketNumber: 'TKT-001',
        ),
        Ticket(
          id: 'ticket2',
          eventId: 'event1',
          userId: 'user2',
          status: 'valid',
          purchaseDate: DateTime.now(),
          price: 29.99,
          ticketNumber: 'TKT-002',
        ),
      ];

      when(mockStorageService.getTickets())
          .thenAnswer((_) async => testTickets);

      expect(ticketViewModel.isLoading, false);

      await ticketViewModel.fetchTickets();

      expect(ticketViewModel.tickets, equals(testTickets));
      expect(ticketViewModel.isLoading, false);

      verify(mockStorageService.getTickets()).called(1);
    });

    test('fetchTickets should handle errors', () async {
      when(mockStorageService.getTickets())
          .thenThrow(Exception('Failed to fetch tickets'));

      expect(ticketViewModel.isLoading, false);

      await ticketViewModel.fetchTickets();

      expect(ticketViewModel.tickets, isEmpty);
      expect(ticketViewModel.isLoading, false);
      expect(ticketViewModel.error, isNotNull);

      verify(mockStorageService.getTickets()).called(1);
    });

    test('fetchTicketsByEvent should return event tickets', () async {
      final testTickets = [
        Ticket(
          id: 'ticket1',
          eventId: 'event1',
          userId: 'user1',
          status: 'valid',
          purchaseDate: DateTime.now(),
          price: 29.99,
          ticketNumber: 'TKT-001',
        ),
        Ticket(
          id: 'ticket2',
          eventId: 'event1',
          userId: 'user2',
          status: 'valid',
          purchaseDate: DateTime.now(),
          price: 29.99,
          ticketNumber: 'TKT-002',
        ),
      ];

      when(mockStorageService.getTicketsByEvent('event1'))
          .thenAnswer((_) async => testTickets);

      final eventTickets = await ticketViewModel.fetchTicketsByEvent('event1');

      expect(eventTickets, equals(testTickets));
      expect(ticketViewModel.isLoading, false);

      verify(mockStorageService.getTicketsByEvent('event1')).called(1);
    });

    test('purchaseTicket should create new ticket', () async {
      final newTicket = Ticket(
        id: 'ticket1',
        eventId: 'event1',
        userId: 'user1',
        status: 'valid',
        purchaseDate: DateTime.now(),
        price: 29.99,
        ticketNumber: 'TKT-001',
      );

      when(mockStorageService.createTicket(any))
          .thenAnswer((_) async => newTicket);

      expect(ticketViewModel.tickets, isEmpty);

      final result = await ticketViewModel.purchaseTicket(
        eventId: 'event1',
        userId: 'user1',
        price: 29.99,
      );

      expect(result, true);
      expect(ticketViewModel.tickets, contains(newTicket));
      expect(ticketViewModel.isLoading, false);

      verify(mockStorageService.createTicket(any)).called(1);
    });

    test('validateTicket should update ticket status', () async {
      final originalTicket = Ticket(
        id: 'ticket1',
        eventId: 'event1',
        userId: 'user1',
        status: 'valid',
        purchaseDate: DateTime.now(),
        price: 29.99,
        ticketNumber: 'TKT-001',
      );

      final validatedTicket = originalTicket.copyWith(
        status: 'used',
        metadata: {'validated_at': DateTime.now().toIso8601String()},
      );

      // Add original ticket to list
      when(mockStorageService.createTicket(any))
          .thenAnswer((_) async => originalTicket);
      await ticketViewModel.purchaseTicket(
        eventId: 'event1',
        userId: 'user1',
        price: 29.99,
      );

      // Setup validate mock
      when(mockStorageService.updateTicket(any))
          .thenAnswer((_) async => validatedTicket);

      final result = await ticketViewModel.validateTicket('ticket1');

      expect(result, true);
      expect(ticketViewModel.tickets.first.status, 'used');
      expect(ticketViewModel.tickets.first.metadata, isNotNull);
      expect(ticketViewModel.isLoading, false);

      verify(mockStorageService.updateTicket(any)).called(1);
    });

    test('refundTicket should update ticket status and add refund metadata',
        () async {
      final originalTicket = Ticket(
        id: 'ticket1',
        eventId: 'event1',
        userId: 'user1',
        status: 'valid',
        purchaseDate: DateTime.now(),
        price: 29.99,
        ticketNumber: 'TKT-001',
      );

      final refundedTicket = originalTicket.copyWith(
        status: 'refunded',
        metadata: {
          'refunded_at': DateTime.now().toIso8601String(),
          'refund_amount': 29.99,
        },
      );

      // Add original ticket to list
      when(mockStorageService.createTicket(any))
          .thenAnswer((_) async => originalTicket);
      await ticketViewModel.purchaseTicket(
        eventId: 'event1',
        userId: 'user1',
        price: 29.99,
      );

      // Setup refund mock
      when(mockStorageService.updateTicket(any))
          .thenAnswer((_) async => refundedTicket);

      final result = await ticketViewModel.refundTicket('ticket1');

      expect(result, true);
      expect(ticketViewModel.tickets.first.status, 'refunded');
      expect(ticketViewModel.tickets.first.metadata?['refund_amount'], 29.99);
      expect(ticketViewModel.isLoading, false);

      verify(mockStorageService.updateTicket(any)).called(1);
    });
  });
}
