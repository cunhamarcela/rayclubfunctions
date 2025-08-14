// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_goal_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CreateGoalState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of CreateGoalState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateGoalStateCopyWith<CreateGoalState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateGoalStateCopyWith<$Res> {
  factory $CreateGoalStateCopyWith(
          CreateGoalState value, $Res Function(CreateGoalState) then) =
      _$CreateGoalStateCopyWithImpl<$Res, CreateGoalState>;
  @useResult
  $Res call({bool isLoading, bool isSuccess, String? errorMessage});
}

/// @nodoc
class _$CreateGoalStateCopyWithImpl<$Res, $Val extends CreateGoalState>
    implements $CreateGoalStateCopyWith<$Res> {
  _$CreateGoalStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateGoalState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isSuccess = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CreateGoalStateImplCopyWith<$Res>
    implements $CreateGoalStateCopyWith<$Res> {
  factory _$$CreateGoalStateImplCopyWith(_$CreateGoalStateImpl value,
          $Res Function(_$CreateGoalStateImpl) then) =
      __$$CreateGoalStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, bool isSuccess, String? errorMessage});
}

/// @nodoc
class __$$CreateGoalStateImplCopyWithImpl<$Res>
    extends _$CreateGoalStateCopyWithImpl<$Res, _$CreateGoalStateImpl>
    implements _$$CreateGoalStateImplCopyWith<$Res> {
  __$$CreateGoalStateImplCopyWithImpl(
      _$CreateGoalStateImpl _value, $Res Function(_$CreateGoalStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CreateGoalState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isSuccess = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$CreateGoalStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CreateGoalStateImpl
    with DiagnosticableTreeMixin
    implements _CreateGoalState {
  const _$CreateGoalStateImpl(
      {this.isLoading = false, this.isSuccess = false, this.errorMessage});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSuccess;
  @override
  final String? errorMessage;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CreateGoalState(isLoading: $isLoading, isSuccess: $isSuccess, errorMessage: $errorMessage)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'CreateGoalState'))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('isSuccess', isSuccess))
      ..add(DiagnosticsProperty('errorMessage', errorMessage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateGoalStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, isSuccess, errorMessage);

  /// Create a copy of CreateGoalState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateGoalStateImplCopyWith<_$CreateGoalStateImpl> get copyWith =>
      __$$CreateGoalStateImplCopyWithImpl<_$CreateGoalStateImpl>(
          this, _$identity);
}

abstract class _CreateGoalState implements CreateGoalState {
  const factory _CreateGoalState(
      {final bool isLoading,
      final bool isSuccess,
      final String? errorMessage}) = _$CreateGoalStateImpl;

  @override
  bool get isLoading;
  @override
  bool get isSuccess;
  @override
  String? get errorMessage;

  /// Create a copy of CreateGoalState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateGoalStateImplCopyWith<_$CreateGoalStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
