// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../models/unified_goal_model.dart';
import '../viewmodels/create_goal_view_model.dart';
import 'widgets/goal_type_selector.dart';
import 'widgets/workout_category_selector.dart';
import 'widgets/measurement_type_selector.dart';
import 'widgets/custom_goal_form.dart';

/// **TELA DE CRIAÇÃO DE METAS - RAY CLUB**
/// 
/// **Data:** 30 de Janeiro de 2025 às 16:00
/// **Objetivo:** Implementar criação de metas exatamente conforme especificação
/// **Funcionalidades:**
/// 1. Meta personalizada (usuário escreve título livre)
/// 2. Meta pré-definida (seleciona da lista de exercícios)
/// 3. Medição por minutos ou dias (check-ins)
/// 4. Integração automática com workout_records
class CreateGoalScreen extends ConsumerStatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  ConsumerState<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends ConsumerState<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  
  // Estado da seleção
  GoalCreationType _selectedType = GoalCreationType.predefined;
  String? _selectedCategory;
  MeasurementType _measurementType = MeasurementType.minutes;
  
  @override
  void dispose() {
    _titleController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createGoalState = ref.watch(createGoalViewModelProvider);
    
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: CustomAppBar(
        title: 'Nova Meta',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header explicativo
              _buildHeader(),
              
              const SizedBox(height: 32),
              
              // 1. Seletor de tipo de meta (Personalizada vs Pré-definida)
              _buildGoalTypeSelector(),
              
              const SizedBox(height: 24),
              
              // 2. Campo de título ou seletor de categoria
              _buildTitleOrCategorySelector(),
              
              const SizedBox(height: 24),
              
              // 3. Seletor de tipo de medição (minutos vs dias)
              _buildMeasurementTypeSelector(),
              
              const SizedBox(height: 24),
              
              // 4. Campo de meta alvo
              _buildTargetField(),
              
              const SizedBox(height: 32),
              
              // 5. Botão de criar meta
              _buildCreateButton(createGoalState),
              
              const SizedBox(height: 16),
              
              // Mostrar loading ou erro
              if (createGoalState.isLoading) _buildLoadingState(),
              if (createGoalState.errorMessage != null) _buildErrorState(createGoalState.errorMessage!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Defina sua Meta Semanal',
          style: AppTypography.headingH2.copyWith(
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crie uma meta personalizada ou escolha uma modalidade de exercício. '
          'Suas metas podem ser medidas em minutos ou em dias de prática.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalTypeSelector() {
    return GoalTypeSelector(
      selectedType: _selectedType,
      onTypeChanged: (type) {
        setState(() {
          _selectedType = type;
          // Limpar seleções ao trocar tipo
          if (type == GoalCreationType.custom) {
            _selectedCategory = null;
          } else {
            _titleController.clear();
          }
        });
      },
    );
  }

  Widget _buildTitleOrCategorySelector() {
    if (_selectedType == GoalCreationType.custom) {
      return CustomGoalForm(
        titleController: _titleController,
      );
    } else {
      return WorkoutCategorySelector(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
        },
      );
    }
  }

  Widget _buildMeasurementTypeSelector() {
    return MeasurementTypeSelector(
      selectedType: _measurementType,
      onTypeChanged: (type) {
        setState(() {
          _measurementType = type;
          // Limpar valor alvo ao trocar tipo
          _targetController.clear();
        });
      },
    );
  }

  Widget _buildTargetField() {
    final String unit = _measurementType == MeasurementType.minutes ? 'minutos' : 'dias';
    final String hint = _measurementType == MeasurementType.minutes 
        ? 'Ex: 150 minutos por semana'
        : 'Ex: 5 dias por semana';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meta da semana',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _targetController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant.withOpacity(0.3),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Digite a meta de $unit';
            }
            final number = int.tryParse(value);
            if (number == null || number <= 0) {
              return 'Digite um número válido maior que zero';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCreateButton(CreateGoalState state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: state.isLoading ? null : _createGoal,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Criar Meta ✨',
          style: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text(
            'Criando sua meta...',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createGoal() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar seleções específicas
    if (_selectedType == GoalCreationType.predefined && _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione uma modalidade de exercício')),
      );
      return;
    }

    final target = double.parse(_targetController.text);
    final title = _selectedType == GoalCreationType.custom 
        ? _titleController.text
        : _selectedCategory!;

    final viewModel = ref.read(createGoalViewModelProvider.notifier);
    
    final success = await viewModel.createGoal(
      title: title,
      category: _selectedType == GoalCreationType.predefined ? _selectedCategory : null,
      measurementType: _measurementType == MeasurementType.minutes ? 'minutes' : 'days',
      targetValue: target,
      isCustom: _selectedType == GoalCreationType.custom,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meta criada com sucesso! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}

/// Enum para tipo de criação de meta
enum GoalCreationType {
  predefined, // Meta pré-definida (da lista de exercícios)
  custom, // Meta personalizada (título livre)
}

/// Enum para tipo de medição
enum MeasurementType {
  minutes, // Medida em minutos
  days, // Medida em dias (check-ins)
}

