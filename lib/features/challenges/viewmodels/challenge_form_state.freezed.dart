// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChallengeFormState {
  String? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  String? get localImagePath => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  List<String> get requirements => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  String? get creatorId =>
      throw _privateConstructorUsedError; // Alterado para nullable para compatibilidade
  bool get isOfficial => throw _privateConstructorUsedError;
  List<String> get invitedUsers => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeFormStateCopyWith<ChallengeFormState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeFormStateCopyWith<$Res> {
  factory $ChallengeFormStateCopyWith(
          ChallengeFormState value, $Res Function(ChallengeFormState) then) =
      _$ChallengeFormStateCopyWithImpl<$Res, ChallengeFormState>;
  @useResult
  $Res call(
      {String? id,
      String title,
      String description,
      String? imageUrl,
      String? imagePath,
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
      bool isSubmitting,
      bool isSuccess,
      String errorMessage});
}

/// @nodoc
class _$ChallengeFormStateCopyWithImpl<$Res, $Val extends ChallengeFormState>
    implements $ChallengeFormStateCopyWith<$Res> {
  _$ChallengeFormStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? imagePath = freezed,
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
    Object? isSubmitting = null,
    Object? isSuccess = null,
    Object? errorMessage = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
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
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
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
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeFormStateImplCopyWith<$Res>
    implements $ChallengeFormStateCopyWith<$Res> {
  factory _$$ChallengeFormStateImplCopyWith(_$ChallengeFormStateImpl value,
          $Res Function(_$ChallengeFormStateImpl) then) =
      __$$ChallengeFormStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String title,
      String description,
      String? imageUrl,
      String? imagePath,
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
      bool isSubmitting,
      bool isSuccess,
      String errorMessage});
}

/// @nodoc
class __$$ChallengeFormStateImplCopyWithImpl<$Res>
    extends _$ChallengeFormStateCopyWithImpl<$Res, _$ChallengeFormStateImpl>
    implements _$$ChallengeFormStateImplCopyWith<$Res> {
  __$$ChallengeFormStateImplCopyWithImpl(_$ChallengeFormStateImpl _value,
      $Res Function(_$ChallengeFormStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? imagePath = freezed,
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
    Object? isSubmitting = null,
    Object? isSuccess = null,
    Object? errorMessage = null,
  }) {
    return _then(_$ChallengeFormStateImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
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
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
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
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: null == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ChallengeFormStateImpl extends _ChallengeFormState {
  const _$ChallengeFormStateImpl(
      {this.id,
      this.title = '',
      this.description = '',
      this.imageUrl,
      this.imagePath,
      this.localImagePath,
      required this.startDate,
      required this.endDate,
      this.type = 'normal',
      this.points = 10,
      final List<String> requirements = const [],
      final List<String> participants = const [],
      this.active = true,
      this.creatorId,
      this.isOfficial = false,
      final List<String> invitedUsers = const [],
      this.isSubmitting = false,
      this.isSuccess = false,
      this.errorMessage = ''})
      : _requirements = requirements,
        _participants = participants,
        _invitedUsers = invitedUsers,
        super._();

  @override
  final String? id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  final String? imageUrl;
  @override
  final String? imagePath;
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
  @JsonKey()
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
// Alterado para nullable para compatibilidade
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
  @JsonKey()
  final bool isSubmitting;
  @override
  @JsonKey()
  final bool isSuccess;
  @override
  @JsonKey()
  final String errorMessage;

  @override
  String toString() {
    return 'ChallengeFormState(id: $id, title: $title, description: $description, imageUrl: $imageUrl, imagePath: $imagePath, localImagePath: $localImagePath, startDate: $startDate, endDate: $endDate, type: $type, points: $points, requirements: $requirements, participants: $participants, active: $active, creatorId: $creatorId, isOfficial: $isOfficial, invitedUsers: $invitedUsers, isSubmitting: $isSubmitting, isSuccess: $isSuccess, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeFormStateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
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
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        title,
        description,
        imageUrl,
        imagePath,
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
        isSubmitting,
        isSuccess,
        errorMessage
      ]);

  /// Create a copy of ChallengeFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeFormStateImplCopyWith<_$ChallengeFormStateImpl> get copyWith =>
      __$$ChallengeFormStateImplCopyWithImpl<_$ChallengeFormStateImpl>(
          this, _$identity);
}

abstract class _ChallengeFormState extends ChallengeFormState {
  const factory _ChallengeFormState(
      {final String? id,
      final String title,
      final String description,
      final String? imageUrl,
      final String? imagePath,
      final String? localImagePath,
      required final DateTime startDate,
      required final DateTime endDate,
      final String type,
      final int points,
      final List<String> requirements,
      final List<String> participants,
      final bool active,
      final String? creatorId,
      final bool isOfficial,
      final List<String> invitedUsers,
      final bool isSubmitting,
      final bool isSuccess,
      final String errorMessage}) = _$ChallengeFormStateImpl;
  const _ChallengeFormState._() : super._();

  @override
  String? get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String? get imageUrl;
  @override
  String? get imagePath;
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
  String? get creatorId; // Alterado para nullable para compatibilidade
  @override
  bool get isOfficial;
  @override
  List<String> get invitedUsers;
  @override
  bool get isSubmitting;
  @override
  bool get isSuccess;
  @override
  String get errorMessage;

  /// Create a copy of ChallengeFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeFormStateImplCopyWith<_$ChallengeFormStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
