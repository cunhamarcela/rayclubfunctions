/// @deprecated Esta classe deve ser migrada para o sistema app_exception.dart
/// Considere criar um NotificationException em app_exception.dart se necessário
/// Esta classe será removida em versões futuras
/// Exceção personalizada para erros de notificação
class NotificationException implements Exception {
  /// Mensagem descritiva do erro
  final String message;
  
  /// Erro original que causou a exceção
  final dynamic originalError;
  
  /// Indica se este erro é relacionado à inicialização
  bool get isInitializationError => 
      message.contains('inicializar') || 
      message.contains('initialize');
  
  /// Indica se este erro é relacionado à recuperação de notificações
  bool get isFetchError => 
      message.contains('buscar') || 
      message.contains('obter');
  
  /// Indica se este erro é relacionado à criação de notificações
  bool get isCreationError => 
      message.contains('criar') || 
      message.contains('create');
  
  /// Indica se este erro é relacionado à exibição de notificações
  bool get isDisplayError => 
      message.contains('mostrar') || 
      message.contains('exibir') ||
      message.contains('display');
  
  /// Indica se este erro é relacionado à inscrição em notificações em tempo real
  bool get isSubscriptionError => 
      message.contains('inscrever') || 
      message.contains('subscribe');
  
  /// Construtor para NotificationException
  const NotificationException({
    required this.message,
    this.originalError,
  });
  
  @override
  String toString() {
    return 'NotificationException: $message';
  }
} 