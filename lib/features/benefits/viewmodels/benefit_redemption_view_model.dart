// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../models/redeemed_benefit.dart';
import '../repositories/benefit_repository.dart';
import '../providers/benefit_providers.dart';

/// Estado para gerenciamento de resgate de benefícios
class BenefitRedemptionState {
  /// Indica se a requisição está em andamento
  final bool isLoading;

  /// Indica se ocorreu um erro durante o resgate
  final bool hasError;

  /// Mensagem de erro caso exista
  final String? errorMessage;

  /// Indica se o resgate foi bem-sucedido
  final bool isSuccess;

  /// Benefício resgatado, se o resgate for bem-sucedido
  final RedeemedBenefit? redeemedBenefit;

  /// Construtor principal
  const BenefitRedemptionState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.isSuccess = false,
    this.redeemedBenefit,
  });

  /// Cria uma cópia do estado atual com os campos especificados alterados
  BenefitRedemptionState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? isSuccess,
    RedeemedBenefit? redeemedBenefit,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return BenefitRedemptionState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSuccess: clearSuccess ? false : (isSuccess ?? this.isSuccess),
      redeemedBenefit: redeemedBenefit ?? this.redeemedBenefit,
    );
  }

  /// Estado inicial
  factory BenefitRedemptionState.initial() => const BenefitRedemptionState();

  /// Estado de carregamento
  factory BenefitRedemptionState.loading() => const BenefitRedemptionState(
        isLoading: true,
        hasError: false,
        isSuccess: false,
        errorMessage: null,
      );

  /// Estado de erro
  factory BenefitRedemptionState.error(String message) => BenefitRedemptionState(
        isLoading: false,
        hasError: true,
        isSuccess: false,
        errorMessage: message,
      );

  /// Estado de sucesso
  factory BenefitRedemptionState.success(RedeemedBenefit benefit) => BenefitRedemptionState(
        isLoading: false,
        hasError: false,
        isSuccess: true,
        redeemedBenefit: benefit,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BenefitRedemptionState &&
        other.isLoading == isLoading &&
        other.hasError == hasError &&
        other.errorMessage == errorMessage &&
        other.isSuccess == isSuccess &&
        other.redeemedBenefit == redeemedBenefit;
  }

  @override
  int get hashCode => Object.hash(
        isLoading,
        hasError,
        errorMessage,
        isSuccess,
        redeemedBenefit,
      );
}

/// Notifier para gerenciar estado de resgate de benefícios
class BenefitRedemptionNotifier extends StateNotifier<BenefitRedemptionState> {
  final BenefitRepository _repository;

  /// Construtor
  BenefitRedemptionNotifier({required BenefitRepository repository})
      : _repository = repository,
        super(BenefitRedemptionState.initial());

  /// Resgata um benefício
  Future<void> redeemBenefit(String benefitId) async {
    try {
      state = BenefitRedemptionState.loading();

      // Verifica se tem pontos suficientes
      final hasEnough = await _repository.hasEnoughPoints(benefitId);
      if (!hasEnough) {
        state = BenefitRedemptionState.error('Pontos insuficientes para resgatar este benefício');
        return;
      }

      final redeemedBenefit = await _repository.redeemBenefit(benefitId);

      if (redeemedBenefit == null) {
        state = BenefitRedemptionState.error('Erro ao resgatar benefício');
        return;
      }

      state = BenefitRedemptionState.success(redeemedBenefit);
    } catch (e) {
      state = BenefitRedemptionState.error('Erro: ${e.toString()}');
    }
  }
  
  /// Marca um benefício como utilizado
  Future<void> markBenefitAsUsed(String redeemedBenefitId) async {
    try {
      state = BenefitRedemptionState.loading();
      
      if (state.redeemedBenefit == null) {
        state = BenefitRedemptionState.error('Nenhum benefício resgatado para marcar como utilizado');
        return;
      }
      
      final updatedBenefit = await _repository.markBenefitAsUsed(redeemedBenefitId);
      state = BenefitRedemptionState.success(updatedBenefit);
    } catch (e) {
      state = BenefitRedemptionState.error('Erro ao marcar benefício como utilizado: ${e.toString()}');
    }
  }

  /// Reseta o estado para inicial
  void reset() {
    state = BenefitRedemptionState.initial();
  }
}

/// Provider para o notifier de resgate de benefícios
final benefitRedemptionViewModelProvider =
    StateNotifierProvider<BenefitRedemptionNotifier, BenefitRedemptionState>((ref) {
  final repository = ref.watch(benefitRepositoryProvider);
  return BenefitRedemptionNotifier(repository: repository);
}); 