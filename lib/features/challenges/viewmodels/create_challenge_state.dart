// Project imports:
import '../models/challenge.dart';

class CreateChallengeState {
  final bool isLoading;
  final bool isSaving;
  final String title;
  final String rules;
  final String reward;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> invitedUsers;
  final String? error;

  const CreateChallengeState({
    this.isLoading = false,
    this.isSaving = false,
    this.title = '',
    this.rules = '',
    this.reward = '100',
    required this.startDate,
    required this.endDate,
    this.invitedUsers = const [],
    this.error,
  });
  
  /// Creates an initial state with default values
  factory CreateChallengeState.initial() => CreateChallengeState(
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
  );
  
  /// Creates a loading state
  factory CreateChallengeState.loading() => CreateChallengeState(
    isLoading: true,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
  );

  /// Creates a copy with modified fields
  CreateChallengeState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? title,
    String? rules,
    String? reward,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? invitedUsers,
    String? error,
  }) {
    return CreateChallengeState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      title: title ?? this.title,
      rules: rules ?? this.rules,
      reward: reward ?? this.reward,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      invitedUsers: invitedUsers ?? this.invitedUsers,
      error: error,
    );
  }
  
  /// Converts state to Challenge object
  Challenge toChallenge(String creatorId) {
    return Challenge(
      id: '', // Will be assigned by the repository
      title: title,
      description: rules,
      points: int.tryParse(reward) ?? 100,
      startDate: startDate,
      endDate: endDate,
      participants: [creatorId], // Creator is automatically a participant
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      creatorId: creatorId,
      invitedUsers: invitedUsers,
    );
  }
} 