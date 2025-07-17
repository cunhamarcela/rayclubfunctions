import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../errors/app_exception.dart';
import '../providers/dio_provider.dart';
import '../providers/environment_provider.dart';

abstract class LoggingService {
  Future<void> logError(dynamic error, StackTrace? stackTrace, {String? context});
  Future<void> logEvent(String event, {Map<String, dynamic>? parameters});
  Future<void> logMetric({required String metricName, required double value, String? unit, Map<String, String>? dimensions});
}

// RemoteLoggingService implementation has been moved to /lib/services/remote_logging_service.dart
// This removes duplication and resolves ambiguity when importing RemoteLoggingService 