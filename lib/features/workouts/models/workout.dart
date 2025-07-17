// Dart imports:
import 'dart:convert';

/// Modelo que representa um treino.
class Workout {
  final String? id;
  final String name;
  final String type;
  final String description;
  final String difficulty;
  final int durationMinutes;
  final int caloriesBurned;
  final String? imageUrl;
  final int exerciseCount;
  final List<String>? tags;
  final Map<String, dynamic>? exercises;
  final bool isPopular;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const Workout({
    this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.difficulty,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.imageUrl,
    required this.exerciseCount,
    this.tags,
    this.exercises,
    this.isPopular = false,
    this.createdAt,
    this.completedAt,
  });

  /// Cria uma instância de Workout a partir de um mapa JSON.
  factory Workout.fromJson(Map<String, dynamic> json) {
    List<String>? tagsList;
    
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        tagsList = List<String>.from(json['tags']);
      } else if (json['tags'] is String) {
        try {
          // Tenta converter a string em uma lista
          final decoded = jsonDecode(json['tags']);
          if (decoded is List) {
            tagsList = List<String>.from(decoded);
          }
        } catch (_) {
          // Se falhar, trata como uma string única
          tagsList = [json['tags'] as String];
        }
      }
    }

    return Workout(
      id: json['id'] as String?,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      difficulty: json['difficulty'] as String,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      caloriesBurned: json['calories_burned'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      exerciseCount: json['exercise_count'] as int? ?? 0,
      tags: tagsList,
      exercises: json['exercises'] as Map<String, dynamic>?,
      isPopular: json['is_popular'] as bool? ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      completedAt: json['completed_at'] != null 
          ? DateTime.parse(json['completed_at'] as String) 
          : null,
    );
  }

  /// Converte a instância em um mapa JSON.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'type': type,
      'description': description,
      'difficulty': difficulty,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'exercise_count': exerciseCount,
      'is_popular': isPopular,
    };

    if (id != null) data['id'] = id;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (tags != null) data['tags'] = jsonEncode(tags);
    if (exercises != null) data['exercises'] = exercises;
    if (createdAt != null) data['created_at'] = createdAt!.toIso8601String();
    if (completedAt != null) data['completed_at'] = completedAt!.toIso8601String();

    return data;
  }

  /// Cria uma cópia desta instância com os campos especificados substituídos.
  Workout copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    String? difficulty,
    int? durationMinutes,
    int? caloriesBurned,
    String? imageUrl,
    int? exerciseCount,
    List<String>? tags,
    Map<String, dynamic>? exercises,
    bool? isPopular,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Workout(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      imageUrl: imageUrl ?? this.imageUrl,
      exerciseCount: exerciseCount ?? this.exerciseCount,
      tags: tags ?? this.tags,
      exercises: exercises ?? this.exercises,
      isPopular: isPopular ?? this.isPopular,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
} 