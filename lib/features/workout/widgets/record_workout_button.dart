// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/workout/view_model/workout_record_view_model.dart';

/// Botão para registrar treino com prevenção de envio duplicado
class RecordWorkoutButton extends ConsumerWidget {
  /// Parâmetros do treino a ser registrado
  final WorkoutParams params;
  
  /// Texto do botão (opcional)
  final String text;
  
  /// Callback opcional para quando o registro for bem-sucedido
  final VoidCallback? onSuccess;
  
  /// Construtor
  const RecordWorkoutButton({
    Key? key,
    required this.params,
    this.text = 'Registrar Treino',
    this.onSuccess,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observar o estado de registro de treino
    final recordState = ref.watch(workoutRecordViewModelProvider);
    
    return ElevatedButton(
      // Desabilitar o botão quando estiver em andamento
      onPressed: recordState.isSubmitting 
        ? null  // Botão desabilitado quando isSubmitting=true
        : () async {
            // Registrar o treino
            await ref.read(workoutRecordViewModelProvider.notifier).recordWorkout(params);
            
            // Verificar se foi bem-sucedido
            final currentState = ref.read(workoutRecordViewModelProvider);
            if (currentState.isSuccess && onSuccess != null) {
              onSuccess!();
            }
          },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: recordState.isSubmitting
        // Indicador de carregamento quando em andamento
        ? Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16, 
                height: 16, 
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 8),
              const Text('Registrando...'),
            ],
          )
        // Texto normal quando não estiver em andamento
        : Text(text),
    );
  }
} 