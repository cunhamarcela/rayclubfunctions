// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'challenge_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChallengeState {
  /// Lista de todos os desafios carregados
  List<Challenge> get challenges => throw _privateConstructorUsedError;

  /// Lista de desafios filtrados por critérios da UI
  List<Challenge> get filteredChallenges => throw _privateConstructorUsedError;

  /// Desafio atualmente selecionado para visualização de detalhes
  Challenge? get selectedChallenge => throw _privateConstructorUsedError;

  /// Lista de convites pendentes de grupo para o usuário atual
  List<ChallengeGroupInvite> get pendingInvites =>
      throw _privateConstructorUsedError;

  /// Lista de ranking/progresso para o desafio selecionado
  List<ChallengeProgress> get progressList =>
      throw _privateConstructorUsedError;

  /// Progresso do usuário atual no desafio selecionado
  ChallengeProgress? get userProgress => throw _privateConstructorUsedError;

  /// Indica se os dados estão sendo carregados
  bool get isLoading => throw _privateConstructorUsedError;

  /// Mensagem de erro, se alguma operação falhou
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Mensagem de sucesso após operações bem-sucedidas
  String? get successMessage => throw _privateConstructorUsedError;

  /// O desafio oficial principal (ex.: Desafio da Ray)
  Challenge? get officialChallenge => throw _privateConstructorUsedError;

  /// ID do grupo selecionado para filtrar o ranking
  String? get selectedGroupIdForFilter => throw _privateConstructorUsedError;

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChallengeStateCopyWith<ChallengeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChallengeStateCopyWith<$Res> {
  factory $ChallengeStateCopyWith(
          ChallengeState value, $Res Function(ChallengeState) then) =
      _$ChallengeStateCopyWithImpl<$Res, ChallengeState>;
  @useResult
  $Res call(
      {List<Challenge> challenges,
      List<Challenge> filteredChallenges,
      Challenge? selectedChallenge,
      List<ChallengeGroupInvite> pendingInvites,
      List<ChallengeProgress> progressList,
      ChallengeProgress? userProgress,
      bool isLoading,
      String? errorMessage,
      String? successMessage,
      Challenge? officialChallenge,
      String? selectedGroupIdForFilter});

  $ChallengeCopyWith<$Res>? get selectedChallenge;
  $ChallengeCopyWith<$Res>? get officialChallenge;
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
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? challenges = null,
    Object? filteredChallenges = null,
    Object? selectedChallenge = freezed,
    Object? pendingInvites = null,
    Object? progressList = null,
    Object? userProgress = freezed,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
    Object? officialChallenge = freezed,
    Object? selectedGroupIdForFilter = freezed,
  }) {
    return _then(_value.copyWith(
      challenges: null == challenges
          ? _value.challenges
          : challenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      filteredChallenges: null == filteredChallenges
          ? _value.filteredChallenges
          : filteredChallenges // ignore: cast_nullable_to_non_nullable
              as List<Challenge>,
      selectedChallenge: freezed == selectedChallenge
          ? _value.selectedChallenge
          : selectedChallenge // ignore: cast_nullable_to_non_nullable
              as Challenge?,
      pendingInvites: null == pendingInvites
          ? _value.pendingInvites
          : pendingInvites // ignore: cast_nullable_to_non_nullable
              as List<ChallengeGroupInvite>,
      progressList: null == progressList
          ? _value.progressList
          : progressList // ignore: cast_nullable_to_non_nullable
              as List<ChallengeProgress>,
      userProgress: freezed == userProgress
          ? _value.userProgress
          : userProgress // ignore: cast_nullable_to_non_nullable
              as ChallengeProgress?,
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
      officialChallenge: freezed == officialChallenge
          ? _value.officialChallenge
          : officialChallenge // ignore: cast_nullable_to_non_nullable
              as Challenge?,
      selectedGroupIdForFilter: freezed == selectedGroupIdForFilter
          ? _value.selectedGroupIdForFilter
          : selectedGroupIdForFilter // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
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
      return _then(_value.copyWith(selectedChallenge: value) as $Val);
    });
  }

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChallengeCopyWith<$Res>? get officialChallenge {
    if (_value.officialChallenge == null) {
      return null;
    }

    return $ChallengeCopyWith<$Res>(_value.officialChallenge!, (value) {
      return _then(_value.copyWith(officialChallenge: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ChallengeStateImplCopyWith<$Res>
    implements $ChallengeStateCopyWith<$Res> {
  factory _$$ChallengeStateImplCopyWith(_$ChallengeStateImpl value,
          $Res Function(_$ChallengeStateImpl) then) =
      __$$ChallengeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Challenge> challenges,
      List<Challenge> filteredChallenges,
      Challenge? selectedChallenge,
      List<ChallengeGroupInvite> pendingInvites,
      List<ChallengeProgress> progressList,
      ChallengeProgress? userProgress,
      bool isLoading,
      String? errorMessage,
      String? successMessage,
      Challenge? officialChallenge,
      String? selectedGroupIdForFilter});

  @override
  $ChallengeCopyWith<$Res>? get selectedChallenge;
  @override
  $ChallengeCopyWith<$Res>? get officialChallenge;
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
    Object? userProgress = freezed,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
    Object? officialChallenge = freezed,
    Object? selectedGroupIdForFilter = freezed,
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
              as List<ChallengeGroupInvite>,
      progressList: null == progressList
          ? _value._progressList
          : progressList // ignore: cast_nullable_to_non_nullable
              as List<ChallengeProgress>,
      userProgress: freezed == userProgress
          ? _value.userProgress
          : userProgress // ignore: cast_nullable_to_non_nullable
              as ChallengeProgress?,
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
      officialChallenge: freezed == officialChallenge
          ? _value.officialChallenge
          : officialChallenge // ignore: cast_nullable_to_non_nullable
              as Challenge?,
      selectedGroupIdForFilter: freezed == selectedGroupIdForFilter
          ? _value.selectedGroupIdForFilter
          : selectedGroupIdForFilter // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ChallengeStateImpl extends _ChallengeState
    with DiagnosticableTreeMixin {
  const _$ChallengeStateImpl(
      {final List<Challenge> challenges = const [],
      final List<Challenge> filteredChallenges = const [],
      this.selectedChallenge,
      final List<ChallengeGroupInvite> pendingInvites = const [],
      final List<ChallengeProgress> progressList = const [],
      this.userProgress,
      this.isLoading = false,
      this.errorMessage,
      this.successMessage,
      this.officialChallenge,
      this.selectedGroupIdForFilter})
      : _challenges = challenges,
        _filteredChallenges = filteredChallenges,
        _pendingInvites = pendingInvites,
        _progressList = progressList,
        super._();

  /// Lista de todos os desafios carregados
  final List<Challenge> _challenges;

  /// Lista de todos os desafios carregados
  @override
  @JsonKey()
  List<Challenge> get challenges {
    if (_challenges is EqualUnmodifiableListView) return _challenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_challenges);
  }

  /// Lista de desafios filtrados por critérios da UI
  final List<Challenge> _filteredChallenges;

  /// Lista de desafios filtrados por critérios da UI
  @override
  @JsonKey()
  List<Challenge> get filteredChallenges {
    if (_filteredChallenges is EqualUnmodifiableListView)
      return _filteredChallenges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredChallenges);
  }

  /// Desafio atualmente selecionado para visualização de detalhes
  @override
  final Challenge? selectedChallenge;

  /// Lista de convites pendentes de grupo para o usuário atual
  final List<ChallengeGroupInvite> _pendingInvites;

  /// Lista de convites pendentes de grupo para o usuário atual
  @override
  @JsonKey()
  List<ChallengeGroupInvite> get pendingInvites {
    if (_pendingInvites is EqualUnmodifiableListView) return _pendingInvites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingInvites);
  }

  /// Lista de ranking/progresso para o desafio selecionado
  final List<ChallengeProgress> _progressList;

  /// Lista de ranking/progresso para o desafio selecionado
  @override
  @JsonKey()
  List<ChallengeProgress> get progressList {
    if (_progressList is EqualUnmodifiableListView) return _progressList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_progressList);
  }

  /// Progresso do usuário atual no desafio selecionado
  @override
  final ChallengeProgress? userProgress;

  /// Indica se os dados estão sendo carregados
  @override
  @JsonKey()
  final bool isLoading;

  /// Mensagem de erro, se alguma operação falhou
  @override
  final String? errorMessage;

  /// Mensagem de sucesso após operações bem-sucedidas
  @override
  final String? successMessage;

  /// O desafio oficial principal (ex.: Desafio da Ray)
  @override
  final Challenge? officialChallenge;

  /// ID do grupo selecionado para filtrar o ranking
  @override
  final String? selectedGroupIdForFilter;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChallengeState(challenges: $challenges, filteredChallenges: $filteredChallenges, selectedChallenge: $selectedChallenge, pendingInvites: $pendingInvites, progressList: $progressList, userProgress: $userProgress, isLoading: $isLoading, errorMessage: $errorMessage, successMessage: $successMessage, officialChallenge: $officialChallenge, selectedGroupIdForFilter: $selectedGroupIdForFilter)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChallengeState'))
      ..add(DiagnosticsProperty('challenges', challenges))
      ..add(DiagnosticsProperty('filteredChallenges', filteredChallenges))
      ..add(DiagnosticsProperty('selectedChallenge', selectedChallenge))
      ..add(DiagnosticsProperty('pendingInvites', pendingInvites))
      ..add(DiagnosticsProperty('progressList', progressList))
      ..add(DiagnosticsProperty('userProgress', userProgress))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('errorMessage', errorMessage))
      ..add(DiagnosticsProperty('successMessage', successMessage))
      ..add(DiagnosticsProperty('officialChallenge', officialChallenge))
      ..add(DiagnosticsProperty(
          'selectedGroupIdForFilter', selectedGroupIdForFilter));
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
            (identical(other.userProgress, userProgress) ||
                other.userProgress == userProgress) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage) &&
            (identical(other.officialChallenge, officialChallenge) ||
                other.officialChallenge == officialChallenge) &&
            (identical(
                    other.selectedGroupIdForFilter, selectedGroupIdForFilter) ||
                other.selectedGroupIdForFilter == selectedGroupIdForFilter));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_challenges),
      const DeepCollectionEquality().hash(_filteredChallenges),
      selectedChallenge,
      const DeepCollectionEquality().hash(_pendingInvites),
      const DeepCollectionEquality().hash(_progressList),
      userProgress,
      isLoading,
      errorMessage,
      successMessage,
      officialChallenge,
      selectedGroupIdForFilter);

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChallengeStateImplCopyWith<_$ChallengeStateImpl> get copyWith =>
      __$$ChallengeStateImplCopyWithImpl<_$ChallengeStateImpl>(
          this, _$identity);
}

abstract class _ChallengeState extends ChallengeState {
  const factory _ChallengeState(
      {final List<Challenge> challenges,
      final List<Challenge> filteredChallenges,
      final Challenge? selectedChallenge,
      final List<ChallengeGroupInvite> pendingInvites,
      final List<ChallengeProgress> progressList,
      final ChallengeProgress? userProgress,
      final bool isLoading,
      final String? errorMessage,
      final String? successMessage,
      final Challenge? officialChallenge,
      final String? selectedGroupIdForFilter}) = _$ChallengeStateImpl;
  const _ChallengeState._() : super._();

  /// Lista de todos os desafios carregados
  @override
  List<Challenge> get challenges;

  /// Lista de desafios filtrados por critérios da UI
  @override
  List<Challenge> get filteredChallenges;

  /// Desafio atualmente selecionado para visualização de detalhes
  @override
  Challenge? get selectedChallenge;

  /// Lista de convites pendentes de grupo para o usuário atual
  @override
  List<ChallengeGroupInvite> get pendingInvites;

  /// Lista de ranking/progresso para o desafio selecionado
  @override
  List<ChallengeProgress> get progressList;

  /// Progresso do usuário atual no desafio selecionado
  @override
  ChallengeProgress? get userProgress;

  /// Indica se os dados estão sendo carregados
  @override
  bool get isLoading;

  /// Mensagem de erro, se alguma operação falhou
  @override
  String? get errorMessage;

  /// Mensagem de sucesso após operações bem-sucedidas
  @override
  String? get successMessage;

  /// O desafio oficial principal (ex.: Desafio da Ray)
  @override
  Challenge? get officialChallenge;

  /// ID do grupo selecionado para filtrar o ranking
  @override
  String? get selectedGroupIdForFilter;

  /// Create a copy of ChallengeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChallengeStateImplCopyWith<_$ChallengeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
