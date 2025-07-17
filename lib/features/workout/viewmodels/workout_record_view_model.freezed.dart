// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_record_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WorkoutRecordState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<WorkoutRecord> get records => throw _privateConstructorUsedError;
  String get selectedWorkoutType => throw _privateConstructorUsedError;
  double get intensity => throw _privateConstructorUsedError;
  List<XFile> get selectedImages => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get successMessage => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutRecordState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutRecordStateCopyWith<WorkoutRecordState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutRecordStateCopyWith<$Res> {
  factory $WorkoutRecordStateCopyWith(
          WorkoutRecordState value, $Res Function(WorkoutRecordState) then) =
      _$WorkoutRecordStateCopyWithImpl<$Res, WorkoutRecordState>;
  @useResult
  $Res call(
      {bool isLoading,
      List<WorkoutRecord> records,
      String selectedWorkoutType,
      double intensity,
      List<XFile> selectedImages,
      String? errorMessage,
      String? successMessage});
}

/// @nodoc
class _$WorkoutRecordStateCopyWithImpl<$Res, $Val extends WorkoutRecordState>
    implements $WorkoutRecordStateCopyWith<$Res> {
  _$WorkoutRecordStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutRecordState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? records = null,
    Object? selectedWorkoutType = null,
    Object? intensity = null,
    Object? selectedImages = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      records: null == records
          ? _value.records
          : records // ignore: cast_nullable_to_non_nullable
              as List<WorkoutRecord>,
      selectedWorkoutType: null == selectedWorkoutType
          ? _value.selectedWorkoutType
          : selectedWorkoutType // ignore: cast_nullable_to_non_nullable
              as String,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as double,
      selectedImages: null == selectedImages
          ? _value.selectedImages
          : selectedImages // ignore: cast_nullable_to_non_nullable
              as List<XFile>,
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
abstract class _$$WorkoutRecordStateImplCopyWith<$Res>
    implements $WorkoutRecordStateCopyWith<$Res> {
  factory _$$WorkoutRecordStateImplCopyWith(_$WorkoutRecordStateImpl value,
          $Res Function(_$WorkoutRecordStateImpl) then) =
      __$$WorkoutRecordStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      List<WorkoutRecord> records,
      String selectedWorkoutType,
      double intensity,
      List<XFile> selectedImages,
      String? errorMessage,
      String? successMessage});
}

/// @nodoc
class __$$WorkoutRecordStateImplCopyWithImpl<$Res>
    extends _$WorkoutRecordStateCopyWithImpl<$Res, _$WorkoutRecordStateImpl>
    implements _$$WorkoutRecordStateImplCopyWith<$Res> {
  __$$WorkoutRecordStateImplCopyWithImpl(_$WorkoutRecordStateImpl _value,
      $Res Function(_$WorkoutRecordStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of WorkoutRecordState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? records = null,
    Object? selectedWorkoutType = null,
    Object? intensity = null,
    Object? selectedImages = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(_$WorkoutRecordStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      records: null == records
          ? _value._records
          : records // ignore: cast_nullable_to_non_nullable
              as List<WorkoutRecord>,
      selectedWorkoutType: null == selectedWorkoutType
          ? _value.selectedWorkoutType
          : selectedWorkoutType // ignore: cast_nullable_to_non_nullable
              as String,
      intensity: null == intensity
          ? _value.intensity
          : intensity // ignore: cast_nullable_to_non_nullable
              as double,
      selectedImages: null == selectedImages
          ? _value._selectedImages
          : selectedImages // ignore: cast_nullable_to_non_nullable
              as List<XFile>,
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

class _$WorkoutRecordStateImpl
    with DiagnosticableTreeMixin
    implements _WorkoutRecordState {
  const _$WorkoutRecordStateImpl(
      {this.isLoading = false,
      final List<WorkoutRecord> records = const [],
      this.selectedWorkoutType = 'Funcional',
      this.intensity = 0.3,
      final List<XFile> selectedImages = const [],
      this.errorMessage,
      this.successMessage})
      : _records = records,
        _selectedImages = selectedImages;

  @override
  @JsonKey()
  final bool isLoading;
  final List<WorkoutRecord> _records;
  @override
  @JsonKey()
  List<WorkoutRecord> get records {
    if (_records is EqualUnmodifiableListView) return _records;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_records);
  }

  @override
  @JsonKey()
  final String selectedWorkoutType;
  @override
  @JsonKey()
  final double intensity;
  final List<XFile> _selectedImages;
  @override
  @JsonKey()
  List<XFile> get selectedImages {
    if (_selectedImages is EqualUnmodifiableListView) return _selectedImages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedImages);
  }

  @override
  final String? errorMessage;
  @override
  final String? successMessage;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'WorkoutRecordState(isLoading: $isLoading, records: $records, selectedWorkoutType: $selectedWorkoutType, intensity: $intensity, selectedImages: $selectedImages, errorMessage: $errorMessage, successMessage: $successMessage)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'WorkoutRecordState'))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('records', records))
      ..add(DiagnosticsProperty('selectedWorkoutType', selectedWorkoutType))
      ..add(DiagnosticsProperty('intensity', intensity))
      ..add(DiagnosticsProperty('selectedImages', selectedImages))
      ..add(DiagnosticsProperty('errorMessage', errorMessage))
      ..add(DiagnosticsProperty('successMessage', successMessage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutRecordStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._records, _records) &&
            (identical(other.selectedWorkoutType, selectedWorkoutType) ||
                other.selectedWorkoutType == selectedWorkoutType) &&
            (identical(other.intensity, intensity) ||
                other.intensity == intensity) &&
            const DeepCollectionEquality()
                .equals(other._selectedImages, _selectedImages) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      const DeepCollectionEquality().hash(_records),
      selectedWorkoutType,
      intensity,
      const DeepCollectionEquality().hash(_selectedImages),
      errorMessage,
      successMessage);

  /// Create a copy of WorkoutRecordState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutRecordStateImplCopyWith<_$WorkoutRecordStateImpl> get copyWith =>
      __$$WorkoutRecordStateImplCopyWithImpl<_$WorkoutRecordStateImpl>(
          this, _$identity);
}

abstract class _WorkoutRecordState implements WorkoutRecordState {
  const factory _WorkoutRecordState(
      {final bool isLoading,
      final List<WorkoutRecord> records,
      final String selectedWorkoutType,
      final double intensity,
      final List<XFile> selectedImages,
      final String? errorMessage,
      final String? successMessage}) = _$WorkoutRecordStateImpl;

  @override
  bool get isLoading;
  @override
  List<WorkoutRecord> get records;
  @override
  String get selectedWorkoutType;
  @override
  double get intensity;
  @override
  List<XFile> get selectedImages;
  @override
  String? get errorMessage;
  @override
  String? get successMessage;

  /// Create a copy of WorkoutRecordState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutRecordStateImplCopyWith<_$WorkoutRecordStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
