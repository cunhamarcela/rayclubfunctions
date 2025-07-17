// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Script para limpar os desafios existentes e criar um novo desafio de teste
/// 
/// Como usar: 
/// 1. Execute o comando no terminal:
///    flutter run -t lib/scripts/create_test_challenge.dart
///
/// ATENÇÃO: Este script apagará todos os desafios existentes!
void main() async {
  // Inicializar ambiente
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  
  // Inicializar Supabase  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const ChallengeCreatorApp());
}

class ChallengeCreatorApp extends StatelessWidget {
  const ChallengeCreatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Criador de Desafio de Teste'),
        ),
        body: const ChallengeCreator(),
      ),
    );
  }
}

class ChallengeCreator extends StatefulWidget {
  const ChallengeCreator({Key? key}) : super(key: key);

  @override
  State<ChallengeCreator> createState() => _ChallengeCreatorState();
}

class _ChallengeCreatorState extends State<ChallengeCreator> {
  final SupabaseClient _client = Supabase.instance.client;
  String _status = 'Pronto para iniciar';
  bool _isLoading = false;
  bool _isCompleted = false;
  String? _challengeId;
  
  Future<void> _deleteAllChallenges() async {
    try {
      setState(() {
        _status = 'Apagando registros de check-in...';
      });
      
      // Apagar registros de check-in
      await _client.from('challenge_check_ins').delete().neq('id', '');
      
      setState(() {
        _status = 'Apagando registros de progresso...';
      });
      
      // Apagar registros de progresso
      await _client.from('challenge_progress').delete().neq('id', '');
      
      setState(() {
        _status = 'Apagando registros de participantes...';
      });
      
      // Apagar registros de participantes
      await _client.from('challenge_participants').delete().neq('id', '');
      
      setState(() {
        _status = 'Apagando desafios...';
      });
      
      // Apagar desafios
      await _client.from('challenges').delete().neq('id', '');
      
      setState(() {
        _status = 'Todos os desafios foram apagados com sucesso!';
      });
    } catch (e) {
      setState(() {
        _status = 'Erro ao apagar desafios: $e';
      });
      rethrow;
    }
  }
  
  Future<String> _createTestChallenge() async {
    try {
      setState(() {
        _status = 'Criando novo desafio de teste...';
      });
      
      // Data inicial = hoje
      final startDate = DateTime.now();
      
      // Data final = hoje + 3 dias
      final endDate = startDate.add(const Duration(days: 3));
      
      // Formatar datas para ISO 8601
      final startIso = startDate.toIso8601String();
      final endIso = endDate.toIso8601String();
      
      // Dados do desafio
      final challengeData = {
        'title': 'Desafio de Teste (3 dias)',
        'description': 'Este é um desafio de teste com duração de 3 dias criado para fins de teste.',
        'start_date': startIso,
        'end_date': endIso,
        'image_url': 'https://picsum.photos/seed/rayclub/800/600', // Imagem aleatória
        'type': 'workout',
        'points': 100,
        'is_official': true,
        'active': true,
        'created_at': startIso,
        'updated_at': startIso,
      };
      
      // Inserir desafio
      final response = await _client.from('challenges').insert(challengeData).select();
      
      if (response.isEmpty) {
        throw Exception('Falha ao criar desafio: resposta vazia');
      }
      
      final challengeId = response[0]['id'] as String;
      
      setState(() {
        _status = 'Desafio criado com sucesso! ID: $challengeId';
        _challengeId = challengeId;
      });
      
      return challengeId;
    } catch (e) {
      setState(() {
        _status = 'Erro ao criar desafio: $e';
      });
      rethrow;
    }
  }
  
  Future<void> _runFullProcess() async {
    try {
      setState(() {
        _isLoading = true;
        _isCompleted = false;
      });
      
      // Limpar desafios existentes
      await _deleteAllChallenges();
      
      // Criar novo desafio
      final challengeId = await _createTestChallenge();
      
      setState(() {
        _status = '''
Processo concluído com sucesso!

Desafio criado:
- ID: $challengeId
- Título: Desafio de Teste (3 dias)
- Duração: 3 dias
- Início: Hoje
- Término: Daqui a 3 dias

Agora você pode:
1. Logar com diferentes usuários no app
2. Entrar no desafio recém-criado
3. Verificar se o desafio aparece no dashboard
''';
        _isLoading = false;
        _isCompleted = true;
      });
    } catch (e) {
      setState(() {
        _status = 'Erro durante o processo: $e';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'ATENÇÃO: Esta operação irá APAGAR TODOS os desafios existentes!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _status,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (!_isCompleted)
              ElevatedButton(
                onPressed: _runFullProcess,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Apagar Desafios Existentes e Criar Novo',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              )
            else
              Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'ID do Desafio: $_challengeId',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_challengeId != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ID copiado: $_challengeId')),
                        );
                      }
                    },
                    child: const Text('Copiar ID do Desafio'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
} 