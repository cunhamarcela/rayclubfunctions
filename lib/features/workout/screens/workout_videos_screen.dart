import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_text_styles.dart';
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';
import 'package:ray_club_app/core/widgets/loading_widget.dart';
import 'package:ray_club_app/core/services/expert_video_guard.dart';
import 'package:ray_club_app/features/home/widgets/youtube_player_widget.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:ray_club_app/features/workout/viewmodels/workout_videos_viewmodel.dart';
import 'package:ray_club_app/features/workout/widgets/workout_video_card.dart';
import 'package:ray_club_app/features/workout/providers/workout_material_providers.dart';
import 'package:ray_club_app/models/material.dart' as app_material;
import 'package:ray_club_app/widgets/pdf_viewer_widget.dart';

@RoutePage()
class WorkoutVideosScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String? categoryName;

  const WorkoutVideosScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  ConsumerState<WorkoutVideosScreen> createState() => _WorkoutVideosScreenState();
}

class _WorkoutVideosScreenState extends ConsumerState<WorkoutVideosScreen> {
  @override
  Widget build(BuildContext context) {
    // Determinar o nome da categoria baseado no ID se não foi fornecido
    final categoryName = widget.categoryName ?? _getCategoryNameFromId(widget.categoryId);
    
    // ✨ NOVA LÓGICA: Detectar se é fisioterapia para mostrar subcategorias
    final isFisioterapia = _isFisioterapiaCategory();
    final isPhysiotherapySubcategory = _isPhysiotherapySubcategory(categoryName);
    
    // ✨ NOVA LÓGICA: Detectar se é corrida para mostrar planilhas
    final isCorrida = _isCorridaCategory();
    
    if (isFisioterapia && !isPhysiotherapySubcategory) {
      // Mostrar subcategorias de fisioterapia
      return _buildFisioterapiaSubcategories(context, categoryName);
    }
    
    // Definir qual provider usar baseado na categoria
    AsyncValue<List<WorkoutVideo>> videosAsync;
    
    if (isPhysiotherapySubcategory) {
      // Usar provider de subcategoria para fisioterapia
      final subcategoryName = _extractSubcategoryName(categoryName);
      videosAsync = ref.watch(physiotherapyVideosBySubcategoryProvider(subcategoryName));
    } else {
      // Comportamento normal para outras categorias
      videosAsync = ref.watch(workoutVideosByCategoryProvider(widget.categoryId));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(
        title: categoryName,
        showBackButton: true,
      ),
      body: videosAsync.when(
        data: (videos) {
          if (videos.isEmpty && !isCorrida) {
            return _buildEmptyState();
          }
          return _buildContent(videos, isCorrida);
        },
        loading: () => const LoadingWidget(),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar vídeos',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  if (isPhysiotherapySubcategory) {
                    final subcategoryName = _extractSubcategoryName(categoryName);
                    ref.refresh(physiotherapyVideosBySubcategoryProvider(subcategoryName));
                  } else {
                    ref.refresh(workoutVideosByCategoryProvider(widget.categoryId));
                  }
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryNameFromId(String categoryId) {
    // Este é um fallback caso o categoryName não seja passado
    return widget.categoryName ?? 'Treinos';
  }

  Widget _buildContent(List<WorkoutVideo> videos, bool isCorrida) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✨ NOVA SEÇÃO: Planilhas de corrida (somente se for categoria corrida)
          if (isCorrida) ...[
            _buildRunningPlanilhasSection(),
            const SizedBox(height: 32),
          ],
          
          // Seção de vídeos (sempre presente)
          if (videos.isNotEmpty) ...[
            _buildVideosSection(videos),
          ] else if (!isCorrida) ...[
            _buildEmptyVideosState(),
          ],
        ],
      ),
    );
  }

  Widget _buildRunningPlanilhasSection() {
    final materialsAsync = ref.watch(runningMaterialsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da seção de planilhas
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF26A69A), // Verde da corrida
                Color(0xFF4DB6AC),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(
                Icons.description,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Planilhas de Treino',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'CenturyGothic',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Guias e planilhas para seus treinos de corrida ✨',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontFamily: 'CenturyGothic',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Lista de planilhas
        materialsAsync.when(
          data: (materials) {
            if (materials.isEmpty) {
              return _buildEmptyPlanilhasState();
            }
            return Column(
              children: materials.map((material) => 
                _buildPlanilhaCard(material)
              ).toList(),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => _buildEmptyPlanilhasState(),
        ),
      ],
    );
  }

  Widget _buildPlanilhaCard(app_material.Material material) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openPdfViewer(context, material),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Ícone do PDF
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF26A69A).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf,
                    color: Color(0xFF26A69A),
                    size: 28,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Informações da planilha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                          fontFamily: 'CenturyGothic',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        material.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontFamily: 'CenturyGothic',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.download,
                            size: 16,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Toque para visualizar',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontFamily: 'CenturyGothic',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Seta indicando ação
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlanilhasState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Planilhas em breve! ✨',
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Planilhas de treino para corrida serão disponibilizadas aqui.',
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVideosSection(List<WorkoutVideo> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da seção de vídeos
        Row(
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 24,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Vídeos de Treino',
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Lista de vídeos
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: WorkoutVideoCard(
                video: video,
                onTap: () => _onVideoTap(video),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyVideosState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum vídeo disponível',
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Em breve adicionaremos novos conteúdos!',
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum vídeo disponível',
            style: AppTextStyles.subtitle.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Em breve adicionaremos novos conteúdos!',
            style: AppTextStyles.body.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onVideoTap(WorkoutVideo video) {
    if (video.youtubeUrl != null && video.youtubeUrl!.isNotEmpty) {
      try {
        // Abrir player do YouTube em modal bottom sheet COM PROTEÇÃO EXPERT
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: true,
          builder: (context) => Consumer(
            builder: (context, ref, _) {
              return ExpertVideoGuard.buildProtectedPlayer(
                context,
                ref,
                video.youtubeUrl ?? video.id,
                DraggableScrollableSheet(
                  initialChildSize: 0.9,
                  minChildSize: 0.5,
                  maxChildSize: 0.95,
                  builder: (context, scrollController) => YouTubePlayerWidget(
                    videoUrl: video.youtubeUrl!,
                    title: video.title,
                    description: video.description ?? video.instructorName,
                    onClose: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),
        );
      } catch (e) {
        debugPrint('Erro ao abrir player do YouTube: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir o vídeo. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Fallback caso não tenha URL do YouTube
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vídeo não disponível no momento'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _openPdfViewer(BuildContext context, app_material.Material material) {
    // ✅ PROTEÇÃO EXPERT: Usar ExpertVideoGuard para PDFs
    ExpertVideoGuard.openProtectedPdf(context, ref, material);
  }

  /// ✨ NOVA FUNCIONALIDADE: Detectar se é categoria de corrida
  bool _isCorridaCategory() {
    // Verificar pelo nome da categoria
    final categoryName = widget.categoryName?.toLowerCase() ?? '';
    return categoryName.contains('corrida') || categoryName.contains('running');
  }

  /// ✨ NOVA FUNCIONALIDADE: Detectar se é categoria de fisioterapia
  bool _isFisioterapiaCategory() {
    // Verificar pelo ID conhecido da fisioterapia
    if (widget.categoryId == 'da178dba-ae94-425a-aaed-133af7b1bb0f') {
      return true;
    }
    
    // Verificar pelo nome da categoria
    final categoryName = widget.categoryName?.toLowerCase() ?? '';
    return categoryName.contains('fisioterapia') || categoryName.contains('physiotherapy');
  }

  /// ✨ NOVA FUNCIONALIDADE: Detectar se é uma subcategoria de fisioterapia
  bool _isPhysiotherapySubcategory(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    final isSubcategory = lowerName.contains('testes - fisioterapia') ||
           lowerName.contains('mobilidade - fisioterapia') ||
           lowerName.contains('estabilidade - fisioterapia');
    print('🔍 Verificando subcategoria: "$categoryName" → $isSubcategory');
    return isSubcategory;
  }

  /// ✨ NOVA FUNCIONALIDADE: Extrair nome da subcategoria
  String _extractSubcategoryName(String categoryName) {
    final parts = categoryName.split(' - ');
    return parts.isNotEmpty ? parts.first : categoryName;
  }

  /// ✨ NOVA FUNCIONALIDADE: Construir tela de subcategorias de fisioterapia
  Widget _buildFisioterapiaSubcategories(BuildContext context, String categoryName) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWidget(
        title: categoryName,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com descrição
            _buildFisioterapiaHeader(),
            
            const SizedBox(height: 24),
            
            // Subcategorias
            ..._buildFisioterapiaSubcategoryCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFisioterapiaHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF16A085), // Verde fisioterapia
            Color(0xFF1ABC9C),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'The Unit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'CenturyGothic',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Fisioterapia e reabilitação preventiva no esporte',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontFamily: 'CenturyGothic',
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Escolha sua área de interesse ✨',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontFamily: 'CenturyGothic',
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFisioterapiaSubcategoryCards(BuildContext context) {
    final subcategories = [
      {
        'name': 'Testes',
        'description': 'Avaliações e diagnósticos funcionais',
        'icon': Icons.assignment,
        'color': const Color(0xFF3498DB),
        'keywords': ['apresentação', 'teste', 'avaliação']
      },
      {
        'name': 'Mobilidade',
        'description': 'Exercícios para melhorar amplitude de movimento',
        'icon': Icons.accessibility_new,
        'color': const Color(0xFF2ECC71),
        'keywords': ['mobilidade']
      },
      {
        'name': 'Estabilidade',
        'description': 'Exercícios de estabilização e controle motor',
        'icon': Icons.balance,
        'color': const Color(0xFF9B59B6),
        'keywords': ['estabilidade', 'prancha', 'core', 'quadril', 'ombro', 'dor', 'prevenção', 'lesões', 'joelho', 'coluna', 'fortalecimento']
      },
    ];

    return subcategories.map((subcategory) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navegar para vídeos filtrados por subcategoria
              _navigateToSubcategoryVideos(context, subcategory);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Ícone da subcategoria
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: (subcategory['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      subcategory['icon'] as IconData,
                      color: subcategory['color'] as Color,
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Informações da subcategoria
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subcategory['name'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                            fontFamily: 'CenturyGothic',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subcategory['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'CenturyGothic',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Vídeos disponíveis',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                                fontFamily: 'CenturyGothic',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Seta indicando navegação
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _navigateToSubcategoryVideos(BuildContext context, Map<String, dynamic> subcategory) {
    final subcategoryName = '${subcategory['name']} - Fisioterapia';
    print('🔍 Navegando para subcategoria: $subcategoryName');
    
    context.router.push(WorkoutVideosRoute(
      categoryId: widget.categoryId,
      categoryName: subcategoryName,
    ));
  }
} 