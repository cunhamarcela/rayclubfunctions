import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider para o serviço Supabase
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});

/// Serviço para gerenciar a conexão com o Supabase
class SupabaseService {
  /// Cliente Supabase para operações com a API
  final supabase = Supabase.instance.client;
  
  /// Getter para o serviço de autenticação
  get auth => supabase.auth;
  
  /// Getter para o serviço de storage
  SupabaseStorageClient get storage => supabase.storage;
  
  /// Inicializa o Supabase (deve ser chamado antes de qualquer operação)
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }
  
  /// Recupera dados de uma tabela
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final response = await supabase.from(table).select();
    return List<Map<String, dynamic>>.from(response);
  }
  
  /// Recupera um registro por ID
  Future<Map<String, dynamic>> getById(String table, String id) async {
    final response = await supabase.from(table).select().eq('id', id).single();
    return response;
  }
  
  /// Insere um novo registro
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    final response = await supabase.from(table).insert(data).select().single();
    return response;
  }
  
  /// Atualiza um registro existente
  Future<Map<String, dynamic>> update(String table, String id, Map<String, dynamic> data) async {
    final response = await supabase.from(table).update(data).eq('id', id).select().single();
    return response;
  }
  
  /// Remove um registro
  Future<void> delete(String table, String id) async {
    await supabase.from(table).delete().eq('id', id);
  }
} 