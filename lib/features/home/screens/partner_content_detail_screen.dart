// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/home/screens/home_screen.dart';
import 'package:ray_club_app/features/home/models/partner_content.dart';

@RoutePage()
class PartnerContentDetailScreen extends ConsumerWidget {
  final PartnerContent content;
  final String studioName;

  const PartnerContentDetailScreen({
    Key? key,
    required this.content,
    required this.studioName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conteúdo temporariamente indisponível'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 24),
            Text(
              'Este conteúdo está temporariamente indisponível',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Estamos trabalhando para disponibilizar novos vídeos em breve.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => context.router.maybePop(),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
} 