// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/benefits/models/benefit.dart';
import 'package:ray_club_app/features/benefits/repositories/benefits_repository.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';

part 'benefits_view_model.freezed.dart';

/// State for the benefits view model
@freezed
class BenefitsState with _$BenefitsState {
  const factory BenefitsState({
    @Default([]) List<Benefit> benefits,
    @Default([]) List<Benefit> filteredBenefits,
    @Default('all') String activeTab,
    @Default(false) bool isLoading,
    String? errorMessage,
    Benefit? selectedBenefit,
    @Default([]) List<String> partners,
  }) = _BenefitsState;
}

/// Provider for the benefits view model
final benefitsViewModelProvider = StateNotifierProvider<BenefitsViewModel, BenefitsState>((ref) {
  final repository = ref.watch(benefitsRepositoryProvider);
  return BenefitsViewModel(repository);
});

/// ViewModel for benefits management
class BenefitsViewModel extends StateNotifier<BenefitsState> {
  final BenefitsRepository _repository;

  BenefitsViewModel(this._repository) : super(const BenefitsState()) {
    loadBenefits();
  }

  /// Loads all benefits
  Future<void> loadBenefits() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final benefits = await _repository.getAllBenefits();
      
      // Extract unique partners
      final partnerSet = <String>{};
      for (var benefit in benefits) {
        partnerSet.add(benefit.partner);
      }
      
      state = state.copyWith(
        benefits: benefits,
        filteredBenefits: benefits,
        partners: partnerSet.toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao carregar benefícios: ${e.toString()}'
      );
    }
  }

  /// Filters benefits by type
  Future<void> filterByType(BenefitType type) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final benefits = await _repository.getBenefitsByType(type);
      state = state.copyWith(
        filteredBenefits: benefits,
        activeTab: type.toString().split('.').last,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao filtrar benefícios: ${e.toString()}'
      );
    }
  }
  
  /// Shows all benefits
  void showAllBenefits() {
    state = state.copyWith(
      filteredBenefits: state.benefits,
      activeTab: 'all',
    );
  }

  /// Filters benefits by partner
  Future<void> filterByPartner(String partner) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final benefits = await _repository.getBenefitsByPartner(partner);
      state = state.copyWith(
        filteredBenefits: benefits,
        activeTab: 'partner',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Falha ao filtrar benefícios por parceiro: ${e.toString()}'
      );
    }
  }

  /// Selects a benefit to show details
  void selectBenefit(Benefit benefit) {
    state = state.copyWith(selectedBenefit: benefit);
  }

  /// Clears the selected benefit
  void clearSelectedBenefit() {
    state = state.copyWith(selectedBenefit: null);
  }
} 
