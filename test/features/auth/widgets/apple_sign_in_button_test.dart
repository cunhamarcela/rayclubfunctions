// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/features/auth/widgets/apple_sign_in_button.dart';

/// Testes para o widget AppleSignInButton
/// 
/// Verifica se o botão segue as diretrizes da Apple e funciona corretamente
void main() {
  group('AppleSignInButton', () {
    testWidgets('deve renderizar corretamente', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(AppleSignInButton), findsOneWidget);
      expect(find.text('Continuar com Apple'), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
    });

    testWidgets('deve executar callback quando pressionado', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );
      
      // Act
      await tester.tap(find.byType(AppleSignInButton));
      await tester.pump();
      
      // Assert
      expect(wasPressed, isTrue);
    });

    testWidgets('deve mostrar loading quando isLoading é true', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Continuar com Apple'), findsNothing);
    });

    testWidgets('deve estar desabilitado quando onPressed é null', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: null,
            ),
          ),
        ),
      );
      
      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('deve ter as cores corretas (preto com texto branco)', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButton(
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style!;
      
      // Verificar cor de fundo
      final backgroundColor = style.backgroundColor?.resolve({});
      expect(backgroundColor, equals(Colors.black));
      
      // Verificar cor do texto
      final foregroundColor = style.foregroundColor?.resolve({});
      expect(foregroundColor, equals(Colors.white));
    });
  });

  group('AppleSignInButtonLight', () {
    testWidgets('deve renderizar corretamente com estilo claro', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButtonLight(
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(AppleSignInButtonLight), findsOneWidget);
      expect(find.text('Continuar com Apple'), findsOneWidget);
      expect(find.byIcon(Icons.apple), findsOneWidget);
    });

    testWidgets('deve ter as cores corretas (branco com texto preto)', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButtonLight(
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
      final style = button.style!;
      
      // Verificar cor de fundo
      final backgroundColor = style.backgroundColor?.resolve({});
      expect(backgroundColor, equals(Colors.white));
      
      // Verificar cor do texto
      final foregroundColor = style.foregroundColor?.resolve({});
      expect(foregroundColor, equals(Colors.black));
    });

    testWidgets('deve executar callback quando pressionado', (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppleSignInButtonLight(
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );
      
      // Act
      await tester.tap(find.byType(AppleSignInButtonLight));
      await tester.pump();
      
      // Assert
      expect(wasPressed, isTrue);
    });
  });
} 