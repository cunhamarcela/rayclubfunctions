// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/services/auth_service.dart';
import 'package:ray_club_app/features/settings/models/advanced_settings_state.dart';
import 'package:ray_club_app/features/settings/repositories/advanced_settings_repository.dart';
import 'package:ray_club_app/features/settings/viewmodels/advanced_settings_view_model.dart';

// Generated mocks
import 'advanced_settings_view_model_test.mocks.dart';

@GenerateMocks([AdvancedSettingsRepository, AuthService])
void main() {
  late MockAdvancedSettingsRepository mockRepository;
  late MockAuthService mockAuthService;
  late AdvancedSettingsViewModel viewModel;

  setUp(() {
    mockRepository = MockAdvancedSettingsRepository();
    mockAuthService = MockAuthService();
    viewModel = AdvancedSettingsViewModel(mockRepository, mockAuthService);
  });

  group('AdvancedSettingsViewModel', () {
    const testUserId = 'test-user-id';
    final testUser = User(id: testUserId, email: 'test@example.com');
    final defaultSettings = const AdvancedSettingsState();
    
    test('initial state should have default values', () {
      // Estado inicial deve ter os valores padrão
      expect(viewModel.state.languageCode, equals('pt_BR'));
      expect(viewModel.state.themeMode, equals(ThemeMode.system));
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.isSyncing, isFalse);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('loads settings on initialization', () async {
      // Configurar os mocks
      when(mockAuthService.currentUser).thenReturn(testUser);
      when(mockRepository.loadSettings(testUserId))
          .thenAnswer((_) async => defaultSettings);
      
      // Inicializar o viewModel novamente para que ele carregue as configurações
      viewModel = AdvancedSettingsViewModel(mockRepository, mockAuthService);
      
      // Aguardar o carregamento
      await Future.delayed(Duration.zero);
      
      // Verificar se o método foi chamado
      verify(mockRepository.loadSettings(testUserId)).called(1);
    });

    test('updateLanguage changes language code', () async {
      // Configura os mocks
      when(mockAuthService.currentUser).thenReturn(testUser);
      when(mockRepository.updateLanguage(any, any)).thenAnswer((_) async {});
      
      // Atualiza o idioma
      await viewModel.updateLanguage('en_US');
      
      // Verifica se o estado foi atualizado
      expect(viewModel.state.languageCode, equals('en_US'));
      
      // Verifica se o método do repositório foi chamado
      verify(mockRepository.updateLanguage(testUserId, 'en_US')).called(1);
    });

    test('toggleThemeMode cycles through theme modes', () async {
      // Configura os mocks
      when(mockAuthService.currentUser).thenReturn(testUser);
      when(mockRepository.updateThemeMode(any, any)).thenAnswer((_) async {});
      
      // Estado inicial (system)
      expect(viewModel.state.themeMode, equals(ThemeMode.system));
      
      // Primeiro toggle (system -> light)
      await viewModel.toggleThemeMode();
      expect(viewModel.state.themeMode, equals(ThemeMode.light));
      
      // Segundo toggle (light -> dark)
      await viewModel.toggleThemeMode();
      expect(viewModel.state.themeMode, equals(ThemeMode.dark));
      
      // Terceiro toggle (dark -> system)
      await viewModel.toggleThemeMode();
      expect(viewModel.state.themeMode, equals(ThemeMode.system));
    });

    test('updatePrivacySettings updates privacy settings', () async {
      // Configura os mocks
      when(mockAuthService.currentUser).thenReturn(testUser);
      when(mockRepository.updatePrivacySettings(any, any)).thenAnswer((_) async {});
      
      // Configura novas configurações de privacidade
      final newPrivacySettings = const PrivacySettings(
        shareActivityWithFriends: false,
        allowFindingMe: false,
        publicProfile: false,
      );
      
      // Atualiza as configurações
      await viewModel.updatePrivacySettings(newPrivacySettings);
      
      // Verifica se o estado foi atualizado
      expect(viewModel.state.privacySettings, equals(newPrivacySettings));
      
      // Verifica se o método do repositório foi chamado
      verify(mockRepository.updatePrivacySettings(testUserId, newPrivacySettings)).called(1);
    });

    test('updateNotificationSettings updates notification settings', () async {
      // Configura os mocks
      when(mockAuthService.currentUser).thenReturn(testUser);
      when(mockRepository.updateNotificationSettings(any, any)).thenAnswer((_) async {});
      
      // Configura novas configurações de notificação
      final newNotificationSettings = const NotificationSettings(
        enableNotifications: false,
        workoutReminders: false,
        reminderTime: '08:00',
      );
      
      // Atualiza as configurações
      await viewModel.updateNotificationSettings(newNotificationSettings);
      
      // Verifica se o estado foi atualizado
      expect(viewModel.state.notificationSettings, equals(newNotificationSettings));
      
      // Verifica se o método do repositório foi chamado
      verify(mockRepository.updateNotificationSettings(testUserId, newNotificationSettings)).called(1);
    });

    test('syncSettings synchronizes settings between devices', () async {
      // Configura os mocks
      when(mockAuthService.currentUser).thenReturn(testUser);
      final syncTime = DateTime.now();
      when(mockRepository.syncSettings(testUserId)).thenAnswer((_) async => syncTime);
      when(mockRepository.loadSettings(testUserId)).thenAnswer((_) async => defaultSettings);
      
      // Sincroniza as configurações
      await viewModel.syncSettings();
      
      // Verifica se o estado foi atualizado
      expect(viewModel.state.isSyncing, isFalse);
      expect(viewModel.state.lastSyncedAt, equals(syncTime));
      
      // Verifica se os métodos do repositório foram chamados
      verify(mockRepository.syncSettings(testUserId)).called(1);
      verify(mockRepository.loadSettings(testUserId)).called(1);
    });

    test('handles error when user is not authenticated', () async {
      // Configura mock para usuário não autenticado
      when(mockAuthService.currentUser).thenReturn(null);
      
      // Tenta atualizar o idioma
      await viewModel.updateLanguage('en_US');
      
      // Verifica se o estado de erro foi atualizado
      expect(viewModel.state.errorMessage, equals('Usuário não autenticado'));
      expect(viewModel.state.isLoading, isFalse);
      
      // Verifica que nenhum método do repositório foi chamado
      verifyNever(mockRepository.updateLanguage(any, any));
    });

    test('handles repository errors during update', () async {
      // Configura os mocks
      when(mockAuthService.currentUser).thenReturn(testUser);
      when(mockRepository.updateLanguage(any, any)).thenThrow(
        StorageException(message: 'Erro de conexão com o banco de dados')
      );
      when(mockRepository.loadSettings(testUserId)).thenAnswer((_) async => defaultSettings);
      
      // Tenta atualizar o idioma
      await viewModel.updateLanguage('en_US');
      
      // Verifica se o estado de erro foi atualizado
      expect(viewModel.state.errorMessage, contains('Erro de conexão'));
      expect(viewModel.state.isLoading, isFalse);
      
      // Verifica que o método de fallback foi chamado para recuperar o estado anterior
      verify(mockRepository.loadSettings(testUserId)).called(1);
    });

    test('clearError clears error message', () {
      // Define um erro no estado
      viewModel = AdvancedSettingsViewModel(mockRepository, mockAuthService);
      viewModel.clearError();
      
      // Verifica se a mensagem de erro foi limpa
      expect(viewModel.state.errorMessage, isNull);
    });
  });
} 