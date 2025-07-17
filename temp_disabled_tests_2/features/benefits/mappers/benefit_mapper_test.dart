import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/benefits/enums/benefit_type.dart';
import 'package:ray_club_app/features/benefits/mappers/benefit_mapper.dart';
import 'package:ray_club_app/features/benefits/models/benefit.dart';

void main() {
  group('BenefitMapper', () {
    test('should convert snake_case JSON to Benefit model', () {
      final json = {
        'id': '1',
        'title': 'Desconto Academia',
        'description': 'Desconto de 20% na mensalidade',
        'image_url': 'https://example.com/image.jpg',
        'partner': 'Academia XYZ',
        'points_required': 500,
        'available_quantity': 10,
        'is_featured': true,
        'type': 'coupon',
      };

      final benefit = BenefitMapper.fromSupabase(json);
      
      expect(benefit.id, '1');
      expect(benefit.title, 'Desconto Academia');
      expect(benefit.imageUrl, 'https://example.com/image.jpg');
      expect(benefit.pointsRequired, 500);
      expect(benefit.isFeatured, true);
      expect(benefit.type, BenefitType.coupon);
    });

    test('should handle null values with safe defaults', () {
      final json = {
        'id': '1',
        'title': null,
        'description': null,
        'points_required': null,
        'type': null,
      };

      final benefit = BenefitMapper.fromSupabase(json);
      
      expect(benefit.id, '1');
      expect(benefit.title, '');
      expect(benefit.description, '');
      expect(benefit.pointsRequired, 0);
      expect(benefit.type, BenefitType.coupon); // valor padrão
    });

    test('should convert different enum string values to correct BenefitType', () {
      // Não podemos testar _parseBenefitType diretamente, então testamos através do fromSupabase
      final couponJson = {'id': '1', 'title': 'Test', 'description': 'Test', 'partner': 'Test', 'type': 'coupon'};
      final qrCodeJson = {'id': '1', 'title': 'Test', 'description': 'Test', 'partner': 'Test', 'type': 'qrcode'};
      final linkJson = {'id': '1', 'title': 'Test', 'description': 'Test', 'partner': 'Test', 'type': 'link'};
      final unknownJson = {'id': '1', 'title': 'Test', 'description': 'Test', 'partner': 'Test', 'type': 'unknown'};
      
      expect(BenefitMapper.fromSupabase(couponJson).type, BenefitType.coupon);
      expect(BenefitMapper.fromSupabase(qrCodeJson).type, BenefitType.qrCode);
      expect(BenefitMapper.fromSupabase(linkJson).type, BenefitType.link);
      expect(BenefitMapper.fromSupabase(unknownJson).type, BenefitType.coupon); // padrão para tipos desconhecidos
    });

    test('needsMapper should correctly identify JSON that needs mapping', () {
      expect(BenefitMapper.needsMapper({'image_url': 'test.jpg'}), true);
      expect(BenefitMapper.needsMapper({'type': 'qrcode'}), true);
      expect(BenefitMapper.needsMapper({'id': '1', 'title': 'Test'}), false);
    });
  });
} 