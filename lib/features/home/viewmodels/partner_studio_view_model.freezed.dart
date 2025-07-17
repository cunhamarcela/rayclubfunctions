// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_studio_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PartnerStudioState {
  List<PartnerStudio> get studios => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of PartnerStudioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PartnerStudioStateCopyWith<PartnerStudioState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerStudioStateCopyWith<$Res> {
  factory $PartnerStudioStateCopyWith(
          PartnerStudioState value, $Res Function(PartnerStudioState) then) =
      _$PartnerStudioStateCopyWithImpl<$Res, PartnerStudioState>;
  @useResult
  $Res call(
      {List<PartnerStudio> studios, bool isLoading, String? errorMessage});
}

/// @nodoc
class _$PartnerStudioStateCopyWithImpl<$Res, $Val extends PartnerStudioState>
    implements $PartnerStudioStateCopyWith<$Res> {
  _$PartnerStudioStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PartnerStudioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studios = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      studios: null == studios
          ? _value.studios
          : studios // ignore: cast_nullable_to_non_nullable
              as List<PartnerStudio>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PartnerStudioStateImplCopyWith<$Res>
    implements $PartnerStudioStateCopyWith<$Res> {
  factory _$$PartnerStudioStateImplCopyWith(_$PartnerStudioStateImpl value,
          $Res Function(_$PartnerStudioStateImpl) then) =
      __$$PartnerStudioStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PartnerStudio> studios, bool isLoading, String? errorMessage});
}

/// @nodoc
class __$$PartnerStudioStateImplCopyWithImpl<$Res>
    extends _$PartnerStudioStateCopyWithImpl<$Res, _$PartnerStudioStateImpl>
    implements _$$PartnerStudioStateImplCopyWith<$Res> {
  __$$PartnerStudioStateImplCopyWithImpl(_$PartnerStudioStateImpl _value,
      $Res Function(_$PartnerStudioStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PartnerStudioState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? studios = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PartnerStudioStateImpl(
      studios: null == studios
          ? _value._studios
          : studios // ignore: cast_nullable_to_non_nullable
              as List<PartnerStudio>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PartnerStudioStateImpl implements _PartnerStudioState {
  const _$PartnerStudioStateImpl(
      {final List<PartnerStudio> studios = const [],
      this.isLoading = false,
      this.errorMessage})
      : _studios = studios;

  final List<PartnerStudio> _studios;
  @override
  @JsonKey()
  List<PartnerStudio> get studios {
    if (_studios is EqualUnmodifiableListView) return _studios;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_studios);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PartnerStudioState(studios: $studios, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartnerStudioStateImpl &&
            const DeepCollectionEquality().equals(other._studios, _studios) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType,
      const DeepCollectionEquality().hash(_studios), isLoading, errorMessage);

  /// Create a copy of PartnerStudioState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartnerStudioStateImplCopyWith<_$PartnerStudioStateImpl> get copyWith =>
      __$$PartnerStudioStateImplCopyWithImpl<_$PartnerStudioStateImpl>(
          this, _$identity);
}

abstract class _PartnerStudioState implements PartnerStudioState {
  const factory _PartnerStudioState(
      {final List<PartnerStudio> studios,
      final bool isLoading,
      final String? errorMessage}) = _$PartnerStudioStateImpl;

  @override
  List<PartnerStudio> get studios;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of PartnerStudioState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartnerStudioStateImplCopyWith<_$PartnerStudioStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
