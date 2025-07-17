// Debug test file para verificar se o botão está funcionando
// Execute este arquivo para ver os logs de debug no console

import 'package:flutter/material.dart';

void main() {
  runApp(const DebugButtonApp());
}

class DebugButtonApp extends StatelessWidget {
  const DebugButtonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Debug Button Test')),
        body: Center(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 80),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                print('📣 BOTÃO TESTE PRESSIONADO - FUNCIONANDO!');
                debugPrint('🚀 Teste clique: Botão está responsivo');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Botão funcionando! Navegaria para histórico'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.history, color: Colors.white),
              label: const Text(
                'Ver Histórico de Treinos (TESTE)',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 