// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_member.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) {
  return _GroupMember.fromJson(json);
}

/// @nodoc
mixin _$GroupMember {
  /// ID do usuário
  String get userId => throw _privateConstructorUsedError;

  /// Nome de exibição do usuário
  String get userDisplayName => throw _privateConstructorUsedError;

  /// Avatar URL do usuário (opcional)
  String? get userAvatarUrl => throw _privateConstructorUsedError;

  /// ID do grupo ao qual pertence
  String get groupId => throw _privateConstructorUsedError;

  /// Indica se o usuário é o criador do grupo
  bool get isCreator => throw _privateConstructorUsedError;

  /// Data em que o usuário entrou no grupo
  DateTime? get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this GroupMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupMemberCopyWith<GroupMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupMemberCopyWith<$Res> {
  factory $GroupMemberCopyWith(
          GroupMember value, $Res Function(GroupMember) then) =
      _$GroupMemberCopyWithImpl<$Res, GroupMember>;
  @useResult
  $Res call(
      {String userId,
      String userDisplayName,
      String? userAvatarUrl,
      String groupId,
      bool isCreator,
      DateTime? joinedAt});
}

/// @nodoc
class _$GroupMemberCopyWithImpl<$Res, $Val extends GroupMember>
    implements $GroupMemberCopyWith<$Res> {
  _$GroupMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userDisplayName = null,
    Object? userAvatarUrl = freezed,
    Object? groupId = null,
    Object? isCreator = null,
    Object? joinedAt = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userDisplayName: null == userDisplayName
          ? _value.userDisplayName
          : userDisplayName // ignore: cast_nullable_to_non_nullable
              as String,
      userAvatarUrl: freezed == userAvatarUrl
          ? _value.userAvatarUrl
          : userAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      isCreator: null == isCreator
          ? _value.isCreator
          : isCreator // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupMemberImplCopyWith<$Res>
    implements $GroupMemberCopyWith<$Res> {
  factory _$$GroupMemberImplCopyWith(
          _$GroupMemberImpl value, $Res Function(_$GroupMemberImpl) then) =
      __$$GroupMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String userId,
      String userDisplayName,
      String? userAvatarUrl,
      String groupId,
      bool isCreator,
      DateTime? joinedAt});
}

/// @nodoc
class __$$GroupMemberImplCopyWithImpl<$Res>
    extends _$GroupMemberCopyWithImpl<$Res, _$GroupMemberImpl>
    implements _$$GroupMemberImplCopyWith<$Res> {
  __$$GroupMemberImplCopyWithImpl(
      _$GroupMemberImpl _value, $Res Function(_$GroupMemberImpl) _then)
      : super(_value, _then);

  /// Create a copy of GroupMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userDisplayName = null,
    Object? userAvatarUrl = freezed,
    Object? groupId = null,
    Object? isCreator = null,
    Object? joinedAt = freezed,
  }) {
    return _then(_$GroupMemberImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userDisplayName: null == userDisplayName
          ? _value.userDisplayName
          : userDisplayName // ignore: cast_nullable_to_non_nullable
              as String,
      userAvatarUrl: freezed == userAvatarUrl
          ? _value.userAvatarUrl
          : userAvatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      isCreator: null == isCreator
          ? _value.isCreator
          : isCreator // ignore: cast_nullable_to_non_nullable
              as bool,
      joinedAt: freezed == joinedAt
          ? _value.joinedAt
          : joinedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupMemberImpl implements _GroupMember {
  const _$GroupMemberImpl(
      {required this.userId,
      required this.userDisplayName,
      this.userAvatarUrl,
      required this.groupId,
      this.isCreator = false,
      this.joinedAt});

  factory _$GroupMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupMemberImplFromJson(json);

  /// ID do usuário
  @override
  final String userId;

  /// Nome de exibição do usuário
  @override
  final String userDisplayName;

  /// Avatar URL do usuário (opcional)
  @override
  final String? userAvatarUrl;

  /// ID do grupo ao qual pertence
  @override
  final String groupId;

  /// Indica se o usuário é o criador do grupo
  @override
  @JsonKey()
  final bool isCreator;

  /// Data em que o usuário entrou no grupo
  @override
  final DateTime? joinedAt;

  @override
  String toString() {
    return 'GroupMember(userId: $userId, userDisplayName: $userDisplayName, userAvatarUrl: $userAvatarUrl, groupId: $groupId, isCreator: $isCreator, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupMemberImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userDisplayName, userDisplayName) ||
                other.userDisplayName == userDisplayName) &&
            (identical(other.userAvatarUrl, userAvatarUrl) ||
                other.userAvatarUrl == userAvatarUrl) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.isCreator, isCreator) ||
                other.isCreator == isCreator) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, userDisplayName,
      userAvatarUrl, groupId, isCreator, joinedAt);

  /// Create a copy of GroupMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupMemberImplCopyWith<_$GroupMemberImpl> get copyWith =>
      __$$GroupMemberImplCopyWithImpl<_$GroupMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupMemberImplToJson(
      this,
    );
  }
}

abstract class _GroupMember implements GroupMember {
  const factory _GroupMember(
      {required final String userId,
      required final String userDisplayName,
      final String? userAvatarUrl,
      required final String groupId,
      final bool isCreator,
      final DateTime? joinedAt}) = _$GroupMemberImpl;

  factory _GroupMember.fromJson(Map<String, dynamic> json) =
      _$GroupMemberImpl.fromJson;

  /// ID do usuário
  @override
  String get userId;

  /// Nome de exibição do usuário
  @override
  String get userDisplayName;

  /// Avatar URL do usuário (opcional)
  @override
  String? get userAvatarUrl;

  /// ID do grupo ao qual pertence
  @override
  String get groupId;

  /// Indica se o usuário é o criador do grupo
  @override
  bool get isCreator;

  /// Data em que o usuário entrou no grupo
  @override
  DateTime? get joinedAt;

  /// Create a copy of GroupMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupMemberImplCopyWith<_$GroupMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
