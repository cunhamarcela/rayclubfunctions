/// Classe utilitária para operações de filtro em dados
class FilterUtils {
  /// Filtra uma lista de mapas com base em um valor de campo específico
  static List<Map<String, dynamic>> filterByField(
    List<Map<String, dynamic>> items,
    String fieldName,
    dynamic value,
  ) {
    return items.where((item) => item[fieldName] == value).toList();
  }

  /// Filtra uma lista de mapas com base em múltiplos campos
  static List<Map<String, dynamic>> filterByMultipleFields(
    List<Map<String, dynamic>> items,
    Map<String, dynamic> conditions,
  ) {
    return items.where((item) {
      for (final entry in conditions.entries) {
        if (item[entry.key] != entry.value) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Filtra uma lista de objetos usando uma função de predicado
  static List<T> filterByPredicate<T>(
    List<T> items,
    bool Function(T item) predicate,
  ) {
    return items.where(predicate).toList();
  }

  /// Filtra uma string removendo caracteres especiais
  static String sanitizeString(String value) {
    return value.replaceAll(RegExp(r'[^\w\s]+'), '');
  }
} 