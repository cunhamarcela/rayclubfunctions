import 'package:ray_club_app/core/utils/model_mapper.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/utils/datetime_extensions.dart';

/// Mapper para conversão entre dados do Supabase e modelo Challenge
/// 
/// Necessário para:
/// 1. Converter campos snake_case para camelCase
/// 2. Tratar corretamente arrays (requirements, participants, invitedUsers)
/// 3. Garantir valores padrão seguros para campos nulos
class ChallengeMapper {
  /// Converte dados do Supabase para o modelo Challenge
  static Challenge fromSupabase(Map<String, dynamic> json) {
    try {
      // Pré-processamento para campos problemáticos
      final processedJson = {
        ...json,
        // Converter snake_case para camelCase
        'imageUrl': json['image_url'],
        'localImagePath': json['local_image_path'],
        'startDate': json['start_date'],
        'endDate': json['end_date'],
        'creatorId': json['creator_id'] ?? '',
        'isOfficial': json['is_official'] ?? false,
        'invitedUsers': _parseStringArray(json['invited_users']),
        'createdAt': json['created_at'],
        'updatedAt': json['updated_at'],
        // Garantir arrays não-nulos
        'requirements': _parseStringArray(json['requirements']),
        'participants': _parseStringArray(json['participants']),
      };
      
      return Challenge.fromJson(processedJson);
    } 
    // Se falhar, usa abordagem manual mais robusta
    catch (e) {
      return Challenge(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        imageUrl: json['image_url'],
        localImagePath: json['local_image_path'],
        startDate: _parseDateTime(json['start_date']) ?? DateTime.now(),
        endDate: _parseDateTime(json['end_date']) ?? 
            DateTime.now().add(const Duration(days: 7)),
        type: json['type'] ?? 'normal',
        points: _parseInt(json['points']) ?? 10,
        requirements: _parseStringArray(json['requirements']),
        participants: _parseStringArray(json['participants']),
        active: json['active'] == true,
        creatorId: json['creator_id'] ?? '',
        isOfficial: json['is_official'] == true,
        invitedUsers: _parseStringArray(json['invited_users']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
      );
    }
  }
  
  /// Determina se um JSON precisa de mapper personalizado
  static bool needsMapper(Map<String, dynamic> json) {
    // Verificar se contém campos em snake_case ou arrays que precisem de conversão
    return json.containsKey('image_url') || 
           json.containsKey('start_date') ||
           json.containsKey('requirements') ||
           json.containsKey('participants');
  }
  
  /// Converte para array de strings de forma segura
  static List<String> _parseStringArray(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    
    // Tentar interpretar como string JSON
    if (value is String) {
      try {
        if (value.startsWith('[') && value.endsWith(']')) {
          return value
              .substring(1, value.length - 1)
              .split(',')
              .map((e) => e.trim().replaceAll('"', ''))
              .where((e) => e.isNotEmpty)
              .toList();
        }
      } catch (_) {}
    }
    
    return [];
  }
  
  /// Converte string para DateTime de forma segura
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    
    try {
      if (value is String) return DateTime.parse(value);
      if (value is int) {
        return value > 100000000000
          ? DateTime.fromMillisecondsSinceEpoch(value)
          : DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
    } catch (_) {
      return null;
    }
    
    return null;
  }
  
  /// Converte para int de forma segura
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
  
  /// Mapeia o modelo Challenge para o formato do Supabase
  static Map<String, dynamic> toSupabase(Challenge challenge) {
    final map = <String, dynamic>{
      'id': challenge.id,
      'title': challenge.title,
      'description': challenge.description,
      'image_url': challenge.imageUrl,
      'local_image_path': challenge.localImagePath,
      'start_date': challenge.startDate.toSupabaseString(),
      'end_date': challenge.endDate.toSupabaseString(),
      'type': challenge.type,
      'points': challenge.points,
      'requirements': challenge.requirements,
      'active': challenge.active,
      'creator_id': challenge.creatorId,
      'is_official': challenge.isOfficial,
      'invited_users': challenge.invitedUsers,
    };
    
    if (challenge.createdAt != null) {
      map['created_at'] = challenge.createdAt!.toSupabaseString();
    }
    
    if (challenge.updatedAt != null) {
      map['updated_at'] = challenge.updatedAt!.toSupabaseString();
    }
    
    return map;
  }
} 