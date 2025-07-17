import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

// Script para diagnosticar problemas de login de usuário específico
void main() async {
  print('🔍 ========== DIAGNÓSTICO DE PROBLEMA DE LOGIN ==========');
  print('🔍 Data/Hora: ${DateTime.now().toIso8601String()}');
  print('');
  
  // Solicitar o email do usuário
  print('📧 Digite o email do usuário que está com problema de login:');
  final String? email = stdin.readLineSync();
  
  if (email == null || email.isEmpty) {
    print('❌ Email não fornecido. Saindo...');
    exit(1);
  }
  
  print('🔍 Investigando problema de login para: $email');
  print('');
  
  try {
    // Inicializar Supabase
    print('📡 Inicializando conexão com Supabase...');
    
    // Você pode definir essas variáveis de ambiente ou substituir pelos valores
    const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const supabaseKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      print('❌ SUPABASE_URL e SUPABASE_ANON_KEY devem ser definidas como variáveis de ambiente');
      print('   Execute: export SUPABASE_URL="sua_url" && export SUPABASE_ANON_KEY="sua_key"');
      exit(1);
    }
    
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    );
    
    final client = Supabase.instance.client;
    print('✅ Conexão estabelecida com sucesso');
    print('');
    
    // 1. Verificar se existe na tabela auth.users
    print('🔍 1. VERIFICANDO TABELA AUTH.USERS');
    print('   Executando: SELECT * FROM auth.users WHERE email = \'$email\'');
    
    try {
      final authUsersResult = await client.rpc('check_auth_user', params: {
        'user_email': email,
      });
      
      print('   Resultado: $authUsersResult');
      
      if (authUsersResult == null || authUsersResult.isEmpty) {
        print('❌ PROBLEMA IDENTIFICADO: Usuário NÃO existe na tabela auth.users');
        print('   Isso significa que a conta nunca foi criada ou foi deletada');
        print('   SOLUÇÃO: O usuário precisa se cadastrar novamente');
        return;
      } else {
        print('✅ Usuário existe na tabela auth.users');
        final userData = authUsersResult;
        print('   ID: ${userData['id']}');
        print('   Email: ${userData['email']}');
        print('   Email Confirmado: ${userData['email_confirmed_at']}');
        print('   Criado em: ${userData['created_at']}');
        print('   Último login: ${userData['last_sign_in_at']}');
        print('   Provider: ${userData['app_metadata']?['provider']}');
      }
    } catch (e) {
      print('⚠️ Erro ao consultar auth.users: $e');
      print('   Tentando método alternativo...');
      
      // Método alternativo: tentar fazer login
      try {
        print('🔍 Tentando verificar existência através de reset de senha...');
        await client.auth.resetPasswordForEmail(email);
        print('✅ Email existe (reset de senha aceito)');
      } catch (resetError) {
        if (resetError.toString().contains('User not found')) {
          print('❌ PROBLEMA IDENTIFICADO: Usuário NÃO existe');
          print('   SOLUÇÃO: O usuário precisa se cadastrar');
          return;
        } else {
          print('✅ Email provavelmente existe (outro tipo de erro no reset)');
        }
      }
    }
    
    print('');
    
    // 2. Verificar se existe na tabela profiles
    print('🔍 2. VERIFICANDO TABELA PROFILES');
    print('   Executando: SELECT * FROM profiles WHERE email = \'$email\'');
    
    try {
      final profileResult = await client
          .from('profiles')
          .select('*')
          .eq('email', email)
          .maybeSingle();
      
      if (profileResult == null) {
        print('⚠️ PROBLEMA IDENTIFICADO: Usuário existe em auth.users mas NÃO tem perfil');
        print('   Isso pode causar problemas de login');
        print('   SOLUÇÃO: Criar perfil manualmente ou trigger não funcionou');
      } else {
        print('✅ Perfil existe na tabela profiles');
        print('   ID: ${profileResult['id']}');
        print('   Email: ${profileResult['email']}');
        print('   Nome: ${profileResult['name']}');
        print('   Criado em: ${profileResult['created_at']}');
        print('   Nível: ${profileResult['level']}');
        print('   Status: ${profileResult['status']}');
      }
    } catch (e) {
      print('❌ Erro ao consultar profiles: $e');
    }
    
    print('');
    
    // 3. Verificar políticas RLS
    print('🔍 3. VERIFICANDO POLÍTICAS RLS');
    
    try {
      final rls = await client.rpc('check_rls_policies');
      print('   Políticas RLS ativas: $rls');
    } catch (e) {
      print('⚠️ Erro ao verificar políticas RLS: $e');
      print('   Isso pode indicar problema de permissões');
    }
    
    print('');
    
    // 4. Verificar se o email está sendo usado com provider diferente
    print('🔍 4. VERIFICANDO PROVIDERS DE AUTENTICAÇÃO');
    
    try {
      final providers = await client.rpc('check_user_providers', params: {
        'user_email': email,
      });
      
      print('   Providers encontrados: $providers');
      
      if (providers != null && providers.isNotEmpty) {
        for (final provider in providers) {
          print('   - Provider: ${provider['provider']}');
          print('   - ID: ${provider['provider_id']}');
        }
        
        // Se tem provider Google/Apple mas está tentando login com senha
        final hasOAuth = providers.any((p) => 
          p['provider'] == 'google' || p['provider'] == 'apple');
        
        if (hasOAuth) {
          print('⚠️ PROBLEMA IDENTIFICADO: Usuário criou conta com Google/Apple');
          print('   Mas está tentando fazer login com email/senha');
          print('   SOLUÇÃO: Usar o botão "Entrar com Google/Apple"');
        }
      }
    } catch (e) {
      print('⚠️ Erro ao verificar providers: $e');
    }
    
    print('');
    
    // 5. Verificar se o email foi confirmado
    print('🔍 5. VERIFICANDO STATUS DE CONFIRMAÇÃO DO EMAIL');
    
    try {
      final confirmStatus = await client.rpc('check_email_confirmation', params: {
        'user_email': email,
      });
      
      if (confirmStatus != null && confirmStatus['email_confirmed_at'] == null) {
        print('❌ PROBLEMA IDENTIFICADO: Email NÃO foi confirmado');
        print('   O usuário precisa verificar o email antes de fazer login');
        print('   SOLUÇÃO: Reenviar email de confirmação');
      } else {
        print('✅ Email foi confirmado');
      }
    } catch (e) {
      print('⚠️ Erro ao verificar confirmação de email: $e');
    }
    
    print('');
    
    // 6. Teste de login simulado
    print('🔍 6. TESTE DE LOGIN SIMULADO');
    print('   NOTA: Este teste NÃO vai funcionar pois não temos a senha');
    print('   Mas podemos verificar o tipo de erro retornado');
    
    try {
      await client.auth.signInWithPassword(
        email: email,
        password: 'senha_teste_invalida_123',
      );
    } catch (e) {
      print('   Erro esperado: $e');
      
      if (e.toString().contains('Invalid login credentials')) {
        print('✅ Usuário existe (erro de credenciais inválidas é esperado)');
      } else if (e.toString().contains('User not found')) {
        print('❌ PROBLEMA CONFIRMADO: Usuário não existe');
      } else if (e.toString().contains('Email not confirmed')) {
        print('❌ PROBLEMA CONFIRMADO: Email não foi confirmado');
      } else {
        print('⚠️ Erro inesperado: investigar mais');
      }
    }
    
    print('');
    print('🔍 ========== RESUMO DO DIAGNÓSTICO ==========');
    print('Email investigado: $email');
    print('Data/Hora: ${DateTime.now().toIso8601String()}');
    print('');
    print('PRÓXIMOS PASSOS:');
    print('1. Verificar se o usuário está usando o provider correto (Google/Apple vs Email/Senha)');
    print('2. Verificar se o email foi confirmado');
    print('3. Se necessário, criar manualmente o perfil do usuário');
    print('4. Verificar se não há problemas de RLS/permissões');
    print('5. Se tudo falhar, pedir para o usuário se cadastrar novamente');
    print('========================================');
    
  } catch (e, stackTrace) {
    print('❌ Erro fatal durante o diagnóstico: $e');
    print('StackTrace: $stackTrace');
  }
} 