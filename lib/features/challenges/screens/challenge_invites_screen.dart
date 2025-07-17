// Flutter imports:
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

/// Tela temporária para visualizar convites de desafios
@RoutePage()
class ChallengeInvitesScreen extends StatelessWidget {
  final String userId;
  
  const ChallengeInvitesScreen({
    Key? key,
    @PathParam('userId') required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Convites para Desafios'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text('Convites de Desafios para o usuário: $userId'),
            const SizedBox(height: 20),
            const Text('Carregando convites...'),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
} 