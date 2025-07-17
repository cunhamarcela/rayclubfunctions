import 'dart:io';

/// Script para diagnosticar o problema específico do OAuth
/// 
/// Execute com: dart diagnose_oauth_issue.dart
void main() {
  print('🔍 ========== DIAGNÓSTICO DO ERRO OAUTH ==========');
  print('');
  
  print('❌ ERRO IDENTIFICADO: "Unable to exchange external code"');
  print('');
  
  print('📋 O que isso significa:');
  print('   1. ✅ O Google OAuth está funcionando');
  print('   2. ✅ O usuário consegue fazer login no Google');
  print('   3. ✅ O app recebe o callback com o código');
  print('   4. ❌ O Supabase NÃO consegue trocar o código por token');
  print('');
  
  print('🔍 POSSÍVEIS CAUSAS:');
  print('');
  
  print('1️⃣ **Configuração do Google Cloud Console**');
  print('   ❌ Client ID errado');
  print('   ❌ Client Secret não configurado no Supabase');
  print('   ❌ URLs de redirect não autorizadas');
  print('');
  
  print('2️⃣ **Configuração do Supabase Dashboard**');
  print('   ❌ Google Provider não está habilitado');
  print('   ❌ Client ID e Client Secret não estão configurados');
  print('   ❌ URLs de callback não estão configuradas');
  print('');
  
  print('3️⃣ **Incompatibilidade de Configuração**');
  print('   ❌ Usando Client ID do iOS mas Secret do Web');
  print('   ❌ Redirect URL diferente entre app e Supabase');
  print('');
  
  print('🔧 SOLUÇÃO PASSO A PASSO:');
  print('');
  
  print('📱 NO GOOGLE CLOUD CONSOLE:');
  print('   1. Vá para: https://console.cloud.google.com/');
  print('   2. APIs & Services > Credentials');
  print('   3. Clique no Client ID: 187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt');
  print('   4. Verifique se é tipo "Web application"');
  print('   5. Em "Authorized redirect URIs", DEVE TER:');
  print('      - https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback');
  print('   6. Copie o Client Secret (será necessário)');
  print('');
  
  print('🔐 NO SUPABASE DASHBOARD:');
  print('   1. Vá para: https://supabase.com/dashboard/project/zsbbgchsjiuicwvtrldn');
  print('   2. Authentication > Providers > Google');
  print('   3. Verifique se está HABILITADO');
  print('   4. Configure:');
  print('      - Client ID: 187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt.apps.googleusercontent.com');
  print('      - Client Secret: (cole o secret do Google Console)');
  print('   5. Em "Redirect URLs", adicione TODAS:');
  print('      - rayclub://login-callback/');
  print('      - rayclub://login-callback');
  print('      - https://rayclub.com.br/auth/callback');
  print('');
  
  print('⚠️  IMPORTANTE: Use o Client ID e Secret do MESMO projeto!');
  print('   - Se o Client ID é do "Web application", use o Secret dele');
  print('   - NÃO misture Client ID do iOS com Secret do Web');
  print('');
  
  print('🔍 VERIFICAÇÃO FINAL:');
  print('   1. Client ID no app: 187648853060-1dcptn3rrnjh1unvpa9segd6o9bdnnqt');
  print('   2. Mesmo Client ID no Supabase');
  print('   3. Client Secret correto no Supabase');
  print('   4. URL callback no Google Console: https://zsbbgchsjiuicwvtrldn.supabase.co/auth/v1/callback');
  print('');
  
  print('💡 DICA: O erro "Unable to exchange external code" quase sempre');
  print('   significa que o Client Secret está errado ou ausente no Supabase!');
  
  print('');
  print('🔍 ========== FIM DO DIAGNÓSTICO ==========');
} 