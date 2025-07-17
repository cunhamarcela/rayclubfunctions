import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/challenges/mappers/challenge_mapper.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';

void main() {
  group('ChallengeMapper', () {
    test('should convert snake_case JSON to Challenge model', () {
      final now = DateTime.now();
      final end = now.add(const Duration(days: 30));
      
      final json = {
        'id': '1',
        'title': 'Desafio de Verão',
        'description': 'Treinos ao ar livre',
        'image_url': 'https://example.com/image.jpg',
        'start_date': now.toIso8601String(),
        'end_date': end.toIso8601String(),
        'points': 20,
        'creator_id': 'user123',
        'is_official': true,
        'requirements': ['treino diário', 'foto comprobatória'],
      };

      final challenge = ChallengeMapper.fromSupabase(json);
      
      expect(challenge.id, '1');
      expect(challenge.title, 'Desafio de Verão');
      expect(challenge.imageUrl, 'https://example.com/image.jpg');
      expect(challenge.startDate.day, now.day);
      expect(challenge.endDate.day, end.day);
      expect(challenge.points, 20);
      expect(challenge.isOfficial, true);
      expect(challenge.requirements.length, 2);
      expect(challenge.requirements[0], 'treino diário');
    });

    test('should handle null values with safe defaults', () {
      final json = {
        'id': '1',
        'title': null,
        'description': null,
        'points': null,
        'start_date': null,
      };

      final challenge = ChallengeMapper.fromSupabase(json);
      
      expect(challenge.id, '1');
      expect(challenge.title, '');
      expect(challenge.description, '');
      expect(challenge.points, 10); // valor padrão
      expect(challenge.type, 'normal'); // valor padrão
      // startDate deve ser aproximadamente agora
      expect(challenge.startDate.difference(DateTime.now()).inMinutes.abs() < 5, true);
    });

    test('should handle string representation of arrays', () {
      final json = {
        'id': '1',
        'title': 'Test',
        'description': 'Test',
        'creator_id': 'user123',
        'start_date': DateTime.now().toIso8601String(),
        'end_date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        'points': 10,
        'requirements': '[req1,req2,req3]',
      };

      final challenge = ChallengeMapper.fromSupabase(json);
      
      expect(challenge.requirements.length, 3);
      expect(challenge.requirements, contains('req1'));
      expect(challenge.requirements, contains('req2'));
      expect(challenge.requirements, contains('req3'));
    });

    test('needsMapper should correctly identify JSON that needs mapping', () {
      expect(ChallengeMapper.needsMapper({'image_url': 'test.jpg'}), true);
      expect(ChallengeMapper.needsMapper({'start_date': 'date'}), true);
      expect(ChallengeMapper.needsMapper({'requirements': ['test']}), true);
      expect(ChallengeMapper.needsMapper({'id': '1', 'title': 'Test'}), false);
    });
  });
} 