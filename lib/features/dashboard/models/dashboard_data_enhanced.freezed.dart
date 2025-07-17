// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_data_enhanced.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardDataEnhanced _$DashboardDataEnhancedFromJson(
    Map<String, dynamic> json) {
  return _DashboardDataEnhanced.fromJson(json);
}

/// @nodoc
mixin _$DashboardDataEnhanced {
  /// Dados de progresso do usuário
  @JsonKey(name: 'user_progress')
  UserProgressData get userProgress => throw _privateConstructorUsedError;

  /// Dados de consumo de água
  @JsonKey(name: 'water_intake')
  WaterIntakeData get waterIntake => throw _privateConstructorUsedError;

  /// Dados de nutrição (pode ser null se não houver dados do dia)
  @JsonKey(name: 'nutrition_data')
  NutritionData? get nutritionData => throw _privateConstructorUsedError;

  /// Lista de metas do usuário
  @JsonKey(name: 'goals')
  List<GoalData> get goals => throw _privateConstructorUsedError;

  /// Treinos recentes
  @JsonKey(name: 'recent_workouts')
  List<RecentWorkoutData> get recentWorkouts =>
      throw _privateConstructorUsedError;

  /// Desafio atual (pode ser null se não houver)
  @JsonKey(name: 'current_challenge')
  ChallengeData? get currentChallenge => throw _privateConstructorUsedError;

  /// Progresso no desafio atual
  @JsonKey(name: 'challenge_progress')
  ChallengeProgressData? get challengeProgress =>
      throw _privateConstructorUsedError;

  /// Benefícios resgatados
  @JsonKey(name: 'redeemed_benefits')
  List<RedeemedBenefitData> get redeemedBenefits =>
      throw _privateConstructorUsedError;

  /// Data da última atualização
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this DashboardDataEnhanced to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DashboardDataEnhanced
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DashboardDataEnhancedCopyWith<DashboardDataEnhanced> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardDataEnhancedCopyWith<$Res> {
  factory $DashboardDataEnhancedCopyWith(DashboardDataEnhanced value,
          $Res Function(DashboardDataEnhanced) then) =
      _$DashboardDataEnhancedCopyWithImpl<$Res, DashboardDataEnhanced>;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_progress') UserProgressData userProgress,
      @JsonKey(name: 'water_intake') WaterIntakeData waterIntake,
      @JsonKey(name: 'nutrition_data') NutritionData? nutritionData,
      @JsonKey(name: 'goals') List<GoalData> goals,
      @JsonKey(name: 'recent_workouts') List<RecentWorkoutData> recentWorkouts,
      @JsonKey(name: 'current_challenge') ChallengeData? currentChallenge,
      @JsonKey(name: 'challenge_progress')
      ChallengeProgressData? challengeProgress,
      @JsonKey(name: 'redeemed_benefits')
      List<RedeemedBenefitData> redeemedBenefits,
      @JsonKey(name: 'last_updated') DateTime lastUpdated});

  $UserProgressDataCopyWith<$Res> get userProgress;
  $WaterIntakeDataCopyWith<$Res> get waterIntake;
  $NutritionDataCopyWith<$Res>? get nutritionData;
  $ChallengeDataCopyWith<$Res>? get currentChallenge;
  $ChallengeProgressDataCopyWith<$Res>? get challengeProgress;
}

/// @nodoc
class _$DashboardDataEnhancedCopyWithImpl<$Res,
        $Val extends DashboardDataEnhanced>
    implements $DashboardDataEnhancedCopyWith<$Res> {
  _$DashboardDataEnhancedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DashboardDataEnhanced
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProgress = null,
    Object? waterIntake = null,
    Object? nutritionData = freezed,
    Object? goals = null,
    Object? recentWorkouts = null,
    Object? currentChallenge = freezed,
    Object? challengeProgress = freezed,
    Object? redeemedBenefits = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      userProgress: null == userProgress
          ? _value.userProgress
          : userProgress // ignore: cast_nullable_to_non_nullable
              as UserProgressData,
      waterIntake: null == waterIntake
          ? _value.waterIntake
          : waterIntake // ignore: cast_nullable_to_non_nullable
              as WaterIntakeData,
      nutritionData: freezed == nutritionData
          ? _value.nutritionData
          : nutritionData // ignore: cast_nullable_to_non_nullable
              as NutritionData?,
      goals: null == goals
          ? _value.goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<GoalData>,
      recentWorkouts: null == recentWorkouts
          ? _value.recentWorkouts
          : recentWorkouts // ignore: cast_nullable_to_non_nullable
              as List<RecentWorkoutData>,
      currentChallenge: freezed == currentChallenge
          ? _value.currentChallenge
          : currentChallenge // ignore: cast_nullable_to_non_nullable
              as ChallengeData?,
      challengeProgress: freezed == challengeProgress
          ? _value.challengeProgress
          : challengeProgress // ignore: cast_nullable_to_non_nullable
              as ChallengeProgressData?,
      redeemedBenefits: null == redeemedBenefits
          ? _value.redeemedBenefits
          : redeemedBenefits // ignore: cast_nullable_to_non_nullable
              as List<RedeemedBenefitData>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of DashboardDataEnhanced
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProgressDataCopyWith<$Res> get userProgress {
    return $UserProgressDataCopyWith<$Res>(_value.userProgress, (value) {
      return _then(_value.copyWith(userProgress: value) as $Val);
    });
  }

  /// Create a copy of DashboardDataEnhanced
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WaterIntakeDataCopyWith<$Res> get waterIntake {
    return $WaterIntakeDataCopyWith<$Res>(_value.waterIntake, (value) {
      return _then(_value.copyWith(waterIntake: value) as $Val);
    });
  }

  /// Create a copy of DashboardDataEnhanced
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionDataCopyWith<$Res>? get nutritionData {
    if (_value.nutritionData == null) {
      return null;
    }

    return $NutritionDataCopyWith<$Res>(_value.nutritionData!, (value) {
      return _then(_value.copyWith(nutritionData: value) as $Val);
    });
  }

  /// Create a copy of DashboardDataEnhanced
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeDataCopyWith<$Res>? get currentChallenge {
    if (_value.currentChallenge == null) {
      return null;
    }

    return $ChallengeDataCopyWith<$Res>(_value.currentChallenge!, (value) {
      return _then(_value.copyWith(currentChallenge: value) as $Val);
    });
  }

  /// Create a copy of DashboardDataEnhanced
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeProgressDataCopyWith<$Res>? get challengeProgress {
    if (_value.challengeProgress == null) {
      return null;
    }

    return $ChallengeProgressDataCopyWith<$Res>(_value.challengeProgress!,
        (value) {
      return _then(_value.copyWith(challengeProgress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DashboardDataEnhancedImplCopyWith<$Res>
    implements $DashboardDataEnhancedCopyWith<$Res> {
  factory _$$DashboardDataEnhancedImplCopyWith(
          _$DashboardDataEnhancedImpl value,
          $Res Function(_$DashboardDataEnhancedImpl) then) =
      __$$DashboardDataEnhancedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_progress') UserProgressData userProgress,
      @JsonKey(name: 'water_intake') WaterIntakeData waterIntake,
      @JsonKey(name: 'nutrition_data') NutritionData? nutritionData,
      @JsonKey(name: 'goals') List<GoalData> goals,
      @JsonKey(name: 'recent_workouts') List<RecentWorkoutData> recentWorkouts,
      @JsonKey(name: 'current_challenge') ChallengeData? currentChallenge,
      @JsonKey(name: 'challenge_progress')
      ChallengeProgressData? challengeProgress,
      @JsonKey(name: 'redeemed_benefits')
      List<RedeemedBenefitData> redeemedBenefits,
      @JsonKey(name: 'last_updated') DateTime lastUpdated});

  @override
  $UserProgressDataCopyWith<$Res> get userProgress;
  @override
  $WaterIntakeDataCopyWith<$Res> get waterIntake;
  @override
  $NutritionDataCopyWith<$Res>? get nutritionData;
  @override
  $ChallengeDataCopyWith<$Res>? get currentChallenge;
  @override
  $ChallengeProgressDataCopyWith<$Res>? get challengeProgress;
}

/// @nodoc
class __$$DashboardDataEnhancedImplCopyWithImpl<$Res>
    extends _$DashboardDataEnhancedCopyWithImpl<$Res,
        _$DashboardDataEnhancedImpl>
    implements _$$DashboardDataEnhancedImplCopyWith<$Res> {
  __$$DashboardDataEnhancedImplCopyWithImpl(_$DashboardDataEnhancedImpl _value,
      $Res Function(_$DashboardDataEnhancedImpl) _then)
      : super(_value, _then);

  /// Create a copy of DashboardDataEnhanced
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userProgress = null,
    Object? waterIntake = null,
    Object? nutritionData = freezed,
    Object? goals = null,
    Object? recentWorkouts = null,
    Object? currentChallenge = freezed,
    Object? challengeProgress = freezed,
    Object? redeemedBenefits = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$DashboardDataEnhancedImpl(
      userProgress: null == userProgress
          ? _value.userProgress
          : userProgress // ignore: cast_nullable_to_non_nullable
              as UserProgressData,
      waterIntake: null == waterIntake
          ? _value.waterIntake
          : waterIntake // ignore: cast_nullable_to_non_nullable
              as WaterIntakeData,
      nutritionData: freezed == nutritionData
          ? _value.nutritionData
          : nutritionData // ignore: cast_nullable_to_non_nullable
              as NutritionData?,
      goals: null == goals
          ? _value._goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<GoalData>,
      recentWorkouts: null == recentWorkouts
          ? _value._recentWorkouts
          : recentWorkouts // ignore: cast_nullable_to_non_nullable
              as List<RecentWorkoutData>,
      currentChallenge: freezed == currentChallenge
          ? _value.currentChallenge
          : currentChallenge // ignore: cast_nullable_to_non_nullable
              as ChallengeData?,
      challengeProgress: freezed == challengeProgress
          ? _value.challengeProgress
          : challengeProgress // ignore: cast_nullable_to_non_nullable
              as ChallengeProgressData?,
      redeemedBenefits: null == redeemedBenefits
          ? _value._redeemedBenefits
          : redeemedBenefits // ignore: cast_nullable_to_non_nullable
              as List<RedeemedBenefitData>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardDataEnhancedImpl implements _DashboardDataEnhanced {
  const _$DashboardDataEnhancedImpl(
      {@JsonKey(name: 'user_progress') required this.userProgress,
      @JsonKey(name: 'water_intake') required this.waterIntake,
      @JsonKey(name: 'nutrition_data') this.nutritionData,
      @JsonKey(name: 'goals') final List<GoalData> goals = const [],
      @JsonKey(name: 'recent_workouts')
      final List<RecentWorkoutData> recentWorkouts = const [],
      @JsonKey(name: 'current_challenge') this.currentChallenge,
      @JsonKey(name: 'challenge_progress') this.challengeProgress,
      @JsonKey(name: 'redeemed_benefits')
      final List<RedeemedBenefitData> redeemedBenefits = const [],
      @JsonKey(name: 'last_updated') required this.lastUpdated})
      : _goals = goals,
        _recentWorkouts = recentWorkouts,
        _redeemedBenefits = redeemedBenefits;

  factory _$DashboardDataEnhancedImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardDataEnhancedImplFromJson(json);

  /// Dados de progresso do usuário
  @override
  @JsonKey(name: 'user_progress')
  final UserProgressData userProgress;

  /// Dados de consumo de água
  @override
  @JsonKey(name: 'water_intake')
  final WaterIntakeData waterIntake;

  /// Dados de nutrição (pode ser null se não houver dados do dia)
  @override
  @JsonKey(name: 'nutrition_data')
  final NutritionData? nutritionData;

  /// Lista de metas do usuário
  final List<GoalData> _goals;

  /// Lista de metas do usuário
  @override
  @JsonKey(name: 'goals')
  List<GoalData> get goals {
    if (_goals is EqualUnmodifiableListView) return _goals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goals);
  }

  /// Treinos recentes
  final List<RecentWorkoutData> _recentWorkouts;

  /// Treinos recentes
  @override
  @JsonKey(name: 'recent_workouts')
  List<RecentWorkoutData> get recentWorkouts {
    if (_recentWorkouts is EqualUnmodifiableListView) return _recentWorkouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentWorkouts);
  }

  /// Desafio atual (pode ser null se não houver)
  @override
  @JsonKey(name: 'current_challenge')
  final ChallengeData? currentChallenge;

  /// Progresso no desafio atual
  @override
  @JsonKey(name: 'challenge_progress')
  final ChallengeProgressData? challengeProgress;

  /// Benefícios resgatados
  final List<RedeemedBenefitData> _redeemedBenefits;

  /// Benefícios resgatados
  @override
  @JsonKey(name: 'redeemed_benefits')
  List<RedeemedBenefitData> get redeemedBenefits {
    if (_redeemedBenefits is EqualUnmodifiableListView)
      return _redeemedBenefits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_redeemedBenefits);
  }

  /// Data da última atualização
  @override
  @JsonKey(name: 'last_updated')
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'DashboardDataEnhanced(userProgress: $userProgress, waterIntake: $waterIntake, nutritionData: $nutritionData, goals: $goals, recentWorkouts: $recentWorkouts, currentChallenge: $currentChallenge, challengeProgress: $challengeProgress, redeemedBenefits: $redeemedBenefits, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardDataEnhancedImpl &&
            (identical(other.userProgress, userProgress) ||
                other.userProgress == userProgress) &&
            (identical(other.waterIntake, waterIntake) ||
                other.waterIntake == waterIntake) &&
            (identical(other.nutritionData, nutritionData) ||
                other.nutritionData == nutritionData) &&
            const DeepCollectionEquality().equals(other._goals, _goals) &&
            const DeepCollectionEquality()
                .equals(other._recentWorkouts, _recentWorkouts) &&
            (identical(other.currentChallenge, currentChallenge) ||
                other.currentChallenge == currentChallenge) &&
            (identical(other.challengeProgress, challengeProgress) ||
                other.challengeProgress == challengeProgress) &&
            const DeepCollectionEquality()
                .equals(other._redeemedBenefits, _redeemedBenefits) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userProgress,
      waterIntake,
      nutritionData,
      const DeepCollectionEquality().hash(_goals),
      const DeepCollectionEquality().hash(_recentWorkouts),
      currentChallenge,
      challengeProgress,
      const DeepCollectionEquality().hash(_redeemedBenefits),
      lastUpdated);

  /// Create a copy of DashboardDataEnhanced
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardDataEnhancedImplCopyWith<_$DashboardDataEnhancedImpl>
      get copyWith => __$$DashboardDataEnhancedImplCopyWithImpl<
          _$DashboardDataEnhancedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardDataEnhancedImplToJson(
      this,
    );
  }
}

abstract class _DashboardDataEnhanced implements DashboardDataEnhanced {
  const factory _DashboardDataEnhanced(
      {@JsonKey(name: 'user_progress')
      required final UserProgressData userProgress,
      @JsonKey(name: 'water_intake') required final WaterIntakeData waterIntake,
      @JsonKey(name: 'nutrition_data') final NutritionData? nutritionData,
      @JsonKey(name: 'goals') final List<GoalData> goals,
      @JsonKey(name: 'recent_workouts')
      final List<RecentWorkoutData> recentWorkouts,
      @JsonKey(name: 'current_challenge') final ChallengeData? currentChallenge,
      @JsonKey(name: 'challenge_progress')
      final ChallengeProgressData? challengeProgress,
      @JsonKey(name: 'redeemed_benefits')
      final List<RedeemedBenefitData> redeemedBenefits,
      @JsonKey(name: 'last_updated')
      required final DateTime lastUpdated}) = _$DashboardDataEnhancedImpl;

  factory _DashboardDataEnhanced.fromJson(Map<String, dynamic> json) =
      _$DashboardDataEnhancedImpl.fromJson;

  /// Dados de progresso do usuário
  @override
  @JsonKey(name: 'user_progress')
  UserProgressData get userProgress;

  /// Dados de consumo de água
  @override
  @JsonKey(name: 'water_intake')
  WaterIntakeData get waterIntake;

  /// Dados de nutrição (pode ser null se não houver dados do dia)
  @override
  @JsonKey(name: 'nutrition_data')
  NutritionData? get nutritionData;

  /// Lista de metas do usuário
  @override
  @JsonKey(name: 'goals')
  List<GoalData> get goals;

  /// Treinos recentes
  @override
  @JsonKey(name: 'recent_workouts')
  List<RecentWorkoutData> get recentWorkouts;

  /// Desafio atual (pode ser null se não houver)
  @override
  @JsonKey(name: 'current_challenge')
  ChallengeData? get currentChallenge;

  /// Progresso no desafio atual
  @override
  @JsonKey(name: 'challenge_progress')
  ChallengeProgressData? get challengeProgress;

  /// Benefícios resgatados
  @override
  @JsonKey(name: 'redeemed_benefits')
  List<RedeemedBenefitData> get redeemedBenefits;

  /// Data da última atualização
  @override
  @JsonKey(name: 'last_updated')
  DateTime get lastUpdated;

  /// Create a copy of DashboardDataEnhanced
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DashboardDataEnhancedImplCopyWith<_$DashboardDataEnhancedImpl>
      get copyWith => throw _privateConstructorUsedError;
}

UserProgressData _$UserProgressDataFromJson(Map<String, dynamic> json) {
  return _UserProgressData.fromJson(json);
}

/// @nodoc
mixin _$UserProgressData {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_workouts')
  int get totalWorkouts => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_streak')
  int get currentStreak => throw _privateConstructorUsedError;
  @JsonKey(name: 'longest_streak')
  int get longestStreak => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_points')
  int get totalPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'days_trained_this_month')
  int get daysTrainedThisMonth => throw _privateConstructorUsedError;
  @JsonKey(name: 'workout_types')
  Map<String, dynamic> get workoutTypes => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserProgressData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProgressData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProgressDataCopyWith<UserProgressData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressDataCopyWith<$Res> {
  factory $UserProgressDataCopyWith(
          UserProgressData value, $Res Function(UserProgressData) then) =
      _$UserProgressDataCopyWithImpl<$Res, UserProgressData>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'total_workouts') int totalWorkouts,
      @JsonKey(name: 'current_streak') int currentStreak,
      @JsonKey(name: 'longest_streak') int longestStreak,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'days_trained_this_month') int daysTrainedThisMonth,
      @JsonKey(name: 'workout_types') Map<String, dynamic> workoutTypes,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$UserProgressDataCopyWithImpl<$Res, $Val extends UserProgressData>
    implements $UserProgressDataCopyWith<$Res> {
  _$UserProgressDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProgressData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? totalWorkouts = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? totalPoints = null,
    Object? daysTrainedThisMonth = null,
    Object? workoutTypes = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      daysTrainedThisMonth: null == daysTrainedThisMonth
          ? _value.daysTrainedThisMonth
          : daysTrainedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      workoutTypes: null == workoutTypes
          ? _value.workoutTypes
          : workoutTypes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProgressDataImplCopyWith<$Res>
    implements $UserProgressDataCopyWith<$Res> {
  factory _$$UserProgressDataImplCopyWith(_$UserProgressDataImpl value,
          $Res Function(_$UserProgressDataImpl) then) =
      __$$UserProgressDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'total_workouts') int totalWorkouts,
      @JsonKey(name: 'current_streak') int currentStreak,
      @JsonKey(name: 'longest_streak') int longestStreak,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'days_trained_this_month') int daysTrainedThisMonth,
      @JsonKey(name: 'workout_types') Map<String, dynamic> workoutTypes,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$UserProgressDataImplCopyWithImpl<$Res>
    extends _$UserProgressDataCopyWithImpl<$Res, _$UserProgressDataImpl>
    implements _$$UserProgressDataImplCopyWith<$Res> {
  __$$UserProgressDataImplCopyWithImpl(_$UserProgressDataImpl _value,
      $Res Function(_$UserProgressDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProgressData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? totalWorkouts = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? totalPoints = null,
    Object? daysTrainedThisMonth = null,
    Object? workoutTypes = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$UserProgressDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      daysTrainedThisMonth: null == daysTrainedThisMonth
          ? _value.daysTrainedThisMonth
          : daysTrainedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      workoutTypes: null == workoutTypes
          ? _value._workoutTypes
          : workoutTypes // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressDataImpl implements _UserProgressData {
  const _$UserProgressDataImpl(
      {this.id = '',
      @JsonKey(name: 'user_id') this.userId = '',
      @JsonKey(name: 'total_workouts') this.totalWorkouts = 0,
      @JsonKey(name: 'current_streak') this.currentStreak = 0,
      @JsonKey(name: 'longest_streak') this.longestStreak = 0,
      @JsonKey(name: 'total_points') this.totalPoints = 0,
      @JsonKey(name: 'days_trained_this_month') this.daysTrainedThisMonth = 0,
      @JsonKey(name: 'workout_types')
      final Map<String, dynamic> workoutTypes = const {},
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : _workoutTypes = workoutTypes;

  factory _$UserProgressDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressDataImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'total_workouts')
  final int totalWorkouts;
  @override
  @JsonKey(name: 'current_streak')
  final int currentStreak;
  @override
  @JsonKey(name: 'longest_streak')
  final int longestStreak;
  @override
  @JsonKey(name: 'total_points')
  final int totalPoints;
  @override
  @JsonKey(name: 'days_trained_this_month')
  final int daysTrainedThisMonth;
  final Map<String, dynamic> _workoutTypes;
  @override
  @JsonKey(name: 'workout_types')
  Map<String, dynamic> get workoutTypes {
    if (_workoutTypes is EqualUnmodifiableMapView) return _workoutTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_workoutTypes);
  }

  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'UserProgressData(id: $id, userId: $userId, totalWorkouts: $totalWorkouts, currentStreak: $currentStreak, longestStreak: $longestStreak, totalPoints: $totalPoints, daysTrainedThisMonth: $daysTrainedThisMonth, workoutTypes: $workoutTypes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.daysTrainedThisMonth, daysTrainedThisMonth) ||
                other.daysTrainedThisMonth == daysTrainedThisMonth) &&
            const DeepCollectionEquality()
                .equals(other._workoutTypes, _workoutTypes) &&
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
      userId,
      totalWorkouts,
      currentStreak,
      longestStreak,
      totalPoints,
      daysTrainedThisMonth,
      const DeepCollectionEquality().hash(_workoutTypes),
      createdAt,
      updatedAt);

  /// Create a copy of UserProgressData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressDataImplCopyWith<_$UserProgressDataImpl> get copyWith =>
      __$$UserProgressDataImplCopyWithImpl<_$UserProgressDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressDataImplToJson(
      this,
    );
  }
}

abstract class _UserProgressData implements UserProgressData {
  const factory _UserProgressData(
      {final String id,
      @JsonKey(name: 'user_id') final String userId,
      @JsonKey(name: 'total_workouts') final int totalWorkouts,
      @JsonKey(name: 'current_streak') final int currentStreak,
      @JsonKey(name: 'longest_streak') final int longestStreak,
      @JsonKey(name: 'total_points') final int totalPoints,
      @JsonKey(name: 'days_trained_this_month') final int daysTrainedThisMonth,
      @JsonKey(name: 'workout_types') final Map<String, dynamic> workoutTypes,
      @JsonKey(name: 'created_at') required final DateTime createdAt,
      @JsonKey(name: 'updated_at')
      required final DateTime updatedAt}) = _$UserProgressDataImpl;

  factory _UserProgressData.fromJson(Map<String, dynamic> json) =
      _$UserProgressDataImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'total_workouts')
  int get totalWorkouts;
  @override
  @JsonKey(name: 'current_streak')
  int get currentStreak;
  @override
  @JsonKey(name: 'longest_streak')
  int get longestStreak;
  @override
  @JsonKey(name: 'total_points')
  int get totalPoints;
  @override
  @JsonKey(name: 'days_trained_this_month')
  int get daysTrainedThisMonth;
  @override
  @JsonKey(name: 'workout_types')
  Map<String, dynamic> get workoutTypes;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of UserProgressData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProgressDataImplCopyWith<_$UserProgressDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WaterIntakeData _$WaterIntakeDataFromJson(Map<String, dynamic> json) {
  return _WaterIntakeData.fromJson(json);
}

/// @nodoc
mixin _$WaterIntakeData {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  int get cups => throw _privateConstructorUsedError;
  int get goal => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WaterIntakeData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WaterIntakeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WaterIntakeDataCopyWith<WaterIntakeData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WaterIntakeDataCopyWith<$Res> {
  factory $WaterIntakeDataCopyWith(
          WaterIntakeData value, $Res Function(WaterIntakeData) then) =
      _$WaterIntakeDataCopyWithImpl<$Res, WaterIntakeData>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      DateTime date,
      int cups,
      int goal,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$WaterIntakeDataCopyWithImpl<$Res, $Val extends WaterIntakeData>
    implements $WaterIntakeDataCopyWith<$Res> {
  _$WaterIntakeDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WaterIntakeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? cups = null,
    Object? goal = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      cups: null == cups
          ? _value.cups
          : cups // ignore: cast_nullable_to_non_nullable
              as int,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WaterIntakeDataImplCopyWith<$Res>
    implements $WaterIntakeDataCopyWith<$Res> {
  factory _$$WaterIntakeDataImplCopyWith(_$WaterIntakeDataImpl value,
          $Res Function(_$WaterIntakeDataImpl) then) =
      __$$WaterIntakeDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      DateTime date,
      int cups,
      int goal,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$WaterIntakeDataImplCopyWithImpl<$Res>
    extends _$WaterIntakeDataCopyWithImpl<$Res, _$WaterIntakeDataImpl>
    implements _$$WaterIntakeDataImplCopyWith<$Res> {
  __$$WaterIntakeDataImplCopyWithImpl(
      _$WaterIntakeDataImpl _value, $Res Function(_$WaterIntakeDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of WaterIntakeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? cups = null,
    Object? goal = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$WaterIntakeDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      cups: null == cups
          ? _value.cups
          : cups // ignore: cast_nullable_to_non_nullable
              as int,
      goal: null == goal
          ? _value.goal
          : goal // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WaterIntakeDataImpl implements _WaterIntakeData {
  const _$WaterIntakeDataImpl(
      {this.id = '',
      @JsonKey(name: 'user_id') this.userId = '',
      required this.date,
      this.cups = 0,
      this.goal = 8,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$WaterIntakeDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$WaterIntakeDataImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final DateTime date;
  @override
  @JsonKey()
  final int cups;
  @override
  @JsonKey()
  final int goal;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'WaterIntakeData(id: $id, userId: $userId, date: $date, cups: $cups, goal: $goal, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WaterIntakeDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.cups, cups) || other.cups == cups) &&
            (identical(other.goal, goal) || other.goal == goal) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, date, cups, goal, createdAt, updatedAt);

  /// Create a copy of WaterIntakeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WaterIntakeDataImplCopyWith<_$WaterIntakeDataImpl> get copyWith =>
      __$$WaterIntakeDataImplCopyWithImpl<_$WaterIntakeDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WaterIntakeDataImplToJson(
      this,
    );
  }
}

abstract class _WaterIntakeData implements WaterIntakeData {
  const factory _WaterIntakeData(
          {final String id,
          @JsonKey(name: 'user_id') final String userId,
          required final DateTime date,
          final int cups,
          final int goal,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$WaterIntakeDataImpl;

  factory _WaterIntakeData.fromJson(Map<String, dynamic> json) =
      _$WaterIntakeDataImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  DateTime get date;
  @override
  int get cups;
  @override
  int get goal;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of WaterIntakeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WaterIntakeDataImplCopyWith<_$WaterIntakeDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GoalData _$GoalDataFromJson(Map<String, dynamic> json) {
  return _GoalData.fromJson(json);
}

/// @nodoc
mixin _$GoalData {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_value')
  double get currentValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'target_value')
  double get targetValue => throw _privateConstructorUsedError;
  String get unit => throw _privateConstructorUsedError;
  DateTime? get deadline => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_completed')
  bool get isCompleted => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this GoalData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoalData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoalDataCopyWith<GoalData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoalDataCopyWith<$Res> {
  factory $GoalDataCopyWith(GoalData value, $Res Function(GoalData) then) =
      _$GoalDataCopyWithImpl<$Res, GoalData>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      @JsonKey(name: 'current_value') double currentValue,
      @JsonKey(name: 'target_value') double targetValue,
      String unit,
      DateTime? deadline,
      @JsonKey(name: 'is_completed') bool isCompleted,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$GoalDataCopyWithImpl<$Res, $Val extends GoalData>
    implements $GoalDataCopyWith<$Res> {
  _$GoalDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoalData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? currentValue = null,
    Object? targetValue = null,
    Object? unit = null,
    Object? deadline = freezed,
    Object? isCompleted = null,
    Object? createdAt = null,
    Object? updatedAt = null,
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoalDataImplCopyWith<$Res>
    implements $GoalDataCopyWith<$Res> {
  factory _$$GoalDataImplCopyWith(
          _$GoalDataImpl value, $Res Function(_$GoalDataImpl) then) =
      __$$GoalDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String category,
      @JsonKey(name: 'current_value') double currentValue,
      @JsonKey(name: 'target_value') double targetValue,
      String unit,
      DateTime? deadline,
      @JsonKey(name: 'is_completed') bool isCompleted,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$GoalDataImplCopyWithImpl<$Res>
    extends _$GoalDataCopyWithImpl<$Res, _$GoalDataImpl>
    implements _$$GoalDataImplCopyWith<$Res> {
  __$$GoalDataImplCopyWithImpl(
      _$GoalDataImpl _value, $Res Function(_$GoalDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of GoalData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? category = null,
    Object? currentValue = null,
    Object? targetValue = null,
    Object? unit = null,
    Object? deadline = freezed,
    Object? isCompleted = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$GoalDataImpl(
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
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      currentValue: null == currentValue
          ? _value.currentValue
          : currentValue // ignore: cast_nullable_to_non_nullable
              as double,
      targetValue: null == targetValue
          ? _value.targetValue
          : targetValue // ignore: cast_nullable_to_non_nullable
              as double,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as String,
      deadline: freezed == deadline
          ? _value.deadline
          : deadline // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GoalDataImpl implements _GoalData {
  const _$GoalDataImpl(
      {this.id = '',
      this.title = '',
      this.description = '',
      this.category = '',
      @JsonKey(name: 'current_value') this.currentValue = 0,
      @JsonKey(name: 'target_value') this.targetValue = 0,
      this.unit = '',
      this.deadline,
      @JsonKey(name: 'is_completed') this.isCompleted = false,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$GoalDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoalDataImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey(name: 'current_value')
  final double currentValue;
  @override
  @JsonKey(name: 'target_value')
  final double targetValue;
  @override
  @JsonKey()
  final String unit;
  @override
  final DateTime? deadline;
  @override
  @JsonKey(name: 'is_completed')
  final bool isCompleted;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'GoalData(id: $id, title: $title, description: $description, category: $category, currentValue: $currentValue, targetValue: $targetValue, unit: $unit, deadline: $deadline, isCompleted: $isCompleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoalDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.currentValue, currentValue) ||
                other.currentValue == currentValue) &&
            (identical(other.targetValue, targetValue) ||
                other.targetValue == targetValue) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.deadline, deadline) ||
                other.deadline == deadline) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
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
      category,
      currentValue,
      targetValue,
      unit,
      deadline,
      isCompleted,
      createdAt,
      updatedAt);

  /// Create a copy of GoalData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoalDataImplCopyWith<_$GoalDataImpl> get copyWith =>
      __$$GoalDataImplCopyWithImpl<_$GoalDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoalDataImplToJson(
      this,
    );
  }
}

abstract class _GoalData implements GoalData {
  const factory _GoalData(
          {final String id,
          final String title,
          final String description,
          final String category,
          @JsonKey(name: 'current_value') final double currentValue,
          @JsonKey(name: 'target_value') final double targetValue,
          final String unit,
          final DateTime? deadline,
          @JsonKey(name: 'is_completed') final bool isCompleted,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$GoalDataImpl;

  factory _GoalData.fromJson(Map<String, dynamic> json) =
      _$GoalDataImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  String get category;
  @override
  @JsonKey(name: 'current_value')
  double get currentValue;
  @override
  @JsonKey(name: 'target_value')
  double get targetValue;
  @override
  String get unit;
  @override
  DateTime? get deadline;
  @override
  @JsonKey(name: 'is_completed')
  bool get isCompleted;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of GoalData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoalDataImplCopyWith<_$GoalDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RecentWorkoutData _$RecentWorkoutDataFromJson(Map<String, dynamic> json) {
  return _RecentWorkoutData.fromJson(json);
}

/// @nodoc
mixin _$RecentWorkoutData {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'workout_name')
  String get workoutName => throw _privateConstructorUsedError;
  @JsonKey(name: 'workout_type')
  String get workoutType => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_completed')
  bool get isCompleted => throw _privateConstructorUsedError;

  /// Serializes this RecentWorkoutData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RecentWorkoutData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecentWorkoutDataCopyWith<RecentWorkoutData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecentWorkoutDataCopyWith<$Res> {
  factory $RecentWorkoutDataCopyWith(
          RecentWorkoutData value, $Res Function(RecentWorkoutData) then) =
      _$RecentWorkoutDataCopyWithImpl<$Res, RecentWorkoutData>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'workout_name') String workoutName,
      @JsonKey(name: 'workout_type') String workoutType,
      DateTime date,
      @JsonKey(name: 'duration_minutes') int durationMinutes,
      @JsonKey(name: 'is_completed') bool isCompleted});
}

/// @nodoc
class _$RecentWorkoutDataCopyWithImpl<$Res, $Val extends RecentWorkoutData>
    implements $RecentWorkoutDataCopyWith<$Res> {
  _$RecentWorkoutDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecentWorkoutData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutName = null,
    Object? workoutType = null,
    Object? date = null,
    Object? durationMinutes = null,
    Object? isCompleted = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      workoutType: null == workoutType
          ? _value.workoutType
          : workoutType // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RecentWorkoutDataImplCopyWith<$Res>
    implements $RecentWorkoutDataCopyWith<$Res> {
  factory _$$RecentWorkoutDataImplCopyWith(_$RecentWorkoutDataImpl value,
          $Res Function(_$RecentWorkoutDataImpl) then) =
      __$$RecentWorkoutDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'workout_name') String workoutName,
      @JsonKey(name: 'workout_type') String workoutType,
      DateTime date,
      @JsonKey(name: 'duration_minutes') int durationMinutes,
      @JsonKey(name: 'is_completed') bool isCompleted});
}

/// @nodoc
class __$$RecentWorkoutDataImplCopyWithImpl<$Res>
    extends _$RecentWorkoutDataCopyWithImpl<$Res, _$RecentWorkoutDataImpl>
    implements _$$RecentWorkoutDataImplCopyWith<$Res> {
  __$$RecentWorkoutDataImplCopyWithImpl(_$RecentWorkoutDataImpl _value,
      $Res Function(_$RecentWorkoutDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of RecentWorkoutData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? workoutName = null,
    Object? workoutType = null,
    Object? date = null,
    Object? durationMinutes = null,
    Object? isCompleted = null,
  }) {
    return _then(_$RecentWorkoutDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      workoutName: null == workoutName
          ? _value.workoutName
          : workoutName // ignore: cast_nullable_to_non_nullable
              as String,
      workoutType: null == workoutType
          ? _value.workoutType
          : workoutType // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RecentWorkoutDataImpl implements _RecentWorkoutData {
  const _$RecentWorkoutDataImpl(
      {this.id = '',
      @JsonKey(name: 'workout_name') this.workoutName = '',
      @JsonKey(name: 'workout_type') this.workoutType = '',
      required this.date,
      @JsonKey(name: 'duration_minutes') this.durationMinutes = 0,
      @JsonKey(name: 'is_completed') this.isCompleted = false});

  factory _$RecentWorkoutDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$RecentWorkoutDataImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(name: 'workout_name')
  final String workoutName;
  @override
  @JsonKey(name: 'workout_type')
  final String workoutType;
  @override
  final DateTime date;
  @override
  @JsonKey(name: 'duration_minutes')
  final int durationMinutes;
  @override
  @JsonKey(name: 'is_completed')
  final bool isCompleted;

  @override
  String toString() {
    return 'RecentWorkoutData(id: $id, workoutName: $workoutName, workoutType: $workoutType, date: $date, durationMinutes: $durationMinutes, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecentWorkoutDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.workoutName, workoutName) ||
                other.workoutName == workoutName) &&
            (identical(other.workoutType, workoutType) ||
                other.workoutType == workoutType) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, workoutName, workoutType,
      date, durationMinutes, isCompleted);

  /// Create a copy of RecentWorkoutData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecentWorkoutDataImplCopyWith<_$RecentWorkoutDataImpl> get copyWith =>
      __$$RecentWorkoutDataImplCopyWithImpl<_$RecentWorkoutDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RecentWorkoutDataImplToJson(
      this,
    );
  }
}

abstract class _RecentWorkoutData implements RecentWorkoutData {
  const factory _RecentWorkoutData(
          {final String id,
          @JsonKey(name: 'workout_name') final String workoutName,
          @JsonKey(name: 'workout_type') final String workoutType,
          required final DateTime date,
          @JsonKey(name: 'duration_minutes') final int durationMinutes,
          @JsonKey(name: 'is_completed') final bool isCompleted}) =
      _$RecentWorkoutDataImpl;

  factory _RecentWorkoutData.fromJson(Map<String, dynamic> json) =
      _$RecentWorkoutDataImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'workout_name')
  String get workoutName;
  @override
  @JsonKey(name: 'workout_type')
  String get workoutType;
  @override
  DateTime get date;
  @override
  @JsonKey(name: 'duration_minutes')
  int get durationMinutes;
  @override
  @JsonKey(name: 'is_completed')
  bool get isCompleted;

  /// Create a copy of RecentWorkoutData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecentWorkoutDataImplCopyWith<_$RecentWorkoutDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChallengeData _$ChallengeDataFromJson(Map<String, dynamic> json) {
  return _ChallengeData.fromJson(json);
}

/// @nodoc
mixin _$ChallengeData {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime get endDate => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_official')
  bool get isOfficial => throw _privateConstructorUsedError;
  @JsonKey(name: 'days_remaining')
  int get daysRemaining => throw _privateConstructorUsedError;

  /// Serializes this ChallengeData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeDataCopyWith<ChallengeData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeDataCopyWith<$Res> {
  factory $ChallengeDataCopyWith(
          ChallengeData value, $Res Function(ChallengeData) then) =
      _$ChallengeDataCopyWithImpl<$Res, ChallengeData>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime endDate,
      int points,
      String type,
      @JsonKey(name: 'is_official') bool isOfficial,
      @JsonKey(name: 'days_remaining') int daysRemaining});
}

/// @nodoc
class _$ChallengeDataCopyWithImpl<$Res, $Val extends ChallengeData>
    implements $ChallengeDataCopyWith<$Res> {
  _$ChallengeDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? points = null,
    Object? type = null,
    Object? isOfficial = null,
    Object? daysRemaining = null,
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
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      daysRemaining: null == daysRemaining
          ? _value.daysRemaining
          : daysRemaining // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeDataImplCopyWith<$Res>
    implements $ChallengeDataCopyWith<$Res> {
  factory _$$ChallengeDataImplCopyWith(
          _$ChallengeDataImpl value, $Res Function(_$ChallengeDataImpl) then) =
      __$$ChallengeDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'start_date') DateTime startDate,
      @JsonKey(name: 'end_date') DateTime endDate,
      int points,
      String type,
      @JsonKey(name: 'is_official') bool isOfficial,
      @JsonKey(name: 'days_remaining') int daysRemaining});
}

/// @nodoc
class __$$ChallengeDataImplCopyWithImpl<$Res>
    extends _$ChallengeDataCopyWithImpl<$Res, _$ChallengeDataImpl>
    implements _$$ChallengeDataImplCopyWith<$Res> {
  __$$ChallengeDataImplCopyWithImpl(
      _$ChallengeDataImpl _value, $Res Function(_$ChallengeDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? points = null,
    Object? type = null,
    Object? isOfficial = null,
    Object? daysRemaining = null,
  }) {
    return _then(_$ChallengeDataImpl(
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
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      isOfficial: null == isOfficial
          ? _value.isOfficial
          : isOfficial // ignore: cast_nullable_to_non_nullable
              as bool,
      daysRemaining: null == daysRemaining
          ? _value.daysRemaining
          : daysRemaining // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeDataImpl implements _ChallengeData {
  const _$ChallengeDataImpl(
      {this.id = '',
      this.title = '',
      this.description = '',
      @JsonKey(name: 'image_url') this.imageUrl,
      @JsonKey(name: 'start_date') required this.startDate,
      @JsonKey(name: 'end_date') required this.endDate,
      this.points = 0,
      this.type = '',
      @JsonKey(name: 'is_official') this.isOfficial = false,
      @JsonKey(name: 'days_remaining') this.daysRemaining = 0});

  factory _$ChallengeDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeDataImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  @override
  @JsonKey()
  final int points;
  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey(name: 'is_official')
  final bool isOfficial;
  @override
  @JsonKey(name: 'days_remaining')
  final int daysRemaining;

  @override
  String toString() {
    return 'ChallengeData(id: $id, title: $title, description: $description, imageUrl: $imageUrl, startDate: $startDate, endDate: $endDate, points: $points, type: $type, isOfficial: $isOfficial, daysRemaining: $daysRemaining)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isOfficial, isOfficial) ||
                other.isOfficial == isOfficial) &&
            (identical(other.daysRemaining, daysRemaining) ||
                other.daysRemaining == daysRemaining));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, imageUrl,
      startDate, endDate, points, type, isOfficial, daysRemaining);

  /// Create a copy of ChallengeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeDataImplCopyWith<_$ChallengeDataImpl> get copyWith =>
      __$$ChallengeDataImplCopyWithImpl<_$ChallengeDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeDataImplToJson(
      this,
    );
  }
}

abstract class _ChallengeData implements ChallengeData {
  const factory _ChallengeData(
          {final String id,
          final String title,
          final String description,
          @JsonKey(name: 'image_url') final String? imageUrl,
          @JsonKey(name: 'start_date') required final DateTime startDate,
          @JsonKey(name: 'end_date') required final DateTime endDate,
          final int points,
          final String type,
          @JsonKey(name: 'is_official') final bool isOfficial,
          @JsonKey(name: 'days_remaining') final int daysRemaining}) =
      _$ChallengeDataImpl;

  factory _ChallengeData.fromJson(Map<String, dynamic> json) =
      _$ChallengeDataImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime get endDate;
  @override
  int get points;
  @override
  String get type;
  @override
  @JsonKey(name: 'is_official')
  bool get isOfficial;
  @override
  @JsonKey(name: 'days_remaining')
  int get daysRemaining;

  /// Create a copy of ChallengeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeDataImplCopyWith<_$ChallengeDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChallengeProgressData _$ChallengeProgressDataFromJson(
    Map<String, dynamic> json) {
  return _ChallengeProgressData.fromJson(json);
}

/// @nodoc
mixin _$ChallengeProgressData {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'challenge_id')
  String get challengeId => throw _privateConstructorUsedError;
  int get points => throw _privateConstructorUsedError;
  int get position => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_check_ins')
  int get totalCheckIns => throw _privateConstructorUsedError;
  @JsonKey(name: 'consecutive_days')
  int get consecutiveDays => throw _privateConstructorUsedError;
  @JsonKey(name: 'completion_percentage')
  double get completionPercentage => throw _privateConstructorUsedError;

  /// Serializes this ChallengeProgressData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeProgressData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeProgressDataCopyWith<ChallengeProgressData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeProgressDataCopyWith<$Res> {
  factory $ChallengeProgressDataCopyWith(ChallengeProgressData value,
          $Res Function(ChallengeProgressData) then) =
      _$ChallengeProgressDataCopyWithImpl<$Res, ChallengeProgressData>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'challenge_id') String challengeId,
      int points,
      int position,
      @JsonKey(name: 'total_check_ins') int totalCheckIns,
      @JsonKey(name: 'consecutive_days') int consecutiveDays,
      @JsonKey(name: 'completion_percentage') double completionPercentage});
}

/// @nodoc
class _$ChallengeProgressDataCopyWithImpl<$Res,
        $Val extends ChallengeProgressData>
    implements $ChallengeProgressDataCopyWith<$Res> {
  _$ChallengeProgressDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChallengeProgressData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? challengeId = null,
    Object? points = null,
    Object? position = null,
    Object? totalCheckIns = null,
    Object? consecutiveDays = null,
    Object? completionPercentage = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      totalCheckIns: null == totalCheckIns
          ? _value.totalCheckIns
          : totalCheckIns // ignore: cast_nullable_to_non_nullable
              as int,
      consecutiveDays: null == consecutiveDays
          ? _value.consecutiveDays
          : consecutiveDays // ignore: cast_nullable_to_non_nullable
              as int,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChallengeProgressDataImplCopyWith<$Res>
    implements $ChallengeProgressDataCopyWith<$Res> {
  factory _$$ChallengeProgressDataImplCopyWith(
          _$ChallengeProgressDataImpl value,
          $Res Function(_$ChallengeProgressDataImpl) then) =
      __$$ChallengeProgressDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      @JsonKey(name: 'challenge_id') String challengeId,
      int points,
      int position,
      @JsonKey(name: 'total_check_ins') int totalCheckIns,
      @JsonKey(name: 'consecutive_days') int consecutiveDays,
      @JsonKey(name: 'completion_percentage') double completionPercentage});
}

/// @nodoc
class __$$ChallengeProgressDataImplCopyWithImpl<$Res>
    extends _$ChallengeProgressDataCopyWithImpl<$Res,
        _$ChallengeProgressDataImpl>
    implements _$$ChallengeProgressDataImplCopyWith<$Res> {
  __$$ChallengeProgressDataImplCopyWithImpl(_$ChallengeProgressDataImpl _value,
      $Res Function(_$ChallengeProgressDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChallengeProgressData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? challengeId = null,
    Object? points = null,
    Object? position = null,
    Object? totalCheckIns = null,
    Object? consecutiveDays = null,
    Object? completionPercentage = null,
  }) {
    return _then(_$ChallengeProgressDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      challengeId: null == challengeId
          ? _value.challengeId
          : challengeId // ignore: cast_nullable_to_non_nullable
              as String,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      position: null == position
          ? _value.position
          : position // ignore: cast_nullable_to_non_nullable
              as int,
      totalCheckIns: null == totalCheckIns
          ? _value.totalCheckIns
          : totalCheckIns // ignore: cast_nullable_to_non_nullable
              as int,
      consecutiveDays: null == consecutiveDays
          ? _value.consecutiveDays
          : consecutiveDays // ignore: cast_nullable_to_non_nullable
              as int,
      completionPercentage: null == completionPercentage
          ? _value.completionPercentage
          : completionPercentage // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChallengeProgressDataImpl implements _ChallengeProgressData {
  const _$ChallengeProgressDataImpl(
      {this.id = '',
      @JsonKey(name: 'user_id') this.userId = '',
      @JsonKey(name: 'challenge_id') this.challengeId = '',
      this.points = 0,
      this.position = 0,
      @JsonKey(name: 'total_check_ins') this.totalCheckIns = 0,
      @JsonKey(name: 'consecutive_days') this.consecutiveDays = 0,
      @JsonKey(name: 'completion_percentage') this.completionPercentage = 0.0});

  factory _$ChallengeProgressDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChallengeProgressDataImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'challenge_id')
  final String challengeId;
  @override
  @JsonKey()
  final int points;
  @override
  @JsonKey()
  final int position;
  @override
  @JsonKey(name: 'total_check_ins')
  final int totalCheckIns;
  @override
  @JsonKey(name: 'consecutive_days')
  final int consecutiveDays;
  @override
  @JsonKey(name: 'completion_percentage')
  final double completionPercentage;

  @override
  String toString() {
    return 'ChallengeProgressData(id: $id, userId: $userId, challengeId: $challengeId, points: $points, position: $position, totalCheckIns: $totalCheckIns, consecutiveDays: $consecutiveDays, completionPercentage: $completionPercentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChallengeProgressDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.challengeId, challengeId) ||
                other.challengeId == challengeId) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.totalCheckIns, totalCheckIns) ||
                other.totalCheckIns == totalCheckIns) &&
            (identical(other.consecutiveDays, consecutiveDays) ||
                other.consecutiveDays == consecutiveDays) &&
            (identical(other.completionPercentage, completionPercentage) ||
                other.completionPercentage == completionPercentage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, challengeId, points,
      position, totalCheckIns, consecutiveDays, completionPercentage);

  /// Create a copy of ChallengeProgressData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeProgressDataImplCopyWith<_$ChallengeProgressDataImpl>
      get copyWith => __$$ChallengeProgressDataImplCopyWithImpl<
          _$ChallengeProgressDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChallengeProgressDataImplToJson(
      this,
    );
  }
}

abstract class _ChallengeProgressData implements ChallengeProgressData {
  const factory _ChallengeProgressData(
      {final String id,
      @JsonKey(name: 'user_id') final String userId,
      @JsonKey(name: 'challenge_id') final String challengeId,
      final int points,
      final int position,
      @JsonKey(name: 'total_check_ins') final int totalCheckIns,
      @JsonKey(name: 'consecutive_days') final int consecutiveDays,
      @JsonKey(name: 'completion_percentage')
      final double completionPercentage}) = _$ChallengeProgressDataImpl;

  factory _ChallengeProgressData.fromJson(Map<String, dynamic> json) =
      _$ChallengeProgressDataImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'challenge_id')
  String get challengeId;
  @override
  int get points;
  @override
  int get position;
  @override
  @JsonKey(name: 'total_check_ins')
  int get totalCheckIns;
  @override
  @JsonKey(name: 'consecutive_days')
  int get consecutiveDays;
  @override
  @JsonKey(name: 'completion_percentage')
  double get completionPercentage;

  /// Create a copy of ChallengeProgressData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeProgressDataImplCopyWith<_$ChallengeProgressDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RedeemedBenefitData _$RedeemedBenefitDataFromJson(Map<String, dynamic> json) {
  return _RedeemedBenefitData.fromJson(json);
}

/// @nodoc
mixin _$RedeemedBenefitData {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'benefit_id')
  String get benefitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'benefit_title')
  String get benefitTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'benefit_image_url')
  String? get benefitImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'redeemed_at')
  DateTime get redeemedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'expiration_date')
  DateTime? get expirationDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'redemption_code')
  String get redemptionCode => throw _privateConstructorUsedError;

  /// Serializes this RedeemedBenefitData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RedeemedBenefitData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RedeemedBenefitDataCopyWith<RedeemedBenefitData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RedeemedBenefitDataCopyWith<$Res> {
  factory $RedeemedBenefitDataCopyWith(
          RedeemedBenefitData value, $Res Function(RedeemedBenefitData) then) =
      _$RedeemedBenefitDataCopyWithImpl<$Res, RedeemedBenefitData>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'benefit_id') String benefitId,
      @JsonKey(name: 'benefit_title') String benefitTitle,
      @JsonKey(name: 'benefit_image_url') String? benefitImageUrl,
      @JsonKey(name: 'redeemed_at') DateTime redeemedAt,
      @JsonKey(name: 'expiration_date') DateTime? expirationDate,
      @JsonKey(name: 'redemption_code') String redemptionCode});
}

/// @nodoc
class _$RedeemedBenefitDataCopyWithImpl<$Res, $Val extends RedeemedBenefitData>
    implements $RedeemedBenefitDataCopyWith<$Res> {
  _$RedeemedBenefitDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RedeemedBenefitData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? benefitId = null,
    Object? benefitTitle = null,
    Object? benefitImageUrl = freezed,
    Object? redeemedAt = null,
    Object? expirationDate = freezed,
    Object? redemptionCode = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      benefitId: null == benefitId
          ? _value.benefitId
          : benefitId // ignore: cast_nullable_to_non_nullable
              as String,
      benefitTitle: null == benefitTitle
          ? _value.benefitTitle
          : benefitTitle // ignore: cast_nullable_to_non_nullable
              as String,
      benefitImageUrl: freezed == benefitImageUrl
          ? _value.benefitImageUrl
          : benefitImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      redeemedAt: null == redeemedAt
          ? _value.redeemedAt
          : redeemedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expirationDate: freezed == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      redemptionCode: null == redemptionCode
          ? _value.redemptionCode
          : redemptionCode // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RedeemedBenefitDataImplCopyWith<$Res>
    implements $RedeemedBenefitDataCopyWith<$Res> {
  factory _$$RedeemedBenefitDataImplCopyWith(_$RedeemedBenefitDataImpl value,
          $Res Function(_$RedeemedBenefitDataImpl) then) =
      __$$RedeemedBenefitDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'benefit_id') String benefitId,
      @JsonKey(name: 'benefit_title') String benefitTitle,
      @JsonKey(name: 'benefit_image_url') String? benefitImageUrl,
      @JsonKey(name: 'redeemed_at') DateTime redeemedAt,
      @JsonKey(name: 'expiration_date') DateTime? expirationDate,
      @JsonKey(name: 'redemption_code') String redemptionCode});
}

/// @nodoc
class __$$RedeemedBenefitDataImplCopyWithImpl<$Res>
    extends _$RedeemedBenefitDataCopyWithImpl<$Res, _$RedeemedBenefitDataImpl>
    implements _$$RedeemedBenefitDataImplCopyWith<$Res> {
  __$$RedeemedBenefitDataImplCopyWithImpl(_$RedeemedBenefitDataImpl _value,
      $Res Function(_$RedeemedBenefitDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of RedeemedBenefitData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? benefitId = null,
    Object? benefitTitle = null,
    Object? benefitImageUrl = freezed,
    Object? redeemedAt = null,
    Object? expirationDate = freezed,
    Object? redemptionCode = null,
  }) {
    return _then(_$RedeemedBenefitDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      benefitId: null == benefitId
          ? _value.benefitId
          : benefitId // ignore: cast_nullable_to_non_nullable
              as String,
      benefitTitle: null == benefitTitle
          ? _value.benefitTitle
          : benefitTitle // ignore: cast_nullable_to_non_nullable
              as String,
      benefitImageUrl: freezed == benefitImageUrl
          ? _value.benefitImageUrl
          : benefitImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      redeemedAt: null == redeemedAt
          ? _value.redeemedAt
          : redeemedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expirationDate: freezed == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      redemptionCode: null == redemptionCode
          ? _value.redemptionCode
          : redemptionCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RedeemedBenefitDataImpl implements _RedeemedBenefitData {
  const _$RedeemedBenefitDataImpl(
      {this.id = '',
      @JsonKey(name: 'benefit_id') this.benefitId = '',
      @JsonKey(name: 'benefit_title') this.benefitTitle = '',
      @JsonKey(name: 'benefit_image_url') this.benefitImageUrl,
      @JsonKey(name: 'redeemed_at') required this.redeemedAt,
      @JsonKey(name: 'expiration_date') this.expirationDate,
      @JsonKey(name: 'redemption_code') this.redemptionCode = ''});

  factory _$RedeemedBenefitDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$RedeemedBenefitDataImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(name: 'benefit_id')
  final String benefitId;
  @override
  @JsonKey(name: 'benefit_title')
  final String benefitTitle;
  @override
  @JsonKey(name: 'benefit_image_url')
  final String? benefitImageUrl;
  @override
  @JsonKey(name: 'redeemed_at')
  final DateTime redeemedAt;
  @override
  @JsonKey(name: 'expiration_date')
  final DateTime? expirationDate;
  @override
  @JsonKey(name: 'redemption_code')
  final String redemptionCode;

  @override
  String toString() {
    return 'RedeemedBenefitData(id: $id, benefitId: $benefitId, benefitTitle: $benefitTitle, benefitImageUrl: $benefitImageUrl, redeemedAt: $redeemedAt, expirationDate: $expirationDate, redemptionCode: $redemptionCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RedeemedBenefitDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.benefitId, benefitId) ||
                other.benefitId == benefitId) &&
            (identical(other.benefitTitle, benefitTitle) ||
                other.benefitTitle == benefitTitle) &&
            (identical(other.benefitImageUrl, benefitImageUrl) ||
                other.benefitImageUrl == benefitImageUrl) &&
            (identical(other.redeemedAt, redeemedAt) ||
                other.redeemedAt == redeemedAt) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.redemptionCode, redemptionCode) ||
                other.redemptionCode == redemptionCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, benefitId, benefitTitle,
      benefitImageUrl, redeemedAt, expirationDate, redemptionCode);

  /// Create a copy of RedeemedBenefitData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RedeemedBenefitDataImplCopyWith<_$RedeemedBenefitDataImpl> get copyWith =>
      __$$RedeemedBenefitDataImplCopyWithImpl<_$RedeemedBenefitDataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RedeemedBenefitDataImplToJson(
      this,
    );
  }
}

abstract class _RedeemedBenefitData implements RedeemedBenefitData {
  const factory _RedeemedBenefitData(
          {final String id,
          @JsonKey(name: 'benefit_id') final String benefitId,
          @JsonKey(name: 'benefit_title') final String benefitTitle,
          @JsonKey(name: 'benefit_image_url') final String? benefitImageUrl,
          @JsonKey(name: 'redeemed_at') required final DateTime redeemedAt,
          @JsonKey(name: 'expiration_date') final DateTime? expirationDate,
          @JsonKey(name: 'redemption_code') final String redemptionCode}) =
      _$RedeemedBenefitDataImpl;

  factory _RedeemedBenefitData.fromJson(Map<String, dynamic> json) =
      _$RedeemedBenefitDataImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'benefit_id')
  String get benefitId;
  @override
  @JsonKey(name: 'benefit_title')
  String get benefitTitle;
  @override
  @JsonKey(name: 'benefit_image_url')
  String? get benefitImageUrl;
  @override
  @JsonKey(name: 'redeemed_at')
  DateTime get redeemedAt;
  @override
  @JsonKey(name: 'expiration_date')
  DateTime? get expirationDate;
  @override
  @JsonKey(name: 'redemption_code')
  String get redemptionCode;

  /// Create a copy of RedeemedBenefitData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RedeemedBenefitDataImplCopyWith<_$RedeemedBenefitDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NutritionData _$NutritionDataFromJson(Map<String, dynamic> json) {
  return _NutritionData.fromJson(json);
}

/// @nodoc
mixin _$NutritionData {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  @JsonKey(name: 'calories_consumed')
  int get caloriesConsumed => throw _privateConstructorUsedError;
  @JsonKey(name: 'calories_goal')
  int get caloriesGoal => throw _privateConstructorUsedError;
  double get proteins => throw _privateConstructorUsedError;
  double get carbs => throw _privateConstructorUsedError;
  double get fats => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this NutritionData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NutritionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NutritionDataCopyWith<NutritionData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NutritionDataCopyWith<$Res> {
  factory $NutritionDataCopyWith(
          NutritionData value, $Res Function(NutritionData) then) =
      _$NutritionDataCopyWithImpl<$Res, NutritionData>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      DateTime date,
      @JsonKey(name: 'calories_consumed') int caloriesConsumed,
      @JsonKey(name: 'calories_goal') int caloriesGoal,
      double proteins,
      double carbs,
      double fats,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class _$NutritionDataCopyWithImpl<$Res, $Val extends NutritionData>
    implements $NutritionDataCopyWith<$Res> {
  _$NutritionDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NutritionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? caloriesConsumed = null,
    Object? caloriesGoal = null,
    Object? proteins = null,
    Object? carbs = null,
    Object? fats = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      caloriesConsumed: null == caloriesConsumed
          ? _value.caloriesConsumed
          : caloriesConsumed // ignore: cast_nullable_to_non_nullable
              as int,
      caloriesGoal: null == caloriesGoal
          ? _value.caloriesGoal
          : caloriesGoal // ignore: cast_nullable_to_non_nullable
              as int,
      proteins: null == proteins
          ? _value.proteins
          : proteins // ignore: cast_nullable_to_non_nullable
              as double,
      carbs: null == carbs
          ? _value.carbs
          : carbs // ignore: cast_nullable_to_non_nullable
              as double,
      fats: null == fats
          ? _value.fats
          : fats // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NutritionDataImplCopyWith<$Res>
    implements $NutritionDataCopyWith<$Res> {
  factory _$$NutritionDataImplCopyWith(
          _$NutritionDataImpl value, $Res Function(_$NutritionDataImpl) then) =
      __$$NutritionDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'user_id') String userId,
      DateTime date,
      @JsonKey(name: 'calories_consumed') int caloriesConsumed,
      @JsonKey(name: 'calories_goal') int caloriesGoal,
      double proteins,
      double carbs,
      double fats,
      @JsonKey(name: 'created_at') DateTime createdAt,
      @JsonKey(name: 'updated_at') DateTime updatedAt});
}

/// @nodoc
class __$$NutritionDataImplCopyWithImpl<$Res>
    extends _$NutritionDataCopyWithImpl<$Res, _$NutritionDataImpl>
    implements _$$NutritionDataImplCopyWith<$Res> {
  __$$NutritionDataImplCopyWithImpl(
      _$NutritionDataImpl _value, $Res Function(_$NutritionDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of NutritionData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? caloriesConsumed = null,
    Object? caloriesGoal = null,
    Object? proteins = null,
    Object? carbs = null,
    Object? fats = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$NutritionDataImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      caloriesConsumed: null == caloriesConsumed
          ? _value.caloriesConsumed
          : caloriesConsumed // ignore: cast_nullable_to_non_nullable
              as int,
      caloriesGoal: null == caloriesGoal
          ? _value.caloriesGoal
          : caloriesGoal // ignore: cast_nullable_to_non_nullable
              as int,
      proteins: null == proteins
          ? _value.proteins
          : proteins // ignore: cast_nullable_to_non_nullable
              as double,
      carbs: null == carbs
          ? _value.carbs
          : carbs // ignore: cast_nullable_to_non_nullable
              as double,
      fats: null == fats
          ? _value.fats
          : fats // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NutritionDataImpl implements _NutritionData {
  const _$NutritionDataImpl(
      {this.id = '',
      @JsonKey(name: 'user_id') this.userId = '',
      required this.date,
      @JsonKey(name: 'calories_consumed') this.caloriesConsumed = 0,
      @JsonKey(name: 'calories_goal') this.caloriesGoal = 2000,
      this.proteins = 0.0,
      this.carbs = 0.0,
      this.fats = 0.0,
      @JsonKey(name: 'created_at') required this.createdAt,
      @JsonKey(name: 'updated_at') required this.updatedAt});

  factory _$NutritionDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$NutritionDataImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final DateTime date;
  @override
  @JsonKey(name: 'calories_consumed')
  final int caloriesConsumed;
  @override
  @JsonKey(name: 'calories_goal')
  final int caloriesGoal;
  @override
  @JsonKey()
  final double proteins;
  @override
  @JsonKey()
  final double carbs;
  @override
  @JsonKey()
  final double fats;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @override
  String toString() {
    return 'NutritionData(id: $id, userId: $userId, date: $date, caloriesConsumed: $caloriesConsumed, caloriesGoal: $caloriesGoal, proteins: $proteins, carbs: $carbs, fats: $fats, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NutritionDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.caloriesConsumed, caloriesConsumed) ||
                other.caloriesConsumed == caloriesConsumed) &&
            (identical(other.caloriesGoal, caloriesGoal) ||
                other.caloriesGoal == caloriesGoal) &&
            (identical(other.proteins, proteins) ||
                other.proteins == proteins) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fats, fats) || other.fats == fats) &&
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
      userId,
      date,
      caloriesConsumed,
      caloriesGoal,
      proteins,
      carbs,
      fats,
      createdAt,
      updatedAt);

  /// Create a copy of NutritionData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NutritionDataImplCopyWith<_$NutritionDataImpl> get copyWith =>
      __$$NutritionDataImplCopyWithImpl<_$NutritionDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NutritionDataImplToJson(
      this,
    );
  }
}

abstract class _NutritionData implements NutritionData {
  const factory _NutritionData(
          {final String id,
          @JsonKey(name: 'user_id') final String userId,
          required final DateTime date,
          @JsonKey(name: 'calories_consumed') final int caloriesConsumed,
          @JsonKey(name: 'calories_goal') final int caloriesGoal,
          final double proteins,
          final double carbs,
          final double fats,
          @JsonKey(name: 'created_at') required final DateTime createdAt,
          @JsonKey(name: 'updated_at') required final DateTime updatedAt}) =
      _$NutritionDataImpl;

  factory _NutritionData.fromJson(Map<String, dynamic> json) =
      _$NutritionDataImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  DateTime get date;
  @override
  @JsonKey(name: 'calories_consumed')
  int get caloriesConsumed;
  @override
  @JsonKey(name: 'calories_goal')
  int get caloriesGoal;
  @override
  double get proteins;
  @override
  double get carbs;
  @override
  double get fats;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;

  /// Create a copy of NutritionData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NutritionDataImplCopyWith<_$NutritionDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
