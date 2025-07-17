import 'package:freezed_annotation/freezed_annotation.dart';

part 'recipe.freezed.dart';
part 'recipe.g.dart';

enum RecipeContentType {
  text,
  video
}

@freezed
class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String title,
    required String description,
    required String category,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'preparation_time_minutes') required int preparationTimeMinutes,
    required int calories,
    required int servings,
    required String difficulty,
    required double rating,
    @JsonKey(name: 'content_type') required RecipeContentType contentType,
    @JsonKey(name: 'author_name') required String authorName,
    @JsonKey(name: 'is_featured') required bool isFeatured,
    
    // Campos para conteúdo de texto
    List<String>? ingredients,
    List<String>? instructions,
    @JsonKey(name: 'nutritionist_tip') String? nutritionistTip,
    
    // Campos para conteúdo de vídeo
    @JsonKey(name: 'video_url') String? videoUrl,
    @JsonKey(name: 'video_id') String? videoId,
    @JsonKey(name: 'video_duration') int? videoDuration,
    
    // Campos comuns - apenas dados reais da Bruna Braga
    required List<String> tags,
    
    // Dados reais da Bruna Braga (sem macronutrientes detalhados fictícios)
    // Apenas valor calórico total e informações de porção conforme documento
    @JsonKey(name: 'servings_text') String? servingsText, // "1 pessoa", "6 porções", etc.
    @JsonKey(name: 'preparation_time_text') String? preparationTimeText, // "5 minutos", "30 minutos", etc.
    
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    
    // Campo calculado dinamicamente no frontend (não salvo no banco)
    @JsonKey(includeFromJson: false, includeToJson: false) @Default(false) bool isFavorite,
  }) = _Recipe;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
} 