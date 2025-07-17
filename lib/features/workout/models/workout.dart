// Package imports:
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import 'exercise.dart';

part 'workout.g.dart';

/// Modelo que representa um treino completo
@JsonSerializable()
class Workout extends Equatable {
  /// Identificador único do treino
  final String id;
  
  /// Título do treino
  final String title;
  
  /// Descrição detalhada do treino
  final String description;
  
  /// Categoria do treino (ex: "Força", "Cardio", etc)
  final String category;
  
  /// Duração estimada em minutos
  final int duration;
  
  /// Nível de dificuldade do treino
  final String level;
  
  /// Calorias estimadas a serem queimadas
  final int calories;
  
  /// URL da imagem de capa do treino
  final String imageUrl;
  
  /// Lista de exercícios que compõem o treino
  final List<Exercise> exercises;
  
  /// Data de criação do treino
  final DateTime? createdAt;
  
  /// Se o treino está favoritado pelo usuário
  final bool isFavorite;
  
  /// Treinador/criador do treino
  final String? trainerName;
  
  /// Se o treino é um treino destaque/recomendado
  final bool isFeatured;

  /// Construtor
  const Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.level,
    required this.calories,
    required this.imageUrl,
    required this.exercises,
    this.createdAt,
    this.isFavorite = false,
    this.trainerName,
    this.isFeatured = false,
  });

  /// Cria um Workout a partir de um Map JSON
  factory Workout.fromJson(Map<String, dynamic> json) => _$WorkoutFromJson(json);

  /// Converte o Workout para um Map JSON
  Map<String, dynamic> toJson() => _$WorkoutToJson(this);

  @override
  List<Object?> get props => [
    id, 
    title, 
    description, 
    category, 
    duration, 
    level, 
    calories, 
    imageUrl, 
    exercises, 
    createdAt, 
    isFavorite, 
    trainerName, 
    isFeatured
  ];

  /// Cria uma cópia deste Workout com os campos especificados atualizados
  Workout copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? duration,
    String? level,
    int? calories,
    String? imageUrl,
    List<Exercise>? exercises,
    DateTime? createdAt,
    bool? isFavorite,
    String? trainerName,
    bool? isFeatured,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      duration: duration ?? this.duration,
      level: level ?? this.level,
      calories: calories ?? this.calories,
      imageUrl: imageUrl ?? this.imageUrl,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      trainerName: trainerName ?? this.trainerName,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }
} 