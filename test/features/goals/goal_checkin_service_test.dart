// Flutter imports:
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/features/goals/services/goal_checkin_service.dart';
import 'package:ray_club_app/core/errors/app_exception.dart';

@GenerateMocks([SupabaseClient, SupabaseQueryBuilder])
import 'goal_checkin_service_test.mocks.dart';

/// **TESTES DO GOAL CHECKIN SERVICE**
/// 
/// **Data:** 30 de Janeiro de 2025 às 17:20
/// **Objetivo:** Testar serviço de check-ins manuais para metas
void main() {
  group('GoalCheckinService', () {
    late MockSupabaseClient mockSupabase;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late GoalCheckinService service;

    setUp(() {
      mockSupabase = MockSupabaseClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      service = GoalCheckinService(mockSupabase);
    });

    group('registerCheckin', () {
      test('deve registrar check-in com sucesso', () async {
        // Arrange
        when(mockSupabase.rpc('register_goal_checkin', params: anyNamed('params')))
            .thenAnswer((_) async => true);

        // Act
        final result = await service.registerCheckin(
          goalId: 'goal123',
          userId: 'user123',
        );

        // Assert
        expect(result, isTrue);
        verify(mockSupabase.rpc('register_goal_checkin', params: {
          'p_goal_id': 'goal123',
          'p_user_id': 'user123',
        })).called(1);
      });

      test('deve retornar false quando check-in não é possível', () async {
        // Arrange
        when(mockSupabase.rpc('register_goal_checkin', params: anyNamed('params')))
            .thenAnswer((_) async => false);

        // Act
        final result = await service.registerCheckin(
          goalId: 'goal123',
          userId: 'user123',
        );

        // Assert
        expect(result, isFalse);
      });

      test('deve lançar AppException em caso de erro', () async {
        // Arrange
        when(mockSupabase.rpc('register_goal_checkin', params: anyNamed('params')))
            .thenThrow(Exception('Erro de conexão'));

        // Act & Assert
        expect(
          () => service.registerCheckin(goalId: 'goal123', userId: 'user123'),
          throwsA(isA<AppException>()),
        );
      });
    });

    group('getGoalProgress', () {
      test('deve retornar progresso da meta', () async {
        // Arrange
        final mockData = {
          'id': 'goal123',
          'title': 'Meta Teste',
          'target': 7.0,
          'progress': 3.0,
          'measurement_type': 'days',
          'completed_at': null,
        };

        when(mockSupabase.from('user_goals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.maybeSingle()).thenAnswer((_) async => mockData);

        // Act
        final result = await service.getGoalProgress(
          goalId: 'goal123',
          userId: 'user123',
        );

        // Assert
        expect(result, isNotNull);
        expect(result!['title'], equals('Meta Teste'));
        expect(result['progress'], equals(3.0));
        expect(result['measurement_type'], equals('days'));
      });

      test('deve retornar null em caso de erro', () async {
        // Arrange
        when(mockSupabase.from('user_goals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.maybeSingle()).thenThrow(Exception('Erro'));

        // Act
        final result = await service.getGoalProgress(
          goalId: 'goal123',
          userId: 'user123',
        );

        // Assert
        expect(result, isNull);
      });
    });

    group('canCheckin', () {
      test('deve retornar true para meta válida em dias', () async {
        // Arrange
        final mockData = {
          'measurement_type': 'days',
          'completed_at': null,
          'progress': 3.0,
          'target': 7.0,
        };

        when(mockSupabase.from('user_goals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.maybeSingle()).thenAnswer((_) async => mockData);

        // Act
        final result = await service.canCheckin(
          goalId: 'goal123',
          userId: 'user123',
        );

        // Assert
        expect(result, isTrue);
      });

      test('deve retornar false para meta em minutos', () async {
        // Arrange
        final mockData = {
          'measurement_type': 'minutes',
          'completed_at': null,
          'progress': 50.0,
          'target': 150.0,
        };

        when(mockSupabase.from('user_goals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.maybeSingle()).thenAnswer((_) async => mockData);

        // Act
        final result = await service.canCheckin(
          goalId: 'goal123',
          userId: 'user123',
        );

        // Assert
        expect(result, isFalse);
      });

      test('deve retornar false para meta já concluída', () async {
        // Arrange
        final mockData = {
          'measurement_type': 'days',
          'completed_at': '2025-01-30T17:00:00Z',
          'progress': 7.0,
          'target': 7.0,
        };

        when(mockSupabase.from('user_goals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.maybeSingle()).thenAnswer((_) async => mockData);

        // Act
        final result = await service.canCheckin(
          goalId: 'goal123',
          userId: 'user123',
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('getCheckinStats', () {
      test('deve retornar estatísticas corretas', () async {
        // Arrange
        final mockData = [
          {
            'id': 'goal1',
            'progress': 7.0,
            'target': 7.0,
            'completed_at': '2025-01-30T17:00:00Z',
          },
          {
            'id': 'goal2',
            'progress': 3.0,
            'target': 5.0,
            'completed_at': null,
          },
        ];

        when(mockSupabase.from('user_goals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.gte(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.lte(any, any)).thenAnswer((_) async => mockData);

        // Act
        final result = await service.getCheckinStats(userId: 'user123');

        // Assert
        expect(result['total_goals'], equals(2));
        expect(result['completed_goals'], equals(1));
        expect(result['total_checkins'], equals(10)); // 7 + 3
        expect(result['completion_rate'], equals(50)); // 1/2 = 50%
      });

      test('deve retornar zeros em caso de erro', () async {
        // Arrange
        when(mockSupabase.from('user_goals')).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.eq(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.gte(any, any)).thenReturn(mockQueryBuilder);
        when(mockQueryBuilder.lte(any, any)).thenThrow(Exception('Erro'));

        // Act
        final result = await service.getCheckinStats(userId: 'user123');

        // Assert
        expect(result['total_goals'], equals(0));
        expect(result['completed_goals'], equals(0));
        expect(result['total_checkins'], equals(0));
        expect(result['completion_rate'], equals(0));
      });
    });
  });
}

