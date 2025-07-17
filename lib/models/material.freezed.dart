// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'material.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Material _$MaterialFromJson(Map<String, dynamic> json) {
  return _Material.fromJson(json);
}

/// @nodoc
mixin _$Material {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'material_type')
  MaterialType get materialType => throw _privateConstructorUsedError;
  @JsonKey(name: 'material_context')
  MaterialContext get materialContext => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_path')
  String get filePath => throw _privateConstructorUsedError;
  @JsonKey(name: 'file_size')
  int? get fileSize => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_name')
  String? get authorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'workout_video_id')
  String? get workoutVideoId =>
      throw _privateConstructorUsedError; // Para PDFs específicos de treinos
  @JsonKey(name: 'order_index')
  int? get orderIndex => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_featured')
  bool get isFeatured => throw _privateConstructorUsedError;
  @JsonKey(name: 'requires_expert_access')
  bool get requiresExpertAccess => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Material to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Material
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MaterialCopyWith<Material> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MaterialCopyWith<$Res> {
  factory $MaterialCopyWith(Material value, $Res Function(Material) then) =
      _$MaterialCopyWithImpl<$Res, Material>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      @JsonKey(name: 'material_type') MaterialType materialType,
      @JsonKey(name: 'material_context') MaterialContext materialContext,
      @JsonKey(name: 'file_path') String filePath,
      @JsonKey(name: 'file_size') int? fileSize,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'author_name') String? authorName,
      @JsonKey(name: 'workout_video_id') String? workoutVideoId,
      @JsonKey(name: 'order_index') int? orderIndex,
      @JsonKey(name: 'is_featured') bool isFeatured,
      @JsonKey(name: 'requires_expert_access') bool requiresExpertAccess,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class _$MaterialCopyWithImpl<$Res, $Val extends Material>
    implements $MaterialCopyWith<$Res> {
  _$MaterialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Material
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? materialType = null,
    Object? materialContext = null,
    Object? filePath = null,
    Object? fileSize = freezed,
    Object? thumbnailUrl = freezed,
    Object? authorName = freezed,
    Object? workoutVideoId = freezed,
    Object? orderIndex = freezed,
    Object? isFeatured = null,
    Object? requiresExpertAccess = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      materialType: null == materialType
          ? _value.materialType
          : materialType // ignore: cast_nullable_to_non_nullable
              as MaterialType,
      materialContext: null == materialContext
          ? _value.materialContext
          : materialContext // ignore: cast_nullable_to_non_nullable
              as MaterialContext,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutVideoId: freezed == workoutVideoId
          ? _value.workoutVideoId
          : workoutVideoId // ignore: cast_nullable_to_non_nullable
              as String?,
      orderIndex: freezed == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MaterialImplCopyWith<$Res>
    implements $MaterialCopyWith<$Res> {
  factory _$$MaterialImplCopyWith(
          _$MaterialImpl value, $Res Function(_$MaterialImpl) then) =
      __$$MaterialImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      @JsonKey(name: 'material_type') MaterialType materialType,
      @JsonKey(name: 'material_context') MaterialContext materialContext,
      @JsonKey(name: 'file_path') String filePath,
      @JsonKey(name: 'file_size') int? fileSize,
      @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
      @JsonKey(name: 'author_name') String? authorName,
      @JsonKey(name: 'workout_video_id') String? workoutVideoId,
      @JsonKey(name: 'order_index') int? orderIndex,
      @JsonKey(name: 'is_featured') bool isFeatured,
      @JsonKey(name: 'requires_expert_access') bool requiresExpertAccess,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'updated_at') DateTime? updatedAt});
}

/// @nodoc
class __$$MaterialImplCopyWithImpl<$Res>
    extends _$MaterialCopyWithImpl<$Res, _$MaterialImpl>
    implements _$$MaterialImplCopyWith<$Res> {
  __$$MaterialImplCopyWithImpl(
      _$MaterialImpl _value, $Res Function(_$MaterialImpl) _then)
      : super(_value, _then);

  /// Create a copy of Material
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? materialType = null,
    Object? materialContext = null,
    Object? filePath = null,
    Object? fileSize = freezed,
    Object? thumbnailUrl = freezed,
    Object? authorName = freezed,
    Object? workoutVideoId = freezed,
    Object? orderIndex = freezed,
    Object? isFeatured = null,
    Object? requiresExpertAccess = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$MaterialImpl(
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
      materialType: null == materialType
          ? _value.materialType
          : materialType // ignore: cast_nullable_to_non_nullable
              as MaterialType,
      materialContext: null == materialContext
          ? _value.materialContext
          : materialContext // ignore: cast_nullable_to_non_nullable
              as MaterialContext,
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: freezed == fileSize
          ? _value.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      authorName: freezed == authorName
          ? _value.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      workoutVideoId: freezed == workoutVideoId
          ? _value.workoutVideoId
          : workoutVideoId // ignore: cast_nullable_to_non_nullable
              as String?,
      orderIndex: freezed == orderIndex
          ? _value.orderIndex
          : orderIndex // ignore: cast_nullable_to_non_nullable
              as int?,
      isFeatured: null == isFeatured
          ? _value.isFeatured
          : isFeatured // ignore: cast_nullable_to_non_nullable
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MaterialImpl implements _Material {
  const _$MaterialImpl(
      {required this.id,
      required this.title,
      required this.description,
      @JsonKey(name: 'material_type') required this.materialType,
      @JsonKey(name: 'material_context') required this.materialContext,
      @JsonKey(name: 'file_path') required this.filePath,
      @JsonKey(name: 'file_size') this.fileSize,
      @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
      @JsonKey(name: 'author_name') this.authorName,
      @JsonKey(name: 'workout_video_id') this.workoutVideoId,
      @JsonKey(name: 'order_index') this.orderIndex,
      @JsonKey(name: 'is_featured') this.isFeatured = false,
      @JsonKey(name: 'requires_expert_access')
      this.requiresExpertAccess = false,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'updated_at') this.updatedAt});

  factory _$MaterialImpl.fromJson(Map<String, dynamic> json) =>
      _$$MaterialImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  @JsonKey(name: 'material_type')
  final MaterialType materialType;
  @override
  @JsonKey(name: 'material_context')
  final MaterialContext materialContext;
  @override
  @JsonKey(name: 'file_path')
  final String filePath;
  @override
  @JsonKey(name: 'file_size')
  final int? fileSize;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  @JsonKey(name: 'author_name')
  final String? authorName;
  @override
  @JsonKey(name: 'workout_video_id')
  final String? workoutVideoId;
// Para PDFs específicos de treinos
  @override
  @JsonKey(name: 'order_index')
  final int? orderIndex;
  @override
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  @override
  @JsonKey(name: 'requires_expert_access')
  final bool requiresExpertAccess;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Material(id: $id, title: $title, description: $description, materialType: $materialType, materialContext: $materialContext, filePath: $filePath, fileSize: $fileSize, thumbnailUrl: $thumbnailUrl, authorName: $authorName, workoutVideoId: $workoutVideoId, orderIndex: $orderIndex, isFeatured: $isFeatured, requiresExpertAccess: $requiresExpertAccess, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MaterialImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.materialType, materialType) ||
                other.materialType == materialType) &&
            (identical(other.materialContext, materialContext) ||
                other.materialContext == materialContext) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.workoutVideoId, workoutVideoId) ||
                other.workoutVideoId == workoutVideoId) &&
            (identical(other.orderIndex, orderIndex) ||
                other.orderIndex == orderIndex) &&
            (identical(other.isFeatured, isFeatured) ||
                other.isFeatured == isFeatured) &&
            (identical(other.requiresExpertAccess, requiresExpertAccess) ||
                other.requiresExpertAccess == requiresExpertAccess) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      materialType,
      materialContext,
      filePath,
      fileSize,
      thumbnailUrl,
      authorName,
      workoutVideoId,
      orderIndex,
      isFeatured,
      requiresExpertAccess,
      createdAt,
      updatedAt);

  /// Create a copy of Material
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MaterialImplCopyWith<_$MaterialImpl> get copyWith =>
      __$$MaterialImplCopyWithImpl<_$MaterialImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MaterialImplToJson(
      this,
    );
  }
}

abstract class _Material implements Material {
  const factory _Material(
      {required final String id,
      required final String title,
      required final String description,
      @JsonKey(name: 'material_type') required final MaterialType materialType,
      @JsonKey(name: 'material_context')
      required final MaterialContext materialContext,
      @JsonKey(name: 'file_path') required final String filePath,
      @JsonKey(name: 'file_size') final int? fileSize,
      @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
      @JsonKey(name: 'author_name') final String? authorName,
      @JsonKey(name: 'workout_video_id') final String? workoutVideoId,
      @JsonKey(name: 'order_index') final int? orderIndex,
      @JsonKey(name: 'is_featured') final bool isFeatured,
      @JsonKey(name: 'requires_expert_access') final bool requiresExpertAccess,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'updated_at') final DateTime? updatedAt}) = _$MaterialImpl;

  factory _Material.fromJson(Map<String, dynamic> json) =
      _$MaterialImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  @JsonKey(name: 'material_type')
  MaterialType get materialType;
  @override
  @JsonKey(name: 'material_context')
  MaterialContext get materialContext;
  @override
  @JsonKey(name: 'file_path')
  String get filePath;
  @override
  @JsonKey(name: 'file_size')
  int? get fileSize;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  @JsonKey(name: 'author_name')
  String? get authorName;
  @override
  @JsonKey(name: 'workout_video_id')
  String? get workoutVideoId; // Para PDFs específicos de treinos
  @override
  @JsonKey(name: 'order_index')
  int? get orderIndex;
  @override
  @JsonKey(name: 'is_featured')
  bool get isFeatured;
  @override
  @JsonKey(name: 'requires_expert_access')
  bool get requiresExpertAccess;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of Material
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MaterialImplCopyWith<_$MaterialImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
