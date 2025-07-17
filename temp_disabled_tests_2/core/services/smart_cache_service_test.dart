// Dart imports:
import 'dart:convert';
import 'dart:typed_data';

// Flutter imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:ray_club_app/core/services/smart_cache_service.dart';

// Generated mocks
import 'smart_cache_service_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences mockPrefs;
  late SmartCacheService cacheService;
  
  setUp(() {
    mockPrefs = MockSharedPreferences();
    cacheService = SmartCacheService(mockPrefs);
  });
  
  group('SmartCacheService', () {
    group('set and get', () {
      test('should store and retrieve string data', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        final metaDataKey = 'cache_meta_$key';
        final dataKey = 'cache_data_$key';
        final updateKey = 'cache_update_$key';
        
        when(mockPrefs.setString(metaDataKey, any)).thenAnswer((_) async => true);
        when(mockPrefs.setString(dataKey, any)).thenAnswer((_) async => true);
        when(mockPrefs.setString(updateKey, any)).thenAnswer((_) async => true);
        
        // Act
        final result = await cacheService.set(key, value);
        
        // Assert
        expect(result, isTrue);
        
        // Verify metadata was stored
        verify(mockPrefs.setString(metaDataKey, any)).called(1);
        verify(mockPrefs.setString(dataKey, value)).called(1);
        verify(mockPrefs.setString(updateKey, any)).called(1);
      });
      
      test('should store and retrieve complex data through json serialization', () async {
        // Arrange
        const key = 'test_complex_key';
        final value = {'name': 'test', 'value': 42, 'items': [1, 2, 3]};
        final metaDataKey = 'cache_meta_$key';
        final dataKey = 'cache_data_$key';
        final updateKey = 'cache_update_$key';
        
        // Setup mock
        when(mockPrefs.setString(metaDataKey, any)).thenAnswer((_) async => true);
        when(mockPrefs.setString(dataKey, any)).thenAnswer((_) async => true);
        when(mockPrefs.setString(updateKey, any)).thenAnswer((_) async => true);
        
        // Act
        final result = await cacheService.set(key, value);
        
        // Assert
        expect(result, isTrue);
        
        // Verify json was stored
        verify(mockPrefs.setString(metaDataKey, any)).called(1);
        verify(mockPrefs.setString(dataKey, jsonEncode(value))).called(1);
        verify(mockPrefs.setString(updateKey, any)).called(1);
      });
      
      test('should retrieve data from memory cache without accessing disk', () async {
        // Arrange
        const key = 'test_memory_key';
        const value = 'memory_value';
        
        // Put the value in memory cache
        await cacheService.set(key, value);
        
        // Reset the mock to verify no calls
        reset(mockPrefs);
        
        // Act
        final result = await cacheService.get(key);
        
        // Assert
        expect(result, equals(value));
        
        // Verify no shared prefs access
        verifyNever(mockPrefs.getString(any));
      });
      
      test('should retrieve data from disk cache when not in memory', () async {
        // Arrange
        const key = 'test_disk_key';
        const value = 'disk_value';
        final metaDataKey = 'cache_meta_$key';
        final dataKey = 'cache_data_$key';
        
        // Setup metadata
        final metadata = {
          'key': key,
          'value_type': 'string',
          'storage_type': 'prefs',
          'created_at': DateTime.now().toIso8601String(),
        };
        
        // Configure mocks
        when(mockPrefs.getString(metaDataKey)).thenReturn(jsonEncode(metadata));
        when(mockPrefs.getString(dataKey)).thenReturn(value);
        
        // Act
        final result = await cacheService.get(key);
        
        // Assert
        expect(result, equals(value));
        
        // Verify disk access
        verify(mockPrefs.getString(metaDataKey)).called(1);
        verify(mockPrefs.getString(dataKey)).called(1);
      });
    });
    
    group('expiry', () {
      test('should respect expiry time in memory cache', () async {
        // Arrange
        const key = 'test_expiry_key';
        const value = 'expirable_value';
        
        // Put value in cache with immediate expiry
        await cacheService.set(key, value, expiry: const Duration(milliseconds: 1));
        
        // Wait for expiry
        await Future.delayed(const Duration(milliseconds: 5));
        
        // Act
        final result = await cacheService.get(key);
        
        // Assert
        expect(result, isNull);
      });
      
      test('should check expiry when retrieving from disk', () async {
        // Arrange
        const key = 'test_disk_expiry_key';
        final metaDataKey = 'cache_meta_$key';
        
        // Expired metadata
        final expiredTime = DateTime.now().subtract(const Duration(hours: 1));
        final metadata = {
          'key': key,
          'value_type': 'string',
          'storage_type': 'prefs',
          'created_at': DateTime.now().toIso8601String(),
          'expires_at': expiredTime.toIso8601String(),
        };
        
        // Configure mocks
        when(mockPrefs.getString(metaDataKey)).thenReturn(jsonEncode(metadata));
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);
        
        // Act
        final result = await cacheService.get(key);
        
        // Assert
        expect(result, isNull);
        
        // Verify removal of expired item
        verify(mockPrefs.remove(any)).called(greaterThan(0));
      });
      
      test('isExpired should return true for expired items', () async {
        // Arrange
        const key = 'test_is_expired_key';
        final metaDataKey = 'cache_meta_$key';
        
        // Expired metadata
        final expiredTime = DateTime.now().subtract(const Duration(hours: 1));
        final metadata = {
          'key': key,
          'value_type': 'string',
          'storage_type': 'prefs',
          'created_at': DateTime.now().toIso8601String(),
          'expires_at': expiredTime.toIso8601String(),
        };
        
        // Configure mocks
        when(mockPrefs.getString(metaDataKey)).thenReturn(jsonEncode(metadata));
        
        // Act
        final isExpired = await cacheService.isExpired(key);
        
        // Assert
        expect(isExpired, isTrue);
      });
      
      test('isExpired should return false for non-expired items', () async {
        // Arrange
        const key = 'test_not_expired_key';
        final metaDataKey = 'cache_meta_$key';
        
        // Non-expired metadata
        final futureTime = DateTime.now().add(const Duration(hours: 1));
        final metadata = {
          'key': key,
          'value_type': 'string',
          'storage_type': 'prefs',
          'created_at': DateTime.now().toIso8601String(),
          'expires_at': futureTime.toIso8601String(),
        };
        
        // Configure mocks
        when(mockPrefs.getString(metaDataKey)).thenReturn(jsonEncode(metadata));
        
        // Act
        final isExpired = await cacheService.isExpired(key);
        
        // Assert
        expect(isExpired, isFalse);
      });
    });
    
    group('remove and clear', () {
      test('should remove item from cache', () async {
        // Arrange
        const key = 'test_remove_key';
        const value = 'removable_value';
        
        // Put value in cache
        await cacheService.set(key, value);
        
        // Configure mocks for removal
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);
        
        // Act
        final removeResult = await cacheService.remove(key);
        final getResult = await cacheService.get(key);
        
        // Assert
        expect(removeResult, isTrue);
        expect(getResult, isNull);
        
        // Verify removals
        verify(mockPrefs.remove(any)).called(greaterThan(0));
      });
      
      test('should clear all cache items', () async {
        // Arrange
        await cacheService.set('key1', 'value1');
        await cacheService.set('key2', 'value2');
        
        // Configure mocks
        when(mockPrefs.getKeys()).thenReturn({'cache_key1', 'cache_key2'});
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);
        
        // Act
        final result = await cacheService.clear();
        
        // Assert
        expect(result, isTrue);
        
        // Verify all keys were queried and all items removed
        verify(mockPrefs.getKeys()).called(1);
        verify(mockPrefs.remove(any)).called(greaterThan(0));
        
        // Check items are gone from memory cache
        expect(await cacheService.get('key1'), isNull);
        expect(await cacheService.get('key2'), isNull);
      });
    });
    
    group('object lists', () {
      test('should store and retrieve list of objects', () async {
        // Arrange
        const key = 'test_object_list';
        final testObjects = [
          _TestObject(id: 1, name: 'Object 1'),
          _TestObject(id: 2, name: 'Object 2'),
          _TestObject(id: 3, name: 'Object 3'),
        ];
        
        // Mock set operation
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        
        // Act - store
        await cacheService.setObjectList<_TestObject>(
          key,
          testObjects,
          fromJson: _TestObject.fromJson,
          toJson: (obj) => obj.toJson(),
        );
        
        // Verify objects were stored
        verify(mockPrefs.setString(any, any)).called(greaterThan(0));
        
        // Reset mock for get
        reset(mockPrefs);
        
        // Mock retrieval from memory cache
        final result = await cacheService.getObjectList<_TestObject>(
          key,
          fromJson: _TestObject.fromJson,
        );
        
        // Assert
        expect(result, isNotNull);
        expect(result!.length, equals(testObjects.length));
        expect(result[0].id, equals(testObjects[0].id));
        expect(result[1].name, equals(testObjects[1].name));
        
        // Verify no shared prefs access (from memory)
        verifyNever(mockPrefs.getString(any));
      });
    });
    
    group('lastCacheUpdate', () {
      test('should get last update time for cache key', () async {
        // Arrange
        const key = 'test_update_time';
        final updateKey = 'cache_update_$key';
        final updateTime = DateTime.now();
        
        // Configure mock
        when(mockPrefs.getString(updateKey))
            .thenReturn(updateTime.toIso8601String());
        
        // Act
        final result = await cacheService.getLastCacheUpdate(key);
        
        // Assert
        expect(result, isNotNull);
        expect(result!.year, equals(updateTime.year));
        expect(result.month, equals(updateTime.month));
        expect(result.day, equals(updateTime.day));
        expect(result.hour, equals(updateTime.hour));
        
        // Verify
        verify(mockPrefs.getString(updateKey)).called(1);
      });
    });
  });
}

/// Test object for serialization tests
class _TestObject {
  final int id;
  final String name;
  
  _TestObject({required this.id, required this.name});
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
  
  factory _TestObject.fromJson(Map<String, dynamic> json) => _TestObject(
    id: json['id'],
    name: json['name'],
  );
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestObject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
} 