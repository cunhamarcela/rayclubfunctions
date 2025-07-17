import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/workout/screens/workout_videos_screen.dart';

void main() {
  group('WorkoutVideosScreen', () {
    testWidgets('deve exibir loading inicialmente', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutVideosScreen(
              categoryId: 'bodybuilding',
              categoryName: 'Musculação',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve exibir título da categoria', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutVideosScreen(
              categoryId: 'pilates',
              categoryName: 'Pilates',
            ),
          ),
        ),
      );

      expect(find.text('Pilates'), findsOneWidget);
    });

    testWidgets('deve usar nome padrão quando categoryName é null', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: WorkoutVideosScreen(
              categoryId: 'functional',
            ),
          ),
        ),
      );

      expect(find.text('Funcional'), findsOneWidget);
    });
  });
} 