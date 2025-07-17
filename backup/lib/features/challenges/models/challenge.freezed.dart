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
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get reward => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt =>
      throw _privateConstructorUsedError; // Campos adicionais necessários para o repositório
  String get creatorId => throw _privateConstructorUsedError;
  bool get isOfficial => throw _privateConstructorUsedError;
  List<String> get invitedUsers => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;

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
      DateTime startDate,
      DateTime endDate,
      int reward,
      List<String> participants,
      DateTime createdAt,
      DateTime updatedAt,
      String creatorId,
      bool isOfficial,
      List<String> invitedUsers,
      String? imageUrl});
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
    Object? startDate = null,
    Object? endDate = null,
    Object? reward = null,
    Object? participants = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? creatorId = null,
    Object? isOfficial = null,
    Object? invitedUsers = null,
    Object? imageUrl = freezed,
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
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reward: null == reward
          ? _value.reward
          : reward // ignore: cast_nullable_to_non_nullable
              as int,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      invitedUsers: null == invitedUsers
          ? _value.invitedUsers
          : invitedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
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
      DateTime startDate,
      DateTime endDate,
      int reward,
      List<String> participants,
      DateTime createdAt,
      DateTime updatedAt,
      String creatorId,
      bool isOfficial,
      List<String> invitedUsers,
      String? imageUrl});
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
    Object? startDate = null,
    Object? endDate = null,
    Object? reward = null,
    Object? participants = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? creatorId = null,
    Object? isOfficial = null,
    Object? invitedUsers = null,
    Object? imageUrl = freezed,
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
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      reward: null == reward
          ? _value.reward
          : reward // ignore: cast_nullable_to_non_nullable
              as int,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      invitedUsers: null == invitedUsers
          ? _value._invitedUsers
          : invitedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeImpl implements _Challenge {
  const _$ChallengeImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.reward,
      required final List<String> participants,
      required this.createdAt,
      required this.updatedAt,
      required this.creatorId,
      this.isOfficial = false,
      final List<String> invitedUsers = const [],
      this.imageUrl})
      : _participants = participants,
        _invitedUsers = invitedUsers;

  factory _$ChallengeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final int reward;
  final List<String> _participants;
  @override
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
// Campos adicionais necessários para o repositório
  @override
  final String creatorId;
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
  final String? imageUrl;

  @override
  String toString() {
    return 'Challenge(id: $id, title: $title, description: $description, startDate: $startDate, endDate: $endDate, reward: $reward, participants: $participants, createdAt: $createdAt, updatedAt: $updatedAt, creatorId: $creatorId, isOfficial: $isOfficial, invitedUsers: $invitedUsers, imageUrl: $imageUrl)';
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
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.reward, reward) || other.reward == reward) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.isOfficial, isOfficial) ||
                other.isOfficial == isOfficial) &&
            const DeepCollectionEquality()
                .equals(other._invitedUsers, _invitedUsers) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      startDate,
      endDate,
      reward,
      const DeepCollectionEquality().hash(_participants),
      createdAt,
      updatedAt,
      creatorId,
      isOfficial,
      const DeepCollectionEquality().hash(_invitedUsers),
      imageUrl);

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

abstract class _Challenge implements Challenge {
  const factory _Challenge(
      {required final String id,
      required final String title,
      required final String description,
      required final DateTime startDate,
      required final DateTime endDate,
      required final int reward,
      required final List<String> participants,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String creatorId,
      final bool isOfficial,
      final List<String> invitedUsers,
      final String? imageUrl}) = _$ChallengeImpl;

  factory _Challenge.fromJson(Map<String, dynamic> json) =
      _$ChallengeImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get reward;
  @override
  List<String> get participants;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt; // Campos adicionais necessários para o repositório
  @override
  String get creatorId;
  @override
  bool get isOfficial;
  @override
  List<String> get invitedUsers;
  @override
  String? get imageUrl;

  /// Create a copy of Challenge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeImplCopyWith<_$ChallengeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChallengeState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)
        $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)
        success,
    required TResult Function(String message) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult? Function(String message)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ChallengeState value) $default, {
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ChallengeState value)? $default, {
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ChallengeState value)? $default, {
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeStateCopyWith<$Res> {
  factory $ChallengeStateCopyWith(
          ChallengeState value, $Res Function(ChallengeState) then) =
      _$ChallengeStateCopyWithImpl<$Res, ChallengeState>;
}

/// @nodoc
class _$ChallengeStateCopyWithImpl<$Res, $Val extends ChallengeState>
    implements $ChallengeStateCopyWith<$Res> {
  _$ChallengeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$ChallengeStateImplCopyWith<$Res> {
  factory _$$ChallengeStateImplCopyWith(_$ChallengeStateImpl value,
          $Res Function(_$ChallengeStateImpl) then) =
      __$$ChallengeStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<Challenge> challenges,
      List<Challenge> filteredChallenges,
      Challenge? selectedChallenge,
      List<ChallengeInvite> pendingInvites,
      List<ChallengeProgress> progressList,
      bool isLoading,
      String? errorMessage,
      String? successMessage});

  $ChallengeCopyWith<$Res>? get selectedChallenge;
}

/// @nodoc
class __$$ChallengeStateImplCopyWithImpl<$Res>
    extends _$ChallengeStateCopyWithImpl<$Res, _$ChallengeStateImpl>
    implements _$$ChallengeStateImplCopyWith<$Res> {
  __$$ChallengeStateImplCopyWithImpl(
      _$ChallengeStateImpl _value, $Res Function(_$ChallengeStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenges = null,
    Object? filteredChallenges = null,
    Object? selectedChallenge = freezed,
    Object? pendingInvites = null,
    Object? progressList = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(_$ChallengeStateImpl(
      challenges: null == challenges
          ? _value._challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      filteredChallenges: null == filteredChallenges
          ? _value._filteredChallenges
          : filteredChallenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      selectedChallenge: freezed == selectedChallenge
          ? _value.selectedChallenge
          : selectedChallenge // ignore: cast_nullable_to_non_nullable
              as Challenge?,
      pendingInvites: null == pendingInvites
          ? _value._pendingInvites
          : pendingInvites // ignore: cast_nullable_to_non_nullable
              as List<ChallengeInvite>,
      progressList: null == progressList
          ? _value._progressList
          : progressList // ignore: cast_nullable_to_non_nullable
              as List<ChallengeProgress>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      successMessage: freezed == successMessage
          ? _value.successMessage
          : successMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeCopyWith<$Res>? get selectedChallenge {
    if (_value.selectedChallenge == null) {
      return null;
    }

    return $ChallengeCopyWith<$Res>(_value.selectedChallenge!, (value) {
      return _then(_value.copyWith(selectedChallenge: value));
    });
  }
}

/// @nodoc

class _$ChallengeStateImpl implements _ChallengeState {
  const _$ChallengeStateImpl(
      {final List<Challenge> challenges = const [],
      final List<Challenge> filteredChallenges = const [],
      this.selectedChallenge,
      final List<ChallengeInvite> pendingInvites = const [],
      final List<ChallengeProgress> progressList = const [],
      this.isLoading = false,
      this.errorMessage,
      this.successMessage})
      : _challenges = challenges,
        _filteredChallenges = filteredChallenges,
        _pendingInvites = pendingInvites,
        _progressList = progressList;

  final List<Challenge> _challenges;
  @override
  @JsonKey()
  List<Challenge> get challenges {
    if (_challenges is EqualUnmodifiableListView) return _challenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_challenges);
  }

  final List<Challenge> _filteredChallenges;
  @override
  @JsonKey()
  List<Challenge> get filteredChallenges {
    if (_filteredChallenges is EqualUnmodifiableListView)
      return _filteredChallenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredChallenges);
  }

  @override
  final Challenge? selectedChallenge;
  final List<ChallengeInvite> _pendingInvites;
  @override
  @JsonKey()
  List<ChallengeInvite> get pendingInvites {
    if (_pendingInvites is EqualUnmodifiableListView) return _pendingInvites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingInvites);
  }

  final List<ChallengeProgress> _progressList;
  @override
  @JsonKey()
  List<ChallengeProgress> get progressList {
    if (_progressList is EqualUnmodifiableListView) return _progressList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_progressList);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  final String? successMessage;

  @override
  String toString() {
    return 'ChallengeState(challenges: $challenges, filteredChallenges: $filteredChallenges, selectedChallenge: $selectedChallenge, pendingInvites: $pendingInvites, progressList: $progressList, isLoading: $isLoading, errorMessage: $errorMessage, successMessage: $successMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeStateImpl &&
            const DeepCollectionEquality()
                .equals(other._challenges, _challenges) &&
            const DeepCollectionEquality()
                .equals(other._filteredChallenges, _filteredChallenges) &&
            (identical(other.selectedChallenge, selectedChallenge) ||
                other.selectedChallenge == selectedChallenge) &&
            const DeepCollectionEquality()
                .equals(other._pendingInvites, _pendingInvites) &&
            const DeepCollectionEquality()
                .equals(other._progressList, _progressList) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_challenges),
      const DeepCollectionEquality().hash(_filteredChallenges),
      selectedChallenge,
      const DeepCollectionEquality().hash(_pendingInvites),
      const DeepCollectionEquality().hash(_progressList),
      isLoading,
      errorMessage,
      successMessage);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeStateImplCopyWith<_$ChallengeStateImpl> get copyWith =>
      __$$ChallengeStateImplCopyWithImpl<_$ChallengeStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)
        $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)
        success,
    required TResult Function(String message) error,
  }) {
    return $default(challenges, filteredChallenges, selectedChallenge,
        pendingInvites, progressList, isLoading, errorMessage, successMessage);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult? Function(String message)? error,
  }) {
    return $default?.call(challenges, filteredChallenges, selectedChallenge,
        pendingInvites, progressList, isLoading, errorMessage, successMessage);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(
          challenges,
          filteredChallenges,
          selectedChallenge,
          pendingInvites,
          progressList,
          isLoading,
          errorMessage,
          successMessage);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ChallengeState value) $default, {
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ChallengeState value)? $default, {
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ChallengeState value)? $default, {
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _ChallengeState implements ChallengeState {
  const factory _ChallengeState(
      {final List<Challenge> challenges,
      final List<Challenge> filteredChallenges,
      final Challenge? selectedChallenge,
      final List<ChallengeInvite> pendingInvites,
      final List<ChallengeProgress> progressList,
      final bool isLoading,
      final String? errorMessage,
      final String? successMessage}) = _$ChallengeStateImpl;

  List<Challenge> get challenges;
  List<Challenge> get filteredChallenges;
  Challenge? get selectedChallenge;
  List<ChallengeInvite> get pendingInvites;
  List<ChallengeProgress> get progressList;
  bool get isLoading;
  String? get errorMessage;
  String? get successMessage;

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeStateImplCopyWith<_$ChallengeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$ChallengeStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'ChallengeState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)
        $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)
        success,
    required TResult Function(String message) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult? Function(String message)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ChallengeState value) $default, {
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ChallengeState value)? $default, {
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ChallengeState value)? $default, {
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements ChallengeState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$ChallengeStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'ChallengeState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)
        $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)
        success,
    required TResult Function(String message) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult? Function(String message)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ChallengeState value) $default, {
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ChallengeState value)? $default, {
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ChallengeState value)? $default, {
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements ChallengeState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$SuccessImplCopyWith<$Res> {
  factory _$$SuccessImplCopyWith(
          _$SuccessImpl value, $Res Function(_$SuccessImpl) then) =
      __$$SuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<Challenge> challenges,
      List<Challenge> filteredChallenges,
      Challenge? selectedChallenge,
      List<ChallengeInvite> pendingInvites,
      List<ChallengeProgress> progressList,
      String? message});

  $ChallengeCopyWith<$Res>? get selectedChallenge;
}

/// @nodoc
class __$$SuccessImplCopyWithImpl<$Res>
    extends _$ChallengeStateCopyWithImpl<$Res, _$SuccessImpl>
    implements _$$SuccessImplCopyWith<$Res> {
  __$$SuccessImplCopyWithImpl(
      _$SuccessImpl _value, $Res Function(_$SuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenges = null,
    Object? filteredChallenges = null,
    Object? selectedChallenge = freezed,
    Object? pendingInvites = null,
    Object? progressList = null,
    Object? message = freezed,
  }) {
    return _then(_$SuccessImpl(
      challenges: null == challenges
          ? _value._challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      filteredChallenges: null == filteredChallenges
          ? _value._filteredChallenges
          : filteredChallenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      selectedChallenge: freezed == selectedChallenge
          ? _value.selectedChallenge
          : selectedChallenge // ignore: cast_nullable_to_non_nullable
              as Challenge?,
      pendingInvites: null == pendingInvites
          ? _value._pendingInvites
          : pendingInvites // ignore: cast_nullable_to_non_nullable
              as List<ChallengeInvite>,
      progressList: null == progressList
          ? _value._progressList
          : progressList // ignore: cast_nullable_to_non_nullable
              as List<ChallengeProgress>,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeCopyWith<$Res>? get selectedChallenge {
    if (_value.selectedChallenge == null) {
      return null;
    }

    return $ChallengeCopyWith<$Res>(_value.selectedChallenge!, (value) {
      return _then(_value.copyWith(selectedChallenge: value));
    });
  }
}

/// @nodoc

class _$SuccessImpl implements _Success {
  const _$SuccessImpl(
      {required final List<Challenge> challenges,
      final List<Challenge> filteredChallenges = const [],
      this.selectedChallenge,
      final List<ChallengeInvite> pendingInvites = const [],
      final List<ChallengeProgress> progressList = const [],
      this.message})
      : _challenges = challenges,
        _filteredChallenges = filteredChallenges,
        _pendingInvites = pendingInvites,
        _progressList = progressList;

  final List<Challenge> _challenges;
  @override
  List<Challenge> get challenges {
    if (_challenges is EqualUnmodifiableListView) return _challenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_challenges);
  }

  final List<Challenge> _filteredChallenges;
  @override
  @JsonKey()
  List<Challenge> get filteredChallenges {
    if (_filteredChallenges is EqualUnmodifiableListView)
      return _filteredChallenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredChallenges);
  }

  @override
  final Challenge? selectedChallenge;
  final List<ChallengeInvite> _pendingInvites;
  @override
  @JsonKey()
  List<ChallengeInvite> get pendingInvites {
    if (_pendingInvites is EqualUnmodifiableListView) return _pendingInvites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingInvites);
  }

  final List<ChallengeProgress> _progressList;
  @override
  @JsonKey()
  List<ChallengeProgress> get progressList {
    if (_progressList is EqualUnmodifiableListView) return _progressList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_progressList);
  }

  @override
  final String? message;

  @override
  String toString() {
    return 'ChallengeState.success(challenges: $challenges, filteredChallenges: $filteredChallenges, selectedChallenge: $selectedChallenge, pendingInvites: $pendingInvites, progressList: $progressList, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SuccessImpl &&
            const DeepCollectionEquality()
                .equals(other._challenges, _challenges) &&
            const DeepCollectionEquality()
                .equals(other._filteredChallenges, _filteredChallenges) &&
            (identical(other.selectedChallenge, selectedChallenge) ||
                other.selectedChallenge == selectedChallenge) &&
            const DeepCollectionEquality()
                .equals(other._pendingInvites, _pendingInvites) &&
            const DeepCollectionEquality()
                .equals(other._progressList, _progressList) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_challenges),
      const DeepCollectionEquality().hash(_filteredChallenges),
      selectedChallenge,
      const DeepCollectionEquality().hash(_pendingInvites),
      const DeepCollectionEquality().hash(_progressList),
      message);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      __$$SuccessImplCopyWithImpl<_$SuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)
        $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)
        success,
    required TResult Function(String message) error,
  }) {
    return success(challenges, filteredChallenges, selectedChallenge,
        pendingInvites, progressList, message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult? Function(String message)? error,
  }) {
    return success?.call(challenges, filteredChallenges, selectedChallenge,
        pendingInvites, progressList, message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(challenges, filteredChallenges, selectedChallenge,
          pendingInvites, progressList, message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ChallengeState value) $default, {
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ChallengeState value)? $default, {
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ChallengeState value)? $default, {
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class _Success implements ChallengeState {
  const factory _Success(
      {required final List<Challenge> challenges,
      final List<Challenge> filteredChallenges,
      final Challenge? selectedChallenge,
      final List<ChallengeInvite> pendingInvites,
      final List<ChallengeProgress> progressList,
      final String? message}) = _$SuccessImpl;

  List<Challenge> get challenges;
  List<Challenge> get filteredChallenges;
  Challenge? get selectedChallenge;
  List<ChallengeInvite> get pendingInvites;
  List<ChallengeProgress> get progressList;
  String? get message;

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SuccessImplCopyWith<_$SuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$ChallengeStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$ErrorImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'ChallengeState.error(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)
        $default, {
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)
        success,
    required TResult Function(String message) error,
  }) {
    return error(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult? Function(String message)? error,
  }) {
    return error?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            bool isLoading,
            String? errorMessage,
            String? successMessage)?
        $default, {
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<Challenge> challenges,
            List<Challenge> filteredChallenges,
            Challenge? selectedChallenge,
            List<ChallengeInvite> pendingInvites,
            List<ChallengeProgress> progressList,
            String? message)?
        success,
    TResult Function(String message)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ChallengeState value) $default, {
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_Success value) success,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ChallengeState value)? $default, {
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_Success value)? success,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ChallengeState value)? $default, {
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_Success value)? success,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements ChallengeState {
  const factory _Error({required final String message}) = _$ErrorImpl;

  String get message;

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChallengeInvite _$ChallengeInviteFromJson(Map<String, dynamic> json) {
  return _ChallengeInvite.fromJson(json);
}

/// @nodoc
mixin _$ChallengeInvite {
  String get id => throw _privateConstructorUsedError;
  String get challengeId => throw _privateConstructorUsedError;
  String get challengeTitle => throw _privateConstructorUsedError;
  String get inviterId => throw _privateConstructorUsedError;
  String get inviterName => throw _privateConstructorUsedError;
  String get inviteeId => throw _privateConstructorUsedError;
  InviteStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get respondedAt => throw _privateConstructorUsedError;

  /// Serializes this ChallengeInvite to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeInviteCopyWith<ChallengeInvite> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeInviteCopyWith<$Res> {
  factory $ChallengeInviteCopyWith(
          ChallengeInvite value, $Res Function(ChallengeInvite) then) =
      _$ChallengeInviteCopyWithImpl<$Res, ChallengeInvite>;
  @useResult
  $Res call(
      {String id,
      String challengeId,
      String challengeTitle,
      String inviterId,
      String inviterName,
      String inviteeId,
      InviteStatus status,
      DateTime createdAt,
      DateTime? respondedAt});
}

/// @nodoc
class _$ChallengeInviteCopyWithImpl<$Res, $Val extends ChallengeInvite>
    implements $ChallengeInviteCopyWith<$Res> {
  _$ChallengeInviteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? challengeId = null,
    Object? challengeTitle = null,
    Object? inviterId = null,
    Object? inviterName = null,
    Object? inviteeId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? respondedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      challengeTitle: null == challengeTitle
          ? _value.challengeTitle
          : challengeTitle // ignore: cast_nullable_to_non_nullable
              as String,
      inviterId: null == inviterId
          ? _value.inviterId
          : inviterId // ignore: cast_nullable_to_non_nullable
              as String,
      inviterName: null == inviterName
          ? _value.inviterName
          : inviterName // ignore: cast_nullable_to_non_nullable
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeInviteImplCopyWith<$Res>
    implements $ChallengeInviteCopyWith<$Res> {
  factory _$$ChallengeInviteImplCopyWith(_$ChallengeInviteImpl value,
          $Res Function(_$ChallengeInviteImpl) then) =
      __$$ChallengeInviteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String challengeId,
      String challengeTitle,
      String inviterId,
      String inviterName,
      String inviteeId,
      InviteStatus status,
      DateTime createdAt,
      DateTime? respondedAt});
}

/// @nodoc
class __$$ChallengeInviteImplCopyWithImpl<$Res>
    extends _$ChallengeInviteCopyWithImpl<$Res, _$ChallengeInviteImpl>
    implements _$$ChallengeInviteImplCopyWith<$Res> {
  __$$ChallengeInviteImplCopyWithImpl(
      _$ChallengeInviteImpl _value, $Res Function(_$ChallengeInviteImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeInvite
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? challengeId = null,
    Object? challengeTitle = null,
    Object? inviterId = null,
    Object? inviterName = null,
    Object? inviteeId = null,
    Object? status = null,
    Object? createdAt = null,
    Object? respondedAt = freezed,
  }) {
    return _then(_$ChallengeInviteImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      challengeTitle: null == challengeTitle
          ? _value.challengeTitle
          : challengeTitle // ignore: cast_nullable_to_non_nullable
              as String,
      inviterId: null == inviterId
          ? _value.inviterId
          : inviterId // ignore: cast_nullable_to_non_nullable
              as String,
      inviterName: null == inviterName
          ? _value.inviterName
          : inviterName // ignore: cast_nullable_to_non_nullable
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
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeInviteImpl implements _ChallengeInvite {
  const _$ChallengeInviteImpl(
      {required this.id,
      required this.challengeId,
      required this.challengeTitle,
      required this.inviterId,
      required this.inviterName,
      required this.inviteeId,
      this.status = InviteStatus.pending,
      required this.createdAt,
      this.respondedAt});

  factory _$ChallengeInviteImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeInviteImplFromJson(json);

  @override
  final String id;
  @override
  final String challengeId;
  @override
  final String challengeTitle;
  @override
  final String inviterId;
  @override
  final String inviterName;
  @override
  final String inviteeId;
  @override
  @JsonKey()
  final InviteStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? respondedAt;

  @override
  String toString() {
    return 'ChallengeInvite(id: $id, challengeId: $challengeId, challengeTitle: $challengeTitle, inviterId: $inviterId, inviterName: $inviterName, inviteeId: $inviteeId, status: $status, createdAt: $createdAt, respondedAt: $respondedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeInviteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.challengeTitle, challengeTitle) ||
                other.challengeTitle == challengeTitle) &&
            (identical(other.inviterId, inviterId) ||
                other.inviterId == inviterId) &&
            (identical(other.inviterName, inviterName) ||
                other.inviterName == inviterName) &&
            (identical(other.inviteeId, inviteeId) ||
                other.inviteeId == inviteeId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.respondedAt, respondedAt) ||
                other.respondedAt == respondedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, challengeId, challengeTitle,
      inviterId, inviterName, inviteeId, status, createdAt, respondedAt);

  /// Create a copy of ChallengeInvite
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeInviteImplCopyWith<_$ChallengeInviteImpl> get copyWith =>
      __$$ChallengeInviteImplCopyWithImpl<_$ChallengeInviteImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeInviteImplToJson(
      this,
    );
  }
}

abstract class _ChallengeInvite implements ChallengeInvite {
  const factory _ChallengeInvite(
      {required final String id,
      required final String challengeId,
      required final String challengeTitle,
      required final String inviterId,
      required final String inviterName,
      required final String inviteeId,
      final InviteStatus status,
      required final DateTime createdAt,
      final DateTime? respondedAt}) = _$ChallengeInviteImpl;

  factory _ChallengeInvite.fromJson(Map<String, dynamic> json) =
      _$ChallengeInviteImpl.fromJson;

  @override
  String get id;
  @override
  String get challengeId;
  @override
  String get challengeTitle;
  @override
  String get inviterId;
  @override
  String get inviterName;
  @override
  String get inviteeId;
  @override
  InviteStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime? get respondedAt;

  /// Create a copy of ChallengeInvite
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeInviteImplCopyWith<_$ChallengeInviteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChallengeProgress _$ChallengeProgressFromJson(Map<String, dynamic> json) {
  return _ChallengeProgress.fromJson(json);
}

/// @nodoc
mixin _$ChallengeProgress {
  String get id => throw _privateConstructorUsedError;
  String get challengeId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userPhotoUrl => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  double get completionPercentage => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this ChallengeProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeProgressCopyWith<ChallengeProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeProgressCopyWith<$Res> {
  factory $ChallengeProgressCopyWith(
          ChallengeProgress value, $Res Function(ChallengeProgress) then) =
      _$ChallengeProgressCopyWithImpl<$Res, ChallengeProgress>;
  @useResult
  $Res call(
      {String id,
      String challengeId,
      String userId,
      String userName,
      String? userPhotoUrl,
      int points,
      int position,
      double completionPercentage,
      DateTime lastUpdated});
}

/// @nodoc
class _$ChallengeProgressCopyWithImpl<$Res, $Val extends ChallengeProgress>
    implements $ChallengeProgressCopyWith<$Res> {
  _$ChallengeProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? challengeId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userPhotoUrl = freezed,
    Object? points = null,
    Object? position = null,
    Object? completionPercentage = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userPhotoUrl: freezed == userPhotoUrl
          ? _value.userPhotoUrl
          : userPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeProgressImplCopyWith<$Res>
    implements $ChallengeProgressCopyWith<$Res> {
  factory _$$ChallengeProgressImplCopyWith(_$ChallengeProgressImpl value,
          $Res Function(_$ChallengeProgressImpl) then) =
      __$$ChallengeProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String challengeId,
      String userId,
      String userName,
      String? userPhotoUrl,
      int points,
      int position,
      double completionPercentage,
      DateTime lastUpdated});
}

/// @nodoc
class __$$ChallengeProgressImplCopyWithImpl<$Res>
    extends _$ChallengeProgressCopyWithImpl<$Res, _$ChallengeProgressImpl>
    implements _$$ChallengeProgressImplCopyWith<$Res> {
  __$$ChallengeProgressImplCopyWithImpl(_$ChallengeProgressImpl _value,
      $Res Function(_$ChallengeProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? challengeId = null,
    Object? userId = null,
    Object? userName = null,
    Object? userPhotoUrl = freezed,
    Object? points = null,
    Object? position = null,
    Object? completionPercentage = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$ChallengeProgressImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      userPhotoUrl: freezed == userPhotoUrl
          ? _value.userPhotoUrl
          : userPhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeProgressImpl implements _ChallengeProgress {
  const _$ChallengeProgressImpl(
      {required this.id,
      required this.challengeId,
      required this.userId,
      required this.userName,
      this.userPhotoUrl,
      required this.points,
      required this.position,
      required this.completionPercentage,
      required this.lastUpdated});

  factory _$ChallengeProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeProgressImplFromJson(json);

  @override
  final String id;
  @override
  final String challengeId;
  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? userPhotoUrl;
  @override
  final int points;
  @override
  final int position;
  @override
  final double completionPercentage;
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'ChallengeProgress(id: $id, challengeId: $challengeId, userId: $userId, userName: $userName, userPhotoUrl: $userPhotoUrl, points: $points, position: $position, completionPercentage: $completionPercentage, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeProgressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userPhotoUrl, userPhotoUrl) ||
                other.userPhotoUrl == userPhotoUrl) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.completionPercentage, completionPercentage) ||
                other.completionPercentage == completionPercentage) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      challengeId,
      userId,
      userName,
      userPhotoUrl,
      points,
      position,
      completionPercentage,
      lastUpdated);

  /// Create a copy of ChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeProgressImplCopyWith<_$ChallengeProgressImpl> get copyWith =>
      __$$ChallengeProgressImplCopyWithImpl<_$ChallengeProgressImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeProgressImplToJson(
      this,
    );
  }
}

abstract class _ChallengeProgress implements ChallengeProgress {
  const factory _ChallengeProgress(
      {required final String id,
      required final String challengeId,
      required final String userId,
      required final String userName,
      final String? userPhotoUrl,
      required final int points,
      required final int position,
      required final double completionPercentage,
      required final DateTime lastUpdated}) = _$ChallengeProgressImpl;

  factory _ChallengeProgress.fromJson(Map<String, dynamic> json) =
      _$ChallengeProgressImpl.fromJson;

  @override
  String get id;
  @override
  String get challengeId;
  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get userPhotoUrl;
  @override
  int get points;
  @override
  int get position;
  @override
  double get completionPercentage;
  @override
  DateTime get lastUpdated;

  /// Create a copy of ChallengeProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeProgressImplCopyWith<_$ChallengeProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
