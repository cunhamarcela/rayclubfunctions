// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/core/errors/error_handler.dart';

void main() {
  final stackTrace = StackTrace.current;

  group('ErrorClassifier:', () {
    test('classifyError deve retornar a mesma instância se já for um AppException', () {
      // Arrange
      final originalException = AppException(
        message: 'Teste',
        code: '123',
      );
      
      // Act
      final result = ErrorClassifier.classifyError(originalException, stackTrace);
      
      // Assert
      expect(result, same(originalException));
    });
    
    test('classifyError deve detectar erros de rede', () {
      // Arrange & Act
      final networkErrors = [
        'SocketException: Failed to connect to host',
        'Connection refused',
        'Network error',
        'Connection timeout',
        'Certificate verification failed',
        'handshake error'
      ];
      
      // Assert
      for (final error in networkErrors) {
        final result = ErrorClassifier.classifyError(Exception(error), stackTrace);
        expect(result, isA<NetworkException>());
        expect(result.message, 'A conexão falhou. Verifique sua internet.');
      }
    });
    
    test('classifyError deve detectar erros de autenticação', () {
      // Arrange & Act
      final authErrors = [
        'Authentication failed',
        'Unauthorized access',
        'Forbidden resource',
        'Insufficient permissions',
        'Invalid token',
        'Invalid credentials',
        'Login failed',
        'Incorrect password'
      ];
      
      // Assert
      for (final error in authErrors) {
        final result = ErrorClassifier.classifyError(Exception(error), stackTrace);
        expect(result, isA<AuthException>());
        expect(result.message, 'Erro de autenticação. Faça login novamente.');
      }
    });
    
    test('classifyError deve detectar erros de armazenamento', () {
      // Arrange & Act
      final storageErrors = [
        'Storage error',
        'File not found',
        'Bucket does not exist',
        'Upload failed',
        'Download error',
        'IO Error while reading file'
      ];
      
      // Assert
      for (final error in storageErrors) {
        final result = ErrorClassifier.classifyError(Exception(error), stackTrace);
        expect(result, isA<StorageException>());
        expect(result.message, 'Erro de armazenamento. Tente novamente mais tarde.');
      }
    });
    
    test('classifyError deve detectar erros de validação', () {
      // Arrange & Act
      final validationErrors = [
        'Validation failed',
        'Invalid input',
        'Required field missing',
        'Invalid format',
        'Constraint violation',
        'NOT NULL constraint failed'
      ];
      
      // Assert
      for (final error in validationErrors) {
        final result = ErrorClassifier.classifyError(Exception(error), stackTrace);
        expect(result, isA<ValidationException>());
        expect(result.message, 'Dados inválidos. Verifique os campos informados.');
      }
    });
    
    test('classifyError deve extrair código de erro quando presente', () {
      // Arrange
      final errorWithCode = Exception('Error occurred: code: ABC123');
      
      // Act
      final result = ErrorClassifier.classifyError(errorWithCode, stackTrace);
      
      // Assert
      expect(result.code, 'ABC123');
    });
    
    test('classifyError deve retornar AppException genérica para outros tipos de erro', () {
      // Arrange
      final genericError = Exception('Algum erro desconhecido');
      
      // Act
      final result = ErrorClassifier.classifyError(genericError, stackTrace);
      
      // Assert
      expect(result, isA<AppException>());
      expect(result is NetworkException, isFalse);
      expect(result is AuthException, isFalse);
      expect(result is StorageException, isFalse);
      expect(result is ValidationException, isFalse);
    });
  });
} 
