import 'package:flutter/material.dart';
import 'test_profile_persistence_fix.dart';

/// Exemplo de como executar o teste de persistência do perfil
/// Cole este código em qualquer lugar do seu app para testar

class TestProfileButton extends StatelessWidget {
  const TestProfileButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Executar o teste completo
        print('🧪 Iniciando teste de persistência...');
        await ProfilePersistenceTest.runProfilePersistenceTest();
        
        // Executar teste de coluna gerada
        print('\n🧪 Iniciando teste de coluna gerada...');
        await ProfilePersistenceTest.testGeneratedColumn();
        
        print('\n✅ Testes concluídos! Verifique os logs no console.');
      },
      child: const Text('🧪 Testar Persistência do Perfil'),
    );
  }
}

/// OU use esta função em qualquer lugar:
Future<void> executarTestePersistencia() async {
  print('🧪 === INICIANDO TESTES DE PERSISTÊNCIA ===');
  
  try {
    // Teste completo
    await ProfilePersistenceTest.runProfilePersistenceTest();
    
    // Teste de coluna gerada  
    await ProfilePersistenceTest.testGeneratedColumn();
    
    print('\n🎉 TODOS OS TESTES CONCLUÍDOS!');
    print('📊 Verifique os logs acima para ver os resultados.');
    
  } catch (e) {
    print('❌ Erro durante os testes: $e');
  }
} 