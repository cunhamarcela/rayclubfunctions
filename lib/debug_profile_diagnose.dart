import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auto_route/auto_route.dart';
import 'providers/user_profile_provider.dart' as profile_providers;
import 'features/workout/providers/user_access_provider.dart';
import 'features/profile/models/profile_model.dart';
import 'core/services/expert_video_guard.dart';

/// Provider para dados crus do banco (debug)
final rawProfileDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;

  final data = await Supabase.instance.client
      .from('profiles')
      .select('id, name, email, account_type, created_at, updated_at')
      .eq('id', userId)
      .maybeSingle();

  return data;
});

@RoutePage()
class DebugProfileDiagnoseScreen extends ConsumerWidget {
  const DebugProfileDiagnoseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔍 DIAGNÓSTICO COMPLETO')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔍 DIAGNÓSTICO COMPLETO - EXPERT/BASIC', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            
            // === USUÁRIO ATUAL ===
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('👤 USUÁRIO ATUAL', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('User ID: ${Supabase.instance.client.auth.currentUser?.id ?? "NENHUM"}'),
                    Text('Email: ${Supabase.instance.client.auth.currentUser?.email ?? "NENHUM"}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // === DADOS CRUS DO BANCO ===
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🗄️ DADOS CRUS DO BANCO', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    Consumer(
                      builder: (context, ref, _) {
                        final rawDataAsync = ref.watch(rawProfileDataProvider);
                        return rawDataAsync.when(
                          data: (rawData) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('✅ Dados crus do banco:'),
                              if (rawData != null) ...[
                                Text('  📱 ID: ${rawData['id']}'),
                                Text('  📧 Email: ${rawData['email']}'),
                                Text('  👤 Nome: ${rawData['name']}'),
                                Text('  🎯 account_type (RAW): "${rawData['account_type']}"'),
                                Text('  📅 Created: ${rawData['created_at']}'),
                                Text('  📅 Updated: ${rawData['updated_at']}'),
                                const SizedBox(height: 10),
                                Text('🔍 ANÁLISE DOS DADOS CRUS:'),
                                Text('  • Campo account_type existe? ${rawData.containsKey('account_type') ? 'SIM' : 'NÃO'}'),
                                Text('  • Valor: "${rawData['account_type']}"'),
                                Text('  • Tipo: ${rawData['account_type'].runtimeType}'),
                                Text('  • É expert? ${rawData['account_type'] == 'expert' ? 'SIM ✅' : 'NÃO ❌'}'),
                              ] else ...[
                                const Text('❌ Dados não encontrados'),
                              ],
                            ],
                          ),
                          loading: () => const Text('⏳ Carregando dados crus...'),
                          error: (error, stack) => Text('❌ Erro nos dados crus: $error'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // === NOVO SISTEMA ===
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🆕 NOVO SISTEMA (userProfileProvider)', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    // userProfileProvider
                    Consumer(
                      builder: (context, ref, _) {
                        final profileAsync = ref.watch(profile_providers.userProfileProvider);
                        return profileAsync.when(
                          data: (profile) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('✅ userProfileProvider - Profile object:'),
                              Text('  📧 Email: ${profile?.email ?? "null"}'),
                              Text('  👤 Nome: ${profile?.name ?? "null"}'),
                              Text('  🎯 accountType (PROCESSADO): "${profile?.accountType ?? "null"}"'),
                              Text('  📱 ID: ${profile?.id ?? "null"}'),
                              const SizedBox(height: 8),
                              Text('🔍 ANÁLISE DO PROFILE OBJECT:'),
                              Text('  • Profile é null? ${profile == null ? 'SIM' : 'NÃO'}'),
                              if (profile != null) ...[
                                Text('  • accountType existe? SIM'),
                                Text('  • accountType value: "${profile.accountType}"'),
                                Text('  • accountType type: ${profile.accountType.runtimeType}'),
                                Text('  • É expert? ${profile.accountType == 'expert' ? 'SIM ✅' : 'NÃO ❌'}'),
                              ],
                            ],
                          ),
                          loading: () => const Text('⏳ userProfileProvider - Carregando...'),
                          error: (error, stack) => Text('❌ userProfileProvider - Erro: $error'),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    
                    // isExpertUserProvider (novo)
                    Consumer(
                      builder: (context, ref, _) {
                                                    final isExpertAsync = ref.watch(profile_providers.isExpertUserProfileProvider);
                        return isExpertAsync.when(
                          data: (isExpert) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('✅ isExpertUserProvider (NOVO): $isExpert'),
                              Text('  🎯 Resultado: ${isExpert ? "EXPERT ✅" : "BASIC ❌"}'),
                              Text('  📊 Tipo: ${isExpert.runtimeType}'),
                            ],
                          ),
                          loading: () => const Text('⏳ isExpertUserProvider - Carregando...'),
                          error: (error, stack) => Text('❌ isExpertUserProvider - Erro: $error'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // === SISTEMA ANTIGO ===
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔄 SISTEMA ANTIGO (userLevelProvider)', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    // userLevelProvider (antigo)
                    Consumer(
                      builder: (context, ref, _) {
                        final userLevelAsync = ref.watch(userLevelProvider);
                        return userLevelAsync.when(
                          data: (level) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('✅ userLevelProvider (ANTIGO): "$level"'),
                              Text('  🎯 Resultado: ${level == "expert" ? "EXPERT ✅" : "BASIC ❌"}'),
                              Text('  📊 Tipo: ${level.runtimeType}'),
                            ],
                          ),
                          loading: () => const Text('⏳ userLevelProvider - Carregando...'),
                          error: (error, stack) => Text('❌ userLevelProvider - Erro: $error'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // === TESTE DIRETO BANCO ===
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🗄️ TESTE DIRETO DO BANCO', 
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    ElevatedButton(
                      onPressed: () async {
                        await _testDirectDatabase(context);
                      },
                      child: const Text('🔍 Verificar Banco Diretamente'),
                    ),
                    const SizedBox(height: 10),
                    
                    ElevatedButton(
                      onPressed: () async {
                        await _testProfileFromJson(context, ref);
                      },
                      child: const Text('🧪 Testar Profile.fromJson()'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // === BOTÕES DE AÇÃO ===
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔄 AÇÕES', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                                                            ref.invalidate(profile_providers.userProfileProvider);
                            ref.invalidate(rawProfileDataProvider);
                          },
                          child: const Text('🔄 Refresh Novo'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            ref.invalidate(userLevelProvider);
                          },
                          child: const Text('🔄 Refresh Antigo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // 🧪 TESTE DE CLIQUE EM VÍDEO
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🧪 TESTE DE CLIQUE EM VÍDEO', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    
                    ElevatedButton(
                      onPressed: () async {
                        print('🧪 [DEBUG] Testando clique em vídeo...');
                        
                        try {
                          // Simular um vídeo qualquer
                          final testVideoId = 'test-video-123';
                          
                          // Testar canPlayVideo
                          final canPlay = await ExpertVideoGuard.canPlayVideo(ref, testVideoId);
                          print('🧪 [DEBUG] canPlayVideo result: $canPlay');
                          
                          if (canPlay) {
                            print('🧪 [DEBUG] ✅ Usuário pode assistir vídeos!');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Teste PASSOU - Usuário pode assistir vídeos'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            print('🧪 [DEBUG] ❌ Usuário NÃO pode assistir vídeos');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ Teste FALHOU - Usuário não pode assistir vídeos'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          print('🧪 [DEBUG] ERRO no teste: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ERRO no teste: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('🧪 Testar Clique em Vídeo'),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    ElevatedButton(
                      onPressed: () async {
                        print('🧪 [DEBUG] Testando handleVideoTap...');
                        
                        try {
                          await ExpertVideoGuard.handleVideoTap(
                            context,
                            ref, 
                            'test-video-456',
                            () {
                              print('🧪 [DEBUG] ✅ onAllowed() foi chamado!');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ onAllowed() executado com sucesso!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          );
                        } catch (e) {
                          print('🧪 [DEBUG] ERRO no handleVideoTap: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('❌ ERRO no handleVideoTap: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('🧪 Testar handleVideoTap'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 🎬 TESTE ESPECÍFICO DE CLIQUE NA HOME
            ElevatedButton(
              onPressed: () async {
                debugPrint('🎬 [DEBUG] ========== TESTE ESPECÍFICO ==========');
                debugPrint('🎬 [DEBUG] Vá para a HOME SCREEN e clique em qualquer vídeo');
                debugPrint('🎬 [DEBUG] Procure por estes logs:');
                debugPrint('🎬 [DEBUG] - 🎯 [handleVideoTap] Iniciando verificação');
                debugPrint('🎬 [DEBUG] - 🎬 [_openVideoPlayer] Abrindo player');
                debugPrint('🎬 [DEBUG] ========================================');
                
                Navigator.of(context).pushReplacementNamed('/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('🎬 IR PARA HOME E TESTAR CLIQUE'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testProfileFromJson(BuildContext context, WidgetRef ref) async {
    try {
      final rawDataAsync = ref.read(rawProfileDataProvider);
      
      await rawDataAsync.when(
        data: (rawData) async {
          if (rawData == null) {
            _showResult(context, '❌ Dados crus não encontrados');
            return;
          }

          // Teste Profile.fromJson diretamente
          final profile = Profile.fromJson(rawData);
          
          _showResult(context, '''
🧪 TESTE PROFILE.fromJSON():

📦 DADOS DE ENTRADA:
${rawData.entries.map((e) => '  • ${e.key}: "${e.value}" (${e.value.runtimeType})').join('\n')}

📊 PROFILE CRIADO:
  • ID: "${profile.id}"
  • Name: "${profile.name}"
  • Email: "${profile.email}"
  • accountType: "${profile.accountType}"
  • accountType tipo: ${profile.accountType.runtimeType}

🔍 VERIFICAÇÕES:
  • Profile criado com sucesso? SIM ✅
  • accountType preenchido? ${profile.accountType.isNotEmpty ? 'SIM ✅' : 'NÃO ❌'}
  • É expert? ${profile.accountType == 'expert' ? 'SIM ✅' : 'NÃO ❌'}
  • Comparação direta: "${profile.accountType}" == "expert" = ${profile.accountType == 'expert'}
          ''');
        },
        loading: () async {
          _showResult(context, '⏳ Aguardando dados crus...');
        },
        error: (error, stack) async {
          _showResult(context, '❌ Erro nos dados crus: $error');
        },
      );

    } catch (e) {
      _showResult(context, '❌ Erro ao testar Profile.fromJson(): $e');
    }
  }

  Future<void> _testDirectDatabase(BuildContext context) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _showResult(context, '❌ Usuário não logado');
        return;
      }

      // Teste 1: Verificar se a tabela profiles tem o campo account_type
      final result = await Supabase.instance.client
          .from('profiles')
          .select('id, name, email, account_type')
          .eq('id', userId)
          .maybeSingle();

      if (result == null) {
        _showResult(context, '❌ Perfil não encontrado na tabela profiles');
        return;
      }

      final accountType = result['account_type'];
      
      _showResult(context, '''
✅ RESULTADO DO BANCO:
📧 Email: ${result['email'] ?? 'null'}
👤 Nome: ${result['name'] ?? 'null'} 
🎯 Account Type: "$accountType"
📱 User ID: ${result['id']}

🔍 ANÁLISE:
• Campo account_type existe? ${result.containsKey('account_type') ? 'SIM' : 'NÃO'}
• Valor: ${accountType ?? 'NULL'}
• É expert? ${accountType == 'expert' ? 'SIM ✅' : 'NÃO ❌'}
      ''');

    } catch (e) {
      _showResult(context, '❌ Erro ao consultar banco: $e');
    }
  }

  void _showResult(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 Resultado do Teste'),
        content: SingleChildScrollView(
          child: SelectableText(message),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 