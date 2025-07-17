abstract class BaseService {
  bool get isInitialized;
  Future<void> initialize();
  Future<void> dispose();
}
