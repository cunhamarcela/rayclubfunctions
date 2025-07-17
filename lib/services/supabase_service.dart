// Dart imports:
import 'dart:typed_data';

// Package imports:
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço para encapsular a funcionalidade do Supabase
class SupabaseService {
  final SupabaseClient client;
  
  /// Construtor que recebe um cliente Supabase
  SupabaseService(this.client);
  
  /// Inicializa o Supabase com as credenciais do .env
  static Future<void> initialize() async {
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_ANON_KEY'];
    
    if (supabaseUrl == null || supabaseKey == null) {
      throw Exception('Credenciais do Supabase não encontradas no .env');
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
  }
  
  /// Retorna o usuário atual, se autenticado
  User? get currentUser => client.auth.currentUser;
  
  /// Verifica se o usuário está logado
  bool get isAuthenticated => currentUser != null;
  
  /// Realiza login com email e senha
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Registra um novo usuário com email e senha
  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  /// Realiza logout
  Future<void> signOut() async {
    await client.auth.signOut();
  }
  
  /// Upload de arquivo para um bucket específico
  Future<String> uploadFile(String bucketName, String filePath, Uint8List fileBytes) async {
    final String fileName = filePath.split('/').last;
    final String fileExt = fileName.split('.').last;
    final String path = '$bucketName/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    
    await client.storage.from(bucketName).uploadBinary(path, fileBytes);
    
    // Retorna a URL pública do arquivo
    return client.storage.from(bucketName).getPublicUrl(path);
  }
  
  /// Recupera a URL pública de um arquivo
  String getPublicUrl(String bucketName, String path) {
    return client.storage.from(bucketName).getPublicUrl(path);
  }
  
  /// Executa uma query RPC (Remote Procedure Call)
  Future<List<Map<String, dynamic>>> rpc(String function, {Map<String, dynamic>? params}) async {
    final response = await client.rpc(function, params: params);
    
    if (response.error != null) {
      final errorMessage = response.error?.message ?? 'Erro desconhecido na chamada RPC';
      throw Exception('Erro na chamada RPC: $errorMessage');
    }
    
    return List<Map<String, dynamic>>.from(response.data as List);
  }
} 
