import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers/auth_provider.dart';

/// Modelo básico para dados do usuário em listas
class UserBasic {
  final String id;
  final String name;
  final String? photoUrl;
  final String? email;

  UserBasic({
    required this.id,
    required this.name,
    this.photoUrl,
    this.email,
  });

  factory UserBasic.fromJson(Map<String, dynamic> json) {
    return UserBasic(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Usuário',
      photoUrl: json['photo_url'] as String?,
      email: json['email'] as String?,
    );
  }
}

/// Provider que fornece uma lista de usuários
final userListProvider = FutureProvider<List<UserBasic>>((ref) async {
  try {
    final response = await Supabase.instance.client
        .from('users')
        .select('id, name, photo_url, email')
        .limit(50);

    return (response as List<dynamic>)
        .map((data) => UserBasic.fromJson(data))
        .toList();
  } catch (e) {
    // Em caso de erro, retornar uma lista vazia
    return [];
  }
});

/// Provider para buscar um usuário específico por ID
final userByIdProvider = FutureProvider.family<UserBasic?, String>((ref, userId) async {
  try {
    final response = await Supabase.instance.client
        .from('users')
        .select('id, name, photo_url, email')
        .eq('id', userId)
        .single();
    
    return UserBasic.fromJson(response);
  } catch (e) {
    return null;
  }
});

/// Provider para obter o perfil detalhado de um usuário por ID
/// Este provider é usado na tela de detalhes do grupo de desafio
final userProfileProvider = FutureProvider.family<UserBasic, String>((ref, userId) async {
  try {
    final response = await Supabase.instance.client
        .from('users')
        .select('id, name, photo_url, email')
        .eq('id', userId)
        .single();
    
    return UserBasic.fromJson(response);
  } catch (e) {
    // Se houver erro, retornar um perfil básico
    return UserBasic(
      id: userId,
      name: 'Usuário',
      photoUrl: null,
      email: null,
    );
  }
});

/// Provider para buscar usuários por texto de busca
final userSearchProvider = FutureProvider.family<List<UserBasic>, String>((ref, searchText) async {
  try {
    if (searchText.length < 3) {
      return [];
    }
    
    final response = await Supabase.instance.client
        .from('users')
        .select('id, name, photo_url, email')
        .ilike('name', '%$searchText%')
        .limit(20);
    
    return (response as List<dynamic>)
        .map((data) => UserBasic.fromJson(data))
        .toList();
  } catch (e) {
    return [];
  }
}); 