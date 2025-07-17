import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/benefits/screens/cupons_screen.dart';

void main() {
  group('CuponsScreen', () {
    Widget createApp() {
      return ProviderScope(
        child: MaterialApp(
          home: const CuponsScreen(),
        ),
      );
    }

    testWidgets('deve exibir o título da tela', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      
      expect(find.text('Cupons de Desconto'), findsOneWidget);
    });



    testWidgets('deve exibir lista de cupons', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      
      // Verifica se alguns cupons específicos estão sendo exibidos
      expect(find.text('Super Coffee | Sublyme | Koala'), findsOneWidget);
      expect(find.text('Haoma'), findsOneWidget);
      expect(find.text('rayricardo'), findsOneWidget);
      expect(find.text('Ray'), findsWidgets);
    });

    testWidgets('deve exibir botões de copiar para cada cupom', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      
      // Verifica se os ícones de copiar estão presentes
      expect(find.byIcon(Icons.copy), findsWidgets);
    });



    testWidgets('deve exibir ícones de loja para cada cupom', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      
      // Verifica se os ícones de loja estão presentes
      expect(find.byIcon(Icons.store), findsWidgets);
    });

    testWidgets('deve ter botão de voltar', (WidgetTester tester) async {
      await tester.pumpWidget(createApp());
      
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });
  });
} 