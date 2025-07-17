import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carregar variáveis de ambiente
  await dotenv.load(fileName: ".env");
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  
  // ID do usuário para teste
  const userId = '01d4a292-1873-4af6-948b-a55eed56d6b9';
  
  print('=== TESTE RÁPIDO DO SISTEMA DE ACESSO ===\n');
  
  try {
    // 1. Verificar dados na tabela
    print('1. Verificando user_progress_level...');
    final userData = await Supabase.instance.client
        .from('user_progress_level')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    
    if (userData == null) {
      print('   ❌ Usuário NÃO encontrado na tabela user_progress_level');
      print('   ⚠️  Isso explica por que o sistema não está funcionando!');
    } else {
      print('   ✅ Usuário encontrado:');
      print('      - current_level: ${userData['current_level']}');
      print('      - level_expires_at: ${userData['level_expires_at']}');
      print('      - unlocked_features: ${userData['unlocked_features']}');
    }
    
    // 2. Testar função RPC
    print('\n2. Testando função RPC check_user_access_level...');
    final rpcResult = await Supabase.instance.client
        .rpc('check_user_access_level', params: {
          'user_id_param': userId
        });
    
    print('   Resultado:');
    print('   - has_extended_access: ${rpcResult['has_extended_access']}');
    print('   - access_level: ${rpcResult['access_level']}');
    print('   - available_features: ${rpcResult['available_features']}');
    
    // 3. Verificar features específicas
    print('\n3. Verificando features disponíveis:');
    final features = rpcResult['available_features'] as List<dynamic>;
    
    print('   Dashboard Normal (enhanced_dashboard): ${features.contains('enhanced_dashboard') ? '✅' : '❌'}');
    print('   Nutrição (nutrition_guide): ${features.contains('nutrition_guide') ? '✅' : '❌'}');
    print('   Vídeos Parceiros (workout_library): ${features.contains('workout_library') ? '✅' : '❌'}');
    print('   Benefícios (detailed_reports): ${features.contains('detailed_reports') ? '✅' : '❌'}');
    
    // 4. Diagnóstico
    print('\n=== DIAGNÓSTICO ===');
    if (userData == null) {
      print('🔴 PROBLEMA: Usuário não existe na tabela user_progress_level');
      print('   SOLUÇÃO: Execute o script SQL para criar/atualizar o usuário como expert');
    } else if (userData['current_level'] != 'expert') {
      print('🟡 PROBLEMA: Usuário está como ${userData['current_level']}, não como expert');
      print('   SOLUÇÃO: Execute o UPDATE para mudar para expert');
    } else if (!features.contains('enhanced_dashboard')) {
      print('🟡 PROBLEMA: Usuário é expert mas não tem todas as features');
      print('   SOLUÇÃO: Execute o UPDATE para corrigir as features');
    } else {
      print('🟢 Tudo parece estar correto no banco de dados!');
      print('   O problema pode estar no código Flutter ou no cache do app.');
    }
    
  } catch (e) {
    print('❌ ERRO: $e');
  }
  
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text('Verifique o console para ver os resultados'),
      ),
    ),
  ));
} 