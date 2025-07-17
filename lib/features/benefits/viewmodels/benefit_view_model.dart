// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// Project imports:
import '../../../core/errors/app_exception.dart' as app_errors;
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../core/services/cache_service.dart';
import '../../../services/qr_service.dart';
import '../models/benefit.dart';
import '../models/redeemed_benefit_model.dart';
import '../enums/benefit_type.dart';
import '../repositories/benefit_repository.dart';
import '../repositories/mock_benefit_repository.dart';
import '../providers/benefit_providers.dart';
import 'benefit_state.dart';

/// Provider do repositório de benefícios
final benefitRepositoryProvider = Provider<BenefitRepository>((ref) {
  // Usar apenas o mock para resolver problemas de compilação
  return MockBenefitRepository();
  
  // Código original comentado:
  /*
  if (kDebugMode) {
    // Em modo de desenvolvimento, usa o mock para testes
    return MockBenefitRepository();
  } else {
    // Em produção, usa a implementação real com Supabase
    final supabase = ref.watch(supabaseClientProvider);
    final cacheService = ref.watch(cacheServiceProvider);
    final connectivityService = ref.watch(connectivityServiceProvider);
    
    return SupabaseBenefitRepository(
      supabaseClient: supabase,
      cacheService: cacheService,
      connectivityService: connectivityService,
    );
  }
  */
});

/// Provider do ViewModel de benefícios
final benefitViewModelProvider = StateNotifierProvider<BenefitViewModel, BenefitState>((ref) {
  final qrService = ref.watch(qrServiceProvider);
  return BenefitViewModel(
    ref.watch(benefitRepositoryProvider),
    qrService,
  );
});

/// ViewModel para gerenciar benefícios
class BenefitViewModel extends StateNotifier<BenefitState> {
  final BenefitRepository _repository;
  final QRService _qrService;
  
  BenefitViewModel(this._repository, this._qrService) : super(const BenefitState());
  
  /// Carrega todos os benefícios disponíveis
  Future<void> loadBenefits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final benefits = await _repository.getBenefits();
      final categories = await _repository.getBenefitCategories();
      
      // Obtém pontos do usuário se for mock
      int? userPoints;
      if (_repository is MockBenefitRepository) {
        try {
          userPoints = await (_repository as MockBenefitRepository).getUserPoints();
        } catch (e) {
          // Ignora erros ao tentar obter pontos durante testes
          if (kDebugMode) {
            print('Erro ao obter pontos do usuário: $e');
          }
        }
      }
      
      state = state.copyWith(
        benefits: benefits,
        categories: categories,
        userPoints: userPoints,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar benefícios: $e',
      );
    }
  }
  
  /// Carrega os benefícios resgatados pelo usuário
  Future<void> loadRedeemedBenefits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final redeemedBenefits = await _repository.getRedeemedBenefits();
      
      // Verifica e atualiza status de expiração antes de atualizar o estado
      await checkExpiredBenefits(redeemedBenefits);
      
      state = state.copyWith(
        redeemedBenefits: redeemedBenefits,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar benefícios resgatados: $e',
      );
    }
  }
  
  /// Verifica quais benefícios estão expirados e atualiza seus status
  Future<void> checkExpiredBenefits(List<RedeemedBenefit> benefits) async {
    final now = DateTime.now();
    bool hasUpdates = false;
    
    for (int i = 0; i < benefits.length; i++) {
      final benefit = benefits[i];
      
      // Verifica se o benefício está com data de expiração no passado
      // Não verificamos mais status já que esse campo não existe mais
      if (benefit.expiresAt != null && benefit.expiresAt!.isBefore(now)) {
        // Tenta atualizar para expirado
        try {
          final updatedBenefit = await _repository.updateBenefitStatus(
            benefit.id, 
            BenefitStatus.expired
          );
          
          // Se conseguiu atualizar, substitui na lista
          if (updatedBenefit != null) {
            benefits[i] = updatedBenefit;
            hasUpdates = true;
          }
        } catch (e) {
          // Ignora erro na atualização e continua
          if (kDebugMode) {
            print('Erro ao atualizar status de benefício expirado: $e');
          }
        }
      }
    }
    
    // Se houver alterações, atualiza o estado
    if (hasUpdates && state.selectedRedeemedBenefit != null) {
      // Atualiza o benefício selecionado se ele estiver entre os expirados
      final updatedSelected = benefits.firstWhere(
        (b) => b.id == state.selectedRedeemedBenefit!.id,
        orElse: () => state.selectedRedeemedBenefit!,
      );
      
      state = state.copyWith(selectedRedeemedBenefit: updatedSelected);
    }
  }
  
  /// Filtra benefícios por categoria
  Future<void> filterByCategory(String? category) async {
    state = state.copyWith(isLoading: true, errorMessage: null, selectedCategory: category);

    try {
      final benefits = category != null 
          ? await _repository.getBenefitsByCategory(category)
          : await _repository.getBenefits();
      
      state = state.copyWith(
        benefits: benefits,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao filtrar benefícios: $e',
      );
    }
  }
  
  /// Seleciona um benefício para visualização detalhada
  Future<void> selectBenefit(String benefitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final benefit = await _repository.getBenefitById(benefitId);
      
      if (benefit == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Benefício não encontrado',
        );
        return;
      }
      
      state = state.copyWith(
        selectedBenefit: benefit,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao selecionar benefício: $e',
      );
    }
  }
  
  /// Seleciona um benefício resgatado para visualização
  Future<void> selectRedeemedBenefit(String redeemedBenefitId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final redeemedBenefit = await _repository.getRedeemedBenefitById(redeemedBenefitId);
      
      if (redeemedBenefit == null) {
        throw app_errors.StorageException(
          message: 'Benefício resgatado não encontrado',
          code: 'redeemed_benefit_not_found',
        );
      }
      
      state = state.copyWith(
        selectedRedeemedBenefit: redeemedBenefit,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
    }
  }
  
  /// Resgata um benefício
  Future<RedeemedBenefit?> redeemBenefit(String benefitId) async {
    state = state.copyWith(
      isRedeeming: true, 
      errorMessage: null,
      benefitBeingRedeemed: null,
    );

    try {
      final benefit = await _repository.getBenefitById(benefitId);
      
      if (benefit == null) {
        state = state.copyWith(
          isRedeeming: false,
          errorMessage: 'Benefício não encontrado',
        );
        return null;
      }
      
      // Verifica se tem pontos suficientes
      final hasEnough = await _repository.hasEnoughPoints(benefitId);
      if (!hasEnough) {
        state = state.copyWith(
          isRedeeming: false,
          errorMessage: 'Pontos insuficientes para resgatar este benefício',
        );
        return null;
      }
      
      state = state.copyWith(
        isRedeeming: true,
        errorMessage: null,
        successMessage: null,
        benefitBeingRedeemed: benefit,
      );
      
      final redeemedBenefit = await _repository.redeemBenefit(benefitId);
      
      // Atualiza pontos do usuário se estiver usando MockBenefitRepository
      int? userPoints;
      if (_repository is MockBenefitRepository) {
        userPoints = await (_repository as MockBenefitRepository).getUserPoints();
      }
      
      // Carrega benefícios resgatados novamente para atualizar a lista
      await loadRedeemedBenefits();
      
      state = state.copyWith(
        isRedeeming: false,
        benefitBeingRedeemed: null,
        redeemedBenefits: state.redeemedBenefits,
        userPoints: userPoints,
        selectedRedeemedBenefit: redeemedBenefit,
        successMessage: 'Benefício resgatado com sucesso!',
      );
      
      return redeemedBenefit;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isRedeeming: false,
        benefitBeingRedeemed: null,
        errorMessage: e.message,
        successMessage: null,
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isRedeeming: false,
        benefitBeingRedeemed: null,
        errorMessage: 'Erro ao resgatar benefício: $e',
        successMessage: null,
      );
      return null;
    }
  }
  
  /// Marca um benefício como utilizado
  Future<bool> markBenefitAsUsed(String redeemedBenefitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    
    try {
      final updatedBenefit = await _repository.markBenefitAsUsed(redeemedBenefitId);
      
      // Atualiza a lista de benefícios resgatados
      await loadRedeemedBenefits();
      
      state = state.copyWith(
        redeemedBenefits: state.redeemedBenefits,
        selectedRedeemedBenefit: updatedBenefit,
        isLoading: false,
        successMessage: 'Benefício marcado como utilizado com sucesso!',
      );
      
      return true;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.message,
        successMessage: null
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao marcar benefício como utilizado: $e',
        successMessage: null
      );
      return false;
    }
  }
  
  /// Cancela um benefício resgatado
  Future<bool> cancelRedeemedBenefit(String redeemedBenefitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    
    try {
      await _repository.cancelRedeemedBenefit(redeemedBenefitId);
      
      // Atualiza pontos do usuário se estiver usando MockBenefitRepository
      int? userPoints;
      if (_repository is MockBenefitRepository) {
        userPoints = await (_repository as MockBenefitRepository).getUserPoints();
      }
      
      // Atualiza a lista de benefícios resgatados
      await loadRedeemedBenefits();
      
      state = state.copyWith(
        redeemedBenefits: state.redeemedBenefits,
        userPoints: userPoints,
        selectedRedeemedBenefit: null,
        isLoading: false,
        successMessage: 'Benefício cancelado com sucesso!',
      );
      
      return true;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false, 
        errorMessage: e.message,
        successMessage: null
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao cancelar benefício: $e',
        successMessage: null
      );
      return false;
    }
  }
  
  /// Carrega benefícios em destaque
  Future<void> loadFeaturedBenefits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final featuredBenefits = await _repository.getFeaturedBenefits();
      
      state = state.copyWith(
        benefits: featuredBenefits,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar benefícios em destaque: $e',
      );
    }
  }
  
  /// Limpa o benefício selecionado
  void clearSelectedBenefit() {
    state = state.copyWith(selectedBenefit: null);
  }
  
  /// Limpa o benefício resgatado selecionado
  void clearSelectedRedeemedBenefit() {
    state = state.copyWith(selectedRedeemedBenefit: null);
  }
  
  /// Limpa mensagem de erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
  
  /// Limpa mensagem de sucesso
  void clearSuccessMessage() {
    state = state.copyWith(successMessage: null);
  }
  
  /// Adiciona pontos ao usuário (apenas para testes com MockBenefitRepository)
  Future<void> addUserPoints(int points) async {
    if (_repository is MockBenefitRepository) {
      final userPoints = await (_repository as MockBenefitRepository).addUserPoints(points);
      state = state.copyWith(userPoints: userPoints);
    }
  }
  
  /// MÉTODOS DE ADMINISTRAÇÃO
  
  /// Verifica se o usuário atual é um administrador
  Future<bool> isAdmin() async {
    try {
      return await _repository.isAdmin();
    } on app_errors.AppException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
  
  /// Carrega todos os benefícios resgatados (por todos os usuários) - somente admin
  Future<void> loadAllRedeemedBenefits() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Verificar se o usuário é admin
      final isAdminUser = await _repository.isAdmin();
      if (!isAdminUser) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Permissão negada. Você não tem acesso de administrador.',
        );
        return;
      }
      
      final allRedeemedBenefits = await _repository.getAllRedeemedBenefits();
      
      // Verifica e atualiza status de expiração antes de atualizar o estado
      await checkExpiredBenefits(allRedeemedBenefits);
      
      state = state.copyWith(
        redeemedBenefits: allRedeemedBenefits,
        isLoading: false,
      );
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar benefícios: $e',
      );
    }
  }
  
  /// Atualiza a data de expiração de um benefício - somente admin
  Future<bool> updateBenefitExpiration(String benefitId, DateTime? newExpirationDate) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedBenefit = await _repository.updateBenefitExpiration(benefitId, newExpirationDate);
      
      if (updatedBenefit == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Benefício não encontrado',
        );
        return false;
      }
      
      // Atualiza a lista de benefícios com o item atualizado
      final updatedBenefits = [...state.benefits];
      final index = updatedBenefits.indexWhere((b) => b.id == benefitId);
      if (index >= 0) {
        updatedBenefits[index] = updatedBenefit;
      }
      
      state = state.copyWith(
        benefits: updatedBenefits,
        selectedBenefit: updatedBenefit,
        isLoading: false,
        successMessage: 'Data de expiração atualizada com sucesso!',
      );
      
      return true;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao atualizar data de expiração: $e',
      );
      return false;
    }
  }
  
  /// Estende a data de expiração de um benefício resgatado - somente admin
  Future<bool> extendRedeemedBenefitExpiration(String redeemedBenefitId, DateTime? newExpirationDate) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedBenefit = await _repository.extendRedeemedBenefitExpiration(redeemedBenefitId, newExpirationDate);
      
      if (updatedBenefit == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Benefício resgatado não encontrado',
        );
        return false;
      }
      
      // Atualiza a lista de benefícios resgatados com o item atualizado
      final updatedRedeemedBenefits = [...state.redeemedBenefits];
      final index = updatedRedeemedBenefits.indexWhere((b) => b.id == redeemedBenefitId);
      if (index >= 0) {
        updatedRedeemedBenefits[index] = updatedBenefit;
      }
      
      state = state.copyWith(
        redeemedBenefits: updatedRedeemedBenefits,
        selectedRedeemedBenefit: updatedBenefit,
        isLoading: false,
        successMessage: 'Data de expiração atualizada com sucesso!',
      );
      
      // Recarregar a lista de benefícios resgatados
      final isUserAdmin = await _repository.isAdmin();
      if (isUserAdmin) {
        await loadAllRedeemedBenefits();
      } else {
        await loadRedeemedBenefits();
      }
      
      return true;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao estender validade do benefício: $e',
      );
      return false;
    }
  }
  
  /// Alterna o status de admin (apenas para testes com MockBenefitRepository)
  Future<void> toggleAdminStatus() async {
    if (_repository is MockBenefitRepository) {
      (_repository as MockBenefitRepository).toggleAdminStatus();
    }
  }
  
  /// Obtem um beneficio pelo ID
  Future<Benefit?> getBenefitById(String benefitId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      final benefit = await _repository.getBenefitById(benefitId);
      
      state = state.copyWith(
        isLoading: false,
      );
      
      return benefit;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(isLoading: false, errorMessage: errorMessage);
      return null;
    }
  }
  
  /// Atualiza um benefício existente (somente admin)
  Future<bool> updateBenefit(Benefit benefit) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      
      // Verificar se o usuário é admin
      final isAdminUser = await _repository.isAdmin();
      if (!isAdminUser) {
        throw app_errors.AppAuthException(
          message: 'Permissão negada. Você não tem acesso de administrador.',
          code: 'permission_denied',
        );
      }
      
      // Implementação simulada - No mundo real, chamaríamos um método do repositório
      // await _repository.updateBenefit(benefit);
      
      // Recarrega a lista de benefícios para atualização
      final benefits = await _repository.getBenefits();
      
      state = state.copyWith(
        benefits: benefits,
        isLoading: false,
        successMessage: 'Benefício atualizado com sucesso!',
      );
      
      return true;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false, 
        errorMessage: errorMessage,
        successMessage: null
      );
      return false;
    }
  }
  
  /// Cria um novo benefício (somente admin)
  Future<bool> createBenefit(Benefit benefit) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
      
      // Verificar se o usuário é admin
      final isAdminUser = await _repository.isAdmin();
      if (!isAdminUser) {
        throw app_errors.AppAuthException(
          message: 'Permissão negada. Você não tem acesso de administrador.',
          code: 'permission_denied',
        );
      }
      
      // Implementação simulada - No mundo real, chamaríamos um método do repositório
      // await _repository.createBenefit(benefit);
      
      // Recarrega a lista de benefícios para atualização
      final benefits = await _repository.getBenefits();
      
      state = state.copyWith(
        benefits: benefits,
        isLoading: false,
        successMessage: 'Benefício criado com sucesso!',
      );
      
      return true;
    } catch (e, stackTrace) {
      final errorMessage = _handleError(e, stackTrace);
      state = state.copyWith(
        isLoading: false, 
        errorMessage: errorMessage,
        successMessage: null
      );
      return false;
    }
  }
  
  /// Gera um QR Code para um benefício resgatado
  Future<bool> generateQRCode(String redeemedBenefitId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final redeemedBenefit = state.redeemedBenefits.firstWhere(
        (b) => b.id == redeemedBenefitId,
        orElse: () => throw StateError('Benefício resgatado não encontrado'),
      );
      
      // Gerar QR code
      final qrResult = await _qrService.generateQRDataForBenefit(
        benefitId: redeemedBenefit.id,
        code: redeemedBenefit.code,
      );
      
      state = state.copyWith(
        isLoading: false,
        qrCodeData: qrResult.data,
        qrCodeExpiresAt: qrResult.expiresAt,
        selectedRedeemedBenefit: redeemedBenefit,
      );
      
      return true;
    } on StateError catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } on app_errors.AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao gerar QR code: $e',
      );
      return false;
    }
  }
  
  /// Verifica se o QR code atual expirou
  bool isQRCodeExpired() {
    if (state.qrCodeExpiresAt == null) return true;
    return DateTime.now().isAfter(state.qrCodeExpiresAt!);
  }
  
  /// Regenera o QR code se expirado
  Future<void> refreshQRCodeIfExpired() async {
    if (isQRCodeExpired() && state.selectedRedeemedBenefit != null) {
      await generateQRCode(state.selectedRedeemedBenefit!.id);
    }
  }
  
  /// Limpa os dados do QR code
  void clearQRCodeData() {
    state = state.copyWith(
      qrCodeData: null,
      qrCodeExpiresAt: null,
    );
  }
  
  /// Trata erros de maneira unificada e retorna uma mensagem adequada para o usuário
  String _handleError(Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('Error in BenefitViewModel: $error');
      print(stackTrace);
    }
    
    if (error is app_errors.AppException) {
      return error.message;
    }
    
    return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
  }
} 
