import 'package:flutter/foundation.dart';

class FlowTrace {
  static void log(String tag, String message, [dynamic data]) {
    final now = DateTime.now().toIso8601String();
    final formatted = '💡 [$tag][$now] $message';

    debugPrint(formatted);
    if (data != null) debugPrint('📦 Dados: ${_formatData(data)}');
  }

  static String _formatData(dynamic data) {
    try {
      return data.toString();
    } catch (e) {
      return 'Erro ao formatar dados: $e';
    }
  }
}