// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/features/auth/models/auth_state.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

/// AuthGate é responsável por verificar o estado de autenticação do usuário
/// e redirecioná-lo para a tela apropriada (home ou login)
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    return authState.when(
      initial: () => const _LoadingScreen(),
      loading: () => const _LoadingScreen(),
      authenticated: (userId) {
        // PATCH: Corrigir bug 1 - verificar se o usuário viu o onboarding
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // Verificar nas SharedPreferences se o onboarding foi visto
          final prefs = GetIt.instance<SharedPreferences>();
          final hasSeenIntro = prefs.getBool('has_seen_intro') ?? false;
          
          if (hasSeenIntro) {
            // Se já viu o onboarding, redirecionar para a home
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            // Verificar no perfil do Supabase se há um campo onboarding_seen
            try {
              final supabase = Supabase.instance.client;
              final profile = await supabase
                  .from('profiles')
                  .select('onboarding_seen')
                  .eq('id', userId)
                  .maybeSingle();
              
              final onboardingSeen = (profile != null && profile['onboarding_seen'] == true);
              
              if (onboardingSeen) {
                // Se foi confirmado no perfil, salvar em SharedPreferences também
                await prefs.setBool('has_seen_intro', true);
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                // Se não viu onboarding em nenhum lugar, redirecionar para intro
                Navigator.pushReplacementNamed(context, '/intro');
              }
            } catch (e) {
              debugPrint('Erro ao verificar onboarding_seen: $e');
              // Em caso de erro, ir para a introdução para garantir
              Navigator.pushReplacementNamed(context, '/intro');
            }
          }
        });
        return const SizedBox.shrink();
      },
      unauthenticated: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return const SizedBox.shrink();
      },
      error: (message) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $message')),
          );
          Navigator.pushReplacementNamed(context, '/login');
        });
        return const SizedBox.shrink();
      },
    );
  }
}

/// Widget de loading exibido enquanto a verificação de autenticação ocorre
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
