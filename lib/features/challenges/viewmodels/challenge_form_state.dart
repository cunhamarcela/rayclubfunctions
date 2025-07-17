// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import '../models/challenge.dart';

part 'challenge_form_state.freezed.dart';

/// Estado do formulário de criação/edição de desafios
@freezed
class ChallengeFormState with _$ChallengeFormState {
  const ChallengeFormState._(); // Para métodos de extensão
  
  /// Construtor principal com todos os campos
  const factory ChallengeFormState({
    String? id,
    @Default('') String title,
    @Default('') String description,
    String? imageUrl,
    String? imagePath,
    String? localImagePath,
    required DateTime startDate,
    required DateTime endDate,
    @Default('normal') String type,
    @Default(10) int points,
    @Default([]) List<String> requirements,
    @Default([]) List<String> participants,
    @Default(true) bool active,
    String? creatorId, // Alterado para nullable para compatibilidade
    @Default(false) bool isOfficial,
    @Default([]) List<String> invitedUsers,
    @Default(false) bool isSubmitting,
    @Default(false) bool isSuccess,
    @Default('') String errorMessage,
  }) = _ChallengeFormState;
  
  /// Estado inicial
  factory ChallengeFormState.initial(String userId) => ChallengeFormState(
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),
    creatorId: userId, // userId é sempre fornecido, então não será nulo aqui
  );
  
  /// Cria estado a partir de um desafio existente
  factory ChallengeFormState.fromChallenge(Challenge challenge) => ChallengeFormState(
    id: challenge.id,
    title: challenge.title,
    description: challenge.description,
    imageUrl: challenge.imageUrl,
    localImagePath: challenge.localImagePath,
    startDate: challenge.startDate,
    endDate: challenge.endDate,
    type: challenge.type,
    points: challenge.points,
    requirements: challenge.requirements ?? [],
    participants: challenge.participants ?? [],
    active: challenge.active,
    creatorId: challenge.creatorId,
    isOfficial: challenge.isOfficial,
    invitedUsers: challenge.invitedUsers ?? [],
  );
  
  /// Métodos para validação
  bool get isTitleValid => title.isNotEmpty;
  bool get isDescriptionValid => description.isNotEmpty;
  bool get isDateRangeValid => startDate.isBefore(endDate);
  
  bool get isValid {
    return isTitleValid && isDescriptionValid && isDateRangeValid;
  }
  
  /// Converte o estado do formulário para um modelo Challenge
  Challenge toChallenge() {
    final DateTime now = DateTime.now();
    return Challenge(
      id: id ?? '',
      title: title,
      description: description,
      imageUrl: imageUrl,
      localImagePath: localImagePath,
      startDate: startDate,
      endDate: endDate,
      type: type,
      points: points,
      requirements: requirements,
      participants: participants,
      active: active,
      creatorId: creatorId, // Já é String? no modelo Challenge
      isOfficial: isOfficial,
      invitedUsers: invitedUsers,
      createdAt: now,
      updatedAt: now,
    );
  }
} 
