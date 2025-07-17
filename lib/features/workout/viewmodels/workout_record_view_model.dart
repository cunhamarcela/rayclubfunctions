// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/core/providers/providers.dart'; // Para authRepositoryProvider
import 'package:ray_club_app/features/workout/models/workout_record.dart';
import 'package:ray_club_app/features/workout/repositories/workout_record_repository.dart';
import 'package:ray_club_app/services/workout_challenge_service.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';

part 'workout_record_view_model.freezed.dart';

/// Estado para o gerenciamento do registro de treinos
@freezed
class WorkoutRecordState with _$WorkoutRecordState {
  const factory WorkoutRecordState({
    @Default(false) bool isLoading,
    @Default([]) List<WorkoutRecord> records,
    @Default('Funcional') String selectedWorkoutType,
    @Default(0.3) double intensity,
    @Default([]) List<XFile> selectedImages,
    String? errorMessage,
    String? successMessage,
  }) = _WorkoutRecordState;
}

/// Provider para o WorkoutRecordViewModel
final workoutRecordViewModelProvider = StateNotifierProvider<WorkoutRecordViewModel, WorkoutRecordState>((ref) {
  final repository = ref.watch(workoutRecordRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  final challengeService = ref.watch(workoutChallengeServiceProvider);
  
  return WorkoutRecordViewModel(
    repository: repository,
    authRepository: authRepository,
    challengeService: challengeService,
    ref: ref,
  );
});

/// ViewModel para gerenciar o registro de treinos
class WorkoutRecordViewModel extends StateNotifier<WorkoutRecordState> {
  final WorkoutRecordRepository _repository;
  final IAuthRepository _authRepository;
  final WorkoutChallengeService _challengeService;
  final Ref ref;
  
  /// Construtor
  WorkoutRecordViewModel({
    required WorkoutRecordRepository repository,
    required IAuthRepository authRepository,
    required WorkoutChallengeService challengeService,
    required this.ref,
  }) : 
    _repository = repository,
    _authRepository = authRepository,
    _challengeService = challengeService,
    super(const WorkoutRecordState());

  /// Lista de tipos de treino disponíveis (removendo Cardio, Yoga, HIIT conforme solicitado)
  List<String> get workoutTypes => [
    'Funcional',
    'Musculação',
    'Pilates',
    'Força',
    'Alongamento',
    'Corrida',
    'Fisioterapia',
    'Outro'
  ];

  /// Atualiza o tipo de treino selecionado
  void updateWorkoutType(String workoutType) {
    state = state.copyWith(selectedWorkoutType: workoutType);
  }

  /// Atualiza o valor da intensidade do treino
  void updateIntensity(double intensity) {
    state = state.copyWith(intensity: intensity);
  }

  /// Obtém o texto da intensidade com base no valor
  String get intensityText {
    if (state.intensity < 0.33) return 'Leve';
    if (state.intensity < 0.66) return 'Moderada';
    return 'Intensa';
  }

  /// Adiciona uma imagem selecionada
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> selectedImages = await picker.pickMultiImage();
      
      if (selectedImages.isNotEmpty) {
        final currentImages = [...state.selectedImages];
        
        // Se não tem nenhuma imagem ainda, adiciona as novas
        if (currentImages.isEmpty) {
          // Limita a 3 imagens
          final imagesToAdd = selectedImages.length > 3 ? selectedImages.sublist(0, 3) : selectedImages;
          state = state.copyWith(selectedImages: imagesToAdd);
        } 
        // Se já tem imagens, mas menos de 3, adiciona até completar 3
        else if (currentImages.length < 3) {
          final int remaining = 3 - currentImages.length;
          final imagesToAdd = selectedImages.length > remaining ? 
              selectedImages.sublist(0, remaining) : 
              selectedImages;
          
          currentImages.addAll(imagesToAdd);
          state = state.copyWith(selectedImages: currentImages);
        } 
        // Se já tem 3 imagens, substitui as existentes
        else if (selectedImages.length >= 3) {
          // Se selecionou 3 ou mais, pega as 3 primeiras
          state = state.copyWith(selectedImages: selectedImages.sublist(0, 3));
        } else {
          // Se selecionou menos de 3, substitui as primeiras
          final newImages = List<XFile>.from(currentImages);
          for (int i = 0; i < selectedImages.length; i++) {
            newImages[i] = selectedImages[i];
          }
          state = state.copyWith(selectedImages: newImages);
        }
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao selecionar imagens: $e',
      );
    }
  }

  /// Adiciona um novo registro de treino
  Future<void> addWorkoutRecord({
    required String workoutName,
    required String workoutType,
    required DateTime date,
    required int durationMinutes,
    required bool isCompleted,
    String? notes,
    String? workoutId,
    List<XFile>? imagesToUpload,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw const AppException(
          message: 'Usuário não autenticado',
          code: 'auth_required',
        );
      }

      // Converter XFile para File se necessário
      List<File>? imageFiles;
      if (imagesToUpload != null && imagesToUpload.isNotEmpty) {
        imageFiles = imagesToUpload.map((xFile) => File(xFile.path)).toList();
      }

      // Criar o registro do treino
      final workoutRecord = WorkoutRecord(
        id: const Uuid().v4(),
        userId: user.id,
        workoutId: workoutId,
        workoutName: workoutName,
        workoutType: workoutType,
        date: date,
        durationMinutes: durationMinutes,
        isCompleted: isCompleted,
        notes: notes,
        imageUrls: const [], // Será preenchido após upload das imagens
      );

      // Salvar registro e fazer upload de imagens se necessário
      final savedRecord = await _repository.createWorkoutRecord(
        workoutRecord,
        images: imageFiles,
      );

      // Atualizar o estado com sucesso
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Treino registrado com sucesso!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException 
            ? e.message 
            : 'Erro ao adicionar treino: ${e.toString()}',
      );
    }
  }

  /// Carrega o histórico de treinos do usuário atual
  Future<void> loadUserWorkoutRecords() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final records = await _repository.getUserWorkoutRecords();
      
      state = state.copyWith(
        isLoading: false,
        records: records,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao carregar histórico de treinos: $e',
      );
    }
  }

  /// Remove um registro de treino
  Future<void> deleteWorkoutRecord(String recordId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await _repository.deleteWorkoutRecord(recordId);
      
      // Atualizar a lista removendo o registro deletado
      final updatedRecords = state.records.where((record) => record.id != recordId).toList();
      
      state = state.copyWith(
        isLoading: false,
        records: updatedRecords,
        successMessage: 'Registro de treino excluído com sucesso!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is AppException ? e.message : 'Erro ao excluir registro: $e',
      );
    }
  }
} 