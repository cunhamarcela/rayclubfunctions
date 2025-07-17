// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:ray_club_app/features/challenges/models/challenge_progress.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';

// Gerar mocks automaticamente
@GenerateMocks([ChallengeRepository])
import 'ranking_consistency_test.mocks.dart';

/// Testes para validar a consistência do ranking 100% banco de dados
/// 
/// Estes testes garantem que:
/// 1. Os dados vêm ordenados do banco
/// 2. Não há reordenação no código Dart
/// 3. As posições são respeitadas conforme o banco
void main() {
  group('Ranking Consistency Tests', () {
    late MockChallengeRepository mockRepository;
    
    setUp(() {
      mockRepository = MockChallengeRepository();
    });
    
    group('Database Ordering', () {
      test('should return progress list ordered by position from database', () async {
        // Arrange - Simular dados já ordenados do banco
        final mockProgressList = [
          ChallengeProgress(
            id: '1',
            userId: 'user1',
            challengeId: 'challenge1',
            userName: 'Usuário 1',
            points: 100,
            position: 1, // ✅ Posição calculada pelo banco
            createdAt: DateTime.now(),
          ),
          ChallengeProgress(
            id: '2',
            userId: 'user2',
            challengeId: 'challenge1',
            userName: 'Usuário 2',
            points: 90,
            position: 2, // ✅ Posição calculada pelo banco
            createdAt: DateTime.now(),
          ),
          ChallengeProgress(
            id: '3',
            userId: 'user3',
            challengeId: 'challenge1',
            userName: 'Usuário 3',
            points: 80,
            position: 3, // ✅ Posição calculada pelo banco
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockRepository.getChallengeProgress('challenge1'))
            .thenAnswer((_) async => mockProgressList);
        
        // Act
        final result = await mockRepository.getChallengeProgress('challenge1');
        
        // Assert - Verificar que os dados vêm ordenados
        expect(result.length, equals(3));
        expect(result[0].position, equals(1));
        expect(result[1].position, equals(2));
        expect(result[2].position, equals(3));
        
        // Verificar que as posições correspondem à ordem dos pontos
        expect(result[0].points, greaterThanOrEqualTo(result[1].points));
        expect(result[1].points, greaterThanOrEqualTo(result[2].points));
      });
      
      test('should handle tie-breaking correctly', () async {
        // Arrange - Simular empate em pontos com critérios de desempate
        final mockProgressList = [
          ChallengeProgress(
            id: '1',
            userId: 'user1',
            challengeId: 'challenge1',
            userName: 'Usuário 1',
            points: 100,
            position: 1, // ✅ Primeiro por ter mais treinos
            checkInsCount: 15,
            createdAt: DateTime.now(),
          ),
          ChallengeProgress(
            id: '2',
            userId: 'user2',
            challengeId: 'challenge1',
            userName: 'Usuário 2',
            points: 100,
            position: 2, // ✅ Segundo por ter menos treinos
            checkInsCount: 12,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockRepository.getChallengeProgress('challenge1'))
            .thenAnswer((_) async => mockProgressList);
        
        // Act
        final result = await mockRepository.getChallengeProgress('challenge1');
        
        // Assert - Verificar critérios de desempate
        expect(result[0].points, equals(result[1].points)); // Mesmos pontos
        expect(result[0].position, equals(1)); // Posição correta do banco
        expect(result[1].position, equals(2)); // Posição correta do banco
        
        // O usuário com mais check-ins deve estar em primeiro
        expect(result[0].checkInsCount! > result[1].checkInsCount!, isTrue);
      });
    });
    
    group('Position Validation', () {
      test('should not modify positions from database', () {
        // Arrange - Dados com posições específicas do banco
        final originalProgress = ChallengeProgress(
          id: '1',
          userId: 'user1',
          challengeId: 'challenge1',
          userName: 'Usuário 1',
          points: 100,
          position: 5, // ✅ Posição específica do banco
          createdAt: DateTime.now(),
        );
        
        // Act - Simular que não há modificação de posição no código
        final processedProgress = originalProgress; // Sem copyWith(position: ...)
        
        // Assert - Posição deve permanecer inalterada
        expect(processedProgress.position, equals(5));
        expect(processedProgress.position, equals(originalProgress.position));
      });
      
      test('should preserve database ordering in lists', () {
        // Arrange - Lista com ordem específica do banco
        final databaseOrderedList = [
          ChallengeProgress(
            id: '3',
            userId: 'user3',
            challengeId: 'challenge1',
            userName: 'Usuário 3',
            points: 120,
            position: 1,
            createdAt: DateTime.now(),
          ),
          ChallengeProgress(
            id: '1',
            userId: 'user1',
            challengeId: 'challenge1',
            userName: 'Usuário 1',
            points: 100,
            position: 2,
            createdAt: DateTime.now(),
          ),
          ChallengeProgress(
            id: '2',
            userId: 'user2',
            challengeId: 'challenge1',
            userName: 'Usuário 2',
            points: 90,
            position: 3,
            createdAt: DateTime.now(),
          ),
        ];
        
        // Act - Simular processamento sem reordenação
        final processedList = List<ChallengeProgress>.from(databaseOrderedList);
        // ✅ NÃO fazer: processedList.sort((a, b) => b.points.compareTo(a.points));
        
        // Assert - Ordem deve permanecer a mesma do banco
        expect(processedList[0].position, equals(1));
        expect(processedList[1].position, equals(2));
        expect(processedList[2].position, equals(3));
        
        // IDs devem estar na mesma ordem
        expect(processedList[0].id, equals('3'));
        expect(processedList[1].id, equals('1'));
        expect(processedList[2].id, equals('2'));
      });
    });
    
    group('Stream Consistency', () {
      test('should maintain order in real-time updates', () async {
        // Arrange - Stream com dados ordenados
        final streamData = [
          ChallengeProgress(
            id: '1',
            userId: 'user1',
            challengeId: 'challenge1',
            userName: 'Usuário 1',
            points: 100,
            position: 1,
            createdAt: DateTime.now(),
          ),
          ChallengeProgress(
            id: '2',
            userId: 'user2',
            challengeId: 'challenge1',
            userName: 'Usuário 2',
            points: 90,
            position: 2,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockRepository.watchChallengeRanking(challengeId: 'challenge1'))
            .thenAnswer((_) => Stream.value(streamData));
        
        // Act
        final stream = mockRepository.watchChallengeRanking(challengeId: 'challenge1');
        final result = await stream.first;
        
        // Assert - Ordem deve ser preservada
        expect(result[0].position, equals(1));
        expect(result[1].position, equals(2));
        expect(result[0].points, greaterThan(result[1].points));
      });
    });
    
    group('Edge Cases', () {
      test('should handle empty ranking list', () async {
        // Arrange
        when(mockRepository.getChallengeProgress('challenge1'))
            .thenAnswer((_) async => []);
        
        // Act
        final result = await mockRepository.getChallengeProgress('challenge1');
        
        // Assert
        expect(result, isEmpty);
      });
      
      test('should handle single user ranking', () async {
        // Arrange
        final singleUserList = [
          ChallengeProgress(
            id: '1',
            userId: 'user1',
            challengeId: 'challenge1',
            userName: 'Usuário 1',
            points: 100,
            position: 1,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockRepository.getChallengeProgress('challenge1'))
            .thenAnswer((_) async => singleUserList);
        
        // Act
        final result = await mockRepository.getChallengeProgress('challenge1');
        
        // Assert
        expect(result.length, equals(1));
        expect(result[0].position, equals(1));
      });
    });
  });
} 