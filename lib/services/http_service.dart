// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:retry/retry.dart';

// Project imports:
import '../core/di/base_service.dart';
import '../core/errors/app_exception.dart';

/// Serviço HTTP para gerenciar todas as requisições de rede usando Dio
class HttpService implements BaseService {
  late final Dio _dio;
  bool _initialized = false;

  HttpService({Dio? dio}) {
    _dio = dio ?? Dio();
  }

  @override
  bool get isInitialized => _initialized;

  /// Inicializa o serviço HTTP configurando interceptors e opções padrão
  @override
  Future<void> initialize() async {
    // Base URL e timeout
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500,
    );

    // Adiciona interceptor de log para depuração
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: true,
      ));
    }

    // Interceptor para manipulação de erros
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Adiciona token de autenticação se disponível
          // Aqui você pode implementar a lógica para adicionar tokens
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final statusCode = response.statusCode;
          if (statusCode != null && statusCode >= 400) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                error: 'Erro na requisição: $statusCode',
              ),
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          return handler.reject(_handleError(error));
        },
      ),
    );

    _initialized = true;
  }

  /// Realiza uma requisição GET com retry para maior confiabilidade
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    int retries = 3,
  }) async {
    if (!_initialized) {
      throw Exception('HttpService não foi inicializado');
    }

    try {
      return await retry(
        () => _dio.get<T>(
          path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        ),
        retryIf: _shouldRetry,
        maxAttempts: retries,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw NetworkException(
        message: 'Erro inesperado na requisição GET: $e',
        code: '0',
        originalError: e,
      );
    }
  }

  /// Realiza uma requisição POST com retry para maior confiabilidade
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int retries = 3,
  }) async {
    if (!_initialized) {
      throw Exception('HttpService não foi inicializado');
    }

    try {
      return await retry(
        () => _dio.post<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
        retryIf: _shouldRetry,
        maxAttempts: retries,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw NetworkException(
        message: 'Erro inesperado na requisição POST: $e',
        code: '0',
        originalError: e,
      );
    }
  }

  /// Realiza uma requisição PUT com retry para maior confiabilidade
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    int retries = 3,
  }) async {
    if (!_initialized) {
      throw Exception('HttpService não foi inicializado');
    }

    try {
      return await retry(
        () => _dio.put<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        ),
        retryIf: _shouldRetry,
        maxAttempts: retries,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw NetworkException(
        message: 'Erro inesperado na requisição PUT: $e',
        code: '0',
        originalError: e,
      );
    }
  }

  /// Realiza uma requisição DELETE com retry para maior confiabilidade
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    int retries = 3,
  }) async {
    if (!_initialized) {
      throw Exception('HttpService não foi inicializado');
    }

    try {
      return await retry(
        () => _dio.delete<T>(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
        ),
        retryIf: _shouldRetry,
        maxAttempts: retries,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw NetworkException(
        message: 'Erro inesperado na requisição DELETE: $e',
        code: '0',
        originalError: e,
      );
    }
  }

  /// Determina se uma requisição deve ser refeita baseado no tipo de erro
  bool _shouldRetry(Exception e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          (e.error is SocketException) ||
          e.type == DioExceptionType.badResponse && 
          (e.response?.statusCode == 429 || 
           e.response?.statusCode == 500 || 
           e.response?.statusCode == 503);
    }
    return false;
  }

  /// Trata os erros de requisição de forma padronizada
  DioException _handleError(DioException error) {
    String errorMessage = 'Ocorreu um erro na requisição';
    int statusCode = 0;

    if (error.response != null) {
      statusCode = error.response?.statusCode ?? 0;
      
      // Tenta extrair mensagem de erro da resposta
      try {
        final data = error.response?.data;
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'] as String? ?? errorMessage;
        } else if (data is Map && data.containsKey('error')) {
          errorMessage = data['error'] as String? ?? errorMessage;
        }
      } catch (_) {
        errorMessage = 'Erro ${error.response?.statusCode ?? "desconhecido"}';
      }
    } else {
      // Erros de conexão ou timeout
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Tempo de conexão esgotado';
          statusCode = -1;
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'Certificado SSL inválido';
          statusCode = -2;
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Erro de conexão';
          statusCode = -3;
          break;
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            errorMessage = 'Sem conexão com a internet';
            statusCode = -4;
          }
          break;
        default:
          errorMessage = error.message ?? 'Erro desconhecido';
          break;
      }
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      error: NetworkException(
        message: errorMessage,
        code: statusCode.toString(),
        originalError: error,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
    _dio.close();
  }
} 
