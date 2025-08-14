// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'admin_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AdminState {
  bool get isLoading => throw _privateConstructorUsedError;
  String? get successMessage => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  List<AdminOperation> get operationHistory =>
      throw _privateConstructorUsedError;

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminStateCopyWith<AdminState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminStateCopyWith<$Res> {
  factory $AdminStateCopyWith(
          AdminState value, $Res Function(AdminState) then) =
      _$AdminStateCopyWithImpl<$Res, AdminState>;
  @useResult
  $Res call(
      {bool isLoading,
      String? successMessage,
      String? errorMessage,
      List<AdminOperation> operationHistory});
}

/// @nodoc
class _$AdminStateCopyWithImpl<$Res, $Val extends AdminState>
    implements $AdminStateCopyWith<$Res> {
  _$AdminStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? successMessage = freezed,
    Object? errorMessage = freezed,
    Object? operationHistory = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      successMessage: freezed == successMessage
          ? _value.successMessage
          : successMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      operationHistory: null == operationHistory
          ? _value.operationHistory
          : operationHistory // ignore: cast_nullable_to_non_nullable
              as List<AdminOperation>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdminStateImplCopyWith<$Res>
    implements $AdminStateCopyWith<$Res> {
  factory _$$AdminStateImplCopyWith(
          _$AdminStateImpl value, $Res Function(_$AdminStateImpl) then) =
      __$$AdminStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? successMessage,
      String? errorMessage,
      List<AdminOperation> operationHistory});
}

/// @nodoc
class __$$AdminStateImplCopyWithImpl<$Res>
    extends _$AdminStateCopyWithImpl<$Res, _$AdminStateImpl>
    implements _$$AdminStateImplCopyWith<$Res> {
  __$$AdminStateImplCopyWithImpl(
      _$AdminStateImpl _value, $Res Function(_$AdminStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? successMessage = freezed,
    Object? errorMessage = freezed,
    Object? operationHistory = null,
  }) {
    return _then(_$AdminStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      successMessage: freezed == successMessage
          ? _value.successMessage
          : successMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      operationHistory: null == operationHistory
          ? _value._operationHistory
          : operationHistory // ignore: cast_nullable_to_non_nullable
              as List<AdminOperation>,
    ));
  }
}

/// @nodoc

class _$AdminStateImpl with DiagnosticableTreeMixin implements _AdminState {
  const _$AdminStateImpl(
      {this.isLoading = false,
      this.successMessage,
      this.errorMessage,
      final List<AdminOperation> operationHistory = const []})
      : _operationHistory = operationHistory;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? successMessage;
  @override
  final String? errorMessage;
  final List<AdminOperation> _operationHistory;
  @override
  @JsonKey()
  List<AdminOperation> get operationHistory {
    if (_operationHistory is EqualUnmodifiableListView)
      return _operationHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_operationHistory);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AdminState(isLoading: $isLoading, successMessage: $successMessage, errorMessage: $errorMessage, operationHistory: $operationHistory)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AdminState'))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('successMessage', successMessage))
      ..add(DiagnosticsProperty('errorMessage', errorMessage))
      ..add(DiagnosticsProperty('operationHistory', operationHistory));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            const DeepCollectionEquality()
                .equals(other._operationHistory, _operationHistory));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, successMessage,
      errorMessage, const DeepCollectionEquality().hash(_operationHistory));

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminStateImplCopyWith<_$AdminStateImpl> get copyWith =>
      __$$AdminStateImplCopyWithImpl<_$AdminStateImpl>(this, _$identity);
}

abstract class _AdminState implements AdminState {
  const factory _AdminState(
      {final bool isLoading,
      final String? successMessage,
      final String? errorMessage,
      final List<AdminOperation> operationHistory}) = _$AdminStateImpl;

  @override
  bool get isLoading;
  @override
  String? get successMessage;
  @override
  String? get errorMessage;
  @override
  List<AdminOperation> get operationHistory;

  /// Create a copy of AdminState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminStateImplCopyWith<_$AdminStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AdminOperation {
  String get email => throw _privateConstructorUsedError;
  String get level => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of AdminOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdminOperationCopyWith<AdminOperation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdminOperationCopyWith<$Res> {
  factory $AdminOperationCopyWith(
          AdminOperation value, $Res Function(AdminOperation) then) =
      _$AdminOperationCopyWithImpl<$Res, AdminOperation>;
  @useResult
  $Res call(
      {String email,
      String level,
      bool success,
      DateTime timestamp,
      String? errorMessage});
}

/// @nodoc
class _$AdminOperationCopyWithImpl<$Res, $Val extends AdminOperation>
    implements $AdminOperationCopyWith<$Res> {
  _$AdminOperationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdminOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? level = null,
    Object? success = null,
    Object? timestamp = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AdminOperationImplCopyWith<$Res>
    implements $AdminOperationCopyWith<$Res> {
  factory _$$AdminOperationImplCopyWith(_$AdminOperationImpl value,
          $Res Function(_$AdminOperationImpl) then) =
      __$$AdminOperationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String email,
      String level,
      bool success,
      DateTime timestamp,
      String? errorMessage});
}

/// @nodoc
class __$$AdminOperationImplCopyWithImpl<$Res>
    extends _$AdminOperationCopyWithImpl<$Res, _$AdminOperationImpl>
    implements _$$AdminOperationImplCopyWith<$Res> {
  __$$AdminOperationImplCopyWithImpl(
      _$AdminOperationImpl _value, $Res Function(_$AdminOperationImpl) _then)
      : super(_value, _then);

  /// Create a copy of AdminOperation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? level = null,
    Object? success = null,
    Object? timestamp = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$AdminOperationImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _value.level
          : level // ignore: cast_nullable_to_non_nullable
              as String,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$AdminOperationImpl
    with DiagnosticableTreeMixin
    implements _AdminOperation {
  const _$AdminOperationImpl(
      {required this.email,
      required this.level,
      required this.success,
      required this.timestamp,
      this.errorMessage});

  @override
  final String email;
  @override
  final String level;
  @override
  final bool success;
  @override
  final DateTime timestamp;
  @override
  final String? errorMessage;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AdminOperation(email: $email, level: $level, success: $success, timestamp: $timestamp, errorMessage: $errorMessage)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AdminOperation'))
      ..add(DiagnosticsProperty('email', email))
      ..add(DiagnosticsProperty('level', level))
      ..add(DiagnosticsProperty('success', success))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('errorMessage', errorMessage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdminOperationImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, email, level, success, timestamp, errorMessage);

  /// Create a copy of AdminOperation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdminOperationImplCopyWith<_$AdminOperationImpl> get copyWith =>
      __$$AdminOperationImplCopyWithImpl<_$AdminOperationImpl>(
          this, _$identity);
}

abstract class _AdminOperation implements AdminOperation {
  const factory _AdminOperation(
      {required final String email,
      required final String level,
      required final bool success,
      required final DateTime timestamp,
      final String? errorMessage}) = _$AdminOperationImpl;

  @override
  String get email;
  @override
  String get level;
  @override
  bool get success;
  @override
  DateTime get timestamp;
  @override
  String? get errorMessage;

  /// Create a copy of AdminOperation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdminOperationImplCopyWith<_$AdminOperationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
