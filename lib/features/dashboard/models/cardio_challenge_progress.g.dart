// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cardio_challenge_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CardioChallengeProgressImpl _$$CardioChallengeProgressImplFromJson(
        Map<String, dynamic> json) =>
    _$CardioChallengeProgressImpl(
      position: (json['position'] as num).toInt(),
      totalMinutes: (json['total_minutes'] as num).toInt(),
      previousDayMinutes: (json['previous_day_minutes'] as num?)?.toInt() ?? 0,
      todayMinutes: (json['today_minutes'] as num?)?.toInt() ?? 0,
      improvementPercentage:
          (json['improvement_percentage'] as num?)?.toDouble() ?? 0.0,
      isParticipating: json['is_participating'] as bool? ?? false,
      totalParticipants: (json['total_participants'] as num?)?.toInt() ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$$CardioChallengeProgressImplToJson(
        _$CardioChallengeProgressImpl instance) =>
    <String, dynamic>{
      'position': instance.position,
      'total_minutes': instance.totalMinutes,
      'previous_day_minutes': instance.previousDayMinutes,
      'today_minutes': instance.todayMinutes,
      'improvement_percentage': instance.improvementPercentage,
      'is_participating': instance.isParticipating,
      'total_participants': instance.totalParticipants,
      'last_updated': instance.lastUpdated.toIso8601String(),
    };
