// Package imports:
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script de diagnóstico para verificar problemas com fotos de treinos
class DiagnosticoFotosTreino {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Executa diagnóstico completo das fotos de treinos
  static Future<void> executarDiagnostico() async {
    debugPrint('🔍 === DIAGNÓSTICO DE FOTOS DOS TREINOS ===');
    
    try {
      await _verificarUsuarioAutenticado();
      await _verificarEstruturaTabela();
      await _verificarTreinosComFotos();
      await _verificarTreinosSemFotos();
      await _verificarURLsInvalidas();
      await _verificarPermissoesBucket();
      await _verificarSampleWorkoutRecord();
      
      debugPrint('✅ === DIAGNÓSTICO CONCLUÍDO ===');
    } catch (e) {
      debugPrint('❌ Erro durante o diagnóstico: $e');
    }
  }

  /// Verifica se usuário está autenticado
  static Future<void> _verificarUsuarioAutenticado() async {
    debugPrint('\n📱 1. Verificando autenticação...');
    
    final user = _client.auth.currentUser;
    if (user != null) {
      debugPrint('✅ Usuário autenticado: ${user.id}');
    } else {
      debugPrint('❌ Usuário não autenticado');
      throw Exception('Usuário não autenticado');
    }
  }

  /// Verifica estrutura da tabela workout_records
  static Future<void> _verificarEstruturaTabela() async {
    debugPrint('\n📋 2. Verificando estrutura da tabela...');
    
    try {
      // Verificar se a coluna image_urls existe e seu tipo
      final response = await _client.rpc('verify_column_structure', params: {
        'table_name': 'workout_records',
        'column_name': 'image_urls'
      });
      
      debugPrint('📊 Estrutura da coluna image_urls: $response');
    } catch (e) {
      debugPrint('⚠️ Erro ao verificar estrutura: $e');
      
      // Fallback: tentar uma consulta simples
      try {
        final sample = await _client
            .from('workout_records')
            .select('id, image_urls')
            .limit(1);
        debugPrint('✅ Coluna image_urls existe e é acessível');
      } catch (e2) {
        debugPrint('❌ Problemas com a coluna image_urls: $e2');
      }
    }
  }

  /// Verifica treinos que têm fotos
  static Future<void> _verificarTreinosComFotos() async {
    debugPrint('\n📸 3. Verificando treinos com fotos...');
    
    try {
      final user = _client.auth.currentUser!;
      
      final response = await _client
          .from('workout_records')
          .select('id, workout_name, image_urls, created_at')
          .eq('user_id', user.id)
          .not('image_urls', 'is', null)
          .neq('image_urls', '[]')
          .order('created_at', ascending: false)
          .limit(5);

      if (response.isEmpty) {
        debugPrint('🔍 Nenhum treino com fotos encontrado');
      } else {
        debugPrint('✅ Encontrados ${response.length} treinos com fotos:');
        for (var record in response) {
          final imageUrls = record['image_urls'];
          debugPrint('  📝 ${record['workout_name']}:');
          debugPrint('     ID: ${record['id']}');
          debugPrint('     URLs: $imageUrls');
          debugPrint('     Tipo: ${imageUrls.runtimeType}');
          
          if (imageUrls is List) {
            debugPrint('     Quantidade: ${imageUrls.length}');
            for (int i = 0; i < imageUrls.length; i++) {
              debugPrint('     URL[$i]: ${imageUrls[i]}');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar treinos com fotos: $e');
    }
  }

  /// Verifica treinos sem fotos
  static Future<void> _verificarTreinosSemFotos() async {
    debugPrint('\n📝 4. Verificando treinos sem fotos...');
    
    try {
      final user = _client.auth.currentUser!;
      
      final response = await _client
          .from('workout_records')
          .select('id, workout_name, image_urls, created_at')
          .eq('user_id', user.id)
          .or('image_urls.is.null,image_urls.eq.[]')
          .order('created_at', ascending: false)
          .limit(5);

      debugPrint('📊 Encontrados ${response.length} treinos sem fotos');
      for (var record in response) {
        debugPrint('  📝 ${record['workout_name']} (${record['id']})');
        debugPrint('     image_urls: ${record['image_urls']}');
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar treinos sem fotos: $e');
    }
  }

  /// Verifica URLs inválidas
  static Future<void> _verificarURLsInvalidas() async {
    debugPrint('\n🔗 5. Verificando URLs inválidas...');
    
    try {
      final user = _client.auth.currentUser!;
      
      final response = await _client
          .from('workout_records')
          .select('id, workout_name, image_urls')
          .eq('user_id', user.id)
          .not('image_urls', 'is', null)
          .neq('image_urls', '[]');

      int urlsInvalidas = 0;
      
      for (var record in response) {
        final imageUrls = record['image_urls'];
        if (imageUrls is List) {
          for (var url in imageUrls) {
            if (url is String) {
              if (!url.startsWith('http')) {
                debugPrint('⚠️ URL inválida encontrada:');
                debugPrint('   Treino: ${record['workout_name']}');
                debugPrint('   URL: $url');
                urlsInvalidas++;
              }
            }
          }
        }
      }
      
      if (urlsInvalidas == 0) {
        debugPrint('✅ Todas as URLs parecem válidas');
      } else {
        debugPrint('❌ Encontradas $urlsInvalidas URLs inválidas');
      }
    } catch (e) {
      debugPrint('❌ Erro ao verificar URLs: $e');
    }
  }

  /// Verifica permissões do bucket de imagens
  static Future<void> _verificarPermissoesBucket() async {
    debugPrint('\n🪣 6. Verificando bucket de imagens...');
    
    try {
      // Verificar se o bucket existe
      final buckets = await _client.storage.listBuckets();
      final workoutBucket = buckets.firstWhere(
        (bucket) => bucket.name == 'workout_images',
        orElse: () => throw Exception('Bucket workout_images não encontrado'),
      );
      
      debugPrint('✅ Bucket workout_images encontrado');
      debugPrint('   ID: ${workoutBucket.id}');
      debugPrint('   Público: ${workoutBucket.public}');
      
      // Tentar listar arquivos (para verificar permissões de leitura)
      try {
        final user = _client.auth.currentUser!;
        final files = await _client.storage
            .from('workout_images')
            .list(path: 'workout_records/', searchOptions: const SearchOptions(limit: 5));
        
        debugPrint('✅ Permissão de leitura OK - ${files.length} arquivos encontrados');
      } catch (e) {
        debugPrint('⚠️ Problema com permissões de leitura: $e');
      }
      
    } catch (e) {
      debugPrint('❌ Erro ao verificar bucket: $e');
    }
  }

  /// Verifica um registro específico de exemplo
  static Future<void> _verificarSampleWorkoutRecord() async {
    debugPrint('\n🔬 7. Análise detalhada de um registro...');
    
    try {
      final user = _client.auth.currentUser!;
      
      // Buscar o treino mais recente
      final response = await _client
          .from('workout_records')
          .select('*')
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        debugPrint('📝 Nenhum treino encontrado para análise');
        return;
      }

      final record = response.first;
      debugPrint('🔍 Analisando treino mais recente:');
      debugPrint('   ID: ${record['id']}');
      debugPrint('   Nome: ${record['workout_name']}');
      debugPrint('   Tipo: ${record['workout_type']}');
      debugPrint('   Data: ${record['date']}');
      debugPrint('   image_urls (raw): ${record['image_urls']}');
      debugPrint('   image_urls tipo: ${record['image_urls'].runtimeType}');
      
      if (record['image_urls'] != null) {
        final imageUrls = record['image_urls'];
        if (imageUrls is List) {
          debugPrint('   Quantidade de imagens: ${imageUrls.length}');
          for (int i = 0; i < imageUrls.length; i++) {
            final url = imageUrls[i];
            debugPrint('   Imagem $i: $url');
            
            // Tentar fazer uma requisição HEAD para verificar se a URL está acessível
            try {
              // Simular verificação de URL (em produção, você poderia usar http package)
              debugPrint('     URL parece válida: ${url.startsWith('http')}');
            } catch (e) {
              debugPrint('     ❌ Problema ao acessar URL: $e');
            }
          }
        } else {
          debugPrint('   ⚠️ image_urls não é uma lista: ${imageUrls.runtimeType}');
        }
      } else {
        debugPrint('   📝 Sem imagens associadas');
      }
      
    } catch (e) {
      debugPrint('❌ Erro na análise detalhada: $e');
    }
  }

  /// Verifica conversão de dados usando o adapter
  static Future<void> verificarConversaoAdapter() async {
    debugPrint('\n🔄 8. Verificando conversão de dados com adapter...');
    
    try {
      final user = _client.auth.currentUser!;
      
      // Buscar dados brutos do banco
      final response = await _client
          .from('workout_records')
          .select('*')
          .eq('user_id', user.id)
          .limit(1);

      if (response.isEmpty) {
        debugPrint('📝 Nenhum treino para testar conversão');
        return;
      }

      final rawData = response.first;
      debugPrint('📥 Dados brutos do banco:');
      debugPrint('   image_urls: ${rawData['image_urls']}');
      debugPrint('   Tipo: ${rawData['image_urls'].runtimeType}');
      
      // Simular conversão do adapter
      final convertedData = {
        'imageUrls': rawData['image_urls'] ?? [],
      };
      
      debugPrint('📤 Após conversão:');
      debugPrint('   imageUrls: ${convertedData['imageUrls']}');
      debugPrint('   Tipo: ${convertedData['imageUrls'].runtimeType}');
      
    } catch (e) {
      debugPrint('❌ Erro na verificação do adapter: $e');
    }
  }
} 