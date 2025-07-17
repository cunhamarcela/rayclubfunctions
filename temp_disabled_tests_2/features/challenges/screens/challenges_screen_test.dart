// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Use mockito for mocking providers if needed
import 'package:mocktail/mocktail.dart' as mocktail; // Or mocktail

// Project imports:
import 'package:ray_club_app/features/auth/models/user.dart' as auth_user;
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/providers/challenge_provider.dart';
import 'package:ray_club_app/features/challenges/screens/challenges_screen.dart';
import 'package:ray_club_app/features/challenges/widgets/challenge_card.dart';
import 'package:ray_club_app/core/widgets/loading_indicator.dart';
import 'package:ray_club_app/core/widgets/empty_state.dart';

// --- Mocks ---
// Mock User if needed directly by currentUserProvider
class MockAuthUser extends mocktail.Mock implements auth_user.User {}

// Helper to create a ProviderContainer with overrides
ProviderContainer createContainer({
  required AsyncValue<List<Challenge>> officialChallengesState,
  required AsyncValue<List<Challenge>> userChallengesState,
  required AsyncValue<auth_user.User?> currentUserState,
}) {
  return ProviderContainer(
    overrides: [
      officialChallengesProvider.overrideWith((ref) => officialChallengesState),
      // Need to handle the family provider correctly
      userChallengesProvider('test-user-id').overrideWith((ref) => userChallengesState),
      // Override currentUserProvider directly
      currentUserProvider.overrideWith((ref) => currentUserState),
    ],
  );
}

// Mock Challenges Data
final testOfficialChallenge = Challenge(
  id: 'official-1', title: 'Official Challenge', description: 'Desc',
  startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 10)),
  isOfficial: true, points: 10, participants: [], type: 'daily', active: true,
);
final testUserChallenge = Challenge(
  id: 'user-1', title: 'My Challenge', description: 'Desc',
  startDate: DateTime.now(), endDate: DateTime.now().add(const Duration(days: 5)),
  isOfficial: false, points: 5, participants: [], type: 'daily', active: true, creatorId: 'test-user-id',
);
final testAuthUser = MockAuthUser();


void main() {
  setUpAll(() {
    // Setup mock user default values
    mocktail.when(() => testAuthUser.id).thenReturn('test-user-id');
    mocktail.when(() => testAuthUser.name).thenReturn('Test User');
    // Register fallback value for family provider argument if needed by mocktail
    mocktail.registerFallbackValue<String>('default-user-id');
  });

  testWidgets('ChallengesScreen displays loading indicators', (WidgetTester tester) async {
    // Arrange: Setup container with loading states
    final container = createContainer(
      officialChallengesState: const AsyncValue.loading(),
      userChallengesState: const AsyncValue.loading(),
      currentUserState: AsyncValue.data(testAuthUser), // User logged in
    );

    // Act: Pump the widget
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ChallengesScreen()), // Need MaterialApp
      ),
    );

    // Assert: Find loading indicators (expect at least two, one for each section)
    expect(find.byType(LoadingIndicator), findsAtLeastNWidgets(2));
    expect(find.byType(ChallengeCard), findsNothing);
    expect(find.byType(EmptyState), findsNothing);
  });

  testWidgets('ChallengesScreen displays error states', (WidgetTester tester) async {
    // Arrange: Setup container with error states
     final testError = Exception('Failed to load');
    final container = createContainer(
      officialChallengesState: AsyncValue.error(testError, StackTrace.current),
      userChallengesState: AsyncValue.error(testError, StackTrace.current),
      currentUserState: AsyncValue.data(testAuthUser), // User logged in
    );

    // Act: Pump the widget
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ChallengesScreen()),
      ),
    );
    await tester.pumpAndSettle(); // Allow state changes to settle

    // Assert: Find error messages or EmptyState with error config
    // Depending on how EmptyState is configured for errors
    expect(find.textContaining('Não foi possível carregar', findRichText: true), findsAtLeastNWidgets(2));
    expect(find.byType(ChallengeCard), findsNothing);
    expect(find.byType(LoadingIndicator), findsNothing);
     expect(find.widgetWithText(EmptyState, 'Tentar novamente'), findsAtLeastNWidgets(2));
  });

   testWidgets('ChallengesScreen displays empty states', (WidgetTester tester) async {
    // Arrange: Setup container with empty data states
    final container = createContainer(
      officialChallengesState: const AsyncValue.data([]), // Empty list
      userChallengesState: const AsyncValue.data([]), // Empty list
      currentUserState: AsyncValue.data(testAuthUser), // User logged in
    );

    // Act: Pump the widget
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ChallengesScreen()),
      ),
    );
     await tester.pumpAndSettle();

    // Assert: Find EmptyState widgets
    expect(find.widgetWithText(EmptyState, 'Não há desafios oficiais disponíveis no momento.'), findsOneWidget);
    expect(find.widgetWithText(EmptyState, 'Você ainda não participa de nenhum desafio.'), findsOneWidget);
    expect(find.byType(ChallengeCard), findsNothing);
    expect(find.byType(LoadingIndicator), findsNothing);
  });


  testWidgets('ChallengesScreen displays challenge cards when data is available', (WidgetTester tester) async {
    // Arrange: Setup container with data
    final container = createContainer(
      officialChallengesState: AsyncValue.data([testOfficialChallenge]),
      userChallengesState: AsyncValue.data([testUserChallenge]),
      currentUserState: AsyncValue.data(testAuthUser), // User logged in
    );

    // Act: Pump the widget
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ChallengesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Assert: Find ChallengeCard widgets
    expect(find.byType(ChallengeCard), findsNWidgets(2));
    expect(find.text(testOfficialChallenge.title), findsOneWidget);
    expect(find.text(testUserChallenge.title), findsOneWidget);
    expect(find.byType(LoadingIndicator), findsNothing);
    expect(find.byType(EmptyState), findsNothing);
    // Check if "Meus Desafios" section title is present
    expect(find.text('Meus Desafios'), findsOneWidget);
    // Check if "Criar Novo Desafio" button is present
    expect(find.widgetWithText(ElevatedButton, 'Criar Novo Desafio'), findsOneWidget);
  });

  testWidgets('ChallengesScreen hides user section when logged out', (WidgetTester tester) async {
    // Arrange: Setup container with user logged out
    final container = createContainer(
      officialChallengesState: AsyncValue.data([testOfficialChallenge]),
      // User challenges provider might not be called/relevant when logged out,
      // but provide a default state just in case.
      userChallengesState: const AsyncValue.data([]),
      currentUserState: const AsyncValue.data(null), // User logged out
    );

    // Act: Pump the widget
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ChallengesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Assert: Official challenge is shown, user section is hidden
    expect(find.byType(ChallengeCard), findsOneWidget);
    expect(find.text(testOfficialChallenge.title), findsOneWidget);
    expect(find.text('Meus Desafios'), findsNothing); // Section title hidden
    expect(find.widgetWithText(ElevatedButton, 'Criar Novo Desafio'), findsNothing); // Button hidden
    expect(find.byType(LoadingIndicator), findsNothing);
    // Check that the official challenges empty state is NOT shown
     expect(find.widgetWithText(EmptyState, 'Não há desafios oficiais disponíveis no momento.'), findsNothing);
     // Check that the user challenges empty state is NOT shown
     expect(find.widgetWithText(EmptyState, 'Você ainda não participa de nenhum desafio.'), findsNothing);

  });

   testWidgets('ChallengesScreen shows only official challenges when user challenges fail', (WidgetTester tester) async {
     // Arrange: Setup container with user challenges failing
     final testError = Exception('Failed to load user challenges');
     final container = createContainer(
       officialChallengesState: AsyncValue.data([testOfficialChallenge]),
       userChallengesState: AsyncValue.error(testError, StackTrace.current),
       currentUserState: AsyncValue.data(testAuthUser), // User logged in
     );

     // Act: Pump the widget
     await tester.pumpWidget(
       UncontrolledProviderScope(
         container: container,
         child: const MaterialApp(home: ChallengesScreen()),
       ),
     );
     await tester.pumpAndSettle();

     // Assert: Official challenge card is shown, user section shows error
     expect(find.byType(ChallengeCard), findsOneWidget); // Only the official one
     expect(find.text(testOfficialChallenge.title), findsOneWidget);
     expect(find.text('Meus Desafios'), findsOneWidget); // Section title still there
     expect(find.widgetWithText(EmptyState, 'Não foi possível carregar seus desafios.'), findsOneWidget); // User error shown
     expect(find.widgetWithText(ElevatedButton, 'Tentar novamente'), findsOneWidget); // Retry button in user error state
     expect(find.byType(LoadingIndicator), findsNothing);
   });

    testWidgets('ChallengesScreen shows only user challenges when official challenges fail', (WidgetTester tester) async {
     // Arrange: Setup container with official challenges failing
     final testError = Exception('Failed to load official challenges');
     final container = createContainer(
       officialChallengesState: AsyncValue.error(testError, StackTrace.current),
       userChallengesState: AsyncValue.data([testUserChallenge]),
       currentUserState: AsyncValue.data(testAuthUser), // User logged in
     );

     // Act: Pump the widget
     await tester.pumpWidget(
       UncontrolledProviderScope(
         container: container,
         child: const MaterialApp(home: ChallengesScreen()),
       ),
     );
     await tester.pumpAndSettle();

     // Assert: User challenge card is shown, official section shows error
     expect(find.byType(ChallengeCard), findsOneWidget); // Only the user one
     expect(find.text(testUserChallenge.title), findsOneWidget);
     expect(find.text('Desafios Oficiais'), findsOneWidget); // Section title still there
     expect(find.widgetWithText(EmptyState, 'Não foi possível carregar os desafios oficiais.'), findsOneWidget); // Official error shown
     // Ensure the user challenge empty state is not shown
     expect(find.widgetWithText(EmptyState, 'Você ainda não participa de nenhum desafio.'), findsNothing);
     expect(find.widgetWithText(ElevatedButton, 'Tentar novamente'), findsAtLeastNWidgets(1)); // Retry button in official error state
     expect(find.byType(LoadingIndicator), findsNothing);
   });

} 