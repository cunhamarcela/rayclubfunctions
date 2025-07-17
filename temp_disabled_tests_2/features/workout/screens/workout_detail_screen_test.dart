// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Project imports:
import 'package:ray_club_app/features/workout/models/workout_model.dart';
import 'package:ray_club_app/features/workout/models/exercise.dart';
import 'package:ray_club_app/features/workout/screens/workout_detail_screen.dart';
import 'package:ray_club_app/features/workout/viewmodels/states/workout_state.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_view_model.dart';
import 'package:ray_club_app/features/workout/repositories/workout_repository.dart';

// Create mock using Mocktail
class MockWorkoutViewModel extends Mock implements WorkoutViewModel {}

// Create a mock or fake repository if needed for ViewModel constructor
class MockWorkoutRepository extends Mock implements WorkoutRepository {}

void main() {
  // Create mock instances
  late MockWorkoutViewModel mockViewModel;
  late WorkoutState mockState;

  // Sample data using correct Exercise model
  final testWorkout = Workout(
    id: '1',
    title: 'Test Workout',
    description: 'This is a test workout description for testing purposes.',
    imageUrl: null,
    type: 'Yoga',
    durationMinutes: 45,
    difficulty: 'intermediário',
    equipment: ['mat', 'blocks', 'strap'],
    sections: [
      WorkoutSection(
        name: 'Aquecimento',
        exercises: [
          Exercise(
            id: 'warm1',
            name: 'Warm-up Exercise 1', 
            detail: 'Warm-up details',
            duration: 60, 
            reps: 0
          ),
          Exercise(
            id: 'warm2',
            name: 'Warm-up Exercise 2', 
            detail: 'Warm-up details 2',
            duration: 60, 
            reps: 0
          ),
        ]
      ),
      WorkoutSection(
        name: 'Parte Principal',
        exercises: [
          Exercise(
            id: 'main1',
            name: 'Main Exercise 1', 
            detail: 'Main exercise details',
            duration: 0, 
            reps: 12
          ),
          Exercise(
            id: 'main2',
            name: 'Main Exercise 2', 
            detail: 'Main exercise details 2',
            duration: 0, 
            reps: 10
          ),
          Exercise(
            id: 'main3',
            name: 'Main Exercise 3', 
            detail: 'Main exercise details 3',
            duration: 0, 
            reps: 8
          ),
        ]
      ),
      WorkoutSection(
        name: 'Desaquecimento',
        exercises: [
          Exercise(
            id: 'cool1',
            name: 'Cool-down Exercise 1', 
            detail: 'Cool-down details',
            duration: 90, 
            reps: 0
          ),
        ]
      ),
    ],
    creatorId: 'test-creator',
    createdAt: DateTime.now(),
  );

  setUp(() {
    // Initialize mocks for each test
    mockViewModel = MockWorkoutViewModel();
    // Define the initial state for the mock ViewModel
    mockState = WorkoutState.loaded(
      workouts: [testWorkout],
      filteredWorkouts: [testWorkout],
      categories: ['Yoga'],
      filter: const WorkoutFilter(),
      selectedWorkout: testWorkout
    );

    // Stub the state getter
    when(() => mockViewModel.state).thenReturn(mockState);
    // Stub other methods if they are called by the widget
    when(() => mockViewModel.selectWorkout(any())).thenAnswer((_) async {});
  });

  // Helper function to pump the widget with necessary setup
  Future<void> pumpWorkoutDetailScreen(WidgetTester tester) async {
     await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override with the mock ViewModel instance
          workoutViewModelProvider.overrideWith((ref) => mockViewModel),
        ],
        child: MaterialApp(
          home: WorkoutDetailScreen(workoutId: '1'),
        ),
      ),
    );
  }


  testWidgets('renders workout detail screen correctly', (WidgetTester tester) async {
    // Act
    await pumpWorkoutDetailScreen(tester);

    // Assert - Check for various elements
    expect(find.text('Test Workout'), findsOneWidget);
    expect(find.text('This is a test workout description for testing purposes.'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
    expect(find.text('intermediário'), findsOneWidget);
    expect(find.text('Yoga'), findsOneWidget);
    expect(find.text('Equipamentos necessários'), findsOneWidget);
    expect(find.text('mat'), findsOneWidget);
    expect(find.text('blocks'), findsOneWidget);
    expect(find.text('strap'), findsOneWidget);
    expect(find.text('Aquecimento'), findsOneWidget);
    expect(find.text('Parte Principal'), findsOneWidget);
    expect(find.text('Desaquecimento'), findsOneWidget);
    expect(find.text('INICIAR TREINO'), findsOneWidget);
  });

  testWidgets('tapping start button shows snackbar', (WidgetTester tester) async {
     // Act
    await pumpWorkoutDetailScreen(tester);

    // Assert: Verify start button exists
    expect(find.text('INICIAR TREINO'), findsOneWidget);
    
    // Act: Tap the start button
    await tester.tap(find.text('INICIAR TREINO'));
    await tester.pumpAndSettle(); // Let snackbar appear
    
    // Assert: Verify snackbar is displayed
    expect(find.text('Iniciando treino...'), findsOneWidget);
  });

  testWidgets('exercise items are displayed correctly', (WidgetTester tester) async {
     // Act
    await pumpWorkoutDetailScreen(tester);

    // Assert: Verify exercise names are displayed
    expect(find.text('Warm-up Exercise 1'), findsOneWidget);
    expect(find.text('Warm-up Exercise 2'), findsOneWidget);
    expect(find.text('Main Exercise 1'), findsOneWidget);
    expect(find.text('Main Exercise 2'), findsOneWidget);
    expect(find.text('Main Exercise 3'), findsOneWidget);
    expect(find.text('Cool-down Exercise 1'), findsOneWidget);
    
    // Optionally check for exercise details like reps/duration if displayed
    // expect(find.textContaining('60s'), findsNWidgets(3)); // Example if duration is shown
    // expect(find.textContaining('12 reps'), findsOneWidget); // Example if reps are shown
  });
} 
