// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'event.freezed.dart';
part 'event.g.dart';

/// Model para eventos
@freezed
class Event with _$Event {
  /// Constructor principal do evento
  const factory Event({
    required String id,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String location,
    String? imageUrl,
    required String organizerId,
    @Default(100) int maxAttendees,
    @Default(0) int currentAttendees,
    @Default([]) List<String> attendees,
    String? type,
    @Default(false) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Event;

  /// Construtor a partir de JSON
  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

/// Estado para a lista de eventos
@freezed
class EventsState with _$EventsState {
  const factory EventsState({
    @Default([]) List<Event> events,
    @Default(false) bool isLoading,
    String? errorMessage,
    String? successMessage,
    Event? selectedEvent,
    @Default([]) List<Event> userEvents,
  }) = _EventsState;

  factory EventsState.fromJson(Map<String, dynamic> json) => _$EventsStateFromJson(json);
} 