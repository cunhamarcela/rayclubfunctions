import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../goals/widgets/clean_goals_widget.dart';

/// Seção de metas para o dashboard principal
class GoalsSectionEnhanced extends ConsumerWidget {
  const GoalsSectionEnhanced({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const CleanGoalsWidget();
  }
}