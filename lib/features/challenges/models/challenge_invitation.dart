import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_invitation.freezed.dart';
part 'challenge_invitation.g.dart';

/// Modelo de dados para convites de grupos de desafio
@freezed
class ChallengeGroupInvite with _$ChallengeGroupInvite {
  const factory ChallengeGroupInvite({
    required String id,
    required String groupId,
    required String inviterId,
    required String inviteeId,
    @JsonKey(name: 'status') required int statusCode,
    String? groupName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? respondedAt,
  }) = _ChallengeGroupInvite;

  factory ChallengeGroupInvite.fromJson(Map<String, dynamic> json) =>
      _$ChallengeGroupInviteFromJson(json);
      
  /// Construtor interno usado apenas pela biblioteca freezed
  const ChallengeGroupInvite._();
  
  /// Retorna o status do convite como uma string legível
  String get status {
    switch (statusCode) {
      case 0:
        return 'Pendente';
      case 1:
        return 'Aceito';
      case 2:
        return 'Recusado';
      default:
        return 'Desconhecido';
    }
  }
  
  /// Verifica se o convite está pendente
  bool get isPending => statusCode == 0;
  
  /// Verifica se o convite foi aceito
  bool get isAccepted => statusCode == 1;
  
  /// Verifica se o convite foi recusado
  bool get isRejected => statusCode == 2;
} 