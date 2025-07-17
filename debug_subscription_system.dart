import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ray_club_app/features/subscription/models/subscription_status.dart';
import 'package:ray_club_app/features/subscription/providers/subscription_providers.dart';
import 'package:ray_club_app/features/subscription/repositories/subscription_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  runApp(const DebugApp());
}

class DebugApp extends StatelessWidget {
  const DebugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Debug Subscription System',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const DebugScreen(),
      ),
    );
  }
}

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  Map<String, dynamic>? rawSupabaseResponse;
  UserAccessStatus? parsedStatus;
  String? errorMessage;
  bool isLoading = false;

  Future<void> _testDirectSupabaseCall() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      rawSupabaseResponse = null;
      parsedStatus = null;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          errorMessage = 'Usuário não autenticado';
          isLoading = false;
        });
        return;
      }

      // Chamada direta ao Supabase
      final response = await Supabase.instance.client.rpc(
        'check_user_access_level',
        params: {'user_id_param': user.id},
      );

      setState(() {
        rawSupabaseResponse = response as Map<String, dynamic>?;
      });

      // Tentar parsear a resposta
      if (response != null) {
        final status = UserAccessStatus.fromJson(response as Map<String, dynamic>);
        setState(() {
          parsedStatus = status;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAccess = ref.watch(currentUserAccessProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Sistema de Assinatura'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status do Provider
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status do Provider (Riverpod)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    userAccess.when(
                      data: (status) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('✅ User ID: ${status.userId}'),
                          Text('✅ Access Level: ${status.accessLevel ?? "null"}'),
                          Text('✅ Has Extended Access: ${status.hasExtendedAccess}'),
                          Text('✅ Features: ${status.availableFeatures.join(", ")}'),
                          const SizedBox(height: 8),
                          Text(
                            'Interpretação: ${status.accessLevel == "expert" ? "PREMIUM" : "BASIC"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: status.accessLevel == "expert" ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('❌ Erro: $error'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Teste direto do Supabase
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Teste Direto Supabase',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: isLoading ? null : _testDirectSupabaseCall,
                          child: const Text('Testar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (isLoading)
                      const Center(child: CircularProgressIndicator()),
                    
                    if (errorMessage != null)
                      Text(
                        '❌ $errorMessage',
                        style: const TextStyle(color: Colors.red),
                      ),
                    
                    if (rawSupabaseResponse != null) ...[
                      const Text(
                        'Resposta Bruta do Supabase:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          rawSupabaseResponse.toString(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                    
                    if (parsedStatus != null) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Status Parseado:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('User ID: ${parsedStatus!.userId}'),
                      Text('Access Level: ${parsedStatus!.accessLevel}'),
                      Text('Has Extended Access: ${parsedStatus!.hasExtendedAccess}'),
                      Text('Features: ${parsedStatus!.availableFeatures}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Verificação de Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Verificação de Features',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...[
                      'basic_workouts',
                      'profile',
                      'basic_challenges',
                      'workout_recording',
                      'enhanced_dashboard',
                      'nutrition_guide',
                      'workout_library',
                      'advanced_tracking',
                      'detailed_reports',
                    ].map((feature) {
                      final hasAccess = ref.watch(featureAccessProvider(feature));
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            hasAccess.when(
                              data: (access) => Icon(
                                access ? Icons.check_circle : Icons.cancel,
                                color: access ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              loading: () => const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              error: (_, __) => const Icon(
                                Icons.error,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(feature),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informações de Debug
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔍 Informações de Debug',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Para que o bloqueio funcione corretamente:'),
                    const SizedBox(height: 4),
                    const Text('1. A função check_user_access_level deve retornar:'),
                    const Text('   - access_level: "basic" ou "expert"'),
                    const Text('   - has_extended_access: true para expert, false para basic'),
                    const Text('   - available_features: array com as features permitidas'),
                    const SizedBox(height: 8),
                    const Text('2. Features para BASIC:'),
                    const Text('   - basic_workouts, profile, basic_challenges, workout_recording'),
                    const SizedBox(height: 8),
                    const Text('3. Features para EXPERT:'),
                    const Text('   - Todas as do basic + enhanced_dashboard, nutrition_guide,'),
                    const Text('     workout_library, advanced_tracking, detailed_reports'),
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