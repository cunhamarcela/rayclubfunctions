// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Challenge _$ChallengeFromJson(Map<String, dynamic> json) {
  return _Challenge.fromJson(json);
}

/// @nodoc
mixin _$Challenge {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get imageUrl =>
      throw _privateConstructorUsedError; // Field for local image path when uploading new images
  String? get localImagePath => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  List<String> get requirements => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  String? get creatorId =>
      throw _privateConstructorUsedError; // Modificado para nullable
  bool get isOfficial => throw _privateConstructorUsedError;
  List<String> get invitedUsers => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Challenge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeCopyWith<Challenge> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeCopyWith<$Res> {
  factory $ChallengeCopyWith(Challenge value, $Res Function(Challenge) then) =
      _$ChallengeCopyWithImpl<$Res, Challenge>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String? imageUrl,
      String? localImagePath,
      DateTime startDate,
      DateTime endDate,
      String type,
      int points,
      List<String> requirements,
      List<String> participants,
      bool active,
      String? creatorId,
      bool isOfficial,
      List<String> invitedUsers,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ChallengeCopyWithImpl<$Res, $Val extends Challenge>
    implements $ChallengeCopyWith<$Res> {
  _$ChallengeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? localImagePath = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? type = null,
    Object? points = null,
    Object? requirements = null,
    Object? participants = null,
    Object? active = null,
    Object? creatorId = freezed,
    Object? isOfficial = null,
    Object? invitedUsers = null,
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
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      localImagePath: freezed == localImagePath
          ? _value.localImagePath
          : localImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      requirements: null == requirements
          ? _value.requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      invitedUsers: null == invitedUsers
          ? _value.invitedUsers
          : invitedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
abstract class _$$ChallengeImplCopyWith<$Res>
    implements $ChallengeCopyWith<$Res> {
  factory _$$ChallengeImplCopyWith(
          _$ChallengeImpl value, $Res Function(_$ChallengeImpl) then) =
      __$$ChallengeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String? imageUrl,
      String? localImagePath,
      DateTime startDate,
      DateTime endDate,
      String type,
      int points,
      List<String> requirements,
      List<String> participants,
      bool active,
      String? creatorId,
      bool isOfficial,
      List<String> invitedUsers,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ChallengeImplCopyWithImpl<$Res>
    extends _$ChallengeCopyWithImpl<$Res, _$ChallengeImpl>
    implements _$$ChallengeImplCopyWith<$Res> {
  __$$ChallengeImplCopyWithImpl(
      _$ChallengeImpl _value, $Res Function(_$ChallengeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? localImagePath = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? type = null,
    Object? points = null,
    Object? requirements = null,
    Object? participants = null,
    Object? active = null,
    Object? creatorId = freezed,
    Object? isOfficial = null,
    Object? invitedUsers = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ChallengeImpl(
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
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      localImagePath: freezed == localImagePath
          ? _value.localImagePath
          : localImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      requirements: null == requirements
          ? _value._requirements
          : requirements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      creatorId: freezed == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String?,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      invitedUsers: null == invitedUsers
          ? _value._invitedUsers
          : invitedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
class _$ChallengeImpl extends _Challenge with DiagnosticableTreeMixin {
  const _$ChallengeImpl(
      {required this.id,
      required this.title,
      required this.description,
      this.imageUrl,
      this.localImagePath,
      required this.startDate,
      required this.endDate,
      this.type = 'normal',
      required this.points,
      final List<String> requirements = const [],
      final List<String> participants = const [],
      this.active = true,
      this.creatorId,
      this.isOfficial = false,
      final List<String> invitedUsers = const [],
      this.createdAt,
      this.updatedAt})
      : _requirements = requirements,
        _participants = participants,
        _invitedUsers = invitedUsers,
        super._();

  factory _$ChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final String? imageUrl;
// Field for local image path when uploading new images
  @override
  final String? localImagePath;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  @JsonKey()
  final String type;
  @override
  final int points;
  final List<String> _requirements;
  @override
  @JsonKey()
  List<String> get requirements {
    if (_requirements is EqualUnmodifiableListView) return _requirements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_requirements);
  }

  final List<String> _participants;
  @override
  @JsonKey()
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  @JsonKey()
  final bool active;
  @override
  final String? creatorId;
// Modificado para nullable
  @override
  @JsonKey()
  final bool isOfficial;
  final List<String> _invitedUsers;
  @override
  @JsonKey()
  List<String> get invitedUsers {
    if (_invitedUsers is EqualUnmodifiableListView) return _invitedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_invitedUsers);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Challenge(id: $id, title: $title, description: $description, imageUrl: $imageUrl, localImagePath: $localImagePath, startDate: $startDate, endDate: $endDate, type: $type, points: $points, requirements: $requirements, participants: $participants, active: $active, creatorId: $creatorId, isOfficial: $isOfficial, invitedUsers: $invitedUsers, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Challenge'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('localImagePath', localImagePath))
      ..add(DiagnosticsProperty('startDate', startDate))
      ..add(DiagnosticsProperty('endDate', endDate))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('points', points))
      ..add(DiagnosticsProperty('requirements', requirements))
      ..add(DiagnosticsProperty('participants', participants))
      ..add(DiagnosticsProperty('active', active))
      ..add(DiagnosticsProperty('creatorId', creatorId))
      ..add(DiagnosticsProperty('isOfficial', isOfficial))
      ..add(DiagnosticsProperty('invitedUsers', invitedUsers))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.localImagePath, localImagePath) ||
                other.localImagePath == localImagePath) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.points, points) || other.points == points) &&
            const DeepCollectionEquality()
                .equals(other._requirements, _requirements) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.isOfficial, isOfficial) ||
                other.isOfficial == isOfficial) &&
            const DeepCollectionEquality()
                .equals(other._invitedUsers, _invitedUsers) &&
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
      imageUrl,
      localImagePath,
      startDate,
      endDate,
      type,
      points,
      const DeepCollectionEquality().hash(_requirements),
      const DeepCollectionEquality().hash(_participants),
      active,
      creatorId,
      isOfficial,
      const DeepCollectionEquality().hash(_invitedUsers),
      createdAt,
      updatedAt);

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      __$$ChallengeImplCopyWithImpl<_$ChallengeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeImplToJson(
      this,
    );
  }
}

abstract class _Challenge extends Challenge {
  const factory _Challenge(
      {required final String id,
      required final String title,
      required final String description,
      final String? imageUrl,
      final String? localImagePath,
      required final DateTime startDate,
      required final DateTime endDate,
      final String type,
      required final int points,
      final List<String> requirements,
      final List<String> participants,
      final bool active,
      final String? creatorId,
      final bool isOfficial,
      final List<String> invitedUsers,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$ChallengeImpl;
  const _Challenge._() : super._();

  factory _Challenge.fromJson(Map<String, dynamic> json) =
      _$ChallengeImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String? get imageUrl; // Field for local image path when uploading new images
  @override
  String? get localImagePath;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  String get type;
  @override
  int get points;
  @override
  List<String> get requirements;
  @override
  List<String> get participants;
  @override
  bool get active;
  @override
  String? get creatorId; // Modificado para nullable
  @override
  bool get isOfficial;
  @override
  List<String> get invitedUsers;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
