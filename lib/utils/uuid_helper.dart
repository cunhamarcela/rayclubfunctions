import 'package:uuid/uuid.dart';

/// Utilitário simples para garantir UUIDs válidos
class UuidHelper {
  /// Checa se uma string é um UUID válido
  static bool isValid(String? id) {
    if (id == null || id.isEmpty) return false;
    try {
      // Verificação simples usando regex
      return RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false,
      ).hasMatch(id);
    } catch (_) {
      return false;
    }
  }

  /// Garante que um ID seja um UUID válido ou gera um novo
  static String ensureValid(String? id) {
    if (isValid(id)) return id!;
    return const Uuid().v4();
  }
} 