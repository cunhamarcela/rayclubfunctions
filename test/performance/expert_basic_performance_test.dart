import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ray_club_app/core/services/expert_video_guard.dart';
import 'package:ray_club_app/features/profile/models/profile_model.dart';
import 'package:ray_club_app/providers/user_profile_provider.dart';

import '../helpers/test_helper.dart';

void main() {
  // This helper creates a container with all necessary mocks for performance tests.
  ProviderContainer createPerformanceTestContainer(
      {Profile? profile, Exception? error, Duration? delay}) {
    final container = ProviderContainer(
      overrides: [
        // Ensure supabase is always mocked
        supabaseClientProvider.overrideWithValue(mockSupabase()),
        // Override the repository with the desired mock behavior
        profileRepositoryProvider.overrideWithValue(
          createMockRepository(profile: profile, error: error, delay: delay),
        ),
      ],
    );
    // Ensure the container is disposed after the test.
    addTearDown(container.dispose);
    return container;
  }

  group('⚡ Performance Expert/Basic - Benchmarks', () {
    test('userProfileProvider deve carregar em < 100ms', () async {
      testLog('🧪 Iniciando teste: Performance userProfileProvider');
      // Arrange
      final container = createPerformanceTestContainer(
        profile: createMockExpertUser(),
        delay: const Duration(milliseconds: 20),
      );

      // Act
      final stopwatch = Stopwatch()..start();
      await container.read(userProfileProvider.future);
      stopwatch.stop();

      // Assert
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 100)));
      testLog('✅ Benchmark userProfileProvider: ${stopwatch.elapsed.inMilliseconds}ms');
    });

    test('isExpertUserProfileProvider deve resolver em < 50ms', () async {
      testLog('🧪 Iniciando teste: Performance isExpertUserProfileProvider');
      // Arrange
      final container =
          createPerformanceTestContainer(profile: createMockExpertUser());
      await container
          .read(userProfileProvider.future); // Ensure profile is loaded first

      // Act
      final stopwatch = Stopwatch()..start();
      final isExpert = container.read(isExpertUserProfileProvider).value;
      stopwatch.stop();

      // Assert
      expect(isExpert, isTrue);
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 50)));
      testLog(
          '✅ Benchmark isExpertUserProfileProvider: ${stopwatch.elapsed.inMilliseconds}ms');
    });

    test('ExpertVideoGuard.canPlayVideo deve ser < 25ms', () async {
      testLog('🧪 Iniciando teste: Performance canPlayVideo');
      // Arrange
      final container =
          createPerformanceTestContainer(profile: createMockExpertUser());
      await container.read(userProfileProvider.future);

      // ✅ CORRIGIDO: Usa o MockWidgetRef padronizado do test_helper
      final mockRef = MockWidgetRef(); 
      when(() => mockRef.read(isExpertUserProfileProvider))
          .thenAnswer((_) => container.read(isExpertUserProfileProvider));
      when(() => mockRef.read(userProfileProvider))
          .thenAnswer((_) => container.read(userProfileProvider));

      // Act
      final stopwatch = Stopwatch()..start();
      final canPlay =
          await ExpertVideoGuard.canPlayVideo(mockRef, 'performance_test_video');
      stopwatch.stop();

      // Assert
      expect(canPlay, isTrue);
      expect(stopwatch.elapsed, lessThan(const Duration(milliseconds: 25)));
      testLog(
          '✅ Benchmark canPlayVideo: ${stopwatch.elapsed.inMilliseconds}ms');
    });
  });

  group('🔥 Testes de Carga e Estresse', () {
    test('100 verificações consecutivas < 1ms média', () async {
      testLog('🧪 Iniciando teste: 100 verificações consecutivas');
      // Arrange
      final container =
          createPerformanceTestContainer(profile: createMockExpertUser());
      await container.read(userProfileProvider.future);

      final mockRef = MockWidgetRef();
      when(() => mockRef.read(isExpertUserProfileProvider))
          .thenAnswer((_) => container.read(isExpertUserProfileProvider));

      // Act
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        await ExpertVideoGuard.canPlayVideo(mockRef, 'load_test_video_$i');
      }
      stopwatch.stop();

      // Assert
      final avgTime = stopwatch.elapsed.inMicroseconds / 100;
      expect(avgTime, lessThan(1000)); // Média < 1ms (1000µs)
      testLog(
          '✅ Carga 100x: ${stopwatch.elapsed.inMilliseconds}ms total (média: ${avgTime.toStringAsFixed(1)}µs)');
    });

    test('Alternância rápida de estado 100x < 10s', () async {
      testLog('🧪 Iniciando teste: Alternância rápida 100x');
      // Arrange
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 100; i++) {
        final profile = i.isEven ? createMockExpertUser() : createMockBasicUser();
        final container = createPerformanceTestContainer(profile: profile);

        // Act
        final userProfile = await container.read(userProfileProvider.future);
        // ✅ CORRIGIDO: Verifica o tipo de conta e lida com a nulidade
        final isExpert = userProfile?.accountType == 'expert';

        // Assert
        expect(isExpert, i.isEven);
        container.dispose(); // Dispose to simulate state change from scratch
      }
      stopwatch.stop();
      expect(stopwatch.elapsed, lessThan(const Duration(seconds: 10)));
      testLog(
          '✅ Alternância 100x: ${stopwatch.elapsed.inMilliseconds}ms total');
    });
  });
} 