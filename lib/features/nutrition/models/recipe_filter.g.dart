// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_filter.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecipeFilterImpl _$$RecipeFilterImplFromJson(Map<String, dynamic> json) =>
    _$RecipeFilterImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: $enumDecode(_$RecipeFilterCategoryEnumMap, json['category']),
      isSelected: json['isSelected'] as bool? ?? false,
    );

Map<String, dynamic> _$$RecipeFilterImplToJson(_$RecipeFilterImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': _$RecipeFilterCategoryEnumMap[instance.category]!,
      'isSelected': instance.isSelected,
    };

const _$RecipeFilterCategoryEnumMap = {
  RecipeFilterCategory.favoritas: 'favoritas',
  RecipeFilterCategory.objetivo: 'objetivo',
  RecipeFilterCategory.paladar: 'paladar',
  RecipeFilterCategory.refeicao: 'refeicao',
  RecipeFilterCategory.timing: 'timing',
  RecipeFilterCategory.macronutrientes: 'macronutrientes',
  RecipeFilterCategory.outros: 'outros',
};

_$RecipeFilterStateImpl _$$RecipeFilterStateImplFromJson(
        Map<String, dynamic> json) =>
    _$RecipeFilterStateImpl(
      availableFilters: (json['availableFilters'] as List<dynamic>?)
              ?.map((e) => RecipeFilter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      selectedFilters: (json['selectedFilters'] as List<dynamic>?)
              ?.map((e) => RecipeFilter.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$$RecipeFilterStateImplToJson(
        _$RecipeFilterStateImpl instance) =>
    <String, dynamic>{
      'availableFilters':
          instance.availableFilters.map((e) => e.toJson()).toList(),
      'selectedFilters':
          instance.selectedFilters.map((e) => e.toJson()).toList(),
      'isLoading': instance.isLoading,
      if (instance.errorMessage case final value?) 'errorMessage': value,
    };
