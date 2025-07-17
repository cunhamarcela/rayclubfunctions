// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/utils/json_utils.dart';
import 'package:ray_club_app/utils/log_utils.dart';

part 'challenge_group.freezed.dart';
part 'challenge_group.g.dart';

/// Status de um convite para grupo
enum InviteStatus { pending, accepted, rejected }

/// Representa um grupo dentro do desafio principal.
/// Os usuários podem criar grupos para visualizar rankings específicos
/// de participantes convidados.
class ChallengeGroup {
  final String id;
  final String name;
  final String description;
  final String creatorId;
  final DateTime createdAt;
  final String? challengeId;
  final bool isPublic;
  
  // Membro do grupo - gerenciados em tabela separada
  final List<ChallengeGroupMember> _members;

  ChallengeGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorId,
    required this.createdAt,
    this.challengeId,
    this.isPublic = false,
    List<ChallengeGroupMember> members = const [],
  }) : _members = members;

  ChallengeGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? creatorId,
    DateTime? createdAt,
    String? challengeId,
    bool? isPublic,
    List<ChallengeGroupMember>? members,
  }) {
    return ChallengeGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      challengeId: challengeId ?? this.challengeId,
      isPublic: isPublic ?? this.isPublic,
      members: members ?? _members,
    );
  }

  // Métodos para interagir com membros
  bool get hasMembers => _members.isNotEmpty;
  
  int get memberCount => _members.length;
  
  List<String> get memberIds => _members.map((member) => member.userId).toList();
  
  List<ChallengeGroupMember> get members => List.unmodifiable(_members);
  
  bool isMember(String userId) => _members.any((member) => member.userId == userId);
  
  bool isCreator(String userId) => creatorId == userId;
  
  /// Lista de IDs de usuários com convites pendentes (não armazenada localmente)
  List<String> get pendingInviteIds => [];
  
  /// Factory que cria uma instância vazia de ChallengeGroup
  static ChallengeGroup empty = ChallengeGroup(
    id: '',
    name: '',
    description: '',
    creatorId: '',
    createdAt: DateTime.now(),
  );
  
  /// Adiciona um membro ao grupo
  ChallengeGroup addMember(ChallengeGroupMember member) {
    if (_members.any((m) => m.userId == member.userId)) {
      return this;
    }
    
    final updatedMembers = List<ChallengeGroupMember>.from(_members)..add(member);
    return copyWith(members: updatedMembers);
  }
  
  /// Remove um membro do grupo pelo ID
  ChallengeGroup removeMember(String userId) {
    final updatedMembers = _members.where((member) => member.userId != userId).toList();
    return copyWith(members: updatedMembers);
  }
  
  /// Cria um objeto ChallengeGroup a partir de um mapa JSON
  factory ChallengeGroup.fromJson(Map<String, dynamic> json) {
    try {
      // Diagnóstico de campos nulos
      JsonUtils.diagnoseNullStringError(json, context: 'ChallengeGroup');
      
      return ChallengeGroup(
        id: JsonUtils.getStringValue(json, 'id'),
        name: JsonUtils.getStringValue(json, 'name', defaultValue: 'Grupo sem nome'),
        description: JsonUtils.getStringValue(json, 'description'),
        creatorId: JsonUtils.getStringValue(json, 'creator_id'),
        createdAt: JsonUtils.safeDateTime(json['created_at']) ?? DateTime.now(),
        challengeId: JsonUtils.getNullableStringValue(json, 'challenge_id'),
        isPublic: JsonUtils.safeBool(json['is_public']),
        // Os membros serão carregados separadamente pelo repositório
      );
    } catch (e) {
      // Logar o erro
      LogUtils.error('Erro ao criar ChallengeGroup a partir de JSON', 
        tag: 'ChallengeGroup',
        error: e);
      
      // Em caso de erro, retornar um grupo vazio com um ID único
      return ChallengeGroup(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Grupo (erro de carregamento)',
        description: '',
        creatorId: '',
        createdAt: DateTime.now(),
        isPublic: false,
      );
    }
  }
  
  /// Converte o grupo para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creator_id': creatorId,
      'created_at': createdAt.toIso8601String(),
      'challenge_id': challengeId,
      'is_public': isPublic,
    };
  }
}

/// Modelo para membros de grupos de desafio
class ChallengeGroupMember {
  final String id;
  final String groupId;
  final String userId;
  final DateTime joinedAt;
  final String? userName; // Opcional, para exibição
  final String? userPhotoUrl; // Opcional, para exibição
  
  ChallengeGroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.joinedAt,
    this.userName,
    this.userPhotoUrl,
  });
  
  factory ChallengeGroupMember.fromJson(Map<String, dynamic> json) {
    try {
      // Diagnóstico de campos nulos
      JsonUtils.diagnoseNullStringError(json, context: 'ChallengeGroupMember');
      
      final String id = JsonUtils.getStringValue(json, 'id', 
          defaultValue: DateTime.now().millisecondsSinceEpoch.toString());
      
      final String userId = JsonUtils.getStringValue(json, 'user_id');
      final String groupId = JsonUtils.getStringValue(json, 'group_id');
      final DateTime joinedAt = JsonUtils.safeDateTime(json['joined_at']) ?? DateTime.now();
      
      // Estes campos podem ser nulos
      final String? userName = JsonUtils.getNullableStringValue(json, 'user_name');
      final String? userPhotoUrl = JsonUtils.getNullableStringValue(json, 'user_photo_url');
      
      return ChallengeGroupMember(
        id: id,
        groupId: groupId,
        userId: userId,
        joinedAt: joinedAt,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
      );
    } catch (e) {
      // Logar o erro
      LogUtils.error('Erro ao criar ChallengeGroupMember a partir de JSON', 
        tag: 'ChallengeGroupMember',
        error: e);
        
      // Em caso de erro, retornar um membro com valores padrão
      return ChallengeGroupMember(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: '',
        userId: '',
        joinedAt: DateTime.now(),
        userName: 'Usuário',
        userPhotoUrl: null,
      );
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'joined_at': joinedAt.toIso8601String(),
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
    };
  }
}

/// Modelo para convites de desafios em grupo
@freezed
class ChallengeGroupInvite with _$ChallengeGroupInvite {
  const factory ChallengeGroupInvite({
    /// ID único do convite
    required String id,
    
    /// ID do grupo para o qual o usuário está sendo convidado
    required String groupId,
    
    /// Nome do grupo (para exibição)
    required String groupName,
    
    /// ID do usuário que está convidando
    required String inviterId,
    
    /// Nome do usuário que está convidando (para exibição)
    required String inviterName,
    
    /// ID do usuário que está sendo convidado
    required String inviteeId,
    
    /// Status do convite (pendente, aceito, recusado)
    @Default(InviteStatus.pending) InviteStatus status,
    
    /// Data de criação do convite
    required DateTime createdAt,
    
    /// Data de resposta do convite (quando aceito ou recusado)
    DateTime? respondedAt,
  }) = _ChallengeGroupInvite;

  /// Cria um ChallengeGroupInvite a partir de um mapa JSON
  factory ChallengeGroupInvite.fromJson(Map<String, dynamic> json) => 
      _$ChallengeGroupInviteFromJson(json);
      
  /// Método seguro para criar um ChallengeGroupInvite a partir de um mapa JSON,
  /// tratando adequadamente valores nulos
  static ChallengeGroupInvite safeFromJson(Map<String, dynamic> json) {
    try {
      return ChallengeGroupInvite(
        id: json['id'] as String? ?? '',
        groupId: json['groupId'] as String? ?? '',
        groupName: json['groupName'] as String? ?? 'Grupo',
        inviterId: json['inviterId'] as String? ?? '',
        inviterName: json['inviterName'] as String? ?? 'Usuário',
        inviteeId: json['inviteeId'] as String? ?? '',
        status: $enumDecodeNullable(_$InviteStatusEnumMap, json['status']) ?? InviteStatus.pending,
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'] as String) 
            : DateTime.now(),
        respondedAt: json['respondedAt'] != null 
            ? DateTime.parse(json['respondedAt'] as String) 
            : null,
      );
    } catch (e) {
      // Em caso de erro, retornar um convite com valores padrão
      return ChallengeGroupInvite(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        groupId: '',
        groupName: 'Grupo',
        inviterId: '',
        inviterName: 'Usuário',
        inviteeId: '',
        createdAt: DateTime.now(),
      );
    }
  }
} 