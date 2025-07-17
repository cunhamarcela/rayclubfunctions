// Explicitly not using freezed for this class to avoid generation issues
// part 'sub_challenge.freezed.dart';
// part 'sub_challenge.g.dart';

/// Status do sub-desafio
enum SubChallengeStatus { active, completed, expired, moderated }

/// Represents a sub-challenge in the Ray Club application.
class SubChallenge {
  final String id;
  final String parentChallengeId;
  final String creatorId;
  final String title;
  final String description;
  final Map<String, dynamic> criteria;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> participants;
  final SubChallengeStatus status;
  final Map<String, dynamic> validationRules;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SubChallenge({
    required this.id,
    required this.parentChallengeId,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.criteria,
    required this.startDate,
    required this.endDate,
    this.participants = const [],
    this.status = SubChallengeStatus.active,
    this.validationRules = const {},
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a SubChallenge from a JSON map
  factory SubChallenge.fromJson(Map<String, dynamic> json) {
    return SubChallenge(
      id: json['id'] as String,
      parentChallengeId: json['parentChallengeId'] as String,
      creatorId: json['creatorId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      criteria: json['criteria'] as Map<String, dynamic>,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      participants: (json['participants'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      status: SubChallengeStatus.values[json['status'] as int? ?? 0],
      validationRules: json['validationRules'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentChallengeId': parentChallengeId,
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'criteria': criteria,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'participants': participants,
      'status': status.index,
      'validationRules': validationRules,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
} 
