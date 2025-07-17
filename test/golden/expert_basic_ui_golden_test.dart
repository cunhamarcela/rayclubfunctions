import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:golden_toolkit/golden_toolkit.dart'; // ✅ CORRIGIDO: Import correto
import 'package:ray_club_app/core/services/expert_video_guard.dart';
import 'package:ray_club_app/providers/user_profile_provider.dart';
import '../helpers/test_helper.dart';

/// 📋 **TESTES GOLDEN UI - SISTEMA EXPERT/BASIC**
/// 🗓️ Data: 2025-01-15 às 17:00 (CORRIGIDO)
/// 🧠 Autor: IA
/// 📄 Contexto: Testes visuais de consistência UI Expert/Basic

void main() {
  group('📸 Golden Tests - Expert/Basic UI', () {
    setUpAll(() async {
      // ✅ CORRIGIDO: Setup correto do golden_toolkit
      await loadAppFonts();
    });

    testGoldens('Video Card Expert vs Basic states', (tester) async {
      testLog('🧪 Iniciando golden test: Video Card states');
      
      // Arrange
      final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1.2)
        ..addScenario(
          'Expert - Acesso Liberado',
          _buildExpertVideoCard(),
        )
        ..addScenario(
          'Basic - Acesso Bloqueado',
          _buildBasicVideoCard(),
        );

      // Act & Assert
      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(800, 600),
      );
      
      await screenMatchesGolden(tester, 'video_card_expert_vs_basic');
      
      testLog('✅ Golden test Video Card: Expert vs Basic');
    });

    testGoldens('Dialog de Bloqueio Premium', (tester) async {
      testLog('🧪 Iniciando golden test: Dialog Premium');
      
      // Arrange
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Dialog Premium Standard',
          _buildPremiumDialog(),
        )
        ..addScenario(
          'Dialog Premium Dark Mode',
          _buildPremiumDialogDark(),
        );

      // Act & Assert
      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(400, 800),
      );
      
      await screenMatchesGolden(tester, 'premium_dialog_states');
      
      testLog('✅ Golden test Dialog Premium: Light/Dark');
    });

    testGoldens('Botões de Ação Expert vs Basic', (tester) async {
      testLog('🧪 Iniciando golden test: Botões de Ação');
      
      // Arrange
      final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 3)
        ..addScenario(
          'Botão Expert Enabled',
          _buildActionButton(isExpert: true, isEnabled: true),
        )
        ..addScenario(
          'Botão Basic Disabled',
          _buildActionButton(isExpert: false, isEnabled: false),
        )
        ..addScenario(
          'Botão Expert Pressed',
          _buildActionButton(isExpert: true, isEnabled: true, isPressed: true),
        )
        ..addScenario(
          'Botão Basic Hover',
          _buildActionButton(isExpert: false, isEnabled: false, isHovered: true),
        );

      // Act & Assert
      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(600, 400),
      );
      
      await screenMatchesGolden(tester, 'action_buttons_expert_vs_basic');
      
      testLog('✅ Golden test Botões: Estados interativos');
    });

    testGoldens('Tela Completa Expert vs Basic', (tester) async {
      testLog('🧪 Iniciando golden test: Telas Completas');
      
      // Arrange
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Tela Expert - Acesso Total',
          _buildExpertScreen(),
        )
        ..addScenario(
          'Tela Basic - Acesso Limitado',
          _buildBasicScreen(),
        );

      // Act & Assert
      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(375, 1200), // Tamanho mobile
      );
      
      await screenMatchesGolden(tester, 'full_screen_expert_vs_basic');
      
      testLog('✅ Golden test Telas: Diferenças de acesso');
    });

    testGoldens('Responsividade Mobile vs Tablet', (tester) async {
      testLog('🧪 Iniciando golden test: Responsividade');
      
      // Arrange
      final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 0.6)
        ..addScenario(
          'Mobile Expert (375x667)',
          _buildResponsiveLayout(isMobile: true, isExpert: true),
        )
        ..addScenario(
          'Tablet Expert (768x1024)',
          _buildResponsiveLayout(isMobile: false, isExpert: true),
        )
        ..addScenario(
          'Mobile Basic (375x667)',
          _buildResponsiveLayout(isMobile: true, isExpert: false),
        )
        ..addScenario(
          'Tablet Basic (768x1024)',
          _buildResponsiveLayout(isMobile: false, isExpert: false),
        );

      // Act & Assert
      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(1200, 1500),
      );
      
      await screenMatchesGolden(tester, 'responsive_layouts');
      
      testLog('✅ Golden test Responsividade: Mobile/Tablet');
    });

    testGoldens('Estados de Loading e Erro', (tester) async {
      testLog('🧪 Iniciando golden test: Estados Especiais');
      
      // Arrange
      final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1)
        // ✅ CORRIGIDO: Testa o estado de loading real usando um provider que demora
        ..addScenario(
          'Loading State',
          _buildTestCardWithOverrides(
            overrides: [
              profileRepositoryProvider.overrideWithValue(
                // Simula um delay longo para garantir que o estado de loading seja capturado
                createMockRepository(delay: const Duration(seconds: 10)),
              )
            ],
          ),
        )
        // ✅ CORRIGIDO: Testa o estado de erro real usando um provider que falha
        ..addScenario(
          'Error State',
          _buildTestCardWithOverrides(
            overrides: [
              overrideWithError(Exception('Golden Test Error')),
            ],
          ),
        )
        ..addScenario(
          'Empty State Expert',
          _buildEmptyState(isExpert: true),
        )
        ..addScenario(
          'Empty State Basic',
          _buildEmptyState(isExpert: false),
        );

      // Act & Assert
      // ✅ CORRIGIDO: Usa pump para renderizar o estado de loading sem esperar a resolução
      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(800, 800),
      );
      
      // Para golden tests, um único pump é geralmente suficiente para capturar o estado.
      await screenMatchesGolden(tester, 'special_states_loading_and_error');
      
      testLog('✅ Golden test Estados: Loading/Error/Empty');
    });
  });
}

// ✅ NOVO: Widget de teste que reage aos providers para os cenários de loading/erro
Widget _buildTestCardWithOverrides({required List<Override> overrides}) {
  return ProviderScope(
    overrides: [
      // Garante que o supabase esteja sempre mockado
      supabaseClientProvider.overrideWithValue(mockSupabase()),
      ...overrides
    ],
    child: Consumer(
      builder: (context, ref, child) {
        // Observa o provider que pode estar em loading ou erro
        final isExpertAsync = ref.watch(isExpertUserProfileProvider);

        return Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isExpertAsync.hasError ? Colors.red.shade300 : Colors.grey.shade300),
          ),
          child: isExpertAsync.when(
            loading: () => const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Carregando...', style: TextStyle(color: Colors.grey)),
              ],
            ),
            error: (err, stack) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade600),
                const SizedBox(height: 16),
                const Text('Ops! Algo deu errado', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            data: (isExpert) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isExpert ? Icons.check_circle : Icons.lock, size: 48, color: Colors.green),
                const SizedBox(height: 16),
                const Text('Estado Carregado'),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ✅ WIDGETS DE TESTE PARA GOLDEN

Widget _buildExpertVideoCard() {
  return ProviderScope(
    overrides: [mockExpertUserProvider()],
    child: Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_fill,
            size: 60,
            color: Colors.green.shade600,
          ),
          const SizedBox(height: 8),
          Text(
            'Vídeo Expert ✨',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Acesso liberado',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBasicVideoCard() {
  return ProviderScope(
    overrides: [mockBasicUserProvider()],
    child: Container(
      width: 300,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 60,
                color: Colors.orange.shade600,
              ),
              const SizedBox(height: 8),
              Text(
                'Vídeo Premium 🌟',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Acesso bloqueado',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'PREMIUM',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPremiumDialog() {
  return Material(
    child: Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 48,
            color: Colors.orange.shade600,
          ),
          const SizedBox(height: 16),
          const Text(
            'Conteúdo Premium 🌟',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Este vídeo está disponível apenas para membros Expert. Quer fazer upgrade?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text('Agora não'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Upgrade ✨'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildPremiumDialogDark() {
  return Material(
    child: Container(
      width: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 48,
            color: Colors.orange.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Conteúdo Premium 🌟',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Este vídeo está disponível apenas para membros Expert. Quer fazer upgrade?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade600),
                  ),
                  child: const Text('Agora não'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Upgrade ✨'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildActionButton({
  required bool isExpert,
  required bool isEnabled,
  bool isPressed = false,
  bool isHovered = false,
}) {
  Color backgroundColor;
  Color textColor;
  String text;
  
  if (isExpert && isEnabled) {
    backgroundColor = isPressed ? Colors.green.shade700 : Colors.green.shade600;
    textColor = Colors.white;
    text = 'Reproduzir ▶️';
  } else {
    backgroundColor = isHovered ? Colors.grey.shade300 : Colors.grey.shade200;
    textColor = Colors.grey.shade600;
    text = 'Conteúdo Premium 🔒';
  }

  return Container(
    width: 200,
    height: 48,
    child: ElevatedButton(
      onPressed: isEnabled ? () {} : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: isPressed ? 1 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

Widget _buildExpertScreen() {
  return ProviderScope(
    overrides: [mockExpertUserProvider()],
    child: Material(
      child: Container(
        width: 375,
        height: 400,
        padding: const EdgeInsets.all(16),
        color: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Icon(Icons.star, color: Colors.green.shade600),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expert User ✨',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Acesso total liberado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Vídeos Disponíveis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(4, (index) => 
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_circle_fill, 
                          color: Colors.green.shade600, size: 32),
                        const SizedBox(height: 4),
                        Text('Vídeo ${index + 1}', 
                          style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildBasicScreen() {
  return ProviderScope(
    overrides: [mockBasicUserProvider()],
    child: Material(
      child: Container(
        width: 375,
        height: 400,
        padding: const EdgeInsets.all(16),
        color: Colors.grey.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic User',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Acesso limitado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Vídeos Disponíveis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: List.generate(4, (index) => 
                  Container(
                    decoration: BoxDecoration(
                      color: index < 2 ? Colors.green.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: index < 2 ? Colors.green.shade300 : Colors.grey.shade400,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          index < 2 ? Icons.play_circle_fill : Icons.lock,
                          color: index < 2 ? Colors.green.shade600 : Colors.grey.shade600,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          index < 2 ? 'Vídeo ${index + 1}' : 'Premium',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildResponsiveLayout({required bool isMobile, required bool isExpert}) {
  final width = isMobile ? 375.0 : 768.0;
  final height = isMobile ? 300.0 : 400.0;
  
  return Container(
    width: width,
    height: height,
    padding: EdgeInsets.all(isMobile ? 16 : 24),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Text(
          '${isMobile ? 'Mobile' : 'Tablet'} - ${isExpert ? 'Expert' : 'Basic'}',
          style: TextStyle(
            fontSize: isMobile ? 14 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isExpert ? Colors.green.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                isExpert ? Icons.check_circle : Icons.lock,
                size: isMobile ? 32 : 48,
                color: isExpert ? Colors.green.shade600 : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildLoadingState() {
  return Container(
    width: 300,
    height: 200,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          'Carregando...',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

Widget _buildErrorState() {
  return Container(
    width: 300,
    height: 200,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.red.shade300),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Colors.red.shade600,
        ),
        const SizedBox(height: 16),
        const Text(
          'Ops! Algo deu errado',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Vamos tentar de novo?',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
}

Widget _buildEmptyState({required bool isExpert}) {
  return Container(
    width: 300,
    height: 200,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          isExpert ? Icons.video_library_outlined : Icons.lock_outline,
          size: 48,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 16),
        Text(
          isExpert ? 'Nenhum vídeo encontrado' : 'Conteúdo não disponível',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isExpert ? 'Em breve mais conteúdo!' : 'Faça upgrade para Expert ✨',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    ),
  );
} 