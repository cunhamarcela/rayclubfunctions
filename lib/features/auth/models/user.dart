// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Represents a user in the Ray Club application.
/// This model is immutable and uses Freezed for code generation.
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? name,
    String? photoUrl,
    required DateTime createdAt,
    DateTime? updatedAt,
    required bool isEmailVerified,
    Map<String, dynamic>? metadata,
    @Default(false) bool? isAdmin,
  }) = _AppUser;

  /// Creates an AppUser from a Supabase User object
  factory AppUser.fromSupabaseUser(User user) {
    return AppUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt:
          user.updatedAt != null ? DateTime.parse(user.updatedAt!) : null,
      isEmailVerified: user.emailConfirmedAt != null,
      metadata: user.userMetadata,
      isAdmin: user.appMetadata?['is_admin'] as bool? ?? false,
    );
  }

  /// Creates an AppUser from a JSON map
  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
} 
