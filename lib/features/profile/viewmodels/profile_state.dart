// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import '../../../core/viewmodels/base_view_model.dart';
import '../models/profile_model.dart';

part 'profile_state.freezed.dart';

/// Estado do ViewModel de perfil usando o novo padrão com BaseState<T>
@freezed
class ProfileState with _$ProfileState {
  const ProfileState._();

  /// Estado inicial, sem dados carregados
  const factory ProfileState.initial() = _ProfileStateInitial;

  /// Estado de carregamento
  const factory ProfileState.loading() = _ProfileStateLoading;

  /// Estado com perfil carregado
  const factory ProfileState.loaded({
    required Profile profile,
  }) = _ProfileStateLoaded;

  /// Estado de erro
  const factory ProfileState.error(String message) = _ProfileStateError;

  /// Estado de atualização em progresso
  const factory ProfileState.updating({
    required Profile profile,
  }) = _ProfileStateUpdating;
  
  /// Verifica se está em estado de carregando
  bool get isLoading => maybeWhen(
        loading: () => true,
        updating: (_) => true,
        orElse: () => false,
      );
  
  /// Verifica se está em estado de erro
  bool get hasError => maybeWhen(
        error: (_) => true,
        orElse: () => false,
      );
  
  /// Obtém a mensagem de erro, se houver
  String? get errorMessage => maybeWhen(
        error: (message) => message,
        orElse: () => null,
      );
  
  /// Obtém o perfil do usuário, se disponível
  Profile? get profile => maybeWhen(
        loaded: (profile) => profile,
        updating: (profile) => profile,
        orElse: () => null,
      );
} 
