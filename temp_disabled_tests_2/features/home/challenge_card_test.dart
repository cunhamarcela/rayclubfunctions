// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/features/home/widgets/challenge/challenge_card.dart';

void main() {
  testWidgets('ChallengeCard renders correctly with mock data', (WidgetTester tester) async {
    final mockChallenge = {
      'id': '1',
      'title': 'Teste de Desafio',
      'description': 'Descrição do desafio de teste',
      'imageUrl': 'assets/images/challenge_default.jpg',
    };

    bool tapCalled = false;

    // Constrói o widget de teste
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChallengeCard(
            challenge: mockChallenge,
            onTap: () {
              tapCalled = true;
            },
          ),
        ),
      ),
    );

    // Verifica se o título e a descrição estão presentes
    expect(find.text('Teste de Desafio'), findsOneWidget);
    expect(find.text('Descrição do desafio de teste'), findsOneWidget);

    // Verifica se o ícone está presente
    expect(find.byIcon(Icons.emoji_events), findsOneWidget);

    // Testa o callback de toque
    await tester.tap(find.byType(GestureDetector));
    expect(tapCalled, true);
  });

  testWidgets('ChallengeCard uses fallback values when data is null', (WidgetTester tester) async {
    // Constrói o widget de teste com dados nulos
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChallengeCard(
            challenge: null,
          ),
        ),
      ),
    );

    // Verifica se os valores padrão estão sendo usados
    expect(find.text('Challenge'), findsOneWidget);
    expect(find.text('Join this exciting challenge now!'), findsOneWidget);
  });
} 
