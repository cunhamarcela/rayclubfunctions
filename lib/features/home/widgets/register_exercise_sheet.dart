// Flutter imports:
import 'dart:io';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Project imports:
// import '../../../core/constants/app_colors.dart';
import '../../../core/providers/providers.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../features/auth/repositories/auth_repository.dart';
import '../../../features/challenges/providers/challenge_providers.dart';
import '../../ranking/providers/ranking_refresh_provider.dart';
import '../../../features/challenges/repositories/challenge_repository.dart';
import '../../../features/challenges/services/workout_challenge_service.dart';
import '../../../features/challenges/viewmodels/challenge_view_model.dart';
import '../../../features/dashboard/providers/dashboard_providers.dart';
import '../../../features/dashboard/viewmodels/dashboard_view_model.dart';
import '../../../features/workout/models/workout_record.dart';
import '../../../features/workout/providers/workout_providers.dart';
import '../../../features/workout/viewmodels/workout_view_model.dart';
import '../../../features/workout/viewmodels/workout_history_view_model.dart';
import '../../../features/workout/repositories/workout_record_repository.dart' show WorkoutRecordRepository; // Importa apenas a interface
import '../../../utils/input_validator.dart';

/// Resultado do registro de um treino
class RegisterWorkoutResult {
  final bool success;
  final WorkoutRecord? workoutRecord;
  final String? error;
  
  const RegisterWorkoutResult({
    required this.success,
    this.workoutRecord,
    this.error,
  });
}

/// Estado para o gerenciamento do registro de treinos
class RegisterWorkoutState {
  final bool isLoading;
  final DateTime selectedDate;
  final String selectedType;
  final String workoutName;
  final int durationMinutes;
  final double intensity;
  final List<XFile> selectedImages;
  final String? errorMessage;
  final String? successMessage;
  final List<String> exerciseTypes;
  
  RegisterWorkoutState({
    this.isLoading = false,
    DateTime? selectedDate,
    this.selectedType = 'Funcional',
    this.workoutName = '',
    this.durationMinutes = 30,
    this.intensity = 3.0,
    List<XFile>? selectedImages,
    this.errorMessage,
    this.successMessage,
    List<String>? exerciseTypes,
  }) : 
    this.selectedDate = selectedDate ?? DateTime.now(),
    this.selectedImages = selectedImages ?? [],
    this.exerciseTypes = exerciseTypes ?? const [
      'Funcional',
      'Musculação',
      'Yoga',
      'Pilates',
      'Cardio',
      'HIIT',
      'Alongamento',
      'Dança',
      'Corrida',
      'Caminhada',
      'Outro'
    ];
  
  RegisterWorkoutState copyWith({
    bool? isLoading,
    DateTime? selectedDate,
    String? selectedType,
    String? workoutName,
    int? durationMinutes,
    double? intensity,
    List<XFile>? selectedImages,
    String? errorMessage,
    String? successMessage,
    List<String>? exerciseTypes,
  }) {
    return RegisterWorkoutState(
      isLoading: isLoading ?? this.isLoading,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedType: selectedType ?? this.selectedType,
      workoutName: workoutName ?? this.workoutName,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      intensity: intensity ?? this.intensity,
      selectedImages: selectedImages ?? this.selectedImages,
      errorMessage: errorMessage,  // Permite limpar com null
      successMessage: successMessage,  // Permite limpar com null
      exerciseTypes: exerciseTypes ?? this.exerciseTypes,
    );
  }
}

/// Provider para o view model de registro de treino
final registerWorkoutViewModelProvider = StateNotifierProvider.autoDispose<RegisterWorkoutViewModel, RegisterWorkoutState>((ref) {
  final repository = ref.watch(workoutRecordRepositoryProvider);
  final challengeService = ref.watch(workoutChallengeServiceProvider);
  final supabase = ref.watch(supabaseClientProvider);
  final challengeRepo = ref.watch(challengeRepositoryProvider);
  
  return RegisterWorkoutViewModel(ref, supabase, repository, challengeRepo, challengeService);
});

class RegisterWorkoutViewModel extends StateNotifier<RegisterWorkoutState> {
  RegisterWorkoutViewModel(
    this.ref, 
    this._supabase, 
    this._repository, 
    this._challengeRepository, 
    this._challengeService,
  ) : super(RegisterWorkoutState());
  
  final Ref ref;
  final SupabaseClient _supabase;
  final WorkoutRecordRepository _repository;
  final ChallengeRepository _challengeRepository;
  final WorkoutChallengeService _challengeService;
  
  // Método para recuperar o repositório de registros de treino via Provider
  WorkoutRecordRepository get _workoutRecordRepository => ref.read(workoutRecordRepositoryProvider);

  /// Atualiza a data selecionada para o treino
  /// 
  /// @param date - Nova data para o treino
  void updateDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }
  
  /// Atualiza o tipo de treino selecionado
  /// 
  /// @param type - Novo tipo de treino
  void updateWorkoutType(String type) {
    state = state.copyWith(selectedType: type);
  }
  
  /// Atualiza o nome personalizado do treino
  /// 
  /// @param name - Novo nome do treino
  void updateWorkoutName(String name) {
    state = state.copyWith(workoutName: name);
  }
  
  /// Atualiza a duração do treino em minutos
  /// 
  /// @param minutes - Nova duração em minutos
  void updateDuration(int minutes) {
    state = state.copyWith(durationMinutes: minutes);
  }
  
  /// Atualiza o valor da intensidade do treino
  /// 
  /// @param intensity - Novo valor de intensidade (1-5)
  void updateIntensity(double intensity) {
    state = state.copyWith(intensity: intensity);
  }
  
  /// Permite ao usuário selecionar imagens da galeria (até 3)
  /// As imagens selecionadas são armazenadas no estado
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> selectedImages = await picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      
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
      debugPrint('❌ Erro ao selecionar imagens: $e');
      state = state.copyWith(errorMessage: 'Erro ao selecionar imagens');
    }
  }

  /// Registra o treino com os dados informados pelo usuário
  /// Faz upload das imagens do treino para o bucket workout-images
  /// @return WorkoutRecord - O registro de treino criado
  Future<RegisterWorkoutResult> registerWorkout({String? challengeId}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      
      final workoutId = const Uuid().v4();
      final userId = _supabase.auth.currentUser?.id;
      
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }
      
      // Mapeia imagens XFile para File
      final List<File> imageFiles = state.selectedImages
          .map((xFile) => File(xFile.path))
          .toList();
      
      // Cria o registro do treino (SEM as URLs das imagens ainda)
      final workoutRecord = WorkoutRecord(
        id: workoutId,
        userId: userId,
        workoutId: null, // Treino livre, sem referência a treino específico
        workoutName: state.workoutName.isNotEmpty ? state.workoutName : 'Treino ${state.selectedType}',
        workoutType: state.selectedType,
        date: state.selectedDate,
        durationMinutes: state.durationMinutes,
        isCompleted: true,
        notes: '',
        imageUrls: [], // Será preenchido pelo repositório após upload
        challengeId: challengeId,
      );
      
      // Criar o registro (com upload de imagens automático se houver)
      final createdRecord = await _repository.createWorkoutRecord(
        workoutRecord,
        images: imageFiles.isNotEmpty ? imageFiles : null,
      );
      
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Treino registrado com sucesso!',
        selectedImages: [], // Limpar imagens após o registro
        workoutName: '', // Limpar nome do treino
        selectedDate: DateTime.now(), // Resetar data para hoje
        durationMinutes: 60, // Resetar duração padrão
      );
      
      // Notificar refresh do ranking de cardio se for treino de cardio
      if (state.selectedType.toLowerCase() == 'cardio') {
        _notifyCardioRankingRefresh();
      }
      
      return RegisterWorkoutResult(success: true, workoutRecord: createdRecord);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao registrar treino: $e',
      );
      return RegisterWorkoutResult(success: false, error: e.toString());
    }
  }
  
  /// Registra um treino e o associa a um desafio específico
  /// 
  /// Este método é útil quando o usuário está fazendo check-in diretamente em um desafio.
  /// Ele faz todas as operações de registerWorkout() e também:
  /// 1. Registra o check-in diretamente para o desafio específico
  /// 2. Atualiza os pontos do usuário no ranking do desafio
  /// 
  /// @param name - Nome do treino
  /// @param type - Tipo do treino (ex: Funcional, Yoga)
  /// @param durationMinutes - Duração em minutos
  /// @param intensity - Intensidade do treino (1-5)
  /// @param challengeId - ID do desafio para o qual registrar o check-in
  /// @return RegisterWorkoutResult com status e detalhes da operação
  Future<RegisterWorkoutResult> registerWorkoutForSpecificChallenge({
    required String name,
    required String type,
    required int durationMinutes,
    required double intensity,
    required String challengeId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    
    final uuid = const Uuid();
    final now = DateTime.now();
    int pointsAwarded = 0;
    
    // Criar o registro do treino
    final record = WorkoutRecord(
      id: uuid.v4(),
      userId: '',  // Será preenchido pelo repositório
      workoutId: null,  // Definir explicitamente como null
      workoutName: name,
      workoutType: type,
      date: state.selectedDate,
      durationMinutes: durationMinutes,
      isCompleted: true,
      notes: 'Check-in para desafio (ID: $challengeId) - Intensidade: ${intensity.round()}/5',
      createdAt: now,
    );
    
    debugPrint('🔍 Registro de treino criado para desafio específico: ${record.toString()}');
    
    try {
      // Salvar o registro (sem imagens neste fluxo)
      final savedRecord = await _repository.createWorkoutRecord(record);
      debugPrint('✅ Registro de treino salvo com sucesso: ${savedRecord.toString()}');
      
      // Flag para verificar se houve erro no check-in mas sucesso no treino
      bool checkInError = false;
      String checkInErrorMessage = '';
      
      // Processar o treino para o desafio específico
      try {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          throw Exception('Usuário não autenticado');
        }
        
        // Permitir treinos de qualquer duração para check-in
        
        // Registrar diretamente o check-in para o desafio específico
        final checkInResult = await _challengeRepository.recordChallengeCheckIn(
          challengeId: challengeId,
          userId: userId,
          workoutId: savedRecord.id,
          workoutName: savedRecord.workoutName,
          workoutType: savedRecord.workoutType,
          date: savedRecord.date,
          durationMinutes: savedRecord.durationMinutes,
        );
        
        if (checkInResult.points > 0) {
          pointsAwarded = checkInResult.points;
          debugPrint('✅ Check-in processado para desafio específico: ${checkInResult.message}');
          
          // Nota: dashboard será atualizado pela UI
          debugPrint('✅ Check-in bem sucedido, dashboard deverá ser atualizado pela UI');
        } else {
          debugPrint('⚠️ Check-in não processado: ${checkInResult.message}');
          checkInError = true;
          checkInErrorMessage = checkInResult.message;
        }
      } catch (e) {
        // Não falhar o registro do treino se houver erro no processamento do desafio
        debugPrint('❌ Erro ao processar check-in para desafio específico: $e');
        checkInError = true;
        checkInErrorMessage = e.toString();
      }
      
      // Mesmo com erro no check-in, o treino foi salvo com sucesso
      if (checkInError) {
        // Personalizar a mensagem com base no erro
        String message = 'Treino registrado, mas houve um problema com o check-in do desafio';
        
        // Usar mensagem genérica para qualquer erro de check-in
        message = 'Treino registrado com sucesso!';
        
        state = state.copyWith(
          isLoading: false,
          errorMessage: message,
        );
        
        return RegisterWorkoutResult(
          success: true,
          workoutRecord: savedRecord,
        );
      }
      
      // Tudo correu bem
      state = state.copyWith(
        isLoading: false,
        successMessage: pointsAwarded > 0 
            ? 'Check-in realizado com sucesso! Você ganhou $pointsAwarded pontos.'
            : 'Check-in realizado com sucesso!'
      );
      
      // Notificar refresh do ranking de cardio se for treino de cardio
      if (type.toLowerCase() == 'cardio') {
        _notifyCardioRankingRefresh();
      }
      
      return RegisterWorkoutResult(
        success: true,
        workoutRecord: savedRecord,
      );
    } catch (e) {
      debugPrint('❌ Erro ao salvar registro de treino: $e');
      
      String errorMessage = 'Falha ao registrar check-in';
      if (e.toString().contains('network')) {
        errorMessage = 'Erro de conexão. Verifique sua internet e tente novamente.';
      } else if (e.toString().contains('permission') || e.toString().contains('403')) {
        errorMessage = 'Você não tem permissão para registrar check-ins.';
      } else if (e.toString().contains('database') || e.toString().contains('SQL')) {
        errorMessage = 'Erro no banco de dados. Tente novamente mais tarde.';
      }
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
      
      throw Exception(errorMessage);
    }
  }
  
  /// Verifica se o usuário já fez check-in hoje para o desafio específico
  /// 
  /// @param challengeId - ID do desafio a verificar
  /// @return bool - true se já fez check-in hoje, false caso contrário
  Future<bool> hasCheckedInToday(String challengeId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuário não autenticado');
    }
    
    final today = DateTime.now();
    return _challengeRepository.hasCheckedInOnDate(userId, challengeId, today);
  }
  
  /// Notifica o ranking de cardio para atualizar após registrar treino
  void _notifyCardioRankingRefresh() {
    final current = ref.read(rankingRefreshNotifierProvider);
    ref.read(rankingRefreshNotifierProvider.notifier).state = current + 1;
    print('DEBUG: Notificando refresh do ranking cardio após treino registrado');
  }
}

/// Função para exibir o sheet de registro de treino
/// Se challengeId for fornecido, o treino será associado a esse desafio automaticamente
void showRegisterExerciseSheet(BuildContext context, {String? challengeId}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => RegisterExerciseSheet(challengeId: challengeId),
  );
}

/// Widget de bottom sheet para registro de exercícios
class RegisterExerciseSheet extends ConsumerStatefulWidget {
  /// ID do desafio, se o registro for para um desafio específico
  final String? challengeId;

  /// Construtor
  const RegisterExerciseSheet({
    this.challengeId,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<RegisterExerciseSheet> createState() => _RegisterExerciseSheetState();
}

class _RegisterExerciseSheetState extends ConsumerState<RegisterExerciseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseNameController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Initialize the workout name in the view model when the controller changes
    _exerciseNameController.addListener(() {
      ref.read(registerWorkoutViewModelProvider.notifier)
          .updateWorkoutName(_exerciseNameController.text);
    });
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obter o estado e o notifier do ViewModel
    final viewModelState = ref.watch(registerWorkoutViewModelProvider);
    final viewModel = ref.watch(registerWorkoutViewModelProvider.notifier);
    
    // Obter altura disponível para ajustar o tamanho do sheet
    final availableHeight = MediaQuery.of(context).size.height * 0.85;
    
    return Container(
      height: availableHeight,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: viewModelState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(context, viewModelState, viewModel),
    );
  }

  /// Constrói o formulário de registro
  Widget _buildForm(
    BuildContext context, 
    RegisterWorkoutState viewModelState,
    RegisterWorkoutViewModel viewModel
  ) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        children: [
          // Título do sheet
          Center(
            child: Text(
              widget.challengeId != null
                  ? 'Registrar Exercício'
                  : 'Registrar Exercício',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4D4D4D),
              ),
            ),
          ),
          
          // Linha divisória
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE6E6E6)),
          ),
          
          // Nome do exercício
          TextFormField(
            controller: _exerciseNameController,
            decoration: InputDecoration(
              labelText: 'Nome do exercício',
              hintText: 'Ex: Treino de pernas, Yoga matinal',
              labelStyle: const TextStyle(
                color: Color(0xFF4D4D4D),
                fontWeight: FontWeight.w500,
              ),
              hintStyle: TextStyle(color: Colors.grey.shade400),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCDA8F0), width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, informe o nome do exercício';
              }
              return null;
            },
            onChanged: (value) {
              viewModel.updateWorkoutName(value);
            },
          ),
          
          const SizedBox(height: 20),
          
          // Tipo de exercício (dropdown)
          DropdownButtonFormField<String>(
            value: viewModelState.selectedType,
            decoration: InputDecoration(
              labelText: 'Tipo de exercício',
              labelStyle: const TextStyle(
                color: Color(0xFF4D4D4D),
                fontWeight: FontWeight.w500,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFCDA8F0), width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            items: viewModelState.exerciseTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                viewModel.updateWorkoutType(value);
              }
            },
            dropdownColor: Colors.white,
            elevation: 2,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF4D4D4D)),
          ),
          
          const SizedBox(height: 20),
          
          // Data do exercício
          InkWell(
            onTap: () => _selectDate(context, viewModel),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Data do exercício',
                labelStyle: const TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontWeight: FontWeight.w500,
                ),
                suffixIcon: const Icon(Icons.calendar_today, size: 20, color: Color(0xFF4D4D4D)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFCDA8F0), width: 1.5),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              child: Text(
                DateFormat('dd/MM/yyyy').format(viewModelState.selectedDate),
                style: const TextStyle(color: Color(0xFF4D4D4D)),
              ),
            ),
          ),
          
          const SizedBox(height: 28),
          
          // Duração em minutos
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Duração (minutos)',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4D4D4D),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: viewModelState.durationMinutes.toString(),
                decoration: InputDecoration(
                  hintText: 'Ex: 30',
                  labelStyle: const TextStyle(
                    color: Color(0xFF4D4D4D),
                    fontWeight: FontWeight.w500,
                  ),
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFF38638), width: 1.5),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe a duração';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Informe um número válido de minutos';
                  }
                  if (duration > 300) {
                    return 'Duração máxima é 300 minutos';
                  }
                  return null;
                },
                onChanged: (value) {
                  final duration = int.tryParse(value);
                  if (duration != null && duration > 0) {
                    viewModel.updateDuration(duration);
                  }
                },
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Intensidade
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Intensidade: ${viewModelState.intensity.toInt()}',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4D4D4D),
                ),
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: const Color(0xFFCDA8F0),
                  inactiveTrackColor: Colors.grey.shade200,
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xFFCDA8F0).withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 10,
                    elevation: 2,
                  ),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
                ),
                child: Slider(
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: viewModelState.intensity.toInt().toString(),
                  value: viewModelState.intensity,
                  onChanged: (value) {
                    viewModel.updateIntensity(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Leve', style: AppTypography.bodySmall.copyWith(color: Colors.grey.shade600)),
                    Text('Moderado', style: AppTypography.bodySmall.copyWith(color: Colors.grey.shade600)),
                    Text('Intenso', style: AppTypography.bodySmall.copyWith(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 28),
          
          // Upload de imagem
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fotos do treino (opcional):',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4D4D4D),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => ref.read(registerWorkoutViewModelProvider.notifier).pickImage(),
                child: _buildImagePreview(viewModelState.selectedImages),
              ),
              if (viewModelState.selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${viewModelState.selectedImages.length}/3 imagens selecionadas',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textLight,
                      fontStyle: FontStyle.italic
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Botões de ação
          Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
            child: Row(
              children: [
                // Botão cancelar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4D4D4D)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontFamily: 'Century',
                        color: Color(0xFF4D4D4D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Botão registrar
                Expanded(
                  child: ElevatedButton(
                    onPressed: viewModelState.isLoading ? null : () => _submitForm(viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCDA8F0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Registrar',
                      style: TextStyle(
                        fontFamily: 'Century',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Permite selecionar a data do exercício
  Future<void> _selectDate(BuildContext context, RegisterWorkoutViewModel viewModel) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: viewModel.state.selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 14)),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione a data do exercício',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      fieldHintText: 'dd/mm/aaaa',
      fieldLabelText: 'Data do exercício',
      errorFormatText: 'Digite uma data válida no formato dd/mm/aaaa',
      errorInvalidText: 'Digite uma data válida',
    );
    
    if (picked != null && picked != viewModel.state.selectedDate) {
      viewModel.updateDate(picked);
    }
  }

  /// Envia o formulário e registra o exercício
  Future<void> _submitForm(RegisterWorkoutViewModel viewModel) async {
    // Validar o formulário
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Permitir registro independente da duração
    
    try {
      // Obter usuário atual diretamente do Supabase
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        SnackBarUtils.showError(context, 'Usuário não autenticado');
        return;
      }
      
      // Verificar se já existe check-in hoje se for para um desafio específico
      if (widget.challengeId != null) {
        debugPrint('🔍 Verificando se já existe check-in hoje para o desafio ${widget.challengeId}');
        
        final hasCheckedIn = await viewModel.hasCheckedInToday(widget.challengeId!);
        
        if (hasCheckedIn) {
          SnackBarUtils.showWarning(
            context, 
            'Você já registrou check-in para este desafio hoje. Volte amanhã para continuar sua sequência!'
          );
          return;
        }
      }
      
      // Registrar o treino
      RegisterWorkoutResult result;
      if (widget.challengeId != null) {
        // Registrar treino para um desafio específico
        result = await viewModel.registerWorkoutForSpecificChallenge(
          name: _exerciseNameController.text.trim(),
          type: viewModel.state.selectedType,
          durationMinutes: viewModel.state.durationMinutes,
          intensity: viewModel.state.intensity,
          challengeId: widget.challengeId!,
        );
      } else {
        // Registrar treino normal
        result = await viewModel.registerWorkout(
          challengeId: widget.challengeId,
        );
      }
      
      // Forçar atualização de todos os providers relevantes para manter sincronização
      debugPrint('🔄 Atualizando providers após registro de treino...');
      
      // Atualizar dados do dashboard
      ref.refresh(dashboardViewModelProvider);
      
      // Atualizar dados dos desafios - usando uma abordagem mais segura
      // Não fazer refresh completo para evitar erros de dispose
      try {
        // Apenas carregar os dados de desafio de forma segura se estiver na tela de desafios
        if (ref.exists(challengeViewModelProvider)) {
          // Somente tente atualizar se o provider ainda existir e estiver acessível
          final challengeViewModel = ref.read(challengeViewModelProvider.notifier);
          final officialChallengeId = ref.read(challengeViewModelProvider).officialChallenge?.id;
          if (officialChallengeId != null) {
            // Agendar a atualização para o próximo frame para evitar conflitos
            Future.microtask(() {
              try {
                challengeViewModel.loadChallengeDetails(officialChallengeId, skipRealtimeUpdates: true);
              } catch (e) {
                debugPrint('⚠️ Erro ao atualizar desafio: $e');
              }
            });
          }
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao acessar provider de desafios: $e');
      }
      
      // Atualizar dados de workout (histórico, etc.)
      ref.refresh(workoutViewModelProvider);
      
      if (ref.exists(workoutHistoryViewModelProvider)) {
        ref.refresh(workoutHistoryViewModelProvider);
      }
      
      // Fechar o bottom sheet
      if (mounted) {
        Navigator.of(context).pop();
        
        // Mostrar mensagem com base no resultado
        if (result.success) {
          SnackBarUtils.showSuccess(context, 'Treino registrado com sucesso!');
        } else {
          String errorMsg = result.error ?? 'Erro ao registrar treino';
          SnackBarUtils.showWarning(context, errorMsg);
        }
      }
    } catch (e) {
      // Mostrar erro
      if (mounted) {
        SnackBarUtils.showError(
          context, 
          'Erro ao registrar: ${e.toString()}'
        );
      }
    }
  }

  // Método para construir o widget que exibe previews das imagens selecionadas
  Widget _buildImagePreview(List<XFile> selectedImages) {
    if (selectedImages.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
        ),
      );
    }
    
    // Se tivermos apenas uma imagem, exibimos full
    if (selectedImages.length == 1) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(selectedImages[0].path),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'Erro ao carregar imagem',
                  style: TextStyle(color: Colors.red),
                ),
              );
            },
          ),
        ),
      );
    }
    
    // Se tivermos múltiplas imagens, mostramos em grid
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: List.generate(selectedImages.length, (index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              File(selectedImages[index].path),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
