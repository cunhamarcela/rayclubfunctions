import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/profile/models/profile_model.dart';
import 'package:ray_club_app/providers/user_profile_provider.dart';
import '../helpers/test_helper.dart';
import 'package:mocktail/mocktail.dart';

/// 📋 **TESTES PROVIDER - SISTEMA EXPERT/BASIC**
/// 🗓️ Data: 2025-01-15 às 16:15 (CORRIGIDO)
/// 🧠 Autor: IA
/// 📄 Contexto: Testes unitários dos providers Expert/Basic, agora com mocks de repositório.

void main() {
  group('🔧 userProfileProvider', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    testWidgets('deve carregar perfil Expert corretamente', (tester) async {
      testLog('🧪 Iniciando teste: userProfileProvider Expert');
      
      // Arrange
      final mockProfile = createMockExpertUser();
      container = createTestProviderContainer(
        overrides: [
          // ✅ NOVO: Usa o override do repositório
          overrideWithProfile(mockProfile),
        ],
      );

      // Act
      await waitForAsyncProviders(container);
      final profileAsync = container.read(userProfileProvider);

      // Assert
      expect(profileAsync.hasValue, isTrue);
      final profile = profileAsync.value;
      expect(profile, isNotNull);
      // ✅ CORRIGIDO: Acessar campos através do .value
      expect(profile!.accountType, equals('expert'));
      expect(profile.id, equals('expert_user_123'));
      expect(profile.name, equals('Expert User'));
      
      testLog('✅ Perfil Expert carregado corretamente');
    });

    testWidgets('deve carregar perfil Basic corretamente', (tester) async {
      testLog('🧪 Iniciando teste: userProfileProvider Basic');
      
      // Arrange
      final mockProfile = createMockBasicUser();
      container = createTestProviderContainer(
        overrides: [
          // ✅ NOVO: Usa o override do repositório
          overrideWithProfile(mockProfile),
        ],
      );

      // Act
      await waitForAsyncProviders(container);
      final profileAsync = container.read(userProfileProvider);

      // Assert
      expect(profileAsync.hasValue, isTrue);
      final profile = profileAsync.value;
      expect(profile, isNotNull);
      // ✅ CORRIGIDO: Acessar campos através do .value
      expect(profile!.accountType, equals('basic'));
      expect(profile.id, equals('basic_user_456'));
      expect(profile.name, equals('Basic User'));
      
      testLog('✅ Perfil Basic carregado corretamente');
    });

    testWidgets('deve tratar usuário não autenticado', (tester) async {
      testLog('🧪 Iniciando teste: userProfileProvider não autenticado');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          // ✅ NOVO: Usa o override que simula um usuário deslogado
          overrideForUnauthenticatedUser(),
        ],
      );

      // Act
      await waitForAsyncProviders(container);
      final profileAsync = container.read(userProfileProvider);

      // Assert
      expect(profileAsync.hasValue, isTrue);
      final profile = profileAsync.value;
      expect(profile, isNull);
      // ✅ CORRIGIDO: O tratamento de null deve ser feito no isExpertUserProfileProvider
      
      testLog('✅ Usuário não autenticado tratado corretamente');
    });

    testWidgets('deve tratar erro no carregamento', (tester) async {
      testLog('🧪 Iniciando teste: userProfileProvider erro');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          // ✅ NOVO: Usa o override de erro
          overrideWithError(Exception('Erro de teste')),
        ],
      );

      // Act
      await waitForAsyncProviders(container);
      final profileAsync = container.read(userProfileProvider);

      // Assert
      expect(profileAsync.hasError, isTrue);
      expect(profileAsync.error, isA<Exception>());
      
      testLog('✅ Erro no carregamento tratado corretamente');
    });

    testWidgets('deve detectar estado de loading', (tester) async {
      testLog('🧪 Iniciando teste: userProfileProvider loading');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          overrideWithProfile(
            createMockExpertUser(),
            delay: const Duration(milliseconds: 500),
          ),
        ],
      );

      // Act & Assert: Verifica o estado de loading imediatamente
      expect(container.read(userProfileProvider).isLoading, isTrue);
      
      // Avança o tempo para completar o Future.delayed
      await tester.pump(const Duration(seconds: 1)); 
      
      // Verifica se o estado mudou para 'hasValue'
      expect(container.read(userProfileProvider).hasValue, isTrue);

      testLog('✅ Estado de loading detectado e resolvido corretamente');
    });
  });

  group('🚀 isExpertUserProfileProvider', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    testWidgets('deve retornar true para usuário Expert', (tester) async {
      testLog('🧪 Iniciando teste: isExpertUserProfileProvider true');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          // ✅ NOVO: Usa o override do repositório
          overrideWithProfile(createMockExpertUser()),
        ],
      );

      // Act
      await waitForAsyncProviders(container);
      final isExpertAsync = container.read(isExpertUserProfileProvider);

      // Assert
      expect(isExpertAsync.hasValue, isTrue);
      expect(isExpertAsync.value, isTrue);
      
      testLog('✅ Expert detectado corretamente');
    });

    testWidgets('deve retornar false para usuário Basic', (tester) async {
      testLog('🧪 Iniciando teste: isExpertUserProfileProvider false');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          // ✅ NOVO: Usa o override do repositório
          overrideWithProfile(createMockBasicUser()),
        ],
      );

      // Act
      await waitForAsyncProviders(container);
      final isExpertAsync = container.read(isExpertUserProfileProvider);

      // Assert
      expect(isExpertAsync.hasValue, isTrue);
      expect(isExpertAsync.value, isFalse);
      
      testLog('✅ Basic detectado corretamente');
    });

    testWidgets('deve retornar false para usuário não autenticado', (tester) async {
      testLog('🧪 Iniciando teste: isExpertUserProfileProvider não autenticado');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          overrideForUnauthenticatedUser(),
        ],
      );

      // Act
      await waitForAsyncProviders(container);
      final isExpertAsync = container.read(isExpertUserProfileProvider);

      // Assert
      expect(isExpertAsync.hasValue, isTrue);
      expect(isExpertAsync.value, isFalse);
      
      testLog('✅ Usuário não autenticado tratado como Basic');
    });

    testWidgets('deve retornar loading quando perfil está carregando', (tester) async {
      testLog('🧪 Iniciando teste: isExpertUserProfileProvider loading');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          overrideWithProfile(
            createMockExpertUser(),
            delay: const Duration(milliseconds: 500),
          ),
        ],
      );

      // Act & Assert
      expect(container.read(isExpertUserProfileProvider).isLoading, isTrue);
      
      // Avança o tempo para completar o Future.delayed
      await tester.pump(const Duration(seconds: 1));
      
      // Verifica se o estado mudou para 'hasValue'
      expect(container.read(isExpertUserProfileProvider).hasValue, isTrue);

      testLog('✅ Estado de loading propagado corretamente');
    });

    testWidgets('deve retornar error quando perfil falha', (tester) async {
      testLog('🧪 Iniciando teste: isExpertUserProfileProvider error');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          // ✅ NOVO: Usa o override de erro
          overrideWithError(Exception('Erro de teste')),
        ],
      );

      // Act
      await waitForAsyncProviders(container);
      final isExpertAsync = container.read(isExpertUserProfileProvider);

      // Assert
      expect(isExpertAsync.hasError, isTrue);
      expect(isExpertAsync.error, isA<Exception>());
      
      testLog('✅ Error propagado corretamente');
    });

    testWidgets('deve reagir a mudanças do perfil', (tester) async {
      testLog('🧪 Iniciando teste: isExpertUserProfileProvider reatividade');
      
      // Arrange
      final mockRepo = createMockRepository(profile: createMockBasicUser());
      
      container = createTestProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act 1 - verificar estado inicial
      await waitForAsyncProviders(container);
      var isExpertAsync = container.read(isExpertUserProfileProvider);
      expect(isExpertAsync.value, isFalse);

      // Act 2 - mudar para Expert
      when(() => mockRepo.getProfileById(any()))
          .thenAnswer((_) async => createMockExpertUser());
      
      // Invalida o provider para forçar a releitura com o novo mock
      container.invalidate(userProfileProvider);
      // ✅ CORRIGIDO: Aguarda o provider ser reconstruído
      await waitForAsyncProviders(container);
      
      isExpertAsync = container.read(isExpertUserProfileProvider);

      // Assert
      expect(isExpertAsync.value, isTrue);
      
      testLog('✅ Reatividade funcionando corretamente');
      await tester.pumpAndSettle();
    });
  });

  group('⚡ Performance', () {
    late ProviderContainer container;

    tearDown(() {
      container.dispose();
    });

    testWidgets('userProfileProvider deve ser rápido', (tester) async {
      testLog('🧪 Iniciando teste: Performance userProfileProvider');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          overrideWithProfile(createMockExpertUser()),
        ],
      );

      // Act & Assert
      await PerformanceTestHelper.validateFutureProviderPerformance(
        container,
        userProfileProvider,
        maxAcceptableTime: const Duration(milliseconds: 100),
        testName: 'userProfileProvider',
      );
      
      testLog('✅ Performance do userProfileProvider validada');
    });

    testWidgets('isExpertUserProfileProvider deve ser rápido', (tester) async {
      testLog('🧪 Iniciando teste: Performance isExpertUserProfileProvider');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          overrideWithProfile(createMockExpertUser()),
        ],
      );
      await waitForAsyncProviders(container);

      // Act & Assert
      PerformanceTestHelper.validateProviderPerformance(
        container,
        isExpertUserProfileProvider,
        maxAcceptableTime: const Duration(milliseconds: 50),
        testName: 'isExpertUserProfileProvider',
      );
      
      testLog('✅ Performance do isExpertUserProfileProvider validada');
    });

    testWidgets('deve funcionar bem com múltiplas leituras', (tester) async {
      testLog('🧪 Iniciando teste: Múltiplas leituras');
      
      // Arrange
      container = createTestProviderContainer(
        overrides: [
          overrideWithProfile(createMockExpertUser()),
        ],
      );
      await waitForAsyncProviders(container);

      // Act - múltiplas leituras
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        final isExpert = container.read(isExpertUserProfileProvider);
        expect(isExpert.value, isTrue);
      }
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 100)));
      
      testLog('✅ Múltiplas leituras otimizadas');
    });

    testWidgets('deve funcionar bem com mudanças frequentes', (tester) async {
      testLog('🧪 Iniciando teste: Mudanças frequentes');
      
      // Arrange
      final mockRepo = createMockRepository();
      container = createTestProviderContainer(
        overrides: [
          profileRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // Act - mudanças frequentes
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 10; i++) {
        if (i.isEven) {
          when(() => mockRepo.getProfileById(any())).thenAnswer((_) async => createMockExpertUser());
        } else {
          when(() => mockRepo.getProfileById(any())).thenAnswer((_) async => createMockBasicUser());
        }
        container.invalidate(userProfileProvider);
        // ✅ CORRIGIDO: Aguarda o provider ser reconstruído
        await waitForAsyncProviders(container);
        final isExpert = container.read(isExpertUserProfileProvider);
        expect(isExpert.hasValue, isTrue);
      }
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
      testLog('✅ Mudanças frequentes otimizadas');
      await tester.pumpAndSettle();
    });
  });
} 