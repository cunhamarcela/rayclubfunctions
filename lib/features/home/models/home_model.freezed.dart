// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HomeData _$HomeDataFromJson(Map<String, dynamic> json) {
  return _HomeData.fromJson(json);
}

/// @nodoc
mixin _$HomeData {
  /// Banner atual em destaque
  BannerItem get activeBanner => throw _privateConstructorUsedError;

  /// Lista de banners disponíveis para rotação
  List<BannerItem> get banners => throw _privateConstructorUsedError;

  /// Indicadores de progresso do usuário
  UserProgress get progress => throw _privateConstructorUsedError;

  /// Categorias de treino disponíveis
  List<WorkoutCategory> get categories => throw _privateConstructorUsedError;

  /// Treinos populares para exibição
  List<PopularWorkout> get popularWorkouts =>
      throw _privateConstructorUsedError;

  /// Data da última atualização
  DateTime get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this HomeData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeDataCopyWith<HomeData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeDataCopyWith<$Res> {
  factory $HomeDataCopyWith(HomeData value, $Res Function(HomeData) then) =
      _$HomeDataCopyWithImpl<$Res, HomeData>;
  @useResult
  $Res call(
      {BannerItem activeBanner,
      List<BannerItem> banners,
      UserProgress progress,
      List<WorkoutCategory> categories,
      List<PopularWorkout> popularWorkouts,
      DateTime lastUpdated});

  $BannerItemCopyWith<$Res> get activeBanner;
  $UserProgressCopyWith<$Res> get progress;
}

/// @nodoc
class _$HomeDataCopyWithImpl<$Res, $Val extends HomeData>
    implements $HomeDataCopyWith<$Res> {
  _$HomeDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeBanner = null,
    Object? banners = null,
    Object? progress = null,
    Object? categories = null,
    Object? popularWorkouts = null,
    Object? lastUpdated = null,
  }) {
    return _then(_value.copyWith(
      activeBanner: null == activeBanner
          ? _value.activeBanner
          : activeBanner // ignore: cast_nullable_to_non_nullable
              as BannerItem,
      banners: null == banners
          ? _value.banners
          : banners // ignore: cast_nullable_to_non_nullable
              as List<BannerItem>,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as UserProgress,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<WorkoutCategory>,
      popularWorkouts: null == popularWorkouts
          ? _value.popularWorkouts
          : popularWorkouts // ignore: cast_nullable_to_non_nullable
              as List<PopularWorkout>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BannerItemCopyWith<$Res> get activeBanner {
    return $BannerItemCopyWith<$Res>(_value.activeBanner, (value) {
      return _then(_value.copyWith(activeBanner: value) as $Val);
    });
  }

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProgressCopyWith<$Res> get progress {
    return $UserProgressCopyWith<$Res>(_value.progress, (value) {
      return _then(_value.copyWith(progress: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeDataImplCopyWith<$Res>
    implements $HomeDataCopyWith<$Res> {
  factory _$$HomeDataImplCopyWith(
          _$HomeDataImpl value, $Res Function(_$HomeDataImpl) then) =
      __$$HomeDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BannerItem activeBanner,
      List<BannerItem> banners,
      UserProgress progress,
      List<WorkoutCategory> categories,
      List<PopularWorkout> popularWorkouts,
      DateTime lastUpdated});

  @override
  $BannerItemCopyWith<$Res> get activeBanner;
  @override
  $UserProgressCopyWith<$Res> get progress;
}

/// @nodoc
class __$$HomeDataImplCopyWithImpl<$Res>
    extends _$HomeDataCopyWithImpl<$Res, _$HomeDataImpl>
    implements _$$HomeDataImplCopyWith<$Res> {
  __$$HomeDataImplCopyWithImpl(
      _$HomeDataImpl _value, $Res Function(_$HomeDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeBanner = null,
    Object? banners = null,
    Object? progress = null,
    Object? categories = null,
    Object? popularWorkouts = null,
    Object? lastUpdated = null,
  }) {
    return _then(_$HomeDataImpl(
      activeBanner: null == activeBanner
          ? _value.activeBanner
          : activeBanner // ignore: cast_nullable_to_non_nullable
              as BannerItem,
      banners: null == banners
          ? _value._banners
          : banners // ignore: cast_nullable_to_non_nullable
              as List<BannerItem>,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as UserProgress,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<WorkoutCategory>,
      popularWorkouts: null == popularWorkouts
          ? _value._popularWorkouts
          : popularWorkouts // ignore: cast_nullable_to_non_nullable
              as List<PopularWorkout>,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeDataImpl implements _HomeData {
  const _$HomeDataImpl(
      {required this.activeBanner,
      required final List<BannerItem> banners,
      required this.progress,
      required final List<WorkoutCategory> categories,
      required final List<PopularWorkout> popularWorkouts,
      required this.lastUpdated})
      : _banners = banners,
        _categories = categories,
        _popularWorkouts = popularWorkouts;

  factory _$HomeDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeDataImplFromJson(json);

  /// Banner atual em destaque
  @override
  final BannerItem activeBanner;

  /// Lista de banners disponíveis para rotação
  final List<BannerItem> _banners;

  /// Lista de banners disponíveis para rotação
  @override
  List<BannerItem> get banners {
    if (_banners is EqualUnmodifiableListView) return _banners;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_banners);
  }

  /// Indicadores de progresso do usuário
  @override
  final UserProgress progress;

  /// Categorias de treino disponíveis
  final List<WorkoutCategory> _categories;

  /// Categorias de treino disponíveis
  @override
  List<WorkoutCategory> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  /// Treinos populares para exibição
  final List<PopularWorkout> _popularWorkouts;

  /// Treinos populares para exibição
  @override
  List<PopularWorkout> get popularWorkouts {
    if (_popularWorkouts is EqualUnmodifiableListView) return _popularWorkouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_popularWorkouts);
  }

  /// Data da última atualização
  @override
  final DateTime lastUpdated;

  @override
  String toString() {
    return 'HomeData(activeBanner: $activeBanner, banners: $banners, progress: $progress, categories: $categories, popularWorkouts: $popularWorkouts, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeDataImpl &&
            (identical(other.activeBanner, activeBanner) ||
                other.activeBanner == activeBanner) &&
            const DeepCollectionEquality().equals(other._banners, _banners) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality()
                .equals(other._popularWorkouts, _popularWorkouts) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      activeBanner,
      const DeepCollectionEquality().hash(_banners),
      progress,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_popularWorkouts),
      lastUpdated);

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeDataImplCopyWith<_$HomeDataImpl> get copyWith =>
      __$$HomeDataImplCopyWithImpl<_$HomeDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeDataImplToJson(
      this,
    );
  }
}

abstract class _HomeData implements HomeData {
  const factory _HomeData(
      {required final BannerItem activeBanner,
      required final List<BannerItem> banners,
      required final UserProgress progress,
      required final List<WorkoutCategory> categories,
      required final List<PopularWorkout> popularWorkouts,
      required final DateTime lastUpdated}) = _$HomeDataImpl;

  factory _HomeData.fromJson(Map<String, dynamic> json) =
      _$HomeDataImpl.fromJson;

  /// Banner atual em destaque
  @override
  BannerItem get activeBanner;

  /// Lista de banners disponíveis para rotação
  @override
  List<BannerItem> get banners;

  /// Indicadores de progresso do usuário
  @override
  UserProgress get progress;

  /// Categorias de treino disponíveis
  @override
  List<WorkoutCategory> get categories;

  /// Treinos populares para exibição
  @override
  List<PopularWorkout> get popularWorkouts;

  /// Data da última atualização
  @override
  DateTime get lastUpdated;

  /// Create a copy of HomeData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeDataImplCopyWith<_$HomeDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BannerItem _$BannerItemFromJson(Map<String, dynamic> json) {
  return _BannerItem.fromJson(json);
}

/// @nodoc
mixin _$BannerItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get subtitle => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String? get actionUrl => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this BannerItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BannerItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BannerItemCopyWith<BannerItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BannerItemCopyWith<$Res> {
  factory $BannerItemCopyWith(
          BannerItem value, $Res Function(BannerItem) then) =
      _$BannerItemCopyWithImpl<$Res, BannerItem>;
  @useResult
  $Res call(
      {String id,
      String title,
      String subtitle,
      String imageUrl,
      String? actionUrl,
      bool isActive});
}

/// @nodoc
class _$BannerItemCopyWithImpl<$Res, $Val extends BannerItem>
    implements $BannerItemCopyWith<$Res> {
  _$BannerItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BannerItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? imageUrl = null,
    Object? actionUrl = freezed,
    Object? isActive = null,
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
      subtitle: null == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      actionUrl: freezed == actionUrl
          ? _value.actionUrl
          : actionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BannerItemImplCopyWith<$Res>
    implements $BannerItemCopyWith<$Res> {
  factory _$$BannerItemImplCopyWith(
          _$BannerItemImpl value, $Res Function(_$BannerItemImpl) then) =
      __$$BannerItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String subtitle,
      String imageUrl,
      String? actionUrl,
      bool isActive});
}

/// @nodoc
class __$$BannerItemImplCopyWithImpl<$Res>
    extends _$BannerItemCopyWithImpl<$Res, _$BannerItemImpl>
    implements _$$BannerItemImplCopyWith<$Res> {
  __$$BannerItemImplCopyWithImpl(
      _$BannerItemImpl _value, $Res Function(_$BannerItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of BannerItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? subtitle = null,
    Object? imageUrl = null,
    Object? actionUrl = freezed,
    Object? isActive = null,
  }) {
    return _then(_$BannerItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      subtitle: null == subtitle
          ? _value.subtitle
          : subtitle // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      actionUrl: freezed == actionUrl
          ? _value.actionUrl
          : actionUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BannerItemImpl implements _BannerItem {
  const _$BannerItemImpl(
      {required this.id,
      required this.title,
      required this.subtitle,
      required this.imageUrl,
      this.actionUrl,
      this.isActive = false});

  factory _$BannerItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$BannerItemImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final String imageUrl;
  @override
  final String? actionUrl;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'BannerItem(id: $id, title: $title, subtitle: $subtitle, imageUrl: $imageUrl, actionUrl: $actionUrl, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BannerItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.subtitle, subtitle) ||
                other.subtitle == subtitle) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.actionUrl, actionUrl) ||
                other.actionUrl == actionUrl) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, subtitle, imageUrl, actionUrl, isActive);

  /// Create a copy of BannerItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BannerItemImplCopyWith<_$BannerItemImpl> get copyWith =>
      __$$BannerItemImplCopyWithImpl<_$BannerItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BannerItemImplToJson(
      this,
    );
  }
}

abstract class _BannerItem implements BannerItem {
  const factory _BannerItem(
      {required final String id,
      required final String title,
      required final String subtitle,
      required final String imageUrl,
      final String? actionUrl,
      final bool isActive}) = _$BannerItemImpl;

  factory _BannerItem.fromJson(Map<String, dynamic> json) =
      _$BannerItemImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get subtitle;
  @override
  String get imageUrl;
  @override
  String? get actionUrl;
  @override
  bool get isActive;

  /// Create a copy of BannerItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BannerItemImplCopyWith<_$BannerItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) {
  return _UserProgress.fromJson(json);
}

/// @nodoc
mixin _$UserProgress {
  /// ID único do registro de progresso
  String? get id => throw _privateConstructorUsedError;

  /// ID do usuário
  String? get userId => throw _privateConstructorUsedError;

  /// Número total de treinos registrados
  int get totalWorkouts => throw _privateConstructorUsedError;

  /// Total de pontos acumulados
  int get totalPoints => throw _privateConstructorUsedError;

  /// Sequência atual de dias treinados
  int get currentStreak => throw _privateConstructorUsedError;

  /// Maior sequência de dias treinados
  int get longestStreak => throw _privateConstructorUsedError;

  /// Mapa de treinos por tipo (ex: "cardio": 10, "força": 5)
  Map<String, int> get workoutsByType => throw _privateConstructorUsedError;

  /// Duração total de treinos em minutos
  int get totalDuration => throw _privateConstructorUsedError;

  /// Número de desafios completados
  int get completedChallenges => throw _privateConstructorUsedError;

  /// Data da última atualização
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Data do último treino
  DateTime? get lastWorkout => throw _privateConstructorUsedError;

  /// Distribuição de treinos por mês
  Map<String, int>? get monthlyWorkouts => throw _privateConstructorUsedError;

  /// Distribuição de treinos por semana
  Map<String, int>? get weeklyWorkouts => throw _privateConstructorUsedError;

  /// Número de dias treinados no mês (para compatibilidade)
  int get daysTrainedThisMonth => throw _privateConstructorUsedError;

  /// Melhor sequência histórica (para compatibilidade)
  int get bestStreak => throw _privateConstructorUsedError;

  /// Porcentagem de progresso no desafio atual (0-100) (para compatibilidade)
  int get challengeProgress => throw _privateConstructorUsedError;

  /// Duração total de treinos na semana recente (em minutos)
  int? get recentWorkoutsDuration => throw _privateConstructorUsedError;

  /// Serializes this UserProgress to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProgressCopyWith<UserProgress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProgressCopyWith<$Res> {
  factory $UserProgressCopyWith(
          UserProgress value, $Res Function(UserProgress) then) =
      _$UserProgressCopyWithImpl<$Res, UserProgress>;
  @useResult
  $Res call(
      {String? id,
      String? userId,
      int totalWorkouts,
      int totalPoints,
      int currentStreak,
      int longestStreak,
      Map<String, int> workoutsByType,
      int totalDuration,
      int completedChallenges,
      DateTime? lastUpdated,
      DateTime? lastWorkout,
      Map<String, int>? monthlyWorkouts,
      Map<String, int>? weeklyWorkouts,
      int daysTrainedThisMonth,
      int bestStreak,
      int challengeProgress,
      int? recentWorkoutsDuration});
}

/// @nodoc
class _$UserProgressCopyWithImpl<$Res, $Val extends UserProgress>
    implements $UserProgressCopyWith<$Res> {
  _$UserProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? totalWorkouts = null,
    Object? totalPoints = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? workoutsByType = null,
    Object? totalDuration = null,
    Object? completedChallenges = null,
    Object? lastUpdated = freezed,
    Object? lastWorkout = freezed,
    Object? monthlyWorkouts = freezed,
    Object? weeklyWorkouts = freezed,
    Object? daysTrainedThisMonth = null,
    Object? bestStreak = null,
    Object? challengeProgress = null,
    Object? recentWorkoutsDuration = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsByType: null == workoutsByType
          ? _value.workoutsByType
          : workoutsByType // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
      completedChallenges: null == completedChallenges
          ? _value.completedChallenges
          : completedChallenges // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastWorkout: freezed == lastWorkout
          ? _value.lastWorkout
          : lastWorkout // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      monthlyWorkouts: freezed == monthlyWorkouts
          ? _value.monthlyWorkouts
          : monthlyWorkouts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      weeklyWorkouts: freezed == weeklyWorkouts
          ? _value.weeklyWorkouts
          : weeklyWorkouts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      daysTrainedThisMonth: null == daysTrainedThisMonth
          ? _value.daysTrainedThisMonth
          : daysTrainedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      bestStreak: null == bestStreak
          ? _value.bestStreak
          : bestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      challengeProgress: null == challengeProgress
          ? _value.challengeProgress
          : challengeProgress // ignore: cast_nullable_to_non_nullable
              as int,
      recentWorkoutsDuration: freezed == recentWorkoutsDuration
          ? _value.recentWorkoutsDuration
          : recentWorkoutsDuration // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProgressImplCopyWith<$Res>
    implements $UserProgressCopyWith<$Res> {
  factory _$$UserProgressImplCopyWith(
          _$UserProgressImpl value, $Res Function(_$UserProgressImpl) then) =
      __$$UserProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? userId,
      int totalWorkouts,
      int totalPoints,
      int currentStreak,
      int longestStreak,
      Map<String, int> workoutsByType,
      int totalDuration,
      int completedChallenges,
      DateTime? lastUpdated,
      DateTime? lastWorkout,
      Map<String, int>? monthlyWorkouts,
      Map<String, int>? weeklyWorkouts,
      int daysTrainedThisMonth,
      int bestStreak,
      int challengeProgress,
      int? recentWorkoutsDuration});
}

/// @nodoc
class __$$UserProgressImplCopyWithImpl<$Res>
    extends _$UserProgressCopyWithImpl<$Res, _$UserProgressImpl>
    implements _$$UserProgressImplCopyWith<$Res> {
  __$$UserProgressImplCopyWithImpl(
      _$UserProgressImpl _value, $Res Function(_$UserProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? userId = freezed,
    Object? totalWorkouts = null,
    Object? totalPoints = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? workoutsByType = null,
    Object? totalDuration = null,
    Object? completedChallenges = null,
    Object? lastUpdated = freezed,
    Object? lastWorkout = freezed,
    Object? monthlyWorkouts = freezed,
    Object? weeklyWorkouts = freezed,
    Object? daysTrainedThisMonth = null,
    Object? bestStreak = null,
    Object? challengeProgress = null,
    Object? recentWorkoutsDuration = freezed,
  }) {
    return _then(_$UserProgressImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      totalWorkouts: null == totalWorkouts
          ? _value.totalWorkouts
          : totalWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      workoutsByType: null == workoutsByType
          ? _value._workoutsByType
          : workoutsByType // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      totalDuration: null == totalDuration
          ? _value.totalDuration
          : totalDuration // ignore: cast_nullable_to_non_nullable
              as int,
      completedChallenges: null == completedChallenges
          ? _value.completedChallenges
          : completedChallenges // ignore: cast_nullable_to_non_nullable
              as int,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastWorkout: freezed == lastWorkout
          ? _value.lastWorkout
          : lastWorkout // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      monthlyWorkouts: freezed == monthlyWorkouts
          ? _value._monthlyWorkouts
          : monthlyWorkouts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      weeklyWorkouts: freezed == weeklyWorkouts
          ? _value._weeklyWorkouts
          : weeklyWorkouts // ignore: cast_nullable_to_non_nullable
              as Map<String, int>?,
      daysTrainedThisMonth: null == daysTrainedThisMonth
          ? _value.daysTrainedThisMonth
          : daysTrainedThisMonth // ignore: cast_nullable_to_non_nullable
              as int,
      bestStreak: null == bestStreak
          ? _value.bestStreak
          : bestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      challengeProgress: null == challengeProgress
          ? _value.challengeProgress
          : challengeProgress // ignore: cast_nullable_to_non_nullable
              as int,
      recentWorkoutsDuration: freezed == recentWorkoutsDuration
          ? _value.recentWorkoutsDuration
          : recentWorkoutsDuration // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProgressImpl implements _UserProgress {
  const _$UserProgressImpl(
      {this.id,
      this.userId,
      this.totalWorkouts = 0,
      this.totalPoints = 0,
      this.currentStreak = 0,
      this.longestStreak = 0,
      final Map<String, int> workoutsByType = const {},
      this.totalDuration = 0,
      this.completedChallenges = 0,
      this.lastUpdated,
      this.lastWorkout,
      final Map<String, int>? monthlyWorkouts,
      final Map<String, int>? weeklyWorkouts,
      this.daysTrainedThisMonth = 0,
      this.bestStreak = 0,
      this.challengeProgress = 0,
      this.recentWorkoutsDuration = 0})
      : _workoutsByType = workoutsByType,
        _monthlyWorkouts = monthlyWorkouts,
        _weeklyWorkouts = weeklyWorkouts;

  factory _$UserProgressImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProgressImplFromJson(json);

  /// ID único do registro de progresso
  @override
  final String? id;

  /// ID do usuário
  @override
  final String? userId;

  /// Número total de treinos registrados
  @override
  @JsonKey()
  final int totalWorkouts;

  /// Total de pontos acumulados
  @override
  @JsonKey()
  final int totalPoints;

  /// Sequência atual de dias treinados
  @override
  @JsonKey()
  final int currentStreak;

  /// Maior sequência de dias treinados
  @override
  @JsonKey()
  final int longestStreak;

  /// Mapa de treinos por tipo (ex: "cardio": 10, "força": 5)
  final Map<String, int> _workoutsByType;

  /// Mapa de treinos por tipo (ex: "cardio": 10, "força": 5)
  @override
  @JsonKey()
  Map<String, int> get workoutsByType {
    if (_workoutsByType is EqualUnmodifiableMapView) return _workoutsByType;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_workoutsByType);
  }

  /// Duração total de treinos em minutos
  @override
  @JsonKey()
  final int totalDuration;

  /// Número de desafios completados
  @override
  @JsonKey()
  final int completedChallenges;

  /// Data da última atualização
  @override
  final DateTime? lastUpdated;

  /// Data do último treino
  @override
  final DateTime? lastWorkout;

  /// Distribuição de treinos por mês
  final Map<String, int>? _monthlyWorkouts;

  /// Distribuição de treinos por mês
  @override
  Map<String, int>? get monthlyWorkouts {
    final value = _monthlyWorkouts;
    if (value == null) return null;
    if (_monthlyWorkouts is EqualUnmodifiableMapView) return _monthlyWorkouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Distribuição de treinos por semana
  final Map<String, int>? _weeklyWorkouts;

  /// Distribuição de treinos por semana
  @override
  Map<String, int>? get weeklyWorkouts {
    final value = _weeklyWorkouts;
    if (value == null) return null;
    if (_weeklyWorkouts is EqualUnmodifiableMapView) return _weeklyWorkouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Número de dias treinados no mês (para compatibilidade)
  @override
  @JsonKey()
  final int daysTrainedThisMonth;

  /// Melhor sequência histórica (para compatibilidade)
  @override
  @JsonKey()
  final int bestStreak;

  /// Porcentagem de progresso no desafio atual (0-100) (para compatibilidade)
  @override
  @JsonKey()
  final int challengeProgress;

  /// Duração total de treinos na semana recente (em minutos)
  @override
  @JsonKey()
  final int? recentWorkoutsDuration;

  @override
  String toString() {
    return 'UserProgress(id: $id, userId: $userId, totalWorkouts: $totalWorkouts, totalPoints: $totalPoints, currentStreak: $currentStreak, longestStreak: $longestStreak, workoutsByType: $workoutsByType, totalDuration: $totalDuration, completedChallenges: $completedChallenges, lastUpdated: $lastUpdated, lastWorkout: $lastWorkout, monthlyWorkouts: $monthlyWorkouts, weeklyWorkouts: $weeklyWorkouts, daysTrainedThisMonth: $daysTrainedThisMonth, bestStreak: $bestStreak, challengeProgress: $challengeProgress, recentWorkoutsDuration: $recentWorkoutsDuration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProgressImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.totalWorkouts, totalWorkouts) ||
                other.totalWorkouts == totalWorkouts) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            const DeepCollectionEquality()
                .equals(other._workoutsByType, _workoutsByType) &&
            (identical(other.totalDuration, totalDuration) ||
                other.totalDuration == totalDuration) &&
            (identical(other.completedChallenges, completedChallenges) ||
                other.completedChallenges == completedChallenges) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.lastWorkout, lastWorkout) ||
                other.lastWorkout == lastWorkout) &&
            const DeepCollectionEquality()
                .equals(other._monthlyWorkouts, _monthlyWorkouts) &&
            const DeepCollectionEquality()
                .equals(other._weeklyWorkouts, _weeklyWorkouts) &&
            (identical(other.daysTrainedThisMonth, daysTrainedThisMonth) ||
                other.daysTrainedThisMonth == daysTrainedThisMonth) &&
            (identical(other.bestStreak, bestStreak) ||
                other.bestStreak == bestStreak) &&
            (identical(other.challengeProgress, challengeProgress) ||
                other.challengeProgress == challengeProgress) &&
            (identical(other.recentWorkoutsDuration, recentWorkoutsDuration) ||
                other.recentWorkoutsDuration == recentWorkoutsDuration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      totalWorkouts,
      totalPoints,
      currentStreak,
      longestStreak,
      const DeepCollectionEquality().hash(_workoutsByType),
      totalDuration,
      completedChallenges,
      lastUpdated,
      lastWorkout,
      const DeepCollectionEquality().hash(_monthlyWorkouts),
      const DeepCollectionEquality().hash(_weeklyWorkouts),
      daysTrainedThisMonth,
      bestStreak,
      challengeProgress,
      recentWorkoutsDuration);

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      __$$UserProgressImplCopyWithImpl<_$UserProgressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProgressImplToJson(
      this,
    );
  }
}

abstract class _UserProgress implements UserProgress {
  const factory _UserProgress(
      {final String? id,
      final String? userId,
      final int totalWorkouts,
      final int totalPoints,
      final int currentStreak,
      final int longestStreak,
      final Map<String, int> workoutsByType,
      final int totalDuration,
      final int completedChallenges,
      final DateTime? lastUpdated,
      final DateTime? lastWorkout,
      final Map<String, int>? monthlyWorkouts,
      final Map<String, int>? weeklyWorkouts,
      final int daysTrainedThisMonth,
      final int bestStreak,
      final int challengeProgress,
      final int? recentWorkoutsDuration}) = _$UserProgressImpl;

  factory _UserProgress.fromJson(Map<String, dynamic> json) =
      _$UserProgressImpl.fromJson;

  /// ID único do registro de progresso
  @override
  String? get id;

  /// ID do usuário
  @override
  String? get userId;

  /// Número total de treinos registrados
  @override
  int get totalWorkouts;

  /// Total de pontos acumulados
  @override
  int get totalPoints;

  /// Sequência atual de dias treinados
  @override
  int get currentStreak;

  /// Maior sequência de dias treinados
  @override
  int get longestStreak;

  /// Mapa de treinos por tipo (ex: "cardio": 10, "força": 5)
  @override
  Map<String, int> get workoutsByType;

  /// Duração total de treinos em minutos
  @override
  int get totalDuration;

  /// Número de desafios completados
  @override
  int get completedChallenges;

  /// Data da última atualização
  @override
  DateTime? get lastUpdated;

  /// Data do último treino
  @override
  DateTime? get lastWorkout;

  /// Distribuição de treinos por mês
  @override
  Map<String, int>? get monthlyWorkouts;

  /// Distribuição de treinos por semana
  @override
  Map<String, int>? get weeklyWorkouts;

  /// Número de dias treinados no mês (para compatibilidade)
  @override
  int get daysTrainedThisMonth;

  /// Melhor sequência histórica (para compatibilidade)
  @override
  int get bestStreak;

  /// Porcentagem de progresso no desafio atual (0-100) (para compatibilidade)
  @override
  int get challengeProgress;

  /// Duração total de treinos na semana recente (em minutos)
  @override
  int? get recentWorkoutsDuration;

  /// Create a copy of UserProgress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProgressImplCopyWith<_$UserProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkoutCategory _$WorkoutCategoryFromJson(Map<String, dynamic> json) {
  return _WorkoutCategory.fromJson(json);
}

/// @nodoc
mixin _$WorkoutCategory {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get iconUrl => throw _privateConstructorUsedError;
  int get workoutCount => throw _privateConstructorUsedError;
  String? get colorHex => throw _privateConstructorUsedError;

  /// Serializes this WorkoutCategory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutCategoryCopyWith<WorkoutCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutCategoryCopyWith<$Res> {
  factory $WorkoutCategoryCopyWith(
          WorkoutCategory value, $Res Function(WorkoutCategory) then) =
      _$WorkoutCategoryCopyWithImpl<$Res, WorkoutCategory>;
  @useResult
  $Res call(
      {String id,
      String name,
      String iconUrl,
      int workoutCount,
      String? colorHex});
}

/// @nodoc
class _$WorkoutCategoryCopyWithImpl<$Res, $Val extends WorkoutCategory>
    implements $WorkoutCategoryCopyWith<$Res> {
  _$WorkoutCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? iconUrl = null,
    Object? workoutCount = null,
    Object? colorHex = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconUrl: null == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      colorHex: freezed == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutCategoryImplCopyWith<$Res>
    implements $WorkoutCategoryCopyWith<$Res> {
  factory _$$WorkoutCategoryImplCopyWith(_$WorkoutCategoryImpl value,
          $Res Function(_$WorkoutCategoryImpl) then) =
      __$$WorkoutCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String iconUrl,
      int workoutCount,
      String? colorHex});
}

/// @nodoc
class __$$WorkoutCategoryImplCopyWithImpl<$Res>
    extends _$WorkoutCategoryCopyWithImpl<$Res, _$WorkoutCategoryImpl>
    implements _$$WorkoutCategoryImplCopyWith<$Res> {
  __$$WorkoutCategoryImplCopyWithImpl(
      _$WorkoutCategoryImpl _value, $Res Function(_$WorkoutCategoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? iconUrl = null,
    Object? workoutCount = null,
    Object? colorHex = freezed,
  }) {
    return _then(_$WorkoutCategoryImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      iconUrl: null == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String,
      workoutCount: null == workoutCount
          ? _value.workoutCount
          : workoutCount // ignore: cast_nullable_to_non_nullable
              as int,
      colorHex: freezed == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutCategoryImpl implements _WorkoutCategory {
  const _$WorkoutCategoryImpl(
      {required this.id,
      required this.name,
      required this.iconUrl,
      required this.workoutCount,
      this.colorHex});

  factory _$WorkoutCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutCategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String iconUrl;
  @override
  final int workoutCount;
  @override
  final String? colorHex;

  @override
  String toString() {
    return 'WorkoutCategory(id: $id, name: $name, iconUrl: $iconUrl, workoutCount: $workoutCount, colorHex: $colorHex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.workoutCount, workoutCount) ||
                other.workoutCount == workoutCount) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, iconUrl, workoutCount, colorHex);

  /// Create a copy of WorkoutCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutCategoryImplCopyWith<_$WorkoutCategoryImpl> get copyWith =>
      __$$WorkoutCategoryImplCopyWithImpl<_$WorkoutCategoryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutCategoryImplToJson(
      this,
    );
  }
}

abstract class _WorkoutCategory implements WorkoutCategory {
  const factory _WorkoutCategory(
      {required final String id,
      required final String name,
      required final String iconUrl,
      required final int workoutCount,
      final String? colorHex}) = _$WorkoutCategoryImpl;

  factory _WorkoutCategory.fromJson(Map<String, dynamic> json) =
      _$WorkoutCategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get iconUrl;
  @override
  int get workoutCount;
  @override
  String? get colorHex;

  /// Create a copy of WorkoutCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutCategoryImplCopyWith<_$WorkoutCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PopularWorkout _$PopularWorkoutFromJson(Map<String, dynamic> json) {
  return _PopularWorkout.fromJson(json);
}

/// @nodoc
mixin _$PopularWorkout {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get duration => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  int get favoriteCount => throw _privateConstructorUsedError;

  /// Serializes this PopularWorkout to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PopularWorkout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PopularWorkoutCopyWith<PopularWorkout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PopularWorkoutCopyWith<$Res> {
  factory $PopularWorkoutCopyWith(
          PopularWorkout value, $Res Function(PopularWorkout) then) =
      _$PopularWorkoutCopyWithImpl<$Res, PopularWorkout>;
  @useResult
  $Res call(
      {String id,
      String title,
      String imageUrl,
      String duration,
      String difficulty,
      int favoriteCount});
}

/// @nodoc
class _$PopularWorkoutCopyWithImpl<$Res, $Val extends PopularWorkout>
    implements $PopularWorkoutCopyWith<$Res> {
  _$PopularWorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PopularWorkout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? duration = null,
    Object? difficulty = null,
    Object? favoriteCount = null,
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
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      favoriteCount: null == favoriteCount
          ? _value.favoriteCount
          : favoriteCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PopularWorkoutImplCopyWith<$Res>
    implements $PopularWorkoutCopyWith<$Res> {
  factory _$$PopularWorkoutImplCopyWith(_$PopularWorkoutImpl value,
          $Res Function(_$PopularWorkoutImpl) then) =
      __$$PopularWorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String imageUrl,
      String duration,
      String difficulty,
      int favoriteCount});
}

/// @nodoc
class __$$PopularWorkoutImplCopyWithImpl<$Res>
    extends _$PopularWorkoutCopyWithImpl<$Res, _$PopularWorkoutImpl>
    implements _$$PopularWorkoutImplCopyWith<$Res> {
  __$$PopularWorkoutImplCopyWithImpl(
      _$PopularWorkoutImpl _value, $Res Function(_$PopularWorkoutImpl) _then)
      : super(_value, _then);

  /// Create a copy of PopularWorkout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? imageUrl = null,
    Object? duration = null,
    Object? difficulty = null,
    Object? favoriteCount = null,
  }) {
    return _then(_$PopularWorkoutImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as String,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      favoriteCount: null == favoriteCount
          ? _value.favoriteCount
          : favoriteCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PopularWorkoutImpl implements _PopularWorkout {
  const _$PopularWorkoutImpl(
      {required this.id,
      required this.title,
      required this.imageUrl,
      required this.duration,
      required this.difficulty,
      this.favoriteCount = 0});

  factory _$PopularWorkoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$PopularWorkoutImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String imageUrl;
  @override
  final String duration;
  @override
  final String difficulty;
  @override
  @JsonKey()
  final int favoriteCount;

  @override
  String toString() {
    return 'PopularWorkout(id: $id, title: $title, imageUrl: $imageUrl, duration: $duration, difficulty: $difficulty, favoriteCount: $favoriteCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PopularWorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.favoriteCount, favoriteCount) ||
                other.favoriteCount == favoriteCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, imageUrl, duration, difficulty, favoriteCount);

  /// Create a copy of PopularWorkout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PopularWorkoutImplCopyWith<_$PopularWorkoutImpl> get copyWith =>
      __$$PopularWorkoutImplCopyWithImpl<_$PopularWorkoutImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PopularWorkoutImplToJson(
      this,
    );
  }
}

abstract class _PopularWorkout implements PopularWorkout {
  const factory _PopularWorkout(
      {required final String id,
      required final String title,
      required final String imageUrl,
      required final String duration,
      required final String difficulty,
      final int favoriteCount}) = _$PopularWorkoutImpl;

  factory _PopularWorkout.fromJson(Map<String, dynamic> json) =
      _$PopularWorkoutImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get imageUrl;
  @override
  String get duration;
  @override
  String get difficulty;
  @override
  int get favoriteCount;

  /// Create a copy of PopularWorkout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PopularWorkoutImplCopyWith<_$PopularWorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
