// Flutter imports:
import 'package:flutter/material.dart';
import 'dart:math' as math;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/models/dashboard_fitness_data.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_fitness_view_model.dart';
import 'package:ray_club_app/features/dashboard/widgets/day_details_modal.dart';
import 'package:ray_club_app/features/dashboard/widgets/animated_progress_ring.dart';

/// Widget do calendário fitness com anéis de progresso estilo Apple Watch
class FitnessCalendarWidget extends ConsumerWidget {
  const FitnessCalendarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardFitnessViewModelProvider);
    final viewModel = ref.read(dashboardFitnessViewModelProvider.notifier);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEDC94), // Fundo bege claro
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header com navegação de mês
          _buildHeader(context, viewModel),
          
          const SizedBox(height: 20),
          
          // Dias da semana
          _buildWeekDaysHeader(),
          
          const SizedBox(height: 16),
          
          // Calendário
          dashboardState.when(
            data: (data) => _buildCalendar(context, data, viewModel),
            loading: () => _buildLoadingCalendar(),
            error: (error, _) => _buildErrorCalendar(context, error),
          ),
        ],
      ),
    );
  }

  /// Constrói o header com navegação de mês
  Widget _buildHeader(BuildContext context, DashboardFitnessViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Botão mês anterior
        IconButton(
          onPressed: viewModel.goToPreviousMonth,
          icon: const Icon(
            Icons.chevron_left,
            color: Color(0xFF4D4D4D),
            size: 28,
          ),
        ),
        
        // Nome do mês e ano
        Column(
          children: [
            Text(
              DateFormat('MMMM', 'pt_BR').format(viewModel.currentMonth),
              style: const TextStyle(
                color: Color(0xFF4D4D4D),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              DateFormat('yyyy').format(viewModel.currentMonth),
              style: const TextStyle(
                color: Color(0xFF4D4D4D),
                fontSize: 16,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        
        // Botão próximo mês
        IconButton(
          onPressed: viewModel.goToNextMonth,
          icon: const Icon(
            Icons.chevron_right,
            color: Color(0xFF4D4D4D),
            size: 28,
          ),
        ),
      ],
    );
  }

  /// Constrói o header com os dias da semana
  Widget _buildWeekDaysHeader() {
    const weekDays = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) => SizedBox(
        width: 40,
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF4D4D4D),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      )).toList(),
    );
  }

  /// Constrói o calendário com os dados
  Widget _buildCalendar(
    BuildContext context,
    DashboardFitnessData data,
    DashboardFitnessViewModel viewModel,
  ) {
    final monthStart = DateTime(data.calendar.year, data.calendar.month, 1);
    final monthEnd = DateTime(data.calendar.year, data.calendar.month + 1, 0);
    
    // Calcular primeiro dia da semana do mês (0 = domingo)
    final firstWeekday = monthStart.weekday == 7 ? 0 : monthStart.weekday;
    
    // Calcular quantas semanas precisamos
    final totalDays = monthEnd.day;
    final totalCells = ((totalDays + firstWeekday - 1) / 7).ceil() * 7;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        final dayNumber = index - firstWeekday + 1;
        
        // Células vazias antes do primeiro dia
        if (dayNumber <= 0) {
          return const SizedBox.shrink();
        }
        
        // Células vazias após o último dia
        if (dayNumber > totalDays) {
          return const SizedBox.shrink();
        }
        
        final date = DateTime(monthStart.year, monthStart.month, dayNumber);
        final dayData = data.calendar.days.firstWhere(
          (day) => day.date.day == dayNumber,
          orElse: () => CalendarDayData(
            day: dayNumber,
            date: date,
            rings: const ActivityRings(),
          ),
        );
        
        return _buildDayCell(context, date, dayData, viewModel);
      },
    );
  }

  /// Constrói uma célula do dia
  Widget _buildDayCell(
    BuildContext context,
    DateTime date,
    CalendarDayData dayData,
    DashboardFitnessViewModel viewModel,
  ) {
    final isToday = viewModel.isToday(date);
    final isFuture = viewModel.isFuture(date);
    
    return GestureDetector(
      onTap: isFuture ? null : () => _showDayDetails(context, date),
      child:         Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: isToday ? Border.all(
              color: const Color(0xFF4D4D4D),
              width: 2,
            ) : null,
          ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Anéis de progresso
            if (!isFuture) _buildActivityRings(dayData.rings),
            
            // Número do dia
            Text(
              '${date.day}',
              style: TextStyle(
                color: isFuture 
                    ? const Color(0xFF4D4D4D).withOpacity(0.3)
                    : const Color(0xFF4D4D4D),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói os anéis de atividade
  Widget _buildActivityRings(ActivityRings rings) {
    return AnimatedActivityRings(
      moveProgress: rings.move,
      exerciseProgress: rings.exercise,
      standProgress: rings.stand,
      size: 36,
      duration: const Duration(milliseconds: 1200),
    );
  }

  /// Constrói um anel individual
  Widget _buildRing({
    required double radius,
    required double strokeWidth,
    required double progress,
    required Color color,
  }) {
    return CustomPaint(
      size: Size(radius * 2, radius * 2),
      painter: RingPainter(
        progress: progress,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }

  /// Constrói o calendário em estado de carregamento
  Widget _buildLoadingCalendar() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 35, // 5 semanas
      itemBuilder: (context, index) {
        return Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white24,
          ),
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Constrói o calendário em estado de erro
  Widget _buildErrorCalendar(BuildContext context, Object error) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Erro ao carregar calendário',
              style: TextStyle(
                color: Colors.red.shade300,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque para tentar novamente',
              style: TextStyle(
                color: Colors.red.shade200,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostra os detalhes do dia
  void _showDayDetails(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayDetailsModal(date: date),
    );
  }
}

/// Painter personalizado para desenhar os anéis de progresso
class RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Anel de fundo (cinza)
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Anel de progresso
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      const startAngle = -math.pi / 2; // Começar no topo

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is RingPainter &&
        (oldDelegate.progress != progress ||
         oldDelegate.color != color ||
         oldDelegate.strokeWidth != strokeWidth);
  }
} 