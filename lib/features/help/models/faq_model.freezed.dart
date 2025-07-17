// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'faq_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Faq _$FaqFromJson(Map<String, dynamic> json) {
  return _Faq.fromJson(json);
}

/// @nodoc
mixin _$Faq {
  /// ID da FAQ
  String get id => throw _privateConstructorUsedError;

  /// Pergunta
  String get question => throw _privateConstructorUsedError;

  /// Resposta
  String get answer => throw _privateConstructorUsedError;

  /// Categoria da FAQ
  String get category => throw _privateConstructorUsedError;

  /// Indica se a FAQ está ativa
  bool get isActive => throw _privateConstructorUsedError;

  /// ID do usuário que atualizou a FAQ
  String? get updatedBy => throw _privateConstructorUsedError;

  /// Data da última atualização
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  /// Serializes this Faq to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Faq
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FaqCopyWith<Faq> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FaqCopyWith<$Res> {
  factory $FaqCopyWith(Faq value, $Res Function(Faq) then) =
      _$FaqCopyWithImpl<$Res, Faq>;
  @useResult
  $Res call(
      {String id,
      String question,
      String answer,
      String category,
      bool isActive,
      String? updatedBy,
      DateTime? lastUpdated});
}

/// @nodoc
class _$FaqCopyWithImpl<$Res, $Val extends Faq> implements $FaqCopyWith<$Res> {
  _$FaqCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Faq
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? answer = null,
    Object? category = null,
    Object? isActive = null,
    Object? updatedBy = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FaqImplCopyWith<$Res> implements $FaqCopyWith<$Res> {
  factory _$$FaqImplCopyWith(_$FaqImpl value, $Res Function(_$FaqImpl) then) =
      __$$FaqImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String question,
      String answer,
      String category,
      bool isActive,
      String? updatedBy,
      DateTime? lastUpdated});
}

/// @nodoc
class __$$FaqImplCopyWithImpl<$Res> extends _$FaqCopyWithImpl<$Res, _$FaqImpl>
    implements _$$FaqImplCopyWith<$Res> {
  __$$FaqImplCopyWithImpl(_$FaqImpl _value, $Res Function(_$FaqImpl) _then)
      : super(_value, _then);

  /// Create a copy of Faq
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? answer = null,
    Object? category = null,
    Object? isActive = null,
    Object? updatedBy = freezed,
    Object? lastUpdated = freezed,
  }) {
    return _then(_$FaqImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      answer: null == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedBy: freezed == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      lastUpdated: freezed == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FaqImpl implements _Faq {
  const _$FaqImpl(
      {required this.id,
      required this.question,
      required this.answer,
      this.category = '',
      this.isActive = true,
      this.updatedBy,
      this.lastUpdated});

  factory _$FaqImpl.fromJson(Map<String, dynamic> json) =>
      _$$FaqImplFromJson(json);

  /// ID da FAQ
  @override
  final String id;

  /// Pergunta
  @override
  final String question;

  /// Resposta
  @override
  final String answer;

  /// Categoria da FAQ
  @override
  @JsonKey()
  final String category;

  /// Indica se a FAQ está ativa
  @override
  @JsonKey()
  final bool isActive;

  /// ID do usuário que atualizou a FAQ
  @override
  final String? updatedBy;

  /// Data da última atualização
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'Faq(id: $id, question: $question, answer: $answer, category: $category, isActive: $isActive, updatedBy: $updatedBy, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FaqImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, question, answer, category,
      isActive, updatedBy, lastUpdated);

  /// Create a copy of Faq
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FaqImplCopyWith<_$FaqImpl> get copyWith =>
      __$$FaqImplCopyWithImpl<_$FaqImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FaqImplToJson(
      this,
    );
  }
}

abstract class _Faq implements Faq {
  const factory _Faq(
      {required final String id,
      required final String question,
      required final String answer,
      final String category,
      final bool isActive,
      final String? updatedBy,
      final DateTime? lastUpdated}) = _$FaqImpl;

  factory _Faq.fromJson(Map<String, dynamic> json) = _$FaqImpl.fromJson;

  /// ID da FAQ
  @override
  String get id;

  /// Pergunta
  @override
  String get question;

  /// Resposta
  @override
  String get answer;

  /// Categoria da FAQ
  @override
  String get category;

  /// Indica se a FAQ está ativa
  @override
  bool get isActive;

  /// ID do usuário que atualizou a FAQ
  @override
  String? get updatedBy;

  /// Data da última atualização
  @override
  DateTime? get lastUpdated;

  /// Create a copy of Faq
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FaqImplCopyWith<_$FaqImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
