// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/workout/models/exercise.dart';

part 'workout_section_model.freezed.dart';
part 'workout_section_model.g.dart';

/// Modelo para representar uma seção de exercícios (aquecimento, principal, etc.)
@freezed
class WorkoutSection with _$WorkoutSection {
  const factory WorkoutSection({
    /// Nome da seção
    required String name,
    
    /// Descrição da seção (opcional)
    String? description,
    
    /// Ordem da seção no treino
    @Default(0) int order,
    
    /// Lista de exercícios na seção
    required List<Exercise> exercises,
    
    /// Tempo estimado em minutos para esta seção
    @Default(0) int estimatedTimeMinutes,
  }) = _WorkoutSection;

  /// Cria um WorkoutSection a partir de um mapa JSON
  factory WorkoutSection.fromJson(Map<String, dynamic> json) => _$WorkoutSectionFromJson(json);
} 
