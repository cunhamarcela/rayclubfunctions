// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Meal _$MealFromJson(Map<String, dynamic> json) {
  return _Meal.fromJson(json);
}

/// @nodoc
mixin _$Meal {
  /// Identificador único da refeição
  String get id => throw _privateConstructorUsedError;

  /// Nome da refeição (ex: "Café da manhã", "Almoço")
  String get name => throw _privateConstructorUsedError;

  /// Data e hora em que a refeição foi consumida
  DateTime get dateTime => throw _privateConstructorUsedError;

  /// Quantidade total de calorias (kcal)
  int get calories => throw _privateConstructorUsedError;

  /// Quantidade de proteínas em gramas
  double get proteins => throw _privateConstructorUsedError;

  /// Quantidade de carboidratos em gramas
  double get carbs => throw _privateConstructorUsedError;

  /// Quantidade de gorduras em gramas
  double get fats => throw _privateConstructorUsedError;

  /// Observações adicionais sobre a refeição
  String? get notes => throw _privateConstructorUsedError;

  /// URL da imagem da refeição, quando disponível
  String? get imageUrl => throw _privateConstructorUsedError;

  /// Indica se a refeição foi marcada como favorita
  bool get isFavorite => throw _privateConstructorUsedError;

  /// Lista de tags para categorização (ex: "lowcarb", "vegetariano")
  List<String> get tags => throw _privateConstructorUsedError;

  /// Serializes this Meal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealCopyWith<Meal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealCopyWith<$Res> {
  factory $MealCopyWith(Meal value, $Res Function(Meal) then) =
      _$MealCopyWithImpl<$Res, Meal>;
  @useResult
  $Res call(
      {String id,
      String name,
      DateTime dateTime,
      int calories,
      double proteins,
      double carbs,
      double fats,
      String? notes,
      String? imageUrl,
      bool isFavorite,
      List<String> tags});
}

/// @nodoc
class _$MealCopyWithImpl<$Res, $Val extends Meal>
    implements $MealCopyWith<$Res> {
  _$MealCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dateTime = null,
    Object? calories = null,
    Object? proteins = null,
    Object? carbs = null,
    Object? fats = null,
    Object? notes = freezed,
    Object? imageUrl = freezed,
    Object? isFavorite = null,
    Object? tags = null,
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
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
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
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MealImplCopyWith<$Res> implements $MealCopyWith<$Res> {
  factory _$$MealImplCopyWith(
          _$MealImpl value, $Res Function(_$MealImpl) then) =
      __$$MealImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      DateTime dateTime,
      int calories,
      double proteins,
      double carbs,
      double fats,
      String? notes,
      String? imageUrl,
      bool isFavorite,
      List<String> tags});
}

/// @nodoc
class __$$MealImplCopyWithImpl<$Res>
    extends _$MealCopyWithImpl<$Res, _$MealImpl>
    implements _$$MealImplCopyWith<$Res> {
  __$$MealImplCopyWithImpl(_$MealImpl _value, $Res Function(_$MealImpl) _then)
      : super(_value, _then);

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? dateTime = null,
    Object? calories = null,
    Object? proteins = null,
    Object? carbs = null,
    Object? fats = null,
    Object? notes = freezed,
    Object? imageUrl = freezed,
    Object? isFavorite = null,
    Object? tags = null,
  }) {
    return _then(_$MealImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dateTime: null == dateTime
          ? _value.dateTime
          : dateTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      calories: null == calories
          ? _value.calories
          : calories // ignore: cast_nullable_to_non_nullable
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
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MealImpl with DiagnosticableTreeMixin implements _Meal {
  const _$MealImpl(
      {required this.id,
      required this.name,
      required this.dateTime,
      required this.calories,
      required this.proteins,
      required this.carbs,
      required this.fats,
      this.notes,
      this.imageUrl,
      this.isFavorite = false,
      final List<String> tags = const []})
      : _tags = tags;

  factory _$MealImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealImplFromJson(json);

  /// Identificador único da refeição
  @override
  final String id;

  /// Nome da refeição (ex: "Café da manhã", "Almoço")
  @override
  final String name;

  /// Data e hora em que a refeição foi consumida
  @override
  final DateTime dateTime;

  /// Quantidade total de calorias (kcal)
  @override
  final int calories;

  /// Quantidade de proteínas em gramas
  @override
  final double proteins;

  /// Quantidade de carboidratos em gramas
  @override
  final double carbs;

  /// Quantidade de gorduras em gramas
  @override
  final double fats;

  /// Observações adicionais sobre a refeição
  @override
  final String? notes;

  /// URL da imagem da refeição, quando disponível
  @override
  final String? imageUrl;

  /// Indica se a refeição foi marcada como favorita
  @override
  @JsonKey()
  final bool isFavorite;

  /// Lista de tags para categorização (ex: "lowcarb", "vegetariano")
  final List<String> _tags;

  /// Lista de tags para categorização (ex: "lowcarb", "vegetariano")
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Meal(id: $id, name: $name, dateTime: $dateTime, calories: $calories, proteins: $proteins, carbs: $carbs, fats: $fats, notes: $notes, imageUrl: $imageUrl, isFavorite: $isFavorite, tags: $tags)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Meal'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('dateTime', dateTime))
      ..add(DiagnosticsProperty('calories', calories))
      ..add(DiagnosticsProperty('proteins', proteins))
      ..add(DiagnosticsProperty('carbs', carbs))
      ..add(DiagnosticsProperty('fats', fats))
      ..add(DiagnosticsProperty('notes', notes))
      ..add(DiagnosticsProperty('imageUrl', imageUrl))
      ..add(DiagnosticsProperty('isFavorite', isFavorite))
      ..add(DiagnosticsProperty('tags', tags));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dateTime, dateTime) ||
                other.dateTime == dateTime) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteins, proteins) ||
                other.proteins == proteins) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fats, fats) || other.fats == fats) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      dateTime,
      calories,
      proteins,
      carbs,
      fats,
      notes,
      imageUrl,
      isFavorite,
      const DeepCollectionEquality().hash(_tags));

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealImplCopyWith<_$MealImpl> get copyWith =>
      __$$MealImplCopyWithImpl<_$MealImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MealImplToJson(
      this,
    );
  }
}

abstract class _Meal implements Meal {
  const factory _Meal(
      {required final String id,
      required final String name,
      required final DateTime dateTime,
      required final int calories,
      required final double proteins,
      required final double carbs,
      required final double fats,
      final String? notes,
      final String? imageUrl,
      final bool isFavorite,
      final List<String> tags}) = _$MealImpl;

  factory _Meal.fromJson(Map<String, dynamic> json) = _$MealImpl.fromJson;

  /// Identificador único da refeição
  @override
  String get id;

  /// Nome da refeição (ex: "Café da manhã", "Almoço")
  @override
  String get name;

  /// Data e hora em que a refeição foi consumida
  @override
  DateTime get dateTime;

  /// Quantidade total de calorias (kcal)
  @override
  int get calories;

  /// Quantidade de proteínas em gramas
  @override
  double get proteins;

  /// Quantidade de carboidratos em gramas
  @override
  double get carbs;

  /// Quantidade de gorduras em gramas
  @override
  double get fats;

  /// Observações adicionais sobre a refeição
  @override
  String? get notes;

  /// URL da imagem da refeição, quando disponível
  @override
  String? get imageUrl;

  /// Indica se a refeição foi marcada como favorita
  @override
  bool get isFavorite;

  /// Lista de tags para categorização (ex: "lowcarb", "vegetariano")
  @override
  List<String> get tags;

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealImplCopyWith<_$MealImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
