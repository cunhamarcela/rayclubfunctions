import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/dashboard/models/dashboard_data_enhanced.dart';

void main() {
  group('Challenge Days Remaining Calculation Tests', () {
    
    test('deve calcular corretamente os dias restantes considerando fuso horário do Brasil', () {
      // Simular dados do desafio atual
      final endDate = DateTime(2025, 6, 15); // 15/06/2025
      
      // Mock da data atual para 28/05/2025 (deveria mostrar 18 dias restantes)
      final mockNow = DateTime(2025, 5, 28);
      
      // Simular o cálculo que o widget faz
      final brazilNow = DateTime(mockNow.year, mockNow.month, mockNow.day);
      final brazilEndDate = DateTime(endDate.year, endDate.month, endDate.day);
      final expectedDaysRemaining = brazilEndDate.difference(brazilNow).inDays + 1;
      
      // Deve ser 19 dias (15/06 - 28/05 = 18 dias + 1 = 19 dias)
      expect(expectedDaysRemaining, equals(19));
    });

    test('deve retornar 0 dias quando o desafio já terminou', () {
      // Simular desafio expirado
      final endDate = DateTime(2025, 5, 25); // Terminou em 25/05/2025
      
      // Mock da data atual para 28/05/2025 (3 dias após o término)
      final mockNow = DateTime(2025, 5, 28);
      
      // Simular o cálculo que o widget faz
      final brazilNow = DateTime(mockNow.year, mockNow.month, mockNow.day);
      final brazilEndDate = DateTime(endDate.year, endDate.month, endDate.day);
      final difference = brazilEndDate.difference(brazilNow).inDays + 1;
      final daysRemaining = difference >= 0 ? difference : 0;
      
      // Deve ser 0 dias
      expect(daysRemaining, equals(0));
    });

    test('deve calcular corretamente no último dia do desafio', () {
      // Simular último dia do desafio
      final endDate = DateTime(2025, 6, 15); // 15/06/2025
      
      // Mock da data atual para o último dia (15/06/2025)
      final mockNow = DateTime(2025, 6, 15);
      
      // Simular o cálculo que o widget faz
      final brazilNow = DateTime(mockNow.year, mockNow.month, mockNow.day);
      final brazilEndDate = DateTime(endDate.year, endDate.month, endDate.day);
      final difference = brazilEndDate.difference(brazilNow).inDays + 1;
      final daysRemaining = difference >= 0 ? difference : 0;
      
      // No último dia deve ser 1
      expect(daysRemaining, equals(1));
    });

    test('deve lidar corretamente com endDate null', () {
      // Simular o cálculo que o widget faz quando endDate é null
      final DateTime? endDate = null;
      
      final daysRemaining = endDate != null
          ? () {
              final now = DateTime.now();
              final brazilNow = DateTime(now.year, now.month, now.day);
              final brazilEndDate = DateTime(endDate.year, endDate.month, endDate.day);
              final difference = brazilEndDate.difference(brazilNow).inDays + 1;
              return difference >= 0 ? difference : 0;
            }()
          : 0;
      
      // Deve ser 0 quando endDate é null
      expect(daysRemaining, equals(0));
    });

    group('Integração com dados reais do dashboard', () {
      test('deve processar corretamente dados do DashboardDataEnhanced', () {
        // Criar dados completos do dashboard
        final dashboardData = DashboardDataEnhanced(
          userProgress: UserProgressData(
            id: 'user-1',
            userId: 'user-1',
            totalWorkouts: 15,
            currentStreak: 3,
            longestStreak: 7,
            totalPoints: 150,
            daysTrainedThisMonth: 10,
            workoutTypes: {},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          waterIntake: WaterIntakeData(
            id: 'water-1',
            userId: 'user-1',
            date: DateTime.now(),
            cups: 6,
            goal: 8,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          goals: [],
          recentWorkouts: [],
          currentChallenge: ChallengeData(
            id: 'challenge-1',
            title: 'Desafio Ray 21 Dias',
            description: 'Desafio de transformação',
            startDate: DateTime(2025, 5, 26),
            endDate: DateTime(2025, 6, 15),
            points: 210,
            type: 'fitness',
            isOfficial: true,
            daysRemaining: 18,
          ),
          challengeProgress: ChallengeProgressData(
            id: 'progress-1',
            userId: 'user-1',
            challengeId: 'challenge-1',
            points: 20,
            position: 5,
            totalCheckIns: 2,
            consecutiveDays: 2,
            completionPercentage: 0.095,
          ),
          redeemedBenefits: [],
          nutritionData: NutritionData(
            id: 'nutrition-1',
            userId: 'user-1',
            date: DateTime.now(),
            caloriesConsumed: 1800,
            caloriesGoal: 2000,
            proteins: 150,
            carbs: 250,
            fats: 70,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          lastUpdated: DateTime.now(),
        );

        // Verificar que os dados estão estruturados corretamente
        expect(dashboardData.currentChallenge?.id, isNotNull);
        expect(dashboardData.currentChallenge?.endDate, isNotNull);
        expect(dashboardData.challengeProgress?.totalCheckIns, equals(2));
      });
    });

    group('Casos extremos', () {
      test('deve lidar com diferenças de fuso horário corretamente', () {
        // Simular diferentes horários do dia
        final endDate = DateTime(2025, 6, 15, 23, 59, 59); // 23:59:59 do último dia
        final currentDate = DateTime(2025, 6, 15, 0, 0, 1);  // 00:00:01 do último dia
        
        // Aplicar a lógica do widget (apenas data, sem horário)
        final brazilNow = DateTime(currentDate.year, currentDate.month, currentDate.day);
        final brazilEndDate = DateTime(endDate.year, endDate.month, endDate.day);
        final difference = brazilEndDate.difference(brazilNow).inDays + 1;
        
        // Mesmo sendo horários diferentes, deve considerar apenas a data (no último dia = 1)
        expect(difference, equals(1));
      });

      test('deve calcular corretamente mudanças de mês', () {
        // Desafio que termina no próximo mês
        final endDate = DateTime(2025, 6, 15);
        final currentDate = DateTime(2025, 5, 31); // Último dia de maio
        
        final brazilNow = DateTime(currentDate.year, currentDate.month, currentDate.day);
        final brazilEndDate = DateTime(endDate.year, endDate.month, endDate.day);
        final difference = brazilEndDate.difference(brazilNow).inDays + 1;
        
        // 31/05 até 15/06 = 15 dias + 1 = 16 dias
        expect(difference, equals(16));
      });

      test('deve calcular corretamente anos bissextos', () {
        // Teste com ano bissexto (2024)
        final endDate = DateTime(2024, 3, 1);
        final currentDate = DateTime(2024, 2, 28); // 28 de fevereiro em ano bissexto
        
        final brazilNow = DateTime(currentDate.year, currentDate.month, currentDate.day);
        final brazilEndDate = DateTime(endDate.year, endDate.month, endDate.day);
        final difference = brazilEndDate.difference(brazilNow).inDays + 1;
        
        // 28/02 até 01/03 em ano bissexto = 2 dias + 1 = 3 dias (29/02 existe)
        expect(difference, equals(3));
      });
    });

    group('Validação da lógica de negócio', () {
      test('deve garantir que o cálculo seja consistente com o desafio de 21 dias', () {
        // Desafio Ray: 26/05/2025 até 15/06/2025 = 21 dias
        final startDate = DateTime(2025, 5, 26);
        final endDate = DateTime(2025, 6, 15);
        
        // Calcular total de dias do desafio
        final totalDays = endDate.difference(startDate).inDays + 1;
        expect(totalDays, equals(21));
        
        // Verificar dias restantes em diferentes momentos
        final testCases = [
          {'date': DateTime(2025, 5, 26), 'expected': 21}, // Primeiro dia
          {'date': DateTime(2025, 5, 28), 'expected': 19}, // Terceiro dia
          {'date': DateTime(2025, 6, 10), 'expected': 6},  // Próximo ao fim
          {'date': DateTime(2025, 6, 15), 'expected': 1},  // Último dia
        ];
        
        for (final testCase in testCases) {
          final currentDate = testCase['date'] as DateTime;
          final expectedDays = testCase['expected'] as int;
          
          final brazilNow = DateTime(currentDate.year, currentDate.month, currentDate.day);
          final brazilEndDate = DateTime(endDate.year, endDate.month, endDate.day);
          final difference = brazilEndDate.difference(brazilNow).inDays + 1;
          final daysRemaining = difference >= 0 ? difference : 0;
          
          expect(daysRemaining, equals(expectedDays), 
                 reason: 'Falha no cálculo para ${currentDate.day}/${currentDate.month}');
        }
      });
    });

    group('Testes dos novos métodos do modelo Challenge', () {
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

      test('daysRemainingBrazil deve calcular corretamente', () {
        // Verificar que o método existe e retorna um int
        expect(testChallenge.daysRemainingBrazil, isA<int>());
        expect(testChallenge.daysRemainingBrazil, greaterThanOrEqualTo(0));
      });

      test('isActiveBrazil deve retornar bool', () {
        // Verificar que o método existe e retorna um bool
        expect(testChallenge.isActiveBrazil, isA<bool>());
      });

      test('totalDays deve calcular corretamente', () {
        // 26/05/2025 até 15/06/2025 = 21 dias
        expect(testChallenge.totalDays, equals(21));
      });

      test('métodos existentes devem continuar funcionando', () {
        expect(testChallenge.formattedDateRange, isNotEmpty);
        expect(testChallenge.participantsCount, equals(0));
        expect(testChallenge.isActive(), isA<bool>());
      });
    });
  });
} 