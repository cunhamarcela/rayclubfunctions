// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_state_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SharedAppState _$SharedAppStateFromJson(Map<String, dynamic> json) {
  return _SharedAppState.fromJson(json);
}

/// @nodoc
mixin _$SharedAppState {
  /// ID do usuário logado
  String? get userId => throw _privateConstructorUsedError;

  /// Nome do usuário para uso em diferentes features
  String? get userName => throw _privateConstructorUsedError;

  /// Status da assinatura do usuário
  bool get isSubscriber => throw _privateConstructorUsedError;

  /// ID do desafio selecionado atualmente (usado em várias features)
  String? get currentChallengeId => throw _privateConstructorUsedError;

  /// ID do treino selecionado atualmente
  String? get currentWorkoutId => throw _privateConstructorUsedError;

  /// Flag que indica se o app está operando em modo offline
  bool get isOfflineMode => throw _privateConstructorUsedError;

  /// Última tela visitada (para navegação)
  String? get lastVisitedRoute => throw _privateConstructorUsedError;

  /// Dados personalizados que podem ser compartilhados entre features
  Map<String, dynamic> get customData => throw _privateConstructorUsedError;

  /// Serializes this SharedAppState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SharedAppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SharedAppStateCopyWith<SharedAppState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SharedAppStateCopyWith<$Res> {
  factory $SharedAppStateCopyWith(
          SharedAppState value, $Res Function(SharedAppState) then) =
      _$SharedAppStateCopyWithImpl<$Res, SharedAppState>;
  @useResult
  $Res call(
      {String? userId,
      String? userName,
      bool isSubscriber,
      String? currentChallengeId,
      String? currentWorkoutId,
      bool isOfflineMode,
      String? lastVisitedRoute,
      Map<String, dynamic> customData});
}

/// @nodoc
class _$SharedAppStateCopyWithImpl<$Res, $Val extends SharedAppState>
    implements $SharedAppStateCopyWith<$Res> {
  _$SharedAppStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SharedAppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? userName = freezed,
    Object? isSubscriber = null,
    Object? currentChallengeId = freezed,
    Object? currentWorkoutId = freezed,
    Object? isOfflineMode = null,
    Object? lastVisitedRoute = freezed,
    Object? customData = null,
  }) {
    return _then(_value.copyWith(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      isSubscriber: null == isSubscriber
          ? _value.isSubscriber
          : isSubscriber // ignore: cast_nullable_to_non_nullable
              as bool,
      currentChallengeId: freezed == currentChallengeId
          ? _value.currentChallengeId
          : currentChallengeId // ignore: cast_nullable_to_non_nullable
              as String?,
      currentWorkoutId: freezed == currentWorkoutId
          ? _value.currentWorkoutId
          : currentWorkoutId // ignore: cast_nullable_to_non_nullable
              as String?,
      isOfflineMode: null == isOfflineMode
          ? _value.isOfflineMode
          : isOfflineMode // ignore: cast_nullable_to_non_nullable
              as bool,
      lastVisitedRoute: freezed == lastVisitedRoute
          ? _value.lastVisitedRoute
          : lastVisitedRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      customData: null == customData
          ? _value.customData
          : customData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SharedAppStateImplCopyWith<$Res>
    implements $SharedAppStateCopyWith<$Res> {
  factory _$$SharedAppStateImplCopyWith(_$SharedAppStateImpl value,
          $Res Function(_$SharedAppStateImpl) then) =
      __$$SharedAppStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? userId,
      String? userName,
      bool isSubscriber,
      String? currentChallengeId,
      String? currentWorkoutId,
      bool isOfflineMode,
      String? lastVisitedRoute,
      Map<String, dynamic> customData});
}

/// @nodoc
class __$$SharedAppStateImplCopyWithImpl<$Res>
    extends _$SharedAppStateCopyWithImpl<$Res, _$SharedAppStateImpl>
    implements _$$SharedAppStateImplCopyWith<$Res> {
  __$$SharedAppStateImplCopyWithImpl(
      _$SharedAppStateImpl _value, $Res Function(_$SharedAppStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SharedAppState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = freezed,
    Object? userName = freezed,
    Object? isSubscriber = null,
    Object? currentChallengeId = freezed,
    Object? currentWorkoutId = freezed,
    Object? isOfflineMode = null,
    Object? lastVisitedRoute = freezed,
    Object? customData = null,
  }) {
    return _then(_$SharedAppStateImpl(
      userId: freezed == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String?,
      userName: freezed == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      isSubscriber: null == isSubscriber
          ? _value.isSubscriber
          : isSubscriber // ignore: cast_nullable_to_non_nullable
              as bool,
      currentChallengeId: freezed == currentChallengeId
          ? _value.currentChallengeId
          : currentChallengeId // ignore: cast_nullable_to_non_nullable
              as String?,
      currentWorkoutId: freezed == currentWorkoutId
          ? _value.currentWorkoutId
          : currentWorkoutId // ignore: cast_nullable_to_non_nullable
              as String?,
      isOfflineMode: null == isOfflineMode
          ? _value.isOfflineMode
          : isOfflineMode // ignore: cast_nullable_to_non_nullable
              as bool,
      lastVisitedRoute: freezed == lastVisitedRoute
          ? _value.lastVisitedRoute
          : lastVisitedRoute // ignore: cast_nullable_to_non_nullable
              as String?,
      customData: null == customData
          ? _value._customData
          : customData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SharedAppStateImpl
    with DiagnosticableTreeMixin
    implements _SharedAppState {
  const _$SharedAppStateImpl(
      {this.userId,
      this.userName,
      this.isSubscriber = false,
      this.currentChallengeId,
      this.currentWorkoutId,
      this.isOfflineMode = false,
      this.lastVisitedRoute,
      final Map<String, dynamic> customData = const {}})
      : _customData = customData;

  factory _$SharedAppStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SharedAppStateImplFromJson(json);

  /// ID do usuário logado
  @override
  final String? userId;

  /// Nome do usuário para uso em diferentes features
  @override
  final String? userName;

  /// Status da assinatura do usuário
  @override
  @JsonKey()
  final bool isSubscriber;

  /// ID do desafio selecionado atualmente (usado em várias features)
  @override
  final String? currentChallengeId;

  /// ID do treino selecionado atualmente
  @override
  final String? currentWorkoutId;

  /// Flag que indica se o app está operando em modo offline
  @override
  @JsonKey()
  final bool isOfflineMode;

  /// Última tela visitada (para navegação)
  @override
  final String? lastVisitedRoute;

  /// Dados personalizados que podem ser compartilhados entre features
  final Map<String, dynamic> _customData;

  /// Dados personalizados que podem ser compartilhados entre features
  @override
  @JsonKey()
  Map<String, dynamic> get customData {
    if (_customData is EqualUnmodifiableMapView) return _customData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_customData);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SharedAppState(userId: $userId, userName: $userName, isSubscriber: $isSubscriber, currentChallengeId: $currentChallengeId, currentWorkoutId: $currentWorkoutId, isOfflineMode: $isOfflineMode, lastVisitedRoute: $lastVisitedRoute, customData: $customData)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'SharedAppState'))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('userName', userName))
      ..add(DiagnosticsProperty('isSubscriber', isSubscriber))
      ..add(DiagnosticsProperty('currentChallengeId', currentChallengeId))
      ..add(DiagnosticsProperty('currentWorkoutId', currentWorkoutId))
      ..add(DiagnosticsProperty('isOfflineMode', isOfflineMode))
      ..add(DiagnosticsProperty('lastVisitedRoute', lastVisitedRoute))
      ..add(DiagnosticsProperty('customData', customData));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SharedAppStateImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.isSubscriber, isSubscriber) ||
                other.isSubscriber == isSubscriber) &&
            (identical(other.currentChallengeId, currentChallengeId) ||
                other.currentChallengeId == currentChallengeId) &&
            (identical(other.currentWorkoutId, currentWorkoutId) ||
                other.currentWorkoutId == currentWorkoutId) &&
            (identical(other.isOfflineMode, isOfflineMode) ||
                other.isOfflineMode == isOfflineMode) &&
            (identical(other.lastVisitedRoute, lastVisitedRoute) ||
                other.lastVisitedRoute == lastVisitedRoute) &&
            const DeepCollectionEquality()
                .equals(other._customData, _customData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      userName,
      isSubscriber,
      currentChallengeId,
      currentWorkoutId,
      isOfflineMode,
      lastVisitedRoute,
      const DeepCollectionEquality().hash(_customData));

  /// Create a copy of SharedAppState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SharedAppStateImplCopyWith<_$SharedAppStateImpl> get copyWith =>
      __$$SharedAppStateImplCopyWithImpl<_$SharedAppStateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SharedAppStateImplToJson(
      this,
    );
  }
}

abstract class _SharedAppState implements SharedAppState {
  const factory _SharedAppState(
      {final String? userId,
      final String? userName,
      final bool isSubscriber,
      final String? currentChallengeId,
      final String? currentWorkoutId,
      final bool isOfflineMode,
      final String? lastVisitedRoute,
      final Map<String, dynamic> customData}) = _$SharedAppStateImpl;

  factory _SharedAppState.fromJson(Map<String, dynamic> json) =
      _$SharedAppStateImpl.fromJson;

  /// ID do usuário logado
  @override
  String? get userId;

  /// Nome do usuário para uso em diferentes features
  @override
  String? get userName;

  /// Status da assinatura do usuário
  @override
  bool get isSubscriber;

  /// ID do desafio selecionado atualmente (usado em várias features)
  @override
  String? get currentChallengeId;

  /// ID do treino selecionado atualmente
  @override
  String? get currentWorkoutId;

  /// Flag que indica se o app está operando em modo offline
  @override
  bool get isOfflineMode;

  /// Última tela visitada (para navegação)
  @override
  String? get lastVisitedRoute;

  /// Dados personalizados que podem ser compartilhados entre features
  @override
  Map<String, dynamic> get customData;

  /// Create a copy of SharedAppState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SharedAppStateImplCopyWith<_$SharedAppStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
