import 'dart:io';

void main() {
  print('🔧 Configuração OAuth - Ray Club YouTube Importer');
  print('');
  print('❌ ERRO DETECTADO: "Error 401: invalid_client"');
  print('');
  print('🚨 SOLUÇÃO: Configurar credenciais OAuth corretamente');
  print('');
  
  print('📋 PASSOS PARA RESOLVER:');
  print('');
  print('1. ✅ ACESSE: https://console.developers.google.com/');
  print('');
  print('2. 🏗️ CRIE/SELECIONE UM PROJETO:');
  print('   - Se não tem projeto: "New Project" > Nome: "Ray Club YouTube"');
  print('   - Se já tem: Selecione o projeto existente');
  print('');
  print('3. 🔌 HABILITE A YOUTUBE DATA API V3:');
  print('   - Vá em "APIs & Services" > "Library"');
  print('   - Busque "YouTube Data API v3"');
  print('   - Clique "ENABLE"');
  print('');
  print('4. 🔑 CRIE CREDENCIAIS OAUTH 2.0:');
  print('   - Vá em "APIs & Services" > "Credentials"');
  print('   - Clique "CREATE CREDENTIALS" > "OAuth 2.0 Client IDs"');
  print('   - Aplicação: "Desktop application"');
  print('   - Nome: "Ray Club Video Importer"');
  print('');
  print('5. ⚙️ CONFIGURE URI DE REDIRECIONAMENTO:');
  print('   - Clique na credencial criada');
  print('   - Em "Authorized redirect URIs" adicione:');
  print('     urn:ietf:wg:oauth:2.0:oob');
  print('   - Clique "SAVE"');
  print('');
  print('6. 📋 COPIE AS NOVAS CREDENCIAIS:');
  print('   - Client ID (algo como: xxxxx.apps.googleusercontent.com)');
  print('   - Client Secret (algo como: GOCSPX-xxxxx)');
  print('');
  print('7. 🔄 ATUALIZE O ARQUIVO .env:');
  print('   GOOGLE_OAUTH_CLIENT_ID=seu_novo_client_id');
  print('   GOOGLE_OAUTH_CLIENT_SECRET=seu_novo_client_secret');
  print('');
  print('8. 🚀 EXECUTE NOVAMENTE:');
  print('   dart run scripts/simple_oauth_importer.dart');
  print('');
  print('💡 DICA: Use SEMPRE "Desktop application" para este tipo de script!');
  print('');
  
  stdout.write('✅ Após configurar, pressione ENTER para continuar...');
  stdin.readLineSync();
  
  print('');
  print('🎯 CHECKLIST FINAL:');
  print('□ Projeto criado/selecionado no Google Console');
  print('□ YouTube Data API v3 habilitada');
  print('□ OAuth 2.0 credencial criada como "Desktop application"');
  print('□ URI de redirecionamento: urn:ietf:wg:oauth:2.0:oob');
  print('□ Client ID e Secret copiados para .env');
  print('');
  print('🎉 Pronto para testar novamente!');
} 