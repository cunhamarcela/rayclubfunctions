// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/features/home/widgets/workout/workout_card.dart';

void main() {
  testWidgets('WorkoutCard renders correctly with mock data', (WidgetTester tester) async {
    final mockWorkout = {
      'id': '1',
      'name': 'Teste de Treino',
      'duration': '45 min',
      'level': 'Intermediário',
      'imageUrl': 'assets/images/workout_default.jpg',
    };

    bool tapCalled = false;

    // Constrói o widget de teste
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutCard(
            workout: mockWorkout,
            onTap: () {
              tapCalled = true;
            },
          ),
        ),
      ),
    );

    // Verifica se o nome e os detalhes estão presentes
    expect(find.text('Teste de Treino'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);
    expect(find.text('Intermediário'), findsOneWidget);

    // Verifica se o ícone está presente
    expect(find.byIcon(Icons.fitness_center), findsOneWidget);

    // Testa o callback de toque
    await tester.tap(find.byType(GestureDetector));
    expect(tapCalled, true);
  });

  testWidgets('WorkoutCard uses fallback values when data is null', (WidgetTester tester) async {
    // Constrói o widget de teste com dados nulos
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutCard(
            workout: null,
          ),
        ),
      ),
    );

    // Verifica se os valores padrão estão sendo usados
    expect(find.text('Workout'), findsOneWidget);
    expect(find.text('30 min'), findsOneWidget);
    expect(find.text('Beginner'), findsOneWidget);
  });
} 
