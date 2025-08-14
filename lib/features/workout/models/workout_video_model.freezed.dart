// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_video_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WorkoutVideo _$WorkoutVideoFromJson(Map<String, dynamic> json) {
  return _WorkoutVideo.fromJson(json);
}

/// @nodoc
mixin _$WorkoutVideo {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get duration => throw _privateConstructorUsedError;
  @JsonKey(name: 'youtube_url')
  String? get youtubeUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'instructor_name')
  String? get instructorName => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get difficulty => throw _privateConstructorUsedError;
  @JsonKey(name: 'order_index')
  int? get orderIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_new')
  bool get isNew => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_popular')
  bool get isPopular => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_recommended')
  bool get isRecommended => throw _privateConstructorUsedError;
  @JsonKey(name: 'requires_expert_access')
  bool get requiresExpertAccess => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt =>
      throw _privateConstructorUsedError; // ✨ NOVO: Suporte a PDFs
  @JsonKey(name: 'has_pdf_materials')
  bool get hasPdfMaterials =>
      throw _privateConstructorUsedError; // ✨ NOVO: Subcategoria (para fisioterapia: testes, mobilidade, estabilidade)
  String? get subcategory => throw _privateConstructorUsedError;

  /// Serializes this WorkoutVideo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutVideo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutVideoCopyWith<WorkoutVideo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutVideoCopyWith<$Res> {
  factory $WorkoutVideoCopyWith(
          WorkoutVideo value, $Res Function(WorkoutVideo) then) =
      _$WorkoutVideoCopyWithImpl<$Res, WorkoutVideo>;
  @useResult
  $Res call(
      {String id,
      String title,
      String duration,
      @JsonKey(name: 'youtube_url') String? youtubeUrl,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      String category,
      @JsonKey(name: 'instructor_name') String? instructorName,
      String? description,
      String? difficulty,
      @JsonKey(name: 'order_index') int? orderIndex,
      @JsonKey(name: 'is_new') bool isNew,
      @JsonKey(name: 'is_popular') bool isPopular,
      @JsonKey(name: 'is_recommended') bool isRecommended,
      @JsonKey(name: 'requires_expert_access') bool requiresExpertAccess,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'has_pdf_materials') bool hasPdfMaterials,
      String? subcategory});
}

/// @nodoc
class _$WorkoutVideoCopyWithImpl<$Res, $Val extends WorkoutVideo>
    implements $WorkoutVideoCopyWith<$Res> {
  _$WorkoutVideoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutVideo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? duration = null,
    Object? youtubeUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? category = null,
    Object? instructorName = freezed,
    Object? description = freezed,
    Object? difficulty = freezed,
    Object? orderIndex = freezed,
    Object? isNew = null,
    Object? isPopular = null,
    Object? isRecommended = null,
    Object? requiresExpertAccess = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? hasPdfMaterials = null,
    Object? subcategory = freezed,
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
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      youtubeUrl: freezed == youtubeUrl
          ? _value.youtubeUrl
          : youtubeUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      instructorName: freezed == instructorName
          ? _value.instructorName
          : instructorName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      orderIndex: freezed == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      isRecommended: null == isRecommended
          ? _value.isRecommended
          : isRecommended // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresExpertAccess: null == requiresExpertAccess
          ? _value.requiresExpertAccess
          : requiresExpertAccess // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasPdfMaterials: null == hasPdfMaterials
          ? _value.hasPdfMaterials
          : hasPdfMaterials // ignore: cast_nullable_to_non_nullable
              as bool,
      subcategory: freezed == subcategory
          ? _value.subcategory
          : subcategory // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutVideoImplCopyWith<$Res>
    implements $WorkoutVideoCopyWith<$Res> {
  factory _$$WorkoutVideoImplCopyWith(
          _$WorkoutVideoImpl value, $Res Function(_$WorkoutVideoImpl) then) =
      __$$WorkoutVideoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String duration,
      @JsonKey(name: 'youtube_url') String? youtubeUrl,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      String category,
      @JsonKey(name: 'instructor_name') String? instructorName,
      String? description,
      String? difficulty,
      @JsonKey(name: 'order_index') int? orderIndex,
      @JsonKey(name: 'is_new') bool isNew,
      @JsonKey(name: 'is_popular') bool isPopular,
      @JsonKey(name: 'is_recommended') bool isRecommended,
      @JsonKey(name: 'requires_expert_access') bool requiresExpertAccess,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt,
      @JsonKey(name: 'has_pdf_materials') bool hasPdfMaterials,
      String? subcategory});
}

/// @nodoc
class __$$WorkoutVideoImplCopyWithImpl<$Res>
    extends _$WorkoutVideoCopyWithImpl<$Res, _$WorkoutVideoImpl>
    implements _$$WorkoutVideoImplCopyWith<$Res> {
  __$$WorkoutVideoImplCopyWithImpl(
      _$WorkoutVideoImpl _value, $Res Function(_$WorkoutVideoImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutVideo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? duration = null,
    Object? youtubeUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? category = null,
    Object? instructorName = freezed,
    Object? description = freezed,
    Object? difficulty = freezed,
    Object? orderIndex = freezed,
    Object? isNew = null,
    Object? isPopular = null,
    Object? isRecommended = null,
    Object? requiresExpertAccess = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? hasPdfMaterials = null,
    Object? subcategory = freezed,
  }) {
    return _then(_$WorkoutVideoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      youtubeUrl: freezed == youtubeUrl
          ? _value.youtubeUrl
          : youtubeUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      instructorName: freezed == instructorName
          ? _value.instructorName
          : instructorName // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      difficulty: freezed == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String?,
      orderIndex: freezed == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      isNew: null == isNew
          ? _value.isNew
          : isNew // ignore: cast_nullable_to_non_nullable
              as bool,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      isRecommended: null == isRecommended
          ? _value.isRecommended
          : isRecommended // ignore: cast_nullable_to_non_nullable
              as bool,
      requiresExpertAccess: null == requiresExpertAccess
          ? _value.requiresExpertAccess
          : requiresExpertAccess // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasPdfMaterials: null == hasPdfMaterials
          ? _value.hasPdfMaterials
          : hasPdfMaterials // ignore: cast_nullable_to_non_nullable
              as bool,
      subcategory: freezed == subcategory
          ? _value.subcategory
          : subcategory // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutVideoImpl implements _WorkoutVideo {
  const _$WorkoutVideoImpl(
      {required this.id,
      required this.title,
      required this.duration,
      @JsonKey(name: 'youtube_url') this.youtubeUrl,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
      required this.category,
      @JsonKey(name: 'instructor_name') this.instructorName,
      this.description,
      this.difficulty,
      @JsonKey(name: 'order_index') this.orderIndex,
      @JsonKey(name: 'is_new') this.isNew = false,
      @JsonKey(name: 'is_popular') this.isPopular = false,
      @JsonKey(name: 'is_recommended') this.isRecommended = false,
      @JsonKey(name: 'requires_expert_access')
      this.requiresExpertAccess = false,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt,
      @JsonKey(name: 'has_pdf_materials') this.hasPdfMaterials = false,
      this.subcategory});

  factory _$WorkoutVideoImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutVideoImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String duration;
  @override
  @JsonKey(name: 'youtube_url')
  final String? youtubeUrl;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  final String category;
  @override
  @JsonKey(name: 'instructor_name')
  final String? instructorName;
  @override
  final String? description;
  @override
  final String? difficulty;
  @override
  @JsonKey(name: 'order_index')
  final int? orderIndex;
  @override
  @JsonKey(name: 'is_new')
  final bool isNew;
  @override
  @JsonKey(name: 'is_popular')
  final bool isPopular;
  @override
  @JsonKey(name: 'is_recommended')
  final bool isRecommended;
  @override
  @JsonKey(name: 'requires_expert_access')
  final bool requiresExpertAccess;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
// ✨ NOVO: Suporte a PDFs
  @override
  @JsonKey(name: 'has_pdf_materials')
  final bool hasPdfMaterials;
// ✨ NOVO: Subcategoria (para fisioterapia: testes, mobilidade, estabilidade)
  @override
  final String? subcategory;

  @override
  String toString() {
    return 'WorkoutVideo(id: $id, title: $title, duration: $duration, youtubeUrl: $youtubeUrl, thumbnailUrl: $thumbnailUrl, category: $category, instructorName: $instructorName, description: $description, difficulty: $difficulty, orderIndex: $orderIndex, isNew: $isNew, isPopular: $isPopular, isRecommended: $isRecommended, requiresExpertAccess: $requiresExpertAccess, createdAt: $createdAt, updatedAt: $updatedAt, hasPdfMaterials: $hasPdfMaterials, subcategory: $subcategory)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutVideoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.youtubeUrl, youtubeUrl) ||
                other.youtubeUrl == youtubeUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.instructorName, instructorName) ||
                other.instructorName == instructorName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.isNew, isNew) || other.isNew == isNew) &&
            (identical(other.isPopular, isPopular) ||
                other.isPopular == isPopular) &&
            (identical(other.isRecommended, isRecommended) ||
                other.isRecommended == isRecommended) &&
            (identical(other.requiresExpertAccess, requiresExpertAccess) ||
                other.requiresExpertAccess == requiresExpertAccess) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.hasPdfMaterials, hasPdfMaterials) ||
                other.hasPdfMaterials == hasPdfMaterials) &&
            (identical(other.subcategory, subcategory) ||
                other.subcategory == subcategory));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      duration,
      youtubeUrl,
      thumbnailUrl,
      category,
      instructorName,
      description,
      difficulty,
      orderIndex,
      isNew,
      isPopular,
      isRecommended,
      requiresExpertAccess,
      createdAt,
      updatedAt,
      hasPdfMaterials,
      subcategory);

  /// Create a copy of WorkoutVideo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutVideoImplCopyWith<_$WorkoutVideoImpl> get copyWith =>
      __$$WorkoutVideoImplCopyWithImpl<_$WorkoutVideoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutVideoImplToJson(
      this,
    );
  }
}

abstract class _WorkoutVideo implements WorkoutVideo {
  const factory _WorkoutVideo(
      {required final String id,
      required final String title,
      required final String duration,
      @JsonKey(name: 'youtube_url') final String? youtubeUrl,
      @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
      required final String category,
      @JsonKey(name: 'instructor_name') final String? instructorName,
      final String? description,
      final String? difficulty,
      @JsonKey(name: 'order_index') final int? orderIndex,
      @JsonKey(name: 'is_new') final bool isNew,
      @JsonKey(name: 'is_popular') final bool isPopular,
      @JsonKey(name: 'is_recommended') final bool isRecommended,
      @JsonKey(name: 'requires_expert_access') final bool requiresExpertAccess,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt,
      @JsonKey(name: 'has_pdf_materials') final bool hasPdfMaterials,
      final String? subcategory}) = _$WorkoutVideoImpl;

  factory _WorkoutVideo.fromJson(Map<String, dynamic> json) =
      _$WorkoutVideoImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get duration;
  @override
  @JsonKey(name: 'youtube_url')
  String? get youtubeUrl;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  String get category;
  @override
  @JsonKey(name: 'instructor_name')
  String? get instructorName;
  @override
  String? get description;
  @override
  String? get difficulty;
  @override
  @JsonKey(name: 'order_index')
  int? get orderIndex;
  @override
  @JsonKey(name: 'is_new')
  bool get isNew;
  @override
  @JsonKey(name: 'is_popular')
  bool get isPopular;
  @override
  @JsonKey(name: 'is_recommended')
  bool get isRecommended;
  @override
  @JsonKey(name: 'requires_expert_access')
  bool get requiresExpertAccess;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt; // ✨ NOVO: Suporte a PDFs
  @override
  @JsonKey(name: 'has_pdf_materials')
  bool
      get hasPdfMaterials; // ✨ NOVO: Subcategoria (para fisioterapia: testes, mobilidade, estabilidade)
  @override
  String? get subcategory;

  /// Create a copy of WorkoutVideo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutVideoImplCopyWith<_$WorkoutVideoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
