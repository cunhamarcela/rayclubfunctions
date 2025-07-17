import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:uuid/uuid.dart';

import '../view_model/robust_workout_record_view_model.dart';
import '../models/workout_record.dart';
import '../repositories/workout_record_repository.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../../../features/challenges/repositories/challenge_repository.dart';
import '../../../features/dashboard/repositories/dashboard_repository.dart';

// Mocks gerados
class MockWorkoutRecordRepository extends Mock implements WorkoutRecordRepository {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockChallengeRepository extends Mock implements ChallengeRepository {}
class MockDashboardRepository extends Mock implements DashboardRepository {}

/// Suite completa de testes para o sistema robusto de workout
/// 
/// Testa todas as proteções implementadas:
/// - Rate limiting
/// - Detecção de duplicatas
/// - Validações de dados
/// - Tratamento de erros
/// - Recuperação automática
void main() {
  group('🛡️ Robust Workout System Tests', () {
    late MockWorkoutRecordRepository mockWorkoutRepo;
    late MockAuthRepository mockAuthRepo;
    late MockChallengeRepository mockChallengeRepo;
    late MockDashboardRepository mockDashboardRepo;
    late RobustWorkoutRecordViewModel viewModel;
    late ProviderContainer container;

    const testUserId = 'test-user-id';
    const testChallengeId = 'test-challenge-id';

    setUp(() {
      mockWorkoutRepo = MockWorkoutRecordRepository();
      mockAuthRepo = MockAuthRepository();
      mockChallengeRepo = MockChallengeRepository();
      mockDashboardRepo = MockDashboardRepository();

      // Setup básico dos mocks
      when(mockAuthRepo.currentUser).thenReturn(
        MockUser(id: testUserId, email: 'test@test.com'),
      );

      container = ProviderContainer(
        overrides: [
          // Override dos providers com mocks
        ],
      );

      viewModel = RobustWorkoutRecordViewModel(
        workoutRecordRepository: mockWorkoutRepo,
        authRepository: mockAuthRepo,
        challengeRepository: mockChallengeRepo,
        dashboardRepository: mockDashboardRepo,
      );
    });

    tearDown(() {
      viewModel.dispose();
      container.dispose();
    });

    group('🚫 Rate Limiting Protection', () {
      test('deve bloquear submissões muito frequentes', () async {
        // Arrange
        final params = RobustWorkoutParams(
          workoutName: 'Teste Treino',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime.now(),
          challengeId: testChallengeId,
        );

        when(mockWorkoutRepo.saveWorkoutRecord(any)).thenAnswer(
          (_) async => {'success': true, 'workout_id': 'test-id'},
        );

        // Act - primeira submissão
        await viewModel.recordWorkout(params);
        expect(viewModel.state.isSuccess, isTrue);
        expect(viewModel.state.consecutiveErrors, equals(0));

        // Act - submissão imediata (deve ser bloqueada)
        await viewModel.recordWorkout(params);

        // Assert
        expect(viewModel.state.isRateLimited, isFalse); // Primeira não deve ativar rate limit
        
        // Simular submissão muito rápida
        viewModel.state = viewModel.state.copyWith(
          submissionHistory: {params.fingerprint: DateTime.now()},
        );

        await viewModel.recordWorkout(params);
        
        // Verificar que rate limit foi ativado através do stream de erro
        String? errorMessage;
        viewModel.workoutError.listen((error) {
          errorMessage = error;
        });

        await Future.delayed(Duration(milliseconds: 100));
        expect(errorMessage, contains('Aguarde'));
      });

      test('deve permitir submissão após período de cooldown', () async {
        // Arrange
        final params = RobustWorkoutParams(
          workoutName: 'Teste Treino',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime.now(),
        );

        when(mockWorkoutRepo.saveWorkoutRecord(any)).thenAnswer(
          (_) async => {'success': true, 'workout_id': 'test-id'},
        );

        // Simular submissão antiga (passado)
        final oldSubmissionTime = DateTime.now().subtract(Duration(minutes: 1));
        viewModel.state = viewModel.state.copyWith(
          submissionHistory: {params.fingerprint: oldSubmissionTime},
        );

        // Act
        await viewModel.recordWorkout(params);

        // Assert
        expect(viewModel.state.isSuccess, isTrue);
      });
    });

    group('🔄 Duplicate Detection', () {
      test('deve detectar tentativas de submissão simultâneas', () async {
        // Arrange
        final params = RobustWorkoutParams(
          workoutName: 'Teste Simultaneo',
          workoutType: 'Cardio',
          durationMinutes: 30,
          date: DateTime.now(),
        );

        when(mockWorkoutRepo.saveWorkoutRecord(any)).thenAnswer(
          (_) async {
            await Future.delayed(Duration(milliseconds: 500)); // Simular delay
            return {'success': true, 'workout_id': 'test-id'};
          },
        );

        // Act - duas submissões simultâneas
        final future1 = viewModel.recordWorkout(params);
        final future2 = viewModel.recordWorkout(params); // Deve ser ignorada

        await Future.wait([future1, future2]);

        // Assert
        verify(mockWorkoutRepo.saveWorkoutRecord(any)).called(1); // Apenas uma chamada
      });

      test('deve identificar treinos duplicados por fingerprint', () {
        // Arrange
        final params1 = RobustWorkoutParams(
          workoutName: 'Treino A',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime(2024, 1, 15),
          challengeId: testChallengeId,
        );

        final params2 = RobustWorkoutParams(
          workoutName: 'Treino A',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime(2024, 1, 15),
          challengeId: testChallengeId,
        );

        // Assert
        expect(params1.fingerprint, equals(params2.fingerprint));
      });

      test('deve gerar fingerprints diferentes para treinos distintos', () {
        // Arrange
        final params1 = RobustWorkoutParams(
          workoutName: 'Treino A',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime(2024, 1, 15),
        );

        final params2 = RobustWorkoutParams(
          workoutName: 'Treino B',
          workoutType: 'Cardio',
          durationMinutes: 30,
          date: DateTime(2024, 1, 16),
        );

        // Assert
        expect(params1.fingerprint, isNot(equals(params2.fingerprint)));
      });
    });

    group('✅ Data Validation', () {
      test('deve rejeitar dados inválidos', () async {
        // Arrange - dados inválidos
        final invalidParams = [
          RobustWorkoutParams(
            workoutName: '',
            workoutType: 'Musculação',
            durationMinutes: 60,
            date: DateTime.now(),
          ),
          RobustWorkoutParams(
            workoutName: 'Treino',
            workoutType: '',
            durationMinutes: 60,
            date: DateTime.now(),
          ),
          RobustWorkoutParams(
            workoutName: 'Treino',
            workoutType: 'Musculação',
            durationMinutes: 0,
            date: DateTime.now(),
          ),
          RobustWorkoutParams(
            workoutName: 'Treino',
            workoutType: 'Musculação',
            durationMinutes: 800, // Mais de 12h
            date: DateTime.now(),
          ),
          RobustWorkoutParams(
            workoutName: 'Treino',
            workoutType: 'Musculação',
            durationMinutes: 60,
            date: DateTime.now().subtract(Duration(days: 40)), // Muito antigo
          ),
          RobustWorkoutParams(
            workoutName: 'Treino',
            workoutType: 'Musculação',
            durationMinutes: 60,
            date: DateTime.now().add(Duration(days: 2)), // Futuro
          ),
        ];

        // Act & Assert
        for (final params in invalidParams) {
          await viewModel.recordWorkout(params);
          expect(viewModel.state.validationErrors.isNotEmpty, isTrue,
              reason: 'Deve ter erros de validação para: ${params.toJson()}');
          viewModel.clearErrors(); // Limpar para próximo teste
        }
      });

      test('deve aceitar dados válidos', () async {
        // Arrange
        final validParams = RobustWorkoutParams(
          workoutName: 'Treino Válido',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime.now().subtract(Duration(hours: 2)),
        );

        when(mockWorkoutRepo.saveWorkoutRecord(any)).thenAnswer(
          (_) async => {'success': true, 'workout_id': 'test-id'},
        );

        // Act
        await viewModel.recordWorkout(validParams);

        // Assert
        expect(viewModel.state.validationErrors.isEmpty, isTrue);
        expect(viewModel.state.isSuccess, isTrue);
      });
    });

    group('🔄 Error Handling & Recovery', () {
      test('deve contar erros consecutivos', () async {
        // Arrange
        final params = RobustWorkoutParams(
          workoutName: 'Treino Erro',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime.now(),
        );

        when(mockWorkoutRepo.saveWorkoutRecord(any))
            .thenThrow(Exception('Erro simulado'));

        // Act - múltiplos erros
        for (int i = 0; i < 3; i++) {
          await viewModel.recordWorkout(params);
          expect(viewModel.state.consecutiveErrors, equals(i + 1));
        }

        // Assert - deve ativar rate limit após 3 erros
        expect(viewModel.state.consecutiveErrors, equals(3));
        
        // Próxima tentativa deve ser bloqueada
        await viewModel.recordWorkout(params);
        expect(viewModel.state.isRateLimited, isTrue);
      });

      test('deve resetar contador de erros após sucesso', () async {
        // Arrange
        final params = RobustWorkoutParams(
          workoutName: 'Treino Recuperação',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime.now(),
        );

        // Simular estado com erros
        viewModel.state = viewModel.state.copyWith(consecutiveErrors: 2);

        when(mockWorkoutRepo.saveWorkoutRecord(any)).thenAnswer(
          (_) async => {'success': true, 'workout_id': 'test-id'},
        );

        // Act
        await viewModel.recordWorkout(params);

        // Assert
        expect(viewModel.state.consecutiveErrors, equals(0));
        expect(viewModel.state.isSuccess, isTrue);
      });

      test('deve implementar retry automático', () async {
        // Arrange
        final params = RobustWorkoutParams(
          workoutName: 'Treino Retry',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime.now(),
        );

        // Configurar mock para falhar 2 vezes, depois sucesso
        var callCount = 0;
        when(mockWorkoutRepo.saveWorkoutRecord(any)).thenAnswer((_) async {
          callCount++;
          if (callCount <= 2) {
            throw Exception('Erro temporário');
          }
          return {'success': true, 'workout_id': 'test-id'};
        });

        // Act
        await viewModel.recordWorkout(params);

        // Assert
        expect(callCount, equals(3)); // 2 falhas + 1 sucesso
        expect(viewModel.state.isSuccess, isTrue);
      });
    });

    group('📊 State Management', () {
      test('deve gerenciar estados corretamente durante submissão', () async {
        // Arrange
        final params = RobustWorkoutParams(
          workoutName: 'Teste Estado',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime.now(),
        );

        when(mockWorkoutRepo.saveWorkoutRecord(any)).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return {'success': true, 'workout_id': 'test-id'};
        });

        // Estados esperados
        final stateChanges = <bool>[];
        
        // Escutar mudanças de estado
        final subscription = viewModel.addListener((state) {
          stateChanges.add(state.isSubmitting);
        });

        // Act
        final future = viewModel.recordWorkout(params);
        
        // Verificar que está enviando
        expect(viewModel.state.isSubmitting, isTrue);
        
        await future;
        
        // Assert
        expect(viewModel.state.isSubmitting, isFalse);
        expect(viewModel.state.isSuccess, isTrue);
      });

      test('deve manter histórico de submissões', () async {
        // Arrange
        final params1 = RobustWorkoutParams(
          workoutName: 'Treino 1',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime.now(),
        );

        final params2 = RobustWorkoutParams(
          workoutName: 'Treino 2',
          workoutType: 'Cardio',
          durationMinutes: 30,
          date: DateTime.now(),
        );

        when(mockWorkoutRepo.saveWorkoutRecord(any)).thenAnswer(
          (_) async => {'success': true, 'workout_id': 'test-id'},
        );

        // Act
        await viewModel.recordWorkout(params1);
        await viewModel.recordWorkout(params2);

        // Assert
        expect(viewModel.state.submissionHistory.length, equals(2));
        expect(viewModel.state.submissionHistory.containsKey(params1.fingerprint), isTrue);
        expect(viewModel.state.submissionHistory.containsKey(params2.fingerprint), isTrue);
      });
    });

    group('🎛️ Control Methods', () {
      test('clearErrors deve limpar todos os erros', () {
        // Arrange
        viewModel.state = viewModel.state.copyWith(
          error: 'Erro teste',
          validationErrors: {'field': 'erro'},
          consecutiveErrors: 2,
          isRateLimited: true,
        );

        // Act
        viewModel.clearErrors();

        // Assert
        expect(viewModel.state.error, isNull);
        expect(viewModel.state.validationErrors.isEmpty, isTrue);
        expect(viewModel.state.consecutiveErrors, equals(0));
        expect(viewModel.state.isRateLimited, isFalse);
      });

      test('resetSubmissionHistory deve limpar histórico', () {
        // Arrange
        viewModel.state = viewModel.state.copyWith(
          submissionHistory: {'key1': DateTime.now(), 'key2': DateTime.now()},
        );

        // Act
        viewModel.resetSubmissionHistory();

        // Assert
        expect(viewModel.state.submissionHistory.isEmpty, isTrue);
      });

      test('getDiagnosticInfo deve retornar informações úteis', () {
        // Act
        final diagnosticInfo = viewModel.getDiagnosticInfo();

        // Assert
        expect(diagnosticInfo.containsKey('state'), isTrue);
        expect(diagnosticInfo.containsKey('controls'), isTrue);
        expect(diagnosticInfo['state']['isSubmitting'], equals(false));
        expect(diagnosticInfo['controls'], isA<Map>());
      });
    });

    group('🔗 Stream Integration', () {
      test('deve emitir eventos corretos nos streams', () async {
        // Arrange
        final params = RobustWorkoutParams(
          workoutName: 'Treino Stream',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime.now(),
        );

        when(mockWorkoutRepo.saveWorkoutRecord(any)).thenAnswer(
          (_) async => {'success': true, 'workout_id': 'test-id'},
        );

        bool workoutCompleted = false;
        String? workoutError;

        viewModel.workoutCompleted.listen((completed) {
          workoutCompleted = completed;
        });

        viewModel.workoutError.listen((error) {
          workoutError = error;
        });

        // Act
        await viewModel.recordWorkout(params);

        // Assert
        expect(workoutCompleted, isTrue);
        expect(workoutError, isNull);
      });

      test('deve emitir erros de validação no stream', () async {
        // Arrange
        final invalidParams = RobustWorkoutParams(
          workoutName: '',
          workoutType: 'Musculação',
          durationMinutes: 60,
          date: DateTime.now(),
        );

        Map<String, String>? validationErrors;
        viewModel.validationErrors.listen((errors) {
          validationErrors = errors;
        });

        // Act
        await viewModel.recordWorkout(invalidParams);

        // Assert
        expect(validationErrors, isNotNull);
        expect(validationErrors!.isNotEmpty, isTrue);
      });
    });
  });
}

// Mock classes auxiliares
class MockUser {
  final String id;
  final String email;
  
  MockUser({required this.id, required this.email});
}

/// Extensão para facilitar a asserção de comportamentos assíncronos
extension ViewModelTestHelpers on RobustWorkoutRecordViewModel {
  void addListener(void Function(RobustWorkoutRecordState) listener) {
    // Implementação do listener para testes
    // Poderia usar um stream controller interno para isso
  }
}

/// Utilitários para testes de integração
class WorkoutTestUtils {
  static RobustWorkoutParams createValidParams({
    String? workoutName,
    String? workoutType,
    int? durationMinutes,
    DateTime? date,
    String? challengeId,
  }) {
    return RobustWorkoutParams(
      workoutName: workoutName ?? 'Treino Teste',
      workoutType: workoutType ?? 'Musculação',
      durationMinutes: durationMinutes ?? 60,
      date: date ?? DateTime.now().subtract(Duration(hours: 1)),
      challengeId: challengeId,
    );
  }

  static Future<void> waitForStateChange(
    RobustWorkoutRecordViewModel viewModel,
    bool Function(RobustWorkoutRecordState) condition,
    {Duration timeout = const Duration(seconds: 5)}
  ) async {
    final startTime = DateTime.now();
    while (!condition(viewModel.state)) {
      if (DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException('Timeout waiting for state change', timeout);
      }
      await Future.delayed(Duration(milliseconds: 10));
    }
  }
}

/// Testes de performance e stress
class WorkoutStressTests {
  static Future<void> runConcurrentSubmissions(
    RobustWorkoutRecordViewModel viewModel,
    int concurrentCount
  ) async {
    final futures = <Future>[];
    
    for (int i = 0; i < concurrentCount; i++) {
      final params = WorkoutTestUtils.createValidParams(
        workoutName: 'Concurrent Workout $i',
      );
      
      futures.add(viewModel.recordWorkout(params));
    }
    
    await Future.wait(futures);
  }
  
  static Future<void> runRapidSubmissions(
    RobustWorkoutRecordViewModel viewModel,
    int submissionCount
  ) async {
    for (int i = 0; i < submissionCount; i++) {
      final params = WorkoutTestUtils.createValidParams(
        workoutName: 'Rapid Workout $i',
      );
      
      await viewModel.recordWorkout(params);
      // Sem delay intencional para testar rate limiting
    }
  }
} 