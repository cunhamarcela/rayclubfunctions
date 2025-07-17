// Debug file para investigar problemas de navegação
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

// Imports do projeto
import 'package:ray_club_app/core/router/app_router.dart';

void main() {
  runApp(const DebugNavigationApp());
}

class DebugNavigationApp extends StatelessWidget {
  const DebugNavigationApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        home: const DebugScreen(),
      ),
    );
  }
}

class DebugScreen extends ConsumerWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Navigation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Teste 1: Verificar se a rota existe
            ElevatedButton(
              onPressed: () {
                try {
                  print('🔍 DEBUG: Testando navegação direta para WorkoutHistoryRoute');
                  // Tentar navegar diretamente
                  context.pushRoute(const WorkoutHistoryRoute());
                  print('✅ DEBUG: Navegação iniciada com sucesso');
                } catch (e, stackTrace) {
                  print('❌ DEBUG: Erro na navegação: $e');
                  print('❌ DEBUG: Stack trace: $stackTrace');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro na navegação: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Teste 1: NavegaçãoDireta'),
            ),
            
            const SizedBox(height: 16),
            
            // Teste 2: Verificar se o path funciona
            ElevatedButton(
              onPressed: () {
                try {
                  print('🔍 DEBUG: Testando navegação por path');
                  context.router.pushNamed('/workouts/history');
                  print('✅ DEBUG: Navegação por path iniciada');
                } catch (e, stackTrace) {
                  print('❌ DEBUG: Erro na navegação por path: $e');
                  print('❌ DEBUG: Stack trace: $stackTrace');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro na navegação por path: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Teste 2: Navegação por Path'),
            ),
            
            const SizedBox(height: 16),
            
            // Teste 3: Verificar se o problema é AuthGuard
            ElevatedButton(
              onPressed: () {
                print('🔍 DEBUG: Verificando se existe AuthGuard bloqueando');
                // Simular o que o AuthGuard faria
                try {
                  // Ir para uma tela que não tem AuthGuard
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const TestWorkoutHistoryScreen(),
                    ),
                  );
                  print('✅ DEBUG: Navegação manual funcionou');
                } catch (e) {
                  print('❌ DEBUG: Erro na navegação manual: $e');
                }
              },
              child: const Text('Teste 3: Navegação Manual'),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Verifique o console para logs de debug',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// Tela simples para testar se o problema é a tela em si
class TestWorkoutHistoryScreen extends StatelessWidget {
  const TestWorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste - Histórico de Treinos'),
        backgroundColor: Colors.orange,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'SUCESSO!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'A navegação funcionou.\nO problema não é a tela de destino.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 