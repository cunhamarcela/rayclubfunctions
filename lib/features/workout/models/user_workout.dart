import 'package:flutter/foundation.dart';

/// Model representing a completed workout by a user
class UserWorkout {
  final String id;
  final String userId;
  final String workoutId;
  final String? userName;
  final String? userPhotoUrl;
  final String? workoutType;
  final int? duration;
  final int? caloriesBurned;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? progress;
  final String? notes;
  final Map<String, dynamic>? feedback;
  final Map<String, dynamic>? exercisesCompleted;

  const UserWorkout({
    required this.id,
    required this.userId,
    required this.workoutId,
    this.userName,
    this.userPhotoUrl,
    this.workoutType,
    this.duration,
    this.caloriesBurned,
    this.startedAt,
    this.completedAt,
    this.progress,
    this.notes,
    this.feedback,
    this.exercisesCompleted,
  });

  factory UserWorkout.fromJson(Map<String, dynamic> json) {
    return UserWorkout(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      workoutId: json['workout_id'] as String,
      userName: json['user_name'] as String?,
      userPhotoUrl: json['user_photo_url'] as String?,
      workoutType: json['workout_type'] as String?,
      duration: json['duration'] as int?,
      caloriesBurned: json['calories_burned'] as int?,
      startedAt: json['started_at'] != null 
          ? DateTime.parse(json['started_at'] as String) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
      progress: json['progress'] != null ? (json['progress'] as num).toDouble() : null,
      notes: json['notes'] as String?,
      feedback: json['feedback'] as Map<String, dynamic>?,
      exercisesCompleted: json['exercises_completed'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'workout_id': workoutId,
    };

    if (userName != null) data['user_name'] = userName;
    if (userPhotoUrl != null) data['user_photo_url'] = userPhotoUrl;
    if (workoutType != null) data['workout_type'] = workoutType;
    if (duration != null) data['duration'] = duration;
    if (caloriesBurned != null) data['calories_burned'] = caloriesBurned;
    if (startedAt != null) data['started_at'] = startedAt!.toIso8601String();
    if (completedAt != null) data['completed_at'] = completedAt!.toIso8601String();
    if (progress != null) data['progress'] = progress;
    if (notes != null) data['notes'] = notes;
    if (feedback != null) data['feedback'] = feedback;
    if (exercisesCompleted != null) data['exercises_completed'] = exercisesCompleted;

    return data;
  }

  UserWorkout copyWith({
    String? id,
    String? userId,
    String? workoutId,
    String? userName,
    String? userPhotoUrl,
    String? workoutType,
    int? duration,
    int? caloriesBurned,
    DateTime? startedAt,
    DateTime? completedAt,
    double? progress,
    String? notes,
    Map<String, dynamic>? feedback,
    Map<String, dynamic>? exercisesCompleted,
  }) {
    return UserWorkout(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workoutId: workoutId ?? this.workoutId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      workoutType: workoutType ?? this.workoutType,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      notes: notes ?? this.notes,
      feedback: feedback ?? this.feedback,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
    );
  }
} 