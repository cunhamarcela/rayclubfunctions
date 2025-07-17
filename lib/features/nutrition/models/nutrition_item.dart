import 'package:freezed_annotation/freezed_annotation.dart';

part 'nutrition_item.freezed.dart';
part 'nutrition_item.g.dart';

@freezed
class NutritionItem with _$NutritionItem {
  const factory NutritionItem({
    required String id,
    required String title,
    required String description,
    required String category,
    required String imageUrl,
    required int preparationTimeMinutes,
    List<String>? ingredients,
    List<String>? instructions,
    required List<String> tags,
    String? nutritionistTip,
  }) = _NutritionItem;

  factory NutritionItem.fromJson(Map<String, dynamic> json) => _$NutritionItemFromJson(json);
} 