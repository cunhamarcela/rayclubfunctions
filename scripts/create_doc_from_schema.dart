import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;

/// Script para criar documentação do esquema Supabase a partir dos CSVs exportados
/// Uso: dart create_doc_from_schema.dart <diretório_com_csvs> <arquivo_output.md>

void main(List<String> args) async {
  if (args.length != 2) {
    print('Uso: dart create_doc_from_schema.dart <diretório_com_csvs> <arquivo_output.md>');
    exit(1);
  }

  final inputDir = args[0];
  final outputFile = args[1];
  final directory = Directory(inputDir);
  
  if (!await directory.exists()) {
    print('Diretório $inputDir não encontrado!');
    exit(1);
  }

  final outputBuffer = StringBuffer();
  outputBuffer.writeln('# Esquema de Banco de Dados do Ray Club App\n');
  outputBuffer.writeln('*Documento gerado automaticamente em ${DateTime.now().toString()}*\n');

  // Map para armazenar dados por seção
  final sectionData = <String, List<String>>{
    'tables': [],
    'columns': [],
    'primary_keys': [],
    'foreign_keys': [],
    'indexes': [],
    'triggers': [],
    'functions': [],
    'views': [],
    'policies': [],
    'extensions': [],
    'buckets': [],
    'json_columns': [],
    'custom_types': [],
    'size_stats': [],
  };

  // Lista todos os arquivos CSV do diretório
  await for (final entity in directory.list()) {
    if (entity is File && path.extension(entity.path) == '.csv') {
      final fileName = path.basenameWithoutExtension(entity.path).toLowerCase();
      
      final content = await entity.readAsString();
      final lines = LineSplitter.split(content).toList();
      
      if (lines.isEmpty) continue;
      
      // Analisar conteúdo baseado no nome do arquivo
      if (fileName.contains('table_count')) {
        parseTablesData(lines, sectionData['tables']!);
      } else if (fileName.contains('column')) {
        parseColumnsData(lines, sectionData['columns']!);
      } else if (fileName.contains('primary_key')) {
        parsePrimaryKeysData(lines, sectionData['primary_keys']!);
      } else if (fileName.contains('foreign_key')) {
        parseForeignKeysData(lines, sectionData['foreign_keys']!);
      } else if (fileName.contains('index')) {
        parseIndexesData(lines, sectionData['indexes']!);
      } else if (fileName.contains('trigger')) {
        parseTriggersData(lines, sectionData['triggers']!);
      } else if (fileName.contains('function')) {
        parseFunctionsData(lines, sectionData['functions']!);
      } else if (fileName.contains('view')) {
        parseViewsData(lines, sectionData['views']!);
      } else if (fileName.contains('polic')) {
        parsePoliciesData(lines, sectionData['policies']!);
      } else if (fileName.contains('extension')) {
        parseExtensionsData(lines, sectionData['extensions']!);
      } else if (fileName.contains('bucket')) {
        parseBucketsData(lines, sectionData['buckets']!);
      } else if (fileName.contains('json')) {
        parseJsonColumnsData(lines, sectionData['json_columns']!);
      } else if (fileName.contains('type')) {
        parseCustomTypesData(lines, sectionData['custom_types']!);
      } else if (fileName.contains('size') || fileName.contains('stat')) {
        parseSizeStatsData(lines, sectionData['size_stats']!);
      }
    }
  }

  // Seção 1: Tabelas e Contagens
  outputBuffer.writeln('## 1. Tabelas e Contagens\n');
  if (sectionData['tables']!.isNotEmpty) {
    sectionData['tables']!.forEach((line) => outputBuffer.writeln(line));
  } else {
    outputBuffer.writeln('*Nenhuma tabela encontrada nos arquivos CSV*\n');
  }

  // Seção 2: Estrutura Detalhada de Tabelas
  outputBuffer.writeln('\n## 2. Estrutura Detalhada de Tabelas\n');
  
  // Agrupar colunas por tabela
  final tableColumnsMap = <String, List<String>>{};
  
  if (sectionData['columns']!.isNotEmpty) {
    for (final columnLine in sectionData['columns']!) {
      final parts = columnLine.split('|');
      if (parts.length >= 2) {
        final tableName = parts[0].trim();
        if (!tableColumnsMap.containsKey(tableName)) {
          tableColumnsMap[tableName] = [];
        }
        tableColumnsMap[tableName]!.add(columnLine);
      }
    }
    
    // Imprimir detalhes de cada tabela
    for (final tableName in tableColumnsMap.keys.toList()..sort()) {
      outputBuffer.writeln('### 2.${tableColumnsMap.keys.toList().indexOf(tableName) + 1} Tabela: $tableName\n');
      
      outputBuffer.writeln('| Coluna | Tipo | Tamanho | Nulo? | Padrão | Descrição |');
      outputBuffer.writeln('|--------|------|---------|-------|--------|-----------|');
      
      for (final columnLine in tableColumnsMap[tableName]!) {
        final parts = columnLine.split('|');
        if (parts.length >= 6) {
          // Ignorar o primeiro campo (nome da tabela) e imprimir os demais
          outputBuffer.writeln('| ${parts.sublist(1).join('|')} |');
        }
      }
      
      outputBuffer.writeln();
    }
  } else {
    outputBuffer.writeln('*Nenhuma informação detalhada de colunas encontrada nos arquivos CSV*\n');
  }

  // Seção 3: Relações entre Tabelas
  outputBuffer.writeln('\n## 3. Relações entre Tabelas\n');
  
  // 3.1 Chaves Primárias
  outputBuffer.writeln('### 3.1 Chaves Primárias\n');
  if (sectionData['primary_keys']!.isNotEmpty) {
    outputBuffer.writeln('| Esquema | Tabela | Coluna |');
    outputBuffer.writeln('|---------|--------|--------|');
    sectionData['primary_keys']!.forEach((line) => outputBuffer.writeln('| $line |'));
  } else {
    outputBuffer.writeln('*Nenhuma informação de chaves primárias encontrada nos arquivos CSV*\n');
  }
  
  // 3.2 Chaves Estrangeiras
  outputBuffer.writeln('\n### 3.2 Chaves Estrangeiras\n');
  if (sectionData['foreign_keys']!.isNotEmpty) {
    outputBuffer.writeln('| Esquema | Tabela | Coluna | Esquema Referenciado | Tabela Referenciada | Coluna Referenciada |');
    outputBuffer.writeln('|---------|--------|--------|---------------------|-------------------|-------------------|');
    sectionData['foreign_keys']!.forEach((line) => outputBuffer.writeln('| $line |'));
  } else {
    outputBuffer.writeln('*Nenhuma informação de chaves estrangeiras encontrada nos arquivos CSV*\n');
  }

  // Seção 4: Índices
  outputBuffer.writeln('\n## 4. Índices\n');
  if (sectionData['indexes']!.isNotEmpty) {
    outputBuffer.writeln('| Tabela | Nome do Índice | Definição |');
    outputBuffer.writeln('|--------|----------------|-----------|');
    sectionData['indexes']!.forEach((line) => outputBuffer.writeln('| $line |'));
  } else {
    outputBuffer.writeln('*Nenhuma informação de índices encontrada nos arquivos CSV*\n');
  }

  // Seção 5: Triggers e Funções
  outputBuffer.writeln('\n## 5. Triggers e Funções\n');
  
  // 5.1 Triggers
  outputBuffer.writeln('### 5.1 Triggers\n');
  if (sectionData['triggers']!.isNotEmpty) {
    outputBuffer.writeln('| Tabela | Nome do Trigger | Momento | Evento | Definição |');
    outputBuffer.writeln('|--------|----------------|---------|--------|-----------|');
    sectionData['triggers']!.forEach((line) => outputBuffer.writeln('| $line |'));
  } else {
    outputBuffer.writeln('*Nenhuma informação de triggers encontrada nos arquivos CSV*\n');
  }
  
  // 5.2 Funções
  outputBuffer.writeln('\n### 5.2 Funções\n');
  if (sectionData['functions']!.isNotEmpty) {
    for (final func in sectionData['functions']!) {
      final parts = func.split('|');
      if (parts.length >= 2) {
        outputBuffer.writeln('#### ${parts[0]}\n');
        outputBuffer.writeln('```sql');
        outputBuffer.writeln(parts[1]);
        outputBuffer.writeln('```\n');
      }
    }
  } else {
    outputBuffer.writeln('*Nenhuma informação de funções encontrada nos arquivos CSV*\n');
  }

  // Seção 6: Políticas de Segurança (RLS)
  outputBuffer.writeln('\n## 6. Políticas de Segurança (RLS)\n');
  if (sectionData['policies']!.isNotEmpty) {
    outputBuffer.writeln('| Esquema | Tabela | Nome da Política | Permissivo | Roles | Comando | Qualificador | Verificação |');
    outputBuffer.writeln('|---------|--------|-----------------|------------|-------|---------|--------------|-------------|');
    sectionData['policies']!.forEach((line) => outputBuffer.writeln('| $line |'));
  } else {
    outputBuffer.writeln('*Nenhuma informação de políticas RLS encontrada nos arquivos CSV*\n');
  }

  // Seção 7: Storage Buckets
  outputBuffer.writeln('\n## 7. Storage Buckets\n');
  if (sectionData['buckets']!.isNotEmpty) {
    outputBuffer.writeln('| Nome | Proprietário | Criado Em | Atualizado Em | Público |');
    outputBuffer.writeln('|------|-------------|-----------|---------------|---------|');
    sectionData['buckets']!.forEach((line) => outputBuffer.writeln('| $line |'));
  } else {
    outputBuffer.writeln('*Nenhuma informação de storage buckets encontrada nos arquivos CSV*\n');
  }

  // Seção 8: Tipos Personalizados
  outputBuffer.writeln('\n## 8. Tipos Personalizados\n');
  if (sectionData['custom_types']!.isNotEmpty) {
    outputBuffer.writeln('| Nome | Tipo | Valores de Enum | Descrição |');
    outputBuffer.writeln('|------|------|----------------|-----------|');
    sectionData['custom_types']!.forEach((line) => outputBuffer.writeln('| $line |'));
  } else {
    outputBuffer.writeln('*Nenhuma informação de tipos personalizados encontrada nos arquivos CSV*\n');
  }

  // Seção 9: Estatísticas de Tamanho
  outputBuffer.writeln('\n## 9. Estatísticas de Tamanho\n');
  if (sectionData['size_stats']!.isNotEmpty) {
    outputBuffer.writeln('| Tabela | Tamanho Total | Tamanho da Tabela | Tamanho dos Índices |');
    outputBuffer.writeln('|--------|---------------|-------------------|---------------------|');
    sectionData['size_stats']!.forEach((line) => outputBuffer.writeln('| $line |'));
  } else {
    outputBuffer.writeln('*Nenhuma informação de estatísticas de tamanho encontrada nos arquivos CSV*\n');
  }

  // Escrever arquivo de saída
  await File(outputFile).writeAsString(outputBuffer.toString());
  print('Documentação gerada com sucesso: $outputFile');
}

// Funções de parsing para cada tipo de dados

void parseTablesData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = line.split(',');
    if (parts.length >= 3) {
      final tableName = parts[0].replaceAll('"', '');
      final rowCount = parts[1].replaceAll('"', '');
      final description = parts.length > 2 ? parts[2].replaceAll('"', '') : '';
      
      output.add('| $tableName | $rowCount | $description |');
    }
  }
}

void parseColumnsData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 6) {
      final tableName = parts[0].replaceAll('"', '');
      final columnName = parts[1].replaceAll('"', '');
      final dataType = parts[2].replaceAll('"', '');
      final maxLength = parts[3].replaceAll('"', '');
      final isNullable = parts[4].replaceAll('"', '');
      final defaultValue = parts[5].replaceAll('"', '');
      final description = parts.length > 6 ? parts[6].replaceAll('"', '') : '';
      
      output.add('$tableName | $columnName | $dataType | $maxLength | $isNullable | $defaultValue | $description');
    }
  }
}

void parsePrimaryKeysData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 3) {
      final schema = parts[0].replaceAll('"', '');
      final tableName = parts[1].replaceAll('"', '');
      final columnName = parts[2].replaceAll('"', '');
      
      output.add('$schema | $tableName | $columnName');
    }
  }
}

void parseForeignKeysData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 6) {
      final schema = parts[0].replaceAll('"', '');
      final tableName = parts[1].replaceAll('"', '');
      final columnName = parts[2].replaceAll('"', '');
      final foreignSchema = parts[3].replaceAll('"', '');
      final foreignTable = parts[4].replaceAll('"', '');
      final foreignColumn = parts[5].replaceAll('"', '');
      
      output.add('$schema | $tableName | $columnName | $foreignSchema | $foreignTable | $foreignColumn');
    }
  }
}

void parseIndexesData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 3) {
      final tableName = parts[0].replaceAll('"', '');
      final indexName = parts[1].replaceAll('"', '');
      final indexDef = parts[2].replaceAll('"', '');
      
      output.add('$tableName | $indexName | $indexDef');
    }
  }
}

void parseTriggersData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 5) {
      final tableName = parts[0].replaceAll('"', '');
      final triggerName = parts[1].replaceAll('"', '');
      final timing = parts[2].replaceAll('"', '');
      final event = parts[3].replaceAll('"', '');
      final definition = parts[4].replaceAll('"', '');
      
      output.add('$tableName | $triggerName | $timing | $event | $definition');
    }
  }
}

void parseFunctionsData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 2) {
      final functionName = parts[0].replaceAll('"', '');
      final definition = parts[1].replaceAll('"', '');
      
      output.add('$functionName | $definition');
    }
  }
}

void parseViewsData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 2) {
      final viewName = parts[0].replaceAll('"', '');
      final definition = parts[1].replaceAll('"', '');
      
      output.add('$viewName | $definition');
    }
  }
}

void parsePoliciesData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 8) {
      final schema = parts[0].replaceAll('"', '');
      final tableName = parts[1].replaceAll('"', '');
      final policyName = parts[2].replaceAll('"', '');
      final permissive = parts[3].replaceAll('"', '');
      final roles = parts[4].replaceAll('"', '');
      final cmd = parts[5].replaceAll('"', '');
      final qual = parts[6].replaceAll('"', '');
      final withCheck = parts[7].replaceAll('"', '');
      
      output.add('$schema | $tableName | $policyName | $permissive | $roles | $cmd | $qual | $withCheck');
    }
  }
}

void parseExtensionsData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 4) {
      final name = parts[0].replaceAll('"', '');
      final defaultVersion = parts[1].replaceAll('"', '');
      final installedVersion = parts[2].replaceAll('"', '');
      final comment = parts[3].replaceAll('"', '');
      
      output.add('$name | $defaultVersion | $installedVersion | $comment');
    }
  }
}

void parseBucketsData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 5) {
      final name = parts[0].replaceAll('"', '');
      final owner = parts[1].replaceAll('"', '');
      final createdAt = parts[2].replaceAll('"', '');
      final updatedAt = parts[3].replaceAll('"', '');
      final isPublic = parts[4].replaceAll('"', '');
      
      output.add('$name | $owner | $createdAt | $updatedAt | $isPublic');
    }
  }
}

void parseJsonColumnsData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 4) {
      final tableName = parts[0].replaceAll('"', '');
      final columnName = parts[1].replaceAll('"', '');
      final dataType = parts[2].replaceAll('"', '');
      final description = parts[3].replaceAll('"', '');
      
      output.add('$tableName | $columnName | $dataType | $description');
    }
  }
}

void parseCustomTypesData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 4) {
      final typeName = parts[0].replaceAll('"', '');
      final typeType = parts[1].replaceAll('"', '');
      final enumValues = parts[2].replaceAll('"', '');
      final description = parts[3].replaceAll('"', '');
      
      output.add('$typeName | $typeType | $enumValues | $description');
    }
  }
}

void parseSizeStatsData(List<String> lines, List<String> output) {
  if (lines.length <= 1) return;
  
  // Pular a linha de cabeçalho
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i];
    final parts = csvSplit(line);
    if (parts.length >= 4) {
      final tableName = parts[0].replaceAll('"', '');
      final totalSize = parts[1].replaceAll('"', '');
      final tableSize = parts[2].replaceAll('"', '');
      final indexSize = parts[3].replaceAll('"', '');
      
      output.add('$tableName | $totalSize | $tableSize | $indexSize');
    }
  }
}

// Helper para dividir linhas CSV corretamente, respeitando aspas
List<String> csvSplit(String line) {
  final result = <String>[];
  bool inQuotes = false;
  StringBuffer currentValue = StringBuffer();
  
  for (int i = 0; i < line.length; i++) {
    final char = line[i];
    
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      result.add(currentValue.toString());
      currentValue = StringBuffer();
    } else {
      currentValue.write(char);
    }
  }
  
  // Adicionar o último valor
  result.add(currentValue.toString());
  
  return result;
} 