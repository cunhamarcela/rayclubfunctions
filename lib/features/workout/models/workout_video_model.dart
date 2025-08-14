import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_video_model.freezed.dart';
part 'workout_video_model.g.dart';

@freezed
class WorkoutVideo with _$WorkoutVideo {
  const factory WorkoutVideo({
    required String id,
    required String title,
    required String duration,
    @JsonKey(name: 'youtube_url') String? youtubeUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    required String category,
    @JsonKey(name: 'instructor_name') String? instructorName,
    String? description,
    String? difficulty,
    @JsonKey(name: 'order_index') int? orderIndex,
    @JsonKey(name: 'is_new') @Default(false) bool isNew,
    @JsonKey(name: 'is_popular') @Default(false) bool isPopular,
    @JsonKey(name: 'is_recommended') @Default(false) bool isRecommended,
    @JsonKey(name: 'requires_expert_access') @Default(false) bool requiresExpertAccess,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    
    // ✨ NOVO: Suporte a PDFs
    @JsonKey(name: 'has_pdf_materials') @Default(false) bool hasPdfMaterials,
    
         // ✨ NOVO: Subcategoria (para fisioterapia: testes, mobilidade, estabilidade)
     String? subcategory,
  }) = _WorkoutVideo;

  factory WorkoutVideo.fromJson(Map<String, dynamic> json) =>
      _$WorkoutVideoFromJson(json);
}

// Enum para categorias de treino
enum WorkoutCategory {
  strength('Força', 'strength'),
  bodybuilding('Musculação', 'bodybuilding'),
  pilates('Pilates', 'pilates'),
  functional('Funcional', 'functional'),
  running('Corrida', 'running'),
  physiotherapy('Fisioterapia', 'physiotherapy');

  final String label;
  final String value;
  const WorkoutCategory(this.label, this.value);

  static WorkoutCategory fromValue(String value) {
    return WorkoutCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => WorkoutCategory.strength,
    );
  }
} 