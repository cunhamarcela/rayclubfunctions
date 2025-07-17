import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../viewmodels/register_workout_view_model.dart';

/// Tela para registro de treinos
class RegisterWorkoutScreen extends ConsumerWidget {
  final String? workoutRecordId;
  
  const RegisterWorkoutScreen({
    Key? key, 
    this.workoutRecordId
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(registerWorkoutViewModelProvider.notifier);
    final state = ref.watch(registerWorkoutViewModelProvider);
    
    // Lista de tipos de treino disponíveis (removendo Cardio, Yoga, HIIT conforme solicitado)
    final List<String> _workoutTypes = [
      'Musculação',
      'Funcional',
      'Força',
      'Pilates',
      'Corrida',
      'Fisioterapia',
      'Alongamento',
      'Flexibilidade',
    ];
    
    // Handler para o botão de envio
    void handleSubmit() async {
      // Esconder o teclado
      FocusScope.of(context).unfocus();
      
      await viewModel.submitWorkout(workoutRecordId: workoutRecordId);
      
      // Observar o estado após a submissão
      state.whenData((result) {
        if (result != null && result.success) {
          // Exibir mensagem de sucesso
          if (result.isCheckIn && result.pointsEarned > 0) {
            SnackbarHelper.showSuccess(
              context: context,
              message: 'Treino registrado como check-in! Você ganhou ${result.pointsEarned} pontos.',
            );
          } else {
            SnackbarHelper.showSuccess(
              context: context,
              message: result.message,
            );
          }
          
          // Se for uma edição, voltar após salvar
          if (workoutRecordId != null) {
            Navigator.of(context).pop();
          }
        }
      });
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          workoutRecordId != null ? 'Editar Treino' : 'Registrar Treino',
          style: AppTypography.titleMedium,
        ),
      ),
      body: SafeArea(
        child: state.maybeWhen(
          error: (error, stackTrace) => _buildErrorView(context, error),
          loading: () => const Center(child: CircularProgressIndicator()),
          orElse: () => _buildForm(context, viewModel, _workoutTypes, state),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: state.isLoading ? null : handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: state.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  workoutRecordId != null ? 'Salvar Alterações' : 'Registrar Treino',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
  
  /// Constrói a view de erro
  Widget _buildErrorView(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao processar',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Constrói o formulário
  Widget _buildForm(
    BuildContext context, 
    RegisterWorkoutViewModel viewModel,
    List<String> workoutTypes,
    AsyncValue<WorkoutRegistrationResult?> state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do treino
          TextField(
            controller: viewModel.nameController,
            decoration: const InputDecoration(
              labelText: 'Nome do treino',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fitness_center),
            ),
          ),
          const SizedBox(height: 16),
          
          // Tipo de treino
          DropdownButtonFormField<String>(
            value: viewModel.selectedType,
            decoration: const InputDecoration(
              labelText: 'Tipo de treino',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.category),
            ),
            items: workoutTypes.map((type) => 
              DropdownMenuItem(
                value: type,
                child: Text(type),
              )
            ).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.selectedType = value;
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Duração
          TextField(
            controller: viewModel.durationController,
            decoration: const InputDecoration(
              labelText: 'Duração (minutos)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer),
              helperText: 'Mínimo de 45 minutos para contar como check-in',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          
          // Data e hora
          InkWell(
            onTap: () => _selectDateTime(context, viewModel),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Data e hora',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm').format(viewModel.selectedDate),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Notas
          TextField(
            controller: viewModel.notesController,
            decoration: const InputDecoration(
              labelText: 'Notas (opcional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
              helperText: 'Detalhes sobre o treino, intensidade, etc.',
            ),
            maxLines: 3,
          ),
          
          // Exibe mensagem sobre check-in quando há um resultado
          if (state.hasValue && state.valueOrNull?.isCheckIn == true) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este treino conta como check-in! Você ganhou ${state.valueOrNull?.pointsEarned} pontos.',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Explicação sobre check-in
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sobre check-ins',
                  style: AppTypography.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  '• Treinos com duração a partir de 45 minutos contam como check-in\n'
                  '• Apenas um check-in por dia é contabilizado\n'
                  '• Check-ins concluídos geram pontos no ranking dos desafios',
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Abre seletor de data e hora
  Future<void> _selectDateTime(BuildContext context, RegisterWorkoutViewModel viewModel) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione a data do treino',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      fieldHintText: 'dd/mm/aaaa',
      fieldLabelText: 'Data do treino',
      errorFormatText: 'Digite uma data válida no formato dd/mm/aaaa',
      errorInvalidText: 'Digite uma data válida',
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(viewModel.selectedDate),
        helpText: 'Selecione a hora do treino',
        cancelText: 'Cancelar',
        confirmText: 'Confirmar',
        hourLabelText: 'Hora',
        minuteLabelText: 'Minuto',
        errorInvalidText: 'Digite uma hora válida',
      );
      
      if (pickedTime != null) {
        viewModel.selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
    }
  }
} 