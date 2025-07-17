// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_participation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChallengeParticipation _$ChallengeParticipationFromJson(
    Map<String, dynamic> json) {
  return _ChallengeParticipation.fromJson(json);
}

/// @nodoc
mixin _$ChallengeParticipation {
  /// ID único da participação
  String get id => throw _privateConstructorUsedError;

  /// ID do desafio
  String get challengeId => throw _privateConstructorUsedError;

  /// ID do usuário
  String get userId => throw _privateConstructorUsedError;

  /// Nome do desafio
  String get challengeName => throw _privateConstructorUsedError;

  /// Progresso atual do usuário (0-100)
  double get currentProgress => throw _privateConstructorUsedError;

  /// Posição do usuário no ranking (opcional)
  int? get rank => throw _privateConstructorUsedError;

  /// Total de participantes no desafio
  int get totalParticipants => throw _privateConstructorUsedError;

  /// Indica se o desafio foi completado
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Data de início do desafio
  DateTime get startDate => throw _privateConstructorUsedError;

  /// Data de fim do desafio
  DateTime get endDate => throw _privateConstructorUsedError;

  /// Data de conclusão (se concluído)
  DateTime? get completionDate => throw _privateConstructorUsedError;

  /// Data de criação do registro
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Data da última atualização
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this ChallengeParticipation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeParticipation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeParticipationCopyWith<ChallengeParticipation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeParticipationCopyWith<$Res> {
  factory $ChallengeParticipationCopyWith(ChallengeParticipation value,
          $Res Function(ChallengeParticipation) then) =
      _$ChallengeParticipationCopyWithImpl<$Res, ChallengeParticipation>;
  @useResult
  $Res call(
      {String id,
      String challengeId,
      String userId,
      String challengeName,
      double currentProgress,
      int? rank,
      int totalParticipants,
      bool isCompleted,
      DateTime startDate,
      DateTime endDate,
      DateTime? completionDate,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$ChallengeParticipationCopyWithImpl<$Res,
        $Val extends ChallengeParticipation>
    implements $ChallengeParticipationCopyWith<$Res> {
  _$ChallengeParticipationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeParticipation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? challengeId = null,
    Object? userId = null,
    Object? challengeName = null,
    Object? currentProgress = null,
    Object? rank = freezed,
    Object? totalParticipants = null,
    Object? isCompleted = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? completionDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
      challengeName: null == challengeName
          ? _value.challengeName
          : challengeName // ignore: cast_nullable_to_non_nullable
              as String,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as double,
      rank: freezed == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int?,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completionDate: freezed == completionDate
          ? _value.completionDate
          : completionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeParticipationImplCopyWith<$Res>
    implements $ChallengeParticipationCopyWith<$Res> {
  factory _$$ChallengeParticipationImplCopyWith(
          _$ChallengeParticipationImpl value,
          $Res Function(_$ChallengeParticipationImpl) then) =
      __$$ChallengeParticipationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String challengeId,
      String userId,
      String challengeName,
      double currentProgress,
      int? rank,
      int totalParticipants,
      bool isCompleted,
      DateTime startDate,
      DateTime endDate,
      DateTime? completionDate,
      DateTime createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$ChallengeParticipationImplCopyWithImpl<$Res>
    extends _$ChallengeParticipationCopyWithImpl<$Res,
        _$ChallengeParticipationImpl>
    implements _$$ChallengeParticipationImplCopyWith<$Res> {
  __$$ChallengeParticipationImplCopyWithImpl(
      _$ChallengeParticipationImpl _value,
      $Res Function(_$ChallengeParticipationImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeParticipation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? challengeId = null,
    Object? userId = null,
    Object? challengeName = null,
    Object? currentProgress = null,
    Object? rank = freezed,
    Object? totalParticipants = null,
    Object? isCompleted = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? completionDate = freezed,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$ChallengeParticipationImpl(
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
      challengeName: null == challengeName
          ? _value.challengeName
          : challengeName // ignore: cast_nullable_to_non_nullable
              as String,
      currentProgress: null == currentProgress
          ? _value.currentProgress
          : currentProgress // ignore: cast_nullable_to_non_nullable
              as double,
      rank: freezed == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int?,
      totalParticipants: null == totalParticipants
          ? _value.totalParticipants
          : totalParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completionDate: freezed == completionDate
          ? _value.completionDate
          : completionDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeParticipationImpl extends _ChallengeParticipation {
  const _$ChallengeParticipationImpl(
      {required this.id,
      required this.challengeId,
      required this.userId,
      required this.challengeName,
      this.currentProgress = 0.0,
      this.rank,
      this.totalParticipants = 0,
      this.isCompleted = false,
      required this.startDate,
      required this.endDate,
      this.completionDate,
      required this.createdAt,
      this.updatedAt})
      : super._();

  factory _$ChallengeParticipationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeParticipationImplFromJson(json);

  /// ID único da participação
  @override
  final String id;

  /// ID do desafio
  @override
  final String challengeId;

  /// ID do usuário
  @override
  final String userId;

  /// Nome do desafio
  @override
  final String challengeName;

  /// Progresso atual do usuário (0-100)
  @override
  @JsonKey()
  final double currentProgress;

  /// Posição do usuário no ranking (opcional)
  @override
  final int? rank;

  /// Total de participantes no desafio
  @override
  @JsonKey()
  final int totalParticipants;

  /// Indica se o desafio foi completado
  @override
  @JsonKey()
  final bool isCompleted;

  /// Data de início do desafio
  @override
  final DateTime startDate;

  /// Data de fim do desafio
  @override
  final DateTime endDate;

  /// Data de conclusão (se concluído)
  @override
  final DateTime? completionDate;

  /// Data de criação do registro
  @override
  final DateTime createdAt;

  /// Data da última atualização
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ChallengeParticipation(id: $id, challengeId: $challengeId, userId: $userId, challengeName: $challengeName, currentProgress: $currentProgress, rank: $rank, totalParticipants: $totalParticipants, isCompleted: $isCompleted, startDate: $startDate, endDate: $endDate, completionDate: $completionDate, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeParticipationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.challengeName, challengeName) ||
                other.challengeName == challengeName) &&
            (identical(other.currentProgress, currentProgress) ||
                other.currentProgress == currentProgress) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.totalParticipants, totalParticipants) ||
                other.totalParticipants == totalParticipants) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.completionDate, completionDate) ||
                other.completionDate == completionDate) &&
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
      challengeId,
      userId,
      challengeName,
      currentProgress,
      rank,
      totalParticipants,
      isCompleted,
      startDate,
      endDate,
      completionDate,
      createdAt,
      updatedAt);

  /// Create a copy of ChallengeParticipation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeParticipationImplCopyWith<_$ChallengeParticipationImpl>
      get copyWith => __$$ChallengeParticipationImplCopyWithImpl<
          _$ChallengeParticipationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeParticipationImplToJson(
      this,
    );
  }
}

abstract class _ChallengeParticipation extends ChallengeParticipation {
  const factory _ChallengeParticipation(
      {required final String id,
      required final String challengeId,
      required final String userId,
      required final String challengeName,
      final double currentProgress,
      final int? rank,
      final int totalParticipants,
      final bool isCompleted,
      required final DateTime startDate,
      required final DateTime endDate,
      final DateTime? completionDate,
      required final DateTime createdAt,
      final DateTime? updatedAt}) = _$ChallengeParticipationImpl;
  const _ChallengeParticipation._() : super._();

  factory _ChallengeParticipation.fromJson(Map<String, dynamic> json) =
      _$ChallengeParticipationImpl.fromJson;

  /// ID único da participação
  @override
  String get id;

  /// ID do desafio
  @override
  String get challengeId;

  /// ID do usuário
  @override
  String get userId;

  /// Nome do desafio
  @override
  String get challengeName;

  /// Progresso atual do usuário (0-100)
  @override
  double get currentProgress;

  /// Posição do usuário no ranking (opcional)
  @override
  int? get rank;

  /// Total de participantes no desafio
  @override
  int get totalParticipants;

  /// Indica se o desafio foi completado
  @override
  bool get isCompleted;

  /// Data de início do desafio
  @override
  DateTime get startDate;

  /// Data de fim do desafio
  @override
  DateTime get endDate;

  /// Data de conclusão (se concluído)
  @override
  DateTime? get completionDate;

  /// Data de criação do registro
  @override
  DateTime get createdAt;

  /// Data da última atualização
  @override
  DateTime? get updatedAt;

  /// Create a copy of ChallengeParticipation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeParticipationImplCopyWith<_$ChallengeParticipationImpl>
      get copyWith => throw _privateConstructorUsedError;
}
