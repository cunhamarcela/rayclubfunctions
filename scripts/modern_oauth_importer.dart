import 'dart:io';
import 'dart:convert';

/// Script OAuth moderno para importar vídeos privados usando localhost
/// Compatível com as novas políticas do Google OAuth
void main() async {
  print('🔐 Importador de Vídeos Privados do YouTube - Ray Club (Moderno)');
  print('');
  
  // Verifica arquivo .env
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ ERRO: Arquivo .env não encontrado');
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
  
  if (clientId == null || clientSecret == null) {
    print('❌ ERRO: Configure as credenciais OAuth no arquivo .env');
    return;
  }
  
  print('✅ Credenciais OAuth encontradas!');
  print('');
  
  // Configuração moderna usando localhost
  final redirectUri = 'http://localhost:8080';
  final scope = 'https://www.googleapis.com/auth/youtube.readonly';
  
  print('📋 CONFIGURAÇÃO NECESSÁRIA NO GOOGLE CONSOLE:');
  print('');
  print('1. ✅ Vá para: https://console.developers.google.com/apis/credentials');
  print('2. ✅ Clique na sua credencial OAuth 2.0');
  print('3. ❌ REMOVA: urn:ietf:wg:oauth:2.0:oob (obsoleto)');
  print('4. ✅ ADICIONE: http://localhost:8080');
  print('5. ✅ Clique em "SAVE"');
  print('6. ⏳ Aguarde alguns minutos para aplicar');
  print('');
  
  stdout.write('✅ Confirmou que configurou localhost:8080 no Google Console? (s/n): ');
  final confirmation = stdin.readLineSync()?.trim().toLowerCase();
  
  if (confirmation != 's' && confirmation != 'sim' && confirmation != 'y' && confirmation != 'yes') {
    print('');
    print('⚠️  Configure primeiro no Google Console e depois execute novamente!');
    return;
  }
  
  print('');
  print('🚀 CONFIGURAÇÃO DETECTADA! Gerando link de autorização...');
  print('');
  
  final authUrl = 'https://accounts.google.com/o/oauth2/v2/auth'
      '?client_id=${Uri.encodeComponent(clientId)}'
      '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
      '&response_type=code'
      '&scope=${Uri.encodeComponent(scope)}'
      '&access_type=offline'
      '&prompt=consent';
  
  print('🔗 PASSO 1: Copie e abra este link no navegador:');
  print('');
  print(authUrl);
  print('');
  print('🔑 PASSO 2: Faça login com sua conta de MANAGER do canal');
  print('🔑 PASSO 3: Autorize o acesso');
  print('🔑 PASSO 4: Após autorizar, você será redirecionado para localhost:8080');
  print('🔑 PASSO 5: Copie o código da URL (após "code=")');
  print('');
  print('💡 EXEMPLO da URL de retorno:');
  print('   http://localhost:8080/?code=4/0AdeuSd...&scope=...');
  print('   ↑ Copie apenas a parte: 4/0AdeuSd...');
  print('');
  
  stdout.write('Cole aqui APENAS o código de autorização: ');
  final authCode = stdin.readLineSync()?.trim();
  
  if (authCode == null || authCode.isEmpty) {
    print('❌ Código de autorização inválido');
    return;
  }
  
  print('');
  print('✅ Código recebido: ${authCode.length > 20 ? authCode.substring(0, 20) + '...' : authCode}');
  print('');
  print('🔄 Próximos passos:');
  print('1. ✅ OAuth configurado com localhost');
  print('2. ✅ Código de autorização obtido');
  print('3. 🔄 Agora execute o script completo de importação');
  print('');
  print('🚀 Execute: dart run scripts/oauth_youtube_manager.dart');
  print('');
  print('💡 O script completo usará este token para:');
  print('   - Buscar vídeos privados do canal');
  print('   - Categorizar automaticamente');
  print('   - Inserir no banco de dados');
  print('   - Excluir vídeos "The Unit"');
  print('   - Evitar duplicatas');
  print('');
  
  // Salva código temporariamente
  final tempFile = File('temp_auth_code.txt');
  await tempFile.writeAsString(authCode);
  print('📝 Código salvo em: temp_auth_code.txt');
  print('🎉 Configuração moderna concluída com sucesso!');
} 