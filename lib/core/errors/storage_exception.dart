/// @deprecated Use StorageException de app_exception.dart em vez desta classe
/// Esta classe será removida em versões futuras
/// Exceção personalizada para erros de armazenamento
class StorageException implements Exception {
  /// Mensagem descritiva do erro
  final String message;
  
  /// Erro original que causou a exceção
  final dynamic originalError;
  
  /// Indica se este erro é de upload
  bool get isUploadError => 
      message.contains('upload') || 
      message.contains('Upload');
  
  /// Indica se este erro é de download
  bool get isDownloadError => 
      message.contains('download') || 
      message.contains('baixar');
  
  /// Indica se este erro é de exclusão
  bool get isDeleteError => 
      message.contains('excluir') || 
      message.contains('delete') ||
      message.contains('remover');
  
  /// Construtor para StorageException
  const StorageException({
    required this.message,
    this.originalError,
  });
  
  @override
  String toString() {
    return 'StorageException: $message';
  }
} 