import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Execute este arquivo com: flutter run -d chrome diagnostico_supabase.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  
  print('🔍 DIAGNÓSTICO - Erro de Banco de Dados Supabase');
  print('=' * 60);
  
  diagnosticarErroBancoDados();
  
  print('\n🔧 SOLUÇÕES RECOMENDADAS:');
  print('1. Verificar RLS (Row Level Security) na tabela profiles');
  print('2. Verificar se a tabela auth.users aceita novos registros');
  print('3. Verificar triggers que podem estar falhando');
  print('4. Verificar constraints de tabela');
  print('5. Verificar permissões de inserção');
  
  print('\n📋 PRÓXIMOS PASSOS:');
  print('1. Acessar Supabase Dashboard');
  print('2. Verificar logs de erro detalhados');
  print('3. Verificar estrutura da tabela profiles');
  print('4. Testar inserção manual de usuário');
  
  runApp(const DiagnosticoApp());
}

class DiagnosticoApp extends StatelessWidget {
  const DiagnosticoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diagnóstico Supabase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DiagnosticoScreen(),
    );
  }
}

class DiagnosticoScreen extends StatefulWidget {
  const DiagnosticoScreen({Key? key}) : super(key: key);

  @override
  State<DiagnosticoScreen> createState() => _DiagnosticoScreenState();
}

class _DiagnosticoScreenState extends State<DiagnosticoScreen> {
  final _client = Supabase.instance.client;
  String _resultado = 'Clique em Iniciar Diagnóstico';
  bool _executando = false;
  double _progresso = 0.0;
  
  Future<void> _executarDiagnostico() async {
    setState(() {
      _executando = true;
      _resultado = 'Executando diagnóstico...\n';
      _progresso = 0.0;
    });
    
    try {
      final relatorio = StringBuffer();
      
      // Informações de conexão
      relatorio.writeln('=== INFORMAÇÕES DE CONEXÃO ===\n');
      relatorio.writeln('URL: ${_client.supabaseUrl}');
      relatorio.writeln('Sessão ativa: ${_client.auth.currentSession != null}');
      if (_client.auth.currentSession != null) {
        relatorio.writeln('Usuário: ${_client.auth.currentUser?.email}');
        relatorio.writeln('ID: ${_client.auth.currentUser?.id}');
      }
      relatorio.writeln('\n-------------------\n');
      
      _atualizarProgresso(0.1);
      
      // 1. Verificar estruturas de tabelas
      relatorio.writeln('=== ESTRUTURAS DE TABELAS ===\n');
      
      final tabelas = [
        'workout_records', 
        'challenge_check_ins', 
        'challenge_progress', 
        'user_progress',
        'challenges',
        'profiles'
      ];
      
      for (int i = 0; i < tabelas.length; i++) {
        final tabela = tabelas[i];
        relatorio.writeln('Tabela: $tabela');
        
        try {
          final colunas = await _client.rpc(
            'get_table_columns', 
            params: {'table_name_param': tabela}
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () => ['Timeout ao buscar colunas']
          );
          
          relatorio.writeln(colunas);
        } catch (e) {
          relatorio.writeln('Erro ao buscar colunas: $e');
          
          // Tentar método alternativo
          try {
            final colunas = await _client
                .from(tabela)
                .select()
                .limit(1);
            
            if (colunas is List && colunas.isNotEmpty) {
              relatorio.writeln('Colunas (baseado no primeiro registro):');
              relatorio.writeln(colunas.first.keys.join(', '));
            } else {
              relatorio.writeln('Tabela vazia ou inacessível');
            }
          } catch (e2) {
            relatorio.writeln('Erro no método alternativo: $e2');
          }
        }
        
        relatorio.writeln('-------------------\n');
        _atualizarProgresso(0.1 + (i + 1) * 0.05);
      }
      
      // 2. Verificar funções RPC relevantes
      relatorio.writeln('=== FUNÇÕES RPC ===\n');
      
      final funcoes = [
        'record_challenge_check_in_v2',
        'process_workout_for_dashboard',
        'process_workout_for_ranking',
        'get_dashboard_data',
        'get_current_streak',
        'has_checked_in_today',
        'add_points_to_progress',
        'recalculate_user_challenge_progress'
      ];
      
      for (int i = 0; i < funcoes.length; i++) {
        final funcao = funcoes[i];
        relatorio.writeln('Função: $funcao');
        
        try {
          // Verificar se a função existe
          final funcaoExiste = await _client.rpc(
            'function_exists',
            params: {'function_name_param': funcao}
          ).timeout(
            const Duration(seconds: 5),
            onTimeout: () => false
          );
          
          relatorio.writeln('Existe: ${funcaoExiste ?? 'Não foi possível verificar'}');
          
          if (funcaoExiste == true) {
            // Tentar obter a definição da função
            try {
              final funcaoDef = await _client.rpc(
                'get_function_definition',
                params: {'function_name_param': funcao}
              ).timeout(
                const Duration(seconds: 10),
                onTimeout: () => 'Timeout ao buscar definição'
              );
              
              relatorio.writeln('Definição (resumo):');
              final defStr = funcaoDef.toString();
              relatorio.writeln(defStr.length > 500 
                ? '${defStr.substring(0, 500)}...' 
                : defStr);
            } catch (e) {
              relatorio.writeln('Erro ao buscar definição: $e');
            }
          }
        } catch (e) {
          relatorio.writeln('Erro ao verificar função: $e');
        }
        
        relatorio.writeln('-------------------\n');
        _atualizarProgresso(0.4 + (i + 1) * 0.05);
      }
      
      // 3. Verificar triggers
      relatorio.writeln('=== TRIGGERS ===\n');
      
      final tabelasVerificarTriggers = [
        'workout_records', 
        'challenge_check_ins', 
        'challenge_progress', 
        'user_progress'
      ];
      
      for (int i = 0; i < tabelasVerificarTriggers.length; i++) {
        final tabela = tabelasVerificarTriggers[i];
        relatorio.writeln('Triggers para: $tabela');
        
        try {
          final triggers = await _client.rpc(
            'get_table_triggers',
            params: {'table_name_param': tabela}
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () => ['Timeout ao buscar triggers']
          );
          
          if (triggers is List && triggers.isNotEmpty) {
            for (final trigger in triggers) {
              relatorio.writeln(trigger);
            }
          } else {
            relatorio.writeln('Nenhum trigger encontrado');
          }
        } catch (e) {
          relatorio.writeln('Erro ao buscar triggers: $e');
        }
        
        relatorio.writeln('-------------------\n');
        _atualizarProgresso(0.6 + (i + 1) * 0.025);
      }
      
      // 4. Verificar registros recentes
      relatorio.writeln('=== REGISTROS RECENTES ===\n');
      
      // 4.1 Treinos recentes
      relatorio.writeln('Treinos recentes:');
      try {
        final treinos = await _client
            .from('workout_records')
            .select('id, user_id, workout_name, workout_type, date, duration_minutes, created_at')
            .order('created_at', ascending: false)
            .limit(5);
        
        if (treinos is List && treinos.isNotEmpty) {
          for (final treino in treinos) {
            relatorio.writeln(treino);
          }
        } else {
          relatorio.writeln('Nenhum treino encontrado');
        }
      } catch (e) {
        relatorio.writeln('Erro ao buscar treinos: $e');
      }
      relatorio.writeln('-------------------\n');
      
      _atualizarProgresso(0.7);
      
      // 4.2 Check-ins recentes
      relatorio.writeln('Check-ins recentes:');
      try {
        final checkins = await _client
            .from('challenge_check_ins')
            .select('id, user_id, challenge_id, check_in_date, points, workout_id, created_at')
            .order('created_at', ascending: false)
            .limit(5);
        
        if (checkins is List && checkins.isNotEmpty) {
          for (final checkin in checkins) {
            relatorio.writeln(checkin);
          }
        } else {
          relatorio.writeln('Nenhum check-in encontrado');
        }
      } catch (e) {
        relatorio.writeln('Erro ao buscar check-ins: $e');
      }
      relatorio.writeln('-------------------\n');
      
      _atualizarProgresso(0.8);
      
      // 4.3 Atualizações recentes de progresso
      relatorio.writeln('Progresso de desafios recente:');
      try {
        final progresso = await _client
            .from('challenge_progress')
            .select('id, user_id, challenge_id, points, check_ins_count, consecutive_days, updated_at')
            .order('updated_at', ascending: false)
            .limit(5);
        
        if (progresso is List && progresso.isNotEmpty) {
          for (final p in progresso) {
            relatorio.writeln(p);
          }
        } else {
          relatorio.writeln('Nenhum progresso encontrado');
        }
      } catch (e) {
        relatorio.writeln('Erro ao buscar progresso: $e');
      }
      relatorio.writeln('-------------------\n');
      
      _atualizarProgresso(0.9);
      
      // 5. Verificar logs de erros
      relatorio.writeln('=== LOGS DE ERROS ===\n');
      try {
        final erros = await _client
            .from('check_in_error_logs')
            .select('id, user_id, challenge_id, workout_id, error_message, created_at')
            .order('created_at', ascending: false)
            .limit(10);
        
        if (erros is List && erros.isNotEmpty) {
          for (final erro in erros) {
            relatorio.writeln(erro);
          }
        } else {
          relatorio.writeln('Nenhum erro encontrado');
        }
      } catch (e) {
        relatorio.writeln('Tabela de logs não encontrada ou erro: $e');
      }
      
      _atualizarProgresso(1.0);
      
      // Salvar relatório em arquivo
      try {
        final arquivo = File('diagnostico_supabase_${DateTime.now().millisecondsSinceEpoch}.txt');
        await arquivo.writeAsString(relatorio.toString());
        
        setState(() {
          _resultado = 'Diagnóstico concluído!\n\nRelatório salvo em: ${arquivo.path}\n\n============ RELATÓRIO ============\n\n${relatorio.toString()}';
          _executando = false;
        });
      } catch (e) {
        setState(() {
          _resultado = 'Diagnóstico concluído, mas não foi possível salvar em arquivo: $e\n\n============ RELATÓRIO ============\n\n${relatorio.toString()}';
          _executando = false;
        });
      }
    } catch (e) {
      setState(() {
        _resultado = 'Erro ao executar diagnóstico: $e';
        _executando = false;
      });
    }
  }
  
  void _atualizarProgresso(double valor) {
    if (mounted) {
      setState(() {
        _progresso = valor;
      });
    }
  }

  /// Verifica se há funções RPC utilitárias necessárias para o diagnóstico
  /// e cria elas temporariamente se não existirem
  Future<void> _verificarCriarFuncoesUtilitarias() async {
    // Função para verificar se uma função existe
    try {
      await _client.rpc('function_exists', params: {'function_name_param': 'get_dashboard_data'});
      print('Função function_exists já existe');
    } catch (e) {
      print('Criando função function_exists...');
      try {
        // Criar função temporária
        await _client.rpc('create_function_exists');
      } catch (e) {
        print('Erro ao criar function_exists: $e');
      }
    }
    
    // Função para obter colunas de uma tabela
    try {
      await _client.rpc('get_table_columns', params: {'table_name_param': 'workout_records'});
      print('Função get_table_columns já existe');
    } catch (e) {
      print('Criando função get_table_columns...');
      try {
        // Criar função temporária
        await _client.rpc('create_get_table_columns');
      } catch (e) {
        print('Erro ao criar get_table_columns: $e');
      }
    }
    
    // Função para obter triggers de uma tabela
    try {
      await _client.rpc('get_table_triggers', params: {'table_name_param': 'workout_records'});
      print('Função get_table_triggers já existe');
    } catch (e) {
      print('Criando função get_table_triggers...');
      try {
        // Criar função temporária
        await _client.rpc('create_get_table_triggers');
      } catch (e) {
        print('Erro ao criar get_table_triggers: $e');
      }
    }
    
    // Função para obter definição de uma função
    try {
      await _client.rpc('get_function_definition', params: {'function_name_param': 'get_dashboard_data'});
      print('Função get_function_definition já existe');
    } catch (e) {
      print('Criando função get_function_definition...');
      try {
        // Criar função temporária
        await _client.rpc('create_get_function_definition');
      } catch (e) {
        print('Erro ao criar get_function_definition: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Verificar e criar funções utilitárias necessárias
    _verificarCriarFuncoesUtilitarias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnóstico Supabase - Ray Club App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Análise de Problemas no Dashboard e Ranking',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Este diagnóstico coletará informações sobre tabelas, funções RPC e dados recentes para identificar problemas na atualização do dashboard e ranking.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _executando ? null : _executarDiagnostico,
                      icon: Icon(_executando ? Icons.hourglass_empty : Icons.play_arrow),
                      label: Text(_executando ? 'Executando...' : 'Iniciar Diagnóstico'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_executando)
              Column(
                children: [
                  LinearProgressIndicator(value: _progresso),
                  const SizedBox(height: 8),
                  Text('Progresso: ${(_progresso * 100).toStringAsFixed(0)}%'),
                  const SizedBox(height: 16),
                ],
              ),
            Expanded(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      _resultado,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_executando)
              ElevatedButton.icon(
                onPressed: () {
                  // Copiar resultado para a área de transferência
                  final data = ClipboardData(text: _resultado);
                  Clipboard.setData(data);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Resultado copiado para a área de transferência'))
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copiar Resultado'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Extensões úteis para o Supabase
extension SupabaseClientExtension on SupabaseClient {
  // Método para executar RPC com validação de UUIDs
  Future<dynamic> rpcWithValidUuids(String function, {Map<String, dynamic>? params}) async {
    // Converter UUIDs para string
    if (params != null) {
      params.forEach((key, value) {
        if (value != null && value is String && _isUuid(value)) {
          // Garantir que o UUID seja válido
          params[key] = value.replaceAll('-', '').toLowerCase();
        }
      });
    }
    
    return rpc(function, params: params);
  }
  
  // Verificar se uma string é um UUID válido
  bool _isUuid(String str) {
    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false
    );
    return uuidPattern.hasMatch(str);
  }
}

void diagnosticarErroBancoDados() {
  print('\n🎯 ERRO ATUAL IDENTIFICADO:');
  print('❌ Code: 500');
  print('❌ Message: Database error saving new user');
  print('');
  print('💡 SIGNIFICADO:');
  print('- Apple Sign In funciona ✅');
  print('- Supabase aceita o token ✅');
  print('- Erro ao inserir usuário na tabela ❌');
  
  print('\n🔍 POSSÍVEIS CAUSAS:');
  print('1. 🛡️  RLS (Row Level Security) muito restritivo');
  print('2. 📋 Trigger falhando na tabela profiles');
  print('3. 🗃️  Constraint/validação de campo falhando');
  print('4. 🔑 Campo obrigatório faltando (email, etc.)');
  print('5. 📊 Problema de schema/estrutura da tabela');
  print('6. 🔒 Permissões insuficientes para auth.users');
  
  print('\n🎯 ÁREAS PARA VERIFICAR NO SUPABASE:');
  print('🔍 Table Editor → auth.users');
  print('🔍 Table Editor → public.profiles');
  print('🔍 Authentication → Settings');
  print('🔍 Database → Functions (triggers)');
  print('🔍 Logs → Ver erros detalhados');
  
  print('\n📝 INFORMAÇÕES DO USUÁRIO APPLE:');
  print('👤 User ID: 000212.6a49ad8ab54345e599af07eb43121ce8.2028');
  print('📧 Email: não fornecido (pode ser o problema!)');
  print('📛 Nome: vazio');
  print('');
  print('⚠️  POSSÍVEL PROBLEMA: Email é obrigatório mas Apple não forneceu');
} 