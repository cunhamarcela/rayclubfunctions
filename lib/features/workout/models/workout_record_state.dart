/// Estado para o registro de treinos com prevenção de duplicação
class WorkoutRecordState {
  /// Indica se o envio está em andamento
  final bool isSubmitting;
  
  /// Indica se o envio foi bem-sucedido
  final bool isSuccess;
  
  /// ID do treino registrado (quando sucesso)
  final String? workoutId;
  
  /// Mensagem de erro (quando falha)
  final String? error;
  
  /// Indica se foi salvo offline
  final bool isOfflineSaved;
  
  /// ID do treino pendente salvo offline
  final String? pendingWorkoutId;
  
  /// Construtor
  WorkoutRecordState({
    required this.isSubmitting,
    required this.isSuccess,
    this.workoutId,
    this.error,
    required this.isOfflineSaved,
    this.pendingWorkoutId,
  });
  
  /// Estado inicial
  factory WorkoutRecordState.initial() => WorkoutRecordState(
    isSubmitting: false,
    isSuccess: false,
    isOfflineSaved: false,
  );
  
  /// Cria uma cópia com atributos atualizados
  WorkoutRecordState copyWith({
    bool? isSubmitting,
    bool? isSuccess,
    String? workoutId,
    String? error,
    bool? isOfflineSaved,
    String? pendingWorkoutId,
  }) {
    return WorkoutRecordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      workoutId: workoutId ?? this.workoutId,
      error: error,
      isOfflineSaved: isOfflineSaved ?? this.isOfflineSaved,
      pendingWorkoutId: pendingWorkoutId ?? this.pendingWorkoutId,
    );
  }
} 