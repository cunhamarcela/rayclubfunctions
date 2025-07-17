// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';
import 'package:ray_club_app/core/providers/providers.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';

import 'dart:ui'; // Import para usar ImageFilter

/// Tela de introdução (Splash/Intro) do Ray Club
/// Apresenta uma tela de boas-vindas com imagem de fundo, logo e botões de ação
@RoutePage()
class IntroScreen extends ConsumerWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('>>> IntroScreen carregada');
    
    // Verificar autenticação para decidir se exibe a tela ou redireciona para home
    final authState = ref.watch(authViewModelProvider);
    
    // Se estiver autenticado, redirecionar para a tela principal
    authState.maybeWhen(
      authenticated: (user) {
        debugPrint('IntroScreen - Usuário autenticado: ${user.id}, redirecionando para HOME');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Imediatamente marcar como visto para evitar mostrar intro no futuro
          _markIntroAsSeen();
          context.router.replaceNamed('/');
        });
        return;
      },
      orElse: () {
        debugPrint('IntroScreen - Usuário não autenticado, mostrando intro');
      },
    );
    
    // Obtém as dimensões da tela para layouts responsivos
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        // Container principal com imagem de fundo
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/logos/backgrounds/intro4.png'),
            fit: BoxFit.contain,
            alignment: Alignment.center,
            // Add a bit of padding to ensure the image doesn't touch the screen edges
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.0), // Make it fully transparent to show original image
              BlendMode.darken,
            ),
          ),
        ),
        // Add padding to ensure the image has some space on top and bottom
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: SafeArea(
          child: Column(
            children: [
              // Área expansível para ocupar menos espaço no topo
              Spacer(flex: 2),
              
              // Logo e Título
              _buildLogoSection(context),
              
              const SizedBox(height: 24),
              
              // Texto da jornada apenas
              _buildMessageSection(context),
              
              // Maior espaço abaixo do texto para empurrar conteúdo para cima
              Spacer(flex: 5),
              
              // Botões de ação
              _buildActionButtons(context),
              
              // Espaço na parte inferior para segurança
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói a seção do logo
  Widget _buildLogoSection(BuildContext context) {
    return Container();
  }

  /// Constrói a seção de mensagens simplificada
  Widget _buildMessageSection(BuildContext context) {
    // Return empty container to remove text
    return Container();
  }

  /// Marca que o usuário já viu a introdução
  static Future<void> _markIntroAsSeen() async {
    try {
      // PATCH: Corrigir bug 1 - Salvar onboarding_seen no SharedPreferences e no Supabase
      final prefs = await SharedPreferences.getInstance();
      debugPrint('💡 IntroScreen: Marcando que o usuário já viu a introdução');
      
      // Salvar na SharedPreferences - garantir que seja salvo corretamente
      bool result = false;
      int attempts = 0;
      const maxAttempts = 3;
      
      while (!result && attempts < maxAttempts) {
        attempts++;
        result = await prefs.setBool('has_seen_intro', true);
        if (result) {
          debugPrint('✅ IntroScreen: Marcado com sucesso que o usuário já viu a introdução (SharedPreferences)');
        } else {
          debugPrint('⚠️ IntroScreen: Tentativa $attempts falhou, tentando novamente...');
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      
      if (!result) {
        debugPrint('❌ IntroScreen: Falha em todas as $maxAttempts tentativas de salvar has_seen_intro');
      }
      
      // Salvar também no Supabase para garantir persistência entre dispositivos
      try {
        final supabase = Supabase.instance.client;
        final user = supabase.auth.currentUser;
        
        if (user != null) {
          await supabase.from('profiles')
            .update({'onboarding_seen': true})
            .eq('id', user.id);
          debugPrint('✅ IntroScreen: Marcado com sucesso que o usuário já viu a introdução (Supabase)');
        }
      } catch (e) {
        debugPrint('⚠️ IntroScreen: Erro ao atualizar onboarding_seen no Supabase: $e');
      }
      
      // Verificar se a flag foi realmente salva
      final wasSet = prefs.getBool('has_seen_intro') ?? false;
      debugPrint('🔍 IntroScreen: Verificação final de has_seen_intro = $wasSet');
      
      if (!wasSet) {
        // Se ainda não foi salvo, tentar uma última vez com outro método
        debugPrint('⚠️ IntroScreen: Flag ainda não está salva, tentando método alternativo');
        await prefs.setString('has_seen_intro_str', 'true');
        // Criar um arquivo backup
        await prefs.setString('intro_seen_backup', DateTime.now().toIso8601String());
      }
    } catch (e) {
      debugPrint('❌ IntroScreen: Erro ao marcar introdução como vista: $e');
      // Em caso de erro, tentar novamente uma vez mais com abordagem diferente
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_seen_intro', true);
        await prefs.setString('intro_seen_backup', 'true');
      } catch (_) {
        // Ignorar erro na segunda tentativa
      }
    }
  }

  /// Constrói os botões de ação
  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Botão principal "Visualizar conteúdo"
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info, // fundo rosa claro
                foregroundColor: Colors.white,    // texto branco
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                debugPrint('📱 IntroScreen: Botão Visualizar conteúdo clicado');
                await _markIntroAsSeen();
                // Navigate to home after marking intro as seen
                if (context.mounted) {
                  context.router.replaceNamed('/');
                }
              },
              child: const Text(
                'Visualizar conteúdo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontFamily: 'CenturyGothic',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Botão secundário "Login"
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                debugPrint('📱 IntroScreen: Botão Login clicado');
                await _markIntroAsSeen();
                // Navigate to login after marking intro as seen
                if (context.mounted) {
                  context.router.replaceNamed('/login');
                }
              },
              child: const Text(
                'Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  fontFamily: 'CenturyGothic',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
