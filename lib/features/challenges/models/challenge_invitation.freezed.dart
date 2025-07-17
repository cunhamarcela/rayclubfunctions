// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_invitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChallengeGroupInvite _$ChallengeGroupInviteFromJson(Map<String, dynamic> json) {
  return _ChallengeGroupInvite.fromJson(json);
}

/// @nodoc
mixin _$ChallengeGroupInvite {
  String get id => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  String get inviterId => throw _privateConstructorUsedError;
  String get inviteeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'status')
  int get statusCode => throw _privateConstructorUsedError;
  String? get groupName => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get respondedAt => throw _privateConstructorUsedError;

  /// Serializes this ChallengeGroupInvite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeGroupInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeGroupInviteCopyWith<ChallengeGroupInvite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeGroupInviteCopyWith<$Res> {
  factory $ChallengeGroupInviteCopyWith(ChallengeGroupInvite value,
          $Res Function(ChallengeGroupInvite) then) =
      _$ChallengeGroupInviteCopyWithImpl<$Res, ChallengeGroupInvite>;
  @useResult
  $Res call(
      {String id,
      String groupId,
      String inviterId,
      String inviteeId,
      @JsonKey(name: 'status') int statusCode,
      String? groupName,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? respondedAt});
}

/// @nodoc
class _$ChallengeGroupInviteCopyWithImpl<$Res,
        $Val extends ChallengeGroupInvite>
    implements $ChallengeGroupInviteCopyWith<$Res> {
  _$ChallengeGroupInviteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeGroupInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? inviterId = null,
    Object? inviteeId = null,
    Object? statusCode = null,
    Object? groupName = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? respondedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      inviterId: null == inviterId
          ? _value.inviterId
          : inviterId // ignore: cast_nullable_to_non_nullable
              as String,
      inviteeId: null == inviteeId
          ? _value.inviteeId
          : inviteeId // ignore: cast_nullable_to_non_nullable
              as String,
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      groupName: freezed == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      respondedAt: freezed == respondedAt
          ? _value.respondedAt
          : respondedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeGroupInviteImplCopyWith<$Res>
    implements $ChallengeGroupInviteCopyWith<$Res> {
  factory _$$ChallengeGroupInviteImplCopyWith(_$ChallengeGroupInviteImpl value,
          $Res Function(_$ChallengeGroupInviteImpl) then) =
      __$$ChallengeGroupInviteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String groupId,
      String inviterId,
      String inviteeId,
      @JsonKey(name: 'status') int statusCode,
      String? groupName,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? respondedAt});
}

/// @nodoc
class __$$ChallengeGroupInviteImplCopyWithImpl<$Res>
    extends _$ChallengeGroupInviteCopyWithImpl<$Res, _$ChallengeGroupInviteImpl>
    implements _$$ChallengeGroupInviteImplCopyWith<$Res> {
  __$$ChallengeGroupInviteImplCopyWithImpl(_$ChallengeGroupInviteImpl _value,
      $Res Function(_$ChallengeGroupInviteImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeGroupInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? groupId = null,
    Object? inviterId = null,
    Object? inviteeId = null,
    Object? statusCode = null,
    Object? groupName = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? respondedAt = freezed,
  }) {
    return _then(_$ChallengeGroupInviteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      inviterId: null == inviterId
          ? _value.inviterId
          : inviterId // ignore: cast_nullable_to_non_nullable
              as String,
      inviteeId: null == inviteeId
          ? _value.inviteeId
          : inviteeId // ignore: cast_nullable_to_non_nullable
              as String,
      statusCode: null == statusCode
          ? _value.statusCode
          : statusCode // ignore: cast_nullable_to_non_nullable
              as int,
      groupName: freezed == groupName
          ? _value.groupName
          : groupName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      respondedAt: freezed == respondedAt
          ? _value.respondedAt
          : respondedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeGroupInviteImpl extends _ChallengeGroupInvite {
  const _$ChallengeGroupInviteImpl(
      {required this.id,
      required this.groupId,
      required this.inviterId,
      required this.inviteeId,
      @JsonKey(name: 'status') required this.statusCode,
      this.groupName,
      this.createdAt,
      this.updatedAt,
      this.respondedAt})
      : super._();

  factory _$ChallengeGroupInviteImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeGroupInviteImplFromJson(json);

  @override
  final String id;
  @override
  final String groupId;
  @override
  final String inviterId;
  @override
  final String inviteeId;
  @override
  @JsonKey(name: 'status')
  final int statusCode;
  @override
  final String? groupName;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? respondedAt;

  @override
  String toString() {
    return 'ChallengeGroupInvite(id: $id, groupId: $groupId, inviterId: $inviterId, inviteeId: $inviteeId, statusCode: $statusCode, groupName: $groupName, createdAt: $createdAt, updatedAt: $updatedAt, respondedAt: $respondedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeGroupInviteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.inviterId, inviterId) ||
                other.inviterId == inviterId) &&
            (identical(other.inviteeId, inviteeId) ||
                other.inviteeId == inviteeId) &&
            (identical(other.statusCode, statusCode) ||
                other.statusCode == statusCode) &&
            (identical(other.groupName, groupName) ||
                other.groupName == groupName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, groupId, inviterId,
      inviteeId, statusCode, groupName, createdAt, updatedAt, respondedAt);

  /// Create a copy of ChallengeGroupInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeGroupInviteImplCopyWith<_$ChallengeGroupInviteImpl>
      get copyWith =>
          __$$ChallengeGroupInviteImplCopyWithImpl<_$ChallengeGroupInviteImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeGroupInviteImplToJson(
      this,
    );
  }
}

abstract class _ChallengeGroupInvite extends ChallengeGroupInvite {
  const factory _ChallengeGroupInvite(
      {required final String id,
      required final String groupId,
      required final String inviterId,
      required final String inviteeId,
      @JsonKey(name: 'status') required final int statusCode,
      final String? groupName,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final DateTime? respondedAt}) = _$ChallengeGroupInviteImpl;
  const _ChallengeGroupInvite._() : super._();

  factory _ChallengeGroupInvite.fromJson(Map<String, dynamic> json) =
      _$ChallengeGroupInviteImpl.fromJson;

  @override
  String get id;
  @override
  String get groupId;
  @override
  String get inviterId;
  @override
  String get inviteeId;
  @override
  @JsonKey(name: 'status')
  int get statusCode;
  @override
  String? get groupName;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get respondedAt;

  /// Create a copy of ChallengeGroupInvite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeGroupInviteImplCopyWith<_$ChallengeGroupInviteImpl>
      get copyWith => throw _privateConstructorUsedError;
}
