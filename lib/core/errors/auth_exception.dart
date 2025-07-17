/// @deprecated Use AuthException de app_exception.dart em vez desta classe
/// Esta classe será removida em versões futuras
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
} 