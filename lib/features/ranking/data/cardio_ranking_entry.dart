// Ray Club — Cardio Ranking Entry model

class CardioRankingEntry {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final int totalCardioMinutes;

  const CardioRankingEntry({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.totalCardioMinutes,
  });

  factory CardioRankingEntry.fromMap(Map<String, dynamic> map) {
    final rawName = map['full_name'] as String?;
    final trimmedName = rawName?.trim();
    final rawAvatar = map['avatar_url'] as String?;
    final trimmedAvatar = rawAvatar?.trim();
    return CardioRankingEntry(
      userId: map['user_id'] as String,
      fullName: (trimmedName != null && trimmedName.isNotEmpty) ? trimmedName : 'Sem nome',
      avatarUrl: (trimmedAvatar != null && trimmedAvatar.isNotEmpty) ? trimmedAvatar : null,
      totalCardioMinutes: (map['total_cardio_minutes'] ?? 0) as int,
    );
  }
}


