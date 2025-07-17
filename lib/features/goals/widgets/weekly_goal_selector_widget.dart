import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/features/goals/models/weekly_goal.dart';
import 'package:ray_club_app/features/goals/viewmodels/weekly_goal_view_model.dart';

/// Widget para seleção de meta semanal
class WeeklyGoalSelectorWidget extends ConsumerStatefulWidget {
  final VoidCallback? onGoalUpdated;

  const WeeklyGoalSelectorWidget({
    super.key,
    this.onGoalUpdated,
  });

  @override
  ConsumerState<WeeklyGoalSelectorWidget> createState() => _WeeklyGoalSelectorWidgetState();
}

class _WeeklyGoalSelectorWidgetState extends ConsumerState<WeeklyGoalSelectorWidget> {
  WeeklyGoalOption? selectedOption;
  final TextEditingController customMinutesController = TextEditingController();
  bool showCustomInput = false;

  @override
  void initState() {
    super.initState();
    // Definir opção selecionada baseada na meta atual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentGoal = ref.read(weeklyGoalViewModelProvider).currentGoal;
      if (currentGoal != null) {
        setState(() {
          selectedOption = WeeklyGoalOption.fromMinutes(currentGoal.goalMinutes);
          if (selectedOption == WeeklyGoalOption.custom) {
            customMinutesController.text = currentGoal.goalMinutes.toString();
            showCustomInput = true;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    customMinutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalState = ref.watch(weeklyGoalViewModelProvider);

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
                'Defina sua Meta Semanal',
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
            'Escolha quantas horas você quer treinar por semana',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),

          // Opções de meta
          ...WeeklyGoalOption.values.map((option) {
            final isSelected = selectedOption == option;
            final isCustom = option == WeeklyGoalOption.custom;

            return Column(
              children: [
                InkWell(
                  onTap: goalState.isUpdating
                      ? null
                      : () {
                          setState(() {
                            selectedOption = option;
                            showCustomInput = isCustom;
                          });

                          if (!isCustom) {
                            // Atualizar meta imediatamente para opções não customizadas
                            _updateGoal(option.minutes);
                          }
                        },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Radio button
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        // Informações da opção
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? AppColors.primary : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isCustom ? option.description : option.formattedTime,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Badge com tempo
                        if (!isCustom)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.2)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              option.description,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected ? AppColors.primary : Colors.grey[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                // Input customizado
                if (isCustom && showCustomInput)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 52, bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customMinutesController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            decoration: InputDecoration(
                              hintText: 'Minutos por semana',
                              suffixText: 'min',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.primary, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: goalState.isUpdating
                              ? null
                              : () {
                                  final minutes = int.tryParse(customMinutesController.text);
                                  if (minutes != null && minutes >= 30 && minutes <= 1440) {
                                    _updateGoal(minutes);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Meta deve estar entre 30 e 1440 minutos'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: goalState.isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Salvar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                
                if (option != WeeklyGoalOption.values.last)
                  const SizedBox(height: 12),
              ],
            );
          }).toList(),

          // Mensagem de erro
          if (goalState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
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
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Dica
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Container(
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
                      'Sua meta será renovada automaticamente toda segunda-feira. Você pode alterá-la a qualquer momento.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                      ),
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

  void _updateGoal(int minutes) async {
    final goalViewModel = ref.read(weeklyGoalViewModelProvider.notifier);
    await goalViewModel.updateGoal(minutes);
    
    // Callback opcional
    widget.onGoalUpdated?.call();
    
    // Mostrar feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Meta atualizada com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
} 