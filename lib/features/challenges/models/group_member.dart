// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_member.freezed.dart';
part 'group_member.g.dart';

/// Representa um membro de um grupo de desafio
@freezed
class GroupMember with _$GroupMember {
  const factory GroupMember({
    /// ID do usuário
    required String userId,
    
    /// Nome de exibição do usuário
    required String userDisplayName,
    
    /// Avatar URL do usuário (opcional)
    String? userAvatarUrl,
    
    /// ID do grupo ao qual pertence
    required String groupId,
    
    /// Indica se o usuário é o criador do grupo
    @Default(false) bool isCreator,
    
    /// Data em que o usuário entrou no grupo
    DateTime? joinedAt,
  }) = _GroupMember;

  /// Cria um GroupMember a partir de um mapa JSON
  factory GroupMember.fromJson(Map<String, dynamic> json) => _$GroupMemberFromJson(json);
} 