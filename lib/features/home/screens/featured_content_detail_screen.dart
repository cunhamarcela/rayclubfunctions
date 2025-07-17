// Flutter imports:
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';
import 'package:ray_club_app/features/home/models/featured_content.dart';
import 'package:ray_club_app/features/home/viewmodels/featured_content_view_model.dart';

@RoutePage()
class FeaturedContentDetailScreen extends ConsumerWidget {
  final String contentId;

  const FeaturedContentDetailScreen({
    super.key,
    @PathParam('id') required this.contentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Carregar o conteúdo específico pelo ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ref.read(featuredContentViewModelProvider.notifier).selectContentById(contentId);
      }
    });
    
    // Observar o estado
    final state = ref.watch(featuredContentViewModelProvider);
    final content = state.selectedContent;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(content?.title ?? 'Carregando...'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      body: _buildContent(context, ref, state),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, FeaturedContentState state) {
    // Exibir loader durante o carregamento
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Exibir mensagem de erro
    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erro ao carregar conteúdo: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(featuredContentViewModelProvider.notifier).selectContentById(contentId);
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Se não encontrou o conteúdo
    if (state.selectedContent == null) {
      return const Center(
        child: Text('Conteúdo não encontrado'),
      );
    }

    // Exibir detalhes do conteúdo
    return _buildContentDetail(context, state.selectedContent!);
  }

  Widget _buildContentDetail(BuildContext context, FeaturedContent content) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem de capa (ou ícone se não tiver imagem)
          if (content.imageUrl != null)
            Image.network(
              content.imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (ctx, _, __) => _buildHeaderIcon(content),
            )
          else
            _buildHeaderIcon(content),

          // Título e descrição
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de categoria
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (content.category.color ?? Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    content.category.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: content.category.color ?? Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Título
                Text(
                  content.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),

                // Data de publicação
                if (content.publishedAt != null)
                  Text(
                    'Publicado em ${_formatDate(content.publishedAt!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF999999),
                    ),
                  ),
                const SizedBox(height: 16),

                // Descrição
                Text(
                  content.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF666666),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Conteúdo completo (mock)
                const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF333333),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),

                // Botão de ação (se tiver URL)
                if (content.actionUrl != null)
                  ElevatedButton(
                    onPressed: () async {
                      // ⚠️ TEMPORARIAMENTE DESABILITADO - Links externos comentados para revisão da App Store
                      // Documentado em: EXTERNAL_LINKS_DOCUMENTATION.md
                      /*
                      if (content.actionUrl != null) {
                        final uri = Uri.parse(content.actionUrl!);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Não foi possível abrir o link'),
                              ),
                            );
                          }
                        }
                      }
                      */
                      
                      // Mensagem temporária
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conteúdo externo temporariamente indisponível'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Acessar conteúdo completo'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(FeaturedContent content) {
    // Definir uma cor padrão caso category.color seja nulo
    final categoryColor = content.category.color ?? Colors.blue;
    
    return Container(
      width: double.infinity,
      height: 150,
      color: categoryColor.withOpacity(0.1),
      child: Center(
        child: Icon(
          content.icon,
          size: 80,
          color: categoryColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
} 
