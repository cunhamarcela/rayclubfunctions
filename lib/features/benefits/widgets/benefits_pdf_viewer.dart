import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/subscription/providers/subscription_providers.dart';

/// Widget especializado para visualização do PDF de benefícios
/// RESTRITO APENAS PARA USUÁRIOS EXPERT
/// 
/// Data: 2025-01-21 às 23:40
/// Autor: IA
/// Contexto: Implementação da visualização exclusiva do PDF beneficios.pdf para usuários EXPERT
class BenefitsPdfViewer extends ConsumerStatefulWidget {
  const BenefitsPdfViewer({super.key});

  @override
  ConsumerState<BenefitsPdfViewer> createState() => _BenefitsPdfViewerState();
}

class _BenefitsPdfViewerState extends ConsumerState<BenefitsPdfViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  
  static const String _benefitsPdfPath = 'beneficios/beneficios.pdf';
  static const String _bucketName = 'materials';

  @override
  void initState() {
    super.initState();
    _initializePdfViewer();
  }

  Future<void> _initializePdfViewer() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Gerar URL assinada para o PDF de benefícios
      final signedUrl = await _generateSignedUrl();
      
      // Criar URL do Google Docs Viewer para visualização fluida
      final viewerUrl = _createViewerUrl(signedUrl);

      // Configurar WebView Controller
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() => _isLoading = true);
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() => _isLoading = false);
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Erro ao carregar o PDF: ${error.description}';
                });
              }
            },
          ),
        )
        ..loadRequest(Uri.parse(viewerUrl));

    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Erro ao acessar o PDF de benefícios: $e';
        });
      }
    }
  }

  /// Gera URL assinada para o PDF no bucket do Supabase
  Future<String> _generateSignedUrl() async {
    try {
      final supabase = Supabase.instance.client;
      
      final signedUrl = await supabase.storage
          .from(_bucketName)
          .createSignedUrl(_benefitsPdfPath, 300); // 5 minutos de expiração
      
      return signedUrl;
    } catch (e) {
      throw Exception('Erro ao gerar acesso ao PDF: $e');
    }
  }

  /// Cria URL do Google Docs Viewer para renderização fluida
  String _createViewerUrl(String signedUrl) {
    return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(signedUrl)}';
  }

  @override
  Widget build(BuildContext context) {
    // Verificar se usuário é EXPERT
    final featureAccess = ref.watch(featureAccessProvider('detailed_reports'));
    
    return featureAccess.when(
      data: (hasAccess) {
        if (!hasAccess) {
          return _buildAccessDenied();
        }
        return _buildPdfViewer();
      },
      loading: () => _buildLoading('Verificando acesso...'),
      error: (error, stack) => _buildAccessDenied(),
    );
  }

  Widget _buildPdfViewer() {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: const Text(
          'Benefícios Exclusivos ✨',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textDark),
            onPressed: _initializePdfViewer,
            tooltip: 'Recarregar PDF',
          ),
        ],
      ),
      body: _buildPdfContent(),
    );
  }

  Widget _buildPdfContent() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        // WebView com o PDF
        if (!_isLoading)
          WebViewWidget(controller: _controller),
        
        // Indicador de carregamento
        if (_isLoading)
          _buildLoading('Carregando PDF de benefícios...'),
      ],
    );
  }

  Widget _buildLoading(String message) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Algo não funcionou como esperado 🤔',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Erro desconhecido',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializePdfViewer,
              icon: const Icon(Icons.refresh),
              label: const Text('Vamos tentar de novo?'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Voltar',
        ),
        title: const Text(
          'Benefícios',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de estrela (mais amigável que cadeado)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_outline,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Título amigável
              Text(
                'Continue Evoluindo! ✨',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Descrição motivacional
              Text(
                'Esta área especial com benefícios exclusivos será desbloqueada conforme você progride no seu desenvolvimento.',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Botão motivacional
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.trending_up),
                label: const Text('Continue Evoluindo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 