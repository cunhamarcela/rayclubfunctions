import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/goals/models/weekly_goal_expanded.dart';
import 'package:ray_club_app/features/goals/viewmodels/weekly_goal_expanded_view_model.dart';

/// Widget expandido para seleção de metas semanais
class WeeklyGoalSelectorExpandedWidget extends ConsumerStatefulWidget {
  final VoidCallback? onGoalCreated;

  const WeeklyGoalSelectorExpandedWidget({
    super.key,
    this.onGoalCreated,
  });

  @override
  ConsumerState<WeeklyGoalSelectorExpandedWidget> createState() => 
      _WeeklyGoalSelectorExpandedWidgetState();
}

class _WeeklyGoalSelectorExpandedWidgetState 
    extends ConsumerState<WeeklyGoalSelectorExpandedWidget> {
  GoalPresetType? selectedPresetType;
  WeeklyGoalExpandedPreset? selectedPreset;
  bool showCustomForm = false;
  
  // Controladores para meta personalizada
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController targetValueController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  
  GoalMeasurementType selectedMeasurementType = GoalMeasurementType.minutes;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    targetValueController.dispose();
    unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(weeklyGoalExpandedViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Row(
            children: [
              Icon(
                Icons.flag,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Defina sua Meta Semanal ✨',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha uma meta para se manter motivado durante a semana 🌱',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Opções pré-estabelecidas
          if (!showCustomForm) ...[
            const Text(
              'Metas Populares',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),
            
            // Projeto Bruna Braga
            _buildPresetOption(
              GoalPresetType.projetoBrunaBraga.defaultValues,
              Icons.fitness_center,
              Colors.pink,
              '7 dias seguindo o programa especial! 💪',
            ),
            
            const SizedBox(height: 12),
            
            // Opções de Cardio
            const Text(
              'Cardio',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildQuickPresetOption(
                    WeeklyGoalExpandedPreset(
                      goalType: GoalPresetType.cardio,
                      measurementType: GoalMeasurementType.minutes,
                      targetValue: 150,
                      unitLabel: 'min',
                      title: 'Cardio - 150min',
                      description: '150 minutos de cardio por semana',
                    ),
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickPresetOption(
                    WeeklyGoalExpandedPreset(
                      goalType: GoalPresetType.cardio,
                      measurementType: GoalMeasurementType.days,
                      targetValue: 3,
                      unitLabel: 'dias',
                      title: 'Cardio - 3 dias',
                      description: '3 dias de cardio por semana',
                    ),
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Opções de Musculação
            const Text(
              'Musculação',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildQuickPresetOption(
                    WeeklyGoalExpandedPreset(
                      goalType: GoalPresetType.musculacao,
                      measurementType: GoalMeasurementType.minutes,
                      targetValue: 180,
                      unitLabel: 'min',
                      title: 'Musculação - 180min',
                      description: '3 horas de musculação por semana',
                    ),
                    Icons.sports_gymnastics,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildQuickPresetOption(
                    WeeklyGoalExpandedPreset(
                      goalType: GoalPresetType.musculacao,
                      measurementType: GoalMeasurementType.days,
                      targetValue: 4,
                      unitLabel: 'dias',
                      title: 'Musculação - 4 dias',
                      description: '4 dias de musculação por semana',
                    ),
                    Icons.sports_gymnastics,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Botão para meta personalizada
            InkWell(
              onTap: () {
                setState(() {
                  showCustomForm = true;
                  selectedPresetType = GoalPresetType.custom;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.grey[600], size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Meta Personalizada',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Crie sua própria meta customizada',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, 
                         color: Colors.grey[400], size: 16),
                  ],
                ),
              ),
            ),
          ],

          // Formulário de meta personalizada
          if (showCustomForm) ...[
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      showCustomForm = false;
                      selectedPresetType = null;
                      _clearCustomForm();
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                const Text(
                  'Meta Personalizada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Nome da meta
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Nome da meta',
                hintText: 'Ex: Correr toda semana',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 16),
            
            // Tipo de medição
            DropdownButtonFormField<GoalMeasurementType>(
              value: selectedMeasurementType,
              decoration: InputDecoration(
                labelText: 'Tipo de medição',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: Icon(selectedMeasurementType.icon),
              ),
              items: WeeklyGoalQuickOptions.availableMeasurementTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedMeasurementType = value;
                    unitController.text = value.defaultUnit;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Valor alvo e unidade
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: targetValueController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                    ],
                    decoration: InputDecoration(
                      labelText: 'Meta',
                      hintText: '150',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.track_changes),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    decoration: InputDecoration(
                      labelText: 'Unidade',
                      hintText: 'min',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Descrição (opcional)
            TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Descreva sua meta...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 20),
            
            // Botão criar meta personalizada
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: goalState.isUpdating ? null : _createCustomGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: goalState.isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Criar Meta Personalizada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],

          // Info box
          if (!showCustomForm) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sua meta será renovada automaticamente toda segunda-feira. Você pode alterá-la a qualquer momento! 📅',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Mostrar erro se houver
          if (goalState.error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      goalState.error!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPresetOption(
    WeeklyGoalExpandedPreset preset,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return InkWell(
      onTap: () => _createPresetGoal(preset),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${preset.targetValue.round()} ${preset.unitLabel}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: color,
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

  Widget _buildQuickPresetOption(
    WeeklyGoalExpandedPreset preset,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => _createPresetGoal(preset),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              '${preset.targetValue.round()} ${preset.unitLabel}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPresetGoal(WeeklyGoalExpandedPreset preset) async {
    try {
      print('🎯 DEBUG: Criando meta preset: ${preset.title} (${preset.goalType})');
      
      final viewModel = ref.read(weeklyGoalExpandedViewModelProvider.notifier);
      
      // Usar função específica baseada no tipo de preset
      final goal = await viewModel.createPresetGoal(preset.goalType);
      
      if (goal != null) {
        print('🎯 DEBUG: ✅ Meta preset criada com sucesso: ${preset.title}');
        _showSuccessMessage(preset.title);
        widget.onGoalCreated?.call();
      } else {
        print('🚨 DEBUG: ❌ Falha ao criar meta preset: resultado null');
        _showErrorMessage('Erro ao criar meta. Tente novamente.');
      }
    } catch (e) {
      print('🚨 DEBUG: ERRO ao criar meta preset: $e');
      _showErrorMessage('Erro ao criar meta: ${e.toString()}');
    }
  }

  Future<void> _createCustomGoal() async {
    if (titleController.text.trim().isEmpty || 
        targetValueController.text.trim().isEmpty ||
        unitController.text.trim().isEmpty) {
      _showErrorMessage('Por favor, preencha todos os campos obrigatórios');
      return;
    }

    final targetValue = double.tryParse(targetValueController.text);
    if (targetValue == null || targetValue <= 0) {
      _showErrorMessage('Por favor, insira um valor válido para a meta');
      return;
    }

    final viewModel = ref.read(weeklyGoalExpandedViewModelProvider.notifier);
    
    final goal = await viewModel.createCustomGoal(
      goalTitle: titleController.text.trim(),
      goalDescription: descriptionController.text.trim().isNotEmpty 
          ? descriptionController.text.trim() 
          : null,
      measurementType: selectedMeasurementType,
      targetValue: targetValue,
      unitLabel: unitController.text.trim(),
    );
    
    if (goal != null) {
      _showSuccessMessage(titleController.text.trim());
      widget.onGoalCreated?.call();
    }
  }

  void _clearCustomForm() {
    titleController.clear();
    descriptionController.clear();
    targetValueController.clear();
    unitController.text = selectedMeasurementType.defaultUnit;
  }

  void _showSuccessMessage(String goalTitle) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meta "$goalTitle" criada com sucesso! ✨'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
} 