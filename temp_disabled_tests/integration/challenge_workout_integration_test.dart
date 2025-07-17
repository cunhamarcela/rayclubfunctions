import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/auth/models/user.dart';
import 'package:ray_club_app/services/workout_challenge_service.dart';

// Gerar mocks
@GenerateMocks([ChallengeRepository, IAuthRepository])
import 'challenge_workout_integration_test.mocks.dart';

void main() {
  late MockChallengeRepository mockChallengeRepository;
  late MockIAuthRepository mockAuthRepository;
  late WorkoutChallengeService service;
  late ProviderContainer container;

  final testUser = AppUser(
    id: 'user-123',
    email: 'test@example.com',
    name: 'Test User',
    photoUrl: null,
    createdAt: DateTime.now(),
    isEmailVerified: true,
    metadata: {'name': 'Test User'},
  );

  final officialChallenge = Challenge(
    id: 'challenge-official-123',
    title: 'Desafio Oficial Ray',
    description: 'Desafio oficial da Ray',
    startDate: DateTime.now().subtract(const Duration(days: 10)),
    endDate: DateTime.now().add(const Duration(days: 20)),
    creatorId: 'ray-admin',
    isOfficial: true,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
  );

  final privateChallenge = Challenge(
    id: 'challenge-private-456',
    title: 'Desafio Privado',
    description: 'Desafio criado por usuário',
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    endDate: DateTime.now().add(const Duration(days: 25)),
    creatorId: 'user-456',
    isOfficial: false,
    createdAt: DateTime.now().subtract(const Duration(days: 8)),
  );

  setUp(() {
    mockChallengeRepository = MockChallengeRepository();
    mockAuthRepository = MockIAuthRepository();
    
    // Substitui o mock para retornar null - vamos simular através de metadata 
    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => null);
    
    when(mockChallengeRepository.getUserActiveChallenges('user-123'))
        .thenAnswer((_) async => [officialChallenge, privateChallenge]);
    
    when(mockChallengeRepository.hasCheckedInOnDate(
      'user-123', 
      'challenge-official-123', 
      any
    )).thenAnswer((_) async => false);
    
    when(mockChallengeRepository.hasCheckedInOnDate(
      'user-123', 
      'challenge-private-456', 
      any
    )).thenAnswer((_) async => false);
    
    when(mockChallengeRepository.getChallengeById('challenge-official-123'))
        .thenAnswer((_) async => officialChallenge);
    
    when(mockChallengeRepository.getChallengeById('challenge-private-456'))
        .thenAnswer((_) async => privateChallenge);
    
    when(mockChallengeRepository.getConsecutiveDaysCount(
      'user-123', 
      'challenge-official-123'
    )).thenAnswer((_) async => 3); // 3 dias consecutivos
    
    // Configurar container com overrides
    container = ProviderContainer();
    
    // Criando o serviço diretamente com as dependências mockadas
    service = WorkoutChallengeService(mockChallengeRepository, mockAuthRepository);
  });

  tearDown(() {
    container.dispose();
  });

  // group('WorkoutChallengeService', () {
    // test('processWorkoutCompletion deve registrar check-ins para desafios ativos', () async {
      // Arrange
      final today = DateTime.now();
      
      // Act
      await service.processWorkoutCompletion('user-123', today);
      
      // Assert
      verify(mockChallengeRepository.hasCheckedInOnDate(
        'user-123', 
        'challenge-official-123', 
        any
      )).called(1);
      
      verify(mockChallengeRepository.hasCheckedInOnDate(
        'user-123', 
        'challenge-private-456', 
        any
      )).called(1);
      
      verify(mockChallengeRepository.recordChallengeCheckIn(
        challengeId: 'challenge-official-123',
        userId: 'user-123',
        workoutId: any(named: 'workoutId'),
        workoutName: any(named: 'workoutName'),
        workoutType: any(named: 'workoutType'),
        date: any(named: 'date'),
        durationMinutes: any(named: 'durationMinutes'),
      )).called(1);
      
      verify(mockChallengeRepository.recordChallengeCheckIn(
        challengeId: 'challenge-private-456',
        userId: 'user-123',
        workoutId: any(named: 'workoutId'),
        workoutName: any(named: 'workoutName'),
        workoutType: any(named: 'workoutType'),
        date: any(named: 'date'),
        durationMinutes: any(named: 'durationMinutes'),
      )).called(1);
    });
    
    // test('processWorkoutCompletion não deve registrar check-in se já existir', () async {
      // Arrange
      final today = DateTime.now();
      
      when(mockChallengeRepository.hasCheckedInOnDate(
        'user-123', 
        'challenge-official-123', 
        any
      )).thenAnswer((_) async => true);
      
      // Act
      await service.processWorkoutCompletion('user-123', today);
      
      // Assert
      verify(mockChallengeRepository.hasCheckedInOnDate(
        'user-123', 
        'challenge-official-123', 
        any
      )).called(1);
      
      verifyNever(mockChallengeRepository.recordChallengeCheckIn(
        challengeId: 'challenge-official-123',
        userId: 'user-123',
        workoutId: any(named: 'workoutId'),
        workoutName: any(named: 'workoutName'),
        workoutType: any(named: 'workoutType'),
        date: any(named: 'date'),
        durationMinutes: any(named: 'durationMinutes'),
      ));
      
      // O outro desafio ainda deve receber check-in
      verify(mockChallengeRepository.recordChallengeCheckIn(
        challengeId: 'challenge-private-456',
        userId: 'user-123',
        workoutId: any(named: 'workoutId'),
        workoutName: any(named: 'workoutName'),
        workoutType: any(named: 'workoutType'),
        date: any(named: 'date'),
        durationMinutes: any(named: 'durationMinutes'),
      )).called(1);
    });
    
    // test('processWorkoutCompletion deve adicionar bônus para sequências consecutivas', () async {
      // Arrange
      final today = DateTime.now();
      
      when(mockChallengeRepository.getConsecutiveDaysCount(
        'user-123', 
        'challenge-official-123'
      )).thenAnswer((_) async => 7); // 7 dias (múltiplo de 7)
      
      // Act
      await service.processWorkoutCompletion('user-123', today);
      
      // Assert
      verify(mockChallengeRepository.addBonusPoints(
        'user-123',
        'challenge-official-123',
        any,
        any,
        'Usuário',
        null
      )).called(1);
    });
  });
} 