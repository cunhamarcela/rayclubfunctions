// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/features/home/widgets/register_exercise_sheet.dart';

void main() {
  testWidgets('RegisterExerciseSheet renders correctly', (WidgetTester tester) async {
    // Constrói o widget de teste
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RegisterExerciseSheet(),
          ),
        ),
      ),
    );

    // Verifica se os títulos estão presentes
    expect(find.text('Registrar Treino'), findsOneWidget);
    expect(find.text('Tipo de Exercício'), findsOneWidget);
    expect(find.text('Duração (minutos)'), findsOneWidget);
    expect(find.text('Calorias Queimadas'), findsOneWidget);

    // Verifica se os exercícios estão presentes
    expect(find.text('Caminhada'), findsOneWidget);
    expect(find.text('Corrida'), findsOneWidget);
    expect(find.text('Yoga'), findsOneWidget);

    // Verifica se o botão de salvar está presente
    expect(find.text('Salvar Exercício'), findsOneWidget);
    
    // Verifica se há apenas 1 slider (intensidade) e 1 campo de texto (duração)
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(TextFormField), findsAtLeastNWidgets(1));
  });

  testWidgets('RegisterExerciseSheet selects an exercise', (WidgetTester tester) async {
    // Constrói o widget de teste
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RegisterExerciseSheet(),
          ),
        ),
      ),
    );

    // Clica no exercício "Yoga"
    await tester.tap(find.text('Yoga'));
    await tester.pump();

    // Verifica se o botão de salvar funciona quando um exercício é selecionado
    await tester.tap(find.text('Salvar Exercício'));
    await tester.pump();

    // Não mostra SnackBar de erro (porque um exercício foi selecionado)
    expect(find.text('Por favor, selecione um tipo de exercício'), findsNothing);
  });

  testWidgets('RegisterExerciseSheet shows error when no exercise selected', (WidgetTester tester) async {
    // Constrói o widget de teste
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: RegisterExerciseSheet(),
          ),
        ),
      ),
    );

    // Clica no botão de salvar sem selecionar um exercício
    await tester.tap(find.text('Salvar Exercício'));
    await tester.pumpAndSettle();

    // Verifica se o SnackBar de erro é exibido
    expect(find.text('Por favor, selecione um tipo de exercício'), findsOneWidget);
  });
} 
