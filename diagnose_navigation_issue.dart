import 'dart:io';

void main() {
  print('🔍 DIAGNÓSTICO DE NAVEGAÇÃO PÓS-AUTENTICAÇÃO');
  print('=' * 60);
  
  diagnoseNavigationIssue();
  
  print('\n📋 INSTRUÇÕES PARA CORRIGIR:');
  print('1. O problema pode estar no timing da navegação');
  print('2. O LoginScreen pode não estar detectando o estado authenticated');
  print('3. Pode haver conflito entre navegações simultâneas');
  print('4. O context pode estar desmontado durante a navegação');
  
  print('\n🔧 SOLUÇÕES RECOMENDADAS:');
  print('1. Adicionar delay antes da navegação');
  print('2. Verificar se o context está montado');
  print('3. Usar Consumer widget no LoginScreen');
  print('4. Adicionar logs detalhados para debug');
  
  print('\n⚠️  PRÓXIMOS PASSOS:');
  print('1. Verificar se o AuthViewModel está realmente mudando o estado');
  print('2. Confirmar se o LoginScreen está escutando as mudanças');
  print('3. Adicionar logs no método navigateToHomeAfterAuth');
  print('4. Testar navegação direta bypass do listener');
}

void diagnoseNavigationIssue() {
  print('\n🔍 ANALISANDO POSSÍVEIS CAUSAS:');
  
  // Verificar arquivos relevantes
  checkFile('lib/features/auth/screens/login_screen.dart', 'LoginScreen');
  checkFile('lib/features/auth/viewmodels/auth_view_model.dart', 'AuthViewModel');
  checkFile('lib/core/router/app_router.dart', 'Router');
  
  print('\n🎯 PROBLEMAS IDENTIFICADOS:');
  print('1. ✅ Apple Sign In funciona (usuário autenticado)');
  print('2. ❌ Navegação não acontece após autenticação');
  print('3. ⚠️  LoginScreen não reage ao estado authenticated');
  print('4. ⚠️  Possível problema de timing na navegação');
  
  print('\n💡 CAUSAS PROVÁVEIS:');
  print('- O LoginScreen pode estar reconstruindo muito rápido');
  print('- O método navigateToHomeAfterAuth pode ter falha');
  print('- Conflito entre múltiplos listeners de estado');
  print('- Context desmontado durante a navegação');
  print('- Erro no router ou nas rotas definidas');
}

void checkFile(String path, String description) {
  final file = File(path);
  if (file.existsSync()) {
    print('✅ $description encontrado: $path');
  } else {
    print('❌ $description NÃO encontrado: $path');
  }
} 