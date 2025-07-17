import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for a configured Dio instance
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  
  // Configuração básica
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.sendTimeout = const Duration(seconds: 30);
  
  // Interceptors para logging e tratamento de erros
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (obj) => print(obj.toString()),
  ));
  
  dio.interceptors.add(InterceptorsWrapper(
    onError: (DioException error, ErrorInterceptorHandler handler) {
      // Transformar erros do Dio em exceções da aplicação
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        // Tratar erros de timeout
      } else if (error.response != null) {
        // Tratar erros com resposta do servidor
      } else {
        // Outros erros
      }
      return handler.next(error);
    },
  ));
  
  return dio;
}); 