abstract class BaseRepository {
  Future<void> initialize();
  Future<void> clearCache();
  Future<void> dispose();
}
