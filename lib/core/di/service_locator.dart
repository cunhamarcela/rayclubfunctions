// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../providers/shared_preferences_provider.dart';
import '../services/cache_service.dart';
import '../providers/providers.dart';
import '../../services/deep_link_service.dart';

/// Instância global do GetIt para injeção de dependências
final GetIt getIt = GetIt.instance;

/// Inicializa as dependências principais da aplicação
Future<void> initializeDependencies() async {
  debugPrint('Inicializando dependências...');
  
  // Inicializar SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Verificar se é a primeira execução do app
  bool hasSeenIntro = prefs.getBool('has_seen_intro') ?? false;
  debugPrint('🔍 Já viu a introdução? $hasSeenIntro');
  
  // Se for a primeira execução, definir flag has_seen_intro como false
  if (!hasSeenIntro) {
    debugPrint('✅ Configurando primeira execução - tela de intro será exibida');
    // NÃO marcar como visto ainda, vamos fazer isso apenas após o usuário navegar para fora da intro
    // await prefs.setBool('has_seen_intro', true);
  }
  
  // Registrar SharedPreferences no GetIt
  getIt.registerSingleton<SharedPreferences>(prefs);
  
  // Inicializar e registrar o CacheService
  final cacheService = SharedPrefsCacheService(prefs);
  getIt.registerSingleton<CacheService>(cacheService);
  
  // Inicializar e registrar o DeepLinkService
  final deepLinkService = DeepLinkService();
  await deepLinkService.initialize();
  getIt.registerSingleton<DeepLinkService>(deepLinkService);
  
  // Nota: O override do provider é feito no main.dart
  
  debugPrint('✅ Dependências inicializadas com sucesso');
}
