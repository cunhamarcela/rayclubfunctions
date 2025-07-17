/// @deprecated Use NetworkException de app_exception.dart em vez desta classe
/// Esta classe será removida em versões futuras
/// Exceção personalizada para erros de rede
class NetworkException implements Exception {
  /// Mensagem descritiva do erro
  final String message;
  
  /// Código de status HTTP, se disponível
  final int statusCode;
  
  /// Erro original que causou a exceção
  final dynamic originalError;
  
  /// Indica se este erro é um timeout
  bool get isTimeout => 
      statusCode == -1 || 
      (originalError?.toString().contains('timeout') ?? false);
  
  /// Indica se este erro é relacionado à conectividade
  bool get isConnectivityError => 
      statusCode == -3 || 
      statusCode == -4 || 
      (originalError?.toString().contains('SocketException') ?? false);
  
  /// Indica se este erro é um erro do servidor (5xx)
  bool get isServerError => 
      statusCode >= 500 && statusCode < 600;
  
  /// Indica se este erro é um erro de autorização (401)
  bool get isUnauthorized => statusCode == 401;
  
  /// Indica se este erro é um erro de acesso proibido (403)
  bool get isForbidden => statusCode == 403;
  
  /// Indica se este erro é um erro de recurso não encontrado (404)
  bool get isNotFound => statusCode == 404;
  
  /// Construtor para NetworkException
  const NetworkException({
    required this.message,
    required this.statusCode,
    this.originalError,
  });
  
  @override
  String toString() {
    return 'NetworkException: $message (código: $statusCode)';
  }
} 