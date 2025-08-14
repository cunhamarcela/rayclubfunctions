import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/ranking/data/cardio_ranking_entry.dart';

void main() {
  test('CardioRankingEntry.fromMap maps correctly with full data', () {
    final map = {
      'user_id': 'uuid-123',
      'full_name': 'Maria Ray',
      'avatar_url': 'https://example.com/a.png',
      'total_cardio_minutes': 150,
    };

    final entry = CardioRankingEntry.fromMap(map);
    expect(entry.userId, 'uuid-123');
    expect(entry.fullName, 'Maria Ray');
    expect(entry.avatarUrl, 'https://example.com/a.png');
    expect(entry.totalCardioMinutes, 150);
  });

  test('CardioRankingEntry.fromMap handles null avatar and default name', () {
    final map = {
      'user_id': 'uuid-xyz',
      'full_name': null,
      'avatar_url': null,
      'total_cardio_minutes': 0,
    };

    final entry = CardioRankingEntry.fromMap(map);
    expect(entry.userId, 'uuid-xyz');
    expect(entry.fullName, 'Sem nome');
    expect(entry.avatarUrl, isNull);
    expect(entry.totalCardioMinutes, 0);
  });
}


