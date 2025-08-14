import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/benefits/widgets/benefits_pdf_viewer.dart';
import 'package:ray_club_app/features/subscription/providers/subscription_providers.dart';

/// Testes básicos para o BenefitsPdfViewer
/// 
/// Data: 2025-01-21 às 23:55
/// Contexto: Validar funcionamento do visualizador PDF exclusivo para EXPERT

void main() {
  group('BenefitsPdfViewer Tests', () {
    
    testWidgets('deve mostrar tela de evolução para usuário não-EXPERT', (WidgetTester tester) async {
      // Arrange - Mock para usuário básico (não EXPERT)
      final container = ProviderContainer(
        overrides: [
          featureAccessProvider('detailed_reports').overrideWith(
            (ref) => const AsyncValue.data(false), // Usuário não tem acesso
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BenefitsPdfViewer(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Continue Evoluindo! ✨'), findsOneWidget);
      expect(find.text('Continue Evoluindo'), findsOneWidget);
      expect(find.byIcon(Icons.star_outline), findsOneWidget);
      expect(find.text('Esta área especial com benefícios exclusivos será desbloqueada conforme você progride no seu desenvolvimento.'), findsOneWidget);
    });

    testWidgets('deve mostrar carregamento durante verificação de acesso', (WidgetTester tester) async {
      // Arrange - Mock para carregamento
      final container = ProviderContainer(
        overrides: [
          featureAccessProvider('detailed_reports').overrideWith(
            (ref) => const AsyncValue.loading(),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BenefitsPdfViewer(),
          ),
        ),
      );

      // Assert
      expect(find.text('Verificando acesso...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('deve mostrar tela de evolução em caso de erro', (WidgetTester tester) async {
      // Arrange - Mock para erro
      final container = ProviderContainer(
        overrides: [
          featureAccessProvider('detailed_reports').overrideWith(
            (ref) => AsyncValue.error('Erro de conexão', StackTrace.empty),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BenefitsPdfViewer(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Continue Evoluindo! ✨'), findsOneWidget);
      expect(find.byIcon(Icons.star_outline), findsOneWidget);
    });

    testWidgets('deve tentar carregar PDF para usuário EXPERT', (WidgetTester tester) async {
      // Arrange - Mock para usuário EXPERT
      final container = ProviderContainer(
        overrides: [
          featureAccessProvider('detailed_reports').overrideWith(
            (ref) => const AsyncValue.data(true), // Usuário EXPERT tem acesso
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BenefitsPdfViewer(),
          ),
        ),
      );
      await tester.pump();

      // Assert - Deve mostrar a estrutura do visualizador PDF
      expect(find.text('Benefícios Exclusivos ✨'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      
      // Deve mostrar carregamento inicial
      expect(find.text('Carregando PDF de benefícios...'), findsOneWidget);
    });

    testWidgets('deve mostrar AppBar correta para tela de negação', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          featureAccessProvider('detailed_reports').overrideWith(
            (ref) => const AsyncValue.data(false),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BenefitsPdfViewer(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Benefícios'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('deve mostrar AppBar correta para visualizador PDF', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          featureAccessProvider('detailed_reports').overrideWith(
            (ref) => const AsyncValue.data(true),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BenefitsPdfViewer(),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Benefícios Exclusivos ✨'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('botão voltar deve funcionar na tela de evolução', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer(
        overrides: [
          featureAccessProvider('detailed_reports').overrideWith(
            (ref) => const AsyncValue.data(false),
          ),
        ],
      );

      bool didPop = false;
      
      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Navigator(
              onPopPage: (route, result) {
                didPop = true;
                return false;
              },
              pages: const [
                MaterialPage(child: BenefitsPdfViewer()),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Toque no botão "Continue Evoluindo"
      await tester.tap(find.text('Continue Evoluindo'));
      await tester.pumpAndSettle();

      // Assert
      expect(didPop, isTrue);
    });
  });

  group('BenefitsPdfViewer Integration', () {
    
    testWidgets('deve usar feature key correto para verificação', (WidgetTester tester) async {
      // Arrange
      String? capturedFeatureKey;
      
      final container = ProviderContainer(
        overrides: [
          featureAccessProvider.overrideWithProvider(
            (featureKey) => Provider((ref) {
              capturedFeatureKey = featureKey;
              return const AsyncValue.data(false);
            }),
          ),
        ],
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: BenefitsPdfViewer(),
          ),
        ),
      );

      // Assert
      expect(capturedFeatureKey, equals('detailed_reports'));
    });
  });
} 