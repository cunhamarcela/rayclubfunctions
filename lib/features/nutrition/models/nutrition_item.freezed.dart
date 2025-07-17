// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NutritionItem _$NutritionItemFromJson(Map<String, dynamic> json) {
  return _NutritionItem.fromJson(json);
}

/// @nodoc
mixin _$NutritionItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  int get preparationTimeMinutes => throw _privateConstructorUsedError;
  List<String>? get ingredients => throw _privateConstructorUsedError;
  List<String>? get instructions => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  String? get nutritionistTip => throw _privateConstructorUsedError;

  /// Serializes this NutritionItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NutritionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NutritionItemCopyWith<NutritionItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NutritionItemCopyWith<$Res> {
  factory $NutritionItemCopyWith(
          NutritionItem value, $Res Function(NutritionItem) then) =
      _$NutritionItemCopyWithImpl<$Res, NutritionItem>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      String imageUrl,
      int preparationTimeMinutes,
      List<String>? ingredients,
      List<String>? instructions,
      List<String> tags,
      String? nutritionistTip});
}

/// @nodoc
class _$NutritionItemCopyWithImpl<$Res, $Val extends NutritionItem>
    implements $NutritionItemCopyWith<$Res> {
  _$NutritionItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NutritionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? imageUrl = null,
    Object? preparationTimeMinutes = null,
    Object? ingredients = freezed,
    Object? instructions = freezed,
    Object? tags = null,
    Object? nutritionistTip = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      preparationTimeMinutes: null == preparationTimeMinutes
          ? _value.preparationTimeMinutes
          : preparationTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      ingredients: freezed == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      nutritionistTip: freezed == nutritionistTip
          ? _value.nutritionistTip
          : nutritionistTip // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NutritionItemImplCopyWith<$Res>
    implements $NutritionItemCopyWith<$Res> {
  factory _$$NutritionItemImplCopyWith(
          _$NutritionItemImpl value, $Res Function(_$NutritionItemImpl) then) =
      __$$NutritionItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      String imageUrl,
      int preparationTimeMinutes,
      List<String>? ingredients,
      List<String>? instructions,
      List<String> tags,
      String? nutritionistTip});
}

/// @nodoc
class __$$NutritionItemImplCopyWithImpl<$Res>
    extends _$NutritionItemCopyWithImpl<$Res, _$NutritionItemImpl>
    implements _$$NutritionItemImplCopyWith<$Res> {
  __$$NutritionItemImplCopyWithImpl(
      _$NutritionItemImpl _value, $Res Function(_$NutritionItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of NutritionItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? imageUrl = null,
    Object? preparationTimeMinutes = null,
    Object? ingredients = freezed,
    Object? instructions = freezed,
    Object? tags = null,
    Object? nutritionistTip = freezed,
  }) {
    return _then(_$NutritionItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      preparationTimeMinutes: null == preparationTimeMinutes
          ? _value.preparationTimeMinutes
          : preparationTimeMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      ingredients: freezed == ingredients
          ? _value._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      instructions: freezed == instructions
          ? _value._instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      nutritionistTip: freezed == nutritionistTip
          ? _value.nutritionistTip
          : nutritionistTip // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NutritionItemImpl implements _NutritionItem {
  const _$NutritionItemImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.category,
      required this.imageUrl,
      required this.preparationTimeMinutes,
      final List<String>? ingredients,
      final List<String>? instructions,
      required final List<String> tags,
      this.nutritionistTip})
      : _ingredients = ingredients,
        _instructions = instructions,
        _tags = tags;

  factory _$NutritionItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$NutritionItemImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String category;
  @override
  final String imageUrl;
  @override
  final int preparationTimeMinutes;
  final List<String>? _ingredients;
  @override
  List<String>? get ingredients {
    final value = _ingredients;
    if (value == null) return null;
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _instructions;
  @override
  List<String>? get instructions {
    final value = _instructions;
    if (value == null) return null;
    if (_instructions is EqualUnmodifiableListView) return _instructions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final String? nutritionistTip;

  @override
  String toString() {
    return 'NutritionItem(id: $id, title: $title, description: $description, category: $category, imageUrl: $imageUrl, preparationTimeMinutes: $preparationTimeMinutes, ingredients: $ingredients, instructions: $instructions, tags: $tags, nutritionistTip: $nutritionistTip)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NutritionItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.preparationTimeMinutes, preparationTimeMinutes) ||
                other.preparationTimeMinutes == preparationTimeMinutes) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            const DeepCollectionEquality()
                .equals(other._instructions, _instructions) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.nutritionistTip, nutritionistTip) ||
                other.nutritionistTip == nutritionistTip));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      category,
      imageUrl,
      preparationTimeMinutes,
      const DeepCollectionEquality().hash(_ingredients),
      const DeepCollectionEquality().hash(_instructions),
      const DeepCollectionEquality().hash(_tags),
      nutritionistTip);

  /// Create a copy of NutritionItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NutritionItemImplCopyWith<_$NutritionItemImpl> get copyWith =>
      __$$NutritionItemImplCopyWithImpl<_$NutritionItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NutritionItemImplToJson(
      this,
    );
  }
}

abstract class _NutritionItem implements NutritionItem {
  const factory _NutritionItem(
      {required final String id,
      required final String title,
      required final String description,
      required final String category,
      required final String imageUrl,
      required final int preparationTimeMinutes,
      final List<String>? ingredients,
      final List<String>? instructions,
      required final List<String> tags,
      final String? nutritionistTip}) = _$NutritionItemImpl;

  factory _NutritionItem.fromJson(Map<String, dynamic> json) =
      _$NutritionItemImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  String get imageUrl;
  @override
  int get preparationTimeMinutes;
  @override
  List<String>? get ingredients;
  @override
  List<String>? get instructions;
  @override
  List<String> get tags;
  @override
  String? get nutritionistTip;

  /// Create a copy of NutritionItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NutritionItemImplCopyWith<_$NutritionItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
