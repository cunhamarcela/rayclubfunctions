import 'package:supabase_flutter/supabase_flutter.dart';

// SCRIPT DE TESTE: Verificar por que Supabase retorna apenas 14 treinos em vez de 22
void main() async {
  // Configurar Supabase
  await Supabase.initialize(
    url: 'https://zsbbgchsjiuicwvtrldn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTEzOTg3NjQsImV4cCI6MjAyNjk3NDc2NH0.mEPlIb4ZSiYIXUZVMKyJF5pIwQOeHKE8dTDT6awbCo8',
  );

  final supabase = Supabase.instance.client;
  const raianyId = 'bbea26ca-f34c-499f-ad3a-48646a614cd3';

  print('🔍 TESTE 1: Query básica (igual ao app)');
  try {
    final result1 = await supabase
        .from('workout_records')
        .select('id, workout_name, workout_type, date, duration_minutes')
        .eq('user_id', raianyId)
        .eq('workout_type', 'Cardio')
        .gt('duration_minutes', 0)
        .order('date', ascending: false);
    
    print('✅ Resultado básico: ${result1.length} treinos');
    for (var workout in result1) {
      print('   - ${workout['workout_name']}: ${workout['duration_minutes']}min em ${workout['date']}');
    }
  } catch (e) {
    print('❌ Erro na query básica: $e');
  }

  print('\n🔍 TESTE 2: Query sem filtros de tipo');
  try {
    final result2 = await supabase
        .from('workout_records')
        .select('id, workout_name, workout_type, date, duration_minutes')
        .eq('user_id', raianyId)
        .gt('duration_minutes', 0)
        .order('date', ascending: false);
    
    print('✅ Todos os treinos: ${result2.length} treinos');
    
    final cardioWorkouts = result2.where((w) => w['workout_type'] == 'Cardio').toList();
    print('✅ Treinos de Cardio filtrados localmente: ${cardioWorkouts.length}');
    
    final totalMinutes = cardioWorkouts.fold<int>(0, (sum, w) => sum + (w['duration_minutes'] as int));
    print('✅ Total de minutos: $totalMinutes');
    
  } catch (e) {
    print('❌ Erro na query sem filtros: $e');
  }

  print('\n🔍 TESTE 3: Query com limit explícito alto');
  try {
    final result3 = await supabase
        .from('workout_records')
        .select('id, workout_name, workout_type, date, duration_minutes')
        .eq('user_id', raianyId)
        .eq('workout_type', 'Cardio')
        .gt('duration_minutes', 0)
        .order('date', ascending: false)
        .limit(50);
    
    print('✅ Com limit 50: ${result3.length} treinos');
  } catch (e) {
    print('❌ Erro na query com limit: $e');
  }

  print('\n🔍 TESTE 4: Contagem total');
  try {
    final count = await supabase
        .from('workout_records')
        .select('*', const FetchOptions(count: CountOption.exact))
        .eq('user_id', raianyId)
        .eq('workout_type', 'Cardio')
        .gt('duration_minutes', 0);
    
    print('✅ Contagem total no Supabase: ${count.count} treinos');
  } catch (e) {
    print('❌ Erro na contagem: $e');
  }
}

