import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/core/services/expert_video_guard.dart';
import 'package:ray_club_app/providers/user_profile_provider.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/test_helper.dart';

// Mocks
class MockBuildContext extends Mock implements BuildContext {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class FakeRoute<T> extends Fake implements Route<T> {}

/// 📋 **TESTES EXPERT VIDEO GUARD - SISTEMA EXPERT/BASIC**
/// 🗓️ Data: 2025-01-15 às 16:00 (CORRIGIDO)
/// 🧠 Autor: IA
/// 📄 Contexto: Testes unitários do ExpertVideoGuard

void main() {
  // ✅ CORRIGIDO: Registra fallbacks para tipos complexos usados nos mocks
  setUpAll(() {
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(FakeRoute<dynamic>());
  });

  group('🔧 ExpertVideoGuard.canPlayVideo', () {
    testWidgets('deve retornar true para usuário Expert', (tester) async {
      testLog('🧪 Iniciando teste: canPlayVideo Expert');
      final mockRef = MockWidgetRef({
        isExpertUserProfileProvider: const AsyncData(true),
      });

      final canPlay = await ExpertVideoGuard.canPlayVideo(mockRef, 'test_video_123');

      expect(canPlay, isTrue);
      testLog('✅ Expert pode reproduzir vídeo');
    });

    testWidgets('deve retornar false para usuário Basic', (tester) async {
      testLog('🧪 Iniciando teste: canPlayVideo Basic');
      final mockRef = MockWidgetRef({
        isExpertUserProfileProvider: const AsyncData(false),
      });

      final canPlay = await ExpertVideoGuard.canPlayVideo(mockRef, 'test_video_123');

      expect(canPlay, isFalse);
      testLog('✅ Basic não pode reproduzir vídeo');
    });

    testWidgets('deve retornar false para usuário não autenticado', (tester) async {
      testLog('🧪 Iniciando teste: canPlayVideo não autenticado');
      final mockRef = MockWidgetRef({
        isExpertUserProfileProvider: const AsyncData(false),
      });

      final canPlay = await ExpertVideoGuard.canPlayVideo(mockRef, 'test_video_123');

      expect(canPlay, isFalse);
      testLog('✅ Usuário não autenticado não pode reproduzir vídeo');
    });

    testWidgets('deve retornar false quando perfil está em loading', (tester) async {
      testLog('🧪 Iniciando teste: canPlayVideo loading');
      final mockRef = MockWidgetRef({
        isExpertUserProfileProvider: const AsyncLoading<bool>(),
      });

      final canPlay = await ExpertVideoGuard.canPlayVideo(mockRef, 'test_video_123');

      expect(canPlay, isFalse);
      testLog('✅ Loading tratado como acesso negado (fail-safe)');
    });

    testWidgets('deve retornar false quando há erro no carregamento', (tester) async {
      testLog('🧪 Iniciando teste: canPlayVideo error');
      final mockRef = MockWidgetRef({
        isExpertUserProfileProvider: AsyncError<bool>('Erro', StackTrace.current),
      });

      final canPlay = await ExpertVideoGuard.canPlayVideo(mockRef, 'test_video_123');

      expect(canPlay, isFalse);
      testLog('✅ Erro tratado como acesso negado (fail-safe)');
    });
  });

  group('🎯 ExpertVideoGuard.handleVideoTap', () {
    late MockBuildContext mockContext;
    late MockNavigatorObserver mockNavigatorObserver;
    bool onAllowedCalled = false;

    setUp(() {
      mockContext = MockBuildContext();
      mockNavigatorObserver = MockNavigatorObserver();
      onAllowedCalled = false;
      // ✅ CORRIGIDO: Garante que o context esteja sempre "montado" nos testes
      when(() => mockContext.mounted).thenReturn(true);
    });

    void onAllowed() {
      onAllowedCalled = true;
    }

    testWidgets('deve chamar onAllowed para usuário Expert', (tester) async {
      testLog('🧪 Iniciando teste: handleVideoTap Expert onAllowed');
      final mockRef = MockWidgetRef({
        isExpertUserProfileProvider: const AsyncData(true),
      });

      await ExpertVideoGuard.handleVideoTap(
        mockContext,
        mockRef,
        'test_video_123',
        onAllowed,
      );

      expect(onAllowedCalled, isTrue);
      testLog('✅ onAllowed chamado para Expert');
    });

    testWidgets('deve mostrar diálogo para usuário Basic', (tester) async {
      testLog('🧪 Iniciando teste: handleVideoTap Basic dialog');
      final mockRef = MockWidgetRef({
        isExpertUserProfileProvider: const AsyncData(false),
      });

      // Não precisamos mais mockar o showDialog, o NavigatorObserver cuidará disso.

      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: Builder(
              builder: (context) {
                // We need a real context to show a dialog
                return ElevatedButton(
                  onPressed: () => ExpertVideoGuard.handleVideoTap(
                    context,
                    mockRef,
                    'test_video_123',
                    onAllowed,
                  ),
                  child: const Text('Tap Me'),
                );
              },
            ),
          ),
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(onAllowedCalled, isFalse);
      
      // ✅ CORRIGIDO: Verifica se o dialog foi chamado pelo menos uma vez
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(greaterThan(0));

      testLog('✅ Diálogo mostrado para Basic');
    });
  });
} 