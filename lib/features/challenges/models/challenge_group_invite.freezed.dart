// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_group_invite.dart';

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
  /// ID único do convite
  String get id => throw _privateConstructorUsedError;

  /// ID do grupo para o qual o usuário foi convidado
  String get groupId => throw _privateConstructorUsedError;

  /// ID do usuário que enviou o convite
  String get inviterId => throw _privateConstructorUsedError;

  /// ID do usuário que foi convidado
  String get inviteeId => throw _privateConstructorUsedError;

  /// Status do convite
  InviteStatus get status => throw _privateConstructorUsedError;

  /// Data de criação do convite
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Data de resposta ao convite (null se ainda não respondido)
  DateTime? get respondedAt => throw _privateConstructorUsedError;

  /// Data de expiração do convite (opcional)
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Mensagem personalizada do convite (opcional)
  String? get message => throw _privateConstructorUsedError;

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
      InviteStatus status,
      DateTime createdAt,
      DateTime? respondedAt,
      DateTime? expiresAt,
      String? message});
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
    Object? status = null,
    Object? createdAt = null,
    Object? respondedAt = freezed,
    Object? expiresAt = freezed,
    Object? message = freezed,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as InviteStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      respondedAt: freezed == respondedAt
          ? _value.respondedAt
          : respondedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
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
      InviteStatus status,
      DateTime createdAt,
      DateTime? respondedAt,
      DateTime? expiresAt,
      String? message});
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
    Object? status = null,
    Object? createdAt = null,
    Object? respondedAt = freezed,
    Object? expiresAt = freezed,
    Object? message = freezed,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as InviteStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      respondedAt: freezed == respondedAt
          ? _value.respondedAt
          : respondedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
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
      this.status = InviteStatus.pending,
      required this.createdAt,
      this.respondedAt,
      this.expiresAt,
      this.message})
      : super._();

  factory _$ChallengeGroupInviteImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeGroupInviteImplFromJson(json);

  /// ID único do convite
  @override
  final String id;

  /// ID do grupo para o qual o usuário foi convidado
  @override
  final String groupId;

  /// ID do usuário que enviou o convite
  @override
  final String inviterId;

  /// ID do usuário que foi convidado
  @override
  final String inviteeId;

  /// Status do convite
  @override
  @JsonKey()
  final InviteStatus status;

  /// Data de criação do convite
  @override
  final DateTime createdAt;

  /// Data de resposta ao convite (null se ainda não respondido)
  @override
  final DateTime? respondedAt;

  /// Data de expiração do convite (opcional)
  @override
  final DateTime? expiresAt;

  /// Mensagem personalizada do convite (opcional)
  @override
  final String? message;

  @override
  String toString() {
    return 'ChallengeGroupInvite(id: $id, groupId: $groupId, inviterId: $inviterId, inviteeId: $inviteeId, status: $status, createdAt: $createdAt, respondedAt: $respondedAt, expiresAt: $expiresAt, message: $message)';
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
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, groupId, inviterId,
      inviteeId, status, createdAt, respondedAt, expiresAt, message);

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
      final InviteStatus status,
      required final DateTime createdAt,
      final DateTime? respondedAt,
      final DateTime? expiresAt,
      final String? message}) = _$ChallengeGroupInviteImpl;
  const _ChallengeGroupInvite._() : super._();

  factory _ChallengeGroupInvite.fromJson(Map<String, dynamic> json) =
      _$ChallengeGroupInviteImpl.fromJson;

  /// ID único do convite
  @override
  String get id;

  /// ID do grupo para o qual o usuário foi convidado
  @override
  String get groupId;

  /// ID do usuário que enviou o convite
  @override
  String get inviterId;

  /// ID do usuário que foi convidado
  @override
  String get inviteeId;

  /// Status do convite
  @override
  InviteStatus get status;

  /// Data de criação do convite
  @override
  DateTime get createdAt;

  /// Data de resposta ao convite (null se ainda não respondido)
  @override
  DateTime? get respondedAt;

  /// Data de expiração do convite (opcional)
  @override
  DateTime? get expiresAt;

  /// Mensagem personalizada do convite (opcional)
  @override
  String? get message;

  /// Create a copy of ChallengeGroupInvite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeGroupInviteImplCopyWith<_$ChallengeGroupInviteImpl>
      get copyWith => throw _privateConstructorUsedError;
}
