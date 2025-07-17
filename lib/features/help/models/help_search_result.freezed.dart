// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'help_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HelpSearchResult {
  /// Lista de FAQs encontradas na busca
  List<Faq> get faqs => throw _privateConstructorUsedError;

  /// Lista de tutoriais encontrados na busca
  List<Tutorial> get tutorials => throw _privateConstructorUsedError;

  /// Lista de artigos encontrados na busca (para implementação futura)
  List<dynamic> get articles => throw _privateConstructorUsedError;

  /// Create a copy of HelpSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HelpSearchResultCopyWith<HelpSearchResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HelpSearchResultCopyWith<$Res> {
  factory $HelpSearchResultCopyWith(
          HelpSearchResult value, $Res Function(HelpSearchResult) then) =
      _$HelpSearchResultCopyWithImpl<$Res, HelpSearchResult>;
  @useResult
  $Res call({List<Faq> faqs, List<Tutorial> tutorials, List<dynamic> articles});
}

/// @nodoc
class _$HelpSearchResultCopyWithImpl<$Res, $Val extends HelpSearchResult>
    implements $HelpSearchResultCopyWith<$Res> {
  _$HelpSearchResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HelpSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? faqs = null,
    Object? tutorials = null,
    Object? articles = null,
  }) {
    return _then(_value.copyWith(
      faqs: null == faqs
          ? _value.faqs
          : faqs // ignore: cast_nullable_to_non_nullable
              as List<Faq>,
      tutorials: null == tutorials
          ? _value.tutorials
          : tutorials // ignore: cast_nullable_to_non_nullable
              as List<Tutorial>,
      articles: null == articles
          ? _value.articles
          : articles // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HelpSearchResultImplCopyWith<$Res>
    implements $HelpSearchResultCopyWith<$Res> {
  factory _$$HelpSearchResultImplCopyWith(_$HelpSearchResultImpl value,
          $Res Function(_$HelpSearchResultImpl) then) =
      __$$HelpSearchResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Faq> faqs, List<Tutorial> tutorials, List<dynamic> articles});
}

/// @nodoc
class __$$HelpSearchResultImplCopyWithImpl<$Res>
    extends _$HelpSearchResultCopyWithImpl<$Res, _$HelpSearchResultImpl>
    implements _$$HelpSearchResultImplCopyWith<$Res> {
  __$$HelpSearchResultImplCopyWithImpl(_$HelpSearchResultImpl _value,
      $Res Function(_$HelpSearchResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of HelpSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? faqs = null,
    Object? tutorials = null,
    Object? articles = null,
  }) {
    return _then(_$HelpSearchResultImpl(
      faqs: null == faqs
          ? _value._faqs
          : faqs // ignore: cast_nullable_to_non_nullable
              as List<Faq>,
      tutorials: null == tutorials
          ? _value._tutorials
          : tutorials // ignore: cast_nullable_to_non_nullable
              as List<Tutorial>,
      articles: null == articles
          ? _value._articles
          : articles // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc

class _$HelpSearchResultImpl implements _HelpSearchResult {
  const _$HelpSearchResultImpl(
      {final List<Faq> faqs = const [],
      final List<Tutorial> tutorials = const [],
      final List<dynamic> articles = const []})
      : _faqs = faqs,
        _tutorials = tutorials,
        _articles = articles;

  /// Lista de FAQs encontradas na busca
  final List<Faq> _faqs;

  /// Lista de FAQs encontradas na busca
  @override
  @JsonKey()
  List<Faq> get faqs {
    if (_faqs is EqualUnmodifiableListView) return _faqs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_faqs);
  }

  /// Lista de tutoriais encontrados na busca
  final List<Tutorial> _tutorials;

  /// Lista de tutoriais encontrados na busca
  @override
  @JsonKey()
  List<Tutorial> get tutorials {
    if (_tutorials is EqualUnmodifiableListView) return _tutorials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tutorials);
  }

  /// Lista de artigos encontrados na busca (para implementação futura)
  final List<dynamic> _articles;

  /// Lista de artigos encontrados na busca (para implementação futura)
  @override
  @JsonKey()
  List<dynamic> get articles {
    if (_articles is EqualUnmodifiableListView) return _articles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_articles);
  }

  @override
  String toString() {
    return 'HelpSearchResult(faqs: $faqs, tutorials: $tutorials, articles: $articles)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HelpSearchResultImpl &&
            const DeepCollectionEquality().equals(other._faqs, _faqs) &&
            const DeepCollectionEquality()
                .equals(other._tutorials, _tutorials) &&
            const DeepCollectionEquality().equals(other._articles, _articles));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_faqs),
      const DeepCollectionEquality().hash(_tutorials),
      const DeepCollectionEquality().hash(_articles));

  /// Create a copy of HelpSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HelpSearchResultImplCopyWith<_$HelpSearchResultImpl> get copyWith =>
      __$$HelpSearchResultImplCopyWithImpl<_$HelpSearchResultImpl>(
          this, _$identity);
}

abstract class _HelpSearchResult implements HelpSearchResult {
  const factory _HelpSearchResult(
      {final List<Faq> faqs,
      final List<Tutorial> tutorials,
      final List<dynamic> articles}) = _$HelpSearchResultImpl;

  /// Lista de FAQs encontradas na busca
  @override
  List<Faq> get faqs;

  /// Lista de tutoriais encontrados na busca
  @override
  List<Tutorial> get tutorials;

  /// Lista de artigos encontrados na busca (para implementação futura)
  @override
  List<dynamic> get articles;

  /// Create a copy of HelpSearchResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HelpSearchResultImplCopyWith<_$HelpSearchResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
