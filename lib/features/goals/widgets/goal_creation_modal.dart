import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/goals/models/personalized_goal.dart';
import 'package:ray_club_app/features/goals/viewmodels/personalized_goal_viewmodel.dart';
import 'package:ray_club_app/features/goals/providers/real_goals_providers.dart';
import 'package:ray_club_app/core/providers/auth_provider.dart';

/// Classe para representar uma modalidade de exercício
class ExerciseModality {
  final String name;
  final String emoji;
  final Color color;
  final String category;
  final int defaultMinutes;

  const ExerciseModality({
    required this.name,
    required this.emoji,
    required this.color,
    required this.category,
    required this.defaultMinutes,
  });
}

/// Modal para criação de metas com opções pré-estabelecidas e personalizadas
class GoalCreationModal extends ConsumerStatefulWidget {
  final VoidCallback? onGoalCreated;
  
  const GoalCreationModal({super.key, this.onGoalCreated});

  @override
  ConsumerState<GoalCreationModal> createState() => _GoalCreationModalState();
}

class _GoalCreationModalState extends ConsumerState<GoalCreationModal> {
  int selectedTab = 0; // 0: Pré-estabelecidas, 1: Personalizada
  
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(personalizedGoalViewModelProvider);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),
          
          // Tabs
          _buildTabs(),
          
          // Content
          Expanded(
            child: selectedTab == 0
                ? _buildPresetGoalsContent()
                : _buildCustomGoalContent(),
          ),
          
          // Loading overlay
          if (state.isCreatingGoal)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Criando sua meta... ✨',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Criar Meta Semanal',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Escolha uma meta pré-estabelecida ou crie a sua própria',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == 0 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Pré-estabelecidas',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTab == 0 ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selectedTab == 1 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Personalizada',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedTab == 1 ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetGoalsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Projeto 7 Dias
          _buildPresetGoalCard(
            title: 'Projeto 7 Dias',
            description: 'Complete 1 check-in por dia durante 7 dias',
            icon: Icons.check_circle,
            color: Colors.orange,
            type: PersonalizedGoalPresetType.projeto7Dias,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 24),
          
          // Modalidades de Exercício
          _buildPresetGoalCard(
            title: 'Cardio',
            description: 'Complete 3 sessões de cardio por semana',
            icon: Icons.favorite,
            color: const Color(0xFFE74C3C),
            type: PersonalizedGoalPresetType.cardioCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Musculação',
            description: 'Complete 3 sessões de musculação por semana',
            icon: Icons.fitness_center,
            color: const Color(0xFFF39C12),
            type: PersonalizedGoalPresetType.musculacaoCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Funcional',
            description: 'Complete 3 sessões de treino funcional por semana',
            icon: Icons.directions_run,
            color: const Color(0xFF3498DB),
            type: PersonalizedGoalPresetType.funcionalCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Yoga',
            description: 'Complete 3 sessões de yoga por semana',
            icon: Icons.self_improvement,
            color: const Color(0xFF9B59B6),
            type: PersonalizedGoalPresetType.yogaCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Pilates',
            description: 'Complete 3 sessões de pilates por semana',
            icon: Icons.accessibility_new,
            color: const Color(0xFF1ABC9C),
            type: PersonalizedGoalPresetType.pilatesCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'HIIT',
            description: 'Complete 3 sessões de HIIT por semana',
            icon: Icons.whatshot,
            color: const Color(0xFFE67E22),
            type: PersonalizedGoalPresetType.hiitCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Corrida',
            description: 'Complete 3 sessões de corrida por semana',
            icon: Icons.directions_run,
            color: const Color(0xFF27AE60),
            type: PersonalizedGoalPresetType.corridaCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Caminhada',
            description: 'Complete 3 sessões de caminhada por semana',
            icon: Icons.directions_walk,
            color: const Color(0xFF2ECC71),
            type: PersonalizedGoalPresetType.caminhadaCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Natação',
            description: 'Complete 3 sessões de natação por semana',
            icon: Icons.pool,
            color: const Color(0xFF3498DB),
            type: PersonalizedGoalPresetType.natacaoCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Ciclismo',
            description: 'Complete 3 sessões de ciclismo por semana',
            icon: Icons.directions_bike,
            color: const Color(0xFF16A085),
            type: PersonalizedGoalPresetType.ciclismoCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Alongamento',
            description: 'Complete 3 sessões de alongamento por semana',
            icon: Icons.accessibility,
            color: const Color(0xFF8E44AD),
            type: PersonalizedGoalPresetType.alongamentoCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Força',
            description: 'Complete 3 sessões de treino de força por semana',
            icon: Icons.fitness_center,
            color: const Color(0xFF8E44AD),
            type: PersonalizedGoalPresetType.forcaCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Fisioterapia',
            description: 'Complete 3 sessões de fisioterapia por semana',
            icon: Icons.local_hospital,
            color: const Color(0xFF95A5A6),
            type: PersonalizedGoalPresetType.fisioterapiaCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 12),
          
          _buildPresetGoalCard(
            title: 'Flexibilidade',
            description: 'Complete 3 sessões de flexibilidade por semana',
            icon: Icons.accessibility_new,
            color: const Color(0xFFE91E63),
            type: PersonalizedGoalPresetType.flexibilidadeCheck,
            badge: 'Modalidade Check',
          ),
          
          const SizedBox(height: 24),
          
          // Sugestão de hidratação
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyan.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.cyan, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sugestão: Hidratação',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.cyan,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '2 litros de água por dia → 14 check-ins na semana',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.cyan.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _createHydrationGoal(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.cyan),
                    foregroundColor: Colors.cyan,
                  ),
                  child: const Text('Usar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetGoalCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required PersonalizedGoalPresetType type,
    required String badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _createPresetGoal(type),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomGoalContent() {
    return CustomGoalForm(onGoalCreated: widget.onGoalCreated);
  }

  Widget _buildExerciseModalitiesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _exerciseModalities.length,
      itemBuilder: (context, index) {
        final modality = _exerciseModalities[index];
        return _buildExerciseModalityCard(modality);
      },
    );
  }

  Widget _buildExerciseModalityCard(ExerciseModality modality) {
    return GestureDetector(
      onTap: () => _createExerciseGoal(modality),
      child: Container(
        decoration: BoxDecoration(
          color: modality.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: modality.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              modality.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              modality.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: modality.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${modality.defaultMinutes}min/semana',
              style: TextStyle(
                fontSize: 11,
                color: modality.color.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Lista das modalidades de exercício  
  static const List<ExerciseModality> _exerciseModalities = [
    ExerciseModality(
      name: 'Cardio',
      emoji: '❤️',
      color: Color(0xFFE74C3C),
      category: 'cardio',
      defaultMinutes: 150,
    ),
    ExerciseModality(
      name: 'Musculação',
      emoji: '💪',
      color: Color(0xFFF39C12),
      category: 'musculacao',
      defaultMinutes: 180,
    ),
    ExerciseModality(
      name: 'Funcional',
      emoji: '🏃‍♀️',
      color: Color(0xFF3498DB),
      category: 'funcional',
      defaultMinutes: 120,
    ),
    ExerciseModality(
      name: 'Yoga',
      emoji: '🧘‍♀️',
      color: Color(0xFF9B59B6),
      category: 'yoga',
      defaultMinutes: 90,
    ),
    ExerciseModality(
      name: 'Pilates',
      emoji: '🤸‍♀️',
      color: Color(0xFF1ABC9C),
      category: 'pilates',
      defaultMinutes: 90,
    ),
    ExerciseModality(
      name: 'HIIT',
      emoji: '🔥',
      color: Color(0xFFE67E22),
      category: 'hiit',
      defaultMinutes: 90,
    ),
    ExerciseModality(
      name: 'Corrida',
      emoji: '🏃‍♂️',
      color: Color(0xFF27AE60),
      category: 'corrida',
      defaultMinutes: 120,
    ),
    ExerciseModality(
      name: 'Caminhada',
      emoji: '🚶‍♀️',
      color: Color(0xFF2ECC71),
      category: 'caminhada',
      defaultMinutes: 150,
    ),
    ExerciseModality(
      name: 'Natação',
      emoji: '🏊‍♀️',
      color: Color(0xFF3498DB),
      category: 'natacao',
      defaultMinutes: 120,
    ),
    ExerciseModality(
      name: 'Ciclismo',
      emoji: '🚴‍♀️',
      color: Color(0xFF16A085),
      category: 'ciclismo',
      defaultMinutes: 150,
    ),
    ExerciseModality(
      name: 'Alongamento',
      emoji: '🤸',
      color: Color(0xFF8E44AD),
      category: 'alongamento',
      defaultMinutes: 60,
    ),
    ExerciseModality(
      name: 'Força',
      emoji: '🏋️‍♀️',
      color: Color(0xFF8E44AD),
      category: 'forca',
      defaultMinutes: 90,
    ),
    ExerciseModality(
      name: 'Fisioterapia',
      emoji: '🩺',
      color: Color(0xFF95A5A6),
      category: 'fisioterapia',
      defaultMinutes: 60,
    ),
    ExerciseModality(
      name: 'Flexibilidade',
      emoji: '🤸‍♂️',
      color: Color(0xFFE91E63),
      category: 'flexibilidade',
      defaultMinutes: 45,
    ),
  ];

  Widget _buildWorkoutCategoryCard({
    required String title,
    required String description,
    required String emoji,
    required Color color,
    required String category,
    required int defaultMinutes,
    required String badge,
  }) {
    return GestureDetector(
      onTap: () => _createWorkoutCategoryGoal(category, defaultMinutes),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Ícone
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Seta
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createWorkoutCategoryGoal(String category, int defaultMinutes) async {
    try {
      final repository = ref.read(realGoalsRepositoryProvider);
      final userId = ref.read(currentUserIdProvider);
      
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      await repository.createOrUpdateCategoryGoal(userId, category, defaultMinutes);

      if (mounted) {
        widget.onGoalCreated?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meta criada com sucesso! 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar meta: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _createExerciseGoal(ExerciseModality modality) async {
    try {
      final repository = ref.read(realGoalsRepositoryProvider);
      final userId = ref.read(currentUserIdProvider);
      
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      await repository.createOrUpdateCategoryGoal(
        userId,
        modality.category,
        modality.defaultMinutes,
      );

      if (mounted) {
        widget.onGoalCreated?.call();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meta de ${modality.name} criada com sucesso! 🎉'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar meta: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _createPresetGoal(PersonalizedGoalPresetType type) async {
    final success = await ref
        .read(personalizedGoalViewModelProvider.notifier)
        .createPresetGoal(type);
    
    if (success && mounted) {
      widget.onGoalCreated?.call();
      Navigator.of(context).pop();
      _showSuccessMessage();
    }
  }

  void _createHydrationGoal() async {
    final goalData = CreateGoalData.hydrationSuggestion();
    final success = await ref
        .read(personalizedGoalViewModelProvider.notifier)
        .createCustomGoal(goalData);
    
    if (success && mounted) {
      widget.onGoalCreated?.call();
      Navigator.of(context).pop();
      _showSuccessMessage();
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Meta criada com sucesso! ✨'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Formulário para criação de meta personalizada
class CustomGoalForm extends ConsumerStatefulWidget {
  final VoidCallback? onGoalCreated;
  
  const CustomGoalForm({super.key, this.onGoalCreated});

  @override
  ConsumerState<CustomGoalForm> createState() => _CustomGoalFormState();
}

class _CustomGoalFormState extends ConsumerState<CustomGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController();
  
  PersonalizedGoalMeasurementType selectedType = PersonalizedGoalMeasurementType.check;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Título
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Nome da Meta',
                hintText: 'Ex: Hidratação, Meditação, Leitura...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.flag),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome da meta é obrigatório';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Descrição (opcional)
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Descreva sua meta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 20),
            
            // Tipo de medição
            const Text(
              'Tipo de Medição',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildMeasurementTypeSelector(),
            
            const SizedBox(height: 20),
            
            // Target e unidade
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: selectedType.isCheckMode ? 'Quantidade' : 'Valor Alvo',
                      hintText: selectedType.isCheckMode ? '7' : '100',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.track_changes),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Campo obrigatório';
                      }
                      final number = double.tryParse(value);
                      if (number == null || number <= 0) {
                        return 'Valor inválido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: InputDecoration(
                      labelText: 'Unidade',
                      hintText: selectedType.defaultUnit,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Unidade obrigatória';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Botão criar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createCustomGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Criar Meta Personalizada',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Dica
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedType.isCheckMode 
                          ? 'Modalidade Check: você clicará em círculos para marcar conclusão'
                          : 'Modalidade Unidade: você adicionará valores para acompanhar progresso',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PersonalizedGoalMeasurementType.values.map((type) {
        final isSelected = selectedType == type;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedType = type;
              _unitController.text = type.defaultUnit;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? type.color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? type.color : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  type.icon,
                  size: 16,
                  color: isSelected ? type.color : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  type.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? type.color : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _createCustomGoal() async {
    if (!_formKey.currentState!.validate()) return;
    
    final goalData = CreateGoalData(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      measurementType: selectedType,
      targetValue: double.parse(_targetController.text),
      unitLabel: _unitController.text.trim(),
      incrementStep: selectedType.suggestedIncrement,
    );
    
    final success = await ref
        .read(personalizedGoalViewModelProvider.notifier)
        .createCustomGoal(goalData);
    
    if (success && mounted) {
      widget.onGoalCreated?.call();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meta personalizada criada com sucesso! ✨'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
} 