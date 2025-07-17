import 'package:flutter/material.dart';

/// Classe auxiliar para validação de tipos em parâmetros de rota
/// Fornece métodos para verificar e converter parâmetros de rotas
class RouteParamValidator {
  
  /// Converte um parâmetro de string para int, retornando null se inválido
  static int? tryParseInt(String? value) {
    if (value == null) return null;
    return int.tryParse(value);
  }
  
  /// Converte um parâmetro de string para int, lançando uma exceção se inválido
  /// Útil quando o parâmetro é obrigatório e deve ser um inteiro válido
  static int parseInt(String value, {String paramName = 'parâmetro'}) {
    final result = int.tryParse(value);
    if (result == null) {
      throw FormatException('O $paramName deve ser um número inteiro válido, recebido: $value');
    }
    return result;
  }
  
  /// Converte um parâmetro de string para double, retornando null se inválido
  static double? tryParseDouble(String? value) {
    if (value == null) return null;
    return double.tryParse(value);
  }
  
  /// Converte um parâmetro de string para double, lançando uma exceção se inválido
  static double parseDouble(String value, {String paramName = 'parâmetro'}) {
    final result = double.tryParse(value);
    if (result == null) {
      throw FormatException('O $paramName deve ser um número decimal válido, recebido: $value');
    }
    return result;
  }
  
  /// Valida se uma string é um UUID válido
  static bool isValidUuid(String value) {
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidPattern.hasMatch(value);
  }
  
  /// Valida se uma string é um UUID válido, lançando uma exceção se inválido
  static String validateUuid(String value, {String paramName = 'ID'}) {
    if (!isValidUuid(value)) {
      throw FormatException('O $paramName deve ser um UUID válido, recebido: $value');
    }
    return value;
  }
  
  /// Exibe um diálogo de erro para parâmetros inválidos
  static void showInvalidParamError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Parâmetro Inválido'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 