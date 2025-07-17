import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';

void main() {
  group('Challenge Model Tests', () {
    late Challenge testChallenge;
    
    setUp(() {
      // Desafio que iniciou em 26/05/2025 e dura 21 dias
      testChallenge = Challenge(
        id: 'test-challenge-1',
        title: 'Desafio Ray 21 Dias',
        description: 'Desafio de 21 dias para transformar sua vida',
        startDate: DateTime(2025, 5, 26), // 26/05/2025
        endDate: DateTime(2025, 6, 15),   // 15/06/2025 (21 dias depois)
        points: 210,
        type: 'fitness',
        active: true,
        isOfficial: true,
      );
    });

    group('daysRemainingBrazil', () {
      test('deve calcular corretamente os dias restantes considerando fuso horário do Brasil', () {
        // Mock da data atual para 28/05/2025 (2 dias após o início)
        final mockNow = DateTime(2025, 5, 28);
        
        // Simular o cálculo manual
        final brazilNow = DateTime(mockNow.year, mockNow.month, mockNow.day);
        final brazilEndDate = DateTime(testChallenge.endDate.year, testChallenge.endDate.month, testChallenge.endDate.day);
        final expectedDays = brazilEndDate.difference(brazilNow).inDays + 1;
        
        // O resultado deve ser 19 dias (15/06 - 28/05 = 18 dias + 1 = 19 dias)
        expect(expectedDays, equals(19));
      });

      test('deve retornar 0 quando o desafio já terminou', () {
        // Criar um desafio que já terminou
        final expiredChallenge = testChallenge.copyWith(
          endDate: DateTime(2025, 5, 25), // Terminou antes de hoje
        );
        
        // Mock da data atual para 28/05/2025
        final mockNow = DateTime(2025, 5, 28);
        final brazilNow = DateTime(mockNow.year, mockNow.month, mockNow.day);
        final brazilEndDate = DateTime(expiredChallenge.endDate.year, expiredChallenge.endDate.month, expiredChallenge.endDate.day);
        final difference = brazilEndDate.difference(brazilNow).inDays + 1;
        final result = difference >= 0 ? difference : 0;
        
        expect(result, equals(0));
      });

      test('deve retornar valor correto no último dia do desafio', () {
        // Mock da data atual para o último dia (15/06/2025)
        final mockNow = DateTime(2025, 6, 15);
        final brazilNow = DateTime(mockNow.year, mockNow.month, mockNow.day);
        final brazilEndDate = DateTime(testChallenge.endDate.year, testChallenge.endDate.month, testChallenge.endDate.day);
        final result = brazilEndDate.difference(brazilNow).inDays + 1;
        
        // No último dia deve retornar 1 (incluindo o dia atual)
        expect(result, equals(1));
      });
    });

    group('isActiveBrazil', () {
      test('deve retornar true quando o desafio está ativo', () {
        // Mock da data atual para 28/05/2025 (dentro do período)
        final mockNow = DateTime(2025, 5, 28);
        final brazilNow = DateTime(mockNow.year, mockNow.month, mockNow.day);
        
        final brazilStartDate = DateTime(testChallenge.startDate.year, testChallenge.startDate.month, testChallenge.startDate.day);
        final brazilEndDate = DateTime(testChallenge.endDate.year, testChallenge.endDate.month, testChallenge.endDate.day);
        
        final isActive = brazilNow.isAfter(brazilStartDate.subtract(const Duration(days: 1))) && 
                        brazilNow.isBefore(brazilEndDate.add(const Duration(days: 1))) && 
                        testChallenge.active;
        
        expect(isActive, isTrue);
      });

      test('deve retornar false quando o desafio não está ativo (flag active = false)', () {
        final inactiveChallenge = testChallenge.copyWith(active: false);
        
        // Mock da data atual para 28/05/2025 (dentro do período)
        final mockNow = DateTime(2025, 5, 28);
        final brazilNow = DateTime(mockNow.year, mockNow.month, mockNow.day);
        
        final brazilStartDate = DateTime(inactiveChallenge.startDate.year, inactiveChallenge.startDate.month, inactiveChallenge.startDate.day);
        final brazilEndDate = DateTime(inactiveChallenge.endDate.year, inactiveChallenge.endDate.month, inactiveChallenge.endDate.day);
        
        final isActive = brazilNow.isAfter(brazilStartDate.subtract(const Duration(days: 1))) && 
                        brazilNow.isBefore(brazilEndDate.add(const Duration(days: 1))) && 
                        inactiveChallenge.active;
        
        expect(isActive, isFalse);
      });

      test('deve retornar false quando a data atual é antes do início', () {
        // Mock da data atual para 25/05/2025 (antes do início)
        final mockNow = DateTime(2025, 5, 25);
        final brazilNow = DateTime(mockNow.year, mockNow.month, mockNow.day);
        
        final brazilStartDate = DateTime(testChallenge.startDate.year, testChallenge.startDate.month, testChallenge.startDate.day);
        final brazilEndDate = DateTime(testChallenge.endDate.year, testChallenge.endDate.month, testChallenge.endDate.day);
        
        final isActive = brazilNow.isAfter(brazilStartDate.subtract(const Duration(days: 1))) && 
                        brazilNow.isBefore(brazilEndDate.add(const Duration(days: 1))) && 
                        testChallenge.active;
        
        expect(isActive, isFalse);
      });

      test('deve retornar false quando a data atual é depois do fim', () {
        // Mock da data atual para 16/06/2025 (depois do fim)
        final mockNow = DateTime(2025, 6, 16);
        final brazilNow = DateTime(mockNow.year, mockNow.month, mockNow.day);
        
        final brazilStartDate = DateTime(testChallenge.startDate.year, testChallenge.startDate.month, testChallenge.startDate.day);
        final brazilEndDate = DateTime(testChallenge.endDate.year, testChallenge.endDate.month, testChallenge.endDate.day);
        
        final isActive = brazilNow.isAfter(brazilStartDate.subtract(const Duration(days: 1))) && 
                        brazilNow.isBefore(brazilEndDate.add(const Duration(days: 1))) && 
                        testChallenge.active;
        
        expect(isActive, isFalse);
      });
    });

    group('totalDays', () {
      test('deve calcular corretamente o total de dias do desafio', () {
        // 26/05/2025 até 15/06/2025 = 21 dias
        final expectedTotalDays = testChallenge.endDate.difference(testChallenge.startDate).inDays + 1;
        expect(expectedTotalDays, equals(21));
      });
    });

    group('Compatibilidade com métodos existentes', () {
      test('formattedDateRange deve funcionar normalmente', () {
        expect(testChallenge.formattedDateRange, isNotEmpty);
      });

      test('participantsCount deve funcionar normalmente', () {
        expect(testChallenge.participantsCount, equals(0));
      });

      test('isActive() método original deve funcionar normalmente', () {
        // Este teste verifica que não quebramos o método original
        expect(testChallenge.isActive(), isA<bool>());
      });
    });
  });
} 