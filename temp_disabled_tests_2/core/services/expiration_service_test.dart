// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:ray_club_app/core/services/expiration_service.dart';
import 'package:ray_club_app/features/benefits/viewmodels/benefit_view_model.dart';
import 'expiration_service_test.mocks.dart';

@GenerateMocks([BenefitViewModel])

class MockNotifier<T> extends MockBenefitViewModel implements StateNotifier<T> {}

class MockProviderRef extends Mock implements Ref {}

void main() {
  late MockProviderRef mockRef;
  late MockBenefitViewModel mockBenefitViewModel;
  late ExpirationService expirationService;

  setUp(() {
    mockRef = MockProviderRef();
    mockBenefitViewModel = MockBenefitViewModel();
    
    when(mockRef.read(benefitViewModelProvider.notifier))
        .thenReturn(mockBenefitViewModel);
    
    expirationService = ExpirationService(mockRef);
  });

  tearDown(() {
    expirationService.dispose();
  });

  group('ExpirationService', () {
    test('initialize deve iniciar verificação periódica', () {
      // Act
      expirationService.initialize();
      
      // Assert
      expect(expirationService.isInitialized, isTrue);
    });
    
    test('_checkBenefitsExpiration deve chamar loadRedeemedBenefits no BenefitViewModel', () async {
      // Arrange
      when(mockBenefitViewModel.loadRedeemedBenefits())
          .thenAnswer((_) async {});
      
      // Act
      await expirationService.checkExpirations();
      
      // Assert
      verify(mockBenefitViewModel.loadRedeemedBenefits()).called(1);
    });
    
    test('dispose deve parar verificações periódicas', () {
      // Arrange
      expirationService.initialize();
      expect(expirationService.isInitialized, isTrue);
      
      // Act
      expirationService.dispose();
      
      // Assert
      expect(expirationService.isInitialized, isFalse);
    });
  });
} 
