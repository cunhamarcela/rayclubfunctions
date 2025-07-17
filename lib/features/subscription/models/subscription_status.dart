/// Modelo para status de acesso do usuário
class UserAccessStatus {
  final String userId;
  final bool hasExtendedAccess;
  final String? accessLevel;
  final DateTime? validUntil;
  final DateTime? lastVerified;
  final List<String> availableFeatures;
  
  const UserAccessStatus({
    required this.userId,
    required this.hasExtendedAccess,
    this.accessLevel,
    this.validUntil,
    this.lastVerified,
    required this.availableFeatures,
  });
  
  /// Construtor para usuário com acesso básico
  factory UserAccessStatus.basic(String userId) {
    return UserAccessStatus(
      userId: userId,
      hasExtendedAccess: false,
      accessLevel: 'basic',
      availableFeatures: _basicFeatures,
    );
  }
  
  /// Construtor para usuário com acesso completo
  factory UserAccessStatus.complete(String userId, {
    required String level,
    required DateTime validUntil,
  }) {
    return UserAccessStatus(
      userId: userId,
      hasExtendedAccess: true,
      accessLevel: level,
      validUntil: validUntil,
      lastVerified: DateTime.now(),
      availableFeatures: _allFeatures,
    );
  }
  
  /// Features disponíveis no acesso básico
  static const List<String> _basicFeatures = [
    'basic_workouts',
    'profile',
    'basic_challenges',
    'workout_recording',
  ];
  
  /// Features disponíveis no acesso completo (expert)
  static const List<String> _allFeatures = [
    'basic_workouts',
    'profile',
    'basic_challenges',
    'workout_recording',
    'enhanced_dashboard',
    'nutrition_guide',
    'workout_library',
    'advanced_tracking',
    'detailed_reports',
  ];
  
  /// Verifica se uma feature específica está disponível
  bool hasAccess(String featureKey) {
    return availableFeatures.contains(featureKey);
  }
  
  /// Verifica se o acesso ainda é válido
  bool get isAccessValid {
    if (!hasExtendedAccess) return true; // Acesso básico sempre válido
    if (validUntil == null) return true; // NULL = acesso permanente (expert)
    return DateTime.now().isBefore(validUntil!);
  }
  
  /// Verifica se precisa revalidar
  bool get needsVerification {
    if (lastVerified == null) return true;
    return DateTime.now().difference(lastVerified!).inHours > 24;
  }
  
  /// Verifica se o usuário é expert
  bool get isExpert => accessLevel == 'expert' && isAccessValid;
  
  /// Verifica se o usuário é basic
  bool get isBasic => accessLevel == 'basic' || !isAccessValid;
  
  factory UserAccessStatus.fromJson(Map<String, dynamic> json) {
    return UserAccessStatus(
      userId: json['user_id'],
      hasExtendedAccess: json['has_extended_access'] ?? false,
      accessLevel: json['access_level'],
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until']) : null,
      lastVerified: json['last_verified'] != null ? DateTime.parse(json['last_verified']) : null,
      availableFeatures: List<String>.from(json['available_features'] ?? _basicFeatures),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'has_extended_access': hasExtendedAccess,
      'access_level': accessLevel,
      'valid_until': validUntil?.toIso8601String(),
      'last_verified': lastVerified?.toIso8601String(),
      'available_features': availableFeatures,
    };
  }
  
  UserAccessStatus copyWith({
    String? userId,
    bool? hasExtendedAccess,
    String? accessLevel,
    DateTime? validUntil,
    DateTime? lastVerified,
    List<String>? availableFeatures,
  }) {
    return UserAccessStatus(
      userId: userId ?? this.userId,
      hasExtendedAccess: hasExtendedAccess ?? this.hasExtendedAccess,
      accessLevel: accessLevel ?? this.accessLevel,
      validUntil: validUntil ?? this.validUntil,
      lastVerified: lastVerified ?? this.lastVerified,
      availableFeatures: availableFeatures ?? this.availableFeatures,
    );
  }
} 