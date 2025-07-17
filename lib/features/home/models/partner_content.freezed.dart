// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PartnerContent _$PartnerContentFromJson(Map<String, dynamic> json) {
  return _PartnerContent.fromJson(json);
}

/// @nodoc
mixin _$PartnerContent {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get duration => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get studioId => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this PartnerContent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PartnerContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartnerContentCopyWith<PartnerContent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerContentCopyWith<$Res> {
  factory $PartnerContentCopyWith(
          PartnerContent value, $Res Function(PartnerContent) then) =
      _$PartnerContentCopyWithImpl<$Res, PartnerContent>;
  @useResult
  $Res call(
      {String id,
      String title,
      String duration,
      String difficulty,
      String imageUrl,
      String? studioId,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$PartnerContentCopyWithImpl<$Res, $Val extends PartnerContent>
    implements $PartnerContentCopyWith<$Res> {
  _$PartnerContentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartnerContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? duration = null,
    Object? difficulty = null,
    Object? imageUrl = null,
    Object? studioId = freezed,
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
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      studioId: freezed == studioId
          ? _value.studioId
          : studioId // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$PartnerContentImplCopyWith<$Res>
    implements $PartnerContentCopyWith<$Res> {
  factory _$$PartnerContentImplCopyWith(_$PartnerContentImpl value,
          $Res Function(_$PartnerContentImpl) then) =
      __$$PartnerContentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String duration,
      String difficulty,
      String imageUrl,
      String? studioId,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$PartnerContentImplCopyWithImpl<$Res>
    extends _$PartnerContentCopyWithImpl<$Res, _$PartnerContentImpl>
    implements _$$PartnerContentImplCopyWith<$Res> {
  __$$PartnerContentImplCopyWithImpl(
      _$PartnerContentImpl _value, $Res Function(_$PartnerContentImpl) _then)
      : super(_value, _then);

  /// Create a copy of PartnerContent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? duration = null,
    Object? difficulty = null,
    Object? imageUrl = null,
    Object? studioId = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PartnerContentImpl(
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
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      studioId: freezed == studioId
          ? _value.studioId
          : studioId // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$PartnerContentImpl implements _PartnerContent {
  const _$PartnerContentImpl(
      {required this.id,
      required this.title,
      required this.duration,
      required this.difficulty,
      required this.imageUrl,
      this.studioId,
      this.createdAt,
      this.updatedAt});

  factory _$PartnerContentImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartnerContentImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String duration;
  @override
  final String difficulty;
  @override
  final String imageUrl;
  @override
  final String? studioId;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'PartnerContent(id: $id, title: $title, duration: $duration, difficulty: $difficulty, imageUrl: $imageUrl, studioId: $studioId, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartnerContentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.studioId, studioId) ||
                other.studioId == studioId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, duration, difficulty,
      imageUrl, studioId, createdAt, updatedAt);

  /// Create a copy of PartnerContent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartnerContentImplCopyWith<_$PartnerContentImpl> get copyWith =>
      __$$PartnerContentImplCopyWithImpl<_$PartnerContentImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PartnerContentImplToJson(
      this,
    );
  }
}

abstract class _PartnerContent implements PartnerContent {
  const factory _PartnerContent(
      {required final String id,
      required final String title,
      required final String duration,
      required final String difficulty,
      required final String imageUrl,
      final String? studioId,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$PartnerContentImpl;

  factory _PartnerContent.fromJson(Map<String, dynamic> json) =
      _$PartnerContentImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get duration;
  @override
  String get difficulty;
  @override
  String get imageUrl;
  @override
  String? get studioId;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of PartnerContent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartnerContentImplCopyWith<_$PartnerContentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
