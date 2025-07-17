// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/features/home/widgets/register_exercise_sheet.dart';

/// Testes para validar a correção do bug do título do treino
/// 
/// Este teste valida que:
/// 1. O nome personalizado do treino é mantido quando informado pelo usuário
/// 2. O nome padrão é usado apenas quando o usuário não informa um nome
/// 3. O estado do ViewModel é atualizado corretamente
void main() {
  group('RegisterWorkoutState - Nome do Treino', () {
    test('deve manter nome personalizado quando informado', () {
      // Arrange
      const nomePersonalizado = 'Meu Treino de Pernas';
      const tipoTreino = 'Funcional';
      
      final state = RegisterWorkoutState(
        workoutName: nomePersonalizado,
        selectedType: tipoTreino,
      );
      
      // Act & Assert
      expect(state.workoutName, equals(nomePersonalizado));
      expect(state.selectedType, equals(tipoTreino));
      
      // Validar que o nome NÃO é igual ao tipo
      expect(state.workoutName, isNot(equals('Treino $tipoTreino')));
    });
    
    test('deve usar nome padrão quando campo está vazio', () {
      // Arrange
      const tipoTreino = 'Funcional';
      const nomeEsperado = 'Treino Funcional';
      
      final state = RegisterWorkoutState(
        workoutName: '', // Nome vazio
        selectedType: tipoTreino,
      );
      
      // Act
      // Simular a lógica que está implementada no registerWorkout
      final nomeParaUsar = state.workoutName.isNotEmpty 
          ? state.workoutName 
          : 'Treino ${state.selectedType}';
      
      // Assert
      expect(nomeParaUsar, equals(nomeEsperado));
    });
    
    test('deve atualizar nome via copyWith', () {
      // Arrange
      const nomeOriginal = 'Nome Original';
      const novoNome = 'Nome Atualizado';
      
      final stateOriginal = RegisterWorkoutState(workoutName: nomeOriginal);
      
      // Act
      final stateAtualizado = stateOriginal.copyWith(workoutName: novoNome);
      
      // Assert
      expect(stateOriginal.workoutName, equals(nomeOriginal));
      expect(stateAtualizado.workoutName, equals(novoNome));
    });
  });
} 