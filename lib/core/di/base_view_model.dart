// Flutter imports:
import 'package:flutter/foundation.dart';

/// Base class for all ViewModels in the app
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  /// Whether the ViewModel is currently loading data
  bool get isLoading => _isLoading;

  /// The current error message, if any
  String? get error => _error;

  /// Set the loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set an error message
  void setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Clear any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Handle an async operation with loading state and error handling
  Future<T?> handleAsync<T>(Future<T> Function() action) async {
    try {
      setLoading(true);
      clearError();
      final result = await action();
      return result;
    } catch (e) {
      setError(e.toString());
      return null;
    } finally {
      setLoading(false);
    }
  }

  Future<void> initialize();

  @override
  void dispose() {
    _error = null;
    super.dispose();
  }
}
