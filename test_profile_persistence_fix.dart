import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Teste específico para verificar se o problema de persistência do perfil foi resolvido
class ProfilePersistenceTest {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Teste completo de persistência do perfil com nova implementação
  static Future<void> runProfilePersistenceTest() async {
    debugPrint('🧪 === TESTE DE PERSISTÊNCIA DO PERFIL ===');
    
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Usuário não autenticado');
        return;
      }

      debugPrint('👤 User ID: $userId');

      // 1. Ler perfil atual
      debugPrint('\n1️⃣ Lendo perfil atual...');
      final currentProfile = await _getCurrentProfile(userId);
      if (currentProfile == null) {
        debugPrint('❌ Perfil não encontrado');
        return;
      }

      debugPrint('📋 Perfil atual:');
      debugPrint('   - Nome: "${currentProfile['name']}"');
      debugPrint('   - Telefone: "${currentProfile['phone']}"');
      debugPrint('   - Instagram: "${currentProfile['instagram']}"');
      debugPrint('   - Updated_at: ${currentProfile['updated_at']}');

      // 2. Testar função de diagnóstico
      debugPrint('\n2️⃣ Executando diagnóstico...');
      final diagnosticResult = await _client.rpc('diagnose_profile_update', params: {
        'p_user_id': userId,
      });
      
      debugPrint('🔍 Resultado do diagnóstico: $diagnosticResult');

      // 3. Testar update usando função segura RPC
      debugPrint('\n3️⃣ Testando update com função segura...');
      
      final testData = {
        'p_user_id': userId,
        'p_name': 'Teste Nome ${DateTime.now().millisecondsSinceEpoch}',
        'p_phone': '(11) ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        'p_instagram': '@teste_${DateTime.now().millisecondsSinceEpoch}',
      };

      debugPrint('📤 Enviando dados via RPC:');
      debugPrint('   - Nome: ${testData['p_name']}');
      debugPrint('   - Telefone: ${testData['p_phone']}');
      debugPrint('   - Instagram: ${testData['p_instagram']}');

      final rpcResult = await _client.rpc('safe_update_profile', params: testData);
      debugPrint('✅ Resultado do RPC: $rpcResult');

      // 4. Aguardar um pouco e verificar persistência
      debugPrint('\n4️⃣ Aguardando e verificando persistência...');
      await Future.delayed(const Duration(seconds: 2));

      final verificationProfile = await _getCurrentProfile(userId);
      if (verificationProfile == null) {
        debugPrint('❌ Falha ao recuperar perfil para verificação');
        return;
      }

      debugPrint('📋 Perfil após update:');
      debugPrint('   - Nome: "${verificationProfile['name']}"');
      debugPrint('   - Telefone: "${verificationProfile['phone']}"');
      debugPrint('   - Instagram: "${verificationProfile['instagram']}"');
      debugPrint('   - Updated_at: ${verificationProfile['updated_at']}');

      // 5. Verificar se os dados persistiram corretamente
      debugPrint('\n5️⃣ Verificando persistência...');
      
      bool persistenceSuccess = true;
      
      if (verificationProfile['name'] != testData['p_name']) {
        debugPrint('❌ FALHA: Nome não persistiu');
        debugPrint('   Esperado: ${testData['p_name']}');
        debugPrint('   Obtido: ${verificationProfile['name']}');
        persistenceSuccess = false;
      } else {
        debugPrint('✅ Nome persistiu corretamente');
      }
      
      if (verificationProfile['phone'] != testData['p_phone']) {
        debugPrint('❌ FALHA: Telefone não persistiu');
        debugPrint('   Esperado: ${testData['p_phone']}');
        debugPrint('   Obtido: ${verificationProfile['phone']}');
        persistenceSuccess = false;
      } else {
        debugPrint('✅ Telefone persistiu corretamente');
      }
      
      if (verificationProfile['instagram'] != testData['p_instagram']) {
        debugPrint('❌ FALHA: Instagram não persistiu');
        debugPrint('   Esperado: ${testData['p_instagram']}');
        debugPrint('   Obtido: ${verificationProfile['instagram']}');
        persistenceSuccess = false;
      } else {
        debugPrint('✅ Instagram persistiu corretamente');
      }

      // 6. Testar update via método normal do repository
      debugPrint('\n6️⃣ Testando update via repository padrão...');
      
      final normalTestData = {
        'name': 'Normal Update ${DateTime.now().millisecondsSinceEpoch}',
        'phone': '(22) ${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        'instagram': '@normal_${DateTime.now().millisecondsSinceEpoch}',
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('profiles')
          .update(normalTestData)
          .eq('id', userId);

      await Future.delayed(const Duration(milliseconds: 1500));

      final normalVerification = await _getCurrentProfile(userId);
      
      debugPrint('📋 Resultado do update normal:');
      debugPrint('   - Nome: "${normalVerification?['name']}"');
      debugPrint('   - Telefone: "${normalVerification?['phone']}"');
      debugPrint('   - Instagram: "${normalVerification?['instagram']}"');

      // 7. Resultado final
      debugPrint('\n🎯 === RESULTADO FINAL ===');
      if (persistenceSuccess) {
        debugPrint('✅ SUCESSO: Problema de persistência resolvido!');
        debugPrint('🔧 A função RPC safe_update_profile está funcionando corretamente');
      } else {
        debugPrint('❌ FALHA: Problema de persistência ainda existe');
        debugPrint('🔧 Será necessária investigação adicional');
      }

    } catch (e, stackTrace) {
      debugPrint('❌ Erro durante o teste: $e');
      debugPrint('📚 Stack trace: $stackTrace');
    }
  }

  /// Busca perfil atual do usuário
  static Future<Map<String, dynamic>?> _getCurrentProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, name, phone, instagram, gender, bio, birth_date, updated_at, photo_url, profile_image_url')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      debugPrint('❌ Erro ao buscar perfil: $e');
      return null;
    }
  }

  /// Teste específico de coluna gerada
  static Future<void> testGeneratedColumn() async {
    debugPrint('\n🧪 === TESTE DE COLUNA GERADA ===');
    
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Usuário não autenticado');
        return;
      }

      // Tentar atualizar photo_url diretamente (deve falhar ou ser ignorado)
      debugPrint('1️⃣ Tentando atualizar photo_url diretamente...');
      
      try {
        await _client
            .from('profiles')
            .update({
              'photo_url': 'https://exemplo.com/nova-foto.jpg',
            })
            .eq('id', userId);
        
        debugPrint('⚠️ Update de photo_url não gerou erro (pode ter sido ignorado)');
      } catch (e) {
        debugPrint('❌ Erro esperado ao tentar atualizar photo_url: $e');
      }

      // Atualizar profile_image_url (deve funcionar)
      debugPrint('2️⃣ Atualizando profile_image_url...');
      
      final newImageUrl = 'https://exemplo.com/foto-${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _client
          .from('profiles')
          .update({
            'profile_image_url': newImageUrl,
          })
          .eq('id', userId);

      await Future.delayed(const Duration(milliseconds: 1000));

      final result = await _getCurrentProfile(userId);
      
      debugPrint('📋 Resultado:');
      debugPrint('   - profile_image_url: "${result?['profile_image_url']}"');
      debugPrint('   - photo_url: "${result?['photo_url']}"');
      
      if (result?['profile_image_url'] == newImageUrl) {
        debugPrint('✅ profile_image_url atualizado corretamente');
      } else {
        debugPrint('❌ profile_image_url não foi atualizado');
      }
      
      if (result?['photo_url'] == newImageUrl) {
        debugPrint('✅ photo_url foi gerado corretamente');
      } else {
        debugPrint('❌ photo_url não reflete profile_image_url');
      }

    } catch (e) {
      debugPrint('❌ Erro no teste de coluna gerada: $e');
    }
  }
} 