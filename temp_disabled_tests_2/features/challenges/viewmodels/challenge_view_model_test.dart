// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:async'; // Added for StreamController
import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/auth/models/user.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_state.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group_invite.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/models/challenge_check_in.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/services/challenge_realtime_service.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_view_model.dart';
import 'challenge_view_model_test.mocks.dart';

@GenerateMocks([ChallengeRepository, IAuthRepository, ChallengeRealtimeService])
void main() {
  late MockChallengeRepository mockRepository;
  late MockIAuthRepository mockAuthRepository;
  late MockChallengeRealtimeService mockRealtimeService;
  late ChallengeViewModel viewModel;
  late MockRef mockRef;

  setUp(() {
    mockRepository = MockChallengeRepository();
    mockAuthRepository = MockIAuthRepository();
    mockRealtimeService = MockChallengeRealtimeService();
    mockRef = MockRef();
    
    // Setup ref.watch to return the mock repository
    when(() => mockRef.watch(any())).thenReturn(mockRepository);
    
    // Mock de autenticação - válido para todos os testes
    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => 
      User(
        id: 'test-user-id',
        email: 'test@example.com',
        name: 'Test User',
      )
    );
    
    viewModel = ChallengeViewModel(
      repository: mockRepository,
      authRepository: mockAuthRepository,
      realtimeService: mockRealtimeService,
      ref: mockRef,
    );
  });

  group('ChallengeViewModel', () {
    test('estado inicial', () {
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.challenges, isEmpty);
      expect(viewModel.state.officialChallenge, isNull);
      expect(viewModel.state.selectedChallenge, isNull);
      expect(viewModel.state.errorMessage, isNull);
    });

    group('loadAllChallenges', () {
      test('carrega todos os desafios com sucesso', () async {
        // Arrange
        final mockChallenges = [
          Challenge(
            id: 'challenge-1',
            title: 'Desafio 1',
            description: 'Descrição 1',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 30)),
            points: 10,
            creatorId: 'test-user-id',
          ),
          Challenge(
            id: 'challenge-2',
            title: 'Desafio 2',
            description: 'Descrição 2',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 60)),
            points: 20,
            creatorId: 'other-user-id',
          ),
        ];

        when(mockRepository.getChallenges()).thenAnswer((_) async => mockChallenges);

        // Act
        await viewModel.loadAllChallenges();

        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.challenges.length, 2);
        expect(viewModel.state.challenges[0].id, 'challenge-1');
        expect(viewModel.state.challenges[1].id, 'challenge-2');
        expect(viewModel.state.errorMessage, isNull);
        
        verify(mockRepository.getChallenges()).called(1);
      });

      test('atualiza o estado de erro quando ocorre uma exceção', () async {
        // Arrange
        when(mockRepository.getChallenges())
            .thenThrow(DatabaseException(message: 'Falha ao carregar desafios'));

        // Act
        await viewModel.loadAllChallenges();

        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.challenges, isEmpty);
        expect(viewModel.state.errorMessage, contains('Falha ao carregar desafios'));
        
        verify(mockRepository.getChallenges()).called(1);
      });
    });

    group('loadOfficialChallenge', () {
      test('carrega desafio oficial com sucesso', () async {
        // Arrange
        final mockChallenge = Challenge(
          id: 'official-challenge',
          title: 'Desafio Oficial',
          description: 'Descrição do desafio oficial',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          points: 30,
          isOfficial: true,
          creatorId: 'admin-user-id',
        );

        final mockProgress = ChallengeProgress(
          id: 'progress-1',
          challengeId: 'official-challenge',
          userId: 'test-user-id',
          points: 100,
          position: 1,
          checkInsCount: 5,
          consecutiveDays: 5,
          userName: 'Test User',
        );

        when(mockRepository.getOfficialChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        
      ))
            .thenAnswer((_) async => mockChallenge);
        when(mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        'official-challenge'
      ))
            .thenAnswer((_) async => [mockProgress]);
        when(mockRepository.getUserProgress('official-challenge', 'test-user-id'))
            .thenAnswer((_) async => mockProgress);

        // Act
        await viewModel.loadOfficialChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        
      );

        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.officialChallenge, isNotNull);
        expect(viewModel.state.officialChallenge?.id, 'official-challenge');
        expect(viewModel.state.officialChallenge?.isOfficial, isTrue);
        expect(viewModel.state.userProgress, isNotNull);
        expect(viewModel.state.userProgress?.points, 100);
        expect(viewModel.state.progressList.length, 1);
        
        verify(mockRepository.getOfficialChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        
      )).called(1);
        verify(mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        'official-challenge'
      )).called(1);
        verify(mockRepository.getUserProgress('official-challenge', 'test-user-id')).called(1);
      });

      test('lida com desafio oficial null', () async {
        // Arrange
        when(mockRepository.getOfficialChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        
      ))
            .thenAnswer((_) async => null);

        // Act
        await viewModel.loadOfficialChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        
      );

        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.officialChallenge, isNull);
        
        verify(mockRepository.getOfficialChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        
      )).called(1);
        verifyNever(mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        any
      ));
        verifyNever(mockRepository.getUserProgress(any, any));
      });
    });

    group('filterChallenges', () {
      test('filtra desafios com sucesso', () async {
        // Arrange
        final mockChallenges = [
          Challenge(
            id: 'challenge-1',
            title: 'Desafio 1',
            description: 'Descrição 1',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 30)),
            points: 10,
            type: 'workout',
            creatorId: 'test-user-id',
          ),
          Challenge(
            id: 'challenge-2',
            title: 'Desafio 2',
            description: 'Descrição 2',
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 60)),
            points: 20,
            type: 'nutrition',
            creatorId: 'other-user-id',
          ),
        ];

        when(mockRepository.getChallenges(
            filters: anyNamed('filters'),
            includeInactive: anyNamed('includeInactive')))
            .thenAnswer((_) async => mockChallenges);

        // Act
        await viewModel.loadAllChallenges();
        await viewModel.filterChallenges(type: 'workout');

        // Assert
        verify(mockRepository.getChallenges(
            filters: {'type': 'workout'},
            includeInactive: false)).called(1);
        
        // Poderia testar mais aqui, mas precisaria implementar a lógica real de filtro
        // no mock, o que está além do escopo deste teste unitário simples
      });
    });

    group('getChallengeById', () {
      test('busca um desafio por ID com sucesso', () async {
        // Arrange
        final challengeId = 'challenge-1';
        final mockChallenge = Challenge(
          id: challengeId,
          title: 'Desafio 1',
          description: 'Descrição 1',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          points: 10,
          creatorId: 'test-user-id',
        );

        when(mockRepository.getChallengeById(challengeId))
            .thenAnswer((_) async => mockChallenge);

        // Act
        final result = await viewModel.getChallengeById(challengeId);

        // Assert
        expect(result, isNotNull);
        expect(result.id, challengeId);
        verify(mockRepository.getChallengeById(challengeId)).called(1);
      });

      test('retorna null quando desafio não é encontrado', () async {
        // Arrange
        final challengeId = 'non-existent-id';
        
        when(mockRepository.getChallengeById(challengeId))
            .thenThrow(NotFoundException(message: 'Desafio não encontrado'));

        // Act & Assert
        expect(() => viewModel.getChallengeById(challengeId), 
               throwsA(isA<NotFoundException>()));
        
        verify(mockRepository.getChallengeById(challengeId)).called(1);
      });
    });

    group('createChallenge', () {
      test('cria um desafio com sucesso', () async {
        // Arrange
        final mockChallenge = Challenge(
          id: '', // ID vazio, será preenchido pelo repositório
          title: 'Novo Desafio',
          description: 'Descrição do novo desafio',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          points: 15,
          creatorId: 'test-user-id',
        );

        final createdChallenge = mockChallenge.copyWith(id: 'new-challenge-id');
        
        when(mockRepository.createChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        any
      ))
            .thenAnswer((_) async => createdChallenge);
        when(mockRepository.getChallenges())
            .thenAnswer((_) async => [createdChallenge]);

        // Act
        final result = await viewModel.createChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        mockChallenge
      );

        // Assert
        expect(result, isNotNull);
        expect(result.id, 'new-challenge-id');
        expect(viewModel.state.successMessage, contains('Desafio criado com sucesso'));
        
        verify(mockRepository.createChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        any
      )).called(1);
        verify(mockRepository.getChallenges()).called(1);
      });

      test('lida com erros na criação de desafio', () async {
        // Arrange
        final mockChallenge = Challenge(
          id: '',
          title: 'Novo Desafio',
          description: 'Descrição do novo desafio',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          points: 15,
          creatorId: 'test-user-id',
        );
        
        when(mockRepository.createChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        any
      ))
            .thenThrow(ValidationException(message: 'Título inválido'));

        // Act
        expect(() => viewModel.createChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        mockChallenge
      ), 
               throwsA(isA<ValidationException>()));
        
        verify(mockRepository.createChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        any
      )).called(1);
        verifyNever(mockRepository.getChallenges());
      });
    });

    test('joinChallenge updates user progress', () async {
      // Arrange
      const challengeId = 'challenge-123';
      const userId = 'user-123';
      
      when(() => mockRepository.joinChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        challengeId, userId
      ))
          .thenAnswer((_) async {});
      
      // Act
      await viewModel.joinChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        challengeId, userId
      );
      
      // Assert
      verify(() => mockRepository.joinChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        challengeId, userId
      )).called(1);
    });

    test('checkInToChallenge records check-in', () async {
      // Arrange
      const challengeId = 'challenge-123';
      const userId = 'user-123';
      
      final checkInResult = CheckInResult(
        challengeId: challengeId,
        userId: userId,
        points: 10,
        message: 'Check-in successful',
        createdAt: DateTime.now(),
      );
      
      when(() => mockRepository.checkInToChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        challengeId: challengeId, userId: userId
      ))
          .thenAnswer((_) async => checkInResult);
      
      // Act
      final result = await viewModel.checkInToChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        challengeId, userId
      );
      
      // Assert
      expect(result, isNotNull);
      expect(result.points, 10);
      verify(() => mockRepository.checkInToChallenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: 'fitness',
        challengeId: challengeId, userId: userId
      )).called(1);
    });

    test('getChallengeProgress returns progress list', () async {
      // Arrange
      const challengeId = 'challenge-123';
      final progressList = [
        ChallengeProgress(
          id: 'progress-1',
          challengeId: challengeId,
          userId: 'user-1',
          userName: 'User 1',
          points: 100,
          position: 1,
          createdAt: DateTime.now(),
        ),
      ];
      
      when(() => mockRepository.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        challengeId
      ))
          .thenAnswer((_) async => progressList);
      
      // Act
      final result = await viewModel.getChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        challengeId
      );
      
      // Assert
      expect(result, isNotEmpty);
      expect(result.length, 1);
      expect(result.first.points, 100);
    });
  });
} 
