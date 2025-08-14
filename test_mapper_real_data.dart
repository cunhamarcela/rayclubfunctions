import 'dart:convert';
import 'package:ray_club_app/features/goals/models/user_goal_mapper.dart';

void main() {
  // Dados reais vindos do Supabase (baseado no que você mostrou)
  final realSupabaseData = {
    'id': 'c73e33a0-695c-4e97-9188-e534bf89a148',
    'user_id': 'some-user-id', // Assumindo que tem um user_id
    'title': 'Meta de Teste - Treinar 3x por semana',
    'target_value': 3.0,
    'current_value': 2.0,
    'unit': 'treinos',
    'goal_type': 'workout',
    'is_completed': false,
    'progress_percentage': 66.66666666666666666700,
    'created_at': '2025-07-18T01:03:21.904704-03:00',
    'updated_at': '2025-07-18T01:04:39.498099-03:00',
    'start_date': '2025-07-18T01:03:21.904704-03:00',
    'target_date': null,
  };

  try {
    print('🔍 Testando mapeamento com dados REAIS do Supabase...');
    print('📊 Dados recebidos: ${jsonEncode(realSupabaseData)}');
    
    final goal = UserGoalMapper.fromSupabaseJson(realSupabaseData);
    
    print('✅ Mapeamento bem-sucedido!');
    print('📋 Meta mapeada:');
    print('   ID: ${goal.id}');
    print('   Título: ${goal.title}');
    print('   Target: ${goal.target}');
    print('   Progress: ${goal.progress}');
    print('   Unit: ${goal.unit}');
    print('   Type: ${goal.type}');
    print('   Completed: ${goal.completedAt != null}');
    
    // Teste de conversão de volta para JSON
    final backToJson = UserGoalMapper.toSupabaseJson(goal);
    print('📤 Conversão de volta para Supabase: ${jsonEncode(backToJson)}');
    
  } catch (e, stackTrace) {
    print('❌ Erro no mapeamento: $e');
    print('🔍 Stack trace: $stackTrace');
  }
} 