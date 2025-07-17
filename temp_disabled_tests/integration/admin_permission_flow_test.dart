// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/benefits/repositories/benefit_repository.dart';
import 'package:ray_club_app/features/benefits/screens/benefit_admin_screen.dart';
import 'package:ray_club_app/features/benefits/screens/benefits_screen.dart';
import 'package:ray_club_app/features/benefits/viewmodels/benefit_view_model.dart';
import 'admin_permission_flow_test.mocks.dart';

@GenerateMocks([BenefitRepository, supabase.SupabaseClient, supabase.GoTrueClient])

/// Este teste de integração verifica o fluxo completo de permissões de administrador
/// e o comportamento do sistema quando um usuário não administrativo tenta acessar
/// funcionalidades restritas.
void main() {
  late MockBenefitRepository mockRepository;
  late ProviderContainer container;
  
  setUp(() {
    mockRepository = MockBenefitRepository();
    
    container = ProviderContainer(
      overrides: [
        benefitRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });
  
  tearDown(() {
    container.dispose();
  });
  
  // group('Fluxo de permissão de administradores', () {
    // testWidgets('Usuário admin deve ver botão de admin na tela de benefícios',
        (WidgetTester tester) async {
      // Configurar o mock repository para responder como admin
      when(mockRepository.isAdmin()).thenAnswer((_) async => true);
      when(mockRepository.getBenefits()).thenAnswer((_) async => []);
      when(mockRepository.getBenefitCategories()).thenAnswer((_) async => []);
      
      // Construir a interface
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            benefitRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: BenefitsScreen(),
          ),
        ),
      );
      
      // Aguardar carregamento
      await tester.pumpAndSettle();
      
      // Verificar se o botão de admin está visível
      expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
    });
    
    // testWidgets('Usuário não-admin não deve ver botão de admin',
        (WidgetTester tester) async {
      // Configurar mock para responder como não-admin
      when(mockRepository.isAdmin()).thenAnswer((_) async => false);
      when(mockRepository.getBenefits()).thenAnswer((_) async => []);
      when(mockRepository.getBenefitCategories()).thenAnswer((_) async => []);
      
      // Construir a interface
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            benefitRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: BenefitsScreen(),
          ),
        ),
      );
      
      // Aguardar carregamento
      await tester.pumpAndSettle();
      
      // Verificar que o botão de admin NÃO está visível
      expect(find.byIcon(Icons.admin_panel_settings), findsNothing);
    });
    
    // testWidgets('Usuário não-admin deve ser bloqueado ao tentar acessar tela de admin diretamente',
        (WidgetTester tester) async {
      // Configurar mock para responder como não-admin
      when(mockRepository.isAdmin()).thenAnswer((_) async => false);
      when(mockRepository.getBenefits()).thenAnswer((_) async => []);
      
      // Mostrar SnackBar com mensagem de erro
      String? capturedMessage;
      
      // Construir o app com uma key para o Scaffold Messenger
      final scaffoldKey = GlobalKey<ScaffoldMessengerState>();
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            benefitRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            scaffoldMessengerKey: scaffoldKey,
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    try {
                      // Tentar navegar para a tela de admin
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BenefitAdminScreen(),
                        ),
                      );
                    } catch (e) {
                      // Capturar a mensagem de erro
                      capturedMessage = e is AppException ? e.message : e.toString();
                      
                      // Mostrar mensagem
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(capturedMessage ?? 'Erro')),
                      );
                    }
                  },
                  child: const Text('Tentar acessar admin'),
                );
              },
            ),
          ),
        ),
      );
      
      // Tocar no botão
      await tester.tap(find.text('Tentar acessar admin'));
      await tester.pumpAndSettle();
      
      // Verificar se o usuário foi bloqueado
      expect(find.text('Admin - Ray Club'), findsNothing);
      
      // Verificar se a mensagem de erro contém informação sobre permissão negada
      expect(find.textContaining('Permissão negada'), findsOneWidget);
    });
    
    // testWidgets('Usuário não-admin deve ser bloqueado ao tentar modificar datas de expiração via repositório',
        (WidgetTester tester) async {
      // Configurar mock para responder como não-admin
      when(mockRepository.isAdmin()).thenAnswer((_) async => false);
      
      // Configurar mock para lançar exceção em operações de admin
      when(mockRepository.updateBenefitExpiration(any, any)).thenAnswer(
        (_) async => throw AppException(
          message: 'Permissão negada. Apenas administradores podem atualizar datas de expiração.',
          code: 'permission_denied',
        ),
      );
      
      // Construir widget de teste
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            benefitRepositoryProvider.overrideWithValue(mockRepository),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    try {
                      // Tentar executar operação de admin
                      final viewModel = container.read(benefitViewModelProvider.notifier);
                      await viewModel.updateBenefitExpiration(
                        'benefit-1',
                        DateTime.now().add(const Duration(days: 30)),
                      );
                    } catch (e) {
                      // Mostrar mensagem
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e is AppException ? e.message : e.toString()),
                        ),
                      );
                    }
                  },
                  child: const Text('Tentar editar data'),
                );
              },
            ),
          ),
        ),
      );
      
      // Tocar no botão
      await tester.tap(find.text('Tentar editar data'));
      await tester.pumpAndSettle();
      
      // Verificar se a mensagem de erro foi exibida
      expect(find.textContaining('Permissão negada'), findsOneWidget);
      
      // Verificar que a função do mock foi chamada
      verify(mockRepository.updateBenefitExpiration(any, any)).called(1);
    });
  });
} 
