#!/usr/bin/env dart

import 'dart:io';

/// Script para corrigir problemas comuns nos testes
void main() async {
  print('🔧 Iniciando correção dos testes...\n');

  // Lista de correções a serem aplicadas
  final fixes = [
    _fixChallengeConstructors,
    _fixChallengeProgressConstructors,
    _fixWorkoutExerciseConstructors,
    _fixMissingImports,
    _fixMockImplementations,
    _removeDebugPrints,
  ];

  for (final fix in fixes) {
    await fix();
  }

  print('\n✅ Correção dos testes concluída!');
}

/// Corrige construtores de Challenge que precisam de parâmetros obrigatórios
Future<void> _fixChallengeConstructors() async {
  print('📝 Corrigindo construtores de Challenge...');
  
  final testFiles = await _getTestFiles();
  
  for (final file in testFiles) {
    String content = await file.readAsString();
    
    // Corrigir Challenge() sem parâmetros obrigatórios
    content = content.replaceAllMapped(
      RegExp(r'Challenge\(\s*([^)]*)\s*\)'),
      (match) {
        final params = match.group(1) ?? '';
        if (!params.contains('id:') || !params.contains('title:')) {
          return '''Challenge(
        id: 'test-id',
        title: 'Test Challenge',
        description: 'Test Description',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
        points: 100,
        type: ChallengeType.fitness,
        $params
      )''';
        }
        return match.group(0)!;
      },
    );
    
    await file.writeAsString(content);
  }
}

/// Corrige construtores de ChallengeProgress
Future<void> _fixChallengeProgressConstructors() async {
  print('📝 Corrigindo construtores de ChallengeProgress...');
  
  final testFiles = await _getTestFiles();
  
  for (final file in testFiles) {
    String content = await file.readAsString();
    
    content = content.replaceAllMapped(
      RegExp(r'ChallengeProgress\(\s*([^)]*)\s*\)'),
      (match) {
        final params = match.group(1) ?? '';
        if (!params.contains('challengeId:') || !params.contains('userId:')) {
          return '''ChallengeProgress(
        id: 'progress-id',
        challengeId: 'challenge-id',
        userId: 'user-id',
        userName: 'Test User',
        points: 0,
        position: 1,
        createdAt: DateTime.now(),
        $params
      )''';
        }
        return match.group(0)!;
      },
    );
    
    await file.writeAsString(content);
  }
}

/// Corrige construtores de WorkoutExercise
Future<void> _fixWorkoutExerciseConstructors() async {
  print('📝 Corrigindo construtores de WorkoutExercise...');
  
  final testFiles = await _getTestFiles();
  
  for (final file in testFiles) {
    String content = await file.readAsString();
    
    content = content.replaceAllMapped(
      RegExp(r'WorkoutExercise\(\s*([^)]*)\s*\)'),
      (match) {
        final params = match.group(1) ?? '';
        if (!params.contains('id:') || !params.contains('detail:')) {
          return '''WorkoutExercise(
        id: 'exercise-id',
        detail: 'Test Exercise',
        duration: 30,
        sets: 3,
        reps: 10,
        $params
      )''';
        }
        return match.group(0)!;
      },
    );
    
    await file.writeAsString(content);
  }
}

/// Corrige imports que faltam
Future<void> _fixMissingImports() async {
  print('📦 Corrigindo imports faltantes...');
  
  final testFiles = await _getTestFiles();
  
  for (final file in testFiles) {
    String content = await file.readAsString();
    
    // Remover imports que não existem mais
    final badImports = [
      "import 'package:ray_club_app/features/challenges/repositories/challenge_group_repository.dart';",
      "import 'package:ray_club_app/features/challenges/viewmodels/challenge_group_state.dart';",
    ];
    
    for (final badImport in badImports) {
      content = content.replaceAll('$badImport\n', '');
      content = content.replaceAll(badImport, '');
    }
    
    // Remover imports de events e location que não existem
    content = content.replaceAll(RegExp(r"import 'package:ray_club_app/features/events/[^']*';\s*\n?"), '');
    content = content.replaceAll(RegExp(r"import 'package:ray_club_app/features/location/[^']*';\s*\n?"), '');
    
    await file.writeAsString(content);
  }
}

/// Corrige implementações de Mock
Future<void> _fixMockImplementations() async {
  print('🎭 Corrigindo implementações de Mock...');
  
  final testFiles = await _getTestFiles();
  
  for (final file in testFiles) {
    String content = await file.readAsString();
    
    // Corrigir implementações de Mock incorretas
    content = content.replaceAll('class MockChallengeGroupRepository extends Mock implements ChallengeGroupRepository', 'class MockChallengeRepository extends Mock implements ChallengeRepository');
    content = content.replaceAll('class MockAuthRepository extends Mock implements AuthRepository', 'class MockAuthRepository extends Mock implements IAuthRepository');
    
    // Corrigir nomes de variáveis
    content = content.replaceAll('MockChallengeGroupRepository', 'MockChallengeRepository');
    
    await file.writeAsString(content);
  }
}

/// Remove prints de debug que causam warnings
Future<void> _removeDebugPrints() async {
  print('🗑️ Removendo prints de debug...');
  
  final debugFiles = [
    'test_apple_signin_config.dart',
    'test_config_simple.dart',
    'test_navigation_fix.dart',
    'test_supabase_oauth.dart',
    'verificar_apple_oauth_supabase.dart',
  ];
  
  for (final fileName in debugFiles) {
    final file = File(fileName);
    if (await file.exists()) {
      String content = await file.readAsString();
      
      // Comentar todas as linhas de print
      content = content.replaceAllMapped(
        RegExp(r'^(\s*)(print\(.+\);)', multiLine: true),
        (match) => '${match.group(1)}// ${match.group(2)}',
      );
      
      await file.writeAsString(content);
    }
  }
}

/// Obtém lista de arquivos de teste
Future<List<File>> _getTestFiles() async {
  final testDir = Directory('test');
  if (!await testDir.exists()) return [];
  
  final files = <File>[];
  await for (final entity in testDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('_test.dart')) {
      files.add(entity);
    }
  }
  return files;
} 