import 'package:supabase_flutter/supabase_flutter.dart';

// SCRIPT DE COMPARAÇÃO: Flutter Query vs SQL Direto
// Objetivo: Descobrir por que Flutter retorna 14 treinos mas SQL mostra 22

void main() async {
  // Configurar Supabase
  await Supabase.initialize(
    url: 'https://zsbbgchsjiuicwvtrldn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTEzOTg3NjQsImV4cCI6MjAyNjk3NDc2NH0.mEPlIb4ZSiYIXUZVMKyJF5pIwQOeHKE8dTDT6awbCo8',
  );

  final supabase = Supabase.instance.client;
  const raianyId = 'bbea26ca-f34c-499f-ad3a-48646a614cd3';

  print('🔍 TESTE 1: Query EXATA do app Flutter');
  try {
    final result1 = await supabase
        .from('workout_records')
        .select('id, workout_name, workout_type, date, duration_minutes, notes, is_completed, image_urls')
        .eq('user_id', raianyId)
        .eq('workout_type', 'Cardio')
        .gt('duration_minutes', 0)
        .order('date', ascending: false);
    
    print('✅ RESULTADO FLUTTER: ${result1.length} treinos encontrados');
    print('📋 LISTA FLUTTER:');
    for (int i = 0; i < result1.length; i++) {
      final item = result1[i];
      print('  ${i + 1}. ${item['workout_name']} - ${item['date']} - ${item['duration_minutes']}min');
    }
  } catch (e) {
    print('❌ ERRO FLUTTER: $e');
  }

  print('\n🔍 TESTE 2: SQL RPC direto');
  try {
    final result2 = await supabase.rpc('get_cardio_ranking').eq('user_id', raianyId);
    print('✅ RESULTADO SQL RPC: ${result2.length} registros');
    if (result2.isNotEmpty) {
      print('📊 DADOS RPC: ${result2.first}');
    }
  } catch (e) {
    print('❌ ERRO SQL RPC: $e');
  }

  print('\n🔍 TESTE 3: Query com limite explícito');
  try {
    final result3 = await supabase
        .from('workout_records')
        .select('id, workout_name, workout_type, date, duration_minutes')
        .eq('user_id', raianyId)
        .eq('workout_type', 'Cardio')
        .gt('duration_minutes', 0)
        .order('date', ascending: false)
        .limit(50); // Limite alto
    
    print('✅ RESULTADO COM LIMITE 50: ${result3.length} treinos encontrados');
  } catch (e) {
    print('❌ ERRO COM LIMITE: $e');
  }

  print('\n🔍 TESTE 4: Query básica sem filtros extras');
  try {
    final result4 = await supabase
        .from('workout_records')
        .select('id, workout_name, workout_type, date, duration_minutes')
        .eq('user_id', raianyId)
        .eq('workout_type', 'Cardio');
    
    print('✅ RESULTADO SEM FILTRO DURATION: ${result4.length} treinos encontrados');
  } catch (e) {
    print('❌ ERRO SEM FILTROS: $e');
  }

  print('\n🔍 TESTE 5: Verificar RLS (Row Level Security)');
  try {
    // Simular query como usuário anônimo
    final result5 = await supabase
        .from('workout_records')
        .select('count', count: CountOption.exact)
        .eq('user_id', raianyId)
        .eq('workout_type', 'Cardio')
        .gt('duration_minutes', 0);
    
    print('✅ COUNT TOTAL (RLS considerado): ${result5.count} treinos');
  } catch (e) {
    print('❌ ERRO COUNT: $e');
  }

  print('\n📋 CONCLUSÃO: Compare os números acima com o SQL direto (22 treinos)');
}

