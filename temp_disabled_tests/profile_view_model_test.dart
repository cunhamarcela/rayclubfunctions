// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:ray_club_app/features/auth/models/user.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/profile/repositories/profile_repository.dart';
import 'package:ray_club_app/features/profile/viewmodels/profile_state.dart';
import 'package:ray_club_app/features/profile/viewmodels/profile_view_model.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}
class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late ProfileViewModel viewModel;
  late MockProfileRepository mockRepository;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    mockAuthRepository = MockAuthRepository();
    
    // Setup default auth user
    when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => 
      User(
        id: 'test-user-id',
        email: 'test@example.com',
        name: 'Test User',
      )
    );
    
    viewModel = ProfileViewModel(
      repository: mockRepository,
      authRepository: mockAuthRepository,
    );
  });

  // group('ProfileViewModel', () {
    // test('initial state is correct', () {
      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.userProfile, isNull);
      expect(viewModel.state.errorMessage, isNull);
    });

    // group('loadUserProfile', () {
      // test('loads user profile successfully', () async {
        // Arrange
        final userProfile = UserProfile(
          id: 'test-user-id',
          displayName: 'Test User',
          email: 'test@example.com',
          photoUrl: 'https://example.com/photo.jpg',
          bio: 'Test bio',
          points: 100,
        );
        
        when(() => mockRepository.getUserProfile('test-user-id'))
            .thenAnswer((_) async => userProfile);
        
        // Act
        await viewModel.loadUserProfile();
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.userProfile, isNotNull);
        expect(viewModel.state.userProfile?.id, 'test-user-id');
        expect(viewModel.state.userProfile?.displayName, 'Test User');
        expect(viewModel.state.errorMessage, isNull);
        
        verify(() => mockRepository.getUserProfile('test-user-id')).called(1);
      });
      
      // test('handles error when loading profile fails', () async {
        // Arrange
        when(() => mockRepository.getUserProfile('test-user-id'))
            .thenThrow(Exception('Falha ao carregar perfil'));
        
        // Act
        await viewModel.loadUserProfile();
        
        // Assert
        expect(viewModel.state.isLoading, isFalse);
        expect(viewModel.state.userProfile, isNull);
        expect(viewModel.state.errorMessage, contains('Falha ao carregar perfil'));
        
        verify(() => mockRepository.getUserProfile('test-user-id')).called(1);
      });
    });
    
    // group('updateUserProfile', () {
      // test('updates user profile successfully', () async {
        // Arrange
        final updatedProfile = UserProfile(
          id: 'test-user-id',
          displayName: 'Updated Name',
          email: 'test@example.com',
          photoUrl: 'https://example.com/new-photo.jpg',
          bio: 'Updated bio',
          points: 100,
        );
        
        when(() => mockRepository.updateUserProfile(any))
            .thenAnswer((_) async => updatedProfile);
        
        // Act
        final result = await viewModel.updateUserProfile(updatedProfile);
        
        // Assert
        expect(result, isNotNull);
        expect(result.displayName, 'Updated Name');
        expect(result.bio, 'Updated bio');
        expect(viewModel.state.userProfile, isNotNull);
        expect(viewModel.state.userProfile?.displayName, 'Updated Name');
        expect(viewModel.state.successMessage, contains('Perfil atualizado com sucesso'));
        
        verify(() => mockRepository.updateUserProfile(any)).called(1);
      });
      
      // test('handles error when updating profile fails', () async {
        // Arrange
        final updatedProfile = UserProfile(
          id: 'test-user-id',
          displayName: 'Updated Name',
          email: 'test@example.com',
          photoUrl: 'https://example.com/new-photo.jpg',
          bio: 'Updated bio',
          points: 100,
        );
        
        when(() => mockRepository.updateUserProfile(any))
            .thenThrow(Exception('Falha ao atualizar perfil'));
        
        // Act & Assert
        expect(() => viewModel.updateUserProfile(updatedProfile), throwsException);
        
        verify(() => mockRepository.updateUserProfile(any)).called(1);
      });
    });
    
    // group('uploadProfilePhoto', () {
      // test('uploads profile photo successfully', () async {
        // Arrange
        final filePath = '/path/to/photo.jpg';
        final photoUrl = 'https://example.com/uploaded-photo.jpg';
        
        when(() => mockRepository.uploadProfilePhoto(
          userId: 'test-user-id',
          filePath: filePath,
        )).thenAnswer((_) async => photoUrl);
        
        when(() => mockRepository.updateUserProfile(any))
            .thenAnswer((invocation) async {
              final profile = invocation.positionalArguments[0] as UserProfile;
              return profile;
            });
        
        // Act
        final result = await viewModel.uploadProfilePhoto(filePath);
        
        // Assert
        expect(result, photoUrl);
        expect(viewModel.state.successMessage, contains('Foto de perfil atualizada com sucesso'));
        
        verify(() => mockRepository.uploadProfilePhoto(
          userId: 'test-user-id',
          filePath: filePath,
        )).called(1);
      });
      
      // test('handles error when uploading photo fails', () async {
        // Arrange
        final filePath = '/path/to/photo.jpg';
        
        when(() => mockRepository.uploadProfilePhoto(
          userId: 'test-user-id',
          filePath: filePath,
        )).thenThrow(Exception('Falha ao fazer upload da foto'));
        
        // Act & Assert
        expect(() => viewModel.uploadProfilePhoto(filePath), throwsException);
        
        verify(() => mockRepository.uploadProfilePhoto(
          userId: 'test-user-id',
          filePath: filePath,
        )).called(1);
        
        verifyNever(() => mockRepository.updateUserProfile(any));
      });
    });
    
    // group('getUserPoints', () {
      // test('gets user points successfully', () async {
        // Arrange
        when(() => mockRepository.getUserPoints('test-user-id'))
            .thenAnswer((_) async => 250);
        
        // Act
        final result = await viewModel.getUserPoints();
        
        // Assert
        expect(result, 250);
        
        verify(() => mockRepository.getUserPoints('test-user-id')).called(1);
      });
    });
    
    // group('getUserAchievements', () {
      // test('gets user achievements successfully', () async {
        // Arrange
        final achievements = [
          {
            'id': 'achievement-1',
            'title': 'First Workout',
            'description': 'Complete your first workout',
            'dateEarned': DateTime.now().toIso8601String(),
          },
          {
            'id': 'achievement-2',
            'title': 'Points Master',
            'description': 'Earn 100 points',
            'dateEarned': DateTime.now().toIso8601String(),
          },
        ];
        
        when(() => mockRepository.getUserAchievements('test-user-id'))
            .thenAnswer((_) async => achievements);
        
        // Act
        final result = await viewModel.getUserAchievements();
        
        // Assert
        expect(result.length, 2);
        expect(result[0]['id'], 'achievement-1');
        expect(result[1]['id'], 'achievement-2');
        expect(viewModel.state.achievements.length, 2);
        
        verify(() => mockRepository.getUserAchievements('test-user-id')).called(1);
      });
    });

    // group('deleteAccount', () {
      // test('should delete account successfully', () async {
        // Arrange
        final profile = Profile(
          id: 'test-user-1',
          name: 'Test User',
          email: 'test@example.com',
        );
        
        when(mockRepository.getCurrentUserProfile())
            .thenAnswer((_) async => profile);
        
        when(mockRepository.deleteAccount(any))
            .thenAnswer((_) async => {});
        
        // Act
        await viewModel.loadData();
        await viewModel.deleteAccount();
        
        // Assert
        verify(mockRepository.deleteAccount('test-user-1')).called(1);
        expect(viewModel.state, equals(const BaseState<Profile>.empty()));
      });
      
      // test('should handle errors when deleting account', () async {
        // Arrange
        final profile = Profile(
          id: 'test-user-1',
          name: 'Test User',
          email: 'test@example.com',
        );
        
        when(mockRepository.getCurrentUserProfile())
            .thenAnswer((_) async => profile);
        
        when(mockRepository.deleteAccount(any))
            .thenThrow(Exception('Failed to delete account'));
        
        // Act
        await viewModel.loadData();
        
        // Assert
        expect(() => viewModel.deleteAccount(), throwsException);
      });
      
      // test('should throw exception if profile is not loaded', () async {
        // Act & Assert
        expect(() => viewModel.deleteAccount(), throwsException);
      });
    });
  });
} 
