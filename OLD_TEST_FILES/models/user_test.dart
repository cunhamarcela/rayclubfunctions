// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:ray_club_app/models/user.dart';

void main() {
  group('User Model Tests', () {
    final testDate = DateTime(2024);
    final testJson = {
      'id': '123',
      'email': 'test@example.com',
      'name': 'Test User',
      'avatarUrl': 'https://example.com/avatar.jpg',
      'createdAt': '2024-01-01T00:00:00.000Z',
      'lastLoginAt': '2024-01-02T00:00:00.000Z',
      'metadata': {'key': 'value'},
    };

    test('should create User from json', () {
      final user = User.fromJson(testJson);

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.metadata?['key'], 'value');
      expect(user.createdAt, isA<DateTime>());
      expect(user.lastLoginAt, isA<DateTime>());
    });

    test('should convert User to json', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        avatarUrl: 'https://example.com/avatar.jpg',
        createdAt: testDate,
        lastLoginAt: testDate.add(const Duration(days: 1)),
        metadata: {'key': 'value'},
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['email'], 'test@example.com');
      expect(json['name'], 'Test User');
      expect(json['avatarUrl'], 'https://example.com/avatar.jpg');
      expect(json['metadata']['key'], 'value');
      expect(json['createdAt'], isA<String>());
      expect(json['lastLoginAt'], isA<String>());
    });

    test('should copy User with new values', () {
      final user = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: testDate,
      );

      final updatedUser = user.copyWith(
        name: 'New Name',
        avatarUrl: 'https://example.com/new.jpg',
      );

      expect(updatedUser.id, user.id);
      expect(updatedUser.email, user.email);
      expect(updatedUser.name, 'New Name');
      expect(updatedUser.avatarUrl, 'https://example.com/new.jpg');
      expect(updatedUser.createdAt, user.createdAt);
    });

    test('should implement equality', () {
      final user1 = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: testDate,
      );

      final user2 = User(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: testDate,
      );

      final user3 = User(
        id: '456',
        email: 'test@example.com',
        name: 'Test User',
        createdAt: testDate,
      );

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
      expect(user1.hashCode, equals(user2.hashCode));
      expect(user1.hashCode, isNot(equals(user3.hashCode)));
    });
  });
}
