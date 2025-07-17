// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/config/app_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add interceptors
  dio.interceptors.addAll([
    _LoggingInterceptor(),
    _ErrorInterceptor(),
    _AuthInterceptor(),
  ]);

  return dio;
});

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
        'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
        'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    return super.onError(err, handler);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        throw TimeoutException('Connection timeout');
      case DioExceptionType.sendTimeout:
        throw TimeoutException('Send timeout');
      case DioExceptionType.receiveTimeout:
        throw TimeoutException('Receive timeout');
      case DioExceptionType.badResponse:
        switch (err.response?.statusCode) {
          case 400:
            throw BadRequestException(err.response?.data['message']);
          case 401:
            throw UnauthorizedException(err.response?.data['message']);
          case 403:
            throw ForbiddenException(err.response?.data['message']);
          case 404:
            throw NotFoundException(err.response?.data['message']);
          case 500:
            throw InternalServerErrorException(err.response?.data['message']);
          default:
            throw UnknownException(err.response?.data['message']);
        }
      case DioExceptionType.cancel:
        throw RequestCancelledException();
      default:
        throw UnknownException('Unknown error occurred');
    }
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Adiciona o token de autenticação às requisições caso o usuário esteja autenticado
    final supabaseClient = Supabase.instance.client;
    final session = supabaseClient.auth.currentSession;
    
    if (session != null && session.accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${session.accessToken}';
    }
    
    return super.onRequest(options, handler);
  }
}

// Custom exceptions
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

class BadRequestException implements Exception {
  final String? message;
  BadRequestException(this.message);
}

class UnauthorizedException implements Exception {
  final String? message;
  UnauthorizedException(this.message);
}

class ForbiddenException implements Exception {
  final String? message;
  ForbiddenException(this.message);
}

class NotFoundException implements Exception {
  final String? message;
  NotFoundException(this.message);
}

class InternalServerErrorException implements Exception {
  final String? message;
  InternalServerErrorException(this.message);
}

class RequestCancelledException implements Exception {}

class UnknownException implements Exception {
  final String? message;
  UnknownException(this.message);
}
