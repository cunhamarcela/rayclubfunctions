// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/utils/form_validator.dart';

void main() {
  group('ProfileEditScreen - Nome Field Validation Tests', () {
    
    test('should validate empty name and return error message', () {
      // Act
      final result = FormValidator.validateName('');
      
      // Assert
      expect(result, equals('O nome é obrigatório'));
    });

    test('should validate null name and return error message', () {
      // Act
      final result = FormValidator.validateName(null);
      
      // Assert
      expect(result, equals('O nome é obrigatório'));
    });

    test('should validate valid name and return null', () {
      // Act
      final result = FormValidator.validateName('João Silva');
      
      // Assert
      expect(result, isNull);
    });

    test('should validate name with special characters and return null', () {
      // Act
      final result = FormValidator.validateName('Maria José da Silva');
      
      // Assert
      expect(result, isNull);
    });

    test('should validate single name and return null', () {
      // Act
      final result = FormValidator.validateName('João');
      
      // Assert
      expect(result, isNull);
    });

    test('should validate name with accents and return null', () {
      // Act
      final result = FormValidator.validateName('José António');
      
      // Assert
      expect(result, isNull);
    });
  });
} 