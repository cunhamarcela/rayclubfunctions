import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 Diagnóstico Completo OAuth - Ray Club');
  print('=' * 50);
  print('');

  // 1. Verificar arquivo .env
  print('📂 1. VERIFICANDO ARQUIVO .env...');
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ Arquivo .env não encontrado!');
    return;
  }
  print('✅ Arquivo .env encontrado');
  
  // 2. Ler credenciais
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
  final youtubeKey = envVars['YOUTUBE_API_KEY'];
  
  print('');
  print('🔑 2. VERIFICANDO CREDENCIAIS...');
  
  if (clientId == null || clientId.isEmpty) {
    print('❌ GOOGLE_OAUTH_CLIENT_ID não encontrado');
  } else {
    print('✅ Client ID: ${clientId.length > 20 ? clientId.substring(0, 20) + '...' : clientId}');
    
    // Verificar formato do Client ID
    if (!clientId.contains('.apps.googleusercontent.com')) {
      print('⚠️  ATENÇÃO: Client ID não parece ter formato correto');
      print('   Formato esperado: xxxxxxxxx.apps.googleusercontent.com');
    }
  }
  
  if (clientSecret == null || clientSecret.isEmpty) {
    print('❌ GOOGLE_OAUTH_CLIENT_SECRET não encontrado');
  } else {
    print('✅ Client Secret: ${clientSecret.length > 10 ? clientSecret.substring(0, 10) + '...' : clientSecret}');
    
    // Verificar formato do Client Secret
    if (!clientSecret.startsWith('GOCSPX-')) {
      print('⚠️  ATENÇÃO: Client Secret não parece ter formato correto');
      print('   Formato esperado: GOCSPX-xxxxxxxxxxxxxxxxx');
    }
  }
  
  if (youtubeKey == null || youtubeKey.isEmpty) {
    print('❌ YOUTUBE_API_KEY não encontrado');
  } else {
    print('✅ YouTube API Key: ${youtubeKey.length > 10 ? youtubeKey.substring(0, 10) + '...' : youtubeKey}');
  }
  
  print('');
  print('🌐 3. TESTANDO CONECTIVIDADE...');
  
  // Testar conectividade básica
  try {
    final result = await Process.run('ping', ['-c', '1', 'accounts.google.com']);
    if (result.exitCode == 0) {
      print('✅ Conectividade com Google OK');
    } else {
      print('❌ Problemas de conectividade com Google');
    }
  } catch (e) {
    print('⚠️  Não foi possível testar conectividade');
  }
  
  print('');
  print('🔧 4. POSSÍVEIS PROBLEMAS E SOLUÇÕES:');
  print('');
  
  print('❓ PROBLEMA MAIS COMUM: Configuração incorreta no Google Console');
  print('');
  print('📋 CHECKLIST PARA RESOLVER:');
  print('');
  print('□ 1. PROJETO CORRETO:');
  print('     - Acesse: https://console.cloud.google.com/');
  print('     - Verifique se está no projeto "RayClub" (canto superior)');
  print('');
  print('□ 2. API HABILITADA:');
  print('     - Vá em "APIs & Services" > "Enabled APIs & services"');
  print('     - Verifique se "YouTube Data API v3" está na lista');
  print('     - Se não estiver: "Library" > Busque "YouTube Data API v3" > "Enable"');
  print('');
  print('□ 3. CREDENCIAIS CORRETAS:');
  print('     - Vá em "APIs & Services" > "Credentials"');
  print('     - Clique na credencial OAuth 2.0');
  print('     - Verifique se está como "Desktop application"');
  print('');
  print('□ 4. URI DE REDIRECIONAMENTO:');
  print('     - Na mesma tela de credenciais');
  print('     - Em "Authorized redirect URIs" deve ter: http://localhost:8080');
  print('     - REMOVA qualquer: urn:ietf:wg:oauth:2.0:oob');
  print('');
  print('□ 5. AGUARDAR PROPAGAÇÃO:');
  print('     - Após salvar, aguarde 5-10 minutos');
  print('     - As mudanças demoram para propagar');
  print('');
  
  print('🆘 SOLUÇÃO ALTERNATIVA: CRIAR NOVA CREDENCIAL');
  print('');
  print('Se o problema persistir, crie uma nova credencial:');
  print('1. Delete a credencial atual');
  print('2. Crie nova: "Desktop application"');
  print('3. Configure URI: http://localhost:8080');
  print('4. Copie as novas credenciais para .env');
  print('');
  
  stdout.write('❓ Quer que eu gere um novo link de teste? (s/n): ');
  final response = stdin.readLineSync()?.trim().toLowerCase();
  
  if (response == 's' || response == 'sim') {
    print('');
    print('🔗 LINK DE TESTE (use apenas se tiver certeza das configurações):');
    
    if (clientId != null && clientId.isNotEmpty) {
      final testUrl = 'https://accounts.google.com/o/oauth2/v2/auth'
          '?client_id=${Uri.encodeComponent(clientId)}'
          '&redirect_uri=${Uri.encodeComponent('http://localhost:8080')}'
          '&response_type=code'
          '&scope=${Uri.encodeComponent('https://www.googleapis.com/auth/youtube.readonly')}'
          '&access_type=offline'
          '&prompt=consent';
      
      print('');
      print(testUrl);
      print('');
      print('⚠️  Use este link APENAS após verificar todas as configurações acima!');
    }
  }
  
  print('');
  print('💡 DICA FINAL: Se nada funcionar, tente criar um projeto completamente novo no Google Console');
  print('   com um nome diferente e configure do zero.');
  print('');
  print('📞 Depois de verificar/corrigir tudo, execute novamente:');
  print('   dart run scripts/modern_oauth_importer.dart');
} 