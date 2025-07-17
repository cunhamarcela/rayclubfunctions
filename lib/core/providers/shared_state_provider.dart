// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers.dart'; // Importando o arquivo que contém o sharedPreferencesProvider

part 'shared_state_provider.freezed.dart';
part 'shared_state_provider.g.dart';

/// Modelo de estado compartilhado para facilitar a comunicação entre features
@freezed
class SharedAppState with _$SharedAppState {
  const factory SharedAppState({
    /// ID do usuário logado
    String? userId,
    
    /// Nome do usuário para uso em diferentes features
    String? userName,
    
    /// Status da assinatura do usuário
    @Default(false) bool isSubscriber,
    
    /// ID do desafio selecionado atualmente (usado em várias features)
    String? currentChallengeId,
    
    /// ID do treino selecionado atualmente
    String? currentWorkoutId,
    
    /// Flag que indica se o app está operando em modo offline
    @Default(false) bool isOfflineMode,
    
    /// Última tela visitada (para navegação)
    String? lastVisitedRoute,
    
    /// Dados personalizados que podem ser compartilhados entre features
    @Default({}) Map<String, dynamic> customData,
  }) = _SharedAppState;

  factory SharedAppState.fromJson(Map<String, dynamic> json) => 
      _$SharedAppStateFromJson(json);
}

/// Chave para armazenar o estado compartilhado no SharedPreferences
const String _sharedStateKey = 'ray_club_shared_state';

/// Validador de entradas para o estado compartilhado
class StateValidator {
  /// Valida se um ID não está vazio e tem o formato esperado
  static bool isValidId(String? id) {
    if (id == null || id.isEmpty) return false;
    // Adicione outras validações conforme necessário, como formato UUID
    return true;
  }
  
  /// Valida se um nome de usuário é aceitável
  static bool isValidUserName(String? userName) {
    if (userName == null) return false;
    return userName.trim().isNotEmpty && userName.length <= 100;
  }

  /// Valida se uma rota é válida
  static bool isValidRoute(String? route) {
    if (route == null || route.isEmpty) return false;
    return route.startsWith('/');
  }
}

/// Provider global para compartilhar estado entre diferentes features
final sharedStateProvider = StateNotifierProvider<SharedStateNotifier, SharedAppState>((ref) {
  // Obtendo o SharedPreferences através do provider
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return SharedStateNotifier(sharedPreferences);
});

/// Gerenciador de estado compartilhado
class SharedStateNotifier extends StateNotifier<SharedAppState> {
  final SharedPreferences _preferences;
  
  SharedStateNotifier(this._preferences) : super(const SharedAppState()) {
    // Carregar o estado salvo quando o notifier é criado
    _loadSavedState();
  }
  
  /// Carrega o estado salvo do SharedPreferences
  Future<void> _loadSavedState() async {
    try {
      final savedState = _preferences.getString(_sharedStateKey);
      if (savedState != null && savedState.isNotEmpty) {
        final Map<String, dynamic> jsonMap = jsonDecode(savedState);
        state = SharedAppState.fromJson(jsonMap);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar estado compartilhado: $e');
      }
      // Em caso de erro, mantém o estado padrão
    }
  }
  
  /// Salva o estado atual no SharedPreferences
  Future<void> _saveState() async {
    try {
      final jsonString = jsonEncode(state.toJson());
      await _preferences.setString(_sharedStateKey, jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao salvar estado compartilhado: $e');
      }
    }
  }

  /// Atualiza informações do usuário
  void updateUserInfo({String? userId, String? userName, bool? isSubscriber}) {
    // Validando entradas
    if (userId != null && !StateValidator.isValidId(userId)) {
      throw ArgumentError('ID de usuário inválido: $userId');
    }
    
    if (userName != null && !StateValidator.isValidUserName(userName)) {
      throw ArgumentError('Nome de usuário inválido: $userName');
    }
    
    state = state.copyWith(
      userId: userId ?? state.userId,
      userName: userName ?? state.userName,
      isSubscriber: isSubscriber ?? state.isSubscriber,
    );
    
    _saveState();
  }

  /// Atualiza o desafio atual
  void setCurrentChallenge(String? challengeId) {
    if (challengeId != null && !StateValidator.isValidId(challengeId)) {
      throw ArgumentError('ID de desafio inválido: $challengeId');
    }
    
    state = state.copyWith(currentChallengeId: challengeId);
    _saveState();
  }

  /// Atualiza o treino atual
  void setCurrentWorkout(String? workoutId) {
    if (workoutId != null && !StateValidator.isValidId(workoutId)) {
      throw ArgumentError('ID de treino inválido: $workoutId');
    }
    
    state = state.copyWith(currentWorkoutId: workoutId);
    _saveState();
  }

  /// Atualiza o status de conectividade
  void setOfflineMode(bool isOffline) {
    state = state.copyWith(isOfflineMode: isOffline);
    _saveState();
  }

  /// Registra a última rota visitada
  void setLastVisitedRoute(String route) {
    if (!StateValidator.isValidRoute(route)) {
      throw ArgumentError('Rota inválida: $route');
    }
    
    state = state.copyWith(lastVisitedRoute: route);
    _saveState();
  }

  /// Armazena dados personalizados para compartilhamento entre features
  void setCustomData(String key, dynamic value) {
    if (key.isEmpty) {
      throw ArgumentError('Chave não pode ser vazia');
    }
    
    // Validando se o valor é serializável para evitar problemas ao salvar
    try {
      jsonEncode(value);
    } catch (e) {
      throw ArgumentError('Valor não é serializável: $value');
    }
    
    final newCustomData = Map<String, dynamic>.from(state.customData);
    newCustomData[key] = value;
    state = state.copyWith(customData: newCustomData);
    
    _saveState();
  }

  /// Recupera dados personalizados
  dynamic getCustomData(String key) {
    return state.customData[key];
  }

  /// Remove dados personalizados
  void removeCustomData(String key) {
    if (!state.customData.containsKey(key)) {
      return; // Não faz nada se a chave não existir
    }
    
    final newCustomData = Map<String, dynamic>.from(state.customData);
    newCustomData.remove(key);
    state = state.copyWith(customData: newCustomData);
    
    _saveState();
  }

  /// Limpa todos os dados (útil para logout)
  void clearAll() {
    state = const SharedAppState();
    _saveState();
  }
} 
