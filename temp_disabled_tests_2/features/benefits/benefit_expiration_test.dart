// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:ray_club_app/features/benefits/repositories/benefit_repository.dart';
import 'package:ray_club_app/features/benefits/viewmodels/benefit_state.dart';
import 'package:ray_club_app/services/qr_service.dart';
import 'benefit_expiration_test.mocks.dart';

@GenerateMocks([BenefitRepository, QRService])

void main() {
  late MockBenefitRepository mockRepository;
  late MockQRService mockQRService;

  setUp(() {
    mockRepository = MockBenefitRepository();
    mockQRService = MockQRService();
  });

  group('Benefícios Repository', () {
    test('Deve retornar uma lista vazia quando não há benefícios resgatados', () async {
      // Arrange
      when(mockRepository.getRedeemedBenefits())
        .thenAnswer((_) async => []);
      
      // Act
      final result = await mockRepository.getRedeemedBenefits();
      
      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getRedeemedBenefits()).called(1);
    });
  });
} 
