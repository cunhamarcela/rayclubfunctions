import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ray_club_app/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Test', () {
    testWidgets('full login flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should start at login screen
      expect(find.text('Login'), findsOneWidget);

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Should navigate to home screen
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
    });

    testWidgets('create and view event flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Navigate to events
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Tap create event button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Fill event details
      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Test Event',
      );
      await tester.enterText(
        find.byKey(const Key('event_description_field')),
        'Test Description',
      );

      // Save event
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify event appears in list
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);

      // Tap on event to view details
      await tester.tap(find.text('Test Event'));
      await tester.pumpAndSettle();

      // Verify event details screen
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Buy Ticket'), findsOneWidget);
    });

    testWidgets('purchase ticket flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Login first
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Navigate to events
      await tester.tap(find.text('Events'));
      await tester.pumpAndSettle();

      // Select an event
      await tester.tap(find.text('Test Event'));
      await tester.pumpAndSettle();

      // Tap buy ticket
      await tester.tap(find.text('Buy Ticket'));
      await tester.pumpAndSettle();

      // Confirm purchase
      await tester.tap(find.text('Confirm Purchase'));
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Purchase Successful'), findsOneWidget);

      // Navigate to tickets
      await tester.tap(find.text('My Tickets'));
      await tester.pumpAndSettle();

      // Verify ticket appears in list
      expect(find.text('Test Event'), findsOneWidget);
      expect(find.text('Valid'), findsOneWidget);
    });
  });
} 