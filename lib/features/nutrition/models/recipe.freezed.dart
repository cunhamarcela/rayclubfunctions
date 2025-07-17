// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Recipe _$RecipeFromJson(Map<String, dynamic> json) {
  return _Recipe.fromJson(json);
}

/// @nodoc
mixin _$Recipe {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'preparation_time_minutes')
  int get preparationTimeMinutes => throw _privateConstructorUsedError;
  int get calories => throw _privateConstructorUsedError;
  int get servings => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  @JsonKey(name: 'content_type')
  RecipeContentType get contentType => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_name')
  String get authorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured')
  bool get isFeatured =>
      throw _privateConstructorUsedError; // Campos para conteúdo de texto
  List<String>? get ingredients => throw _privateConstructorUsedError;
  List<String>? get instructions => throw _privateConstructorUsedError;
  @JsonKey(name: 'nutritionist_tip')
  String? get nutritionistTip =>
      throw _privateConstructorUsedError; // Campos para conteúdo de vídeo
  @JsonKey(name: 'video_url')
  String? get videoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'video_id')
  String? get videoId => throw _privateConstructorUsedError;
  @JsonKey(name: 'video_duration')
  int? get videoDuration =>
      throw _privateConstructorUsedError; // Campos comuns - apenas dados reais da Bruna Braga
  List<String> get tags =>
      throw _privateConstructorUsedError; // Dados reais da Bruna Braga (sem macronutrientes detalhados fictícios)
// Apenas valor calórico total e informações de porção conforme documento
  @JsonKey(name: 'servings_text')
  String? get servingsText =>
      throw _privateConstructorUsedError; // "1 pessoa", "6 porções", etc.
  @JsonKey(name: 'preparation_time_text')
  String? get preparationTimeText =>
      throw _privateConstructorUsedError; // "5 minutos", "30 minutos", etc.
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Campo calculado dinamicamente no frontend (não salvo no banco)
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isFavorite => throw _privateConstructorUsedError;

  /// Serializes this Recipe to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecipeCopyWith<Recipe> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) then) =
      _$RecipeCopyWithImpl<$Res, Recipe>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      @JsonKey(name: 'image_url') String imageUrl,
      @JsonKey(name: 'preparation_time_minutes') int preparationTimeMinutes,
      int calories,
      int servings,
      String difficulty,
      double rating,
      @JsonKey(name: 'content_type') RecipeContentType contentType,
      @JsonKey(name: 'author_name') String authorName,
      @JsonKey(name: 'is_featured') bool isFeatured,
      List<String>? ingredients,
      List<String>? instructions,
      @JsonKey(name: 'nutritionist_tip') String? nutritionistTip,
      @JsonKey(name: 'video_url') String? videoUrl,
      @JsonKey(name: 'video_id') String? videoId,
      @JsonKey(name: 'video_duration') int? videoDuration,
      List<String> tags,
      @JsonKey(name: 'servings_text') String? servingsText,
      @JsonKey(name: 'preparation_time_text') String? preparationTimeText,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(includeFromJson: false, includeToJson: false) bool isFavorite});
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res, $Val extends Recipe>
    implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Recipe
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
    Object? calories = null,
    Object? servings = null,
    Object? difficulty = null,
    Object? rating = null,
    Object? contentType = null,
    Object? authorName = null,
    Object? isFeatured = null,
    Object? ingredients = freezed,
    Object? instructions = freezed,
    Object? nutritionistTip = freezed,
    Object? videoUrl = freezed,
    Object? videoId = freezed,
    Object? videoDuration = freezed,
    Object? tags = null,
    Object? servingsText = freezed,
    Object? preparationTimeText = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isFavorite = null,
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
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      servings: null == servings
          ? _value.servings
          : servings // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as RecipeContentType,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      ingredients: freezed == ingredients
          ? _value.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      instructions: freezed == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      nutritionistTip: freezed == nutritionistTip
          ? _value.nutritionistTip
          : nutritionistTip // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoId: freezed == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String?,
      videoDuration: freezed == videoDuration
          ? _value.videoDuration
          : videoDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      servingsText: freezed == servingsText
          ? _value.servingsText
          : servingsText // ignore: cast_nullable_to_non_nullable
              as String?,
      preparationTimeText: freezed == preparationTimeText
          ? _value.preparationTimeText
          : preparationTimeText // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecipeImplCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$$RecipeImplCopyWith(
          _$RecipeImpl value, $Res Function(_$RecipeImpl) then) =
      __$$RecipeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      @JsonKey(name: 'image_url') String imageUrl,
      @JsonKey(name: 'preparation_time_minutes') int preparationTimeMinutes,
      int calories,
      int servings,
      String difficulty,
      double rating,
      @JsonKey(name: 'content_type') RecipeContentType contentType,
      @JsonKey(name: 'author_name') String authorName,
      @JsonKey(name: 'is_featured') bool isFeatured,
      List<String>? ingredients,
      List<String>? instructions,
      @JsonKey(name: 'nutritionist_tip') String? nutritionistTip,
      @JsonKey(name: 'video_url') String? videoUrl,
      @JsonKey(name: 'video_id') String? videoId,
      @JsonKey(name: 'video_duration') int? videoDuration,
      List<String> tags,
      @JsonKey(name: 'servings_text') String? servingsText,
      @JsonKey(name: 'preparation_time_text') String? preparationTimeText,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt,
      @JsonKey(includeFromJson: false, includeToJson: false) bool isFavorite});
}

/// @nodoc
class __$$RecipeImplCopyWithImpl<$Res>
    extends _$RecipeCopyWithImpl<$Res, _$RecipeImpl>
    implements _$$RecipeImplCopyWith<$Res> {
  __$$RecipeImplCopyWithImpl(
      _$RecipeImpl _value, $Res Function(_$RecipeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Recipe
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
    Object? calories = null,
    Object? servings = null,
    Object? difficulty = null,
    Object? rating = null,
    Object? contentType = null,
    Object? authorName = null,
    Object? isFeatured = null,
    Object? ingredients = freezed,
    Object? instructions = freezed,
    Object? nutritionistTip = freezed,
    Object? videoUrl = freezed,
    Object? videoId = freezed,
    Object? videoDuration = freezed,
    Object? tags = null,
    Object? servingsText = freezed,
    Object? preparationTimeText = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? isFavorite = null,
  }) {
    return _then(_$RecipeImpl(
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
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
              as int,
      servings: null == servings
          ? _value.servings
          : servings // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      rating: null == rating
          ? _value.rating
          : rating // ignore: cast_nullable_to_non_nullable
              as double,
      contentType: null == contentType
          ? _value.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as RecipeContentType,
      authorName: null == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
              as bool,
      ingredients: freezed == ingredients
          ? _value._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      instructions: freezed == instructions
          ? _value._instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      nutritionistTip: freezed == nutritionistTip
          ? _value.nutritionistTip
          : nutritionistTip // ignore: cast_nullable_to_non_nullable
              as String?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoId: freezed == videoId
          ? _value.videoId
          : videoId // ignore: cast_nullable_to_non_nullable
              as String?,
      videoDuration: freezed == videoDuration
          ? _value.videoDuration
          : videoDuration // ignore: cast_nullable_to_non_nullable
              as int?,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      servingsText: freezed == servingsText
          ? _value.servingsText
          : servingsText // ignore: cast_nullable_to_non_nullable
              as String?,
      preparationTimeText: freezed == preparationTimeText
          ? _value.preparationTimeText
          : preparationTimeText // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecipeImpl implements _Recipe {
  const _$RecipeImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.category,
      @JsonKey(name: 'image_url') required this.imageUrl,
      @JsonKey(name: 'preparation_time_minutes')
      required this.preparationTimeMinutes,
      required this.calories,
      required this.servings,
      required this.difficulty,
      required this.rating,
      @JsonKey(name: 'content_type') required this.contentType,
      @JsonKey(name: 'author_name') required this.authorName,
      @JsonKey(name: 'is_featured') required this.isFeatured,
      final List<String>? ingredients,
      final List<String>? instructions,
      @JsonKey(name: 'nutritionist_tip') this.nutritionistTip,
      @JsonKey(name: 'video_url') this.videoUrl,
      @JsonKey(name: 'video_id') this.videoId,
      @JsonKey(name: 'video_duration') this.videoDuration,
      required final List<String> tags,
      @JsonKey(name: 'servings_text') this.servingsText,
      @JsonKey(name: 'preparation_time_text') this.preparationTimeText,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      this.isFavorite = false})
      : _ingredients = ingredients,
        _instructions = instructions,
        _tags = tags;

  factory _$RecipeImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecipeImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String category;
  @override
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @override
  @JsonKey(name: 'preparation_time_minutes')
  final int preparationTimeMinutes;
  @override
  final int calories;
  @override
  final int servings;
  @override
  final String difficulty;
  @override
  final double rating;
  @override
  @JsonKey(name: 'content_type')
  final RecipeContentType contentType;
  @override
  @JsonKey(name: 'author_name')
  final String authorName;
  @override
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
// Campos para conteúdo de texto
  final List<String>? _ingredients;
// Campos para conteúdo de texto
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

  @override
  @JsonKey(name: 'nutritionist_tip')
  final String? nutritionistTip;
// Campos para conteúdo de vídeo
  @override
  @JsonKey(name: 'video_url')
  final String? videoUrl;
  @override
  @JsonKey(name: 'video_id')
  final String? videoId;
  @override
  @JsonKey(name: 'video_duration')
  final int? videoDuration;
// Campos comuns - apenas dados reais da Bruna Braga
  final List<String> _tags;
// Campos comuns - apenas dados reais da Bruna Braga
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

// Dados reais da Bruna Braga (sem macronutrientes detalhados fictícios)
// Apenas valor calórico total e informações de porção conforme documento
  @override
  @JsonKey(name: 'servings_text')
  final String? servingsText;
// "1 pessoa", "6 porções", etc.
  @override
  @JsonKey(name: 'preparation_time_text')
  final String? preparationTimeText;
// "5 minutos", "30 minutos", etc.
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
// Campo calculado dinamicamente no frontend (não salvo no banco)
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isFavorite;

  @override
  String toString() {
    return 'Recipe(id: $id, title: $title, description: $description, category: $category, imageUrl: $imageUrl, preparationTimeMinutes: $preparationTimeMinutes, calories: $calories, servings: $servings, difficulty: $difficulty, rating: $rating, contentType: $contentType, authorName: $authorName, isFeatured: $isFeatured, ingredients: $ingredients, instructions: $instructions, nutritionistTip: $nutritionistTip, videoUrl: $videoUrl, videoId: $videoId, videoDuration: $videoDuration, tags: $tags, servingsText: $servingsText, preparationTimeText: $preparationTimeText, createdAt: $createdAt, updatedAt: $updatedAt, isFavorite: $isFavorite)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecipeImpl &&
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
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.servings, servings) ||
                other.servings == servings) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            const DeepCollectionEquality()
                .equals(other._instructions, _instructions) &&
            (identical(other.nutritionistTip, nutritionistTip) ||
                other.nutritionistTip == nutritionistTip) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.videoId, videoId) || other.videoId == videoId) &&
            (identical(other.videoDuration, videoDuration) ||
                other.videoDuration == videoDuration) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.servingsText, servingsText) ||
                other.servingsText == servingsText) &&
            (identical(other.preparationTimeText, preparationTimeText) ||
                other.preparationTimeText == preparationTimeText) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        category,
        imageUrl,
        preparationTimeMinutes,
        calories,
        servings,
        difficulty,
        rating,
        contentType,
        authorName,
        isFeatured,
        const DeepCollectionEquality().hash(_ingredients),
        const DeepCollectionEquality().hash(_instructions),
        nutritionistTip,
        videoUrl,
        videoId,
        videoDuration,
        const DeepCollectionEquality().hash(_tags),
        servingsText,
        preparationTimeText,
        createdAt,
        updatedAt,
        isFavorite
      ]);

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      __$$RecipeImplCopyWithImpl<_$RecipeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecipeImplToJson(
      this,
    );
  }
}

abstract class _Recipe implements Recipe {
  const factory _Recipe(
      {required final String id,
      required final String title,
      required final String description,
      required final String category,
      @JsonKey(name: 'image_url') required final String imageUrl,
      @JsonKey(name: 'preparation_time_minutes')
      required final int preparationTimeMinutes,
      required final int calories,
      required final int servings,
      required final String difficulty,
      required final double rating,
      @JsonKey(name: 'content_type')
      required final RecipeContentType contentType,
      @JsonKey(name: 'author_name') required final String authorName,
      @JsonKey(name: 'is_featured') required final bool isFeatured,
      final List<String>? ingredients,
      final List<String>? instructions,
      @JsonKey(name: 'nutritionist_tip') final String? nutritionistTip,
      @JsonKey(name: 'video_url') final String? videoUrl,
      @JsonKey(name: 'video_id') final String? videoId,
      @JsonKey(name: 'video_duration') final int? videoDuration,
      required final List<String> tags,
      @JsonKey(name: 'servings_text') final String? servingsText,
      @JsonKey(name: 'preparation_time_text') final String? preparationTimeText,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at') required final DateTime updatedAt,
      @JsonKey(includeFromJson: false, includeToJson: false)
      final bool isFavorite}) = _$RecipeImpl;

  factory _Recipe.fromJson(Map<String, dynamic> json) = _$RecipeImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  @JsonKey(name: 'image_url')
  String get imageUrl;
  @override
  @JsonKey(name: 'preparation_time_minutes')
  int get preparationTimeMinutes;
  @override
  int get calories;
  @override
  int get servings;
  @override
  String get difficulty;
  @override
  double get rating;
  @override
  @JsonKey(name: 'content_type')
  RecipeContentType get contentType;
  @override
  @JsonKey(name: 'author_name')
  String get authorName;
  @override
  @JsonKey(name: 'is_featured')
  bool get isFeatured; // Campos para conteúdo de texto
  @override
  List<String>? get ingredients;
  @override
  List<String>? get instructions;
  @override
  @JsonKey(name: 'nutritionist_tip')
  String? get nutritionistTip; // Campos para conteúdo de vídeo
  @override
  @JsonKey(name: 'video_url')
  String? get videoUrl;
  @override
  @JsonKey(name: 'video_id')
  String? get videoId;
  @override
  @JsonKey(name: 'video_duration')
  int? get videoDuration; // Campos comuns - apenas dados reais da Bruna Braga
  @override
  List<String>
      get tags; // Dados reais da Bruna Braga (sem macronutrientes detalhados fictícios)
// Apenas valor calórico total e informações de porção conforme documento
  @override
  @JsonKey(name: 'servings_text')
  String? get servingsText; // "1 pessoa", "6 porções", etc.
  @override
  @JsonKey(name: 'preparation_time_text')
  String? get preparationTimeText; // "5 minutos", "30 minutos", etc.
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime
      get updatedAt; // Campo calculado dinamicamente no frontend (não salvo no banco)
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get isFavorite;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecipeImplCopyWith<_$RecipeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
