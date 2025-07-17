import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Este é um script temporário para debug
  print('🔍 === DEBUG TREINO ESPECÍFICO ===');
  
  try {
    final client = Supabase.instance.client;
    
    // ID do treino que está com problema
    const workoutId = '24017ce1-e99e-4e98-bc47-5ba8a142a132';
    
    print('📍 Buscando treino: $workoutId');
    
    // Buscar dados brutos do banco
    final response = await client
        .from('workout_records')
        .select('*')
        .eq('id', workoutId)
        .single();
    
    print('📊 Dados brutos do banco:');
    print('   ID: ${response['id']}');
    print('   workout_name: ${response['workout_name']}');
    print('   workout_type: ${response['workout_type']}');
    print('   image_urls: ${response['image_urls']}');
    print('   image_urls type: ${response['image_urls'].runtimeType}');
    print('   created_at: ${response['created_at']}');
    print('   user_id: ${response['user_id']}');
    
    if (response['image_urls'] != null) {
      final imageUrls = response['image_urls'];
      if (imageUrls is List) {
        print('   Quantidade de URLs: ${imageUrls.length}');
        for (int i = 0; i < imageUrls.length; i++) {
          print('   URL[$i]: ${imageUrls[i]}');
        }
      } else {
        print('   ⚠️ image_urls não é uma lista!');
      }
    } else {
      print('   ❌ image_urls é null');
    }
    
  } catch (e) {
    print('❌ Erro: $e');
  }
} 