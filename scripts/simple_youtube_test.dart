import 'dart:io';
import 'dart:convert';

/// Script simples para testar acesso ao canal do YouTube
/// Testa primeiro com API Key para ver se conseguimos acessar o canal
void main() async {
  print('🔍 Teste Simples - Acesso ao Canal YouTube');
  print('=' * 50);
  print('');

  // Lê as configurações
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ Arquivo .env não encontrado');
    return;
  }

  final envContent = await envFile.readAsString();
  final envVars = <String, String>{};
  
  for (final line in envContent.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    
    final parts = trimmed.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      final value = parts.sublist(1).join('=').trim();
      envVars[key] = value;
    }
  }

  final youtubeKey = envVars['YOUTUBE_API_KEY'];
  
  if (youtubeKey == null || youtubeKey.isEmpty) {
    print('❌ YOUTUBE_API_KEY não encontrada no .env');
    return;
  }
  
  print('✅ YouTube API Key encontrada');
  print('');

  const channelId = 'UCJIOE2pKr_sGWxSuUNEBoaw';
  
  // Testa acesso básico ao canal
  try {
    print('🔄 Testando acesso ao canal com API Key...');
    
    final result = await Process.run('curl', [
      '-s',
      'https://www.googleapis.com/youtube/v3/channels?part=snippet,contentDetails&id=$channelId&key=$youtubeKey'
    ]);
    
    if (result.exitCode == 0) {
      final response = jsonDecode(result.stdout.toString());
      
      if (response['items'] != null && response['items'].isNotEmpty) {
        final channel = response['items'][0];
        final snippet = channel['snippet'];
        
        print('✅ Canal encontrado!');
        print('📋 Informações do canal:');
        print('   - Nome: ${snippet['title']}');
        print('   - Criado em: ${snippet['publishedAt']}');
        print('   - Descrição: ${snippet['description']?.toString().substring(0, 100) ?? 'Sem descrição'}...');
        
        // Verifica se há playlist de uploads
        final contentDetails = channel['contentDetails'];
        final uploadsPlaylist = contentDetails?['relatedPlaylists']?['uploads'];
        
        if (uploadsPlaylist != null) {
          print('   - Playlist de uploads: $uploadsPlaylist');
          print('');
          
          // Tenta acessar vídeos da playlist
          print('🔄 Tentando acessar playlist de uploads...');
          
          final playlistResult = await Process.run('curl', [
            '-s',
            'https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=$uploadsPlaylist&maxResults=5&key=$youtubeKey'
          ]);
          
          if (playlistResult.exitCode == 0) {
            final playlistResponse = jsonDecode(playlistResult.stdout.toString());
            final items = playlistResponse['items'] ?? [];
            
            print('📹 Encontrados ${items.length} vídeos (máximo 5 para teste):');
            
            if (items.isEmpty) {
              print('   ⚠️  Nenhum vídeo público encontrado na playlist');
              print('   💡 Isso é normal para canais com vídeos privados!');
            } else {
              for (int i = 0; i < items.length; i++) {
                final video = items[i];
                final videoSnippet = video['snippet'];
                print('   ${i + 1}. ${videoSnippet['title']}');
              }
            }
          }
        }
        
        print('');
        print('🎯 RESULTADO: API Key funciona, canal existe!');
        print('');
        print('💡 PRÓXIMOS PASSOS PARA VÍDEOS PRIVADOS:');
        print('');
        print('📋 OPÇÃO 1: Aguardar OAuth propagar (recomendado)');
        print('   - Aguarde 10-15 minutos');
        print('   - Execute: dart run scripts/modern_oauth_importer.dart');
        print('');
        print('📋 OPÇÃO 2: Verificar permissões do canal');
        print('   - Confirme que você tem acesso de MANAGER');
        print('   - Tente fazer login com a conta correta');
        print('');
        print('📋 OPÇÃO 3: Usar método manual');
        print('   - Como manager, você pode baixar vídeos manualmente');
        print('   - Fazer upload para o banco via script direto');
        print('');
        
      } else {
        print('❌ Canal não encontrado ou sem acesso');
        print('💡 Verifique se o Channel ID está correto');
      }
    } else {
      print('❌ Erro na requisição: ${result.stderr}');
    }
    
  } catch (e) {
    print('❌ Erro no teste: $e');
  }
  
  print('');
  stdout.write('❓ Quer tentar o OAuth novamente após aguardar? (s/n): ');
  final response = stdin.readLineSync()?.trim().toLowerCase();
  
  if (response == 's' || response == 'sim') {
    print('');
    print('⏳ Aguarde 2 minutos para as configurações propagarem...');
    await Future.delayed(Duration(seconds: 10)); // Simula espera
    print('🚀 Execute: dart run scripts/modern_oauth_importer.dart');
  }
} 