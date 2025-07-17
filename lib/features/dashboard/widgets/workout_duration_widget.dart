// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/theme/app_typography.dart';
import 'package:ray_club_app/features/dashboard/providers/dashboard_providers.dart';

/// Widget que exibe o progresso de tempo de treino
class WorkoutDurationWidget extends ConsumerWidget {
  /// Construtor
  const WorkoutDurationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Acesso aos dados através do provider
    final totalDurationAsync = ref.watch(totalDurationProvider);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: totalDurationAsync.when(
          data: (totalDuration) {
            // Meta semanal em minutos (padrão: 180 minutos, ou 3 horas)
            const weeklyGoalMinutes = 180;
            
            // Tempo total da semana (usando a duração total como aproximação)
            final weeklyDuration = totalDuration;
            
            // Calcular percentual (limitado a 100%)
            final weeklyPercent = (weeklyDuration / weeklyGoalMinutes).clamp(0.0, 1.0);
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Color(0xFFF38638)),
                    const SizedBox(width: 8),
                    Text(
                      'Progresso de Tempo',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4D4D4D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicador circular de progresso
                    CircularPercentIndicator(
                      radius: 45.0,
                      lineWidth: 10.0,
                      percent: weeklyPercent,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$weeklyDuration',
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF38638),
                            ),
                          ),
                          Text(
                            'min',
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFF4D4D4D),
                            ),
                          ),
                        ],
                      ),
                      progressColor: const Color(0xFFF38638),
                      backgroundColor: const Color(0xFFE6E6E6),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    const SizedBox(width: 16),
                    // Informações da meta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meta Semanal',
                            style: AppTypography.titleSmall.copyWith(
                              color: const Color(0xFF4D4D4D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$weeklyDuration/$weeklyGoalMinutes min',
                            style: AppTypography.bodyMedium.copyWith(
                              color: const Color(0xFF4D4D4D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: weeklyPercent,
                            backgroundColor: const Color(0xFFE6E6E6),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCDA8F0)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(weeklyPercent * 100).toInt()}% concluído',
                            style: AppTypography.labelSmall.copyWith(
                              color: const Color(0xFF4D4D4D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Tempo total de treino nesta semana. Continue assim!',
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF4D4D4D),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator(
              color: Color(0xFFF38638),
            )),
          ),
          error: (error, stackTrace) => SizedBox(
            height: 150,
            child: Center(
              child: Text(
                'Erro ao carregar os dados de tempo',
                style: AppTypography.bodyMedium.copyWith(color: Color(0xFFF38638)),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 