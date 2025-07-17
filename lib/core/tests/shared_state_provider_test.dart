// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../providers/providers.dart';
import '../providers/shared_state_provider.dart';

void main() {
  late ProviderContainer container;
  late SharedPreferences preferences;

  setUp(() async {
    // Configurar SharedPreferences para testes
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    
    // Criar container com override para o provider do SharedPreferences
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SharedStateNotifier', () {
    test('deve inicializar com estado padrão', () {
      final state = container.read(sharedStateProvider);
      
      expect(state.userId, isNull);
      expect(state.userName, isNull);
      expect(state.isSubscriber, isFalse);
      expect(state.isOfflineMode, isFalse);
      expect(state.customData, isEmpty);
    });

    test('deve atualizar informações do usuário', () {
      final notifier = container.read(sharedStateProvider.notifier);
      
      notifier.updateUserInfo(
        userId: 'user-123',
        userName: 'Test User',
        isSubscriber: true,
      );
      
      final state = container.read(sharedStateProvider);
      expect(state.userId, equals('user-123'));
      expect(state.userName, equals('Test User'));
      expect(state.isSubscriber, isTrue);
    });

    test('deve validar ID de usuário inválido', () {
      final notifier = container.read(sharedStateProvider.notifier);
      
      expect(
        () => notifier.updateUserInfo(userId: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('deve validar nome de usuário inválido', () {
      final notifier = container.read(sharedStateProvider.notifier);
      
      expect(
        () => notifier.updateUserInfo(userName: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('deve atualizar o modo offline', () {
      final notifier = container.read(sharedStateProvider.notifier);
      
      notifier.setOfflineMode(true);
      
      final state = container.read(sharedStateProvider);
      expect(state.isOfflineMode, isTrue);
    });

    test('deve gerenciar dados personalizados', () {
      final notifier = container.read(sharedStateProvider.notifier);
      
      // Adicionar dado
      notifier.setCustomData('testKey', 'testValue');
      var state = container.read(sharedStateProvider);
      expect(state.customData['testKey'], equals('testValue'));
      
      // Atualizar dado
      notifier.setCustomData('testKey', 'newValue');
      state = container.read(sharedStateProvider);
      expect(state.customData['testKey'], equals('newValue'));
      
      // Obter dado
      final value = notifier.getCustomData('testKey');
      expect(value, equals('newValue'));
      
      // Remover dado
      notifier.removeCustomData('testKey');
      state = container.read(sharedStateProvider);
      expect(state.customData['testKey'], isNull);
    });

    test('deve limpar todos os dados', () {
      final notifier = container.read(sharedStateProvider.notifier);
      
      // Configurar alguns dados
      notifier.updateUserInfo(userId: 'user-123', userName: 'Test User');
      notifier.setCurrentChallenge('challenge-123');
      notifier.setCustomData('testKey', 'testValue');
      
      // Verificar que os dados foram configurados
      var state = container.read(sharedStateProvider);
      expect(state.userId, equals('user-123'));
      expect(state.currentChallengeId, equals('challenge-123'));
      expect(state.customData['testKey'], equals('testValue'));
      
      // Limpar todos os dados
      notifier.clearAll();
      
      // Verificar que todos os dados foram limpos
      state = container.read(sharedStateProvider);
      expect(state.userId, isNull);
      expect(state.userName, isNull);
      expect(state.currentChallengeId, isNull);
      expect(state.customData, isEmpty);
    });

    test('deve validar valores não-serializáveis em customData', () {
      final notifier = container.read(sharedStateProvider.notifier);
      
      // Tentar adicionar um valor não-serializável
      expect(
        () => notifier.setCustomData('testKey', Object()),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('StateValidator', () {
    test('deve validar IDs corretamente', () {
      expect(StateValidator.isValidId('valid-id'), isTrue);
      expect(StateValidator.isValidId(''), isFalse);
      expect(StateValidator.isValidId(null), isFalse);
    });

    test('deve validar nomes de usuário corretamente', () {
      expect(StateValidator.isValidUserName('Valid User'), isTrue);
      expect(StateValidator.isValidUserName(''), isFalse);
      expect(StateValidator.isValidUserName('   '), isFalse);
      expect(StateValidator.isValidUserName(null), isFalse);
    });

    test('deve validar rotas corretamente', () {
      expect(StateValidator.isValidRoute('/home'), isTrue);
      expect(StateValidator.isValidRoute('/challenges/123'), isTrue);
      expect(StateValidator.isValidRoute('invalid-route'), isFalse);
      expect(StateValidator.isValidRoute(''), isFalse);
      expect(StateValidator.isValidRoute(null), isFalse);
    });
  });
} 
