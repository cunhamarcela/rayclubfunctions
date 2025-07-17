import 'dart:convert';
import 'dart:io';

void main() async {
  print('🗂️ Verificando Categorias no Supabase - Ray Club');
  print('=' * 55);

  // Lê configurações do .env
  final envFile = File('.env');
  final envContent = await envFile.readAsString();
  
  final supabaseUrlMatch = RegExp(r'SUPABASE_URL=(.+)').firstMatch(envContent);
  final supabaseKeyMatch = RegExp(r'SUPABASE_ANON_KEY=(.+)').firstMatch(envContent);
  
  if (supabaseUrlMatch == null || supabaseKeyMatch == null) {
    print('❌ Configurações do Supabase não encontradas no .env');
    exit(1);
  }

  final supabaseUrl = supabaseUrlMatch.group(1);
  final supabaseKey = supabaseKeyMatch.group(1);

  print('✅ Configurações encontradas');
  print('🔗 URL: ${supabaseUrl?.substring(0, 30)}...');

  try {
    // Busca categorias de treino
    await fetchCategories(supabaseUrl!, supabaseKey!, 'workout_categories');
    
    // Busca algumas entradas existentes de vídeos para ver a estrutura
    await fetchExistingVideos(supabaseUrl, supabaseKey);
    
  } catch (e) {
    print('💥 Erro: $e');
  }
}

Future<void> fetchCategories(String baseUrl, String apiKey, String table) async {
  try {
    final client = HttpClient();
    final url = '$baseUrl/rest/v1/$table?select=*';
    
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('apikey', apiKey);
    request.headers.set('Authorization', 'Bearer $apiKey');
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('\n📊 Status da consulta: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List<dynamic>;
      
      print('✅ Categorias encontradas: ${data.length}');
      print('\n🗂️ CATEGORIAS DISPONÍVEIS:');
      print('-' * 50);
      
      for (final category in data) {
        final id = category['id'] ?? 'N/A';
        final name = category['name'] ?? 'Sem nome';
        final description = category['description'] ?? 'Sem descrição';
        
        print('📁 $name');
        print('   ID: $id');
        print('   Descrição: $description');
        print('');
      }
      
    } else {
      print('❌ Erro ao buscar categorias: ${response.statusCode}');
      print('Response: $responseBody');
    }
    
    client.close();
    
  } catch (e) {
    print('💥 Erro na consulta de categorias: $e');
  }
}

Future<void> fetchExistingVideos(String baseUrl, String apiKey) async {
  try {
    final client = HttpClient();
    final url = '$baseUrl/rest/v1/workout_videos?select=id,title,youtube_url,category&limit=5';
    
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('apikey', apiKey);
    request.headers.set('Authorization', 'Bearer $apiKey');
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('\n📹 VÍDEOS EXISTENTES (amostra):');
    print('-' * 50);
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as List<dynamic>;
      
      print('Total de vídeos existentes: ${data.length} (mostrando apenas 5)');
      
      for (final video in data) {
        final title = video['title'] ?? 'Sem título';
        final youtubeUrl = video['youtube_url'] ?? 'N/A';
        final category = video['category'] ?? 'N/A';
        
        print('🎥 $title');
        print('   YouTube URL: $youtubeUrl');
        print('   Categoria: $category');
        print('');
      }
      
    } else if (response.statusCode == 404) {
      print('ℹ️ Tabela workout_videos ainda não possui dados');
    } else {
      print('❌ Erro ao buscar vídeos: ${response.statusCode}');
      print('Response: $responseBody');
    }
    
    client.close();
    
  } catch (e) {
    print('💥 Erro na consulta de vídeos: $e');
  }
} 