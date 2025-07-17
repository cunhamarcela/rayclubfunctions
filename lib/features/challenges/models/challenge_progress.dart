// Dart imports:
import 'dart:math' as math;

// Project imports:
import 'package:ray_club_app/utils/json_utils.dart';
import 'package:ray_club_app/utils/log_utils.dart';

// Explicitly not using freezed for this class to avoid generation issues
// part 'challenge_progress.freezed.dart';
// part 'challenge_progress.g.dart';

/// Modelo que representa o progresso de um usuário em um desafio
class ChallengeProgress {
  // Constantes para valores padrão
  static const String _defaultUserName = 'Usuário';
  static const int _defaultPoints = 0;
  static const int _defaultCheckInsCount = 0;
  static const int _defaultConsecutiveDays = 0;
  static const int _defaultPosition = 0;
  static const double _defaultCompletionPercentage = 0.0;
  static const bool _defaultCompleted = false;
  static const String _logTag = 'ChallengeProgress';

  final String id;
  final String userId;
  final String challengeId;
  final String userName; // Mantemos como não-nulo mas garantimos um valor default
  final String? userPhotoUrl;
  final int points;
  final int? checkInsCount;
  final DateTime? lastCheckIn;
  final int? consecutiveDays;
  final bool completed;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Para compatibilidade com código existente
  final int position;
  final double completionPercentage;
  DateTime get lastUpdated => updatedAt ?? createdAt;

  const ChallengeProgress({
    required this.id,
    required this.userId,
    required this.challengeId,
    required this.userName,
    this.userPhotoUrl,
    required this.points,
    this.checkInsCount,
    this.lastCheckIn,
    this.consecutiveDays,
    this.completed = _defaultCompleted,
    required this.createdAt,
    this.updatedAt,
    this.position = _defaultPosition,
    this.completionPercentage = _defaultCompletionPercentage,
  });

  /// Método estático seguro para obter pontos
  static int getPoints(Map<String, dynamic> json) {
    try {
      final dynamic pointsValue = json['points'];
      if (pointsValue == null) return _defaultPoints;
      
      if (pointsValue is int) return pointsValue;
      if (pointsValue is double) return pointsValue.round();
      if (pointsValue is String) {
        final parsed = int.tryParse(pointsValue);
        if (parsed != null) return parsed;
      }
      
      return _defaultPoints;
    } catch (e) {
      LogUtils.error('Erro ao extrair pontos', tag: _logTag, error: e);
      return _defaultPoints;
    }
  }
  
  /// Método estático seguro para obter total de treinos
  static int getWorkouts(Map<String, dynamic> data) {
    try {
      if (data.containsKey('total_workouts')) {
        final dynamic value = data['total_workouts'];
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? _defaultCheckInsCount;
        return _defaultCheckInsCount;
      } else if (data.containsKey('workouts')) {
        final dynamic value = data['workouts'];
        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? _defaultCheckInsCount;
        return _defaultCheckInsCount;
      }
      return _defaultCheckInsCount;
    } catch (e) {
      LogUtils.error('Erro ao extrair total de treinos', tag: _logTag, error: e);
      return _defaultCheckInsCount;
    }
  }

  /// Extrai informações do perfil do usuário do JSON
  /// Trata diferentes estruturas de dados que podem ser retornadas pelo Supabase
  static Map<String, dynamic> _getProfileData(Map<String, dynamic> json) {
    try {
      // Verifica se temos dados de perfil aninhados
      if (json.containsKey('profiles') && json['profiles'] != null) {
        final dynamic profiles = json['profiles'];
        if (profiles is Map<String, dynamic>) {
          return profiles;
        } else if (profiles is List && profiles.isNotEmpty) {
          // Às vezes o Supabase retorna um array com um objeto
          final dynamic firstProfile = profiles.first;
          if (firstProfile is Map<String, dynamic>) {
            return firstProfile;
          }
        }
      }
      return {};
    } catch (e) {
      // Se ocorrer qualquer erro ao extrair os dados de perfil, retornar um mapa vazio
      LogUtils.error('Erro ao extrair dados de perfil', tag: _logTag, error: e);
      return {};
    }
  }

  /// Extrai informações do usuário do JSON, seja diretamente ou através do perfil
  static String extractUserName(Map<String, dynamic> json, String userId) {
    try {
      // Primeiro tentar extrair do campo específico
      String? userName = JsonUtils.getNullableStringValue(json, 'user_name');
      
      // Se não encontrou, tentar campos alternativos
      if (userName == null || userName.trim().isEmpty) {
        userName = JsonUtils.getNullableStringValue(json, 'userName');
      }
      
      // Se ainda não encontrou, tentar extrair do nome de usuário
      if (userName == null || userName.trim().isEmpty) {
        userName = JsonUtils.getNullableStringValue(json, 'username');
      }
      
      // Se nenhum campo estiver disponível, use o ID de usuário truncado ou o padrão
      if (userName == null || userName.trim().isEmpty) {
        if (userId.isNotEmpty) {
          userName = 'User-${userId.substring(0, math.min(4, userId.length))}';
        } else {
          userName = _defaultUserName;
        }
      }
      
      return userName;
    } catch (e) {
      LogUtils.error('Erro ao extrair nome do usuário', tag: _logTag, error: e);
      return _defaultUserName;
    }
  }

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    try {
      // Registrar diagnóstico de possíveis erros
      JsonUtils.diagnoseNullStringError(json, context: _logTag);
      
      // Usar valores padrão seguros para campos obrigatórios
      final String id = JsonUtils.getStringValue(json, 'id', 
          defaultValue: DateTime.now().millisecondsSinceEpoch.toString());
          
      final String userId = JsonUtils.getStringValue(json, 'user_id');
      final String challengeId = JsonUtils.getStringValue(json, 'challenge_id');
      
      // Extrair nome de usuário com método auxiliar (com tratamento seguro para null)
      final String userName = extractUserName(json, userId);
      
      // Converter de forma segura para inteiro
      final int checkInsCount = JsonUtils.safeInt(json['check_ins_count'], defaultValue: _defaultCheckInsCount);
      final int consecutiveDays = JsonUtils.safeInt(json['consecutive_days'], defaultValue: _defaultConsecutiveDays);
      final int position = JsonUtils.safeInt(json['position'], defaultValue: _defaultPosition);
      
      // Converter de forma segura para double
      final double completionPercentage = JsonUtils.safeDouble(
        json['completion_percentage'], 
        defaultValue: _defaultCompletionPercentage
      );
      
      // Converter de forma segura para boolean
      final bool completed = JsonUtils.safeBool(json['completed'], defaultValue: _defaultCompleted);
      
      // Extrair e tratar photo URL com segurança - melhorado para lidar melhor com nulos
      String? userPhotoUrl;
      try {
        userPhotoUrl = JsonUtils.getNullableStringValue(json, 'user_photo_url');
        // Verificar se a URL é válida (mesmo que básica)
        if (userPhotoUrl != null && userPhotoUrl.trim().isEmpty) {
          userPhotoUrl = null; // Converter strings vazias para null
        }
        
        // Verificar se é uma URL que parece válida (pelo menos tem http ou https)
        if (userPhotoUrl != null && 
            !userPhotoUrl.startsWith('http://') && 
            !userPhotoUrl.startsWith('https://')) {
          LogUtils.warning('URL de foto possivelmente inválida: $userPhotoUrl', tag: _logTag);
          // Manter a URL como está, mesmo que pareça inválida
        }
      } catch (e) {
        LogUtils.error('Erro ao processar URL da foto', tag: _logTag, error: e);
        userPhotoUrl = null; // Em caso de erro, definir como null
      }
      
      LogUtils.debug('✅ ChallengeProgress construído com sucesso: id=$id, userId=$userId', tag: _logTag);
      
      // Criar o objeto com valores seguros
      return ChallengeProgress(
        id: id,
        userId: userId,
        challengeId: challengeId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        points: getPoints(json),
        checkInsCount: checkInsCount,
        lastCheckIn: JsonUtils.safeDateTime(json['last_check_in']),
        consecutiveDays: consecutiveDays,
        completed: completed,
        createdAt: JsonUtils.safeDateTime(json['created_at']) ?? DateTime.now(),
        updatedAt: JsonUtils.safeDateTime(json['updated_at']),
        position: position,
        completionPercentage: completionPercentage,
      );
    } catch (e) {
      LogUtils.error('Erro ao criar ChallengeProgress', tag: _logTag, error: e);
      // Retornar um objeto padrão em caso de erro
      return ChallengeProgress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '',
        challengeId: '',
        userName: _defaultUserName,
        points: _defaultPoints,
        createdAt: DateTime.now(),
      );
    }
  }
  
  /// Método auxiliar para extrair string de forma segura
  static String? _extractStringValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    // Tenta converter outros tipos para string
    return value.toString();
  }
  
  /// Método auxiliar para normalizar strings (converte string vazia para null)
  static String? _normalizeStringValue(Map<String, dynamic> json, String key) {
    final value = _extractStringValue(json, key);
    // Retorna null para strings vazias ou nulas
    return (value != null && value.trim().isNotEmpty) ? value : null;
  }
  
  /// Método auxiliar para extrair int de forma segura
  static int? _extractIntValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
  
  /// Método auxiliar para extrair double de forma segura
  static double? _extractDoubleValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  /// Método auxiliar para extrair boolean de forma segura
  static bool? _extractBoolValue(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lowerValue = value.toLowerCase();
      if (lowerValue == 'true' || lowerValue == '1' || lowerValue == 'yes') return true;
      if (lowerValue == 'false' || lowerValue == '0' || lowerValue == 'no') return false;
    }
    return null;
  }
  
  /// Método auxiliar para parse seguro de DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    
    try {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is DateTime) {
        return value;
      } else if (value is int) {
        // Assume que é timestamp em milissegundos
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
    } catch (e) {
      LogUtils.error('Erro ao converter DateTime', tag: _logTag, error: e);
    }
    
    return null;
  }

  /// Converte o objeto para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'challenge_id': challengeId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'points': points,
      'check_ins_count': checkInsCount,
      'last_check_in': lastCheckIn?.toIso8601String(),
      'consecutive_days': consecutiveDays,
      'completed': completed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'position': position,
      'completion_percentage': completionPercentage,
    };
  }
  
  /// Cria uma cópia deste objeto com os campos opcionalmente alterados
  ChallengeProgress copyWith({
    String? id,
    String? userId,
    String? challengeId,
    String? userName,
    String? userPhotoUrl,
    int? points,
    int? checkInsCount,
    DateTime? lastCheckIn,
    int? consecutiveDays,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? position,
    double? completionPercentage,
  }) {
    return ChallengeProgress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      points: points ?? this.points,
      checkInsCount: checkInsCount ?? this.checkInsCount,
      lastCheckIn: lastCheckIn ?? this.lastCheckIn,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      position: position ?? this.position,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}

/// Classe para encapsular dados de atualização de progresso do usuário
class UserProgressUpdateData {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int points;
  final double completionPercentage;
  final bool applyOptimisticUpdate;

  UserProgressUpdateData({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.points,
    required this.completionPercentage,
    this.applyOptimisticUpdate = true,
  });

  @override
  String toString() {
    return 'UserProgressUpdateData{userId: $userId, userName: $userName, points: $points, completion: ${completionPercentage.toStringAsFixed(1)}%, optimistic: $applyOptimisticUpdate}';
  }
  
  /// Converts this object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'points': points,
      'completion_percentage': completionPercentage,
    };
  }
}