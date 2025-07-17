/// Exceção personalizada para a aplicação.
/// Permite padronizar erros com código, mensagem e detalhes.
class AppException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AppException');
    
    if (code != null) {
      buffer.write('($code)');
    }
    
    buffer.write(': $message');
    
    if (details != null) {
      buffer.write('\nDetalhes: $details');
    }
    
    return buffer.toString();
  }
}

/// Exceção específica para erros de autenticação.
class AppAuthException extends AppException {
  const AppAuthException({
    required String message,
    String? code,
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          code: code ?? 'auth_error',
          details: details,
        );
} 