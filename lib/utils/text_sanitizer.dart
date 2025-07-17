// Flutter imports:
import 'package:flutter/foundation.dart';

/// Utilitário para sanitização de textos e URLs
/// Centraliza os métodos de sanitização para manter consistência no app
class TextSanitizer {
  /// Sanitiza um texto, removendo espaços em branco no início e fim
  /// e caracteres potencialmente perigosos para segurança
  static String sanitizeText(String? text) {
    if (text == null || text.isEmpty) return '';
    
    String sanitized = text.trim();
    
    // Remove tags HTML e JavaScript
    sanitized = sanitized
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll(RegExp(r'javascript:'), '');
    
    // Remove eventos JavaScript (como onclick, onmouseover, etc.)
    sanitized = sanitized.replaceAll(RegExp(r'on\w+\s*=\s*"[^"]*"'), '');
    sanitized = sanitized.replaceAll(RegExp(r"on\w+\s*=\s*'[^']*'"), '');
    
    return sanitized;
  }
  
  /// Sanitiza uma URL, removendo espaços e verificando sua validade
  static String? sanitizeUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    
    String sanitized = url.trim();
    
    // Verifica se a URL começa com http:// ou https://
    if (!sanitized.startsWith('http://') && !sanitized.startsWith('https://')) {
      debugPrint('URL inválida detectada: $sanitized');
      return null;
    }
    
    // Sanitiza a URL para evitar caracteres inválidos/perigosos
    sanitized = sanitized
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll(RegExp(r'javascript:'), '')
      .replaceAll(RegExp(r'"'), '')
      .replaceAll(RegExp(r"'"), '');
    
    return sanitized.isEmpty ? null : sanitized;
  }
  
  /// Sanitiza um texto nulo, retornando null se vazio após sanitização
  static String? sanitizeNullableText(String? text) {
    if (text == null) return null;
    
    String sanitized = sanitizeText(text);
    return sanitized.isEmpty ? null : sanitized;
  }
  
  /// Sanitiza texto para segurança em consultas SQL
  static String sanitizeForSql(String? text) {
    if (text == null) return '';
    
    // Escapa aspas simples e remove caracteres potencialmente perigosos para SQL
    return text
      .replaceAll("'", "''")
      .replaceAll(RegExp(r'[;\\]'), '');
  }
} 