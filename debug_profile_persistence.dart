import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script de diagnóstico para verificar a persistência de dados do perfil
class ProfilePersistenceDiagnostic {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Teste completo de persistência do perfil
  static Future<void> runFullDiagnostic() async {
    debugPrint('🔍 === DIAGNÓSTICO DE PERSISTÊNCIA DO PERFIL ===');
    
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ Usuário não autenticado');
        return;
      }

      debugPrint('👤 User ID: $userId');

      // 1. Ler dados atuais
      debugPrint('\n1️⃣ Lendo dados atuais do perfil...');
      final currentData = await _readProfile(userId);
      if (currentData == null) {
        debugPrint('❌ Perfil não encontrado');
        return;
      }

      debugPrint('📋 Dados atuais:');
      debugPrint('   - Nome: "${currentData['name']}"');
      debugPrint('   - Telefone: "${currentData['phone']}"');
      debugPrint('   - Instagram: "${currentData['instagram']}"');
      debugPrint('   - Gênero: "${currentData['gender']}"');

      // 2. Fazer uma atualização de teste
      debugPrint('\n2️⃣ Fazendo update de teste...');
      final testName = 'TESTE_${DateTime.now().millisecondsSinceEpoch}';
      final updateResult = await _updateProfile(userId, {'name': testName});
      
      if (updateResult) {
        debugPrint('✅ Update executado com sucesso');
      } else {
        debugPrint('❌ Falha no update');
        return;
      }

      // 3. Verificar se foi persistido
      debugPrint('\n3️⃣ Verificando se dados foram persistidos...');
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final updatedData = await _readProfile(userId);
      if (updatedData == null) {
        debugPrint('❌ Perfil não encontrado após update');
        return;
      }

      debugPrint('📋 Dados após update:');
      debugPrint('   - Nome: "${updatedData['name']}"');
      debugPrint('   - Telefone: "${updatedData['phone']}"');
      debugPrint('   - Instagram: "${updatedData['instagram']}"');
      debugPrint('   - Gênero: "${updatedData['gender']}"');

      if (updatedData['name'] == testName) {
        debugPrint('✅ Dados persistidos corretamente!');
      } else {
        debugPrint('❌ PROBLEMA: Dados não foram persistidos!');
        debugPrint('   - Esperado: "$testName"');
        debugPrint('   - Encontrado: "${updatedData['name']}"');
      }

      // 4. Restaurar dados originais
      debugPrint('\n4️⃣ Restaurando dados originais...');
      final restoreResult = await _updateProfile(userId, {
        'name': currentData['name'],
        'phone': currentData['phone'],
        'instagram': currentData['instagram'],
        'gender': currentData['gender'],
      });

      if (restoreResult) {
        debugPrint('✅ Dados restaurados');
      } else {
        debugPrint('❌ Falha ao restaurar dados');
      }

      // 5. Verificar triggers
      debugPrint('\n5️⃣ Verificando triggers ativos...');
      await _checkTriggers();

      // 6. Verificar RLS
      debugPrint('\n6️⃣ Verificando políticas RLS...');
      await _checkRLS();

    } catch (e, stackTrace) {
      debugPrint('❌ Erro no diagnóstico: $e');
      debugPrint('Stack trace: $stackTrace');
    }

    debugPrint('\n🔍 === FIM DO DIAGNÓSTICO ===');
  }

  /// Ler dados do perfil
  static Future<Map<String, dynamic>?> _readProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, name, phone, instagram, gender, updated_at')
          .eq('id', userId)
          .single();
      
      return response;
    } catch (e) {
      debugPrint('❌ Erro ao ler perfil: $e');
      return null;
    }
  }

  /// Atualizar perfil
  static Future<bool> _updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      final updateData = {
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _client
          .from('profiles')
          .update(updateData)
          .eq('id', userId);
      
      return true;
    } catch (e) {
      debugPrint('❌ Erro ao atualizar perfil: $e');
      return false;
    }
  }

  /// Verificar triggers ativos
  static Future<void> _checkTriggers() async {
    try {
      final response = await _client.rpc('check_profile_triggers');
      debugPrint('📋 Triggers encontrados: $response');
    } catch (e) {
      debugPrint('⚠️ Não foi possível verificar triggers: $e');
    }
  }

  /// Verificar políticas RLS
  static Future<void> _checkRLS() async {
    try {
      final response = await _client.rpc('check_profile_policies');
      debugPrint('📋 Políticas RLS encontradas: $response');
    } catch (e) {
      debugPrint('⚠️ Não foi possível verificar RLS: $e');
    }
  }

  /// Teste rápido de persistência
  static Future<bool> quickPersistenceTest() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      // Ler dados atuais
      final currentData = await _readProfile(userId);
      if (currentData == null) return false;

      // Fazer update de teste
      final testValue = 'TEST_${DateTime.now().millisecondsSinceEpoch}';
      final updateSuccess = await _updateProfile(userId, {'name': testValue});
      if (!updateSuccess) return false;

      // Verificar persistência
      await Future.delayed(const Duration(milliseconds: 500));
      final updatedData = await _readProfile(userId);
      if (updatedData == null) return false;

      final isPersisted = updatedData['name'] == testValue;

      // Restaurar dados
      await _updateProfile(userId, {'name': currentData['name']});

      return isPersisted;
    } catch (e) {
      debugPrint('❌ Erro no teste rápido: $e');
      return false;
    }
  }
} 