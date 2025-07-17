import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:auto_route/auto_route.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../core/services/expert_video_guard.dart';

/// Ferramenta de debug para verificar sistema de verificação de usuário expert/basic
/// ✅ Segue estrutura do app: features/developer/screens/
@RoutePage()
class BasicUserDebugScreen extends ConsumerWidget {
  const BasicUserDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Debug: Basic User'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧪 FERRAMENTA DE DEBUG DO SISTEMA DE VERIFICAÇÃO',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta ferramenta verifica se o sistema está corretamente bloqueando usuários basic e liberando expert.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Card 1: Informações do Auth
            _buildAuthInfoCard(),
            const SizedBox(height: 16),
            
            // Card 2: Informações do Perfil
            _buildProfileInfoCard(ref),
            const SizedBox(height: 16),
            
            // Card 3: Verificação Expert
            _buildExpertVerificationCard(ref),
            const SizedBox(height: 16),
            
            // Card 4: Testes de Acesso
            _buildAccessTestsCard(ref, context),
            const SizedBox(height: 16),
            
            // Card 5: Simulação de Usuário Basic
            _buildBasicUserSimulationCard(context),
            const SizedBox(height: 16),
            
            // Card 6: Ações de Debug
            _buildDebugActionsCard(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔐 INFORMAÇÕES DE AUTENTICAÇÃO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            Consumer(
              builder: (context, ref, child) {
                final user = Supabase.instance.client.auth.currentUser;
                
                if (user == null) {
                  return const Text('❌ Usuário não autenticado');
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('✅ User ID: ${user.id}'),
                    Text('✅ Email: ${user.email}'),
                    Text('✅ Provider: ${user.appMetadata['provider'] ?? 'N/A'}'),
                    Text('✅ Created: ${user.createdAt}'),
                    Text('✅ Last Sign In: ${user.lastSignInAt}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👤 PERFIL DO USUÁRIO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            Consumer(
              builder: (context, ref, child) {
                final profileAsync = ref.watch(userProfileProvider);
                
                return profileAsync.when(
                  data: (profile) {
                    if (profile == null) {
                      return const Text('❌ Perfil não encontrado');
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✅ Nome: ${profile.name ?? 'N/A'}'),
                        Text('✅ Email: ${profile.email ?? 'N/A'}'),
                        Text('✅ ID: ${profile.id}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: profile.accountType == 'expert' 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: profile.accountType == 'expert' 
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                profile.accountType == 'expert' 
                                    ? Icons.verified_user
                                    : Icons.person,
                                color: profile.accountType == 'expert' 
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Account Type: ${profile.accountType}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: profile.accountType == 'expert' 
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('❌ Erro: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertVerificationCard(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔍 VERIFICAÇÃO EXPERT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            Consumer(
              builder: (context, ref, child) {
                final isExpertAsync = ref.watch(isExpertUserProfileProvider);
                
                return isExpertAsync.when(
                  data: (isExpert) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('✅ Verificação concluída'),
                        Text('✅ É Expert: $isExpert'),
                        Text('✅ Tipo: ${isExpert.runtimeType}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isExpert 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isExpert ? Colors.green : Colors.red,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isExpert ? Icons.check_circle : Icons.cancel,
                                color: isExpert ? Colors.green : Colors.red,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                isExpert ? 'EXPERT USER' : 'BASIC USER',
                                style: TextStyle(
                                  color: isExpert ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 12),
                      Text('Verificando...'),
                    ],
                  ),
                  error: (error, stack) => Text('❌ Erro: $error'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessTestsCard(WidgetRef ref, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧪 TESTES DE ACESSO',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      debugPrint('🧪 [TEST] ========== TESTE canPlayVideo ==========');
                      final canPlay = await ExpertVideoGuard.canPlayVideo(ref, 'test-video-123');
                      debugPrint('🧪 [TEST] Resultado: $canPlay');
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('canPlayVideo: $canPlay'),
                            backgroundColor: canPlay ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Testar canPlayVideo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      debugPrint('🧪 [TEST] ========== TESTE handleVideoTap ==========');
                      await ExpertVideoGuard.handleVideoTap(
                        context,
                        ref,
                        'test-video-456',
                        () {
                          debugPrint('🧪 [TEST] ✅ onAllowed() foi chamado - EXPERT!');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ ACESSO LIBERADO - EXPERT!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.touch_app),
                    label: const Text('Testar handleVideoTap'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      debugPrint('🧪 [TEST] ========== TESTE canAccessSync ==========');
                      final canAccess = ExpertVideoGuard.canAccessSync(ref);
                      debugPrint('🧪 [TEST] Resultado: $canAccess');
                      
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('canAccessSync: $canAccess'),
                            backgroundColor: canAccess ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.sync),
                    label: const Text('Testar canAccessSync'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicUserSimulationCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎭 SIMULAÇÃO DE USUÁRIO BASIC',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            const Text(
              'Esta simulação mostra como seria o diálogo de bloqueio para usuários basic.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  debugPrint('🎭 [SIMULATION] ========== SIMULANDO USUÁRIO BASIC ==========');
                  debugPrint('🎭 [SIMULATION] Mostrando diálogo de bloqueio...');
                  
                  await ExpertVideoGuard.showExpertRequiredDialog(context);
                  
                  debugPrint('🎭 [SIMULATION] ========== FIM DA SIMULAÇÃO ==========');
                },
                icon: const Icon(Icons.block),
                label: const Text('Simular Bloqueio Basic'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugActionsCard(WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🔧 AÇÕES DE DEBUG',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint('🔧 [DEBUG] ========== INVALIDANDO PROVIDERS ==========');
                  ref.invalidate(userProfileProvider);
                  ref.invalidate(isExpertUserProfileProvider);
                  debugPrint('🔧 [DEBUG] Providers invalidados - dados serão recarregados');
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Recarregar Dados'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint('🔧 [DEBUG] ========== ESTADO DOS PROVIDERS ==========');
                  
                  final profileAsync = ref.read(userProfileProvider);
                  final isExpertAsync = ref.read(isExpertUserProfileProvider);
                  
                  debugPrint('🔧 [DEBUG] userProfileProvider: $profileAsync');
                  debugPrint('🔧 [DEBUG] isExpertUserProfileProvider: $isExpertAsync');
                  debugPrint('🔧 [DEBUG] ===============================================');
                },
                icon: const Icon(Icons.info),
                label: const Text('Log Estado Atual'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 