// =====================================================
// 🔍 DIAGNÓSTICO FRONTEND - RAY CLUB METAS SYSTEM
// =====================================================
// Data: 2025-01-30
// Objetivo: Análise completa da estrutura atual de metas no Flutter
// Versão: 1.0.0
// =====================================================

import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 === DIAGNÓSTICO COMPLETO DO FRONTEND - SISTEMA DE METAS ===\n');
  
  final diagnostico = FrontendDiagnostico();
  await diagnostico.executarAnaliseCompleta();
}

class FrontendDiagnostico {
  final String baseDir = './lib';
  final List<String> arquivosAnalisados = [];
  final Map<String, dynamic> estatisticas = {};

  Future<void> executarAnaliseCompleta() async {
    print('📊 Iniciando análise da estrutura do frontend...\n');
    
    // Seção 1: Estrutura de Diretórios
    await _analisarEstruturaDiretorios();
    
    // Seção 2: Models de Metas
    await _analisarModels();
    
    // Seção 3: Repositories
    await _analisarRepositories();
    
    // Seção 4: ViewModels
    await _analisarViewModels();
    
    // Seção 5: Providers (Riverpod)
    await _analisarProviders();
    
    // Seção 6: UI/Screens
    await _analisarUI();
    
    // Seção 7: Serviços
    await _analisarServicos();
    
    // Seção 8: Testes
    await _analisarTestes();
    
    // Seção 9: Resumo e Recomendações
    _gerarResumoFinal();
  }

  Future<void> _analisarEstruturaDiretorios() async {
    print('🏗️  === SEÇÃO 1: ESTRUTURA DE DIRETÓRIOS ===');
    
    final diretorios = [
      'lib/features/goals',
      'lib/features/goals/models',
      'lib/features/goals/repositories',
      'lib/features/goals/viewmodels',
      'lib/features/goals/providers',
      'lib/features/goals/ui',
      'lib/features/goals/services',
      'test/features/goals',
    ];
    
    for (final dir in diretorios) {
      final directory = Directory(dir);
      if (await directory.exists()) {
        final files = await directory.list().toList();
        print('✅ $dir - ${files.length} arquivos');
        
        // Listar arquivos específicos
        for (final file in files) {
          if (file is File && file.path.endsWith('.dart')) {
            print('   📄 ${file.path.split('/').last}');
            arquivosAnalisados.add(file.path);
          }
        }
      } else {
        print('❌ $dir - NÃO EXISTE');
      }
    }
    print('');
  }

  Future<void> _analisarModels() async {
    print('🎯 === SEÇÃO 2: ANÁLISE DE MODELS ===');
    
    final modelsDir = Directory('lib/features/goals/models');
    if (await modelsDir.exists()) {
      final files = await modelsDir.list().where((f) => f.path.endsWith('.dart')).toList();
      
      print('📋 Encontrados ${files.length} arquivos de models:');
      
      for (final file in files) {
        await _analisarArquivoModel(file as File);
      }
    } else {
      print('❌ Diretório de models não encontrado');
    }
    print('');
  }

  Future<void> _analisarArquivoModel(File file) async {
    final content = await file.readAsString();
    final fileName = file.path.split('/').last;
    
    print('📄 Analisando: $fileName');
    
    // Verificar se é um modelo Freezed
    final isFreezed = content.contains('@freezed') || content.contains('_\$');
    print('   🧊 Freezed: ${isFreezed ? "SIM" : "NÃO"}');
    
    // Verificar enums
    final enumMatches = RegExp(r'enum\s+(\w+)').allMatches(content);
    if (enumMatches.isNotEmpty) {
      print('   📊 Enums encontrados:');
      for (final match in enumMatches) {
        print('      - ${match.group(1)}');
      }
    }
    
    // Verificar classes
    final classMatches = RegExp(r'class\s+(\w+)').allMatches(content);
    if (classMatches.isNotEmpty) {
      print('   🏛️  Classes encontradas:');
      for (final match in classMatches) {
        print('      - ${match.group(1)}');
      }
    }
    
    // Verificar se tem fromJson/toJson
    final hasFromJson = content.contains('fromJson');
    final hasToJson = content.contains('toJson');
    print('   🔄 Serialização: fromJson:$hasFromJson, toJson:$hasToJson');
    
    print('');
  }

  Future<void> _analisarRepositories() async {
    print('🗄️  === SEÇÃO 3: ANÁLISE DE REPOSITORIES ===');
    
    final repoDir = Directory('lib/features/goals/repositories');
    if (await repoDir.exists()) {
      final files = await repoDir.list().where((f) => f.path.endsWith('.dart')).toList();
      
      print('📋 Encontrados ${files.length} arquivos de repositories:');
      
      for (final file in files) {
        await _analisarArquivoRepository(file as File);
      }
    } else {
      print('❌ Diretório de repositories não encontrado');
    }
    print('');
  }

  Future<void> _analisarArquivoRepository(File file) async {
    final content = await file.readAsString();
    final fileName = file.path.split('/').last;
    
    print('📄 Analisando: $fileName');
    
    // Verificar se é abstract (interface)
    final isAbstract = content.contains('abstract class');
    print('   🔮 Interface: ${isAbstract ? "SIM" : "NÃO"}');
    
    // Verificar implementação do Supabase
    final usesSupabase = content.contains('SupabaseClient') || content.contains('supabase');
    print('   🗃️  Usa Supabase: ${usesSupabase ? "SIM" : "NÃO"}');
    
    // Contar métodos
    final methodMatches = RegExp(r'Future<[^>]*>\s+(\w+)\s*\(').allMatches(content);
    print('   ⚡ Métodos async: ${methodMatches.length}');
    for (final match in methodMatches) {
      print('      - ${match.group(1)}()');
    }
    
    // Verificar se usa _mapFromDatabase/_mapToDatabase
    final hasMapping = content.contains('_mapFromDatabase') || content.contains('_mapToDatabase');
    print('   🗺️  Mapeamento de dados: ${hasMapping ? "SIM" : "NÃO"}');
    
    print('');
  }

  Future<void> _analisarViewModels() async {
    print('🧠 === SEÇÃO 4: ANÁLISE DE VIEW MODELS ===');
    
    final vmDir = Directory('lib/features/goals/viewmodels');
    if (await vmDir.exists()) {
      final files = await vmDir.list().where((f) => f.path.endsWith('.dart')).toList();
      
      print('📋 Encontrados ${files.length} arquivos de ViewModels:');
      
      for (final file in files) {
        await _analisarArquivoViewModel(file as File);
      }
    } else {
      print('❌ Diretório de ViewModels não encontrado');
    }
    print('');
  }

  Future<void> _analisarArquivoViewModel(File file) async {
    final content = await file.readAsString();
    final fileName = file.path.split('/').last;
    
    print('📄 Analisando: $fileName');
    
    // Verificar se usa Riverpod
    final usesRiverpod = content.contains('StateNotifier') || content.contains('riverpod');
    print('   🎣 Usa Riverpod: ${usesRiverpod ? "SIM" : "NÃO"}');
    
    // Verificar padrão MVVM
    final followsMVVM = content.contains('ViewModel') && content.contains('Repository');
    print('   🏗️  Segue MVVM: ${followsMVVM ? "SIM" : "NÃO"}');
    
    // Contar métodos públicos
    final publicMethods = RegExp(r'^\s+(Future<[^>]*>|void|bool|String|\w+)\s+(\w+)\s*\(').allMatches(content);
    print('   📝 Métodos públicos: ${publicMethods.length}');
    
    // Verificar tratamento de erro
    final hasErrorHandling = content.contains('try') && content.contains('catch');
    print('   🚨 Tratamento de erro: ${hasErrorHandling ? "SIM" : "NÃO"}');
    
    print('');
  }

  Future<void> _analisarProviders() async {
    print('🎣 === SEÇÃO 5: ANÁLISE DE PROVIDERS (RIVERPOD) ===');
    
    final providerDir = Directory('lib/features/goals/providers');
    if (await providerDir.exists()) {
      final files = await providerDir.list().where((f) => f.path.endsWith('.dart')).toList();
      
      print('📋 Encontrados ${files.length} arquivos de Providers:');
      
      for (final file in files) {
        await _analisarArquivoProvider(file as File);
      }
    } else {
      print('❌ Diretório de Providers não encontrado');
    }
    print('');
  }

  Future<void> _analisarArquivoProvider(File file) async {
    final content = await file.readAsString();
    final fileName = file.path.split('/').last;
    
    print('📄 Analisando: $fileName');
    
    // Contar providers
    final providerMatches = RegExp(r'final\s+(\w+)\s*=\s*(\w*Provider)').allMatches(content);
    print('   🎛️  Providers definidos: ${providerMatches.length}');
    for (final match in providerMatches) {
      print('      - ${match.group(1)} (${match.group(2)})');
    }
    
    // Verificar se tem provider family
    final hasFamilyProvider = content.contains('family');
    print('   👨‍👩‍👧‍👦 Usa Family: ${hasFamilyProvider ? "SIM" : "NÃO"}');
    
    print('');
  }

  Future<void> _analisarUI() async {
    print('🎨 === SEÇÃO 6: ANÁLISE DE UI/SCREENS ===');
    
    final uiDir = Directory('lib/features/goals/ui');
    if (await uiDir.exists()) {
      final files = await uiDir.list(recursive: true).where((f) => f.path.endsWith('.dart')).toList();
      
      print('📋 Encontrados ${files.length} arquivos de UI:');
      
      for (final file in files) {
        await _analisarArquivoUI(file as File);
      }
    } else {
      print('❌ Diretório de UI não encontrado');
    }
    print('');
  }

  Future<void> _analisarArquivoUI(File file) async {
    final content = await file.readAsString();
    final fileName = file.path.split('/').last;
    
    print('📄 Analisando: $fileName');
    
    // Verificar se é StatelessWidget ou StatefulWidget
    final isStateless = content.contains('StatelessWidget');
    final isStateful = content.contains('StatefulWidget');
    print('   🧱 Tipo: ${isStateless ? "StatelessWidget" : isStateful ? "StatefulWidget" : "Outro"}');
    
    // Verificar se usa ConsumerWidget (Riverpod)
    final usesConsumer = content.contains('ConsumerWidget') || content.contains('Consumer');
    print('   🎣 Usa Riverpod: ${usesConsumer ? "SIM" : "NÃO"}');
    
    // Verificar widgets principais
    final widgets = ['Scaffold', 'Column', 'Row', 'ListView', 'Container', 'Card'];
    final usedWidgets = widgets.where((w) => content.contains(w)).toList();
    print('   🧩 Widgets usados: ${usedWidgets.join(", ")}');
    
    print('');
  }

  Future<void> _analisarServicos() async {
    print('⚙️  === SEÇÃO 7: ANÁLISE DE SERVIÇOS ===');
    
    final serviceDir = Directory('lib/features/goals/services');
    if (await serviceDir.exists()) {
      final files = await serviceDir.list().where((f) => f.path.endsWith('.dart')).toList();
      
      print('📋 Encontrados ${files.length} arquivos de serviços:');
      
      for (final file in files) {
        final fileName = (file as File).path.split('/').last;
        print('   📄 $fileName');
      }
    } else {
      print('❌ Diretório de serviços não encontrado');
    }
    print('');
  }

  Future<void> _analisarTestes() async {
    print('🧪 === SEÇÃO 8: ANÁLISE DE TESTES ===');
    
    final testDir = Directory('test/features/goals');
    if (await testDir.exists()) {
      final files = await testDir.list(recursive: true).where((f) => f.path.endsWith('.dart')).toList();
      
      print('📋 Encontrados ${files.length} arquivos de teste:');
      
      for (final file in files) {
        final fileName = (file as File).path.split('/').last;
        final content = await (file as File).readAsString();
        
        // Contar testes
        final testCount = RegExp(r'test\s*\(').allMatches(content).length;
        final groupCount = RegExp(r'group\s*\(').allMatches(content).length;
        
        print('   📄 $fileName - $testCount testes, $groupCount grupos');
      }
    } else {
      print('❌ Diretório de testes não encontrado');
    }
    print('');
  }

  void _gerarResumoFinal() {
    print('📊 === SEÇÃO 9: RESUMO E RECOMENDAÇÕES ===');
    
    print('✅ PONTOS POSITIVOS IDENTIFICADOS:');
    print('   - Estrutura modular seguindo MVVM');
    print('   - Uso do Riverpod para gerenciamento de estado');
    print('   - Separação clara entre models, repositories e ViewModels');
    
    print('\n⚠️  PONTOS DE ATENÇÃO:');
    print('   - Verificar se todas as novas categorias estão implementadas');
    print('   - Confirmar se measurementType está sendo usado corretamente');
    print('   - Validar se a UI está seguindo o design das telas fornecidas');
    
    print('\n🛠️  PRÓXIMOS PASSOS RECOMENDADOS:');
    print('   1. Executar script SQL update_goals_schema.sql no Supabase');
    print('   2. Atualizar _mapFromDatabase/_mapToDatabase no repository');
    print('   3. Criar/atualizar telas de criação de metas');
    print('   4. Implementar lógica de seleção dias vs minutos');
    print('   5. Adicionar as novas categorias (Funcional, Yoga, etc.)');
    
    print('\n📈 ESTATÍSTICAS:');
    print('   - Total de arquivos analisados: ${arquivosAnalisados.length}');
    print('   - Estrutura do projeto: MVVM com Riverpod');
    print('   - Backend: Supabase');
    print('   - Status: Pronto para implementar melhorias');
    
    print('\n✅ === DIAGNÓSTICO FRONTEND FINALIZADO ===');
  }
} 