import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/workout_record_repository.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../../../features/challenges/repositories/challenge_repository.dart';

/// Estados possíveis para o ViewModel de registro de treino
enum RegisterWorkoutState {
  initial,
  loading,
  success,
  error,
}

/// Classe para armazenar o resultado do registro de treino
class WorkoutRegistrationResult {
  final bool success;
  final bool isCheckIn;
  final int pointsEarned;
  final String message;
  final String? recordId;
  final Map<String, dynamic>? rawData;

  WorkoutRegistrationResult({
    required this.success,
    required this.isCheckIn,
    required this.pointsEarned,
    required this.message,
    this.recordId,
    this.rawData,
  });

  factory WorkoutRegistrationResult.fromJson(Map<String, dynamic> json) {
    return WorkoutRegistrationResult(
      success: json['success'] as bool? ?? false,
      isCheckIn: json['is_check_in'] as bool? ?? false,
      pointsEarned: json['points_earned'] as int? ?? 0,
      message: json['message'] as String? ?? 'Operação concluída',
      recordId: json['record_id'] as String?,
      rawData: json,
    );
  }
}

/// Provider para o ViewModel de registro de treino
final registerWorkoutViewModelProvider = StateNotifierProvider.autoDispose<RegisterWorkoutViewModel, AsyncValue<WorkoutRegistrationResult?>>((ref) {
  final workoutRepository = ref.watch(workoutRecordRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final challengeRepository = ref.watch(challengeRepositoryProvider);

  return RegisterWorkoutViewModel(
    workoutRepository: workoutRepository,
    authRepository: authRepository,
    challengeRepository: challengeRepository,
  );
});

/// ViewModel para a tela de registro de treino
class RegisterWorkoutViewModel extends StateNotifier<AsyncValue<WorkoutRegistrationResult?>> {
  final WorkoutRecordRepository workoutRepository;
  final AuthRepository authRepository;
  final ChallengeRepository challengeRepository;

  // Controllers para os campos do formulário
  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  
  // Estado do formulário
  String _selectedType = 'Outro';
  DateTime _selectedDate = DateTime.now();
  String? _activeChallenge;

  RegisterWorkoutViewModel({
    required this.workoutRepository,
    required this.authRepository,
    required this.challengeRepository,
  }) : super(const AsyncValue.data(null)) {
    _initialize();
  }

  // Getters para os valores atuais
  String get selectedType => _selectedType;
  DateTime get selectedDate => _selectedDate;
  String? get activeChallenge => _activeChallenge;

  // Setters para atualizar os valores
  set selectedType(String value) {
    _selectedType = value;
  }
  
  set selectedDate(DateTime value) {
    _selectedDate = value;
  }

  Future<void> _initialize() async {
    try {
      // Carregar o desafio ativo atual
      final activeChallenge = await challengeRepository.getCurrentActiveChallenge();
      if (activeChallenge != null) {
        _activeChallenge = activeChallenge.id;
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar desafio ativo: $e');
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    durationController.dispose();
    super.dispose();
  }

  /// Submete o registro de treino
  Future<void> submitWorkout({String? workoutRecordId}) async {
    if (!_validateInputs()) {
      return;
    }

    try {
      state = const AsyncValue.loading();

      final currentUser = await authRepository.getCurrentUser();
      if (currentUser == null) {
        state = AsyncValue.error(
          Exception('Usuário não autenticado'), 
          StackTrace.current
        );
        return;
      }

      // Obter o challenger ID (pode ser passado ou usar o ativo)
      final challengeId = _activeChallenge ?? '';
      
      // Chamar o método do repositório
      final result = await workoutRepository.saveWorkoutRecord(
        userId: currentUser.id,
        challengeId: challengeId,
        workoutName: nameController.text.trim(),
        workoutType: selectedType,
        durationMinutes: int.parse(durationController.text),
        date: selectedDate,
        notes: notesController.text,
        workoutRecordId: workoutRecordId,
      );

      // Converter o resultado para um objeto estruturado
      final workoutResult = WorkoutRegistrationResult.fromJson(result);
      
      // Atualizar o estado
      state = AsyncValue.data(workoutResult);
      
      // Limpar o formulário em caso de sucesso e sem edição
      if (workoutResult.success && workoutRecordId == null) {
        _resetForm();
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Valida os campos do formulário
  bool _validateInputs() {
    // Verificar nome do treino
    if (nameController.text.trim().isEmpty) {
      state = AsyncValue.error(
        Exception('O nome do treino é obrigatório'), 
        StackTrace.current
      );
      return false;
    }

    // Verificar tipo de treino
    if (_selectedType.isEmpty) {
      state = AsyncValue.error(
        Exception('Selecione um tipo de treino'), 
        StackTrace.current
      );
      return false;
    }

    // Verificar duração (deve ser um número positivo)
    try {
      final duration = int.parse(durationController.text);
      if (duration <= 0) {
        state = AsyncValue.error(
          Exception('A duração deve ser maior que zero'), 
          StackTrace.current
        );
        return false;
      }
    } catch (e) {
      state = AsyncValue.error(
        Exception('Informe uma duração válida em minutos'), 
        StackTrace.current
      );
      return false;
    }

    return true;
  }

  /// Reseta o formulário para os valores iniciais
  void _resetForm() {
    nameController.clear();
    notesController.clear();
    durationController.clear();
    _selectedType = 'Outro';
    _selectedDate = DateTime.now();
  }
} 