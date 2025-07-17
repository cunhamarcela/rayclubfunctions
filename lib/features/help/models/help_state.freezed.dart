// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'help_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HelpState {
  /// Lista de perguntas frequentes
  List<Faq> get faqs => throw _privateConstructorUsedError;

  /// Lista de tutoriais disponíveis
  List<Tutorial> get tutorials => throw _privateConstructorUsedError;

  /// Índice da FAQ expandida, -1 se nenhuma estiver expandida
  int get expandedFaqIndex => throw _privateConstructorUsedError;

  /// Índice do tutorial expandido, -1 se nenhum estiver expandido
  int get expandedTutorialIndex => throw _privateConstructorUsedError;

  /// Indica se está carregando dados
  bool get isLoading => throw _privateConstructorUsedError;

  /// Indica se está em modo de busca
  bool get isSearching => throw _privateConstructorUsedError;

  /// Termo de busca atual
  String? get searchQuery => throw _privateConstructorUsedError;

  /// Resultados da busca: FAQs
  List<Faq> get searchResultsFaqs => throw _privateConstructorUsedError;

  /// Resultados da busca: Tutoriais
  List<Tutorial> get searchResultsTutorials =>
      throw _privateConstructorUsedError;

  /// Mensagem de erro, se houver
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Mensagem de sucesso após operações de CRUD
  String? get successMessage => throw _privateConstructorUsedError;

  /// Create a copy of HelpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HelpStateCopyWith<HelpState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HelpStateCopyWith<$Res> {
  factory $HelpStateCopyWith(HelpState value, $Res Function(HelpState) then) =
      _$HelpStateCopyWithImpl<$Res, HelpState>;
  @useResult
  $Res call(
      {List<Faq> faqs,
      List<Tutorial> tutorials,
      int expandedFaqIndex,
      int expandedTutorialIndex,
      bool isLoading,
      bool isSearching,
      String? searchQuery,
      List<Faq> searchResultsFaqs,
      List<Tutorial> searchResultsTutorials,
      String? errorMessage,
      String? successMessage});
}

/// @nodoc
class _$HelpStateCopyWithImpl<$Res, $Val extends HelpState>
    implements $HelpStateCopyWith<$Res> {
  _$HelpStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HelpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? faqs = null,
    Object? tutorials = null,
    Object? expandedFaqIndex = null,
    Object? expandedTutorialIndex = null,
    Object? isLoading = null,
    Object? isSearching = null,
    Object? searchQuery = freezed,
    Object? searchResultsFaqs = null,
    Object? searchResultsTutorials = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
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
      expandedFaqIndex: null == expandedFaqIndex
          ? _value.expandedFaqIndex
          : expandedFaqIndex // ignore: cast_nullable_to_non_nullable
              as int,
      expandedTutorialIndex: null == expandedTutorialIndex
          ? _value.expandedTutorialIndex
          : expandedTutorialIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      searchResultsFaqs: null == searchResultsFaqs
          ? _value.searchResultsFaqs
          : searchResultsFaqs // ignore: cast_nullable_to_non_nullable
              as List<Faq>,
      searchResultsTutorials: null == searchResultsTutorials
          ? _value.searchResultsTutorials
          : searchResultsTutorials // ignore: cast_nullable_to_non_nullable
              as List<Tutorial>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      successMessage: freezed == successMessage
          ? _value.successMessage
          : successMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HelpStateImplCopyWith<$Res>
    implements $HelpStateCopyWith<$Res> {
  factory _$$HelpStateImplCopyWith(
          _$HelpStateImpl value, $Res Function(_$HelpStateImpl) then) =
      __$$HelpStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Faq> faqs,
      List<Tutorial> tutorials,
      int expandedFaqIndex,
      int expandedTutorialIndex,
      bool isLoading,
      bool isSearching,
      String? searchQuery,
      List<Faq> searchResultsFaqs,
      List<Tutorial> searchResultsTutorials,
      String? errorMessage,
      String? successMessage});
}

/// @nodoc
class __$$HelpStateImplCopyWithImpl<$Res>
    extends _$HelpStateCopyWithImpl<$Res, _$HelpStateImpl>
    implements _$$HelpStateImplCopyWith<$Res> {
  __$$HelpStateImplCopyWithImpl(
      _$HelpStateImpl _value, $Res Function(_$HelpStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of HelpState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? faqs = null,
    Object? tutorials = null,
    Object? expandedFaqIndex = null,
    Object? expandedTutorialIndex = null,
    Object? isLoading = null,
    Object? isSearching = null,
    Object? searchQuery = freezed,
    Object? searchResultsFaqs = null,
    Object? searchResultsTutorials = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(_$HelpStateImpl(
      faqs: null == faqs
          ? _value._faqs
          : faqs // ignore: cast_nullable_to_non_nullable
              as List<Faq>,
      tutorials: null == tutorials
          ? _value._tutorials
          : tutorials // ignore: cast_nullable_to_non_nullable
              as List<Tutorial>,
      expandedFaqIndex: null == expandedFaqIndex
          ? _value.expandedFaqIndex
          : expandedFaqIndex // ignore: cast_nullable_to_non_nullable
              as int,
      expandedTutorialIndex: null == expandedTutorialIndex
          ? _value.expandedTutorialIndex
          : expandedTutorialIndex // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSearching: null == isSearching
          ? _value.isSearching
          : isSearching // ignore: cast_nullable_to_non_nullable
              as bool,
      searchQuery: freezed == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String?,
      searchResultsFaqs: null == searchResultsFaqs
          ? _value._searchResultsFaqs
          : searchResultsFaqs // ignore: cast_nullable_to_non_nullable
              as List<Faq>,
      searchResultsTutorials: null == searchResultsTutorials
          ? _value._searchResultsTutorials
          : searchResultsTutorials // ignore: cast_nullable_to_non_nullable
              as List<Tutorial>,
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
}

/// @nodoc

class _$HelpStateImpl implements _HelpState {
  const _$HelpStateImpl(
      {final List<Faq> faqs = const [],
      final List<Tutorial> tutorials = const [],
      this.expandedFaqIndex = -1,
      this.expandedTutorialIndex = -1,
      this.isLoading = false,
      this.isSearching = false,
      this.searchQuery,
      final List<Faq> searchResultsFaqs = const [],
      final List<Tutorial> searchResultsTutorials = const [],
      this.errorMessage,
      this.successMessage})
      : _faqs = faqs,
        _tutorials = tutorials,
        _searchResultsFaqs = searchResultsFaqs,
        _searchResultsTutorials = searchResultsTutorials;

  /// Lista de perguntas frequentes
  final List<Faq> _faqs;

  /// Lista de perguntas frequentes
  @override
  @JsonKey()
  List<Faq> get faqs {
    if (_faqs is EqualUnmodifiableListView) return _faqs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_faqs);
  }

  /// Lista de tutoriais disponíveis
  final List<Tutorial> _tutorials;

  /// Lista de tutoriais disponíveis
  @override
  @JsonKey()
  List<Tutorial> get tutorials {
    if (_tutorials is EqualUnmodifiableListView) return _tutorials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tutorials);
  }

  /// Índice da FAQ expandida, -1 se nenhuma estiver expandida
  @override
  @JsonKey()
  final int expandedFaqIndex;

  /// Índice do tutorial expandido, -1 se nenhum estiver expandido
  @override
  @JsonKey()
  final int expandedTutorialIndex;

  /// Indica se está carregando dados
  @override
  @JsonKey()
  final bool isLoading;

  /// Indica se está em modo de busca
  @override
  @JsonKey()
  final bool isSearching;

  /// Termo de busca atual
  @override
  final String? searchQuery;

  /// Resultados da busca: FAQs
  final List<Faq> _searchResultsFaqs;

  /// Resultados da busca: FAQs
  @override
  @JsonKey()
  List<Faq> get searchResultsFaqs {
    if (_searchResultsFaqs is EqualUnmodifiableListView)
      return _searchResultsFaqs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchResultsFaqs);
  }

  /// Resultados da busca: Tutoriais
  final List<Tutorial> _searchResultsTutorials;

  /// Resultados da busca: Tutoriais
  @override
  @JsonKey()
  List<Tutorial> get searchResultsTutorials {
    if (_searchResultsTutorials is EqualUnmodifiableListView)
      return _searchResultsTutorials;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchResultsTutorials);
  }

  /// Mensagem de erro, se houver
  @override
  final String? errorMessage;

  /// Mensagem de sucesso após operações de CRUD
  @override
  final String? successMessage;

  @override
  String toString() {
    return 'HelpState(faqs: $faqs, tutorials: $tutorials, expandedFaqIndex: $expandedFaqIndex, expandedTutorialIndex: $expandedTutorialIndex, isLoading: $isLoading, isSearching: $isSearching, searchQuery: $searchQuery, searchResultsFaqs: $searchResultsFaqs, searchResultsTutorials: $searchResultsTutorials, errorMessage: $errorMessage, successMessage: $successMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HelpStateImpl &&
            const DeepCollectionEquality().equals(other._faqs, _faqs) &&
            const DeepCollectionEquality()
                .equals(other._tutorials, _tutorials) &&
            (identical(other.expandedFaqIndex, expandedFaqIndex) ||
                other.expandedFaqIndex == expandedFaqIndex) &&
            (identical(other.expandedTutorialIndex, expandedTutorialIndex) ||
                other.expandedTutorialIndex == expandedTutorialIndex) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSearching, isSearching) ||
                other.isSearching == isSearching) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality()
                .equals(other._searchResultsFaqs, _searchResultsFaqs) &&
            const DeepCollectionEquality().equals(
                other._searchResultsTutorials, _searchResultsTutorials) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_faqs),
      const DeepCollectionEquality().hash(_tutorials),
      expandedFaqIndex,
      expandedTutorialIndex,
      isLoading,
      isSearching,
      searchQuery,
      const DeepCollectionEquality().hash(_searchResultsFaqs),
      const DeepCollectionEquality().hash(_searchResultsTutorials),
      errorMessage,
      successMessage);

  /// Create a copy of HelpState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HelpStateImplCopyWith<_$HelpStateImpl> get copyWith =>
      __$$HelpStateImplCopyWithImpl<_$HelpStateImpl>(this, _$identity);
}

abstract class _HelpState implements HelpState {
  const factory _HelpState(
      {final List<Faq> faqs,
      final List<Tutorial> tutorials,
      final int expandedFaqIndex,
      final int expandedTutorialIndex,
      final bool isLoading,
      final bool isSearching,
      final String? searchQuery,
      final List<Faq> searchResultsFaqs,
      final List<Tutorial> searchResultsTutorials,
      final String? errorMessage,
      final String? successMessage}) = _$HelpStateImpl;

  /// Lista de perguntas frequentes
  @override
  List<Faq> get faqs;

  /// Lista de tutoriais disponíveis
  @override
  List<Tutorial> get tutorials;

  /// Índice da FAQ expandida, -1 se nenhuma estiver expandida
  @override
  int get expandedFaqIndex;

  /// Índice do tutorial expandido, -1 se nenhum estiver expandido
  @override
  int get expandedTutorialIndex;

  /// Indica se está carregando dados
  @override
  bool get isLoading;

  /// Indica se está em modo de busca
  @override
  bool get isSearching;

  /// Termo de busca atual
  @override
  String? get searchQuery;

  /// Resultados da busca: FAQs
  @override
  List<Faq> get searchResultsFaqs;

  /// Resultados da busca: Tutoriais
  @override
  List<Tutorial> get searchResultsTutorials;

  /// Mensagem de erro, se houver
  @override
  String? get errorMessage;

  /// Mensagem de sucesso após operações de CRUD
  @override
  String? get successMessage;

  /// Create a copy of HelpState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HelpStateImplCopyWith<_$HelpStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
