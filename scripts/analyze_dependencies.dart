import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Script para analisar dependências não utilizadas no projeto
/// Execute com: dart scripts/analyze_dependencies.dart
void main() async {
  print('🔍 Analisando dependências do projeto...');

  // Ler o pubspec.yaml
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('❌ pubspec.yaml não encontrado!');
    return;
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final pubspec = loadYaml(pubspecContent);
  
  // Extrair dependências
  final dependencies = <String>[];
  if (pubspec['dependencies'] != null) {
    dependencies.addAll(_extractDependencyNames(pubspec['dependencies']));
  }
  
  if (pubspec['dev_dependencies'] != null) {
    dependencies.addAll(_extractDependencyNames(pubspec['dev_dependencies']));
  }
  
  print('📦 Total de dependências: ${dependencies.length}');
  
  // Analisar código fonte
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('❌ Diretório lib/ não encontrado!');
    return;
  }
  
  // Encontrar todos os arquivos Dart
  final dartFiles = await _findDartFiles(libDir);
  print('📄 Total de arquivos Dart: ${dartFiles.length}');
  
  // Analisar imports
  final importedPackages = <String>{};
  int totalImports = 0;
  
  for (final file in dartFiles) {
    final content = file.readAsStringSync();
    final imports = _extractImports(content);
    totalImports += imports.length;
    
    for (final import in imports) {
      final package = _extractPackageName(import);
      if (package != null) {
        importedPackages.add(package);
      }
    }
  }
  
  print('📥 Total de imports: $totalImports');
  print('📦 Pacotes importados: ${importedPackages.length}');
  
  // Encontrar não utilizados
  final unusedDependencies = dependencies
      .where((dep) => !importedPackages.contains(dep))
      .where((dep) => !_isSpecialDependency(dep))
      .toList();
  
  print('\n🚩 Dependências potencialmente não utilizadas:');
  if (unusedDependencies.isEmpty) {
    print('✅ Não foram encontradas dependências não utilizadas!');
  } else {
    for (final dep in unusedDependencies) {
      print('  • $dep');
    }
    
    print('\n⚠️ ATENÇÃO: Algumas dependências podem ser usadas indiretamente.');
    print('   Verifique manualmente antes de remover.');
  }
  
  // Sugestões
  print('\n🔧 Sugestões de otimização:');
  print('  1. Use pacotes com suporte a tree-shaking quando possível');
  print('  2. Considere alternativas mais leves para pacotes grandes');
  print('  3. Importe apenas o necessário (import específico ao invés de toda a biblioteca)');
  print('  4. Use lazy loading para features menos utilizadas');
}

List<String> _extractDependencyNames(YamlMap dependencies) {
  return dependencies.keys.cast<String>().toList();
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

List<String> _extractImports(String content) {
  final regex = RegExp(r"import\s+['\"]([^'\"]+)['\"]");
  return regex
      .allMatches(content)
      .map((match) => match.group(1) ?? '')
      .where((path) => path.isNotEmpty)
      .toList();
}

String? _extractPackageName(String importPath) {
  if (importPath.startsWith('package:')) {
    final parts = importPath.substring(8).split('/');
    return parts.isNotEmpty ? parts[0] : null;
  }
  return null;
}

bool _isSpecialDependency(String dep) {
  // Algumas dependências são usadas de maneiras especiais (ex: geração de código)
  const specialDeps = {
    'flutter', 'flutter_test', 'flutter_lints', 'integration_test',
    'build_runner', 'freezed', 'json_serializable', 'flutter_gen_runner',
    'auto_route_generator', 'riverpod_generator', 'flutter_launcher_icons',
    'flutter_native_splash', 'hive_generator', 'mocktail', 'mockito'
  };
  
  return specialDeps.contains(dep);
} 