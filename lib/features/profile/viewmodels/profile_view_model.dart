// Flutter imports:
import 'package:flutter/foundation.dart';

// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../../../core/errors/app_exception.dart';
import '../../../core/providers/supabase_providers.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/viewmodels/base_view_model.dart';
import '../models/profile_model.dart';
import '../repositories/profile_repository.dart';
import '../repositories/supabase_profile_repository.dart';
import '../providers/profile_providers.dart';

/// Provider para o repositório de perfil
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // Em ambiente de produção, usa a implementação Supabase
  // Em desenvolvimento ou testes, pode usar o mock
  final supabase = ref.watch(supabaseClientProvider);
  final offlineHelper = ref.watch(offlineRepositoryHelperProvider);
  
  // Adicionar suporte offline
  return SupabaseProfileRepository(
    supabase,
    offlineHelper,
  );
});

/// Provider para o ViewModel de perfil
final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, BaseState<Profile>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  
  return ProfileViewModel(
    repository: repository,
    connectivityService: connectivityService,
    ref: ref,
  );
});

/// ViewModel para gerenciar o perfil do usuário
class ProfileViewModel extends BaseViewModel<Profile> {
  final ProfileRepository _repository;
  final Ref _ref;

  /// Construtor
  ProfileViewModel({
    required ProfileRepository repository,
    ConnectivityService? connectivityService,
    required Ref ref,
  }) : _repository = repository,
       _ref = ref,
       super(connectivityService: connectivityService);
  
  @override
  Future<void> loadData({Profile? useCachedData}) async {
    if (useCachedData != null) {
      state = BaseState.data(data: useCachedData);
      // Ainda tenta recarregar em background
      _loadCurrentUserProfile(silentUpdate: true);
      return;
    }
    
    await _loadCurrentUserProfile();
  }
  
  /// Carrega o perfil do usuário atual
  Future<void> _loadCurrentUserProfile({bool silentUpdate = false}) async {
    try {
      if (!silentUpdate) {
        state = const BaseState.loading();
      }
      
      final profile = await _repository.getCurrentUserProfile();
      
      if (profile == null) {
        if (!silentUpdate) {
          state = const BaseState.error(message: 'Perfil não encontrado');
        }
        return;
      }
      
      state = BaseState.data(data: profile);
    } catch (e, stackTrace) {
      if (!silentUpdate) {
        state = handleError(e, stackTrace: stackTrace);
      }
      logError('Erro ao carregar perfil', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Carrega o perfil do usuário por ID
  Future<void> loadProfileById(String userId) async {
    try {
      state = const BaseState.loading();
      
      final profile = await _repository.getProfileById(userId);
      
      if (profile == null) {
        state = const BaseState.error(message: 'Perfil não encontrado');
        return;
      }
      
      state = BaseState.data(data: profile);
    } catch (e, stackTrace) {
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao carregar perfil por ID', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Atualiza o perfil do usuário
  Future<void> updateProfile({
    String? name,
    String? bio,
    List<String>? goals,
    String? phone,
    String? gender,
    DateTime? birthDate,
    String? instagram,
  }) async {
    // Verificar se temos o perfil atual
    final currentState = state;
    if (currentState is! BaseStateData<Profile>) {
      state = const BaseState.error(message: 'Perfil não disponível para atualização');
      return;
    }

    final currentProfile = currentState.data;

    try {
      debugPrint('🔍 Iniciando atualização de perfil:');
      debugPrint('   - Nome: $name');
      debugPrint('   - Telefone: $phone');
      debugPrint('   - Gênero: $gender');
      debugPrint('   - Data nascimento: $birthDate');
      debugPrint('   - Instagram: $instagram');
      debugPrint('   - Bio: $bio');

      state = const BaseState.loading();

      // Validar dados antes de enviar
      if (phone != null && phone.isNotEmpty && !_isValidPhone(phone)) {
        throw AppException(message: 'Número de telefone inválido. Use o formato (XX) XXXXX-XXXX');
      }

      if (instagram != null && instagram.isNotEmpty && !_isValidInstagram(instagram)) {
        throw AppException(message: 'Instagram inválido. Use o formato @seuuser ou seuuser');
      }

      if (birthDate != null && birthDate.isAfter(DateTime.now())) {
        throw AppException(message: 'Data de nascimento não pode ser no futuro');
      }

      debugPrint('✅ Validações aprovadas, enviando para repositório...');

      final updatedProfile = await _repository.updateProfile(
        currentProfile.copyWith(
          name: name ?? currentProfile.name,
          bio: bio ?? currentProfile.bio,
          goals: goals ?? currentProfile.goals,
          phone: phone ?? currentProfile.phone,
          gender: gender ?? currentProfile.gender,
          birthDate: birthDate ?? currentProfile.birthDate,
          instagram: instagram ?? currentProfile.instagram,
        ),
      );

      debugPrint('✅ Perfil atualizado com sucesso - primeira etapa');

      // 🔄 FORÇA RECARREGAMENTO COMPLETO DO BANCO
      debugPrint('🔄 Forçando recarregamento completo dos dados do banco...');
      
      // Aguardar um pouco para garantir que o banco foi atualizado
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Recarregar dados diretamente do banco
      final freshProfile = await _repository.getCurrentUserProfile();
      
      if (freshProfile != null) {
        debugPrint('✅ Dados recarregados do banco:');
        debugPrint('   - Nome: "${freshProfile.name}"');
        debugPrint('   - Telefone: "${freshProfile.phone}"');
        debugPrint('   - Instagram: "${freshProfile.instagram}"');
        debugPrint('   - Gênero: "${freshProfile.gender}"');
        
        state = BaseState.data(data: freshProfile);
      } else {
        debugPrint('⚠️ Falha ao recarregar dados do banco, usando dados do update');
        state = BaseState.data(data: updatedProfile);
      }

      // 🔄 Invalidar TODOS os providers relacionados ao perfil
      debugPrint('🔄 Invalidando todos os providers relacionados...');
      _ref.invalidate(currentProfileProvider);
      _ref.invalidate(userPhotoUrlProvider);
      _ref.invalidate(userDisplayNameProvider);
      
      // Invalidar o próprio profileViewModelProvider para forçar rebuild completo
      _ref.invalidateSelf();

      debugPrint('✅ Providers invalidados após atualização do perfil');
      
      // 🔄 AGUARDAR MAIS UM POUCO PARA GARANTIR PROPAGAÇÃO
      await Future.delayed(const Duration(milliseconds: 300));
      
      debugPrint('✅ Atualização de perfil finalizada com sucesso');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao atualizar perfil: $e');
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao atualizar perfil', error: e, stackTrace: stackTrace);
      rethrow; // Permitir que a UI trate o erro
    }
  }
  
  /// Valida número de telefone
  bool _isValidPhone(String phone) {
    final numericPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return numericPhone.length >= 10 && numericPhone.length <= 11;
  }
  
  /// Valida Instagram
  bool _isValidInstagram(String instagram) {
    final cleanInstagram = instagram.replaceAll('@', '');
    final regex = RegExp(r'^[a-zA-Z0-9._]{1,30}$');
    return regex.hasMatch(cleanInstagram);
  }
  
  /// Atualiza a foto de perfil do usuário
  Future<String> uploadProfilePhoto(String filePath) async {
    try {
      // Verificar se temos o perfil atual
      final currentState = state;
      if (currentState is! BaseStateData<Profile>) {
        throw Exception('Perfil não disponível para atualização');
      }
      
      final currentProfile = currentState.data;
      
      state = const BaseState.loading();
      
      // Fazer upload da foto
      final photoUrl = await _repository.updateProfilePhoto(currentProfile.id, filePath);
      
      // Atualizar o estado com a nova URL da foto
      final updatedProfile = currentProfile.copyWith(
        photoUrl: photoUrl,
        updatedAt: DateTime.now(),
      );
      
      state = BaseState.data(data: updatedProfile);
      
      // 🔄 Invalidar providers para forçar recarregamento da foto em toda a UI
      _ref.invalidate(currentProfileProvider);
      _ref.invalidate(userPhotoUrlProvider);
      _ref.invalidate(userDisplayNameProvider);
      
      debugPrint('✅ Providers invalidados após upload da foto');
      
      return photoUrl;
    } catch (e, stackTrace) {
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao fazer upload da foto de perfil', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Atualiza o email do usuário
  Future<void> updateEmail(String email) async {
    // Verificar se temos o perfil atual
    final currentState = state;
    if (currentState is! BaseStateData<Profile>) {
      state = const BaseState.error(message: 'Perfil não disponível para atualização');
      return;
    }
    
    final currentProfile = currentState.data;
    
    try {
      state = const BaseState.loading();
      
      await _repository.updateEmail(currentProfile.id, email);
      
      final updatedProfile = currentProfile.copyWith(
        email: email,
        updatedAt: DateTime.now(),
      );
      
      state = BaseState.data(data: updatedProfile);
    } catch (e, stackTrace) {
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao atualizar email', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Envia link para redefinição de senha
  Future<void> sendPasswordResetLink(String email) async {
    try {
      // Não alteramos o estado para não interromper a UI
      await _repository.sendPasswordResetLink(email);
    } catch (e, stackTrace) {
      logError('Erro ao enviar link de redefinição de senha', error: e, stackTrace: stackTrace);
      rethrow; // Deixa o chamador lidar com o erro
    }
  }
  
  /// Verifica a disponibilidade de um nome de usuário
  Future<bool> isUsernameAvailable(String username) async {
    try {
      return await _repository.isUsernameAvailable(username);
    } catch (e, stackTrace) {
      logError('Erro ao verificar disponibilidade de username', error: e, stackTrace: stackTrace);
      return false; // Em caso de erro, considera indisponível por segurança
    }
  }
  
  /// Atualiza as metas do perfil do usuário
  Future<void> updateProfileGoals({
    int? dailyWaterGoal,
    int? dailyWorkoutGoal,
    int? weeklyWorkoutGoal,
    double? weightGoal,
    double? currentWeight,
    List<String>? preferredWorkoutTypes,
  }) async {
    // Verificar se temos o perfil atual
    final currentState = state;
    if (currentState is! BaseStateData<Profile>) {
      state = const BaseState.error(message: 'Perfil não disponível para atualização');
      return;
    }
    
    final currentProfile = currentState.data;
    
    try {
      state = const BaseState.loading();
      
      final updatedProfile = await _repository.updateProfileGoals(
        userId: currentProfile.id,
        dailyWaterGoal: dailyWaterGoal,
        dailyWorkoutGoal: dailyWorkoutGoal,
        weeklyWorkoutGoal: weeklyWorkoutGoal,
        weightGoal: weightGoal,
        currentWeight: currentWeight,
        preferredWorkoutTypes: preferredWorkoutTypes,
      );
      
      state = BaseState.data(data: updatedProfile);
    } catch (e, stackTrace) {
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao atualizar metas do perfil', error: e, stackTrace: stackTrace);
    }
  }
  
  /// Exclui a conta do usuário
  Future<void> deleteAccount() async {
    try {
      final currentState = state;
      if (currentState is! BaseStateData<Profile>) {
        throw Exception('Perfil não disponível para exclusão');
      }
      
      final userId = currentState.data.id;
      
      state = const BaseState.loading();
      
      await _repository.deleteAccount(userId);
      
      // Após excluir a conta, atualizamos o estado para refletir que não há mais usuário
      state = const BaseState.initial();
    } catch (e, stackTrace) {
      state = handleError(e, stackTrace: stackTrace);
      logError('Erro ao excluir conta', error: e, stackTrace: stackTrace);
      rethrow; // Propagar o erro para que o chamador possa exibir uma mensagem apropriada
    }
  }
} 
