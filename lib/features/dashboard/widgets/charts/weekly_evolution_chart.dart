// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:fl_chart/fl_chart.dart';

// Project imports:
import 'package:ray_club_app/features/goals/models/workout_category_goal.dart';

/// Widget que exibe um gráfico de linha da evolução semanal de uma categoria
class WeeklyEvolutionChart extends StatefulWidget {
  /// Lista de dados de evolução semanal
  final List<WeeklyEvolution> evolutionData;
  
  /// Categoria sendo visualizada
  final String category;
  
  /// Altura do gráfico
  final double height;
  
  /// Se deve mostrar linhas de grade
  final bool showGrid;
  
  /// Se deve mostrar a linha de meta
  final bool showGoalLine;

  const WeeklyEvolutionChart({
    super.key,
    required this.evolutionData,
    required this.category,
    this.height = 250,
    this.showGrid = true,
    this.showGoalLine = true,
  });

  @override
  State<WeeklyEvolutionChart> createState() => _WeeklyEvolutionChartState();
}

class _WeeklyEvolutionChartState extends State<WeeklyEvolutionChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.evolutionData.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: widget.height,
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
            child: _buildChart(),
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
            color: _getCategoryColor(),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Evolução Semanal',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4D4D4D),
                ),
              ),
              Text(
                _getCategoryDisplayName(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7C7C7C),
                ),
              ),
            ],
          ),
        ),
        _buildCurrentWeekBadge(),
      ],
    );
  }

  Widget _buildCurrentWeekBadge() {
    if (widget.evolutionData.isEmpty) return const SizedBox();
    
    final currentWeek = widget.evolutionData.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: currentWeek.completed 
            ? const Color(0xFF4CAF50).withOpacity(0.1)
            : const Color(0xFF2196F3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        currentWeek.completed ? 'Meta atingida! 🎉' : '${currentWeek.percentageCompleted.toInt()}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: currentWeek.completed 
              ? const Color(0xFF4CAF50)
              : const Color(0xFF2196F3),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          horizontalInterval: _calculateInterval(),
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFF0F0F0),
            strokeWidth: 1,
          ),
          getDrawingVerticalLine: (value) => FlLine(
            color: const Color(0xFFF0F0F0),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: _buildBottomTitle,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _calculateInterval(),
              reservedSize: 45,
              getTitlesWidget: _buildLeftTitle,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        minX: 0,
        maxX: (widget.evolutionData.length - 1).toDouble(),
        minY: 0,
        maxY: _getMaxY(),
        lineBarsData: _buildLineBars(),
        lineTouchData: LineTouchData(
          enabled: true,
          touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
            setState(() {
              if (touchResponse != null && touchResponse.lineBarSpots != null) {
                _touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
              } else {
                _touchedIndex = -1;
              }
            });
          },
          getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
            return spotIndexes.map((spotIndex) {
              return TouchedSpotIndicatorData(
                FlLine(
                  color: _getCategoryColor().withOpacity(0.5),
                  strokeWidth: 2,
                ),
                FlDotData(
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 6,
                      color: _getCategoryColor(),
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
              );
            }).toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.white,
            getTooltipItems: _buildTooltipItems,
          ),
        ),
      ),
      duration: const Duration(milliseconds: 250),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(
          color: _getCategoryColor(),
          label: 'Realizado',
          icon: Icons.trending_up,
        ),
        const SizedBox(width: 16),
        if (widget.showGoalLine)
          _buildLegendItem(
            color: const Color(0xFF9E9E9E),
            label: 'Meta',
            icon: Icons.flag,
          ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(24),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum dado disponível',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Faça alguns treinos para ver sua evolução!',
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

  List<LineChartBarData> _buildLineBars() {
    return [
      // Linha dos minutos realizados
      LineChartBarData(
        isCurved: true,
        curveSmoothness: 0.3,
        color: _getCategoryColor(),
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) {
            final isCompleted = widget.evolutionData[index.toInt()].completed;
            return FlDotCirclePainter(
              radius: isCompleted ? 5 : 4,
              color: isCompleted ? const Color(0xFF4CAF50) : _getCategoryColor(),
              strokeWidth: 2,
              strokeColor: Colors.white,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getCategoryColor().withOpacity(0.3),
              _getCategoryColor().withOpacity(0.1),
              _getCategoryColor().withOpacity(0.05),
            ],
          ),
        ),
        spots: widget.evolutionData.asMap().entries.map((entry) {
          return FlSpot(
            entry.key.toDouble(),
            entry.value.currentMinutes.toDouble(),
          );
        }).toList(),
      ),
      
      // Linha da meta (se habilitada)
      if (widget.showGoalLine)
        LineChartBarData(
          isCurved: false,
          color: const Color(0xFF9E9E9E),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          dashArray: [5, 5],
          spots: widget.evolutionData.asMap().entries.map((entry) {
            return FlSpot(
              entry.key.toDouble(),
              entry.value.goalMinutes.toDouble(),
            );
          }).toList(),
        ),
    ];
  }

  Widget _buildBottomTitle(double value, TitleMeta meta) {
    if (value.toInt() >= widget.evolutionData.length) {
      return const SizedBox();
    }

    final evolution = widget.evolutionData[value.toInt()];
    final isCurrentWeek = value.toInt() == 0; // Primeira posição é a semana atual
    
    return Text(
      isCurrentWeek ? 'Atual' : _getWeekLabel(evolution.weekStartDate),
      style: TextStyle(
        color: isCurrentWeek ? _getCategoryColor() : const Color(0xFF9E9E9E),
        fontSize: 12,
        fontWeight: isCurrentWeek ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildLeftTitle(double value, TitleMeta meta) {
    return Text(
      '${value.toInt()}min',
      style: const TextStyle(
        color: Color(0xFF9E9E9E),
        fontSize: 12,
      ),
    );
  }

  List<LineTooltipItem> _buildTooltipItems(List<LineBarSpot> touchedSpots) {
    return touchedSpots.map((LineBarSpot touchedSpot) {
      const textStyle = TextStyle(
        color: Color(0xFF4D4D4D),
        fontWeight: FontWeight.w600,
        fontSize: 14,
      );

      final index = touchedSpot.spotIndex;
      final evolution = widget.evolutionData[index];
      
      return LineTooltipItem(
        '${evolution.weekDescription}\n${evolution.currentMinutes} min (${evolution.percentageCompleted.toInt()}%)',
        textStyle,
      );
    }).toList();
  }

  Color _getCategoryColor() {
    switch (widget.category.toLowerCase()) {
      case 'corrida':
      case 'caminhada':
        return const Color(0xFFFF6B6B);
      case 'yoga':
      case 'alongamento':
        return const Color(0xFF4ECDC4);
      case 'funcional':
      case 'crossfit':
      case 'musculacao':
        return const Color(0xFFFF8E53);
      case 'natacao':
        return const Color(0xFF45B7D1);
      case 'ciclismo':
        return const Color(0xFF9B59B6);
      case 'pilates':
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFF95A5A6);
    }
  }

  String _getCategoryDisplayName() {
    switch (widget.category.toLowerCase()) {
      case 'corrida':
        return 'Corrida 🏃‍♀️';
      case 'caminhada':
        return 'Caminhada 🚶‍♀️';
      case 'yoga':
        return 'Yoga 🧘‍♀️';
      case 'alongamento':
        return 'Alongamento 🤸‍♀️';
      case 'funcional':
        return 'Funcional 💪';
      case 'crossfit':
        return 'CrossFit 🏋️‍♀️';
      case 'natacao':
        return 'Natação 🏊‍♀️';
      case 'ciclismo':
        return 'Ciclismo 🚴‍♀️';
      case 'musculacao':
        return 'Musculação 🏋️‍♂️';
      case 'pilates':
        return 'Pilates 🤸‍♀️';
      default:
        return widget.category.substring(0, 1).toUpperCase() + 
               widget.category.substring(1).toLowerCase();
    }
  }

  double _getMaxY() {
    if (widget.evolutionData.isEmpty) return 100;
    
    final maxCurrentMinutes = widget.evolutionData
        .map((e) => e.currentMinutes)
        .reduce((a, b) => a > b ? a : b);
    
    final maxGoalMinutes = widget.evolutionData
        .map((e) => e.goalMinutes)
        .reduce((a, b) => a > b ? a : b);
    
    final maxValue = maxCurrentMinutes > maxGoalMinutes ? maxCurrentMinutes : maxGoalMinutes;
    
    // Adicionar 20% de margem superior
    return (maxValue * 1.2).toDouble();
  }

  double _calculateInterval() {
    final maxY = _getMaxY();
    return (maxY / 5).roundToDouble(); // 5 divisões aproximadamente
  }

  String _getWeekLabel(DateTime weekStart) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final daysDifference = currentWeekStart.difference(weekStart).inDays;
    
    if (daysDifference == 7) {
      return '1sem';
    } else if (daysDifference <= 28) {
      return '${(daysDifference / 7).round()}sem';
    } else {
      return '${weekStart.day}/${weekStart.month}';
    }
  }
} 