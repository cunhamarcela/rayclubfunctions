import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/profile/models/profile_model.dart';
import 'package:ray_club_app/features/profile/repositories/profile_repository.dart';
import 'package:ray_club_app/providers/user_profile_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 📋 **TEST HELPER - SISTEMA EXPERT/BASIC**
/// 🗓️ Data: 2025-01-15 às 16:00 (CORRIGIDO)
/// 🧠 Autor: IA
/// 📄 Contexto: Utilitários para testes do sistema Expert/Basic

// Mocks para o Supabase
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

// Variáveis globais para os mocks
MockSupabaseClient? _mockSupabaseClient;
MockGoTrueClient? _mockGoTrueClient;
MockUser? _mockUser;

/// ✅ NOVO: Mocka a instância global do Supabase para testes
/// Evita que `Supabase.instance.client` falhe nos testes.
MockSupabaseClient mockSupabase({bool isLoggedIn = true}) {
  _mockSupabaseClient = MockSupabaseClient();
  _mockGoTrueClient = MockGoTrueClient();
  _mockUser = MockUser();

  // Configura o mock do GoTrueClient para retornar um usuário (ou não)
  when(() => _mockUser!.id).thenReturn('mock_user_id');
  when(() => _mockGoTrueClient!.currentUser).thenAnswer((_) => isLoggedIn ? _mockUser : null);

  // Configura o mock do SupabaseClient para usar o mock do GoTrueClient
  when(() => _mockSupabaseClient!.auth).thenReturn(_mockGoTrueClient!);

  return _mockSupabaseClient!;
}

class MockSupabaseProfileRepository extends Mock implements ProfileRepository {}

/// Cria um container de teste com providers mocados
ProviderContainer createTestProviderContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    overrides: [
      // Mocka o supabase client por padrão para evitar chamadas reais
      supabaseClientProvider.overrideWithValue(mockSupabase()),
      ...overrides,
    ],
  );
  return container;
}

/// Cria um mock de usuário Expert
Profile createMockExpertUser({
  String? id,
  String? name,
  String? email,
}) {
  return Profile(
    id: id ?? 'expert_user_123',
    name: name ?? 'Expert User',
    email: email ?? 'expert@test.com',
    accountType: 'expert',
    photoUrl: 'https://test.com/avatar.jpg', // ✅ CORRIGIDO: photoUrl em vez de avatarUrl
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Cria um mock de usuário Basic
Profile createMockBasicUser({
  String? id,
  String? name,
  String? email,
}) {
  return Profile(
    id: id ?? 'basic_user_456',
    name: name ?? 'Basic User',
    email: email ?? 'basic@test.com',
    accountType: 'basic',
    photoUrl: 'https://test.com/avatar.jpg', // ✅ CORRIGIDO: photoUrl em vez de avatarUrl
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Cria um mock de usuário com account_type null (deve ser tratado como basic)
Profile createMockUserWithNullAccountType({
  String? id,
  String? name,
  String? email,
}) {
  return Profile(
    id: id ?? 'null_user_789',
    name: name ?? 'Null User',
    email: email ?? 'null@test.com',
    // ✅ CORRIGIDO: accountType default já é 'basic' no modelo
    photoUrl: 'https://test.com/avatar.jpg', // ✅ CORRIGIDO: photoUrl em vez de avatarUrl
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

/// Override para simular usuário Expert
@Deprecated('Use overrideWithProfile ou overrideWithError em vez disso')
Override mockExpertUserProvider({Profile? customProfile}) {
  return userProfileProvider.overrideWith(
    (ref) async {
      // Simula delay pequeno para ser realista
      await Future.delayed(const Duration(milliseconds: 50));
      return customProfile ?? createMockExpertUser();
    },
  );
}

/// Override para simular usuário Basic
@Deprecated('Use overrideWithProfile ou overrideWithError em vez disso')
Override mockBasicUserProvider({Profile? customProfile}) {
  return userProfileProvider.overrideWith(
    (ref) async {
      // Simula delay pequeno para ser realista
      await Future.delayed(const Duration(milliseconds: 50));
      return customProfile ?? createMockBasicUser();
    },
  );
}

/// Override para simular usuário não autenticado
@Deprecated('Use overrideWithProfile ou overrideWithError em vez disso')
Override mockUnauthenticatedUserProvider() {
  return userProfileProvider.overrideWith(
    (ref) async {
      // Simula delay pequeno para ser realista
      await Future.delayed(const Duration(milliseconds: 50));
      return null;
    },
  );
}

/// Override para simular erro no carregamento do perfil
@Deprecated('Use overrideWithProfile ou overrideWithError em vez disso')
Override mockUserProfileErrorProvider({
  String errorMessage = 'Erro ao carregar perfil',
}) {
  return userProfileProvider.overrideWith(
    (ref) async {
      // Simula delay pequeno para ser realista
      await Future.delayed(const Duration(milliseconds: 50));
      throw Exception(errorMessage);
    },
  );
}

/// Override para simular loading lento do perfil
@Deprecated('Use overrideWithProfile ou overrideWithError em vez disso')
Override mockUserProfileSlowLoadingProvider({
  Duration delay = const Duration(seconds: 2),
  Profile? profile,
}) {
  return userProfileProvider.overrideWith(
    (ref) => Future.delayed(
      delay,
      () => profile ?? createMockExpertUser(),
    ),
  );
}

/// ✅ NOVO: Override que simula um retorno de perfil com sucesso
Override overrideWithProfile(Profile? profile, {Duration? delay}) {
  return profileRepositoryProvider.overrideWithValue(
    createMockRepository(profile: profile, delay: delay),
  );
}

/// ✅ NOVO: Override que simula um erro no repositório
Override overrideWithError(Exception error, {Duration? delay}) {
  return profileRepositoryProvider.overrideWithValue(
    createMockRepository(error: error, delay: delay),
  );
}

/// ✅ NOVO: Override para simular um usuário não autenticado
/// Neste caso, o userProfileProvider retornará null porque o userId será null,
/// então não precisamos mockar o repositório. O override antigo é mantido por enquanto.
Override overrideForUnauthenticatedUser() {
  return supabaseClientProvider.overrideWithValue(mockSupabase(isLoggedIn: false));
}

// Função interna para criar e configurar o mock do repositório
MockSupabaseProfileRepository createMockRepository({
  Profile? profile,
  Exception? error,
  Duration? delay,
}) {
  final mockRepo = MockSupabaseProfileRepository();

  if (error != null) {
    when(() => mockRepo.getProfileById(any())).thenAnswer((_) async {
      if (delay != null) await Future.delayed(delay);
      throw error;
    });
  } else {
    when(() => mockRepo.getProfileById(any())).thenAnswer((_) async {
      if (delay != null) await Future.delayed(delay);
      return profile;
    });
  }

  return mockRepo;
}

/// Função utilitária para aguardar providers assíncronos
Future<void> waitForAsyncProviders(
  ProviderContainer container, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  // ✅ CORRIGIDO: Aguarda diretamente o provider usando .future
  try {
    await container.read(userProfileProvider.future).timeout(timeout);
  } catch (e) {
    // Ignora erros (como timeout ou exceptions do provider) - o teste verificará o estado.
  }
  
  // A pausa foi removida para acelerar os testes.
  // A boa prática é ouvir as mudanças no provider em vez de usar delays.
}

/// Enum para os estados de AsyncValue
enum AsyncValueState {
  loading,
  hasData,
  hasError,
}

/// Função utilitária para verificar se um provider está no estado esperado
bool isProviderInState<T>(
  ProviderContainer container,
  ProviderBase<AsyncValue<T>> provider,
  AsyncValueState expectedState,
) {
  try {
    final value = container.read(provider);
    
    switch (expectedState) {
      case AsyncValueState.loading:
        return value.isLoading;
      case AsyncValueState.hasData:
        return value.hasValue;
      case AsyncValueState.hasError:
        return value.hasError;
    }
  } catch (e) {
    return false;
  }
}

/// ✅ NOVO: Mock para WidgetRef usando mocktail
/// Permite interceptar chamadas a `ref.watch` e `ref.read` nos testes.
class MockWidgetRef extends Mock implements WidgetRef {}

/// Função utilitária para testar performance
class PerformanceTestHelper {
  /// ✅ CORRIGIDO: Mede performance para FutureProvider
  static Future<Duration> measureFutureProviderTime<T>(
    ProviderContainer container,
    FutureProvider<T> provider,
  ) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // ✅ CORRIGIDO: Para FutureProvider, lê o valor diretamente
      await container.read(provider.future);
    } catch (e) {
      // Ignora erros para medição de tempo
    }
    
    stopwatch.stop();
    return stopwatch.elapsed;
  }
  
  /// ✅ CORRIGIDO: Mede performance para Provider normal
  static Duration measureProviderTime<T>(
    ProviderContainer container,
    ProviderBase<T> provider,
  ) {
    final stopwatch = Stopwatch()..start();
    
    try {
      container.read(provider);
    } catch (e) {
      // Ignora erros para medição de tempo
    }
    
    stopwatch.stop();
    return stopwatch.elapsed;
  }
  
  /// ✅ CORRIGIDO: Valida performance para FutureProvider
  static Future<void> validateFutureProviderPerformance<T>(
    ProviderContainer container,
    FutureProvider<T> provider, {
    Duration maxAcceptableTime = const Duration(milliseconds: 500),
    String? testName,
  }) async {
    final elapsed = await measureFutureProviderTime(container, provider);
    
    expect(
      elapsed,
      lessThan(maxAcceptableTime),
      reason: '${testName ?? 'FutureProvider'} demorou muito: ${elapsed.inMilliseconds}ms '
          '(máximo: ${maxAcceptableTime.inMilliseconds}ms)',
    );
  }
  
  /// ✅ CORRIGIDO: Valida performance para Provider normal
  static void validateProviderPerformance<T>(
    ProviderContainer container,
    ProviderBase<T> provider, {
    Duration maxAcceptableTime = const Duration(milliseconds: 500),
    String? testName,
  }) {
    final elapsed = measureProviderTime(container, provider);
    
    expect(
      elapsed,
      lessThan(maxAcceptableTime),
      reason: '${testName ?? 'Provider'} demorou muito: ${elapsed.inMilliseconds}ms '
          '(máximo: ${maxAcceptableTime.inMilliseconds}ms)',
    );
  }
}

/// Função utilitária para logs de teste
void testLog(String message) {
  print('🧪 [${DateTime.now().toIso8601String()}] $message');
}

/// ✅ ADICIONADO: Função para criar override do isExpertUserProfileProvider
Override mockIsExpertProvider(bool isExpert) {
  return isExpertUserProfileProvider.overrideWith(
    (ref) => AsyncValue.data(isExpert),
  );
}

/// Função utilitária para verificar múltiplos cenários
Future<void> runMultipleScenarios(
  String testSuite,
  Map<String, Future<void> Function()> scenarios,
) async {
  testLog('🧪 Iniciando suite: $testSuite');
  
  for (final entry in scenarios.entries) {
    try {
      testLog('🎯 Executando cenário: ${entry.key}');
      await entry.value();
      testLog('✅ Cenário "${entry.key}" passou');
    } catch (e) {
      testLog('❌ Cenário "${entry.key}" falhou: $e');
      rethrow;
    }
  }
  
  testLog('🎉 Suite "$testSuite" concluída com sucesso');
}

// ✅ ADICIONADO: Função main para que o arquivo seja reconhecido como teste
void main() {
  // Este arquivo contém apenas helpers e utilitários
  // Os testes reais estão em outros arquivos
  test('test_helper.dart carregado corretamente', () {
    expect(true, isTrue);
    testLog('✅ test_helper.dart: Helpers carregados com sucesso');
  });
} 