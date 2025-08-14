// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:ray_club_app/core/widgets/app_bar_widget.dart';
import 'package:ray_club_app/features/goals/widgets/clean_goals_widget.dart';

/// Tela principal de metas simplificada
@RoutePage()
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'Minhas Metas',
        showBackButton: true,
      ),
      body: const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Minhas Metas ✨',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Defina metas por categoria e veja seu progresso atualizar automaticamente quando registrar exercícios! 🎯',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 24),
              
              // Widget de metas limpo
              CleanGoalsWidget(),
              
              SizedBox(height: 100), // Espaço extra no final
            ],
          ),
        ),
      ),
    );
  }
}