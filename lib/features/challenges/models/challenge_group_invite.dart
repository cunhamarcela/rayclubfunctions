// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/utils/json_utils.dart';
import 'package:ray_club_app/utils/log_utils.dart';

part 'challenge_group_invite.freezed.dart';
part 'challenge_group_invite.g.dart';

/// Status de um convite para grupo de desafio
enum InviteStatus { pending, accepted, rejected }

/// Representa um convite para participar de um grupo de desafio
@freezed
class ChallengeGroupInvite with _$ChallengeGroupInvite {
  const factory ChallengeGroupInvite({
    /// ID único do convite
    required String id,
    
    /// ID do grupo para o qual o usuário foi convidado
    required String groupId,
    
    /// ID do usuário que enviou o convite
    required String inviterId,
    
    /// ID do usuário que foi convidado
    required String inviteeId,
    
    /// Status do convite
    @Default(InviteStatus.pending) InviteStatus status,
    
    /// Data de criação do convite
    required DateTime createdAt,
    
    /// Data de resposta ao convite (null se ainda não respondido)
    DateTime? respondedAt,
    
    /// Data de expiração do convite (opcional)
    DateTime? expiresAt,
    
    /// Mensagem personalizada do convite (opcional)
    String? message,
  }) = _ChallengeGroupInvite;

  /// Cria um ChallengeGroupInvite a partir de um mapa JSON
  factory ChallengeGroupInvite.fromJson(Map<String, dynamic> json) => 
      _$ChallengeGroupInviteFromJson(json);
  
  const ChallengeGroupInvite._();
  
  /// Verifica se o convite está pendente
  bool get isPending => status == InviteStatus.pending;
  
  /// Verifica se o convite foi aceito
  bool get isAccepted => status == InviteStatus.accepted;
  
  /// Verifica se o convite foi rejeitado
  bool get isRejected => status == InviteStatus.rejected;
  
  /// Verifica se o convite expirou
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  /// Verifica se o convite ainda é válido (pendente e não expirado)
  bool get isValid => isPending && !isExpired;
} 