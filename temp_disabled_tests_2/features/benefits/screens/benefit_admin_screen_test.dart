// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:ray_club_app/features/benefits/models/benefit.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';
import 'package:ray_club_app/features/benefits/repositories/benefit_repository.dart';
import 'package:ray_club_app/features/benefits/screens/benefit_admin_screen.dart';
import 'package:ray_club_app/features/benefits/viewmodels/benefit_state.dart';
import 'package:ray_club_app/features/benefits/viewmodels/benefit_view_model.dart';
import 'package:ray_club_app/features/benefits/widgets/custom_date_picker.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';
import 'package:ray_club_app/services/qr_service.dart';
import 'benefit_admin_screen_test.mocks.dart';

@GenerateMocks([BenefitRepository, QRService])

class MockBenefitViewModel extends StateNotifier<BenefitState> implements BenefitViewModel {
  final MockBenefitRepository repository;
  
  MockBenefitViewModel(this.repository) : super(const BenefitState());
  
  @override
  Future<bool> isAdmin() async {
    return true; // Fingir que é admin para o teste
  }
  
  @override
  Future<void> loadAllRedeemedBenefits() async {
    state = state.copyWith(
      redeemedBenefits: [
        RedeemedBenefit(
          id: 'redeemed-1',
          benefitId: 'benefit-1',
          userId: 'user-1',
          title: 'Test Benefit',
          description: 'Test description',
          code: 'CODE123',
          status: BenefitStatus.active,
          expirationDate: DateTime.now().add(const Duration(days: 30)),
          redeemedAt: DateTime.now().subtract(const Duration(days: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        RedeemedBenefit(
          id: 'redeemed-2',
          benefitId: 'benefit-2',
          userId: 'user-2',
          title: 'Expired Benefit',
          description: 'Expired description',
          code: 'CODE456',
          status: BenefitStatus.expired,
          expirationDate: DateTime.now().subtract(const Duration(days: 1)),
          redeemedAt: DateTime.now().subtract(const Duration(days: 10)),
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
    );
  }
  
  @override
  Future<bool> updateBenefitExpiration(String benefitId, DateTime? newExpirationDate) async {
    return true;
  }
  
  @override
  Future<bool> extendRedeemedBenefitExpiration(String redeemedBenefitId, DateTime? newExpirationDate) async {
    // Simula atualização bem-sucedida
    final updatedBenefit = state.redeemedBenefits
        .firstWhere((b) => b.id == redeemedBenefitId)
        .copyWith(expirationDate: newExpirationDate);
    
    final updatedList = [...state.redeemedBenefits];
    final index = updatedList.indexWhere((b) => b.id == redeemedBenefitId);
    updatedList[index] = updatedBenefit;
    
    state = state.copyWith(
      redeemedBenefits: updatedList,
      selectedRedeemedBenefit: updatedBenefit,
    );
    
    return true;
  }
  
  @override
  Future<void> loadBenefits() async {
    state = state.copyWith(
      benefits: [
        Benefit(
          id: 'benefit-1',
          title: 'Test Benefit',
          description: 'Test Description',
          partner: 'Test Partner',
          pointsRequired: 100,
          availableQuantity: 10,
          expirationDate: DateTime.now().add(const Duration(days: 30)),
        ),
        Benefit(
          id: 'benefit-2',
          title: 'Another Benefit',
          description: 'Another Description',
          partner: 'Another Partner',
          pointsRequired: 200,
          availableQuantity: 5,
          expirationDate: DateTime.now().add(const Duration(days: 60)),
        ),
      ],
    );
  }
  
  @override
  Future<void> selectBenefit(String benefitId) async {
    final benefit = state.benefits.firstWhere((b) => b.id == benefitId);
    state = state.copyWith(selectedBenefit: benefit);
  }
  
  @override
  Future<void> selectRedeemedBenefit(String redeemedBenefitId) async {
    final benefit = state.redeemedBenefits.firstWhere((b) => b.id == redeemedBenefitId);
    state = state.copyWith(selectedRedeemedBenefit: benefit);
  }
  
  // Implementações necessárias (que não são usadas diretamente nestes testes)
  @override
  Future<void> addUserPoints(int points) async {}
  
  @override
  Future<bool> cancelRedeemedBenefit(String redeemedBenefitId) async => true;
  
  @override
  Future<void> checkExpiredBenefits(List<RedeemedBenefit> benefits) async {}
  
  @override
  void clearError() {}

  @override
  void clearQRCodeData() {}

  @override
  void clearSuccessMessage() {}
  
  @override
  void clearSelectedBenefit() {}
  
  @override
  void clearSelectedRedeemedBenefit() {}

  @override
  Future<bool> createBenefit(Benefit benefit) async => true;

  @override
  Future<String?> generateQRCode(String redeemedBenefitId) async => "qr-data";
  
  @override
  Future<void> filterByCategory(String? category) async {}
  
  @override
  Future<List<String>> getBenefitCategories() async => [];
  
  @override
  Future<void> loadFeaturedBenefits() async {}
  
  @override
  Future<void> loadRedeemedBenefits() async {}
  
  @override
  Future<bool> markBenefitAsUsed(String redeemedBenefitId) async => true;
  
  @override
  Future<RedeemedBenefit?> redeemBenefit(String benefitId) async => null;

  @override
  Future<bool> updateBenefit(Benefit benefit) async => true;

  @override
  Future<bool> verifyQRCode(String code) async => true;
}

void main() {
  late MockBenefitRepository mockRepository;
  late MockBenefitViewModel mockViewModel;
  late ProviderContainer container;
  
  setUp(() {
    mockRepository = MockBenefitRepository();
    mockViewModel = MockBenefitViewModel(mockRepository);
    
    // Configurar o container com providers de teste
    container = ProviderContainer(
      overrides: [
        benefitViewModelProvider.overrideWith((_) => mockViewModel),
      ],
    );
  });
  
  tearDown(() {
    container.dispose();
  });
  
  testWidgets('BenefitAdminScreen carrega com abas', (WidgetTester tester) async {
    // Preparar: Simular verificação de admin
    when(mockRepository.isAdmin()).thenAnswer((_) async => true);
    
    // Renderizar o widget com um ProviderScope para usar o container de teste
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          benefitViewModelProvider.overrideWith((_) => mockViewModel),
        ],
        child: MaterialApp(
          home: const BenefitAdminScreen(benefitTitle: 'Test Benefit'),
        ),
      ),
    );
    
    // Aguardar carregamento
    await tester.pumpAndSettle();
    
    // Verificar se a tela carregou corretamente com suas abas
    expect(find.text('Admin - Ray Club'), findsOneWidget);
    expect(find.text('Benefícios'), findsOneWidget);
    expect(find.text('Resgatados'), findsOneWidget);
  });
  
  testWidgets('BenefitAdminScreen mostra benefícios na primeira aba', (WidgetTester tester) async {
    // Preparar: Simular verificação de admin
    when(mockRepository.isAdmin()).thenAnswer((_) async => true);
    
    // Renderizar o widget com um ProviderScope para usar o container de teste
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          benefitViewModelProvider.overrideWith((_) => mockViewModel),
        ],
        child: MaterialApp(
          home: const BenefitAdminScreen(benefitTitle: 'Test Benefit'),
        ),
      ),
    );
    
    // Aguardar carregamento inicial e chamadas assíncronas
    await tester.pumpAndSettle();
    
    // Verificar se os benefícios são exibidos
    expect(find.text('Test Benefit'), findsOneWidget);
    expect(find.text('Another Benefit'), findsOneWidget);
  });
  
  testWidgets('BenefitAdminScreen permite alterar a data de expiração de um benefício', (WidgetTester tester) async {
    // Preparar: Simular verificação de admin
    when(mockRepository.isAdmin()).thenAnswer((_) async => true);
    
    // Renderizar o widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          benefitViewModelProvider.overrideWith((_) => mockViewModel),
        ],
        child: MaterialApp(
          home: const BenefitAdminScreen(
            benefitTitle: 'Test Benefit',
            availableQuantity: 10,
            expirationDate: null,
            pointsRequired: 100,
          ),
        ),
      ),
    );
    
    // Aguardar carregamento inicial
    await tester.pumpAndSettle();
    
    // Abrir detalhes de um benefício
    await tester.tap(find.text('Test Benefit').first);
    await tester.pumpAndSettle();
    
    // Verificar se o pop-up de detalhes é exibido
    expect(find.text('Alterar Data de Expiração'), findsOneWidget);
    
    // Encontrar e interagir com o widget CustomDatePicker
    final customDatePicker = find.byType(CustomDatePicker);
    expect(customDatePicker, findsOneWidget);
    
    // Simular mudança de data (a implementação completa dependeria da estrutura do CustomDatePicker)
    // Você pode modificar isso baseado em como o CustomDatePicker funciona no seu app
  });
  
  testWidgets('BenefitAdminScreen permite alterar a data de expiração de um benefício resgatado', (WidgetTester tester) async {
    // Preparar: Simular verificação de admin
    when(mockRepository.isAdmin()).thenAnswer((_) async => true);
    
    // Renderizar o widget
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          benefitViewModelProvider.overrideWith((_) => mockViewModel),
        ],
        child: MaterialApp(
          home: const BenefitAdminScreen(
            benefitTitle: 'Test Benefit',
            availableQuantity: 10,
            expirationDate: null,
            pointsRequired: 100,
          ),
        ),
      ),
    );
    
    // Aguardar carregamento inicial
    await tester.pumpAndSettle();
    
    // Navegar para a aba de benefícios resgatados
    await tester.tap(find.text('Resgatados'));
    await tester.pumpAndSettle();
    
    // Verificar se os benefícios resgatados são exibidos
    expect(find.text('CODE123'), findsOneWidget);
    
    // Abrir detalhes de um benefício resgatado
    await tester.tap(find.text('CODE123').first);
    await tester.pumpAndSettle();
    
    // Verificar se o pop-up de detalhes é exibido
    expect(find.text('Alterar Expiração'), findsOneWidget);
    
    // Encontrar e interagir com o widget CustomDatePicker
    final customDatePicker = find.byType(CustomDatePicker);
    expect(customDatePicker, findsOneWidget);
    
    // Simular mudança de data (a implementação completa dependeria da estrutura do CustomDatePicker)
  });
} 
