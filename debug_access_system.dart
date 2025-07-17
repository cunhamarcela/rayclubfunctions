import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ray_club_app/core/di/providers.dart';
import 'package:ray_club_app/features/subscription/providers/subscription_providers.dart';
import 'package:ray_club_app/features/subscription/models/subscription_status.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase com suas credenciais
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  
  runApp(const DebugAccessApp());
}

class DebugAccessApp extends StatelessWidget {
  const DebugAccessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'Debug Access System',
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
  String debugInfo = 'Carregando...';
  
  @override
  void initState() {
    super.initState();
    _runDebug();
  }
  
  Future<void> _runDebug() async {
    final buffer = StringBuffer();
    
    try {
      // 1. Verificar usuário atual
      final user = Supabase.instance.client.auth.currentUser;
      buffer.writeln('=== USUÁRIO ATUAL ===');
      buffer.writeln('ID: ${user?.id}');
      buffer.writeln('Email: ${user?.email}');
      buffer.writeln('');
      
      // 2. Verificar dados direto do Supabase
      buffer.writeln('=== DADOS DO SUPABASE ===');
      
      // Buscar na tabela user_progress_level
      final progressData = await Supabase.instance.client
          .from('user_progress_level')
          .select()
          .eq('user_id', user?.id ?? '')
          .maybeSingle();
          
      buffer.writeln('user_progress_level:');
      buffer.writeln('  current_level: ${progressData?['current_level']}');
      buffer.writeln('  level_expires_at: ${progressData?['level_expires_at']}');
      buffer.writeln('  unlocked_features: ${progressData?['unlocked_features']}');
      buffer.writeln('');
      
      // 3. Testar função RPC
      buffer.writeln('=== FUNÇÃO RPC ===');
      final rpcResult = await Supabase.instance.client
          .rpc('check_user_access_level', params: {
            'user_id_param': user?.id ?? ''
          });
      
      buffer.writeln('Resultado RPC:');
      buffer.writeln('  has_extended_access: ${rpcResult['has_extended_access']}');
      buffer.writeln('  access_level: ${rpcResult['access_level']}');
      buffer.writeln('  available_features: ${rpcResult['available_features']}');
      buffer.writeln('');
      
      // 4. Verificar providers do app
      buffer.writeln('=== PROVIDERS DO APP ===');
      
      // Verificar UserAccessStatus
      final accessStatus = await ref.read(currentUserAccessProvider.future);
      buffer.writeln('UserAccessStatus:');
      buffer.writeln('  userId: ${accessStatus.userId}');
      buffer.writeln('  hasExtendedAccess: ${accessStatus.hasExtendedAccess}');
      buffer.writeln('  accessLevel: ${accessStatus.accessLevel}');
      buffer.writeln('  isExpert: ${accessStatus.isExpert}');
      buffer.writeln('  isBasic: ${accessStatus.isBasic}');
      buffer.writeln('  availableFeatures: ${accessStatus.availableFeatures}');
      buffer.writeln('');
      
      // 5. Testar acesso a features específicas
      buffer.writeln('=== TESTE DE FEATURES ===');
      final features = [
        'enhanced_dashboard',
        'nutrition_guide',
        'workout_library',
        'detailed_reports',
        'basic_workouts',
        'profile',
        'basic_challenges',
        'workout_recording'
      ];
      
      for (final feature in features) {
        final hasAccess = await ref.read(featureAccessProvider(feature).future);
        buffer.writeln('  $feature: ${hasAccess ? "✅ PERMITIDO" : "❌ BLOQUEADO"}');
      }
      buffer.writeln('');
      
      // 6. Verificar configuração do app
      buffer.writeln('=== CONFIGURAÇÃO DO APP ===');
      final appConfig = ref.read(appConfigProvider);
      buffer.writeln('  safeMode: ${appConfig.safeMode}');
      buffer.writeln('  progressGatesEnabled: ${appConfig.progressGatesEnabled}');
      
    } catch (e, stack) {
      buffer.writeln('ERRO: $e');
      buffer.writeln('Stack: $stack');
    }
    
    setState(() {
      debugInfo = buffer.toString();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Access System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDebug,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          debugInfo,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
          ),
        ),
      ),
    );
  }
} 