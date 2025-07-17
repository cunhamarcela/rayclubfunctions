// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/challenges/models/challenge_model.dart';
import 'package:ray_club_app/features/challenges/models/challenge_progress_model.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_state.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_view_model.dart';

// Mock para o repositório de desafios
class MockChallengeRepository extends Mock implements ChallengeRepository {}

void main() {
  late ChallengeViewModel viewModel;
  late MockChallengeRepository mockRepository;

  // Configuração inicial para cada teste
  setUp(() {
    mockRepository = MockChallengeRepository();
    viewModel = ChallengeViewModel(mockRepository);
  });

  // Desafio de exemplo para testes
  final testChallenge = Challenge(
    id: 'challenge-1',
    title: 'Desafio de Teste',
    description: 'Descrição do desafio de teste',
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 30)),
    imageUrl: 'https://example.com/image.jpg',
    isOfficial: true,
    participantsCount: 10,
    type: 'weight_loss',
    creator: 'user-1',
    creatorName: 'Usuário Teste',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  // Progresso de exemplo para testes
  final testProgress = [
    ChallengeProgress(
      id: 'progress-1',
      challengeId: 'challenge-1',
      userId: 'user-1',
      userName: 'Usuário 1',
      points: 100,
      lastUpdated: DateTime.now(),
      progressPercentage: 50,
    ),
    ChallengeProgress(
      id: 'progress-2',
      challengeId: 'challenge-1',
      userId: 'user-2',
      userName: 'Usuário 2',
      points: 75,
      lastUpdated: DateTime.now(),
      progressPercentage: 30,
    ),
  ];

  group('ChallengeViewModel - Carregamento de desafios', () {
    test('deve iniciar com estado inicial correto', () {
      expect(viewModel.state, const ChallengeState());
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.challenges, isEmpty);
      expect(viewModel.state.error, isNull);
    });

    test('deve carregar desafios com sucesso', () async {
      // Arrange
      when(() => mockRepository.getChallenges())
          .thenAnswer((_) async => [testChallenge]);

      // Act
      await viewModel.loadChallenges();

      // Assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.challenges, [testChallenge]);
      expect(viewModel.state.error, isNull);
      verify(() => mockRepository.getChallenges()).called(1);
    });

    test('deve setar estado de erro quando carregamento de desafios falhar', () async {
      // Arrange
      when(() => mockRepository.getChallenges())
          .thenThrow(AppException(message: 'Erro ao carregar desafios'));

      // Act
      await viewModel.loadChallenges();

      // Assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.challenges, isEmpty);
      expect(viewModel.state.error, 'Erro ao carregar desafios');
      verify(() => mockRepository.getChallenges()).called(1);
    });
  });

  group('ChallengeViewModel - Detalhes do desafio e ranking', () {
    test('deve carregar detalhes do desafio com sucesso', () async {
      // Arrange
      when(() => mockRepository.getChallengeById('challenge-1'))
          .thenAnswer((_) async => testChallenge);

      // Act
      await viewModel.loadChallengeDetails('challenge-1');

      // Assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.selectedChallenge, testChallenge);
      expect(viewModel.state.error, isNull);
      verify(() => mockRepository.getChallengeById('challenge-1')).called(1);
    });

    test('deve carregar ranking do desafio com sucesso', () async {
      // Arrange
      when(() => mockRepository.getChallengeProgress('challenge-1'))
          .thenAnswer((_) async => testProgress);

      // Act
      await viewModel.loadChallengeRanking('challenge-1');

      // Assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.progressList, testProgress);
      expect(viewModel.state.error, isNull);
      verify(() => mockRepository.getChallengeProgress('challenge-1')).called(1);
    });
  });

  group('ChallengeViewModel - Atualização de progresso', () {
    test('deve atualizar progresso com sucesso', () async {
      // Arrange
      final progressUpdate = testProgress[0].copyWith(points: 150, progressPercentage: 75);
      
      when(() => mockRepository.updateProgress(progressUpdate))
          .thenAnswer((_) async => progressUpdate);
      
      when(() => mockRepository.getChallengeProgress('challenge-1'))
          .thenAnswer((_) async => [progressUpdate, testProgress[1]]);

      // Act
      await viewModel.updateProgress(progressUpdate);

      // Assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.progressList, [progressUpdate, testProgress[1]]);
      expect(viewModel.state.error, isNull);
      verify(() => mockRepository.updateProgress(progressUpdate)).called(1);
      verify(() => mockRepository.getChallengeProgress('challenge-1')).called(1);
    });

    test('deve validar pontos ao atualizar progresso', () async {
      // Arrange
      final invalidProgress = testProgress[0].copyWith(points: -10);
      
      // Act & Assert
      expect(() => viewModel.updateProgress(invalidProgress), throwsA(isA<ValidationException>()));
      verifyNever(() => mockRepository.updateProgress(any()));
    });
  });
} 
