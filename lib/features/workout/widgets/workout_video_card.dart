import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';
import 'package:ray_club_app/core/utils/youtube_utils.dart';
import 'package:ray_club_app/core/services/expert_video_guard.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:ray_club_app/features/workout/providers/user_access_provider.dart';
import 'package:ray_club_app/providers/user_profile_provider.dart' as profile_providers;
import 'package:ray_club_app/features/workout/screens/workout_video_detail_screen.dart';

/// Widget de card de vídeo com proteção FAIL-SAFE
/// ⚠️ QUALQUER ERRO OU DÚVIDA = BLOQUEIO TOTAL
class WorkoutVideoCard extends ConsumerWidget {
  final WorkoutVideo video;
  final VoidCallback onTap;
  final VoidCallback? onUpgradeRequested;

  const WorkoutVideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.onUpgradeRequested,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🎬 [WorkoutVideoCard] ========== VERIFICANDO VÍDEO ==========');
    print('🎬 [WorkoutVideoCard] Video ID: ${video.id}');
    print('🎬 [WorkoutVideoCard] Video Title: ${video.title}');
    print('🎬 [WorkoutVideoCard] Requires Expert Access: ${video.requiresExpertAccess}');
    
    try {
      // ✅ Usar novo provider global - verificação instantânea
      final isExpertAsync = ref.watch(profile_providers.isExpertUserProfileProvider);
      
      return isExpertAsync.when(
        data: (isExpert) {
          print('🎬 [WorkoutVideoCard] Usuário é expert: $isExpert');
          return _buildCard(context, ref, isExpert);
        },
        loading: () {
          print('⏳ [WorkoutVideoCard] Carregando status do usuário...');
          return _buildBlockedCard(context, 'Carregando...');
        },
        error: (error, stack) {
          print('❌ [WorkoutVideoCard] Erro ao verificar usuário: $error');
          return _buildBlockedCard(context, 'Erro de acesso');
        },
      );
    } catch (e, stackTrace) {
      // ⚠️ ERRO NO BUILD = CARD BLOQUEADO
      print('❌ [WorkoutVideoCard] Erro crítico no build: $e');
      print('❌ [WorkoutVideoCard] Stack: $stackTrace');
      return _buildBlockedCard(context, 'Erro crítico');
    }
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, bool isExpert) {
    print('🔧 [WorkoutVideoCard] _buildCard para vídeo ${video.id} - isExpert: $isExpert');
    
    try {
      // ✅ Verificação simples e direta - usuários expert têm acesso
      final canAccess = isExpert;
      print('🔧 [WorkoutVideoCard] Resultado final para ${video.id}: canAccess = $canAccess');
      
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutVideoDetailScreen(video: video),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Row(
                children: [
                  _buildThumbnail(canAccess),
                  Expanded(
                    child: _buildContent(canAccess),
                  ),
                ],
              ),
              // ⚠️ OVERLAY SEMPRE PRESENTE PARA USUARIOS NÃO-EXPERT
              if (!canAccess) _buildAccessOverlay(context),
            ],
          ),
        ),
      );
    } catch (e, stackTrace) {
      // ⚠️ ERRO NA CONSTRUÇÃO = CARD BLOQUEADO
      debugPrint('❌ Erro _buildCard: $e');
      debugPrint('Stack: $stackTrace');
      return _buildBlockedCard(context, 'Erro de construção');
    }
  }

  /// ✅ Verificação simplificada - removido métodos redundantes
  /// Agora usando apenas o provider global unificado

  /// ✅ Manipulação de clique agora é feita diretamente no InkWell

  Widget _buildContent(bool canAccess) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.title,
            style: AppTextStyles.cardTitle.copyWith(
              color: canAccess ? AppColors.textPrimary : AppColors.textDisabled,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // ✨ NOVO: Indicador de PDF
          if (video.hasPdfMaterials)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.picture_as_pdf,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Material PDF',
                    style: AppTextStyles.chipText.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(bool canAccess) {
    try {
      final thumbnailUrl = video.thumbnailUrl ?? 
          (video.youtubeUrl != null 
              ? YouTubeUtils.getThumbnailUrl(video.youtubeUrl!)
              : null);

      return Container(
        width: 120,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          color: AppColors.divider,
        ),
        child: Stack(
          children: [
            if (thumbnailUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: ColorFiltered(
                  colorFilter: canAccess 
                      ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                      : ColorFilter.mode(Colors.black.withValues(alpha: 0.5), BlendMode.darken),
                  child: Image.network(
                    thumbnailUrl,
                    width: 120,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(canAccess),
                  ),
                ),
              )
            else
              _buildPlaceholder(canAccess),
            
            // ⚠️ ÍCONE CENTRAL SEMPRE CORRETO
            Center(
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: canAccess 
                      ? const Color(0xFFFF0000).withValues(alpha: 0.9)
                      : const Color(0xFFE78639).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  canAccess ? Icons.play_arrow : Icons.lock,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            
            // Badge YouTube apenas para experts
            if (canAccess) Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
            

          ],
        ),
      );
    } catch (e) {
      // ⚠️ ERRO = PLACEHOLDER BLOQUEADO
      return _buildPlaceholder(false);
    }
  }

  Widget _buildPlaceholder(bool canAccess) {
    return Container(
      color: canAccess ? AppColors.divider : AppColors.divider.withValues(alpha: 0.5),
      child: Center(
        child: Icon(
          canAccess ? Icons.video_library : Icons.lock,
          size: 40,
          color: canAccess 
              ? AppColors.textSecondary.withValues(alpha: 0.5)
              : const Color(0xFFE78639),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color, bool canAccess) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: canAccess 
            ? color.withValues(alpha: 0.1)
            : color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.smallText.copyWith(
          color: canAccess ? color : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAccessOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFE78639),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE78639),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'EXPERT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ⚠️ CARD COMPLETAMENTE BLOQUEADO EM CASO DE ERRO
  Widget _buildBlockedCard(BuildContext context, String reason) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE78639), width: 2),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock,
                  color: Color(0xFFE78639),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'EXPERT',
                  style: AppTextStyles.smallText.copyWith(
                    color: const Color(0xFFE78639),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    reason,
                    style: AppTextStyles.smallText.copyWith(
                      color: Colors.grey[600],
                      fontSize: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚀 Upgrade para Expert'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Com o plano Expert você terá:'),
            SizedBox(height: 8),
            Text('✅ Acesso a todos os vídeos de parceiros'),
            Text('✅ Treinos exclusivos de Fight Fit'),
            Text('✅ Conteúdo de Goya Health Club'),
            Text('✅ Vídeos de Bora Assessoria'),
            Text('✅ E muito mais!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mais tarde'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onUpgradeRequested?.call();
            },
            child: const Text('Quero Upgrade!'),
          ),
        ],
      ),
    );
  }
} 