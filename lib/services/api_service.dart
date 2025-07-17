// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for handling API requests using Dio
class ApiService {
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_URL'] ?? 'https://api.rayclub.com',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    // Add request interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // You can add auth token here if needed
          // final token = await getToken();
          // options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          print('API Error: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }
  
  /// Make a GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      // Log error and rethrow
      print('GET request error: $e');
      rethrow;
    }
  }
  
  /// Make a POST request
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      // Log error and rethrow
      print('POST request error: $e');
      rethrow;
    }
  }
  
  /// Make a PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } catch (e) {
      // Log error and rethrow
      print('PUT request error: $e');
      rethrow;
    }
  }
  
  /// Make a DELETE request
  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } catch (e) {
      // Log error and rethrow
      print('DELETE request error: $e');
      rethrow;
    }
  }
} 
