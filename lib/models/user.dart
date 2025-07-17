/// Modelo simplificado de usuário do aplicativo
class AppUser {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isEmailVerified;
  final String? displayName;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
    required this.createdAt,
    this.isEmailVerified = false,
    this.displayName,
  });

  /// Cria um usuário a partir de um mapa JSON
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      displayName: json['display_name'] as String?,
    );
  }

  /// Converte o usuário para um mapa JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'is_email_verified': isEmailVerified,
      'display_name': displayName,
    };
  }

  /// Cria uma cópia do usuário com campos modificados
  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    bool? isEmailVerified,
    String? displayName,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      displayName: displayName ?? this.displayName,
    );
  }
} 