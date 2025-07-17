import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  print('🔍 Diagnóstico de Configuração do .env\n');
  
  // Tentar carregar o .env
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Arquivo .env carregado com sucesso\n');
  } catch (e) {
    print('❌ Erro ao carregar .env: $e\n');
    print('📝 Criando arquivo .env de exemplo...\n');
    createExampleEnv();
    return;
  }
  
  // Verificar variáveis existentes
  print('📋 Variáveis encontradas no .env:');
  dotenv.env.forEach((key, value) {
    if (key.contains('KEY') || key.contains('SECRET')) {
      print('  $key: ****** (ocultado)');
    } else {
      print('  $key: ${value.substring(0, value.length > 30 ? 30 : value.length)}...');
    }
  });
  
  print('\n🔧 Configuração Necessária:\n');
  
  // Verificar se temos as variáveis básicas
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    print('❌ Variáveis básicas do Supabase não encontradas!\n');
    createExampleEnv();
    return;
  }
  
  // Sugerir configuração completa
  print('✅ Variáveis básicas encontradas. Gerando configuração completa...\n');
  
  final envContent = '''
# ===== CONFIGURAÇÃO BÁSICA =====
SUPABASE_URL=$supabaseUrl
SUPABASE_ANON_KEY=$supabaseAnonKey

# ===== CONFIGURAÇÃO POR AMBIENTE =====
# Development
DEV_SUPABASE_URL=$supabaseUrl
DEV_SUPABASE_ANON_KEY=$supabaseAnonKey
DEV_API_URL=$supabaseUrl
DEV_DEBUG_MODE=true

# Staging
STAGING_SUPABASE_URL=$supabaseUrl
STAGING_SUPABASE_ANON_KEY=$supabaseAnonKey
STAGING_API_URL=$supabaseUrl
STAGING_DEBUG_MODE=true

# Production
PROD_SUPABASE_URL=$supabaseUrl
PROD_SUPABASE_ANON_KEY=$supabaseAnonKey
PROD_API_URL=$supabaseUrl
PROD_DEBUG_MODE=false

# ===== GOOGLE OAUTH =====
GOOGLE_WEB_CLIENT_ID=${dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt.apps.googleusercontent.com'}
GOOGLE_IOS_CLIENT_ID=${dotenv.env['GOOGLE_IOS_CLIENT_ID'] ?? '187648853060-aub6vfna1dmvb4ihb5o7ir3re3bn0c0i.apps.googleusercontent.com'}

# ===== STORAGE =====
STORAGE_URL=$supabaseUrl/storage/v1
STORAGE_WORKOUT_BUCKET=workout-images
STORAGE_PROFILE_BUCKET=profile-images
STORAGE_NUTRITION_BUCKET=nutrition-images
STORAGE_FEATURED_BUCKET=featured-images
STORAGE_CHALLENGE_BUCKET=challenge-media

# ===== APP CONFIG =====
APP_NAME=Ray Club
APP_BUNDLE_ID=com.rayclub.app
APP_SCHEME=rayclub
API_URL=$supabaseUrl

# ===== ENVIRONMENT =====
ENVIRONMENT=development
''';
  
  // Salvar em um arquivo .env.fixed
  final file = File('.env.fixed');
  await file.writeAsString(envContent);
  
  print('📝 Arquivo .env.fixed criado com a configuração completa!');
  print('👉 Para aplicar as correções, execute:');
  print('   cp .env.fixed .env');
  print('\n⚠️  IMPORTANTE: Revise o arquivo antes de substituir!\n');
}

void createExampleEnv() {
  final exampleContent = '''
# ===== CONFIGURAÇÃO BÁSICA =====
SUPABASE_URL=https://zsbbgchsjuicwtrldn.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzanVpY3d0cmxkbiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzI5NjE5NjI0LCJleHAiOjIwNDUxOTU2MjR9.Yx_tFJvXKKLuqz0K-w0B3lMcqY-rQ5Q6hYjaVBMVMz8

# ===== CONFIGURAÇÃO POR AMBIENTE =====
# Development
DEV_SUPABASE_URL=https://zsbbgchsjuicwtrldn.supabase.co
DEV_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzanVpY3d0cmxkbiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzI5NjE5NjI0LCJleHAiOjIwNDUxOTU2MjR9.Yx_tFJvXKKLuqz0K-w0B3lMcqY-rQ5Q6hYjaVBMVMz8
DEV_API_URL=https://zsbbgchsjuicwtrldn.supabase.co
DEV_DEBUG_MODE=true

# Staging
STAGING_SUPABASE_URL=https://zsbbgchsjuicwtrldn.supabase.co
STAGING_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzanVpY3d0cmxkbiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzI5NjE5NjI0LCJleHAiOjIwNDUxOTU2MjR9.Yx_tFJvXKKLuqz0K-w0B3lMcqY-rQ5Q6hYjaVBMVMz8
STAGING_API_URL=https://zsbbgchsjuicwtrldn.supabase.co
STAGING_DEBUG_MODE=true

# Production
PROD_SUPABASE_URL=https://zsbbgchsjuicwtrldn.supabase.co
PROD_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzanVpY3d0cmxkbiIsInJvbGUiOiJhbm9uIiwiaWF0IjoxNzI5NjE5NjI0LCJleHAiOjIwNDUxOTU2MjR9.Yx_tFJvXKKLuqz0K-w0B3lMcqY-rQ5Q6hYjaVBMVMz8
PROD_API_URL=https://zsbbgchsjuicwtrldn.supabase.co
PROD_DEBUG_MODE=false

# ===== GOOGLE OAUTH =====
GOOGLE_WEB_CLIENT_ID=187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=187648853060-aub6vfna1dmvb4ihb5o7ir3re3bn0c0i.apps.googleusercontent.com

# ===== STORAGE =====
STORAGE_URL=https://zsbbgchsjuicwtrldn.supabase.co/storage/v1
STORAGE_WORKOUT_BUCKET=workout-images
STORAGE_PROFILE_BUCKET=profile-images
STORAGE_NUTRITION_BUCKET=nutrition-images
STORAGE_FEATURED_BUCKET=featured-images
STORAGE_CHALLENGE_BUCKET=challenge-media

# ===== APP CONFIG =====
APP_NAME=Ray Club
APP_BUNDLE_ID=com.rayclub.app
APP_SCHEME=rayclub
API_URL=https://zsbbgchsjuicwtrldn.supabase.co

# ===== ENVIRONMENT =====
ENVIRONMENT=development
''';
  
  final file = File('.env.example');
  file.writeAsStringSync(exampleContent);
  
  print('📝 Arquivo .env.example criado!');
  print('👉 Para usar, execute:');
  print('   cp .env.example .env');
} 