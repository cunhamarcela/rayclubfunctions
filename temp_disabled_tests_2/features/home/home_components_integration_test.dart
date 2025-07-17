// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/features/home/widgets/challenge/challenge_card.dart';
import 'package:ray_club_app/features/home/widgets/register_exercise_sheet.dart';
import 'package:ray_club_app/features/home/widgets/workout/workout_card.dart';

void main() {
  group('Home Components Integration', () {
    testWidgets('Todos os componentes funcionam juntos em uma tela', (WidgetTester tester) async {
      // Lista de desafios para teste
      final challenges = [
        {
          'id': '1',
          'title': 'Desafio Semanal',
          'description': 'Complete 3 treinos esta semana',
          'imageUrl': 'assets/images/challenge_default.jpg',
        },
        {
          'id': '2',
          'title': 'Desafio de Corrida',
          'description': 'Corra 10km em uma semana',
          'imageUrl': 'assets/images/challenge_default.jpg',
        },
      ];
      
      // Lista de treinos para teste
      final workouts = [
        {
          'id': '1',
          'name': 'Treino HIIT',
          'duration': '30 min',
          'level': 'Intermediário',
          'imageUrl': 'assets/images/workout_default.jpg',
        },
        {
          'id': '2',
          'name': 'Yoga para Iniciantes',
          'duration': '45 min',
          'level': 'Iniciante',
          'imageUrl': 'assets/images/workout_default.jpg',
        },
      ];
      
      // Constrói o widget de teste simulando uma mini HomeScreen
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Desafios Ativos',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: challenges.length,
                        itemBuilder: (context, index) {
                          return ChallengeCard(challenge: challenges[index]);
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Sugestões para você',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workouts.length,
                      itemBuilder: (context, index) {
                        return WorkoutCard(workout: workouts[index]);
                      },
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  showRegisterExerciseSheet(
                    tester.element(find.byType(FloatingActionButton)),
                    challengeId: null,
                  );
                },
                label: const Text('Registrar treino'),
                icon: const Icon(Icons.add),
              ),
            ),
          ),
        ),
      );
      
      // Verifica se todos os componentes foram renderizados corretamente
      
      // Títulos das seções
      expect(find.text('Desafios Ativos'), findsOneWidget);
      expect(find.text('Sugestões para você'), findsOneWidget);
      
      // Cards de desafio
      expect(find.text('Desafio Semanal'), findsOneWidget);
      expect(find.text('Desafio de Corrida'), findsOneWidget);
      
      // Cards de treino
      expect(find.text('Treino HIIT'), findsOneWidget);
      expect(find.text('Yoga para Iniciantes'), findsOneWidget);
      
      // FAB
      expect(find.text('Registrar treino'), findsOneWidget);
      
      // Simula clicar no FAB para abrir o RegisterExerciseSheet
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Verifica se o RegisterExerciseSheet foi aberto
      expect(find.text('Registrar Treino'), findsOneWidget);
      expect(find.text('Tipo de Exercício'), findsOneWidget);
    });
    
    testWidgets('ChallengeCard e WorkoutCard respondem a onTap', (WidgetTester tester) async {
      int challengeTapCount = 0;
      int workoutTapCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ChallengeCard(
                  challenge: {'title': 'Desafio Teste', 'description': 'Descrição'},
                  onTap: () {
                    challengeTapCount++;
                  },
                ),
                WorkoutCard(
                  workout: {'name': 'Treino Teste', 'duration': '30 min', 'level': 'Iniciante'},
                  onTap: () {
                    workoutTapCount++;
                  },
                ),
              ],
            ),
          ),
        ),
      );
      
      // Testa o tap no ChallengeCard
      await tester.tap(find.text('Desafio Teste'));
      expect(challengeTapCount, 1);
      
      // Testa o tap no WorkoutCard
      await tester.tap(find.text('Treino Teste'));
      expect(workoutTapCount, 1);
    });
  });
} 
