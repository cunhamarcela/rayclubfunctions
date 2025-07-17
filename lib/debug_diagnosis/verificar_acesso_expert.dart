import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import '../features/subscription/providers/subscription_providers.dart';
import '../features/subscription/models/subscription_status.dart';

/// Widget de debug para verificar se usuário expert tem acesso completo
@RoutePage()
class VerificarAcessoExpertScreen extends ConsumerStatefulWidget {
  const VerificarAcessoExpertScreen({super.key});

  @override
  ConsumerState<VerificarAcessoExpertScreen> createState() => _VerificarAcessoExpertScreenState();
}

class _VerificarAcessoExpertScreenState extends ConsumerState<VerificarAcessoExpertScreen> {
  String? debugInfo;
  bool isLoading = false;

  /// Lista de todas as features que devem estar disponíveis para expert
  final List<String> expertFeatures = [
    'basic_workouts',
    'profile',
    'basic_challenges',
    'workout_recording',
    'enhanced_dashboard',
    'nutrition_guide',
    'workout_library',
    'advanced_tracking',
    'detailed_reports',
  ];

  @override
  void initState() {
    super.initState();
    _verificarAcesso();
  }

  Future<void> _verificarAcesso() async {
    setState(() {
      isLoading = true;
      debugInfo = null;
    });

    final buffer = StringBuffer();
    
    try {
      buffer.writeln('🔍 VERIFICAÇÃO DE ACESSO EXPERT');
      buffer.writeln('=' * 50);
      buffer.writeln('');

      // 1. Verificar status do usuário
      final userAccessAsync = ref.read(currentUserAccessProvider);
      
      late UserAccessStatus userAccess;
      await userAccessAsync.when(
        data: (status) async {
          userAccess = status;
        },
        loading: () async {
          throw Exception('Ainda carregando dados do usuário');
        },
        error: (error, stack) async {
          throw Exception('Erro ao carregar dados: $error');
        },
      );
      
      buffer.writeln('📋 STATUS DO USUÁRIO:');
      buffer.writeln('  User ID: ${userAccess.userId}');
      buffer.writeln('  Access Level: ${userAccess.accessLevel}');
      buffer.writeln('  Has Extended Access: ${userAccess.hasExtendedAccess}');
      buffer.writeln('  Is Expert: ${userAccess.isExpert}');
      buffer.writeln('  Is Basic: ${userAccess.isBasic}');
      buffer.writeln('  Valid Until: ${userAccess.validUntil ?? "PERMANENTE"}');
      buffer.writeln('  Last Verified: ${userAccess.lastVerified}');
      buffer.writeln('');

      // 2. Verificar features disponíveis
      buffer.writeln('🎯 FEATURES DISPONÍVEIS:');
      buffer.writeln('  Total: ${userAccess.availableFeatures.length}');
      buffer.writeln('  Features: ${userAccess.availableFeatures.join(", ")}');
      buffer.writeln('');

      // 3. Verificar cada feature individualmente
      buffer.writeln('✅ TESTE DE ACESSO POR FEATURE:');
      int featuresLiberadas = 0;
      
      for (final feature in expertFeatures) {
        try {
          final featureAccessAsyncValue = ref.read(featureAccessProvider(feature));
          final hasAccess = featureAccessAsyncValue.when(
            data: (access) => access,
            loading: () => false,
            error: (error, stack) => false,
          );
          
          final status = hasAccess ? "✅ LIBERADO" : "❌ BLOQUEADO";
          buffer.writeln('  $feature: $status');
          
          if (hasAccess) featuresLiberadas++;
        } catch (e) {
          buffer.writeln('  $feature: ❌ ERRO - $e');
        }
      }
      
      buffer.writeln('');
      buffer.writeln('📊 RESUMO:');
      buffer.writeln('  Features liberadas: $featuresLiberadas/${expertFeatures.length}');
      
      // 4. Verificar configuração do app
      final appConfig = ref.read(appConfigProvider);
      buffer.writeln('');
      buffer.writeln('⚙️ CONFIGURAÇÃO DO APP:');
      buffer.writeln('  Safe Mode: ${appConfig.safeMode}');
      buffer.writeln('  Progress Gates Enabled: ${appConfig.progressGatesEnabled}');
      
      // 5. Diagnóstico final
      buffer.writeln('');
      buffer.writeln('🎯 DIAGNÓSTICO FINAL:');
      
      if (userAccess.isExpert && featuresLiberadas == expertFeatures.length) {
        buffer.writeln('  ✅ SUCESSO: Usuário expert com acesso completo!');
      } else if (userAccess.isExpert && featuresLiberadas < expertFeatures.length) {
        buffer.writeln('  ⚠️ ATENÇÃO: Usuário expert mas algumas features bloqueadas');
        buffer.writeln('  💡 Solução: Execute promover_usuario_expert.sql no Supabase');
      } else if (!userAccess.isExpert) {
        buffer.writeln('  ❌ PROBLEMA: Usuário não é expert');
        buffer.writeln('  💡 Solução: Execute promote_to_expert_permanent() no Supabase');
      }
      
      // 6. Recomendações
      buffer.writeln('');
      buffer.writeln('💡 PRÓXIMOS PASSOS:');
      
      if (appConfig.safeMode) {
        buffer.writeln('  - Safe Mode está ATIVO (todos os bloqueios desabilitados)');
      }
      
      if (!appConfig.progressGatesEnabled) {
        buffer.writeln('  - Progress Gates estão DESABILITADOS');
      }
      
      if (userAccess.isExpert && featuresLiberadas == expertFeatures.length) {
        buffer.writeln('  - ✅ Tudo funcionando perfeitamente!');
        buffer.writeln('  - Usuário pode acessar todas as features sem restrição');
      } else {
        buffer.writeln('  - Execute o script SQL de correção no Supabase');
        buffer.writeln('  - Faça hot restart do app após mudanças no banco');
        buffer.writeln('  - Verifique logs do console para mais detalhes');
      }

    } catch (e, stack) {
      buffer.writeln('❌ ERRO NA VERIFICAÇÃO:');
      buffer.writeln('  Erro: $e');
      buffer.writeln('  Stack: $stack');
    }

    setState(() {
      debugInfo = buffer.toString();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar Acesso Expert'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _verificarAcesso,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header com instruções
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Verificação de Acesso Expert',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Esta tela verifica se o usuário expert tem acesso completo a todas as features do app.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botão de verificação
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _verificarAcesso,
                icon: isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.security),
                label: Text(isLoading ? 'Verificando...' : 'Verificar Acesso'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Resultado da verificação
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: debugInfo != null
                      ? SingleChildScrollView(
                          child: SelectableText(
                            debugInfo!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        )
                      : const Center(
                          child: Text(
                            'Clique em "Verificar Acesso" para iniciar a verificação',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            
            // Footer com comandos SQL
            Card(
              color: Colors.orange.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.code, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Comandos SQL Úteis',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• Promover para expert: SELECT promote_to_expert_permanent(\'user-id\');',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                    const Text(
                      '• Verificar status: SELECT check_user_access_level(\'user-id\');',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                    const Text(
                      '• Garantir acesso: SELECT ensure_expert_access(\'user-id\');',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 