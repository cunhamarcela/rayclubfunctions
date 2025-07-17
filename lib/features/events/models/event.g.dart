// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventImpl _$$EventImplFromJson(Map<String, dynamic> json) => _$EventImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      imageUrl: json['imageUrl'] as String?,
      organizerId: json['organizerId'] as String,
      maxAttendees: (json['maxAttendees'] as num?)?.toInt() ?? 100,
      currentAttendees: (json['currentAttendees'] as num?)?.toInt() ?? 0,
      attendees: (json['attendees'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      type: json['type'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$EventImplToJson(_$EventImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'location': instance.location,
      if (instance.imageUrl case final value?) 'imageUrl': value,
      'organizerId': instance.organizerId,
      'maxAttendees': instance.maxAttendees,
      'currentAttendees': instance.currentAttendees,
      'attendees': instance.attendees,
      if (instance.type case final value?) 'type': value,
      'isActive': instance.isActive,
      if (instance.createdAt?.toIso8601String() case final value?)
        'createdAt': value,
      if (instance.updatedAt?.toIso8601String() case final value?)
        'updatedAt': value,
    };

_$EventsStateImpl _$$EventsStateImplFromJson(Map<String, dynamic> json) =>
    _$EventsStateImpl(
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLoading: json['isLoading'] as bool? ?? false,
      errorMessage: json['errorMessage'] as String?,
      successMessage: json['successMessage'] as String?,
      selectedEvent: json['selectedEvent'] == null
          ? null
          : Event.fromJson(json['selectedEvent'] as Map<String, dynamic>),
      userEvents: (json['userEvents'] as List<dynamic>?)
              ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EventsStateImplToJson(_$EventsStateImpl instance) =>
    <String, dynamic>{
      'events': instance.events.map((e) => e.toJson()).toList(),
      'isLoading': instance.isLoading,
      if (instance.errorMessage case final value?) 'errorMessage': value,
      if (instance.successMessage case final value?) 'successMessage': value,
      if (instance.selectedEvent?.toJson() case final value?)
        'selectedEvent': value,
      'userEvents': instance.userEvents.map((e) => e.toJson()).toList(),
    };
