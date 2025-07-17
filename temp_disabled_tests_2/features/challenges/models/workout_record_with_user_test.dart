import 'package:flutter_test/flutter_test.dart';
import 'package:ray_club_app/features/challenges/models/workout_record_with_user.dart';

void main() {
  group('WorkoutRecordWithUser', () {
    test('should create a WorkoutRecordWithUser from valid JSON', () {
      // Arrange
      final json = {
        'id': 'workout-123',
        'user_id': 'user-123',
        'user_name': 'John Doe',
        'user_photo_url': 'https://example.com/photo.jpg',
        'workout_name': 'Morning Run',
        'workout_type': 'Running',
        'date': '2023-08-15T10:30:00.000Z',
        'duration_minutes': 45,
        'image_urls': ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        'notes': 'Great workout today!'
      };

      // Act
      final workoutRecord = WorkoutRecordWithUser.fromJson(json);

      // Assert
      expect(workoutRecord.id, 'workout-123');
      expect(workoutRecord.userId, 'user-123');
      expect(workoutRecord.userName, 'John Doe');
      expect(workoutRecord.userPhotoUrl, 'https://example.com/photo.jpg');
      expect(workoutRecord.workoutName, 'Morning Run');
      expect(workoutRecord.workoutType, 'Running');
      expect(workoutRecord.date.year, 2023);
      expect(workoutRecord.date.month, 8);
      expect(workoutRecord.date.day, 15);
      expect(workoutRecord.durationMinutes, 45);
      expect(workoutRecord.imageUrls, ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
      expect(workoutRecord.notes, 'Great workout today!');
    });

    test('should handle missing or null values with defaults', () {
      // Arrange
      final json = {
        'id': 'workout-123',
        'user_id': 'user-123',
        'date': '2023-08-15T10:30:00.000Z',
      };

      // Act
      final workoutRecord = WorkoutRecordWithUser.fromJson(json);

      // Assert
      expect(workoutRecord.id, 'workout-123');
      expect(workoutRecord.userId, 'user-123');
      expect(workoutRecord.userName, 'Usuário anônimo');
      expect(workoutRecord.userPhotoUrl, null);
      expect(workoutRecord.workoutName, 'Treino sem nome');
      expect(workoutRecord.workoutType, 'Outro');
      expect(workoutRecord.date.year, 2023);
      expect(workoutRecord.durationMinutes, 0);
      expect(workoutRecord.imageUrls, null);
      expect(workoutRecord.notes, null);
    });

    test('equality should compare by id and userId', () {
      // Arrange
      final workout1 = WorkoutRecordWithUser(
        id: 'workout-123',
        userId: 'user-123',
        userName: 'John',
        workoutName: 'Run',
        workoutType: 'Cardio',
        date: DateTime(2023, 8, 15),
        durationMinutes: 30,
      );

      final workout2 = WorkoutRecordWithUser(
        id: 'workout-123',
        userId: 'user-123',
        userName: 'Different Name',  // Different values but same ID
        workoutName: 'Different Workout',
        workoutType: 'Different Type',
        date: DateTime(2023, 9, 20),
        durationMinutes: 60,
      );

      final workout3 = WorkoutRecordWithUser(
        id: 'workout-456',  // Different ID
        userId: 'user-123',
        userName: 'John',
        workoutName: 'Run',
        workoutType: 'Cardio',
        date: DateTime(2023, 8, 15),
        durationMinutes: 30,
      );

      // Assert
      expect(workout1 == workout2, true);
      expect(workout1 == workout3, false);
      expect(workout1.hashCode == workout2.hashCode, true);
      expect(workout1.hashCode == workout3.hashCode, false);
    });
  });
} 