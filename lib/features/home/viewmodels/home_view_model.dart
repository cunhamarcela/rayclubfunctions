// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/services/cache_service.dart';
import 'package:ray_club_app/features/home/models/home_model.dart';
import 'package:ray_club_app/features/home/repositories/home_repository.dart';
import 'package:ray_club_app/features/home/viewmodels/states/home_state.dart';

/// Provider para o repositório da Home
/// Responsável por fornecer uma instância do repositório de dados da Home
/// que será usado pelo ViewModel
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final supabase = Supabase.instance.client;
  final cacheService = ref.watch(cacheServiceProvider);
  return SupabaseHomeRepository(supabase, cacheService);
});

/// Provider para HomeViewModel
/// Fornece uma instância do ViewModel da Home que gerencia
/// o estado e a lógica de negócios da tela Home
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeViewModel(repository);
});

/// ViewModel para a tela Home
/// Responsável por gerenciar o estado e a lógica de negócios relacionada
/// à tela principal do aplicativo.
class HomeViewModel extends StateNotifier<HomeState> {
  /// Repositório que fornece acesso aos dados necessários para a Home
  final HomeRepository _repository;

  /// Construtor que inicializa o ViewModel com estado inicial
  /// e carrega os dados automaticamente
  /// 
  /// @param repository Instância do repositório de dados da Home
  HomeViewModel(this._repository) : super(HomeState.initial()) {
    loadHomeData();
  }

  /// Carrega todos os dados necessários para a tela Home
  /// 
  /// Recupera banners, destaques da semana, treinos recomendados,
  /// progresso do usuário e outros dados relevantes para a Home
  Future<void> loadHomeData() async {
    try {
      print('🔍 HomeViewModel: Iniciando carregamento de dados');
      state = HomeState.loading();
      
      print('🔍 HomeViewModel: Chamando repository.getHomeData()');
      final homeData = await _repository.getHomeData();
      
      print('✅ HomeViewModel: Dados carregados com sucesso');
      // Atualiza o estado com os dados carregados
      state = HomeState.loaded(homeData);
    } on AppException catch (e) {
      print('❌ HomeViewModel - Erro específico da aplicação: ${e.message}');
      print('❌ Erro original: ${e.originalError}');
      print('❌ Stack trace: ${e.stackTrace}');
      
      // Tentar carregar dados parciais em vez de mostrar apenas erro
      await _loadPartialData(errorMessage: e.message);
    } catch (e, stack) {
      print('❌ HomeViewModel - Erro genérico: $e');
      print('❌ Stack trace: $stack');
      
      // Tentar carregar dados parciais
      await _loadPartialData(errorMessage: 'Erro ao carregar dados: ${e.toString()}');
    }
  }
  
  /// Tenta carregar dados parciais quando o carregamento completo falha
  Future<void> _loadPartialData({required String errorMessage}) async {
    print('🔄 Tentando carregar dados parciais após erro');
    
    try {
      // Criando estrutura básica com dados vazios
      HomeData partialData = HomeData.empty();
      
      // Tentar carregar banners separadamente
      try {
        final banners = await _repository.getBanners();
        if (banners.isNotEmpty) {
          partialData = partialData.copyWith(
            banners: banners,
            activeBanner: banners.firstWhere(
              (banner) => banner.isActive, 
              orElse: () => banners.first
            ),
          );
          print('✅ Banners carregados em modo parcial: ${banners.length}');
        }
      } catch (e) {
        print('⚠️ Não foi possível carregar banners: $e');
      }
      
      // Tentar carregar categorias separadamente
      try {
        final categories = await _repository.getWorkoutCategories();
        if (categories.isNotEmpty) {
          partialData = partialData.copyWith(categories: categories);
          print('✅ Categorias carregadas em modo parcial: ${categories.length}');
        }
      } catch (e) {
        print('⚠️ Não foi possível carregar categorias: $e');
      }
      
      // Tentar carregar treinos populares separadamente
      try {
        final popularWorkouts = await _repository.getPopularWorkouts();
        if (popularWorkouts.isNotEmpty) {
          partialData = partialData.copyWith(popularWorkouts: popularWorkouts);
          print('✅ Treinos populares carregados em modo parcial: ${popularWorkouts.length}');
        }
      } catch (e) {
        print('⚠️ Não foi possível carregar treinos populares: $e');
      }
      
      // Definir estado com dados parciais e erro
      state = HomeState.partial(
        partialData,
        errorMessage: errorMessage,
      );
      print('✅ HomeViewModel: Carregamento parcial concluído');
    } catch (fallbackError) {
      print('❌ Erro também no carregamento parcial: $fallbackError');
      // Se tudo falhar, mostrar apenas a mensagem de erro
      state = HomeState.error(errorMessage);
    }
  }

  /// Atualiza o índice do banner atual
  /// 
  /// Usado pelo PageView de banners para controlar qual banner está sendo exibido
  /// 
  /// @param index Novo índice do banner a ser exibido
  void updateBannerIndex(int index) {
    if (state.data?.banners != null && 
        index >= 0 && 
        index < state.data!.banners.length) {
      state = state.copyWith(currentBannerIndex: index);
    }
  }
  
  /// Atualiza apenas os dados de progresso do usuário
  /// 
  /// Útil para atualizar o progresso após a realização de atividades
  /// sem recarregar todos os dados da tela
  Future<void> refreshUserProgress() async {
    try {
      if (state.data == null) {
        await loadHomeData();
        return;
      }
      
      final progress = await _repository.getUserProgress();
      
      // Atualiza apenas o progresso, mantendo os outros dados
      state = state.copyWith(
        data: state.data!.copyWith(
          progress: progress,
          lastUpdated: DateTime.now(),
        ),
      );
    } catch (e) {
      // Não alteramos o estado em caso de erro no refresh
      // apenas para não perdermos os dados já carregados
      print('Erro ao atualizar progresso: $e');
    }
  }
} 
