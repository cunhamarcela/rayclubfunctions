// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_state_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SharedAppStateImpl _$$SharedAppStateImplFromJson(Map<String, dynamic> json) =>
    _$SharedAppStateImpl(
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      isSubscriber: json['isSubscriber'] as bool? ?? false,
      currentChallengeId: json['currentChallengeId'] as String?,
      currentWorkoutId: json['currentWorkoutId'] as String?,
      isOfflineMode: json['isOfflineMode'] as bool? ?? false,
      lastVisitedRoute: json['lastVisitedRoute'] as String?,
      customData: json['customData'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$SharedAppStateImplToJson(
        _$SharedAppStateImpl instance) =>
    <String, dynamic>{
      if (instance.userId case final value?) 'userId': value,
      if (instance.userName case final value?) 'userName': value,
      'isSubscriber': instance.isSubscriber,
      if (instance.currentChallengeId case final value?)
        'currentChallengeId': value,
      if (instance.currentWorkoutId case final value?)
        'currentWorkoutId': value,
      'isOfflineMode': instance.isOfflineMode,
      if (instance.lastVisitedRoute case final value?)
        'lastVisitedRoute': value,
      'customData': instance.customData,
    };
