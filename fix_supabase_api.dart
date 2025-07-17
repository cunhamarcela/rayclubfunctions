import 'dart:io';

void main() async {
  final filePath = 'lib/features/challenges/repositories/supabase_challenge_repository.dart';
  String content = await File(filePath).readAsString();
  
  // Correção 1: Remover .execute()
  content = content.replaceAll('.execute();', ';');
  
  // Correção 2: Substituir .in_() por .filter()
  final regex = RegExp(r'\.in_\(([^,]+),\s*([^)]+)\)');
  content = content.replaceAllMapped(regex, (match) {
    return '.filter(${match.group(1)}, \'in\', ${match.group(2)})';
  });
  
  // Correção 3: Ajustar respostas
  content = content.replaceAll('response.data', 'response');
  content = content.replaceAll('response.data.isEmpty', 'response.isEmpty');
  content = content.replaceAll('response.data[0]', 'response[0]');
  
  content = content.replaceAll('challengesResponse.data', 'challengesResponse');
  content = content.replaceAll('participantResponse.data', 'participantResponse');
  content = content.replaceAll('progressResponse.data', 'progressResponse');
  content = content.replaceAll('userProgressResponse.data', 'userProgressResponse');
  content = content.replaceAll('groupsResponse.data', 'groupsResponse');
  
  // Correção 4: Ajustar tratamento de erros
  content = content.replaceAll('response.error != null', 'false');
  
  // Salvar as alterações
  await File('${filePath}.fixed').writeAsString(content);
  
  print('Arquivo corrigido salvo como ${filePath}.fixed');
  print('Revise as alterações e substitua o arquivo original se estiver satisfeito.');
} 