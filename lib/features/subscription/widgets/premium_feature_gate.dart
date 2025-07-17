import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/subscription_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Widget que controla acesso a features premium
/// Mostra o conteúdo se o usuário tem acesso, senão mostra paywall
class PremiumFeatureGate extends ConsumerWidget {
  /// Feature key para verificação de acesso
  final String featureKey;
  
  /// Widget a ser exibido se o usuário tem acesso
  final Widget child;
  
  /// Título do paywall (opcional)
  final String? paywallTitle;
  
  /// Descrição do paywall (opcional)
  final String? paywallDescription;
  
  /// Se deve mostrar loading durante verificação
  final bool showLoading;
  
  /// URL da landing page (padrão: rayclub.com.br)
  final String landingPageUrl;
  
  const PremiumFeatureGate({
    super.key,
    required this.featureKey,
    required this.child,
    this.paywallTitle,
    this.paywallDescription,
    this.showLoading = true,
    this.landingPageUrl = 'https://rayclub.com.br',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verifica configuração de segurança primeiro
    final appConfig = ref.watch(appConfigProvider);
    
    // Se modo seguro ativo, mostra tudo liberado
    if (appConfig.safeMode) {
      return child;
    }
    
    // Se gates desabilitados, mostra conteúdo
    if (!appConfig.progressGatesEnabled) {
      return child;
    }
    
    final featureAccess = ref.watch(featureAccessProvider(featureKey));
    
    return featureAccess.when(
      data: (hasAccess) {
        if (hasAccess) {
          return child;
        } else {
          return _buildPaywall(context, ref);
        }
      },
      loading: () => showLoading 
          ? const Center(child: CircularProgressIndicator())
          : _buildPaywall(context, ref),
      error: (error, stack) => _buildPaywall(context, ref),
    );
  }
  
  Widget _buildPaywall(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone de cadeado
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Título
          Text(
            paywallTitle ?? 'Conteúdo Exclusivo',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4D4D4D),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Descrição
          Text(
            paywallDescription ?? 'Este conteúdo faz parte dos recursos avançados do Ray Club.',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Botão "Clique para saber mais"
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _openLandingPage(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Clique para saber mais',
                style: AppTypography.button.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _openLandingPage(BuildContext context, WidgetRef ref) async {
    try {
      // ⚠️ TEMPORARIAMENTE DESABILITADO - Links externos comentados para revisão da App Store
      // Documentado em: EXTERNAL_LINKS_DOCUMENTATION.md
      /*
      final uri = Uri.parse(landingPageUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      */
      
      // Mensagem temporária
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site externo temporariamente indisponível. Visite: rayclub.com.br'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao abrir landing page: $e');
    }
  }
}

/// Widget para mostrar paywall inline (menor)
class InlinePremiumGate extends ConsumerWidget {
  final String featureKey;
  final Widget child;
  final String buttonText;
  final String landingPageUrl;
  
  const InlinePremiumGate({
    super.key,
    required this.featureKey,
    required this.child,
    this.buttonText = 'Clique para saber mais',
    this.landingPageUrl = 'https://rayclub.com.br',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    
    if (appConfig.safeMode || !appConfig.progressGatesEnabled) {
      return child;
    }
    
    final featureAccess = ref.watch(featureAccessProvider(featureKey));
    
    return featureAccess.when(
      data: (hasAccess) => hasAccess ? child : _buildInlineGate(context, ref),
      loading: () => child,
      error: (error, stack) => _buildInlineGate(context, ref),
    );
  }
  
  Widget _buildInlineGate(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_outline,
            size: 20,
            color: AppColors.primary,
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Text(
              'Recurso premium disponível',
              style: AppTypography.bodySmall.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          
          TextButton(
            onPressed: () => _openLandingPage(context, ref),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              buttonText,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _openLandingPage(BuildContext context, WidgetRef ref) async {
    try {
      // ⚠️ TEMPORARIAMENTE DESABILITADO - Links externos comentados para revisão da App Store
      // Documentado em: EXTERNAL_LINKS_DOCUMENTATION.md
      /*
      final uri = Uri.parse(landingPageUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      */
      
      // Mensagem temporária
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site externo temporariamente indisponível. Visite: rayclub.com.br'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao abrir landing page: $e');
    }
  }
}

/// Widget de gate de progresso mais gamificado  
class ProgressGate extends ConsumerWidget {
  final String featureKey;
  final Widget child;
  final String progressTitle;
  final String progressDescription;
  final String landingPageUrl;
  
  const ProgressGate({
    super.key,
    required this.featureKey,
    required this.child,
    this.progressTitle = 'Continue evoluindo',
    this.progressDescription = 'Este recurso está aguardando seu próximo nível de progresso.',
    this.landingPageUrl = 'https://rayclub.com.br',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    
    if (appConfig.safeMode || !appConfig.progressGatesEnabled) {
      return child;
    }
    
    final featureAccess = ref.watch(featureAccessProvider(featureKey));
    
    return featureAccess.when(
      data: (hasAccess) => hasAccess ? child : _buildProgressGate(context, ref),
      loading: () => child,
      error: (error, stack) => _buildProgressGate(context, ref),
    );
  }
  
  Widget _buildProgressGate(BuildContext context, WidgetRef ref) {
    // Verifica se o child é um Scaffold para determinar se é uma tela completa
    final isFullScreen = child is Scaffold;
    
    if (isFullScreen) {
      // Retorna uma tela completa com Scaffold
      return Scaffold(
        backgroundColor: const Color(0xFFE6E6E6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4D4D4D)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Acesso Restrito',
            style: TextStyle(
              color: const Color(0xFF4D4D4D),
              fontFamily: 'Century',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _buildProgressContent(context, ref),
          ),
        ),
      );
    }
    
    // Para widgets inline, retorna apenas o container
    return _buildProgressContent(context, ref);
  }
  
  Widget _buildProgressContent(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
        ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícone de estrela/progresso
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_up,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Título
          Text(
            progressTitle,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontFamily: 'Century',
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Descrição
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
            progressDescription,
              style: TextStyle(
                fontSize: 16,
              color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Botão de ação
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
            onPressed: () => _openLandingPage(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
              ),
                elevation: 0,
            ),
            child: Text(
              'Clique para saber mais',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _openLandingPage(BuildContext context, WidgetRef ref) async {
    try {
      // ⚠️ TEMPORARIAMENTE DESABILITADO - Links externos comentados para revisão da App Store
      // Documentado em: EXTERNAL_LINKS_DOCUMENTATION.md
      /*
      final uri = Uri.parse(landingPageUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
      */
      
      // Mensagem temporária
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site externo temporariamente indisponível. Visite: rayclub.com.br'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Erro ao abrir landing page: $e');
    }
  }
}

/// Widget discreto para controles inline pequenos
class QuietProgressGate extends ConsumerWidget {
  final String featureKey;
  final Widget child;
  final Widget? placeholder;
  
  const QuietProgressGate({
    super.key,
    required this.featureKey,
    required this.child,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    
    if (appConfig.safeMode || !appConfig.progressGatesEnabled) {
      return child;
    }
    
    final featureAccess = ref.watch(featureAccessProvider(featureKey));
    
    return featureAccess.when(
      data: (hasAccess) => hasAccess ? child : (placeholder ?? const SizedBox.shrink()),
      loading: () => child,
      error: (error, stack) => placeholder ?? const SizedBox.shrink(),
    );
  }
}

/// NOVO: Widget que permite VISUALIZAR mas restringe FUNCIONALIDADE
/// Linguagem amigável à Apple Store - foca em evolução/progressão
class ViewOnlyProgressGate extends ConsumerWidget {
  final String featureKey;
  final Widget child;
  final String evolutionTitle;
  final String evolutionDescription;
  final String landingPageUrl;
  
  const ViewOnlyProgressGate({
    super.key,
    required this.featureKey,
    required this.child,
    this.evolutionTitle = 'Continue Evoluindo',
    this.evolutionDescription = 'Este conteúdo será desbloqueado conforme você progride.',
    this.landingPageUrl = 'https://rayclub.com.br',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appConfig = ref.watch(appConfigProvider);
    
    // Se modo seguro ou gates desabilitados, mostra tudo liberado
    if (appConfig.safeMode || !appConfig.progressGatesEnabled) {
      return child;
    }
    
    final featureAccess = ref.watch(featureAccessProvider(featureKey));
    
    return featureAccess.when(
      data: (hasAccess) {
        if (hasAccess) {
          // Usuário tem acesso - funcionalidade completa
          return child;
        } else {
          // Usuário não tem acesso - apenas visualização
          return _buildViewOnlyWrapper(context, ref);
        }
      },
      loading: () => child, // Durante carregamento, mostra o conteúdo
      error: (error, stack) => _buildViewOnlyWrapper(context, ref), // Em caso de erro, trata como sem acesso
    );
  }
  
  Widget _buildViewOnlyWrapper(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        // Conteúdo original visível
        child,
        
        // Interceptor de cliques invisível
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showEvolutionDialog(context, ref),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  // Overlay sutil opcional para indicar restrição
                  color: Colors.black.withValues(alpha: 0.02),
                ),
              ),
            ),
          ),
        ),
        
        // Badge discreto indicando próximo nível
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 10,
                  color: Colors.white,
                ),
                const SizedBox(width: 2),
                Text(
                  'EVOLUA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  void _showEvolutionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.trending_up,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                evolutionTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              evolutionDescription,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Você pode visualizar todos os conteúdos disponíveis. Para interagir com eles, continue evoluindo em sua jornada.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Continue sua evolução para desbloquear ainda mais conteúdos incríveis!',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Entendi',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Visite rayclub.com.br para evoluir ainda mais'),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Saiba Mais',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 