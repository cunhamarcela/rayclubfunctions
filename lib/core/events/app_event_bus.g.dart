// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_event_bus.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthEventImpl _$$AuthEventImplFromJson(Map<String, dynamic> json) =>
    _$AuthEventImpl(
      type: json['type'] as String,
      userId: json['userId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$AuthEventImplToJson(_$AuthEventImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      if (instance.userId case final value?) 'userId': value,
      if (instance.data case final value?) 'data': value,
      'runtimeType': instance.$type,
    };

_$WorkoutEventImpl _$$WorkoutEventImplFromJson(Map<String, dynamic> json) =>
    _$WorkoutEventImpl(
      type: json['type'] as String,
      workoutId: json['workoutId'] as String,
      data: json['data'] as Map<String, dynamic>?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$WorkoutEventImplToJson(_$WorkoutEventImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'workoutId': instance.workoutId,
      if (instance.data case final value?) 'data': value,
      'runtimeType': instance.$type,
    };

_$ChallengeEventImpl _$$ChallengeEventImplFromJson(Map<String, dynamic> json) =>
    _$ChallengeEventImpl(
      type: json['type'] as String,
      challengeId: json['challengeId'] as String,
      data: json['data'] as Map<String, dynamic>?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ChallengeEventImplToJson(
        _$ChallengeEventImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'challengeId': instance.challengeId,
      if (instance.data case final value?) 'data': value,
      'runtimeType': instance.$type,
    };

_$NutritionEventImpl _$$NutritionEventImplFromJson(Map<String, dynamic> json) =>
    _$NutritionEventImpl(
      type: json['type'] as String,
      mealId: json['mealId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$NutritionEventImplToJson(
        _$NutritionEventImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      if (instance.mealId case final value?) 'mealId': value,
      if (instance.data case final value?) 'data': value,
      'runtimeType': instance.$type,
    };

_$BenefitsEventImpl _$$BenefitsEventImplFromJson(Map<String, dynamic> json) =>
    _$BenefitsEventImpl(
      type: json['type'] as String,
      benefitId: json['benefitId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$BenefitsEventImplToJson(_$BenefitsEventImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      if (instance.benefitId case final value?) 'benefitId': value,
      if (instance.data case final value?) 'data': value,
      'runtimeType': instance.$type,
    };

_$ConnectivityEventImpl _$$ConnectivityEventImplFromJson(
        Map<String, dynamic> json) =>
    _$ConnectivityEventImpl(
      isOnline: json['isOnline'] as bool,
      timestamp: json['timestamp'] as String?,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$ConnectivityEventImplToJson(
        _$ConnectivityEventImpl instance) =>
    <String, dynamic>{
      'isOnline': instance.isOnline,
      if (instance.timestamp case final value?) 'timestamp': value,
      'runtimeType': instance.$type,
    };

_$CustomEventImpl _$$CustomEventImplFromJson(Map<String, dynamic> json) =>
    _$CustomEventImpl(
      name: json['name'] as String,
      data: json['data'] as Map<String, dynamic>,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$CustomEventImplToJson(_$CustomEventImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'data': instance.data,
      'runtimeType': instance.$type,
    };
