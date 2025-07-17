import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';
import 'package:ray_club_app/services/pdf_service.dart';
import 'package:ray_club_app/models/material.dart' as app_material;

/// Widget reutilizável para visualização segura de PDFs
class PdfViewerWidget extends ConsumerStatefulWidget {
  final app_material.Material material;
  final String title;
  final VoidCallback? onClose;

  const PdfViewerWidget({
    super.key,
    required this.material,
    required this.title,
    this.onClose,
  });

  @override
  ConsumerState<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends ConsumerState<PdfViewerWidget> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() async {
    try {
      final pdfService = ref.read(pdfServiceProvider);

      // Gera URL assinada com expiração de 2 minutos
      final signedUrl = await pdfService.generateSignedUrl(
        widget.material.filePath,
        expiresInSeconds: 120,
      );

      // Cria URL do Google Docs Viewer
      final viewerUrl = pdfService.createViewerUrl(signedUrl);

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Erro ao carregar PDF: ${error.description}';
              });
            },
          ),
        )
        ..loadRequest(Uri.parse(viewerUrl));

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao acessar o material: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          widget.title,
          style: AppTextStyles.subtitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeWebView,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) _buildLoadingState(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Carregando material...',
              style: AppTextStyles.body,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: AppColors.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeWebView,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
} 