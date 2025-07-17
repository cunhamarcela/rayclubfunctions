// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo para dados do usuário
class UserData {
  final String id;
  final String? name;
  final String? email;
  final String? avatarUrl;

  UserData({
    required this.id,
    this.name,
    this.email,
    this.avatarUrl,
  });

  factory UserData.fromUser(User user) {
    return UserData(
      id: user.id,
      name: user.userMetadata?['name'] as String? ?? 'Usuário',
      email: user.email,
      avatarUrl: null,
    );
  }
}

/// Provider que fornece acesso ao usuário atualmente autenticado
final currentUserProvider = Provider<UserData?>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) {
    return null;
  }
  return UserData.fromUser(user);
}); 
