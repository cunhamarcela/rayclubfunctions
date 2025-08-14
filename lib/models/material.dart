import 'package:freezed_annotation/freezed_annotation.dart';

part 'material.freezed.dart';
part 'material.g.dart';

/// Tipos de material disponíveis
enum MaterialType {
  pdf,
  ebook,
  guide,
  document,
  video
}

/// Contexto do material (onde será usado)
enum MaterialContext {
  workout,
  nutrition,
  general
}

/// Modelo unificado para materiais (PDFs, ebooks, guias)
@freezed
class Material with _$Material {
  const factory Material({
    required String id,
    required String title,
    required String description,
    @JsonKey(name: 'material_type') required MaterialType materialType,
    @JsonKey(name: 'material_context') required MaterialContext materialContext,
    @JsonKey(name: 'file_path') required String filePath,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'author_name') String? authorName,
    @JsonKey(name: 'workout_video_id') String? workoutVideoId, // Para PDFs específicos de treinos
    @JsonKey(name: 'video_url') String? videoUrl, // Para materiais em vídeo
    @JsonKey(name: 'video_id') String? videoId, // ID do YouTube para vídeos
    @JsonKey(name: 'video_duration') int? videoDuration, // Duração em segundos
    @JsonKey(name: 'order_index') int? orderIndex,
    @JsonKey(name: 'is_featured') @Default(false) bool isFeatured,
    @JsonKey(name: 'requires_expert_access') @Default(false) bool requiresExpertAccess,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Material;

  factory Material.fromJson(Map<String, dynamic> json) => _$MaterialFromJson(json);
} 