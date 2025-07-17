import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/workout/providers/user_access_provider.dart';
import 'package:ray_club_app/providers/user_profile_provider.dart' as profile_providers;

/// Serviço centralizado para proteção de vídeos expert
/// Implementa sistema fail-safe: qualquer erro resulta em bloqueio
class ExpertVideoGuard {
  
  /// Verifica se o usuário pode reproduzir vídeos do YouTube
  /// Retorna true apenas se for usuário EXPERT com acesso válido
  /// ⚠️ EM CASO DE QUALQUER ERRO OU DÚVIDA: RETORNA FALSE
  /// ✅ Atualizado para usar novo provider global
  static Future<bool> canPlayVideo(WidgetRef ref, String videoId) async {
    try {
      debugPrint('🔍 [ExpertVideoGuard] ========== VERIFICAÇÃO DE ACESSO ==========');
      debugPrint('🔍 [ExpertVideoGuard] Video ID: $videoId');
      debugPrint('🔍 [ExpertVideoGuard] Timestamp: ${DateTime.now()}');
      
      // ✅ Usar novo provider global - verificação instantânea
      final isExpertAsync = ref.read(profile_providers.isExpertUserProfileProvider);
      
      debugPrint('🔍 [ExpertVideoGuard] isExpertAsync.runtimeType: ${isExpertAsync.runtimeType}');
      debugPrint('🔍 [ExpertVideoGuard] isExpertAsync: $isExpertAsync');
      
      return isExpertAsync.maybeWhen(
        data: (isExpert) {
          debugPrint('🔍 [ExpertVideoGuard] ========== DADOS CARREGADOS ==========');
          debugPrint('🔍 [ExpertVideoGuard] Provider retornou dados: $isExpert');
          debugPrint('🔍 [ExpertVideoGuard] isExpert.runtimeType: ${isExpert.runtimeType}');
          debugPrint('🔍 [ExpertVideoGuard] isExpert == true: ${isExpert == true}');
          debugPrint('🔍 [ExpertVideoGuard] isExpert === true: ${identical(isExpert, true)}');
          
          if (isExpert == true) {
            debugPrint('🔍 [ExpertVideoGuard] ✅ EXPERT = ACESSO LIBERADO AO VÍDEO');
            debugPrint('🔍 [ExpertVideoGuard] ========== RESULTADO: TRUE ==========');
            return true;
          } else {
            debugPrint('🔍 [ExpertVideoGuard] ❌ BASIC = ACESSO NEGADO');
            debugPrint('🔍 [ExpertVideoGuard] ❌ Valor isExpert: $isExpert');
            debugPrint('🔍 [ExpertVideoGuard] ========== RESULTADO: FALSE ==========');
            return false;
          }
        },
        loading: () {
          debugPrint('🔍 [ExpertVideoGuard] ⏳ LOADING = ACESSO NEGADO');
          debugPrint('🔍 [ExpertVideoGuard] ========== RESULTADO: FALSE (LOADING) ==========');
          return false;
        },
        error: (error, stack) {
          debugPrint('🔍 [ExpertVideoGuard] ❌ ERROR = ACESSO NEGADO');
          debugPrint('🔍 [ExpertVideoGuard] ❌ Error: $error');
          debugPrint('🔍 [ExpertVideoGuard] ========== RESULTADO: FALSE (ERROR) ==========');
          return false;
        },
        orElse: () {
          debugPrint('🔍 [ExpertVideoGuard] ❌ ORELSE = ACESSO NEGADO');
          debugPrint('🔍 [ExpertVideoGuard] ========== RESULTADO: FALSE (ORELSE) ==========');
          return false;
        },
      );
    } catch (e, stackTrace) {
      debugPrint('🔍 [ExpertVideoGuard] ❌ EXCEPTION = ACESSO NEGADO');
      debugPrint('🔍 [ExpertVideoGuard] ERROR during access check: $e');
      debugPrint('🔍 [ExpertVideoGuard] StackTrace: $stackTrace');
      debugPrint('🔍 [ExpertVideoGuard] ========== RESULTADO: FALSE (EXCEPTION) ==========');
      return false; // Fail-safe: qualquer erro nega acesso
    }
  }
  
  /// Manipula o clique em vídeos com verificação rigorosa
  /// ⚠️ FAIL-SAFE: Qualquer problema = bloqueio mostrado
  static Future<void> handleVideoTap(BuildContext context, WidgetRef ref, String videoId, VoidCallback onAllowed) async {
    try {
      debugPrint('🎯 [handleVideoTap] Iniciando verificação para videoId: $videoId');
      
      if (!context.mounted) {
        debugPrint('🎯 [handleVideoTap] Context não montado - abortando');
        return;
      }
      
      final canPlay = await canPlayVideo(ref, videoId);
      debugPrint('🎯 [handleVideoTap] canPlay result: $canPlay');
      
      if (!context.mounted) {
        debugPrint('🎯 [handleVideoTap] Context não montado após canPlayVideo - abortando');
        return;
      }
      
      if (canPlay) {
        debugPrint('🎯 [handleVideoTap] ✅ CHAMANDO onAllowed()');
        onAllowed();
        debugPrint('🎯 [handleVideoTap] ✅ onAllowed() EXECUTADO');
      } else {
        debugPrint('🎯 [handleVideoTap] ❌ Mostrando diálogo de acesso negado');
        await showExpertRequiredDialog(context);
      }
    } catch (e) {
      debugPrint('[ExpertVideoGuard] Error in handleVideoTap: $e');
      if (context.mounted) {
        await showExpertRequiredDialog(context);
      }
    }
  }
  
  /// Verifica acesso de forma síncrona para widgets
  /// ⚠️ FAIL-SAFE: Qualquer problema = retorna false
  /// ✅ Atualizado para usar novo provider global
  static bool canAccessSync(WidgetRef ref) {
    try {
      // ✅ Usar novo provider global - verificação instantânea
      final isExpertAsync = ref.read(profile_providers.isExpertUserProfileProvider);
      return isExpertAsync.maybeWhen(
        data: (isExpert) => isExpert,
        orElse: () => false,
      );
    } catch (e) {
      debugPrint('[ExpertVideoGuard] Error in canAccessSync: $e');
      return false;
    }
  }
  
  /// Diálogo de bloqueio para usuários não-expert
  static Future<void> showExpertRequiredDialog(BuildContext context) async {
    if (!context.mounted) return;
    
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE78639).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFFE78639),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Continue Evoluindo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Este conteúdo estará disponível conforme você progride em sua jornada.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Você pode visualizar todos os conteúdos disponíveis. Para interagir com eles, continue evoluindo!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE78639),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Entendi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Widget para mostrar overlay de bloqueio em cards
  /// ⚠️ SEMPRE FUNCIONA, mesmo em caso de erro
  static Widget buildProtectedPlayer(BuildContext context, WidgetRef ref, String videoId, Widget playerWidget) {
    // ✅ Usar novo provider global - verificação instantânea
    final isExpertAsync = ref.read(profile_providers.isExpertUserProfileProvider);
    
    return isExpertAsync.when(
      data: (isExpert) {
        if (isExpert) {
          return playerWidget;
        } else {
          return GestureDetector(
            onTap: () => showExpertRequiredDialog(context),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 48,
                          color: const Color(0xFFE78639).withValues(alpha: 0.8),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'CONTINUE EVOLUINDO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Toque para saber mais',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91E63).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'EXPERT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      loading: () => Container(
        height: 200,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFE91E63)),
        ),
      ),
      error: (error, stack) => GestureDetector(
        onTap: () => showExpertRequiredDialog(context),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                SizedBox(height: 12),
                Text(
                  'Erro ao carregar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 