// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'benefits_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BenefitsState {
  List<Benefit> get benefits => throw _privateConstructorUsedError;
  List<Benefit> get filteredBenefits => throw _privateConstructorUsedError;
  String get activeTab => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  Benefit? get selectedBenefit => throw _privateConstructorUsedError;
  List<String> get partners => throw _privateConstructorUsedError;

  /// Create a copy of BenefitsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BenefitsStateCopyWith<BenefitsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BenefitsStateCopyWith<$Res> {
  factory $BenefitsStateCopyWith(
          BenefitsState value, $Res Function(BenefitsState) then) =
      _$BenefitsStateCopyWithImpl<$Res, BenefitsState>;
  @useResult
  $Res call(
      {List<Benefit> benefits,
      List<Benefit> filteredBenefits,
      String activeTab,
      bool isLoading,
      String? errorMessage,
      Benefit? selectedBenefit,
      List<String> partners});

  $BenefitCopyWith<$Res>? get selectedBenefit;
}

/// @nodoc
class _$BenefitsStateCopyWithImpl<$Res, $Val extends BenefitsState>
    implements $BenefitsStateCopyWith<$Res> {
  _$BenefitsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BenefitsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? benefits = null,
    Object? filteredBenefits = null,
    Object? activeTab = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? selectedBenefit = freezed,
    Object? partners = null,
  }) {
    return _then(_value.copyWith(
      benefits: null == benefits
          ? _value.benefits
          : benefits // ignore: cast_nullable_to_non_nullable
              as List<Benefit>,
      filteredBenefits: null == filteredBenefits
          ? _value.filteredBenefits
          : filteredBenefits // ignore: cast_nullable_to_non_nullable
              as List<Benefit>,
      activeTab: null == activeTab
          ? _value.activeTab
          : activeTab // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedBenefit: freezed == selectedBenefit
          ? _value.selectedBenefit
          : selectedBenefit // ignore: cast_nullable_to_non_nullable
              as Benefit?,
      partners: null == partners
          ? _value.partners
          : partners // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  /// Create a copy of BenefitsState
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
}

/// @nodoc
abstract class _$$BenefitsStateImplCopyWith<$Res>
    implements $BenefitsStateCopyWith<$Res> {
  factory _$$BenefitsStateImplCopyWith(
          _$BenefitsStateImpl value, $Res Function(_$BenefitsStateImpl) then) =
      __$$BenefitsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Benefit> benefits,
      List<Benefit> filteredBenefits,
      String activeTab,
      bool isLoading,
      String? errorMessage,
      Benefit? selectedBenefit,
      List<String> partners});

  @override
  $BenefitCopyWith<$Res>? get selectedBenefit;
}

/// @nodoc
class __$$BenefitsStateImplCopyWithImpl<$Res>
    extends _$BenefitsStateCopyWithImpl<$Res, _$BenefitsStateImpl>
    implements _$$BenefitsStateImplCopyWith<$Res> {
  __$$BenefitsStateImplCopyWithImpl(
      _$BenefitsStateImpl _value, $Res Function(_$BenefitsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BenefitsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? benefits = null,
    Object? filteredBenefits = null,
    Object? activeTab = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? selectedBenefit = freezed,
    Object? partners = null,
  }) {
    return _then(_$BenefitsStateImpl(
      benefits: null == benefits
          ? _value._benefits
          : benefits // ignore: cast_nullable_to_non_nullable
              as List<Benefit>,
      filteredBenefits: null == filteredBenefits
          ? _value._filteredBenefits
          : filteredBenefits // ignore: cast_nullable_to_non_nullable
              as List<Benefit>,
      activeTab: null == activeTab
          ? _value.activeTab
          : activeTab // ignore: cast_nullable_to_non_nullable
              as String,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      selectedBenefit: freezed == selectedBenefit
          ? _value.selectedBenefit
          : selectedBenefit // ignore: cast_nullable_to_non_nullable
              as Benefit?,
      partners: null == partners
          ? _value._partners
          : partners // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$BenefitsStateImpl implements _BenefitsState {
  const _$BenefitsStateImpl(
      {final List<Benefit> benefits = const [],
      final List<Benefit> filteredBenefits = const [],
      this.activeTab = 'all',
      this.isLoading = false,
      this.errorMessage,
      this.selectedBenefit,
      final List<String> partners = const []})
      : _benefits = benefits,
        _filteredBenefits = filteredBenefits,
        _partners = partners;

  final List<Benefit> _benefits;
  @override
  @JsonKey()
  List<Benefit> get benefits {
    if (_benefits is EqualUnmodifiableListView) return _benefits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_benefits);
  }

  final List<Benefit> _filteredBenefits;
  @override
  @JsonKey()
  List<Benefit> get filteredBenefits {
    if (_filteredBenefits is EqualUnmodifiableListView)
      return _filteredBenefits;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredBenefits);
  }

  @override
  @JsonKey()
  final String activeTab;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  final Benefit? selectedBenefit;
  final List<String> _partners;
  @override
  @JsonKey()
  List<String> get partners {
    if (_partners is EqualUnmodifiableListView) return _partners;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_partners);
  }

  @override
  String toString() {
    return 'BenefitsState(benefits: $benefits, filteredBenefits: $filteredBenefits, activeTab: $activeTab, isLoading: $isLoading, errorMessage: $errorMessage, selectedBenefit: $selectedBenefit, partners: $partners)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BenefitsStateImpl &&
            const DeepCollectionEquality().equals(other._benefits, _benefits) &&
            const DeepCollectionEquality()
                .equals(other._filteredBenefits, _filteredBenefits) &&
            (identical(other.activeTab, activeTab) ||
                other.activeTab == activeTab) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.selectedBenefit, selectedBenefit) ||
                other.selectedBenefit == selectedBenefit) &&
            const DeepCollectionEquality().equals(other._partners, _partners));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_benefits),
      const DeepCollectionEquality().hash(_filteredBenefits),
      activeTab,
      isLoading,
      errorMessage,
      selectedBenefit,
      const DeepCollectionEquality().hash(_partners));

  /// Create a copy of BenefitsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BenefitsStateImplCopyWith<_$BenefitsStateImpl> get copyWith =>
      __$$BenefitsStateImplCopyWithImpl<_$BenefitsStateImpl>(this, _$identity);
}

abstract class _BenefitsState implements BenefitsState {
  const factory _BenefitsState(
      {final List<Benefit> benefits,
      final List<Benefit> filteredBenefits,
      final String activeTab,
      final bool isLoading,
      final String? errorMessage,
      final Benefit? selectedBenefit,
      final List<String> partners}) = _$BenefitsStateImpl;

  @override
  List<Benefit> get benefits;
  @override
  List<Benefit> get filteredBenefits;
  @override
  String get activeTab;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  Benefit? get selectedBenefit;
  @override
  List<String> get partners;

  /// Create a copy of BenefitsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BenefitsStateImplCopyWith<_$BenefitsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
