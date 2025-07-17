// Dart imports:
import 'dart:convert';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/utils/date_utils.dart';
import 'package:ray_club_app/utils/datetime_extensions.dart';
import 'challenge_progress.dart';
import 'challenge_group.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

/// Represents a challenge in the Ray Club application.
@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required String title,
    required String description,
    String? imageUrl,
    // Field for local image path when uploading new images
    String? localImagePath,
    required DateTime startDate,
    required DateTime endDate,
    @Default('normal') String type,
    required int points,
    @Default([]) List<String> requirements,
    @Default([]) List<String> participants,
    @Default(true) bool active,
    String? creatorId, // Modificado para nullable
    @Default(false) bool isOfficial,
    @Default([]) List<String> invitedUsers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);

  const Challenge._();
  
  bool isActive() {
    final now = DateTime.now();
    return startDate.isBefore(now) && endDate.isAfter(now) && active;
  }

  String get formattedDateRange {
    return '${DateUtils.formatDate(startDate)} - ${DateUtils.formatDate(endDate)}';
  }

  String get formattedStartDate {
    return DateUtils.formatDate(startDate);
  }

  String get formattedEndDate {
    return DateUtils.formatDate(endDate);
  }

  int get participantsCount {
    return participants.length;
  }
  
  /// Retorna o número total de dias de duração do desafio (inclusivo)
  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Retorna os dias restantes considerando fuso horário do Brasil
  int get daysRemainingBrazil {
    final now = DateTime.now();
    final brazilNow = DateTime(now.year, now.month, now.day);
    final brazilEndDate = DateTime(endDate.year, endDate.month, endDate.day);
    
    final difference = brazilEndDate.difference(brazilNow).inDays + 1;
    return difference >= 0 ? difference : 0;
  }

  /// Verifica se está ativo considerando fuso horário do Brasil
  bool get isActiveBrazil {
    final now = DateTime.now();
    final brazilNow = DateTime(now.year, now.month, now.day);
    
    final brazilStartDate = DateTime(startDate.year, startDate.month, startDate.day);
    final brazilEndDate = DateTime(endDate.year, endDate.month, endDate.day);
    
    return brazilNow.isAfter(brazilStartDate.subtract(const Duration(days: 1))) && 
           brazilNow.isBefore(brazilEndDate.add(const Duration(days: 1))) && 
           active;
  }
}

/// Parse requirements safely
Map<String, dynamic> parseRequirements(dynamic requirements) {
  if (requirements == null) return {};
  if (requirements is Map) return Map<String, dynamic>.from(requirements as Map);
  if (requirements is String) {
    try {
      return jsonDecode(requirements as String);
    } catch (e) {
      return {};
    }
  }
  return {};
}

/// Converts the Challenge instance to a JSON map.
Map<String, dynamic> toJson(Challenge challenge) {
  final Map<String, dynamic> data = {
    'id': challenge.id,
    'title': challenge.title,
    'description': challenge.description,
    'image_url': challenge.imageUrl,
    'start_date': challenge.startDate.toSupabaseString(),
    'end_date': challenge.endDate.toSupabaseString(),
    'type': challenge.type,
    'points': challenge.points,
    'active': challenge.active,
    'is_official': challenge.isOfficial,
  };
  
  // Add nullable fields only if they have values
  if (challenge.requirements.isNotEmpty) data['requirements'] = challenge.requirements;
  if (challenge.creatorId != null && challenge.creatorId!.isNotEmpty) data['creator_id'] = challenge.creatorId;
  if (challenge.participants.isNotEmpty) data['participants'] = challenge.participants;
  if (challenge.invitedUsers.isNotEmpty) data['invited_users'] = challenge.invitedUsers;
  if (challenge.createdAt != null) data['created_at'] = challenge.createdAt!.toSupabaseString();
  if (challenge.updatedAt != null) data['updated_at'] = challenge.updatedAt!.toSupabaseString();
  
  // Add localImagePath for image uploads if present
  if (challenge.localImagePath != null) data['local_image_path'] = challenge.localImagePath;
  
  return data;
}

/// Creates a copy of this Challenge instance with updated fields.
Challenge copyWith(Challenge challenge, {
  String? id,
  String? title,
  String? description,
  String? imageUrl,
  String? localImagePath,
  DateTime? startDate,
  DateTime? endDate,
  String? type,
  int? points,
  List<String>? requirements,
  List<String>? participants,
  bool? active,
  String? creatorId,
  bool? isOfficial,
  List<String>? invitedUsers,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return Challenge(
    id: id ?? challenge.id,
    title: title ?? challenge.title,
    description: description ?? challenge.description,
    imageUrl: imageUrl ?? challenge.imageUrl,
    localImagePath: localImagePath ?? challenge.localImagePath,
    startDate: startDate ?? challenge.startDate,
    endDate: endDate ?? challenge.endDate,
    type: type ?? challenge.type,
    points: points ?? challenge.points,
    requirements: requirements ?? challenge.requirements,
    participants: participants ?? challenge.participants,
    active: active ?? challenge.active,
    creatorId: creatorId ?? challenge.creatorId,
    isOfficial: isOfficial ?? challenge.isOfficial,
    invitedUsers: invitedUsers ?? challenge.invitedUsers,
    createdAt: createdAt ?? challenge.createdAt,
    updatedAt: updatedAt ?? challenge.updatedAt,
  );
}

// Removed deprecated class: ChallengeInvite (replaced by ChallengeGroupInvite)
// End of file 
