import 'flow_trace.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DebugInspector {
  final SupabaseClient client;

  DebugInspector(this.client);

  Future<void> printUserProfile(String userId) async {
    final response = await client
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .single();

    FlowTrace.log('🔎 USER_PROFILE', 'Dados do usuário carregados', response);
  }

  Future<void> printChallengeProgress(String userId) async {
    final response = await client
        .from('challenge_progress')
        .select()
        .eq('user_id', userId);

    FlowTrace.log('🏁 PROGRESS', 'Progresso nos desafios', response);
  }

  Future<void> printWorkoutRecords(String userId) async {
    final response = await client
        .from('workout_records')
        .select()
        .eq('user_id', userId);

    FlowTrace.log('🏋️ WORKOUTS', 'Treinos registrados', response);
  }
}