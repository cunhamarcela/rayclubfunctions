// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'auth_service.dart';
import 'mock_auth_service.dart';

/// Provedor para o serviço de autenticação
final authServiceProvider = Provider<AuthService>((ref) {
  // Em desenvolvimento ou teste, use a implementação mockada
  if (kDebugMode) {
    return MockAuthService();
  }
  
  // Em produção, use a implementação real
  final supabase = Supabase.instance.client;
  
  // Cria uma instância temporária de SharedPreferences
  final prefs = SharedPreferences.getInstance();
  
  return MockAuthService(); // Temporariamente retornando mock para todos os ambientes
}); 