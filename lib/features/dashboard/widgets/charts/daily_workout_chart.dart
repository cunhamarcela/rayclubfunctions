// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de dados para evolução diária de treinos
class DailyWorkoutData {
  final DateTime date;
  final int minutes;
  final int workoutCount;

  DailyWorkoutData({
    required this.date,
    required this.minutes,
    required this.workoutCount,
  });
}

/// Provider para dados de evolução diária
final dailyWorkoutDataProvider = FutureProvider.family<List<DailyWorkoutData>, int>((ref, days) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  
  if (userId == null) return [];
  
  final startDate = DateTime.now().subtract(Duration(days: days));
  final endDate = DateTime.now();
  
  final response = await supabase
      .from('workout_records')
      .select('date, duration_minutes')
      .eq('user_id', userId)
      .gte('date', startDate.toIso8601String())
      .lte('date', endDate.toIso8601String())
      .order('date');
  
  // Agrupar dados por dia
  final Map<String, DailyWorkoutData> dailyData = {};
  
  for (final record in response) {
    final date = DateTime.parse(record['date']);
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final minutes = record['duration_minutes'] as int? ?? 0;
    
    if (dailyData.containsKey(dateKey)) {
      final existing = dailyData[dateKey]!;
      dailyData[dateKey] = DailyWorkoutData(
        date: existing.date,
        minutes: existing.minutes + minutes,
        workoutCount: existing.workoutCount + 1,
      );
    } else {
      dailyData[dateKey] = DailyWorkoutData(
        date: date,
        minutes: minutes,
        workoutCount: 1,
      );
    }
  }
  
  // Preencher dias sem treino com valor 0
  final result = <DailyWorkoutData>[];
  for (int i = days; i >= 0; i--) {
    final date = DateTime.now().subtract(Duration(days: i));
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    if (dailyData.containsKey(dateKey)) {
      result.add(dailyData[dateKey]!);
    } else {
      result.add(DailyWorkoutData(
        date: date,
        minutes: 0,
        workoutCount: 0,
      ));
    }
  }
  
  return result;
});

/// Widget que exibe um gráfico de linha da evolução diária dos minutos de treino
class DailyWorkoutChart extends ConsumerWidget {
  /// Número de dias para mostrar (padrão: 7 dias)
  final int days;
  
  /// Altura do gráfico
  final double height;
  
  /// Se deve mostrar linhas de grade
  final bool showGrid;

  const DailyWorkoutChart({
    super.key,
    this.days = 7,
    this.height = 280,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dailyWorkoutDataProvider(days));
    
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: dataAsync.when(
              data: (data) => _buildChart(data),
              loading: () => _buildLoading(),
              error: (error, _) => _buildError(),
            ),
          ),
          const SizedBox(height: 8),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Evolução dos Treinos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4D4D4D),
                ),
              ),
              Text(
                'Minutos de treino dos últimos $days dias',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8E8E8E),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '📊',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<DailyWorkoutData> data) {
    if (data.isEmpty) {
      return _buildEmptyState();
    }

    final maxMinutes = data.map((d) => d.minutes).reduce((a, b) => a > b ? a : b);
    final maxY = maxMinutes > 0 ? (maxMinutes * 1.2).ceil().toDouble() : 60.0;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: showGrid,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final date = data[index].date;
                  final dayNames = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dayNames[date.weekday - 1],
                      style: const TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const Text('');
                return Text(
                  '${value.toInt()}min',
                  style: const TextStyle(
                    color: Color(0xFF8E8E8E),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.minutes.toDouble());
            }).toList(),
            isCurved: true,
            color: const Color(0xFF2196F3),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: data[index].minutes > 0 
                      ? const Color(0xFF2196F3) 
                      : Colors.grey.withOpacity(0.5),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2196F3).withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((touchedSpot) {
                final index = touchedSpot.spotIndex;
                final dataPoint = data[index];
                return LineTooltipItem(
                  '${dataPoint.minutes} min\n${dataPoint.workoutCount} treino${dataPoint.workoutCount != 1 ? 's' : ''}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum treino registrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece a treinar para ver sua evolução!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar dados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Minutos de treino',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF8E8E8E),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 