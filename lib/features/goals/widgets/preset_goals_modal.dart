import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../models/preset_category_goals.dart';
import '../repositories/workout_category_goals_repository.dart';
import 'goal_creation_modal.dart';

/// Modal simplificado para criar metas usando presets
class PresetGoalsModal extends ConsumerStatefulWidget {
  final VoidCallback? onGoalCreated;
  
  const PresetGoalsModal({super.key, this.onGoalCreated});

  /// Mostra o modal
  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PresetGoalsModal(),
    );
  }

  @override
  ConsumerState<PresetGoalsModal> createState() => _PresetGoalsModalState();
}

class _PresetGoalsModalState extends ConsumerState<PresetGoalsModal> {
  PresetCategoryGoal? _selectedPreset;
  GoalUnit _selectedUnit = GoalUnit.minutes;
  int? _selectedValue;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descrição simples
              Text(
                'Escolha uma meta para se manter motivado durante a semana 🎯',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Título da seção de metas populares
              Text(
                'Metas Populares',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Grid de metas pré-estabelecidas com scroll 
              SizedBox(
                height: 400, // Altura fixa para evitar overflow
                child: _buildPresetGrid(),
              ),

              if (_selectedPreset != null) ...[
                const SizedBox(height: 24),
                _buildGoalConfiguration(),
              ],

              const SizedBox(height: 32),

              // Seção de Meta Personalizada
              _buildCustomGoalSection(),

              const SizedBox(height: 24),

              // Botão de criar meta
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedPreset != null && _selectedValue != null && !_isLoading
                      ? _createGoal
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedPreset?.color ?? AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Criar Meta ${_selectedPreset?.displayName ?? ""}',
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // Info adicional
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sua meta será renovada automaticamente toda segunda-feira. Você pode alterá-la a qualquer momento! 📅',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetGrid() {
    final presets = PresetCategoryGoal.allPresets;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: presets.length,
      itemBuilder: (context, index) {
        final preset = presets[index];
        final isSelected = _selectedPreset == preset;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedPreset = preset;
              _selectedValue = preset.defaultMinutes;
              _selectedUnit = GoalUnit.minutes;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? preset.lightColor : Colors.grey.shade50,
              border: Border.all(
                color: isSelected ? preset.color : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  preset.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  preset.displayName,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? preset.color : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  preset.formatMinutes(preset.defaultMinutes),
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? preset.color : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoalConfiguration() {
    if (_selectedPreset == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da configuração
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _selectedPreset!.lightColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(
                _selectedPreset!.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPreset!.displayName,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _selectedPreset!.color,
                      ),
                    ),
                    Text(
                      _selectedPreset!.motivationalText,
                      style: AppTypography.bodySmall.copyWith(
                        color: _selectedPreset!.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Seletor de unidade
        Text(
          'Tipo de medição',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildUnitSelector(GoalUnit.minutes),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUnitSelector(GoalUnit.days),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Seletor de valor
        Text(
          _selectedUnit == GoalUnit.minutes ? 'Meta em minutos' : 'Meta em dias',
          style: AppTypography.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        _buildValueSelector(),
      ],
    );
  }

  Widget _buildUnitSelector(GoalUnit unit) {
    final isSelected = _selectedUnit == unit;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUnit = unit;
          if (unit == GoalUnit.minutes) {
            _selectedValue = _selectedPreset!.defaultMinutes;
          } else {
            _selectedValue = _selectedPreset!.suggestedDays.first;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? _selectedPreset!.color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _selectedPreset!.color : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unit == GoalUnit.minutes ? Icons.access_time : Icons.calendar_today,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              unit.label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueSelector() {
    final suggestions = _selectedUnit == GoalUnit.minutes
        ? _selectedPreset!.suggestedMinutes
        : _selectedPreset!.suggestedDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botões de sugestões rápidas
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((value) {
            final isSelected = _selectedValue == value;
            final displayText = _selectedUnit == GoalUnit.minutes
                ? _selectedPreset!.formatMinutes(value)
                : '$value ${value == 1 ? "dia" : "dias"}';

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedValue = value;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _selectedPreset!.color : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? _selectedPreset!.color : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  displayText,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Campo customizado
        Text(
          'Ou digite um valor personalizado:',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: _selectedUnit == GoalUnit.minutes ? 'Ex: 90' : 'Ex: 5',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _selectedPreset!.color),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  final intValue = int.tryParse(value);
                  if (intValue != null && intValue > 0) {
                    setState(() {
                      _selectedValue = intValue;
                    });
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _selectedPreset!.lightColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedPreset!.color),
              ),
              child: Text(
                _selectedUnit.label,
                style: AppTypography.bodyMedium.copyWith(
                  color: _selectedPreset!.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomGoalSection() {
    return GestureDetector(
      onTap: () {
        // Fechar modal atual e abrir modal de meta personalizada
        Navigator.of(context).pop();
        _openCustomGoalModal();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meta Personalizada',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Crie sua própria meta customizada',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openCustomGoalModal() async {
    // Fechar modal atual
    Navigator.of(context).pop();
    
    // Abrir modal de meta personalizada
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GoalCreationModal(),
    );
    
    // Refresh após criar meta personalizada
    if (widget.onGoalCreated != null) {
      widget.onGoalCreated!();
    }
  }

  Future<void> _createGoal() async {
    if (_selectedPreset == null || _selectedValue == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(workoutCategoryGoalsRepositoryProvider);
      
      // Converter para minutos se necessário
      int goalMinutes = _selectedValue!;
      if (_selectedUnit == GoalUnit.days) {
        // Assumir 30 minutos por sessão para conversão de dias para minutos
        goalMinutes = _selectedValue! * 30;
      }

      await repository.setCategoryGoal(
        _selectedPreset!.category,
        goalMinutes,
      );

      if (mounted) {
        SnackbarHelper.showSuccess(
          context: context,
          message: 'Meta criada com sucesso! 🎉',
        );
        widget.onGoalCreated?.call();
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(
          context: context,
          message: 'Erro ao criar meta: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 