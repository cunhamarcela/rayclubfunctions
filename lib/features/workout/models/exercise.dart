// Package imports:
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exercise.g.dart';

/// Modelo que representa um exercício dentro de um treino
@JsonSerializable()
class Exercise extends Equatable {
  /// Identificador único do exercício
  final String id;
  
  /// Nome do exercício
  final String name;
  
  /// Detalhes do exercício (séries, repetições, etc)
  final String detail;
  
  /// URL da imagem ilustrativa do exercício
  final String? imageUrl;
  
  /// Tempo de descanso em segundos
  final int? restTime;
  
  /// Instruções para realização do exercício
  final String? instructions;
  
  /// Músculos trabalhados neste exercício
  final List<String>? targetMuscles;
  
  /// Equipamentos necessários para este exercício
  final List<String>? equipment;
  
  /// URL do vídeo demonstrativo do exercício (opcional)
  final String? videoUrl;
  
  /// Descrição do exercício
  final String? description;
  
  /// Número de séries
  final int? sets;
  
  /// Número de repetições por série
  final int? reps;
  
  /// Duração em segundos (para exercícios por tempo)
  final int? duration;

  /// Construtor
  const Exercise({
    required this.id,
    required this.name,
    required this.detail,
    this.imageUrl,
    this.restTime,
    this.instructions,
    this.targetMuscles,
    this.equipment,
    this.videoUrl,
    this.description,
    this.sets = 3,
    this.reps = 12,
    this.duration,
  });

  /// Cria um Exercise a partir de um Map JSON
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  /// Converte o Exercise para um Map JSON
  Map<String, dynamic> toJson() => _$ExerciseToJson(this);

  @override
  List<Object?> get props => [
    id, 
    name, 
    detail, 
    imageUrl, 
    restTime, 
    instructions, 
    targetMuscles, 
    equipment, 
    videoUrl,
    description,
    sets,
    reps,
    duration
  ];

  /// Cria uma cópia deste Exercise com os campos especificados atualizados
  Exercise copyWith({
    String? id,
    String? name,
    String? detail,
    String? imageUrl,
    int? restTime,
    String? instructions,
    List<String>? targetMuscles,
    List<String>? equipment,
    String? videoUrl,
    String? description,
    int? sets,
    int? reps,
    int? duration,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      detail: detail ?? this.detail,
      imageUrl: imageUrl ?? this.imageUrl,
      restTime: restTime ?? this.restTime,
      instructions: instructions ?? this.instructions,
      targetMuscles: targetMuscles ?? this.targetMuscles,
      equipment: equipment ?? this.equipment,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      duration: duration ?? this.duration,
    );
  }
} 