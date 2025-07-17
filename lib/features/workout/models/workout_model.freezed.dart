// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Workout _$WorkoutFromJson(Map<String, dynamic> json) {
  return _Workout.fromJson(json);
}

/// @nodoc
mixin _$Workout {
  /// Identificador único do treino
  String get id => throw _privateConstructorUsedError;

  /// Título do treino
  String get title => throw _privateConstructorUsedError;

  /// Descrição detalhada do treino
  String get description => throw _privateConstructorUsedError;

  /// URL da imagem do treino (opcional)
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Tipo/categoria do treino (ex: "Yoga", "HIIT", "Musculação")
  String get type => throw _privateConstructorUsedError;

  /// Duração do treino em minutos
  int get durationMinutes => throw _privateConstructorUsedError;

  /// Nível de dificuldade (ex: "Iniciante", "Intermediário", "Avançado")
  String get difficulty => throw _privateConstructorUsedError;

  /// Nível no banco de dados (usado quando o campo difficulty não está disponível)
  String? get level => throw _privateConstructorUsedError;

  /// Lista de equipamentos necessários
  List<String> get equipment => throw _privateConstructorUsedError;

  /// Lista de seções do treino (aquecimento, principal, etc.)
  List<WorkoutSection> get sections => throw _privateConstructorUsedError;

  /// ID do criador do treino
  String get creatorId => throw _privateConstructorUsedError;

  /// Data de criação do treino
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Data da última atualização (opcional)
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Mapa de exercícios por seção (para compatibilidade com testes)
  /// A chave representa o nome da seção (ex: 'warmup', 'main', 'cooldown')
  /// O valor é uma lista de nomes de exercícios
  Map<String, List<String>>? get exercises =>
      throw _privateConstructorUsedError;

  /// Serializes this Workout to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutCopyWith<Workout> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutCopyWith<$Res> {
  factory $WorkoutCopyWith(Workout value, $Res Function(Workout) then) =
      _$WorkoutCopyWithImpl<$Res, Workout>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String? imageUrl,
      String type,
      int durationMinutes,
      String difficulty,
      String? level,
      List<String> equipment,
      List<WorkoutSection> sections,
      String creatorId,
      DateTime createdAt,
      DateTime? updatedAt,
      Map<String, List<String>>? exercises});
}

/// @nodoc
class _$WorkoutCopyWithImpl<$Res, $Val extends Workout>
    implements $WorkoutCopyWith<$Res> {
  _$WorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? type = null,
    Object? durationMinutes = null,
    Object? difficulty = null,
    Object? level = freezed,
    Object? equipment = null,
    Object? sections = null,
    Object? creatorId = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? exercises = freezed,
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      level: freezed == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String?,
      equipment: null == equipment
          ? _value.equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sections: null == sections
          ? _value.sections
          : sections // ignore: cast_nullable_to_non_nullable
              as List<WorkoutSection>,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      exercises: freezed == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutImplCopyWith<$Res> implements $WorkoutCopyWith<$Res> {
  factory _$$WorkoutImplCopyWith(
          _$WorkoutImpl value, $Res Function(_$WorkoutImpl) then) =
      __$$WorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      String? imageUrl,
      String type,
      int durationMinutes,
      String difficulty,
      String? level,
      List<String> equipment,
      List<WorkoutSection> sections,
      String creatorId,
      DateTime createdAt,
      DateTime? updatedAt,
      Map<String, List<String>>? exercises});
}

/// @nodoc
class __$$WorkoutImplCopyWithImpl<$Res>
    extends _$WorkoutCopyWithImpl<$Res, _$WorkoutImpl>
    implements _$$WorkoutImplCopyWith<$Res> {
  __$$WorkoutImplCopyWithImpl(
      _$WorkoutImpl _value, $Res Function(_$WorkoutImpl) _then)
      : super(_value, _then);

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? imageUrl = freezed,
    Object? type = null,
    Object? durationMinutes = null,
    Object? difficulty = null,
    Object? level = freezed,
    Object? equipment = null,
    Object? sections = null,
    Object? creatorId = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? exercises = freezed,
  }) {
    return _then(_$WorkoutImpl(
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
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
      level: freezed == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String?,
      equipment: null == equipment
          ? _value._equipment
          : equipment // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sections: null == sections
          ? _value._sections
          : sections // ignore: cast_nullable_to_non_nullable
              as List<WorkoutSection>,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      exercises: freezed == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutImpl implements _Workout {
  const _$WorkoutImpl(
      {required this.id,
      required this.title,
      required this.description,
      this.imageUrl,
      required this.type,
      required this.durationMinutes,
      required this.difficulty,
      this.level,
      required final List<String> equipment,
      final List<WorkoutSection> sections = const [],
      required this.creatorId,
      required this.createdAt,
      this.updatedAt,
      final Map<String, List<String>>? exercises})
      : _equipment = equipment,
        _sections = sections,
        _exercises = exercises;

  factory _$WorkoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutImplFromJson(json);

  /// Identificador único do treino
  @override
  final String id;

  /// Título do treino
  @override
  final String title;

  /// Descrição detalhada do treino
  @override
  final String description;

  /// URL da imagem do treino (opcional)
  @override
  final String? imageUrl;

  /// Tipo/categoria do treino (ex: "Yoga", "HIIT", "Musculação")
  @override
  final String type;

  /// Duração do treino em minutos
  @override
  final int durationMinutes;

  /// Nível de dificuldade (ex: "Iniciante", "Intermediário", "Avançado")
  @override
  final String difficulty;

  /// Nível no banco de dados (usado quando o campo difficulty não está disponível)
  @override
  final String? level;

  /// Lista de equipamentos necessários
  final List<String> _equipment;

  /// Lista de equipamentos necessários
  @override
  List<String> get equipment {
    if (_equipment is EqualUnmodifiableListView) return _equipment;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_equipment);
  }

  /// Lista de seções do treino (aquecimento, principal, etc.)
  final List<WorkoutSection> _sections;

  /// Lista de seções do treino (aquecimento, principal, etc.)
  @override
  @JsonKey()
  List<WorkoutSection> get sections {
    if (_sections is EqualUnmodifiableListView) return _sections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sections);
  }

  /// ID do criador do treino
  @override
  final String creatorId;

  /// Data de criação do treino
  @override
  final DateTime createdAt;

  /// Data da última atualização (opcional)
  @override
  final DateTime? updatedAt;

  /// Mapa de exercícios por seção (para compatibilidade com testes)
  /// A chave representa o nome da seção (ex: 'warmup', 'main', 'cooldown')
  /// O valor é uma lista de nomes de exercícios
  final Map<String, List<String>>? _exercises;

  /// Mapa de exercícios por seção (para compatibilidade com testes)
  /// A chave representa o nome da seção (ex: 'warmup', 'main', 'cooldown')
  /// O valor é uma lista de nomes de exercícios
  @override
  Map<String, List<String>>? get exercises {
    final value = _exercises;
    if (value == null) return null;
    if (_exercises is EqualUnmodifiableMapView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Workout(id: $id, title: $title, description: $description, imageUrl: $imageUrl, type: $type, durationMinutes: $durationMinutes, difficulty: $difficulty, level: $level, equipment: $equipment, sections: $sections, creatorId: $creatorId, createdAt: $createdAt, updatedAt: $updatedAt, exercises: $exercises)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.level, level) || other.level == level) &&
            const DeepCollectionEquality()
                .equals(other._equipment, _equipment) &&
            const DeepCollectionEquality().equals(other._sections, _sections) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      imageUrl,
      type,
      durationMinutes,
      difficulty,
      level,
      const DeepCollectionEquality().hash(_equipment),
      const DeepCollectionEquality().hash(_sections),
      creatorId,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_exercises));

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutImplCopyWith<_$WorkoutImpl> get copyWith =>
      __$$WorkoutImplCopyWithImpl<_$WorkoutImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutImplToJson(
      this,
    );
  }
}

abstract class _Workout implements Workout {
  const factory _Workout(
      {required final String id,
      required final String title,
      required final String description,
      final String? imageUrl,
      required final String type,
      required final int durationMinutes,
      required final String difficulty,
      final String? level,
      required final List<String> equipment,
      final List<WorkoutSection> sections,
      required final String creatorId,
      required final DateTime createdAt,
      final DateTime? updatedAt,
      final Map<String, List<String>>? exercises}) = _$WorkoutImpl;

  factory _Workout.fromJson(Map<String, dynamic> json) = _$WorkoutImpl.fromJson;

  /// Identificador único do treino
  @override
  String get id;

  /// Título do treino
  @override
  String get title;

  /// Descrição detalhada do treino
  @override
  String get description;

  /// URL da imagem do treino (opcional)
  @override
  String? get imageUrl;

  /// Tipo/categoria do treino (ex: "Yoga", "HIIT", "Musculação")
  @override
  String get type;

  /// Duração do treino em minutos
  @override
  int get durationMinutes;

  /// Nível de dificuldade (ex: "Iniciante", "Intermediário", "Avançado")
  @override
  String get difficulty;

  /// Nível no banco de dados (usado quando o campo difficulty não está disponível)
  @override
  String? get level;

  /// Lista de equipamentos necessários
  @override
  List<String> get equipment;

  /// Lista de seções do treino (aquecimento, principal, etc.)
  @override
  List<WorkoutSection> get sections;

  /// ID do criador do treino
  @override
  String get creatorId;

  /// Data de criação do treino
  @override
  DateTime get createdAt;

  /// Data da última atualização (opcional)
  @override
  DateTime? get updatedAt;

  /// Mapa de exercícios por seção (para compatibilidade com testes)
  /// A chave representa o nome da seção (ex: 'warmup', 'main', 'cooldown')
  /// O valor é uma lista de nomes de exercícios
  @override
  Map<String, List<String>>? get exercises;

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutImplCopyWith<_$WorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkoutSection _$WorkoutSectionFromJson(Map<String, dynamic> json) {
  return _WorkoutSection.fromJson(json);
}

/// @nodoc
mixin _$WorkoutSection {
  /// Nome da seção
  String get name => throw _privateConstructorUsedError;

  /// Lista de exercícios na seção
  List<Exercise> get exercises => throw _privateConstructorUsedError;

  /// Serializes this WorkoutSection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutSectionCopyWith<WorkoutSection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutSectionCopyWith<$Res> {
  factory $WorkoutSectionCopyWith(
          WorkoutSection value, $Res Function(WorkoutSection) then) =
      _$WorkoutSectionCopyWithImpl<$Res, WorkoutSection>;
  @useResult
  $Res call({String name, List<Exercise> exercises});
}

/// @nodoc
class _$WorkoutSectionCopyWithImpl<$Res, $Val extends WorkoutSection>
    implements $WorkoutSectionCopyWith<$Res> {
  _$WorkoutSectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? exercises = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      exercises: null == exercises
          ? _value.exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutSectionImplCopyWith<$Res>
    implements $WorkoutSectionCopyWith<$Res> {
  factory _$$WorkoutSectionImplCopyWith(_$WorkoutSectionImpl value,
          $Res Function(_$WorkoutSectionImpl) then) =
      __$$WorkoutSectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, List<Exercise> exercises});
}

/// @nodoc
class __$$WorkoutSectionImplCopyWithImpl<$Res>
    extends _$WorkoutSectionCopyWithImpl<$Res, _$WorkoutSectionImpl>
    implements _$$WorkoutSectionImplCopyWith<$Res> {
  __$$WorkoutSectionImplCopyWithImpl(
      _$WorkoutSectionImpl _value, $Res Function(_$WorkoutSectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? exercises = null,
  }) {
    return _then(_$WorkoutSectionImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      exercises: null == exercises
          ? _value._exercises
          : exercises // ignore: cast_nullable_to_non_nullable
              as List<Exercise>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutSectionImpl implements _WorkoutSection {
  const _$WorkoutSectionImpl(
      {required this.name, required final List<Exercise> exercises})
      : _exercises = exercises;

  factory _$WorkoutSectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutSectionImplFromJson(json);

  /// Nome da seção
  @override
  final String name;

  /// Lista de exercícios na seção
  final List<Exercise> _exercises;

  /// Lista de exercícios na seção
  @override
  List<Exercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  String toString() {
    return 'WorkoutSection(name: $name, exercises: $exercises)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutSectionImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._exercises, _exercises));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, const DeepCollectionEquality().hash(_exercises));

  /// Create a copy of WorkoutSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutSectionImplCopyWith<_$WorkoutSectionImpl> get copyWith =>
      __$$WorkoutSectionImplCopyWithImpl<_$WorkoutSectionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutSectionImplToJson(
      this,
    );
  }
}

abstract class _WorkoutSection implements WorkoutSection {
  const factory _WorkoutSection(
      {required final String name,
      required final List<Exercise> exercises}) = _$WorkoutSectionImpl;

  factory _WorkoutSection.fromJson(Map<String, dynamic> json) =
      _$WorkoutSectionImpl.fromJson;

  /// Nome da seção
  @override
  String get name;

  /// Lista de exercícios na seção
  @override
  List<Exercise> get exercises;

  /// Create a copy of WorkoutSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutSectionImplCopyWith<_$WorkoutSectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkoutFilter _$WorkoutFilterFromJson(Map<String, dynamic> json) {
  return _WorkoutFilter.fromJson(json);
}

/// @nodoc
mixin _$WorkoutFilter {
  /// Categoria selecionada (vazio = todas)
  String get category => throw _privateConstructorUsedError;

  /// Duração máxima em minutos (0 = sem filtro)
  int get maxDuration => throw _privateConstructorUsedError;

  /// Duração mínima em minutos (usado para intervalos de duração)
  int get minDuration => throw _privateConstructorUsedError;

  /// Dificuldade selecionada (vazio = todas)
  String get difficulty => throw _privateConstructorUsedError;

  /// Serializes this WorkoutFilter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutFilterCopyWith<WorkoutFilter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutFilterCopyWith<$Res> {
  factory $WorkoutFilterCopyWith(
          WorkoutFilter value, $Res Function(WorkoutFilter) then) =
      _$WorkoutFilterCopyWithImpl<$Res, WorkoutFilter>;
  @useResult
  $Res call(
      {String category, int maxDuration, int minDuration, String difficulty});
}

/// @nodoc
class _$WorkoutFilterCopyWithImpl<$Res, $Val extends WorkoutFilter>
    implements $WorkoutFilterCopyWith<$Res> {
  _$WorkoutFilterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? maxDuration = null,
    Object? minDuration = null,
    Object? difficulty = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      maxDuration: null == maxDuration
          ? _value.maxDuration
          : maxDuration // ignore: cast_nullable_to_non_nullable
              as int,
      minDuration: null == minDuration
          ? _value.minDuration
          : minDuration // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkoutFilterImplCopyWith<$Res>
    implements $WorkoutFilterCopyWith<$Res> {
  factory _$$WorkoutFilterImplCopyWith(
          _$WorkoutFilterImpl value, $Res Function(_$WorkoutFilterImpl) then) =
      __$$WorkoutFilterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String category, int maxDuration, int minDuration, String difficulty});
}

/// @nodoc
class __$$WorkoutFilterImplCopyWithImpl<$Res>
    extends _$WorkoutFilterCopyWithImpl<$Res, _$WorkoutFilterImpl>
    implements _$$WorkoutFilterImplCopyWith<$Res> {
  __$$WorkoutFilterImplCopyWithImpl(
      _$WorkoutFilterImpl _value, $Res Function(_$WorkoutFilterImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutFilter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? maxDuration = null,
    Object? minDuration = null,
    Object? difficulty = null,
  }) {
    return _then(_$WorkoutFilterImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      maxDuration: null == maxDuration
          ? _value.maxDuration
          : maxDuration // ignore: cast_nullable_to_non_nullable
              as int,
      minDuration: null == minDuration
          ? _value.minDuration
          : minDuration // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutFilterImpl implements _WorkoutFilter {
  const _$WorkoutFilterImpl(
      {this.category = '',
      this.maxDuration = 0,
      this.minDuration = 0,
      this.difficulty = ''});

  factory _$WorkoutFilterImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutFilterImplFromJson(json);

  /// Categoria selecionada (vazio = todas)
  @override
  @JsonKey()
  final String category;

  /// Duração máxima em minutos (0 = sem filtro)
  @override
  @JsonKey()
  final int maxDuration;

  /// Duração mínima em minutos (usado para intervalos de duração)
  @override
  @JsonKey()
  final int minDuration;

  /// Dificuldade selecionada (vazio = todas)
  @override
  @JsonKey()
  final String difficulty;

  @override
  String toString() {
    return 'WorkoutFilter(category: $category, maxDuration: $maxDuration, minDuration: $minDuration, difficulty: $difficulty)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutFilterImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.maxDuration, maxDuration) ||
                other.maxDuration == maxDuration) &&
            (identical(other.minDuration, minDuration) ||
                other.minDuration == minDuration) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, category, maxDuration, minDuration, difficulty);

  /// Create a copy of WorkoutFilter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutFilterImplCopyWith<_$WorkoutFilterImpl> get copyWith =>
      __$$WorkoutFilterImplCopyWithImpl<_$WorkoutFilterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutFilterImplToJson(
      this,
    );
  }
}

abstract class _WorkoutFilter implements WorkoutFilter {
  const factory _WorkoutFilter(
      {final String category,
      final int maxDuration,
      final int minDuration,
      final String difficulty}) = _$WorkoutFilterImpl;

  factory _WorkoutFilter.fromJson(Map<String, dynamic> json) =
      _$WorkoutFilterImpl.fromJson;

  /// Categoria selecionada (vazio = todas)
  @override
  String get category;

  /// Duração máxima em minutos (0 = sem filtro)
  @override
  int get maxDuration;

  /// Duração mínima em minutos (usado para intervalos de duração)
  @override
  int get minDuration;

  /// Dificuldade selecionada (vazio = todas)
  @override
  String get difficulty;

  /// Create a copy of WorkoutFilter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutFilterImplCopyWith<_$WorkoutFilterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
