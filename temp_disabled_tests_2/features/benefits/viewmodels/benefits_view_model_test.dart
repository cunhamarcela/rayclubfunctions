// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';
import 'package:ray_club_app/features/benefits/models/benefit.dart';
import 'package:ray_club_app/features/benefits/repositories/benefits_repository.dart';
import 'package:ray_club_app/features/benefits/viewmodels/benefits_view_model.dart';
import 'benefits_view_model_test.mocks.dart';

@GenerateMocks([BenefitsRepository])
void main() {
  late MockBenefitsRepository mockRepository;
  late BenefitsViewModel viewModel;

  setUp(() {
    mockRepository = MockBenefitsRepository();
    viewModel = BenefitsViewModel(mockRepository);
  });

  // Helper para criar um benefício de teste
  Benefit _createTestBenefit({
    required String id,
    required String title,
    required String description,
    required String partner,
    required int pointsRequired,
    required DateTime expirationDate,
    required int availableQuantity,
    BenefitType type = BenefitType.coupon,
    bool isFeatured = false,
    String? imageUrl,
    String? category,
  }) {
    return Benefit(
      id: id,
      title: title,
      description: description,
      partner: partner,
      type: type,
      pointsRequired: pointsRequired,
      expirationDate: expirationDate,
      availableQuantity: availableQuantity,
      isFeatured: isFeatured,
      imageUrl: imageUrl ?? '',
      category: category ?? '',
    );
  }

  group('BenefitsViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.state.benefits, isEmpty);
      expect(viewModel.state.filteredBenefits, isEmpty);
      expect(viewModel.state.activeTab, 'all');
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, isNull);
      expect(viewModel.state.selectedBenefit, isNull);
      expect(viewModel.state.partners, isEmpty);
    });

    group('loadBenefits', () {
      test('loads benefits and updates state', () async {
        // Arrange
        final benefits = [
          _createTestBenefit(
            id: '1',
            title: 'Test Benefit 1',
            description: 'Description 1',
            partner: 'Partner 1',
            pointsRequired: 100,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            availableQuantity: 10,
            type: BenefitType.coupon,
          ),
          _createTestBenefit(
            id: '2',
            title: 'Test Benefit 2',
            description: 'Description 2',
            partner: 'Partner 2',
            pointsRequired: 200,
            expirationDate: DateTime.now().add(const Duration(days: 60)),
            availableQuantity: 5,
            type: BenefitType.qrCode,
          ),
        ];

        when(mockRepository.getAllBenefits()).thenAnswer((_) async => benefits);

        // Act
        await viewModel.loadBenefits();

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.benefits.length, 2);
        expect(viewModel.state.filteredBenefits.length, 2);
        expect(viewModel.state.benefits[0].id, '1');
        expect(viewModel.state.benefits[1].id, '2');
        
        // Verificar se os parceiros únicos foram extraídos
        expect(viewModel.state.partners.length, 2);
        expect(viewModel.state.partners.contains('Partner 1'), isTrue);
        expect(viewModel.state.partners.contains('Partner 2'), isTrue);
        
        verify(mockRepository.getAllBenefits()).called(1);
      });

      test('handles error during benefits loading', () async {
        // Arrange
        when(mockRepository.getAllBenefits()).thenThrow(Exception('Network error'));

        // Act
        await viewModel.loadBenefits();

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, contains('Falha ao carregar benefícios'));
        expect(viewModel.state.benefits, isEmpty);
        
        verify(mockRepository.getAllBenefits()).called(1);
      });
    });

    group('filterByType', () {
      test('filters benefits by type', () async {
        // Arrange
        final benefits = [
          _createTestBenefit(
            id: '1',
            title: 'Coupon Benefit',
            description: 'Description 1',
            partner: 'Partner 1',
            pointsRequired: 100,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            availableQuantity: 10,
            type: BenefitType.coupon,
          ),
        ];

        when(mockRepository.getBenefitsByType(BenefitType.coupon))
            .thenAnswer((_) async => benefits);

        // Act
        await viewModel.filterByType(BenefitType.coupon);

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.activeTab, 'coupon');
        expect(viewModel.state.filteredBenefits.length, 1);
        expect(viewModel.state.filteredBenefits[0].title, 'Coupon Benefit');
        
        verify(mockRepository.getBenefitsByType(BenefitType.coupon)).called(1);
      });

      test('handles error during filtering', () async {
        // Arrange
        when(mockRepository.getBenefitsByType(BenefitType.coupon))
            .thenThrow(Exception('Filter error'));

        // Act
        await viewModel.filterByType(BenefitType.coupon);

        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.errorMessage, contains('Falha ao filtrar benefícios'));
        
        verify(mockRepository.getBenefitsByType(BenefitType.coupon)).called(1);
      });
    });

    group('showAllBenefits', () {
      test('shows all benefits', () async {
        // Arrange - Primeiro carregue alguns benefícios
        final allBenefits = [
          _createTestBenefit(
            id: '1',
            title: 'Benefit 1',
            description: 'Description 1',
            partner: 'Partner 1',
            pointsRequired: 100,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            availableQuantity: 10,
          ),
          _createTestBenefit(
            id: '2',
            title: 'Benefit 2',
            description: 'Description 2',
            partner: 'Partner 2',
            pointsRequired: 200,
            expirationDate: DateTime.now().add(const Duration(days: 60)),
            availableQuantity: 5,
          ),
        ];

        // Filtrar para apenas um benefício
        final filteredBenefits = [allBenefits[0]];

        when(mockRepository.getAllBenefits()).thenAnswer((_) async => allBenefits);
        when(mockRepository.getBenefitsByType(any)).thenAnswer((_) async => filteredBenefits);

        // Primeiro carregue todos os benefícios
        await viewModel.loadBenefits();
        
        // Depois filtre
        await viewModel.filterByType(BenefitType.coupon);
        
        // Verifique se o filtro foi aplicado
        expect(viewModel.state.filteredBenefits.length, 1);
        
        // Act - Mostrar todos novamente
        viewModel.showAllBenefits();
        
        // Assert
        expect(viewModel.state.activeTab, 'all');
        expect(viewModel.state.filteredBenefits.length, 2); // Todos os benefícios devem ser mostrados
      });
    });

    group('filterByPartner', () {
      test('filters benefits by partner', () async {
        // Arrange - Primeiro carregue alguns benefícios
        final allBenefits = [
          _createTestBenefit(
            id: '1',
            title: 'Benefit 1',
            description: 'Description 1',
            partner: 'Partner 1',
            pointsRequired: 100,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            availableQuantity: 10,
          ),
          _createTestBenefit(
            id: '2',
            title: 'Benefit 2',
            description: 'Description 2',
            partner: 'Partner 2',
            pointsRequired: 200,
            expirationDate: DateTime.now().add(const Duration(days: 60)),
            availableQuantity: 5,
          ),
        ];

        when(mockRepository.getAllBenefits()).thenAnswer((_) async => allBenefits);
        when(mockRepository.getBenefitsByPartner('Partner 1'))
            .thenAnswer((_) async => [allBenefits[0]]);

        // Primeiro carregue todos os benefícios
        await viewModel.loadBenefits();
        
        // Act - Filtrar por parceiro
        await viewModel.filterByPartner('Partner 1');
        
        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.filteredBenefits.length, 1);
        expect(viewModel.state.filteredBenefits[0].partner, 'Partner 1');
        
        verify(mockRepository.getBenefitsByPartner('Partner 1')).called(1);
      });

      test('handles null partner by showing all benefits', () async {
        // Arrange
        final benefits = [
          _createTestBenefit(
            id: '1',
            title: 'Benefit 1',
            description: 'Description 1',
            partner: 'Partner 1',
            pointsRequired: 100,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            availableQuantity: 10,
          ),
          _createTestBenefit(
            id: '2',
            title: 'Benefit 2',
            description: 'Description 2',
            partner: 'Partner 2',
            pointsRequired: 200,
            expirationDate: DateTime.now().add(const Duration(days: 60)),
            availableQuantity: 5,
          ),
        ];

        when(mockRepository.getAllBenefits()).thenAnswer((_) async => benefits);
        
        // Primeiro carregue benefícios
        await viewModel.loadBenefits();
        
        // Act
        await viewModel.filterByPartner(null);
        
        // Assert
        expect(viewModel.state.filteredBenefits.length, 2); // Todos os benefícios são mostrados
      });
    });

    group('searchBenefits', () {
      test('searches benefits by query', () async {
        // Arrange
        final allBenefits = [
          _createTestBenefit(
            id: '1',
            title: 'ACME Discount',
            description: 'Description 1',
            partner: 'ACME',
            pointsRequired: 100,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            availableQuantity: 10,
          ),
          _createTestBenefit(
            id: '2',
            title: 'XYZ Discount',
            description: 'Description 2',
            partner: 'XYZ',
            pointsRequired: 200,
            expirationDate: DateTime.now().add(const Duration(days: 60)),
            availableQuantity: 5,
          ),
        ];

        when(mockRepository.getAllBenefits()).thenAnswer((_) async => allBenefits);
        when(mockRepository.searchBenefits('ACME')).thenAnswer((_) async => [allBenefits[0]]);

        // Primeiro carregue todos os benefícios
        await viewModel.loadBenefits();
        
        // Act
        await viewModel.searchBenefits('ACME');
        
        // Assert
        expect(viewModel.state.isLoading, false);
        expect(viewModel.state.filteredBenefits.length, 1);
        expect(viewModel.state.filteredBenefits[0].title, 'ACME Discount');
        
        verify(mockRepository.searchBenefits('ACME')).called(1);
      });

      test('handles empty search query by showing all benefits', () async {
        // Arrange
        final benefits = [
          _createTestBenefit(
            id: '1',
            title: 'Benefit 1',
            description: 'Description 1',
            partner: 'Partner 1',
            pointsRequired: 100,
            expirationDate: DateTime.now().add(const Duration(days: 30)),
            availableQuantity: 10,
          ),
          _createTestBenefit(
            id: '2',
            title: 'Benefit 2',
            description: 'Description 2',
            partner: 'Partner 2',
            pointsRequired: 200,
            expirationDate: DateTime.now().add(const Duration(days: 60)),
            availableQuantity: 5,
          ),
        ];

        when(mockRepository.getAllBenefits()).thenAnswer((_) async => benefits);
        
        // Primeiro carregue benefícios
        await viewModel.loadBenefits();
        
        // Act - Pesquisar com string vazia
        await viewModel.searchBenefits('');
        
        // Assert
        expect(viewModel.state.filteredBenefits.length, 2); // Todos os benefícios são mostrados
        verify(mockRepository.getAllBenefits()).called(2); // Uma vez no loadBenefits e outra vez no searchBenefits
      });
    });
  });
} 