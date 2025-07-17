import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Script para validar a configuração de produção
/// 
/// Execute com: dart validate_production_config.dart
void main() async {
  print('🔍 Validando configuração de produção...\n');
  
  // Carregar .env
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Arquivo .env carregado com sucesso\n');
  } catch (e) {
    print('❌ ERRO: Arquivo .env não encontrado!');
    print('   Crie um arquivo .env baseado no env.production.example');
    exit(1);
  }
  
  // Validar variáveis obrigatórias
  final requiredVars = {
    'PROD_SUPABASE_URL': 'URL do Supabase de produção',
    'PROD_SUPABASE_ANON_KEY': 'Chave anônima do Supabase de produção',
    'GOOGLE_WEB_CLIENT_ID': 'Google Web Client ID',
    'GOOGLE_IOS_CLIENT_ID': 'Google iOS Client ID',
    'APPLE_CLIENT_ID': 'Apple Client ID',
    'APPLE_SERVICE_ID': 'Apple Service ID',
  };
  
  var hasErrors = false;
  
  print('📋 Verificando variáveis obrigatórias:\n');
  
  for (final entry in requiredVars.entries) {
    final value = dotenv.env[entry.key];
    if (value == null || value.isEmpty) {
      print('❌ ${entry.key}: NÃO CONFIGURADA');
      print('   Descrição: ${entry.value}');
      hasErrors = true;
    } else {
      // Validações específicas
      if (entry.key.contains('SUPABASE_URL')) {
        if (value.contains('zsbbgchsjiuicwvtrldn')) {
          print('❌ ${entry.key}: USANDO URL DE DESENVOLVIMENTO!');
          print('   Valor atual: $value');
          print('   ⚠️  Esta é a URL que está causando o erro no Google Login!');
          hasErrors = true;
        } else if (!value.startsWith('https://') || !value.contains('.supabase.co')) {
          print('⚠️  ${entry.key}: Formato inválido');
          print('   Esperado: https://SEU_PROJETO.supabase.co');
          hasErrors = true;
        } else {
          print('✅ ${entry.key}: Configurada corretamente');
        }
      } else if (entry.key.contains('ANON_KEY')) {
        if (value.length < 100) {
          print('⚠️  ${entry.key}: Chave parece muito curta');
          hasErrors = true;
        } else {
          print('✅ ${entry.key}: Configurada');
        }
      } else {
        print('✅ ${entry.key}: ${value}');
      }
    }
  }
  
  print('\n📋 Verificando variáveis opcionais:\n');
  
  final optionalVars = {
    'BASE_URL': 'https://rayclub.com.br',
    'APP_ENV': 'production',
    'SENTRY_DSN': 'Configuração do Sentry',
  };
  
  for (final entry in optionalVars.entries) {
    final value = dotenv.env[entry.key];
    if (value == null || value.isEmpty) {
      print('⚠️  ${entry.key}: Não configurada (opcional)');
      if (entry.value.isNotEmpty) {
        print('   Valor sugerido: ${entry.value}');
      }
    } else {
      print('✅ ${entry.key}: $value');
    }
  }
  
  // Verificar Google Client IDs
  print('\n📋 Validando Google OAuth:\n');
  
  final googleWebId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
  final googleIosId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];
  
  if (googleWebId == '187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt.apps.googleusercontent.com' &&
      googleIosId == '187648853060-aub6vfna1dmvb4ihb5o7ir3re3bn0c0i.apps.googleusercontent.com') {
    print('✅ Google Client IDs estão corretos');
  } else {
    print('⚠️  Google Client IDs foram alterados!');
    print('   Certifique-se de que estão configurados corretamente no Google Cloud Console');
  }
  
  // Resultado final
  print('\n' + '=' * 60);
  
  if (hasErrors) {
    print('\n❌ CONFIGURAÇÃO INVÁLIDA!');
    print('\nCorreções necessárias:');
    print('1. Configure todas as variáveis obrigatórias no arquivo .env');
    print('2. Substitua a URL do Supabase de desenvolvimento pela URL de produção');
    print('3. Obtenha as credenciais corretas no painel do Supabase');
    print('\nConsulte o arquivo APPLE_REVIEW_FIX_GUIDE.md para instruções detalhadas.');
    exit(1);
  } else {
    print('\n✅ CONFIGURAÇÃO VÁLIDA!');
    print('\nPróximos passos:');
    print('1. Execute o script SQL fix_apple_signin_database.sql no Supabase');
    print('2. Crie o usuário de teste review@rayclub.com');
    print('3. Faça o build: flutter build ios --release');
    print('4. Teste em um dispositivo real antes de submeter');
  }
} 