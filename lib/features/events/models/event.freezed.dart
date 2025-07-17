// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Event _$EventFromJson(Map<String, dynamic> json) {
  return _Event.fromJson(json);
}

/// @nodoc
mixin _$Event {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String get organizerId => throw _privateConstructorUsedError;
  int get maxAttendees => throw _privateConstructorUsedError;
  int get currentAttendees => throw _privateConstructorUsedError;
  List<String> get attendees => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventCopyWith<Event> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res, Event>;
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      DateTime startDate,
      DateTime endDate,
      String location,
      String? imageUrl,
      String organizerId,
      int maxAttendees,
      int currentAttendees,
      List<String> attendees,
      String? type,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$EventCopyWithImpl<$Res, $Val extends Event>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? location = null,
    Object? imageUrl = freezed,
    Object? organizerId = null,
    Object? maxAttendees = null,
    Object? currentAttendees = null,
    Object? attendees = null,
    Object? type = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      organizerId: null == organizerId
          ? _value.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as String,
      maxAttendees: null == maxAttendees
          ? _value.maxAttendees
          : maxAttendees // ignore: cast_nullable_to_non_nullable
              as int,
      currentAttendees: null == currentAttendees
          ? _value.currentAttendees
          : currentAttendees // ignore: cast_nullable_to_non_nullable
              as int,
      attendees: null == attendees
          ? _value.attendees
          : attendees // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventImplCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$$EventImplCopyWith(
          _$EventImpl value, $Res Function(_$EventImpl) then) =
      __$$EventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String description,
      DateTime startDate,
      DateTime endDate,
      String location,
      String? imageUrl,
      String organizerId,
      int maxAttendees,
      int currentAttendees,
      List<String> attendees,
      String? type,
      bool isActive,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$EventImplCopyWithImpl<$Res>
    extends _$EventCopyWithImpl<$Res, _$EventImpl>
    implements _$$EventImplCopyWith<$Res> {
  __$$EventImplCopyWithImpl(
      _$EventImpl _value, $Res Function(_$EventImpl) _then)
      : super(_value, _then);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? location = null,
    Object? imageUrl = freezed,
    Object? organizerId = null,
    Object? maxAttendees = null,
    Object? currentAttendees = null,
    Object? attendees = null,
    Object? type = freezed,
    Object? isActive = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$EventImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      organizerId: null == organizerId
          ? _value.organizerId
          : organizerId // ignore: cast_nullable_to_non_nullable
              as String,
      maxAttendees: null == maxAttendees
          ? _value.maxAttendees
          : maxAttendees // ignore: cast_nullable_to_non_nullable
              as int,
      currentAttendees: null == currentAttendees
          ? _value.currentAttendees
          : currentAttendees // ignore: cast_nullable_to_non_nullable
              as int,
      attendees: null == attendees
          ? _value._attendees
          : attendees // ignore: cast_nullable_to_non_nullable
              as List<String>,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventImpl implements _Event {
  const _$EventImpl(
      {required this.id,
      required this.title,
      required this.description,
      required this.startDate,
      required this.endDate,
      required this.location,
      this.imageUrl,
      required this.organizerId,
      this.maxAttendees = 100,
      this.currentAttendees = 0,
      final List<String> attendees = const [],
      this.type,
      this.isActive = false,
      this.createdAt,
      this.updatedAt})
      : _attendees = attendees;

  factory _$EventImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String description;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final String location;
  @override
  final String? imageUrl;
  @override
  final String organizerId;
  @override
  @JsonKey()
  final int maxAttendees;
  @override
  @JsonKey()
  final int currentAttendees;
  final List<String> _attendees;
  @override
  @JsonKey()
  List<String> get attendees {
    if (_attendees is EqualUnmodifiableListView) return _attendees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attendees);
  }

  @override
  final String? type;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'Event(id: $id, title: $title, description: $description, startDate: $startDate, endDate: $endDate, location: $location, imageUrl: $imageUrl, organizerId: $organizerId, maxAttendees: $maxAttendees, currentAttendees: $currentAttendees, attendees: $attendees, type: $type, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.organizerId, organizerId) ||
                other.organizerId == organizerId) &&
            (identical(other.maxAttendees, maxAttendees) ||
                other.maxAttendees == maxAttendees) &&
            (identical(other.currentAttendees, currentAttendees) ||
                other.currentAttendees == currentAttendees) &&
            const DeepCollectionEquality()
                .equals(other._attendees, _attendees) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      description,
      startDate,
      endDate,
      location,
      imageUrl,
      organizerId,
      maxAttendees,
      currentAttendees,
      const DeepCollectionEquality().hash(_attendees),
      type,
      isActive,
      createdAt,
      updatedAt);

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      __$$EventImplCopyWithImpl<_$EventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventImplToJson(
      this,
    );
  }
}

abstract class _Event implements Event {
  const factory _Event(
      {required final String id,
      required final String title,
      required final String description,
      required final DateTime startDate,
      required final DateTime endDate,
      required final String location,
      final String? imageUrl,
      required final String organizerId,
      final int maxAttendees,
      final int currentAttendees,
      final List<String> attendees,
      final String? type,
      final bool isActive,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$EventImpl;

  factory _Event.fromJson(Map<String, dynamic> json) = _$EventImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get description;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  String get location;
  @override
  String? get imageUrl;
  @override
  String get organizerId;
  @override
  int get maxAttendees;
  @override
  int get currentAttendees;
  @override
  List<String> get attendees;
  @override
  String? get type;
  @override
  bool get isActive;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of Event
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventImplCopyWith<_$EventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EventsState _$EventsStateFromJson(Map<String, dynamic> json) {
  return _EventsState.fromJson(json);
}

/// @nodoc
mixin _$EventsState {
  List<Event> get events => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get successMessage => throw _privateConstructorUsedError;
  Event? get selectedEvent => throw _privateConstructorUsedError;
  List<Event> get userEvents => throw _privateConstructorUsedError;

  /// Serializes this EventsState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EventsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventsStateCopyWith<EventsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventsStateCopyWith<$Res> {
  factory $EventsStateCopyWith(
          EventsState value, $Res Function(EventsState) then) =
      _$EventsStateCopyWithImpl<$Res, EventsState>;
  @useResult
  $Res call(
      {List<Event> events,
      bool isLoading,
      String? errorMessage,
      String? successMessage,
      Event? selectedEvent,
      List<Event> userEvents});

  $EventCopyWith<$Res>? get selectedEvent;
}

/// @nodoc
class _$EventsStateCopyWithImpl<$Res, $Val extends EventsState>
    implements $EventsStateCopyWith<$Res> {
  _$EventsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? events = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
    Object? selectedEvent = freezed,
    Object? userEvents = null,
  }) {
    return _then(_value.copyWith(
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<Event>,
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
      selectedEvent: freezed == selectedEvent
          ? _value.selectedEvent
          : selectedEvent // ignore: cast_nullable_to_non_nullable
              as Event?,
      userEvents: null == userEvents
          ? _value.userEvents
          : userEvents // ignore: cast_nullable_to_non_nullable
              as List<Event>,
    ) as $Val);
  }

  /// Create a copy of EventsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $EventCopyWith<$Res>? get selectedEvent {
    if (_value.selectedEvent == null) {
      return null;
    }

    return $EventCopyWith<$Res>(_value.selectedEvent!, (value) {
      return _then(_value.copyWith(selectedEvent: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EventsStateImplCopyWith<$Res>
    implements $EventsStateCopyWith<$Res> {
  factory _$$EventsStateImplCopyWith(
          _$EventsStateImpl value, $Res Function(_$EventsStateImpl) then) =
      __$$EventsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Event> events,
      bool isLoading,
      String? errorMessage,
      String? successMessage,
      Event? selectedEvent,
      List<Event> userEvents});

  @override
  $EventCopyWith<$Res>? get selectedEvent;
}

/// @nodoc
class __$$EventsStateImplCopyWithImpl<$Res>
    extends _$EventsStateCopyWithImpl<$Res, _$EventsStateImpl>
    implements _$$EventsStateImplCopyWith<$Res> {
  __$$EventsStateImplCopyWithImpl(
      _$EventsStateImpl _value, $Res Function(_$EventsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of EventsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? events = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
    Object? selectedEvent = freezed,
    Object? userEvents = null,
  }) {
    return _then(_$EventsStateImpl(
      events: null == events
          ? _value._events
          : events // ignore: cast_nullable_to_non_nullable
              as List<Event>,
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
      selectedEvent: freezed == selectedEvent
          ? _value.selectedEvent
          : selectedEvent // ignore: cast_nullable_to_non_nullable
              as Event?,
      userEvents: null == userEvents
          ? _value._userEvents
          : userEvents // ignore: cast_nullable_to_non_nullable
              as List<Event>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventsStateImpl implements _EventsState {
  const _$EventsStateImpl(
      {final List<Event> events = const [],
      this.isLoading = false,
      this.errorMessage,
      this.successMessage,
      this.selectedEvent,
      final List<Event> userEvents = const []})
      : _events = events,
        _userEvents = userEvents;

  factory _$EventsStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventsStateImplFromJson(json);

  final List<Event> _events;
  @override
  @JsonKey()
  List<Event> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  final String? successMessage;
  @override
  final Event? selectedEvent;
  final List<Event> _userEvents;
  @override
  @JsonKey()
  List<Event> get userEvents {
    if (_userEvents is EqualUnmodifiableListView) return _userEvents;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userEvents);
  }

  @override
  String toString() {
    return 'EventsState(events: $events, isLoading: $isLoading, errorMessage: $errorMessage, successMessage: $successMessage, selectedEvent: $selectedEvent, userEvents: $userEvents)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventsStateImpl &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage) &&
            (identical(other.selectedEvent, selectedEvent) ||
                other.selectedEvent == selectedEvent) &&
            const DeepCollectionEquality()
                .equals(other._userEvents, _userEvents));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_events),
      isLoading,
      errorMessage,
      successMessage,
      selectedEvent,
      const DeepCollectionEquality().hash(_userEvents));

  /// Create a copy of EventsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventsStateImplCopyWith<_$EventsStateImpl> get copyWith =>
      __$$EventsStateImplCopyWithImpl<_$EventsStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventsStateImplToJson(
      this,
    );
  }
}

abstract class _EventsState implements EventsState {
  const factory _EventsState(
      {final List<Event> events,
      final bool isLoading,
      final String? errorMessage,
      final String? successMessage,
      final Event? selectedEvent,
      final List<Event> userEvents}) = _$EventsStateImpl;

  factory _EventsState.fromJson(Map<String, dynamic> json) =
      _$EventsStateImpl.fromJson;

  @override
  List<Event> get events;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  String? get successMessage;
  @override
  Event? get selectedEvent;
  @override
  List<Event> get userEvents;

  /// Create a copy of EventsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventsStateImplCopyWith<_$EventsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
