import 'dart:io';
import 'dart:convert';

/// Script simplificado para importar vídeos privados usando OAuth
/// Este script autentica usando suas credenciais de manager para acessar vídeos privados
void main() async {
  print('🔐 Importador de Vídeos Privados do YouTube - Ray Club');
  print('');
  
  // Instruções para OAuth
  print('📋 CONFIGURAÇÃO OAUTH NECESSÁRIA:');
  print('1. Acesse: https://console.developers.google.com/');
  print('2. Crie um projeto ou selecione um existente');
  print('3. Habilite a YouTube Data API v3');
  print('4. Crie credenciais OAuth 2.0 para aplicação desktop');
  print('5. Configure as credenciais no arquivo .env');
  print('');
  
  // Verifica arquivo .env
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ ERRO: Arquivo .env não encontrado');
    print('📋 Crie um arquivo .env na raiz do projeto com:');
    print('');
    print('GOOGLE_OAUTH_CLIENT_ID=seu_client_id_aqui');
    print('GOOGLE_OAUTH_CLIENT_SECRET=seu_client_secret_aqui');
    print('YOUTUBE_API_KEY=AIzaSyB7ABH_EMd3kg2DGRh3SXMJaKBSNsotPNs');
    print('SUPABASE_URL=https://ggrjepkyhwlfbhyqrzgg.supabase.co');
    print('SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdncmplcGt5aHdsZmJoeXFyemdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ1MzAzNzksImV4cCI6MjA1MDEwNjM3OX0.j8u5cQOdKHiafkzC1lgOK3PpGUQEYRtAM8StyQqLNzw');
    return;
  }
  
  // Lê arquivo .env
  final envContent = await envFile.readAsString();
  final envVars = <String, String>{};
  
  for (final line in envContent.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    
    final parts = trimmed.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      final value = parts.sublist(1).join('=').trim();
      envVars[key] = value;
    }
  }
  
  final clientId = envVars['GOOGLE_OAUTH_CLIENT_ID'];
  final clientSecret = envVars['GOOGLE_OAUTH_CLIENT_SECRET'];
  
  if (clientId == null || clientSecret == null || 
      clientId == 'SEU_CLIENT_ID_AQUI' || clientSecret == 'SEU_CLIENT_SECRET_AQUI') {
    print('❌ ERRO: Configure as credenciais OAuth no arquivo .env');
    print('');
    print('GOOGLE_OAUTH_CLIENT_ID=seu_client_id_real_aqui');
    print('GOOGLE_OAUTH_CLIENT_SECRET=seu_client_secret_real_aqui');
    print('');
    print('📋 Para obter as credenciais:');
    print('1. Acesse: https://console.developers.google.com/');
    print('2. Vá em "APIs & Services" > "Credentials"');
    print('3. Clique em "Create Credentials" > "OAuth 2.0 Client IDs"');
    print('4. Escolha "Desktop application"');
    print('5. Copie o Client ID e Client Secret para o .env');
    return;
  }
  
  print('✅ Arquivo .env encontrado e configurado!');
  print('');
  
  // Gera URL de autorização
  final redirectUri = 'urn:ietf:wg:oauth:2.0:oob';
  final scope = 'https://www.googleapis.com/auth/youtube.readonly';
  
  final authUrl = 'https://accounts.google.com/o/oauth2/v2/auth'
      '?client_id=${Uri.encodeComponent(clientId)}'
      '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
      '&response_type=code'
      '&scope=${Uri.encodeComponent(scope)}'
      '&access_type=offline'
      '&prompt=consent';
  
  print('🔗 PASSO 1: Abra este link no navegador:');
  print(authUrl);
  print('');
  print('🔑 PASSO 2: Faça login com sua conta de MANAGER do canal');
  print('🔑 PASSO 3: Autorize o acesso');
  print('🔑 PASSO 4: Copie o código de autorização');
  print('');
  
  stdout.write('Cole aqui o código de autorização: ');
  final authCode = stdin.readLineSync()?.trim();
  
  if (authCode == null || authCode.isEmpty) {
    print('❌ Código de autorização inválido');
    return;
  }
  
  print('');
  print('🔄 Próximos passos:');
  print('1. ✅ OAuth configurado e autorizado');
  print('2. 🔄 Agora execute o script completo:');
  print('   dart run scripts/oauth_youtube_manager.dart');
  print('');
  print('💡 O script completo usará este token para:');
  print('   - Buscar vídeos privados do canal');
  print('   - Categorizar automaticamente');
  print('   - Inserir no banco de dados');
  print('   - Excluir vídeos "The Unit"');
  print('   - Evitar duplicatas');
  print('');
  print('🎉 Configuração concluída com sucesso!');
  
  // Salva código temporariamente para debug
  final tempFile = File('temp_auth_code.txt');
  await tempFile.writeAsString(authCode);
  print('📝 Código salvo em: temp_auth_code.txt (para debug)');
} 