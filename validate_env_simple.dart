import 'dart:io';

void main() {
  print('🔍 Validando configuração de produção...\n');
  
  // Verificar se o arquivo .env existe
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ ERRO: Arquivo .env não encontrado!');
    print('   Execute: cp env.production.example .env');
    exit(1);
  }
  
  print('✅ Arquivo .env encontrado\n');
  
  // Ler o arquivo
  final lines = envFile.readAsLinesSync();
  final env = <String, String>{};
  
  for (final line in lines) {
    if (line.trim().isEmpty || line.startsWith('#')) continue;
    final parts = line.split('=');
    if (parts.length >= 2) {
      env[parts[0].trim()] = parts.sublist(1).join('=').trim();
    }
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
    final value = env[entry.key];
    if (value == null || value.isEmpty) {
      print('❌ ${entry.key}: NÃO CONFIGURADA');
      print('   Descrição: ${entry.value}');
      hasErrors = true;
    } else {
      // Validações específicas
      if (entry.key.contains('SUPABASE_URL')) {
        if (value == 'https://zsbbgchsjiuicwvtrldn.supabase.co') {
          print('✅ ${entry.key}: Configurada corretamente');
          print('   URL: $value');
        } else {
          print('⚠️  ${entry.key}: URL diferente da esperada');
          print('   Valor atual: $value');
          print('   Valor esperado: https://zsbbgchsjiuicwvtrldn.supabase.co');
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
  
  // Verificar Google Client IDs
  print('\n📋 Validando Google OAuth:\n');
  
  final googleWebId = env['GOOGLE_WEB_CLIENT_ID'];
  final googleIosId = env['GOOGLE_IOS_CLIENT_ID'];
  
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
    print('2. Verifique se as credenciais estão corretas');
    print('\nConsulte o arquivo APPLE_REVIEW_FIX_GUIDE.md para instruções detalhadas.');
    exit(1);
  } else {
    print('\n✅ CONFIGURAÇÃO VÁLIDA!');
    print('\nPróximos passos:');
    print('1. Execute o script SQL fix_apple_signin_database.sql no Supabase');
    print('2. Execute o script SQL setup_apple_review_user.sql no Supabase');
    print('3. Faça o build: flutter build ios --release');
    print('4. Teste em um dispositivo real antes de submeter');
    print('\nSua URL do Supabase: https://zsbbgchsjiuicwvtrldn.supabase.co');
  }
} 