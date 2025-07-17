// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart' as app_errors;
import 'package:ray_club_app/features/benefits/models/benefit.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit_model.dart';
import 'package:ray_club_app/features/benefits/repositories/benefit_repository.dart';
import 'package:ray_club_app/features/benefits/viewmodels/benefit_state.dart';
import 'package:ray_club_app/features/benefits/viewmodels/benefit_view_model.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';
import 'package:ray_club_app/services/qr_service.dart';

// Mocks para testes
class MockBenefitRepository extends Mock implements BenefitRepository {}
class MockQRService extends Mock implements QRService {}
class FakeBenefit extends Fake implements Benefit {}
class FakeRedeemedBenefit extends Fake implements RedeemedBenefit {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBenefit());
    registerFallbackValue(FakeRedeemedBenefit());
    registerFallbackValue(BenefitStatus.active);
    registerFallbackValue(DateTime.now());
  });

  late MockBenefitRepository mockRepository;
  late MockQRService mockQRService;
  late BenefitViewModel viewModel;

  setUp(() {
    mockRepository = MockBenefitRepository();
    mockQRService = MockQRService();
    viewModel = BenefitViewModel(mockRepository, mockQRService);
  });

  group('BenefitViewModel', () {
    test('estado inicial é correto', () {
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.benefits.isEmpty, true);
      expect(viewModel.state.categories.isEmpty, true);
      expect(viewModel.state.redeemedBenefits.isEmpty, true);
      expect(viewModel.state.selectedBenefit, null);
      expect(viewModel.state.selectedRedeemedBenefit, null);
      expect(viewModel.state.selectedCategory, null);
      expect(viewModel.state.errorMessage, null);
    });

    group('loadBenefits', () {
      test('carrega benefícios com sucesso', () async {
        // Arrange
        final mockBenefits = [
          Benefit(
            id: 'benefit-1',
            title: 'Benefício 1',
            description: 'Descrição 1',
            partner: 'Parceiro 1',
            type: BenefitType.coupon,
            pointsRequired: 100,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            availableQuantity: 10,
          ),
          Benefit(
            id: 'benefit-2',
            title: 'Benefício 2',
            description: 'Descrição 2',
            partner: 'Parceiro 2',
            type: BenefitType.qrCode,
            pointsRequired: 200,
            expirationDate: DateTime.now().add(const Duration(days: 60)),
            availableQuantity: 5,
          ),
        ];

        when(() => mockRepository.getBenefits())
            .thenAnswer((_) async => mockBenefits);
        when(() => mockRepository.getBenefitCategories())
            .thenAnswer((_) async => ['Parceiro 1', 'Parceiro 2']);

        // Act
        await viewModel.loadBenefits();

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.benefits.length, 2);
        expect(viewModel.state.benefits[0].id, 'benefit-1');
        expect(viewModel.state.benefits[1].id, 'benefit-2');
        verify(() => mockRepository.getBenefits()).called(1);
        verify(() => mockRepository.getBenefitCategories()).called(1);
      });

      test('atualiza o estado para error quando ocorre uma exceção', () async {
        // Arrange
        when(() => mockRepository.getBenefits())
            .thenThrow(app_errors.StorageException(
          message: 'Erro ao carregar benefícios',
          code: 'STORAGE_ERROR',
        ));

        // Act
        await viewModel.loadBenefits();

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, 'Erro ao carregar benefícios');
        verify(() => mockRepository.getBenefits()).called(1);
      });
    });

    group('filterByCategory', () {
      test('filtra benefícios por categoria selecionada', () async {
        // Arrange
        final mockBenefits = [
          Benefit(
            id: 'benefit-1',
            title: 'Benefício 1',
            description: 'Descrição 1',
            partner: 'Parceiro 1',
            type: BenefitType.coupon,
            pointsRequired: 100,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            availableQuantity: 10,
          ),
        ];

        final partnerCategory = 'Parceiro 1';

        when(() => mockRepository.getBenefitsByCategory(partnerCategory))
            .thenAnswer((_) async => mockBenefits);

        // Act
        await viewModel.filterByCategory(partnerCategory);

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.selectedCategory, partnerCategory);
        expect(viewModel.state.benefits.length, 1);
        expect(viewModel.state.benefits[0].id, 'benefit-1');
        verify(() => mockRepository.getBenefitsByCategory(partnerCategory)).called(1);
      });

      test('limpa o filtro quando a categoria é null', () async {
        // Arrange
        final mockBenefits = [
          Benefit(
            id: 'benefit-1',
            title: 'Benefício 1',
            description: 'Descrição 1',
            partner: 'Parceiro 1',
            type: BenefitType.coupon,
            pointsRequired: 100,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            availableQuantity: 10,
          ),
          Benefit(
            id: 'benefit-2',
            title: 'Benefício 2',
            description: 'Descrição 2',
            partner: 'Parceiro 2',
            type: BenefitType.qrCode,
            pointsRequired: 200,
            expirationDate: DateTime.now().add(const Duration(days: 60)),
            availableQuantity: 5,
          ),
        ];

        when(() => mockRepository.getBenefits())
            .thenAnswer((_) async => mockBenefits);

        // Act
        await viewModel.filterByCategory(null);

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.selectedCategory, null);
        expect(viewModel.state.benefits.length, 2);
        verify(() => mockRepository.getBenefits()).called(1);
      });
    });

    group('selectBenefit', () {
      test('seleciona um benefício pelo ID', () async {
        // Arrange
        final mockBenefit = Benefit(
          id: 'benefit-1',
          title: 'Benefício 1',
          description: 'Descrição 1',
          partner: 'Parceiro 1',
          type: BenefitType.coupon,
          pointsRequired: 100,
          expirationDate: DateTime.now().add(const Duration(days: 30)),
          availableQuantity: 10,
        );

        when(() => mockRepository.getBenefitById('benefit-1'))
            .thenAnswer((_) async => mockBenefit);

        // Act
        await viewModel.selectBenefit('benefit-1');

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.selectedBenefit?.id, 'benefit-1');
        verify(() => mockRepository.getBenefitById('benefit-1')).called(1);
      });

      test('atualiza para erro quando o benefício não é encontrado', () async {
        // Arrange
        when(() => mockRepository.getBenefitById('invalid-id'))
            .thenAnswer((_) async => null);

        // Act
        await viewModel.selectBenefit('invalid-id');

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, 'Benefício não encontrado');
        verify(() => mockRepository.getBenefitById('invalid-id')).called(1);
      });
    });

    group('redeemBenefit', () {
      test('resgata um benefício com sucesso', () async {
        // Arrange
        final mockBenefit = Benefit(
          id: 'benefit-1',
          title: 'Benefício 1',
          description: 'Descrição 1',
          partner: 'Parceiro 1',
          type: BenefitType.coupon,
          pointsRequired: 100,
          expirationDate: DateTime.now().add(const Duration(days: 30)),
          availableQuantity: 10,
        );

        final mockRedeemedBenefit = RedeemedBenefit(
          id: 'redeemed-1',
          benefitId: 'benefit-1',
          title: 'Benefício 1',
          description: 'Descrição 1',
          code: 'CODE123',
          status: BenefitStatus.active,
          expirationDate: DateTime.now().add(const Duration(days: 30)),
          redeemedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );

        // Configure all necessary mocks
        when(() => mockRepository.getBenefitById('benefit-1'))
            .thenAnswer((_) async => mockBenefit);
        when(() => mockRepository.hasEnoughPoints('benefit-1'))
            .thenAnswer((_) async => true);
        when(() => mockRepository.redeemBenefit('benefit-1'))
            .thenAnswer((_) async => mockRedeemedBenefit);
        when(() => mockRepository.getRedeemedBenefits())
            .thenAnswer((_) async => [mockRedeemedBenefit]);

        // Act
        final result = await viewModel.redeemBenefit('benefit-1');

        // Assert
        expect(result, isNotNull);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.successMessage, 'Benefício resgatado com sucesso!');
        expect(viewModel.state.selectedRedeemedBenefit?.id, 'redeemed-1');
        verify(() => mockRepository.getBenefitById('benefit-1')).called(1);
        verify(() => mockRepository.hasEnoughPoints('benefit-1')).called(1);
        verify(() => mockRepository.redeemBenefit('benefit-1')).called(1);
        verify(() => mockRepository.getRedeemedBenefits()).called(1);
      });

      test('atualiza para erro quando ocorre um problema no resgate', () async {
        // Arrange
        final mockBenefit = Benefit(
          id: 'benefit-1',
          title: 'Benefício 1',
          description: 'Descrição 1',
          partner: 'Parceiro 1',
          type: BenefitType.coupon,
          pointsRequired: 100,
          expirationDate: DateTime.now().add(const Duration(days: 30)),
          availableQuantity: 10,
        );

        when(() => mockRepository.getBenefitById('benefit-1'))
            .thenAnswer((_) async => mockBenefit);
        when(() => mockRepository.hasEnoughPoints('benefit-1'))
            .thenAnswer((_) async => true);
        when(() => mockRepository.redeemBenefit('benefit-1'))
            .thenThrow(app_errors.StorageException(
          message: 'Pontos insuficientes',
          code: 'INSUFFICIENT_POINTS',
        ));

        // Act
        final result = await viewModel.redeemBenefit('benefit-1');

        // Assert
        expect(result, null);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.isRedeeming, false);
        expect(viewModel.state.errorMessage, 'Pontos insuficientes');
        verify(() => mockRepository.getBenefitById('benefit-1')).called(1);
        verify(() => mockRepository.hasEnoughPoints('benefit-1')).called(1);
        verify(() => mockRepository.redeemBenefit('benefit-1')).called(1);
      });
    });

    group('loadRedeemedBenefits', () {
      test('carrega benefícios resgatados com sucesso', () async {
        // Arrange
        final mockRedeemedBenefits = [
          RedeemedBenefit(
            id: 'redeemed-1',
            benefitId: 'benefit-1',
            userId: 'user-1',
            title: 'Benefício 1',
            description: 'Descrição 1',
            code: 'CODE123',
            status: BenefitStatus.active,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            redeemedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          RedeemedBenefit(
            id: 'redeemed-2',
            benefitId: 'benefit-2',
            userId: 'user-1',
            title: 'Benefício 2',
            description: 'Descrição 2',
            code: 'CODE456',
            status: BenefitStatus.used,
            expirationDate: DateTime.now(),
            redeemedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.getRedeemedBenefits())
            .thenAnswer((_) async => mockRedeemedBenefits);
        
        when(() => mockRepository.updateBenefitStatus(any(), any()))
            .thenAnswer((_) async => null);

        // Act
        await viewModel.loadRedeemedBenefits();

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.redeemedBenefits.length, 2);
        expect(viewModel.state.redeemedBenefits[0].id, 'redeemed-1');
        expect(viewModel.state.redeemedBenefits[1].id, 'redeemed-2');
        verify(() => mockRepository.getRedeemedBenefits()).called(1);
      });
    });

    group('clearError', () {
      test('limpa o estado de erro', () async {
        // Arrange - primeiro provocamos um erro
        when(() => mockRepository.getBenefits())
            .thenThrow(app_errors.StorageException(
          message: 'Erro de teste',
          code: 'TEST_ERROR',
        ));
        await viewModel.loadBenefits();
        expect(viewModel.state.errorMessage, 'Erro de teste');

        // Act
        viewModel.clearError();

        // Assert
        expect(viewModel.state.errorMessage, null);
      });
    });

    // Novos testes para verificação de permissões de admin
    group('isAdmin', () {
      test('retorna true quando o usuário é administrador', () async {
        // Arrange
        when(() => mockRepository.isAdmin()).thenAnswer((_) async => true);

        // Act
        final result = await viewModel.isAdmin();

        // Assert
        expect(result, true);
        verify(() => mockRepository.isAdmin()).called(1);
      });

      test('retorna false quando o usuário não é administrador', () async {
        // Arrange
        when(() => mockRepository.isAdmin()).thenAnswer((_) async => false);

        // Act
        final result = await viewModel.isAdmin();

        // Assert
        expect(result, false);
        verify(() => mockRepository.isAdmin()).called(1);
      });

      test('retorna false quando ocorre uma exceção', () async {
        // Arrange
        when(() => mockRepository.isAdmin()).thenThrow(app_errors.AuthException(
          message: 'Erro de autenticação',
          code: 'AUTH_ERROR',
        ));

        // Act
        final result = await viewModel.isAdmin();

        // Assert
        expect(result, false);
        verify(() => mockRepository.isAdmin()).called(1);
      });
    });

    group('loadAllRedeemedBenefits', () {
      test('carrega todos os benefícios resgatados quando é admin', () async {
        // Arrange
        final mockRedeemedBenefits = [
          RedeemedBenefit(
            id: 'redeemed-1',
            benefitId: 'benefit-1',
            userId: 'user-1',
            title: 'Benefício 1',
            description: 'Descrição 1',
            code: 'CODE123',
            status: BenefitStatus.active,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            redeemedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
          RedeemedBenefit(
            id: 'redeemed-2',
            benefitId: 'benefit-2',
            userId: 'user-2',
            title: 'Benefício 2',
            description: 'Descrição 2',
            code: 'CODE456',
            status: BenefitStatus.used,
            expirationDate: DateTime.now(),
            redeemedAt: DateTime.now(),
            createdAt: DateTime.now(),
          ),
        ];

        when(() => mockRepository.isAdmin()).thenAnswer((_) async => true);
        when(() => mockRepository.getAllRedeemedBenefits())
            .thenAnswer((_) async => mockRedeemedBenefits);
        when(() => mockRepository.updateBenefitStatus(any(), any()))
            .thenAnswer((_) async => null);

        // Act
        await viewModel.loadAllRedeemedBenefits();

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.redeemedBenefits.length, 2);
        expect(viewModel.state.errorMessage, null);
        verify(() => mockRepository.isAdmin()).called(1);
        verify(() => mockRepository.getAllRedeemedBenefits()).called(1);
      });

      test('gera erro quando usuário não é admin', () async {
        // Arrange
        when(() => mockRepository.isAdmin()).thenAnswer((_) async => false);

        // Act
        await viewModel.loadAllRedeemedBenefits();

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, 'Permissão negada. Você não tem acesso de administrador.');
        verify(() => mockRepository.isAdmin()).called(1);
        verifyNever(() => mockRepository.getAllRedeemedBenefits());
      });
    });

    // Testes para atualização de datas de expiração
    group('updateBenefitExpiration', () {
      test('atualiza a data de expiração com sucesso', () async {
        // Arrange
        final mockBenefit = Benefit(
          id: 'benefit-1',
          title: 'Benefício 1',
          description: 'Descrição 1',
          partner: 'Parceiro 1',
          type: BenefitType.coupon,
          pointsRequired: 100,
          expirationDate: DateTime.now().add(const Duration(days: 30)),
          availableQuantity: 10,
        );
        
        final updatedBenefit = mockBenefit.copyWith(
          expirationDate: DateTime(2024, 12, 31),
        );
        
        final newExpirationDate = DateTime(2024, 12, 31);

        when(() => mockRepository.updateBenefitExpiration('benefit-1', newExpirationDate))
            .thenAnswer((_) async => updatedBenefit);

        // Act
        final result = await viewModel.updateBenefitExpiration('benefit-1', newExpirationDate);

        // Assert
        expect(result, true);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.selectedBenefit, updatedBenefit);
        verify(() => mockRepository.updateBenefitExpiration('benefit-1', newExpirationDate)).called(1);
      });

      test('retorna false quando o benefício não é encontrado', () async {
        // Arrange
        final newExpirationDate = DateTime(2024, 12, 31);

        when(() => mockRepository.updateBenefitExpiration('invalid-id', newExpirationDate))
            .thenAnswer((_) async => null);

        // Act
        final result = await viewModel.updateBenefitExpiration('invalid-id', newExpirationDate);

        // Assert
        expect(result, false);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, 'Benefício não encontrado');
        verify(() => mockRepository.updateBenefitExpiration('invalid-id', newExpirationDate)).called(1);
      });

      test('retorna false quando ocorre uma exceção', () async {
        // Arrange
        final newExpirationDate = DateTime(2024, 12, 31);

        when(() => mockRepository.updateBenefitExpiration('benefit-1', newExpirationDate))
            .thenThrow(app_errors.StorageException(
          message: 'Erro ao atualizar data de expiração',
          code: 'STORAGE_ERROR',
        ));

        // Act
        final result = await viewModel.updateBenefitExpiration('benefit-1', newExpirationDate);

        // Assert
        expect(result, false);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, 'Erro ao atualizar data de expiração');
        verify(() => mockRepository.updateBenefitExpiration('benefit-1', newExpirationDate)).called(1);
      });
    });

    group('extendRedeemedBenefitExpiration', () {
      test('estende a data de expiração de um benefício resgatado com sucesso', () async {
        // Arrange
        final mockRedeemedBenefit = RedeemedBenefit(
          id: 'redeemed-1',
          benefitId: 'benefit-1',
          userId: 'user-1',
          title: 'Benefício resgatado',
          description: 'Descrição do benefício resgatado',
          code: 'CODE123',
          status: BenefitStatus.active,
          expirationDate: DateTime.now().add(const Duration(days: 10)),
          redeemedAt: DateTime.now(),
          createdAt: DateTime.now(),
        );
        
        final updatedRedeemedBenefit = mockRedeemedBenefit.copyWith(
          expirationDate: DateTime(2024, 12, 31),
        );
        
        final newExpirationDate = DateTime(2024, 12, 31);

        when(() => mockRepository.extendRedeemedBenefitExpiration('redeemed-1', newExpirationDate))
            .thenAnswer((_) async => updatedRedeemedBenefit);

        // Act
        final result = await viewModel.extendRedeemedBenefitExpiration('redeemed-1', newExpirationDate);

        // Assert
        expect(result, true);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.selectedRedeemedBenefit, updatedRedeemedBenefit);
        verify(() => mockRepository.extendRedeemedBenefitExpiration('redeemed-1', newExpirationDate)).called(1);
      });

      test('retorna false quando o benefício resgatado não é encontrado', () async {
        // Arrange
        final newExpirationDate = DateTime(2024, 12, 31);

        when(() => mockRepository.extendRedeemedBenefitExpiration('invalid-id', newExpirationDate))
            .thenAnswer((_) async => null);

        // Act
        final result = await viewModel.extendRedeemedBenefitExpiration('invalid-id', newExpirationDate);

        // Assert
        expect(result, false);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, 'Benefício resgatado não encontrado');
        verify(() => mockRepository.extendRedeemedBenefitExpiration('invalid-id', newExpirationDate)).called(1);
      });

      test('retorna false quando ocorre uma exceção', () async {
        // Arrange
        final newExpirationDate = DateTime(2024, 12, 31);

        when(() => mockRepository.extendRedeemedBenefitExpiration('redeemed-1', newExpirationDate))
            .thenThrow(app_errors.StorageException(
          message: 'Erro ao estender validade do benefício',
          code: 'STORAGE_ERROR',
        ));

        // Act
        final result = await viewModel.extendRedeemedBenefitExpiration('redeemed-1', newExpirationDate);

        // Assert
        expect(result, false);
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, 'Erro ao estender validade do benefício');
        verify(() => mockRepository.extendRedeemedBenefitExpiration('redeemed-1', newExpirationDate)).called(1);
      });
    });
  });
} 
