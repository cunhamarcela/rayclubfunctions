import 'dart:io';
import 'package:path/path.dart' as path;

/// Script para identificar código potencialmente não utilizado
/// Execute com: dart scripts/find_unused_code.dart
void main() async {
  print('🔍 Analisando código não utilizado...');

  // Diretório para análise
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ Diretório lib/ não encontrado!');
    return;
  }

  // Encontrar arquivos Dart
  final dartFiles = await _findDartFiles(libDir);
  print('📄 Total de arquivos Dart: ${dartFiles.length}');

  // Mapear classes e funções públicas
  final declarations = <CodeDeclaration>[];
  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    declarations.addAll(_findDeclarations(content, file.path));
  }

  print('📊 Total de declarações encontradas: ${declarations.length}');

  // Verificar uso de cada declaração
  final unusedElements = <CodeDeclaration>[];
  for (final declaration in declarations) {
    bool isUsed = false;
    for (final file in dartFiles) {
      // Não verificar no arquivo onde foi declarada
      if (file.path == declaration.filePath) continue;

      final content = file.readAsStringSync();
      if (content.contains(declaration.name)) {
        isUsed = true;
        break;
      }
    }

    if (!isUsed && !_isSpecialName(declaration.name)) {
      unusedElements.add(declaration);
    }
  }

  // Mostrar elementos não utilizados
  if (unusedElements.isEmpty) {
    print('✅ Não foram encontrados elementos não utilizados!');
  } else {
    print('\n🚩 Potenciais elementos não utilizados:');
    print('------------------------------------');

    // Agrupar por arquivo
    final byFile = <String, List<CodeDeclaration>>{};
    for (final element in unusedElements) {
      byFile.putIfAbsent(element.filePath, () => []);
      byFile[element.filePath]!.add(element);
    }

    // Exibir organizados por arquivo
    for (final filePath in byFile.keys) {
      final relativePath = path.relative(filePath, from: Directory.current.path);
      print('\n📁 $relativePath:');
      
      for (final element in byFile[filePath]!) {
        final typeEmoji = element.type == 'class' ? '🔶' : 
                         element.type == 'method' ? '🔷' : '⚪';
        print('  $typeEmoji ${element.name} (${element.type})');
      }
    }

    print('\n⚠️ ATENÇÃO: Esta análise pode ter falsos positivos.');
    print('   Verifique manualmente antes de remover qualquer código.');
  }

  // Sugestões
  print('\n🔧 Sugestões para redução de código:');
  print('  1. Remova classes e funções não utilizadas');
  print('  2. Converta widgets Stateful para Stateless quando possível');
  print('  3. Use const constructors para widgets estáticos');
  print('  4. Mova código comum para utilitários compartilhados');
  print('  5. Implemente lazy loading para features grandes');
}

Future<List<File>> _findDartFiles(Directory dir) async {
  final files = <File>[];
  final entities = dir.listSync(recursive: true);
  
  for (final entity in entities) {
    if (entity is File && entity.path.endsWith('.dart')) {
      files.add(entity);
    }
  }
  
  return files;
}

List<CodeDeclaration> _findDeclarations(String content, String filePath) {
  final declarations = <CodeDeclaration>[];
  
  // Encontrar classes
  final classRegex = RegExp(r'class\s+(\w+)');
  for (final match in classRegex.allMatches(content)) {
    final className = match.group(1);
    if (className != null && !_isPrivate(className)) {
      declarations.add(CodeDeclaration(className, 'class', filePath));
    }
  }
  
  // Encontrar métodos e funções
  final methodRegex = RegExp(r'(?:void|Future|String|int|double|bool|List|Map|Set|Widget|dynamic|\w+)\s+(\w+)\s*\([^\)]*\)');
  for (final match in methodRegex.allMatches(content)) {
    final methodName = match.group(1);
    if (methodName != null && !_isPrivate(methodName) && !_isCommonMethodName(methodName)) {
      declarations.add(CodeDeclaration(methodName, 'method', filePath));
    }
  }
  
  return declarations;
}

bool _isPrivate(String name) {
  return name.startsWith('_');
}

bool _isCommonMethodName(String name) {
  // Nomes comuns que provavelmente são usados em override
  const commonMethods = {
    'build', 'initState', 'dispose', 'didChangeDependencies',
    'didUpdateWidget', 'setState', 'createState', 'main', 
    'toString', 'hashCode', 'operator==', 'noSuchMethod'
  };
  return commonMethods.contains(name);
}

bool _isSpecialName(String name) {
  // Nomes que provavelmente são usados por reflexão ou geração de código
  return name.endsWith('Provider') || 
         name.endsWith('Controller') || 
         name.endsWith('State') ||
         name.endsWith('Factory') ||
         name.startsWith('init') ||
         name.startsWith('get') ||
         name.startsWith('set');
}

class CodeDeclaration {
  final String name;
  final String type; // 'class', 'method', etc.
  final String filePath;
  
  CodeDeclaration(this.name, this.type, this.filePath);
} 