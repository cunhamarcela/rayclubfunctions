import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/foundation.dart';
import 'package:ray_club_app/features/auth/models/user.dart';
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/challenges/models/challenge.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group.dart';
import 'package:ray_club_app/features/challenges/models/challenge_group_invite.dart';
import 'package:ray_club_app/features/challenges/repositories/challenge_repository.dart';
import 'package:ray_club_app/features/challenges/viewmodels/challenge_group_view_model.dart';
import 'package:ray_club_app/core/services/supabase_service.dart';
import 'package:ray_club_app/core/services/auth_service.dart';

// Mocks
class MockChallengeRepository extends Mock implements ChallengeRepository {}
class MockAuthService extends Mock implements AuthService {}
class MockSupabaseService extends Mock implements SupabaseService {}

void main() {
  late ChallengeGroupViewModel viewModel;
  late MockSupabaseService mockSupabaseService;
  late MockAuthService mockAuthService;

  setUp(() {
    mockSupabaseService = MockSupabaseService();
    mockAuthService = MockAuthService();
    viewModel = ChallengeGroupViewModel(mockSupabaseService, mockAuthService);
  });

  group('ChallengeGroupViewModel Tests', () {
    test('initial state is correct', () {
      expect(viewModel.state.groups, isEmpty);
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, isNull);
    });

    test('loadUserGroups with no user shows error', () async {
      // Arrange
      when(() => mockAuthService.currentUser).thenReturn(null);
      
      // Act
      await viewModel.loadUserGroups();
      
      // Assert
      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.errorMessage, 'Usuário não autenticado');
    });
  });
} 