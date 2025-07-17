// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/errors/app_exception.dart';
import 'package:ray_club_app/features/benefits/models/benefit.dart';
import 'package:ray_club_app/features/benefits/models/redeemed_benefit.dart';
import 'package:ray_club_app/features/benefits/repositories/supabase_benefit_repository.dart';
import 'supabase_benefit_repository_test.mocks.dart';

@GenerateMocks([SupabaseClient, GoTrueClient, PostgrestClient, PostgrestFilterBuilder])

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGotrueClient mockGotrueClient;
  late MockPostgrestClient mockPostgrestClient;
  late MockPostgrestFilterBuilder mockFilterBuilder;
  late SupabaseBenefitRepository repository;

  const String usersTable = 'users';
  const String benefitsTable = 'benefits';
  const String redeemedBenefitsTable = 'redeemed_benefits';
  
  final DateTime expirationDate = DateTime.now().add(const Duration(days: 7));
  
  // Mock user data
  final mockUser = User(
    id: 'test-user-id',
    appMetadata: {},
    userMetadata: {},
    aud: 'authenticated',
    createdAt: DateTime.now().toString(),
  );
  
  final mockAdminUserResponse = {
    'is_admin': true
  };
  
  final mockNonAdminUserResponse = {
    'is_admin': false
  };
  
  final mockBenefitData = {
    'id': 'benefit-1',
    'title': 'Test Benefit',
    'description': 'Test Description',
    'partner': 'Test Partner',
    'expires_at': expirationDate.toIso8601String(),
  };
  
  final mockRedeemedBenefitData = {
    'id': 'redeemed-1',
    'benefit_id': 'benefit-1',
    'user_id': 'test-user-id',
    'redeemed_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    'redemption_code': 'CODE123',
    'status': 'active',
    'expires_at': expirationDate.toIso8601String(),
  };

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGotrueClient = MockGotrueClient();
    mockPostgrestClient = MockPostgrestClient();
    mockFilterBuilder = MockPostgrestFilterBuilder();
    
    repository = SupabaseBenefitRepository(supabaseClient: mockSupabaseClient);
    
    // Setup common mocks
    when(mockSupabaseClient.auth).thenReturn(mockGotrueClient);
    when(mockGotrueClient.currentUser).thenReturn(mockUser);
    when(mockSupabaseClient.from(any)).thenReturn(mockPostgrestClient);
  });

  group('isAdmin', () {
    test('returns true when user is admin', () async {
      // Arrange
      when(mockPostgrestClient.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockAdminUserResponse);
      
      // Act
      final result = await repository.isAdmin();
      
      // Assert
      expect(result, true);
      verify(mockSupabaseClient.from(usersTable)).called(1);
    });
    
    test('returns false when user is not admin', () async {
      // Arrange
      when(mockPostgrestClient.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockNonAdminUserResponse);
      
      // Act
      final result = await repository.isAdmin();
      
      // Assert
      expect(result, false);
      verify(mockSupabaseClient.from(usersTable)).called(1);
    });
    
    test('returns false when user data not found', () async {
      // Arrange
      when(mockPostgrestClient.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => null);
      
      // Act
      final result = await repository.isAdmin();
      
      // Assert
      expect(result, false);
    });
    
    test('returns false when error occurs', () async {
      // Arrange
      when(mockPostgrestClient.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenThrow(Exception('Database error'));
      
      // Act
      final result = await repository.isAdmin();
      
      // Assert
      expect(result, false);
    });
  });
  
  group('updateBenefitExpiration', () {
    test('throws AuthException when user is not admin', () async {
      // Arrange - mock user is not admin
      when(mockPostgrestClient.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockNonAdminUserResponse);
      
      // Act & Assert
      expect(
        () => repository.updateBenefitExpiration('benefit-1', expirationDate),
        throwsA(isA<AuthException>().having(
          (e) => e.code, 
          'code', 
          'permission_denied'
        )),
      );
    });
    
    test('updates benefit expiration when user is admin', () async {
      // Arrange - mock user is admin
      when(mockPostgrestClient.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq(any, any)).thenReturn(mockFilterBuilder);
      
      // For admin check
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockAdminUserResponse);
      
      // For update operation
      when(mockPostgrestClient.update(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockBenefitData);
      
      // Act
      final result = await repository.updateBenefitExpiration('benefit-1', expirationDate);
      
      // Assert
      expect(result, isA<Benefit>());
      expect(result?.id, 'benefit-1');
      verify(mockSupabaseClient.from(benefitsTable)).called(1);
      verify(mockPostgrestClient.update({
        'expires_at': expirationDate.toIso8601String(),
      })).called(1);
    });
    
    test('returns null when benefit not found', () async {
      // Arrange - mock user is admin
      when(mockPostgrestClient.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq(any, any)).thenReturn(mockFilterBuilder);
      
      // For admin check
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockAdminUserResponse);
      
      // For update operation
      when(mockPostgrestClient.update(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      
      // Second call to maybeSingle returns null (no benefit found)
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockAdminUserResponse)
                                          .thenAnswer((_) async => null);
      
      // Act
      final result = await repository.updateBenefitExpiration('benefit-1', expirationDate);
      
      // Assert
      expect(result, isNull);
    });
  });
  
  group('extendRedeemedBenefitExpiration', () {
    test('throws AuthException when user is not admin', () async {
      // Arrange - mock user is not admin
      when(mockPostgrestClient.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockNonAdminUserResponse);
      
      // Act & Assert
      expect(
        () => repository.extendRedeemedBenefitExpiration('redeemed-1', expirationDate),
        throwsA(isA<AuthException>().having(
          (e) => e.code, 
          'code', 
          'permission_denied'
        )),
      );
    });
    
    test('extends redeemed benefit expiration and reactivates expired benefit', () async {
      // Arrange - mock user is admin
      when(mockPostgrestClient.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq(any, any)).thenReturn(mockFilterBuilder);
      
      // First call for admin check
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockAdminUserResponse);
      
      // Second call for current benefit check (expired benefit)
      final expiredBenefit = {
        ...mockRedeemedBenefitData,
        'status': 'expired'
      };
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockAdminUserResponse)
                                           .thenAnswer((_) async => expiredBenefit);
      
      // For update operation
      when(mockPostgrestClient.update(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.select()).thenReturn(mockFilterBuilder);
      
      // Updated benefit result
      final updatedBenefit = {
        ...mockRedeemedBenefitData,
        'status': 'active',
        'expires_at': expirationDate.toIso8601String()
      };
      when(mockFilterBuilder.single()).thenAnswer((_) async => updatedBenefit);
      
      // Act
      final result = await repository.extendRedeemedBenefitExpiration('redeemed-1', expirationDate);
      
      // Assert
      expect(result, isA<RedeemedBenefit>());
      expect(result?.id, 'redeemed-1');
      expect(result?.status, RedemptionStatus.active); // Should be reactivated
      verify(mockSupabaseClient.from(redeemedBenefitsTable)).called(1);
      verify(mockPostgrestClient.update({
        'expires_at': expirationDate.toIso8601String(),
        'status': 'active', // Should update status to active
      })).called(1);
    });
  });
  
  group('getAllRedeemedBenefits', () {
    test('throws AuthException when user is not admin', () async {
      // Arrange - mock user is not admin
      when(mockPostgrestClient.select(any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('id', any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockNonAdminUserResponse);
      
      // Act & Assert
      expect(
        () => repository.getAllRedeemedBenefits(),
        throwsA(isA<AuthException>().having(
          (e) => e.code, 
          'code', 
          'permission_denied'
        )),
      );
    });
    
    test('returns all redeemed benefits when user is admin', () async {
      // Arrange - mock user is admin
      when(mockPostgrestClient.select()).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq(any, any)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => mockAdminUserResponse);
      
      // For get all operation
      when(mockFilterBuilder.order(any, ascending: anyNamed('ascending'))).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder).thenAnswer((_) async => [mockRedeemedBenefitData, mockRedeemedBenefitData]);
      
      // Act
      final result = await repository.getAllRedeemedBenefits();
      
      // Assert
      expect(result, isA<List<RedeemedBenefit>>());
      expect(result.length, 2);
      verify(mockSupabaseClient.from(redeemedBenefitsTable)).called(1);
    });
  });
} 
