// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return _Profile.fromJson(json);
}

/// @nodoc
mixin _$Profile {
  /// ID do usuário
  String get id => throw _privateConstructorUsedError;

  /// Nome do usuário
  String? get name => throw _privateConstructorUsedError;

  /// E-mail do usuário
  String? get email => throw _privateConstructorUsedError;

  /// URL da foto de perfil
  String? get photoUrl => throw _privateConstructorUsedError;

  /// Número de treinos completados
  int get completedWorkouts => throw _privateConstructorUsedError;

  /// Número de dias em sequência de treino
  int get streak => throw _privateConstructorUsedError;

  /// Pontos acumulados pelo usuário
  int get points => throw _privateConstructorUsedError;

  /// Data de criação do perfil
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Data da última atualização do perfil
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Biografia ou descrição do usuário
  String? get bio => throw _privateConstructorUsedError;

  /// Objetivos de fitness do usuário (ex: "Perder peso", "Ganhar massa muscular")
  List<String> get goals => throw _privateConstructorUsedError;

  /// IDs dos treinos favoritos do usuário
  List<String> get favoriteWorkoutIds => throw _privateConstructorUsedError;

  /// Número de telefone do usuário
  String? get phone => throw _privateConstructorUsedError;

  /// Gênero do usuário
  String? get gender => throw _privateConstructorUsedError;

  /// Data de nascimento do usuário
  DateTime? get birthDate => throw _privateConstructorUsedError;

  /// Instagram do usuário
  String? get instagram => throw _privateConstructorUsedError;

  /// Meta de copos de água diários
  int get dailyWaterGoal => throw _privateConstructorUsedError;

  /// Meta de treinos diários
  int get dailyWorkoutGoal => throw _privateConstructorUsedError;

  /// Meta de treinos semanais
  int get weeklyWorkoutGoal => throw _privateConstructorUsedError;

  /// Meta de peso (kg)
  double? get weightGoal => throw _privateConstructorUsedError;

  /// Altura do usuário (cm)
  double? get height => throw _privateConstructorUsedError;

  /// Peso atual do usuário (kg)
  double? get currentWeight => throw _privateConstructorUsedError;

  /// Tipos de treinos preferidos
  List<String> get preferredWorkoutTypes => throw _privateConstructorUsedError;

  /// Tipo de conta do usuário (basic/expert)
  String get accountType => throw _privateConstructorUsedError;

  /// Estatísticas do usuário
  Map<String, dynamic> get stats => throw _privateConstructorUsedError;

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileCopyWith<Profile> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCopyWith<$Res> {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) then) =
      _$ProfileCopyWithImpl<$Res, Profile>;
  @useResult
  $Res call(
      {String id,
      String? name,
      String? email,
      String? photoUrl,
      int completedWorkouts,
      int streak,
      int points,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? bio,
      List<String> goals,
      List<String> favoriteWorkoutIds,
      String? phone,
      String? gender,
      DateTime? birthDate,
      String? instagram,
      int dailyWaterGoal,
      int dailyWorkoutGoal,
      int weeklyWorkoutGoal,
      double? weightGoal,
      double? height,
      double? currentWeight,
      List<String> preferredWorkoutTypes,
      String accountType,
      Map<String, dynamic> stats});
}

/// @nodoc
class _$ProfileCopyWithImpl<$Res, $Val extends Profile>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? email = freezed,
    Object? photoUrl = freezed,
    Object? completedWorkouts = null,
    Object? streak = null,
    Object? points = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? bio = freezed,
    Object? goals = null,
    Object? favoriteWorkoutIds = null,
    Object? phone = freezed,
    Object? gender = freezed,
    Object? birthDate = freezed,
    Object? instagram = freezed,
    Object? dailyWaterGoal = null,
    Object? dailyWorkoutGoal = null,
    Object? weeklyWorkoutGoal = null,
    Object? weightGoal = freezed,
    Object? height = freezed,
    Object? currentWeight = freezed,
    Object? preferredWorkoutTypes = null,
    Object? accountType = null,
    Object? stats = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      completedWorkouts: null == completedWorkouts
          ? _value.completedWorkouts
          : completedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      goals: null == goals
          ? _value.goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteWorkoutIds: null == favoriteWorkoutIds
          ? _value.favoriteWorkoutIds
          : favoriteWorkoutIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      instagram: freezed == instagram
          ? _value.instagram
          : instagram // ignore: cast_nullable_to_non_nullable
              as String?,
      dailyWaterGoal: null == dailyWaterGoal
          ? _value.dailyWaterGoal
          : dailyWaterGoal // ignore: cast_nullable_to_non_nullable
              as int,
      dailyWorkoutGoal: null == dailyWorkoutGoal
          ? _value.dailyWorkoutGoal
          : dailyWorkoutGoal // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyWorkoutGoal: null == weeklyWorkoutGoal
          ? _value.weeklyWorkoutGoal
          : weeklyWorkoutGoal // ignore: cast_nullable_to_non_nullable
              as int,
      weightGoal: freezed == weightGoal
          ? _value.weightGoal
          : weightGoal // ignore: cast_nullable_to_non_nullable
              as double?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double?,
      currentWeight: freezed == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      preferredWorkoutTypes: null == preferredWorkoutTypes
          ? _value.preferredWorkoutTypes
          : preferredWorkoutTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      accountType: null == accountType
          ? _value.accountType
          : accountType // ignore: cast_nullable_to_non_nullable
              as String,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileImplCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$$ProfileImplCopyWith(
          _$ProfileImpl value, $Res Function(_$ProfileImpl) then) =
      __$$ProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? name,
      String? email,
      String? photoUrl,
      int completedWorkouts,
      int streak,
      int points,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? bio,
      List<String> goals,
      List<String> favoriteWorkoutIds,
      String? phone,
      String? gender,
      DateTime? birthDate,
      String? instagram,
      int dailyWaterGoal,
      int dailyWorkoutGoal,
      int weeklyWorkoutGoal,
      double? weightGoal,
      double? height,
      double? currentWeight,
      List<String> preferredWorkoutTypes,
      String accountType,
      Map<String, dynamic> stats});
}

/// @nodoc
class __$$ProfileImplCopyWithImpl<$Res>
    extends _$ProfileCopyWithImpl<$Res, _$ProfileImpl>
    implements _$$ProfileImplCopyWith<$Res> {
  __$$ProfileImplCopyWithImpl(
      _$ProfileImpl _value, $Res Function(_$ProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? email = freezed,
    Object? photoUrl = freezed,
    Object? completedWorkouts = null,
    Object? streak = null,
    Object? points = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? bio = freezed,
    Object? goals = null,
    Object? favoriteWorkoutIds = null,
    Object? phone = freezed,
    Object? gender = freezed,
    Object? birthDate = freezed,
    Object? instagram = freezed,
    Object? dailyWaterGoal = null,
    Object? dailyWorkoutGoal = null,
    Object? weeklyWorkoutGoal = null,
    Object? weightGoal = freezed,
    Object? height = freezed,
    Object? currentWeight = freezed,
    Object? preferredWorkoutTypes = null,
    Object? accountType = null,
    Object? stats = null,
  }) {
    return _then(_$ProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      completedWorkouts: null == completedWorkouts
          ? _value.completedWorkouts
          : completedWorkouts // ignore: cast_nullable_to_non_nullable
              as int,
      streak: null == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as int,
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      goals: null == goals
          ? _value._goals
          : goals // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favoriteWorkoutIds: null == favoriteWorkoutIds
          ? _value._favoriteWorkoutIds
          : favoriteWorkoutIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      instagram: freezed == instagram
          ? _value.instagram
          : instagram // ignore: cast_nullable_to_non_nullable
              as String?,
      dailyWaterGoal: null == dailyWaterGoal
          ? _value.dailyWaterGoal
          : dailyWaterGoal // ignore: cast_nullable_to_non_nullable
              as int,
      dailyWorkoutGoal: null == dailyWorkoutGoal
          ? _value.dailyWorkoutGoal
          : dailyWorkoutGoal // ignore: cast_nullable_to_non_nullable
              as int,
      weeklyWorkoutGoal: null == weeklyWorkoutGoal
          ? _value.weeklyWorkoutGoal
          : weeklyWorkoutGoal // ignore: cast_nullable_to_non_nullable
              as int,
      weightGoal: freezed == weightGoal
          ? _value.weightGoal
          : weightGoal // ignore: cast_nullable_to_non_nullable
              as double?,
      height: freezed == height
          ? _value.height
          : height // ignore: cast_nullable_to_non_nullable
              as double?,
      currentWeight: freezed == currentWeight
          ? _value.currentWeight
          : currentWeight // ignore: cast_nullable_to_non_nullable
              as double?,
      preferredWorkoutTypes: null == preferredWorkoutTypes
          ? _value._preferredWorkoutTypes
          : preferredWorkoutTypes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      accountType: null == accountType
          ? _value.accountType
          : accountType // ignore: cast_nullable_to_non_nullable
              as String,
      stats: null == stats
          ? _value._stats
          : stats // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileImpl with DiagnosticableTreeMixin implements _Profile {
  const _$ProfileImpl(
      {required this.id,
      this.name,
      this.email,
      this.photoUrl,
      this.completedWorkouts = 0,
      this.streak = 0,
      this.points = 0,
      this.createdAt,
      this.updatedAt,
      this.bio,
      final List<String> goals = const [],
      final List<String> favoriteWorkoutIds = const [],
      this.phone,
      this.gender,
      this.birthDate,
      this.instagram,
      this.dailyWaterGoal = 8,
      this.dailyWorkoutGoal = 1,
      this.weeklyWorkoutGoal = 5,
      this.weightGoal,
      this.height,
      this.currentWeight,
      final List<String> preferredWorkoutTypes = const [],
      this.accountType = 'basic',
      final Map<String, dynamic> stats = const {
        'total_workouts': 0,
        'total_challenges': 0,
        'total_checkins': 0,
        'longest_streak': 0,
        'points_earned': 0,
        'completed_challenges': 0,
        'water_intake_average': 0
      }})
      : _goals = goals,
        _favoriteWorkoutIds = favoriteWorkoutIds,
        _preferredWorkoutTypes = preferredWorkoutTypes,
        _stats = stats;

  factory _$ProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileImplFromJson(json);

  /// ID do usuário
  @override
  final String id;

  /// Nome do usuário
  @override
  final String? name;

  /// E-mail do usuário
  @override
  final String? email;

  /// URL da foto de perfil
  @override
  final String? photoUrl;

  /// Número de treinos completados
  @override
  @JsonKey()
  final int completedWorkouts;

  /// Número de dias em sequência de treino
  @override
  @JsonKey()
  final int streak;

  /// Pontos acumulados pelo usuário
  @override
  @JsonKey()
  final int points;

  /// Data de criação do perfil
  @override
  final DateTime? createdAt;

  /// Data da última atualização do perfil
  @override
  final DateTime? updatedAt;

  /// Biografia ou descrição do usuário
  @override
  final String? bio;

  /// Objetivos de fitness do usuário (ex: "Perder peso", "Ganhar massa muscular")
  final List<String> _goals;

  /// Objetivos de fitness do usuário (ex: "Perder peso", "Ganhar massa muscular")
  @override
  @JsonKey()
  List<String> get goals {
    if (_goals is EqualUnmodifiableListView) return _goals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_goals);
  }

  /// IDs dos treinos favoritos do usuário
  final List<String> _favoriteWorkoutIds;

  /// IDs dos treinos favoritos do usuário
  @override
  @JsonKey()
  List<String> get favoriteWorkoutIds {
    if (_favoriteWorkoutIds is EqualUnmodifiableListView)
      return _favoriteWorkoutIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteWorkoutIds);
  }

  /// Número de telefone do usuário
  @override
  final String? phone;

  /// Gênero do usuário
  @override
  final String? gender;

  /// Data de nascimento do usuário
  @override
  final DateTime? birthDate;

  /// Instagram do usuário
  @override
  final String? instagram;

  /// Meta de copos de água diários
  @override
  @JsonKey()
  final int dailyWaterGoal;

  /// Meta de treinos diários
  @override
  @JsonKey()
  final int dailyWorkoutGoal;

  /// Meta de treinos semanais
  @override
  @JsonKey()
  final int weeklyWorkoutGoal;

  /// Meta de peso (kg)
  @override
  final double? weightGoal;

  /// Altura do usuário (cm)
  @override
  final double? height;

  /// Peso atual do usuário (kg)
  @override
  final double? currentWeight;

  /// Tipos de treinos preferidos
  final List<String> _preferredWorkoutTypes;

  /// Tipos de treinos preferidos
  @override
  @JsonKey()
  List<String> get preferredWorkoutTypes {
    if (_preferredWorkoutTypes is EqualUnmodifiableListView)
      return _preferredWorkoutTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredWorkoutTypes);
  }

  /// Tipo de conta do usuário (basic/expert)
  @override
  @JsonKey()
  final String accountType;

  /// Estatísticas do usuário
  final Map<String, dynamic> _stats;

  /// Estatísticas do usuário
  @override
  @JsonKey()
  Map<String, dynamic> get stats {
    if (_stats is EqualUnmodifiableMapView) return _stats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stats);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Profile(id: $id, name: $name, email: $email, photoUrl: $photoUrl, completedWorkouts: $completedWorkouts, streak: $streak, points: $points, createdAt: $createdAt, updatedAt: $updatedAt, bio: $bio, goals: $goals, favoriteWorkoutIds: $favoriteWorkoutIds, phone: $phone, gender: $gender, birthDate: $birthDate, instagram: $instagram, dailyWaterGoal: $dailyWaterGoal, dailyWorkoutGoal: $dailyWorkoutGoal, weeklyWorkoutGoal: $weeklyWorkoutGoal, weightGoal: $weightGoal, height: $height, currentWeight: $currentWeight, preferredWorkoutTypes: $preferredWorkoutTypes, accountType: $accountType, stats: $stats)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Profile'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('email', email))
      ..add(DiagnosticsProperty('photoUrl', photoUrl))
      ..add(DiagnosticsProperty('completedWorkouts', completedWorkouts))
      ..add(DiagnosticsProperty('streak', streak))
      ..add(DiagnosticsProperty('points', points))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('bio', bio))
      ..add(DiagnosticsProperty('goals', goals))
      ..add(DiagnosticsProperty('favoriteWorkoutIds', favoriteWorkoutIds))
      ..add(DiagnosticsProperty('phone', phone))
      ..add(DiagnosticsProperty('gender', gender))
      ..add(DiagnosticsProperty('birthDate', birthDate))
      ..add(DiagnosticsProperty('instagram', instagram))
      ..add(DiagnosticsProperty('dailyWaterGoal', dailyWaterGoal))
      ..add(DiagnosticsProperty('dailyWorkoutGoal', dailyWorkoutGoal))
      ..add(DiagnosticsProperty('weeklyWorkoutGoal', weeklyWorkoutGoal))
      ..add(DiagnosticsProperty('weightGoal', weightGoal))
      ..add(DiagnosticsProperty('height', height))
      ..add(DiagnosticsProperty('currentWeight', currentWeight))
      ..add(DiagnosticsProperty('preferredWorkoutTypes', preferredWorkoutTypes))
      ..add(DiagnosticsProperty('accountType', accountType))
      ..add(DiagnosticsProperty('stats', stats));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.completedWorkouts, completedWorkouts) ||
                other.completedWorkouts == completedWorkouts) &&
            (identical(other.streak, streak) || other.streak == streak) &&
            (identical(other.points, points) || other.points == points) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            const DeepCollectionEquality().equals(other._goals, _goals) &&
            const DeepCollectionEquality()
                .equals(other._favoriteWorkoutIds, _favoriteWorkoutIds) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.instagram, instagram) ||
                other.instagram == instagram) &&
            (identical(other.dailyWaterGoal, dailyWaterGoal) ||
                other.dailyWaterGoal == dailyWaterGoal) &&
            (identical(other.dailyWorkoutGoal, dailyWorkoutGoal) ||
                other.dailyWorkoutGoal == dailyWorkoutGoal) &&
            (identical(other.weeklyWorkoutGoal, weeklyWorkoutGoal) ||
                other.weeklyWorkoutGoal == weeklyWorkoutGoal) &&
            (identical(other.weightGoal, weightGoal) ||
                other.weightGoal == weightGoal) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.currentWeight, currentWeight) ||
                other.currentWeight == currentWeight) &&
            const DeepCollectionEquality()
                .equals(other._preferredWorkoutTypes, _preferredWorkoutTypes) &&
            (identical(other.accountType, accountType) ||
                other.accountType == accountType) &&
            const DeepCollectionEquality().equals(other._stats, _stats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        email,
        photoUrl,
        completedWorkouts,
        streak,
        points,
        createdAt,
        updatedAt,
        bio,
        const DeepCollectionEquality().hash(_goals),
        const DeepCollectionEquality().hash(_favoriteWorkoutIds),
        phone,
        gender,
        birthDate,
        instagram,
        dailyWaterGoal,
        dailyWorkoutGoal,
        weeklyWorkoutGoal,
        weightGoal,
        height,
        currentWeight,
        const DeepCollectionEquality().hash(_preferredWorkoutTypes),
        accountType,
        const DeepCollectionEquality().hash(_stats)
      ]);

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      __$$ProfileImplCopyWithImpl<_$ProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileImplToJson(
      this,
    );
  }
}

abstract class _Profile implements Profile {
  const factory _Profile(
      {required final String id,
      final String? name,
      final String? email,
      final String? photoUrl,
      final int completedWorkouts,
      final int streak,
      final int points,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final String? bio,
      final List<String> goals,
      final List<String> favoriteWorkoutIds,
      final String? phone,
      final String? gender,
      final DateTime? birthDate,
      final String? instagram,
      final int dailyWaterGoal,
      final int dailyWorkoutGoal,
      final int weeklyWorkoutGoal,
      final double? weightGoal,
      final double? height,
      final double? currentWeight,
      final List<String> preferredWorkoutTypes,
      final String accountType,
      final Map<String, dynamic> stats}) = _$ProfileImpl;

  factory _Profile.fromJson(Map<String, dynamic> json) = _$ProfileImpl.fromJson;

  /// ID do usuário
  @override
  String get id;

  /// Nome do usuário
  @override
  String? get name;

  /// E-mail do usuário
  @override
  String? get email;

  /// URL da foto de perfil
  @override
  String? get photoUrl;

  /// Número de treinos completados
  @override
  int get completedWorkouts;

  /// Número de dias em sequência de treino
  @override
  int get streak;

  /// Pontos acumulados pelo usuário
  @override
  int get points;

  /// Data de criação do perfil
  @override
  DateTime? get createdAt;

  /// Data da última atualização do perfil
  @override
  DateTime? get updatedAt;

  /// Biografia ou descrição do usuário
  @override
  String? get bio;

  /// Objetivos de fitness do usuário (ex: "Perder peso", "Ganhar massa muscular")
  @override
  List<String> get goals;

  /// IDs dos treinos favoritos do usuário
  @override
  List<String> get favoriteWorkoutIds;

  /// Número de telefone do usuário
  @override
  String? get phone;

  /// Gênero do usuário
  @override
  String? get gender;

  /// Data de nascimento do usuário
  @override
  DateTime? get birthDate;

  /// Instagram do usuário
  @override
  String? get instagram;

  /// Meta de copos de água diários
  @override
  int get dailyWaterGoal;

  /// Meta de treinos diários
  @override
  int get dailyWorkoutGoal;

  /// Meta de treinos semanais
  @override
  int get weeklyWorkoutGoal;

  /// Meta de peso (kg)
  @override
  double? get weightGoal;

  /// Altura do usuário (cm)
  @override
  double? get height;

  /// Peso atual do usuário (kg)
  @override
  double? get currentWeight;

  /// Tipos de treinos preferidos
  @override
  List<String> get preferredWorkoutTypes;

  /// Tipo de conta do usuário (basic/expert)
  @override
  String get accountType;

  /// Estatísticas do usuário
  @override
  Map<String, dynamic> get stats;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
