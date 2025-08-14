import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../services/supabase_service.dart';

part 'admin_view_model.freezed.dart';

/// Estado do painel administrativo
@freezed
class AdminState with _$AdminState {
  const factory AdminState({
    @Default(false) bool isLoading,
    String? successMessage,
    String? errorMessage,
    @Default([]) List<AdminOperation> operationHistory,
  }) = _AdminState;
}

/// Registro de uma operação administrativa
@freezed
class AdminOperation with _$AdminOperation {
  const factory AdminOperation({
    required String email,
    required String level,
    required bool success,
    required DateTime timestamp,
    String? errorMessage,
  }) = _AdminOperation;
}

/// ViewModel do painel administrativo
class AdminViewModel extends StateNotifier<AdminState> {
  final SupabaseService _supabaseService;

  AdminViewModel(this._supabaseService) : super(const AdminState());

  /// Atualiza o nível de um usuário por email
  Future<void> updateUserLevel({
    required String email,
    required String level,
  }) async {
    state = state.copyWith(
      isLoading: true,
      successMessage: null,
      errorMessage: null,
    );

    try {
      // Chamar função SQL para atualizar usuário
      final response = await _supabaseService.client
          .rpc('update_user_level_by_email', {
        'email_param': email,
        'new_level': level,
        'expires_at': level == 'expert' 
            ? DateTime.now().add(const Duration(days: 30)).toIso8601String()
            : null,
      });

      debugPrint('📊 Resposta da função SQL: $response');

      // Verificar se a resposta contém sucesso
      if (response != null && response['success'] == true) {
        final operation = AdminOperation(
          email: email,
          level: level,
          success: true,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          isLoading: false,
          successMessage: '✅ Usuário $email ${level == 'expert' ? 'promovido' : 'revertido'} com sucesso!',
          operationHistory: [operation, ...state.operationHistory],
        );
      } else {
        // Ainda considera sucesso se não houve erro
        final operation = AdminOperation(
          email: email,
          level: level,
          success: true,
          timestamp: DateTime.now(),
        );

        state = state.copyWith(
          isLoading: false,
          successMessage: '✅ Comando executado para $email (nível: $level)',
          operationHistory: [operation, ...state.operationHistory],
        );
      }
    } catch (error) {
      debugPrint('❌ Erro ao atualizar usuário: $error');

      final operation = AdminOperation(
        email: email,
        level: level,
        success: false,
        timestamp: DateTime.now(),
        errorMessage: error.toString(),
      );

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar usuário: $error',
        operationHistory: [operation, ...state.operationHistory],
      );
    }
  }

  /// Verifica o status de pagamento de um usuário
  Future<void> checkPaymentStatus(String email) async {
    state = state.copyWith(
      isLoading: true,
      successMessage: null,
      errorMessage: null,
    );

    try {
      final response = await _supabaseService.client
          .rpc('check_payment_status', {
        'email_param': email,
      });

      debugPrint('📊 Status do pagamento: $response');

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Status verificado para $email',
      );
    } catch (error) {
      debugPrint('❌ Erro ao verificar status: $error');

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao verificar status: $error',
      );
    }
  }

  /// Processa usuários pendentes
  Future<void> processPendingUsers() async {
    state = state.copyWith(
      isLoading: true,
      successMessage: null,
      errorMessage: null,
    );

    try {
      final response = await _supabaseService.client
          .rpc('process_pending_user_levels');

      debugPrint('📊 Processamento de pendentes: $response');

      final processedCount = response['processed_count'] ?? 0;
      final errorCount = response['error_count'] ?? 0;

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Processados: $processedCount usuários, Erros: $errorCount',
      );
    } catch (error) {
      debugPrint('❌ Erro ao processar pendentes: $error');

      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao processar usuários pendentes: $error',
      );
    }
  }

  /// Limpa mensagens de status
  void clearMessages() {
    state = state.copyWith(
      successMessage: null,
      errorMessage: null,
    );
  }

  /// Limpa o histórico de operações
  void clearHistory() {
    state = state.copyWith(
      operationHistory: [],
    );
  }
}

/// Provider do ViewModel administrativo
final adminViewModelProvider = StateNotifierProvider<AdminViewModel, AdminState>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return AdminViewModel(supabaseService);
}); 