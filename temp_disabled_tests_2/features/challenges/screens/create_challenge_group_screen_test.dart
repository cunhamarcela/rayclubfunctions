// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:ray_club_app/features/challenges/screens/create_challenge_group_screen.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_group_view_model.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/widgets/ray_button.dart';

import 'create_challenge_group_screen_test.mocks.dart';

@GenerateMocks([ChallengeGroupViewModel])
void main() {
  late MockChallengeGroupViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockChallengeGroupViewModel();
  });

  final mockProvider = StateNotifierProvider<ChallengeGroupViewModel, ChallengeGroupState>(
    (ref) => mockViewModel,
  );

  testWidgets('CreateChallengeGroupScreen renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeGroupViewModelProvider.overrideWith((_) => mockViewModel),
        ],
        child: MaterialApp(
          home: const CreateChallengeGroupScreen(),
        ),
      ),
    );

    // Verify that the title is displayed
    expect(find.text('Criar Novo Grupo'), findsOneWidget);
    
    // Verify that the input fields are displayed
    expect(find.widgetWithText(TextFormField, 'Nome do grupo'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Descrição'), findsOneWidget);
    
    // Verify that the create button is displayed
    expect(find.widgetWithText(RayButton, 'Criar Grupo'), findsOneWidget);
    
    // Verify that the icon is displayed
    expect(find.byIcon(Icons.group_add), findsOneWidget);
  });

  testWidgets('Empty name field shows validation error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeGroupViewModelProvider.overrideWith((_) => mockViewModel),
        ],
        child: MaterialApp(
          home: const CreateChallengeGroupScreen(),
        ),
      ),
    );

    // Tap the create button without filling any fields
    await tester.tap(find.widgetWithText(RayButton, 'Criar Grupo'));
    await tester.pump();

    // Verify that validation error is shown
    expect(find.text('O nome do grupo é obrigatório'), findsOneWidget);
  });

  testWidgets('Form submission calls createGroup method on ViewModel', (WidgetTester tester) async {
    // Setup mock response
    when(mockViewModel.createGroup(name: 'Test Group', description: 'Test Description'))
        .thenAnswer((_) async => true);

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          challengeGroupViewModelProvider.overrideWith((_) => mockViewModel),
        ],
        child: MaterialApp(
          home: const CreateChallengeGroupScreen(),
        ),
      ),
    );

    // Enter text in the name field
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome do grupo'), 
      'Test Group'
    );
    
    // Enter text in the description field
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descrição'), 
      'Test Description'
    );
    
    // Tap the create button
    await tester.tap(find.widgetWithText(RayButton, 'Criar Grupo'));
    await tester.pump();

    // Verify that createGroup was called with correct parameters
    verify(mockViewModel.createGroup(
      name: 'Test Group',
      description: 'Test Description',
    )).called(1);
  });
} 