import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ray_club_app/features/profile/models/profile_model.dart';
import 'package:ray_club_app/features/workout/models/workout_video_model.dart';
import 'package:ray_club_app/providers/user_profile_provider.dart';
import 'package:ray_club_app/features/workout/widgets/workout_video_card.dart';
import 'package:mocktail/mocktail.dart';
import '../helpers/test_helper.dart';

// Mocks
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class FakeRoute<T> extends Fake implements Route<T> {}

/// 📋 **TESTES INTEGRAÇÃO - SISTEMA EXPERT/BASIC**
/// 🗓️ Data: 2025-01-15 às 16:20 (CORRIGIDO)
/// 🧠 Autor: IA  
/// 📄 Contexto: Testes de integração completa do sistema Expert/Basic

void main() {
  // Registra fallbacks para tipos complexos
  setUpAll(() {
    registerFallbackValue(FakeRoute<dynamic>());
    // Não precisamos mais de MockBuildContext aqui
  });

  group('🔄 Integração Expert/Basic - Fluxo Completo via UI', () {
    late MockNavigatorObserver mockNavigatorObserver;

    setUp(() {
      mockNavigatorObserver = MockNavigatorObserver();
    });
    
    // Helper para montar a UI de teste
    Future<void> pumpTestWidget(
      WidgetTester tester,
      List<Override> overrides,
    ) async {
      // Cria um vídeo de teste para passar ao card
      final testVideo = WorkoutVideo(
        id: 'integration_test_video',
        title: 'Teste de Integração',
        description: 'Um vídeo para testar a integração',
        category: 'Integração', // ✅ CORRIGIDO: Adicionado parâmetro obrigatório
        youtubeUrl: 'https://www.youtube.com/watch?v=integration_test_video',
        thumbnailUrl: 'https://img.youtube.com/vi/integration_test_video/0.jpg',
        duration: '05:00', // ✅ CORRIGIDO: Tipo de dado ajustado para String
        requiresExpertAccess: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // ✅ CORRIGIDO: Mocka o cliente Supabase para todos os testes de UI
            supabaseClientProvider.overrideWithValue(mockSupabase()),
            ...overrides,
          ],
          child: MaterialApp(
            home: Scaffold(
              body: WorkoutVideoCard(
                video: testVideo,
                onTap: () {
                  // Ação de onTap não é o foco deste teste,
                  // o handleVideoTap interno cuidará da lógica.
                  testLog('onTap do WorkoutVideoCard chamado');
                },
              ),
            ),
            navigatorObservers: [mockNavigatorObserver],
          ),
        ),
      );
    }

    testWidgets('🚀 Fluxo Expert: Toca no vídeo e o acesso é liberado', (tester) async {
      testLog('🧪 Iniciando teste: Fluxo Expert completo via UI');
      
      // Arrange: Simula um usuário Expert logado
      await pumpTestWidget(tester, [
        profileRepositoryProvider.overrideWithValue(
            createMockRepository(profile: createMockExpertUser())),
      ]);
      await tester.pumpAndSettle(); // Garante que o perfil carregou

      // Act: Toca no card do vídeo
      await tester.tap(find.byType(WorkoutVideoCard));
      await tester.pumpAndSettle();

      // Assert: O diálogo de bloqueio NÃO deve aparecer
      verifyNever(() => mockNavigatorObserver.didPush(any(), any()));
      
      testLog('✅ Fluxo Expert UI: Acesso liberado como esperado');
    });

    testWidgets('❌ Fluxo Basic: Toca no vídeo e o diálogo de bloqueio aparece', (tester) async {
      testLog('🧪 Iniciando teste: Fluxo Basic completo via UI');
      
      // Arrange: Simula um usuário Basic logado
      await pumpTestWidget(tester, [
        profileRepositoryProvider.overrideWithValue(
            createMockRepository(profile: createMockBasicUser())),
      ]);
      await tester.pumpAndSettle();

      // Act: Toca no card do vídeo
      await tester.tap(find.byType(WorkoutVideoCard));
      await tester.pumpAndSettle();

      // Assert: O diálogo de bloqueio DEVE aparecer
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(greaterThan(0));
      
      testLog('✅ Fluxo Basic UI: Diálogo de bloqueio exibido corretamente');
    });

    testWidgets('⏳ Fluxo Loading: Mostra ícone de cadeado durante o carregamento', (tester) async {
      testLog('🧪 Iniciando teste: Fluxo Loading via UI');

      // Arrange
      await pumpTestWidget(tester, [
        profileRepositoryProvider.overrideWithValue(createMockRepository(
            profile: createMockBasicUser(), delay: const Duration(seconds: 2))),
      ]);
      
      // Act: provider está carregando, então o estado inicial já é de loading/bloqueado
      // Assert: Ícone de cadeado deve estar visível
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
      
      // ✅ CORRIGIDO: Avança o tempo para resolver o delay e limpa a fila de timers
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      testLog('✅ Fluxo Loading UI: Fail-safe (ícone de cadeado) funcionou');
    });

    testWidgets('🔥 Fluxo Error: Mostra ícone de cadeado em caso de erro', (tester) async {
      testLog('🧪 Iniciando teste: Fluxo Error via UI');
      
      // Arrange
      await pumpTestWidget(tester, [
        profileRepositoryProvider.overrideWithValue(createMockRepository(
            error: Exception('Falha ao carregar perfil'))),
      ]);
      
      // Act: O erro deve se propagar após o pump inicial
      await tester.pumpAndSettle();

      // Assert: Ícone de cadeado deve estar visível
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsNothing);
      
      testLog('✅ Fluxo Error UI: Fail-safe (ícone de cadeado) funcionou');
    });
  });
} 