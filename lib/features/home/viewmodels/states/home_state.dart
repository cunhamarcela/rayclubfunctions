// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:ray_club_app/features/home/models/home_model.dart';

part 'home_state.freezed.dart';

/// Estado da tela Home usando Freezed para imutabilidade
@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    /// Dados completos da Home
    HomeData? data,
    
    /// Flag para indicar se está carregando
    @Default(false) bool isLoading,
    
    /// Mensagem de erro se houver falha
    String? error,
    
    /// Índice do banner atual na exibição
    @Default(0) int currentBannerIndex,
    
    /// Flag para indicar se a tela foi inicializada
    @Default(false) bool isInitialized,
  }) = _HomeState;
  
  /// Cria uma instância inicial vazia
  factory HomeState.initial() => const HomeState();
  
  /// Cria uma instância de estado de carregamento
  factory HomeState.loading() => const HomeState(isLoading: true);
  
  /// Cria uma instância de estado de erro
  factory HomeState.error(String message) => HomeState(error: message, isLoading: false);
  
  /// Cria uma instância de estado carregado com sucesso
  factory HomeState.loaded(HomeData data) => HomeState(
    data: data,
    isLoading: false,
    isInitialized: true,
  );
  
  /// Cria uma instância de estado com dados parciais e erro
  /// Útil quando parte dos dados foi carregada mas houve erro em algum componente
  factory HomeState.partial(HomeData partialData, {required String errorMessage}) => HomeState(
    data: partialData,
    error: errorMessage,
    isLoading: false,
    isInitialized: true,
  );
} 
