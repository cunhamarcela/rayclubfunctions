// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:ray_club_app/features/goals/models/water_intake_model.dart';
import 'package:ray_club_app/features/goals/repositories/water_intake_repository.dart';
import 'package:ray_club_app/features/goals/viewmodels/water_view_model.dart';

// Generate mocks
@GenerateMocks([SupabaseWaterIntakeRepository])
import 'water_view_model_test.mocks.dart';

void main() {
  late MockSupabaseWaterIntakeRepository mockRepository;
  late WaterViewModel viewModel;
  const testUserId = 'test-user-id';

  setUp(() {
    mockRepository = MockSupabaseWaterIntakeRepository();
    viewModel = WaterViewModel(mockRepository, testUserId);
  });

  group('WaterViewModel Tests', () {
    final testDate = DateTime(2023, 5, 15);
    final testWaterIntake = WaterIntake(
      id: '1',
      userId: testUserId,
      date: testDate,
      currentGlasses: 3,
      dailyGoal: 8,
      createdAt: testDate,
      updatedAt: testDate,
    );

    test('loadWaterIntake should load water intake data', () async {
      // Arrange
      when(mockRepository.getWaterIntakeByDate(any))
          .thenAnswer((_) async => testWaterIntake);

      // Act
      await viewModel.loadWaterIntake();

      // Assert
      expect(viewModel.state.waterIntake, equals(testWaterIntake));
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.errorMessage, isNull);
      verify(mockRepository.getWaterIntakeByDate(any)).called(1);
    });

    test('addGlass should increment water intake and persist to Supabase', () async {
      // Arrange
      when(mockRepository.getWaterIntakeByDate(any))
          .thenAnswer((_) async => testWaterIntake);
      
      final updatedWaterIntake = testWaterIntake.copyWith(
        cups: testWaterIntake.currentGlasses + 1,
        updatedAt: DateTime.now(),
      );
      
      when(mockRepository.insertOrUpdateWaterIntake(
        userId: testUserId,
        date: any,
        cups: testWaterIntake.currentGlasses + 1,
        goal: testWaterIntake.dailyGoal,
        notes: any,
      )).thenAnswer((_) async => updatedWaterIntake);

      // Load initial data
      await viewModel.loadWaterIntake();

      // Act
      await viewModel.addGlass();

      // Assert
      expect(viewModel.state.waterIntake!.currentGlasses, equals(testWaterIntake.currentGlasses + 1));
      verify(mockRepository.insertOrUpdateWaterIntake(
        userId: testUserId,
        date: any,
        cups: testWaterIntake.currentGlasses + 1,
        goal: testWaterIntake.dailyGoal,
        notes: any,
      )).called(1);
    });

    test('removeGlass should decrement water intake and persist to Supabase', () async {
      // Arrange
      when(mockRepository.getWaterIntakeByDate(any))
          .thenAnswer((_) async => testWaterIntake);
      
      final updatedWaterIntake = testWaterIntake.copyWith(
        cups: testWaterIntake.currentGlasses - 1,
        updatedAt: DateTime.now(),
      );
      
      when(mockRepository.insertOrUpdateWaterIntake(
        userId: testUserId,
        date: any,
        cups: testWaterIntake.currentGlasses - 1,
        goal: testWaterIntake.dailyGoal,
        notes: any,
      )).thenAnswer((_) async => updatedWaterIntake);

      // Load initial data
      await viewModel.loadWaterIntake();

      // Act
      await viewModel.removeGlass();

      // Assert
      expect(viewModel.state.waterIntake!.currentGlasses, equals(testWaterIntake.currentGlasses - 1));
      verify(mockRepository.insertOrUpdateWaterIntake(
        userId: testUserId,
        date: any,
        cups: testWaterIntake.currentGlasses - 1,
        goal: testWaterIntake.dailyGoal,
        notes: any,
      )).called(1);
    });

    test('updateGoal should update goal and persist to Supabase', () async {
      // Arrange
      when(mockRepository.getWaterIntakeByDate(any))
          .thenAnswer((_) async => testWaterIntake);
      
      const newGoal = 10;
      final updatedWaterIntake = testWaterIntake.copyWith(
        goal: newGoal,
        updatedAt: DateTime.now(),
      );
      
      when(mockRepository.insertOrUpdateWaterIntake(
        userId: testUserId,
        date: any,
        cups: testWaterIntake.currentGlasses,
        goal: newGoal,
        notes: any,
      )).thenAnswer((_) async => updatedWaterIntake);

      // Load initial data
      await viewModel.loadWaterIntake();

      // Act
      await viewModel.updateGoal(newGoal);

      // Assert
      expect(viewModel.state.waterIntake!.dailyGoal, equals(newGoal));
      verify(mockRepository.insertOrUpdateWaterIntake(
        userId: testUserId,
        date: any,
        cups: testWaterIntake.currentGlasses,
        goal: newGoal,
        notes: any,
      )).called(1);
    });
  });
} 