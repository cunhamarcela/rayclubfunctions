// Flutter imports:
import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:ray_club_app/core/constants/app_colors.dart';
import 'package:ray_club_app/core/constants/privacy_policy.dart';

/// Tela que exibe a política de privacidade completa
@RoutePage()
class PrivacyPolicyScreen extends StatelessWidget {
  /// Construtor padrão
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  /// Rota para esta tela
  static const String routeName = '/privacy-policy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(PrivacyPolicy.title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: MarkdownWidget(
            data: PrivacyPolicy.content,
            config: MarkdownConfig(
              configs: [
                H1Config(
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                H2Config(
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                H3Config(
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                PConfig(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget que exibe um diálogo com a versão resumida da política de privacidade
class PrivacyPolicyDialog extends StatelessWidget {
  /// Construtor padrão
  const PrivacyPolicyDialog({Key? key}) : super(key: key);

  /// Exibe o diálogo de política de privacidade
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => const PrivacyPolicyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(PrivacyPolicy.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              PrivacyPolicy.shortVersion,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(PrivacyPolicyScreen.routeName);
              },
              child: const Text('Ver política completa'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Recusar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Aceitar'),
        ),
      ],
    );
  }
} 