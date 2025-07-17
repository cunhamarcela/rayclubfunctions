// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'benefit_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BenefitState {
  /// Lista de todos os benefícios disponíveis
  List<Benefit> get benefits => throw _privateConstructorUsedError;

  /// Lista de benefícios resgatados pelo usuário
  List<RedeemedBenefit> get redeemedBenefits =>
      throw _privateConstructorUsedError;

  /// Lista de categorias de benefícios
  List<String> get categories => throw _privateConstructorUsedError;

  /// Categoria atualmente selecionada para filtro
  String? get selectedCategory => throw _privateConstructorUsedError;

  /// Benefício selecionado para visualização detalhada
  Benefit? get selectedBenefit => throw _privateConstructorUsedError;

  /// Benefício resgatado selecionado para visualização
  RedeemedBenefit? get selectedRedeemedBenefit =>
      throw _privateConstructorUsedError;

  /// Pontos disponíveis do usuário
  int? get userPoints => throw _privateConstructorUsedError;

  /// Indica se está carregando dados
  bool get isLoading => throw _privateConstructorUsedError;

  /// Mensagem de erro, se houver
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Mensagem de sucesso, se houver
  String? get successMessage => throw _privateConstructorUsedError;

  /// Indica se está em processo de resgate
  bool get isRedeeming => throw _privateConstructorUsedError;

  /// Benefício que está sendo resgatado atualmente
  Benefit? get benefitBeingRedeemed => throw _privateConstructorUsedError;

  /// Dados do QR code gerado
  String? get qrCodeData => throw _privateConstructorUsedError;

  /// Data/hora de expiração do QR code
  DateTime? get qrCodeExpiresAt => throw _privateConstructorUsedError;

  /// Create a copy of BenefitState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BenefitStateCopyWith<BenefitState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BenefitStateCopyWith<$Res> {
  factory $BenefitStateCopyWith(
          BenefitState value, $Res Function(BenefitState) then) =
      _$BenefitStateCopyWithImpl<$Res, BenefitState>;
  @useResult
  $Res call(
      {List<Benefit> benefits,
      List<RedeemedBenefit> redeemedBenefits,
      List<String> categories,
      String? selectedCategory,
      Benefit? selectedBenefit,
      RedeemedBenefit? selectedRedeemedBenefit,
      int? userPoints,
      bool isLoading,
      String? errorMessage,
      String? successMessage,
      bool isRedeeming,
      Benefit? benefitBeingRedeemed,
      String? qrCodeData,
      DateTime? qrCodeExpiresAt});

  $BenefitCopyWith<$Res>? get selectedBenefit;
  $RedeemedBenefitCopyWith<$Res>? get selectedRedeemedBenefit;
  $BenefitCopyWith<$Res>? get benefitBeingRedeemed;
}

/// @nodoc
class _$BenefitStateCopyWithImpl<$Res, $Val extends BenefitState>
    implements $BenefitStateCopyWith<$Res> {
  _$BenefitStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BenefitState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? benefits = null,
    Object? redeemedBenefits = null,
    Object? categories = null,
    Object? selectedCategory = freezed,
    Object? selectedBenefit = freezed,
    Object? selectedRedeemedBenefit = freezed,
    Object? userPoints = freezed,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
    Object? isRedeeming = null,
    Object? benefitBeingRedeemed = freezed,
    Object? qrCodeData = freezed,
    Object? qrCodeExpiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      benefits: null == benefits
          ? _value.benefits
          : benefits // ignore: cast_nullable_to_non_nullable
              as List<Benefit>,
      redeemedBenefits: null == redeemedBenefits
          ? _value.redeemedBenefits
          : redeemedBenefits // ignore: cast_nullable_to_non_nullable
              as List<RedeemedBenefit>,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedCategory: freezed == selectedCategory
          ? _value.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedBenefit: freezed == selectedBenefit
          ? _value.selectedBenefit
          : selectedBenefit // ignore: cast_nullable_to_non_nullable
              as Benefit?,
      selectedRedeemedBenefit: freezed == selectedRedeemedBenefit
          ? _value.selectedRedeemedBenefit
          : selectedRedeemedBenefit // ignore: cast_nullable_to_non_nullable
              as RedeemedBenefit?,
      userPoints: freezed == userPoints
          ? _value.userPoints
          : userPoints // ignore: cast_nullable_to_non_nullable
              as int?,
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
      isRedeeming: null == isRedeeming
          ? _value.isRedeeming
          : isRedeeming // ignore: cast_nullable_to_non_nullable
              as bool,
      benefitBeingRedeemed: freezed == benefitBeingRedeemed
          ? _value.benefitBeingRedeemed
          : benefitBeingRedeemed // ignore: cast_nullable_to_non_nullable
              as Benefit?,
      qrCodeData: freezed == qrCodeData
          ? _value.qrCodeData
          : qrCodeData // ignore: cast_nullable_to_non_nullable
              as String?,
      qrCodeExpiresAt: freezed == qrCodeExpiresAt
          ? _value.qrCodeExpiresAt
          : qrCodeExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of BenefitState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BenefitCopyWith<$Res>? get selectedBenefit {
    if (_value.selectedBenefit == null) {
      return null;
    }

    return $BenefitCopyWith<$Res>(_value.selectedBenefit!, (value) {
      return _then(_value.copyWith(selectedBenefit: value) as $Val);
    });
  }

  /// Create a copy of BenefitState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RedeemedBenefitCopyWith<$Res>? get selectedRedeemedBenefit {
    if (_value.selectedRedeemedBenefit == null) {
      return null;
    }

    return $RedeemedBenefitCopyWith<$Res>(_value.selectedRedeemedBenefit!,
        (value) {
      return _then(_value.copyWith(selectedRedeemedBenefit: value) as $Val);
    });
  }

  /// Create a copy of BenefitState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BenefitCopyWith<$Res>? get benefitBeingRedeemed {
    if (_value.benefitBeingRedeemed == null) {
      return null;
    }

    return $BenefitCopyWith<$Res>(_value.benefitBeingRedeemed!, (value) {
      return _then(_value.copyWith(benefitBeingRedeemed: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$BenefitStateImplCopyWith<$Res>
    implements $BenefitStateCopyWith<$Res> {
  factory _$$BenefitStateImplCopyWith(
          _$BenefitStateImpl value, $Res Function(_$BenefitStateImpl) then) =
      __$$BenefitStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Benefit> benefits,
      List<RedeemedBenefit> redeemedBenefits,
      List<String> categories,
      String? selectedCategory,
      Benefit? selectedBenefit,
      RedeemedBenefit? selectedRedeemedBenefit,
      int? userPoints,
      bool isLoading,
      String? errorMessage,
      String? successMessage,
      bool isRedeeming,
      Benefit? benefitBeingRedeemed,
      String? qrCodeData,
      DateTime? qrCodeExpiresAt});

  @override
  $BenefitCopyWith<$Res>? get selectedBenefit;
  @override
  $RedeemedBenefitCopyWith<$Res>? get selectedRedeemedBenefit;
  @override
  $BenefitCopyWith<$Res>? get benefitBeingRedeemed;
}

/// @nodoc
class __$$BenefitStateImplCopyWithImpl<$Res>
    extends _$BenefitStateCopyWithImpl<$Res, _$BenefitStateImpl>
    implements _$$BenefitStateImplCopyWith<$Res> {
  __$$BenefitStateImplCopyWithImpl(
      _$BenefitStateImpl _value, $Res Function(_$BenefitStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BenefitState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? benefits = null,
    Object? redeemedBenefits = null,
    Object? categories = null,
    Object? selectedCategory = freezed,
    Object? selectedBenefit = freezed,
    Object? selectedRedeemedBenefit = freezed,
    Object? userPoints = freezed,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
    Object? isRedeeming = null,
    Object? benefitBeingRedeemed = freezed,
    Object? qrCodeData = freezed,
    Object? qrCodeExpiresAt = freezed,
  }) {
    return _then(_$BenefitStateImpl(
      benefits: null == benefits
          ? _value._benefits
          : benefits // ignore: cast_nullable_to_non_nullable
              as List<Benefit>,
      redeemedBenefits: null == redeemedBenefits
          ? _value._redeemedBenefits
          : redeemedBenefits // ignore: cast_nullable_to_non_nullable
              as List<RedeemedBenefit>,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<String>,
      selectedCategory: freezed == selectedCategory
          ? _value.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedBenefit: freezed == selectedBenefit
          ? _value.selectedBenefit
          : selectedBenefit // ignore: cast_nullable_to_non_nullable
              as Benefit?,
      selectedRedeemedBenefit: freezed == selectedRedeemedBenefit
          ? _value.selectedRedeemedBenefit
          : selectedRedeemedBenefit // ignore: cast_nullable_to_non_nullable
              as RedeemedBenefit?,
      userPoints: freezed == userPoints
          ? _value.userPoints
          : userPoints // ignore: cast_nullable_to_non_nullable
              as int?,
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
      isRedeeming: null == isRedeeming
          ? _value.isRedeeming
          : isRedeeming // ignore: cast_nullable_to_non_nullable
              as bool,
      benefitBeingRedeemed: freezed == benefitBeingRedeemed
          ? _value.benefitBeingRedeemed
          : benefitBeingRedeemed // ignore: cast_nullable_to_non_nullable
              as Benefit?,
      qrCodeData: freezed == qrCodeData
          ? _value.qrCodeData
          : qrCodeData // ignore: cast_nullable_to_non_nullable
              as String?,
      qrCodeExpiresAt: freezed == qrCodeExpiresAt
          ? _value.qrCodeExpiresAt
          : qrCodeExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

class _$BenefitStateImpl implements _BenefitState {
  const _$BenefitStateImpl(
      {final List<Benefit> benefits = const [],
      final List<RedeemedBenefit> redeemedBenefits = const [],
      final List<String> categories = const [],
      this.selectedCategory,
      this.selectedBenefit,
      this.selectedRedeemedBenefit,
      this.userPoints,
      this.isLoading = false,
      this.errorMessage,
      this.successMessage,
      this.isRedeeming = false,
      this.benefitBeingRedeemed,
      this.qrCodeData,
      this.qrCodeExpiresAt})
      : _benefits = benefits,
        _redeemedBenefits = redeemedBenefits,
        _categories = categories;

  /// Lista de todos os benefícios disponíveis
  final List<Benefit> _benefits;

  /// Lista de todos os benefícios disponíveis
  @override
  @JsonKey()
  List<Benefit> get benefits {
    if (_benefits is EqualUnmodifiableListView) return _benefits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_benefits);
  }

  /// Lista de benefícios resgatados pelo usuário
  final List<RedeemedBenefit> _redeemedBenefits;

  /// Lista de benefícios resgatados pelo usuário
  @override
  @JsonKey()
  List<RedeemedBenefit> get redeemedBenefits {
    if (_redeemedBenefits is EqualUnmodifiableListView)
      return _redeemedBenefits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_redeemedBenefits);
  }

  /// Lista de categorias de benefícios
  final List<String> _categories;

  /// Lista de categorias de benefícios
  @override
  @JsonKey()
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  /// Categoria atualmente selecionada para filtro
  @override
  final String? selectedCategory;

  /// Benefício selecionado para visualização detalhada
  @override
  final Benefit? selectedBenefit;

  /// Benefício resgatado selecionado para visualização
  @override
  final RedeemedBenefit? selectedRedeemedBenefit;

  /// Pontos disponíveis do usuário
  @override
  final int? userPoints;

  /// Indica se está carregando dados
  @override
  @JsonKey()
  final bool isLoading;

  /// Mensagem de erro, se houver
  @override
  final String? errorMessage;

  /// Mensagem de sucesso, se houver
  @override
  final String? successMessage;

  /// Indica se está em processo de resgate
  @override
  @JsonKey()
  final bool isRedeeming;

  /// Benefício que está sendo resgatado atualmente
  @override
  final Benefit? benefitBeingRedeemed;

  /// Dados do QR code gerado
  @override
  final String? qrCodeData;

  /// Data/hora de expiração do QR code
  @override
  final DateTime? qrCodeExpiresAt;

  @override
  String toString() {
    return 'BenefitState(benefits: $benefits, redeemedBenefits: $redeemedBenefits, categories: $categories, selectedCategory: $selectedCategory, selectedBenefit: $selectedBenefit, selectedRedeemedBenefit: $selectedRedeemedBenefit, userPoints: $userPoints, isLoading: $isLoading, errorMessage: $errorMessage, successMessage: $successMessage, isRedeeming: $isRedeeming, benefitBeingRedeemed: $benefitBeingRedeemed, qrCodeData: $qrCodeData, qrCodeExpiresAt: $qrCodeExpiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BenefitStateImpl &&
            const DeepCollectionEquality().equals(other._benefits, _benefits) &&
            const DeepCollectionEquality()
                .equals(other._redeemedBenefits, _redeemedBenefits) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            (identical(other.selectedBenefit, selectedBenefit) ||
                other.selectedBenefit == selectedBenefit) &&
            (identical(
                    other.selectedRedeemedBenefit, selectedRedeemedBenefit) ||
                other.selectedRedeemedBenefit == selectedRedeemedBenefit) &&
            (identical(other.userPoints, userPoints) ||
                other.userPoints == userPoints) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage) &&
            (identical(other.isRedeeming, isRedeeming) ||
                other.isRedeeming == isRedeeming) &&
            (identical(other.benefitBeingRedeemed, benefitBeingRedeemed) ||
                other.benefitBeingRedeemed == benefitBeingRedeemed) &&
            (identical(other.qrCodeData, qrCodeData) ||
                other.qrCodeData == qrCodeData) &&
            (identical(other.qrCodeExpiresAt, qrCodeExpiresAt) ||
                other.qrCodeExpiresAt == qrCodeExpiresAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_benefits),
      const DeepCollectionEquality().hash(_redeemedBenefits),
      const DeepCollectionEquality().hash(_categories),
      selectedCategory,
      selectedBenefit,
      selectedRedeemedBenefit,
      userPoints,
      isLoading,
      errorMessage,
      successMessage,
      isRedeeming,
      benefitBeingRedeemed,
      qrCodeData,
      qrCodeExpiresAt);

  /// Create a copy of BenefitState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BenefitStateImplCopyWith<_$BenefitStateImpl> get copyWith =>
      __$$BenefitStateImplCopyWithImpl<_$BenefitStateImpl>(this, _$identity);
}

abstract class _BenefitState implements BenefitState {
  const factory _BenefitState(
      {final List<Benefit> benefits,
      final List<RedeemedBenefit> redeemedBenefits,
      final List<String> categories,
      final String? selectedCategory,
      final Benefit? selectedBenefit,
      final RedeemedBenefit? selectedRedeemedBenefit,
      final int? userPoints,
      final bool isLoading,
      final String? errorMessage,
      final String? successMessage,
      final bool isRedeeming,
      final Benefit? benefitBeingRedeemed,
      final String? qrCodeData,
      final DateTime? qrCodeExpiresAt}) = _$BenefitStateImpl;

  /// Lista de todos os benefícios disponíveis
  @override
  List<Benefit> get benefits;

  /// Lista de benefícios resgatados pelo usuário
  @override
  List<RedeemedBenefit> get redeemedBenefits;

  /// Lista de categorias de benefícios
  @override
  List<String> get categories;

  /// Categoria atualmente selecionada para filtro
  @override
  String? get selectedCategory;

  /// Benefício selecionado para visualização detalhada
  @override
  Benefit? get selectedBenefit;

  /// Benefício resgatado selecionado para visualização
  @override
  RedeemedBenefit? get selectedRedeemedBenefit;

  /// Pontos disponíveis do usuário
  @override
  int? get userPoints;

  /// Indica se está carregando dados
  @override
  bool get isLoading;

  /// Mensagem de erro, se houver
  @override
  String? get errorMessage;

  /// Mensagem de sucesso, se houver
  @override
  String? get successMessage;

  /// Indica se está em processo de resgate
  @override
  bool get isRedeeming;

  /// Benefício que está sendo resgatado atualmente
  @override
  Benefit? get benefitBeingRedeemed;

  /// Dados do QR code gerado
  @override
  String? get qrCodeData;

  /// Data/hora de expiração do QR code
  @override
  DateTime? get qrCodeExpiresAt;

  /// Create a copy of BenefitState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BenefitStateImplCopyWith<_$BenefitStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
