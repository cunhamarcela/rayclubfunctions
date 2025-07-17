import 'uuid_helper.dart';

/// Extensão para simplificar a validação de UUIDs em strings
extension StringUuidExtension on String {
  /// Converte a string para um UUID válido ou gera um novo se for inválido
  String toValidUuid() => UuidHelper.ensureValid(this);
  
  /// Verifica se a string é um UUID válido
  bool get isValidUuid => UuidHelper.isValid(this);
}

/// Extensão para tratar valores String? (nullable)
extension NullableStringUuidExtension on String? {
  /// Converte a string para um UUID válido ou gera um novo se for inválido/nulo
  String toValidUuid() => UuidHelper.ensureValid(this);
  
  /// Verifica se a string é um UUID válido
  bool get isValidUuid => this != null && UuidHelper.isValid(this);
} 