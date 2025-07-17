// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';

void main() {
  group('FileValidationException', () {
    test('should create instance with required parameters', () {
      final exception = FileValidationException(
        message: 'Invalid file',
      );
      
      expect(exception.message, 'Invalid file');
      expect(exception.code, 'file_validation_error'); // default code
      expect(exception.originalError, isNull);
      expect(exception.stackTrace, isNull);
    });
    
    test('should create instance with all parameters', () {
      final originalError = Exception('Original error');
      final stackTrace = StackTrace.current;
      
      final exception = FileValidationException(
        message: 'Invalid file',
        code: 'custom_code',
        originalError: originalError,
        stackTrace: stackTrace,
      );
      
      expect(exception.message, 'Invalid file');
      expect(exception.code, 'custom_code');
      expect(exception.originalError, originalError);
      expect(exception.stackTrace, stackTrace);
    });
    
    test('should convert to string properly', () {
      final exception = FileValidationException(
        message: 'Invalid file',
        code: 'test_code',
      );
      
      expect(exception.toString(), 'AppException: Invalid file (Code: test_code)');
    });
  });
} 
