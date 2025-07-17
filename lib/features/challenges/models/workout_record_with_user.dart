import 'package:flutter/foundation.dart';

/// Model class that represents a workout record with user information
class WorkoutRecordWithUser {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String workoutName;
  final String workoutType;
  final DateTime date;
  final int durationMinutes;
  final List<String>? imageUrls;
  final String? notes;
  
  const WorkoutRecordWithUser({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.workoutName,
    required this.workoutType,
    required this.date,
    required this.durationMinutes,
    this.imageUrls,
    this.notes,
  });
  
  /// Creates a WorkoutRecordWithUser from JSON data
  factory WorkoutRecordWithUser.fromJson(Map<String, dynamic> json) {
    return WorkoutRecordWithUser(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Usuário anônimo',
      userPhotoUrl: json['user_photo_url'] as String?,
      workoutName: json['workout_name'] as String? ?? 'Treino sem nome',
      workoutType: json['workout_type'] as String? ?? 'Outro',
      date: json['date'] != null 
          ? DateTime.parse(json['date'] as String) 
          : DateTime.now(),
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls'] as List) 
          : null,
      notes: json['notes'] as String?,
    );
  }
  
  /// Converts this workout record to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'workout_name': workoutName,
      'workout_type': workoutType,
      'date': date.toIso8601String(),
      'duration_minutes': durationMinutes,
      'image_urls': imageUrls,
      'notes': notes,
    };
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is WorkoutRecordWithUser &&
        other.id == id &&
        other.userId == userId;
  }
  
  @override
  int get hashCode => id.hashCode ^ userId.hashCode;
} 