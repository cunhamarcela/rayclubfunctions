class ParticipantWorkout {
  final String id;
  final String workoutName;
  final String workoutType;
  final DateTime date;
  final int durationMinutes;
  final String? notes;
  final bool isCompleted;
  final List<String>? imageUrls;

  const ParticipantWorkout({
    required this.id,
    required this.workoutName,
    required this.workoutType,
    required this.date,
    required this.durationMinutes,
    this.notes,
    required this.isCompleted,
    this.imageUrls,
  });

  factory ParticipantWorkout.fromMap(Map<String, dynamic> map) {
    return ParticipantWorkout(
      id: map['id'] as String,
      workoutName: map['workout_name'] as String? ?? 'Treino de Cardio',
      workoutType: map['workout_type'] as String? ?? 'cardio',
      date: DateTime.parse(map['date'] as String),
      durationMinutes: (map['duration_minutes'] ?? 0) as int,
      notes: map['notes'] as String?,
      isCompleted: (map['is_completed'] ?? true) as bool,
      imageUrls: map['image_urls'] != null 
          ? List<String>.from(map['image_urls'] as List)
          : null,
    );
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Hoje';
    } else if (difference == 1) {
      return 'Ontem';
    } else if (difference < 7) {
      return '$difference dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String get durationFormatted {
    if (durationMinutes < 60) {
      return '${durationMinutes}min';
    } else {
      final hours = durationMinutes ~/ 60;
      final minutes = durationMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    }
  }
}
