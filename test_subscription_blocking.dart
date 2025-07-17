import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/subscription/models/subscription_status.dart';
import 'package:ray_club_app/features/subscription/providers/subscription_providers.dart';
import 'package:ray_club_app/features/subscription/widgets/premium_feature_gate.dart';

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Test Subscription Blocking',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const TestScreen(),
      ),
    );
  }
}

class TestScreen extends ConsumerWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAccess = ref.watch(currentUserAccessProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste de Bloqueio de Conteúdo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status do usuário
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status do Usuário',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    userAccess.when(
                      data: (status) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('User ID: ${status.userId}'),
                          Text('Access Level: ${status.accessLevel ?? "basic"}'),
                          Text('Has Extended Access: ${status.hasExtendedAccess}'),
                          Text('Features: ${status.availableFeatures.join(", ")}'),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Erro: $error'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Teste Dashboard Enhanced
            const Text(
              'Dashboard Enhanced',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ProgressGate(
              featureKey: 'enhanced_dashboard',
              progressTitle: 'Dashboard Avançado',
              progressDescription: 'Complete mais treinos para desbloquear.',
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade100,
                child: const Text('✅ Dashboard Enhanced Desbloqueado!'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Teste Nutrição
            const Text(
              'Nutrição',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ProgressGate(
              featureKey: 'nutrition_guide',
              progressTitle: 'Guia de Nutrição',
              progressDescription: 'Evolua no app para acessar receitas e vídeos.',
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade100,
                child: const Text('✅ Nutrição Desbloqueada!'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Teste Biblioteca de Treinos
            const Text(
              'Biblioteca de Treinos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ProgressGate(
              featureKey: 'workout_library',
              progressTitle: 'Biblioteca Completa',
              progressDescription: 'Mantenha sua consistência para desbloquear.',
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.green.shade100,
                child: const Text('✅ Biblioteca de Treinos Desbloqueada!'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Teste de Features Individuais
            const Text(
              'Verificação de Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...['enhanced_dashboard', 'nutrition_guide', 'workout_library', 'advanced_tracking', 'detailed_reports'].map(
              (feature) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final hasAccess = ref.watch(featureAccessProvider(feature));
                        return hasAccess.when(
                          data: (access) => Icon(
                            access ? Icons.check_circle : Icons.cancel,
                            color: access ? Colors.green : Colors.red,
                          ),
                          loading: () => const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          error: (_, __) => const Icon(Icons.error, color: Colors.orange),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(feature),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botão para simular mudança de nível
            ElevatedButton(
              onPressed: () {
                // Este botão seria usado para testar a mudança de nível
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Para testar mudança de nível, altere no Supabase'),
                  ),
                );
              },
              child: const Text('Simular Mudança de Nível'),
            ),
          ],
        ),
      ),
    );
  }
} 