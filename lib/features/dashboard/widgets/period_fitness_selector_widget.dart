// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/models/dashboard_period.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_fitness_view_model.dart';

/// Widget para seleção de período do dashboard fitness
class PeriodFitnessSelectorWidget extends ConsumerStatefulWidget {
  const PeriodFitnessSelectorWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<PeriodFitnessSelectorWidget> createState() => _PeriodFitnessSelectorWidgetState();
}

class _PeriodFitnessSelectorWidgetState extends ConsumerState<PeriodFitnessSelectorWidget> {
  /// Mostra o date picker para período personalizado
  Future<void> _showCustomDatePicker() async {
    final viewModel = ref.read(dashboardFitnessViewModelProvider.notifier);
    final now = DateTime.now();
    
    final dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: viewModel.customRange != null 
          ? DateTimeRange(
              start: viewModel.customRange!.start,
              end: viewModel.customRange!.end,
            )
          : DateTimeRange(
              start: DateTime(now.year, now.month, 1),
              end: now,
            ),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione o período ✨',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      fieldStartLabelText: 'Data inicial',
      fieldEndLabelText: 'Data final',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF38638),
              onPrimary: Colors.white,
              surface: Color(0xFFE6E6E6),
              onSurface: Color(0xFF4D4D4D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (dateRange != null) {
      final customRange = DateRange(
        start: dateRange.start,
        end: dateRange.end,
      );
      await viewModel.updatePeriod(DashboardPeriod.custom, customRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF38638).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.date_range_outlined,
                  color: Color(0xFFF38638),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Período de visualização',
                style: TextStyle(
                  fontFamily: 'Century',
                  fontSize: 14,
                  color: Color(0xFF4D4D4D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF38638).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '✨ Fitness',
                  style: TextStyle(
                    fontFamily: 'Century',
                    fontSize: 11,
                    color: Color(0xFFF38638),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // 🔧 USAR CONSUMER PARA OBSERVAR MUDANÇAS DE ESTADO
          Consumer(
            builder: (context, ref, child) {
              // 🔥 IMPORTANTE: Assistir mudanças no estado para rebuild automático
              ref.watch(dashboardFitnessViewModelProvider);
              final viewModel = ref.read(dashboardFitnessViewModelProvider.notifier);
              final selectedPeriod = viewModel.selectedPeriod;
              final customRange = viewModel.customRange;
              final isCustomPeriod = viewModel.isCustomPeriod;
              final currentPeriodDescription = viewModel.currentPeriodDescription;
              final availablePeriods = viewModel.availablePeriods;
              
              debugPrint('🎨 Rebuilding period selector - Current period: ${selectedPeriod.displayName}');
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE6E6E6),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DashboardPeriod>(
                        value: selectedPeriod,
                        isExpanded: true,
                        style: const TextStyle(
                          fontFamily: 'Century',
                          fontSize: 14,
                          color: Color(0xFF4D4D4D),
                          fontWeight: FontWeight.w500,
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFFF38638),
                          size: 20,
                        ),
                        dropdownColor: Colors.white,
                        items: availablePeriods.map((period) {
                          return DropdownMenuItem<DashboardPeriod>(
                            value: period,
                            child: Row(
                              children: [
                                Icon(
                                  _getPeriodIcon(period),
                                  color: const Color(0xFFF38638),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  period.displayName,
                                  style: const TextStyle(
                                    fontFamily: 'Century',
                                    fontSize: 14,
                                    color: Color(0xFF4D4D4D),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (DashboardPeriod? newPeriod) async {
                          if (newPeriod == null) return;
                          
                          debugPrint('🔄 Alterando período: ${selectedPeriod.displayName} → ${newPeriod.displayName}');
                          
                          if (newPeriod == DashboardPeriod.custom) {
                            await _showCustomDatePicker();
                          } else {
                            await viewModel.updatePeriod(newPeriod);
                          }
                        },
                      ),
                    ),
                  ),
                  
                  // Mostrar descrição do período se não for custom
                  if (!isCustomPeriod) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentPeriodDescription,
                        style: const TextStyle(
                          fontFamily: 'Century',
                          fontSize: 12,
                          color: Color(0xFF8D8D8D),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                  
                  // Mostrar range customizado se for custom
                  if (isCustomPeriod && customRange != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF38638).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF38638).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Color(0xFFF38638),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customRange!.formattedRange,
                                  style: const TextStyle(
                                    fontFamily: 'Century',
                                    fontSize: 13,
                                    color: Color(0xFFF38638),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${customRange!.durationInDays} dias selecionados',
                                  style: const TextStyle(
                                    fontFamily: 'Century',
                                    fontSize: 11,
                                    color: Color(0xFF8D8D8D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _showCustomDatePicker,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF38638).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.edit_calendar_outlined,
                                color: Color(0xFFF38638),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Retorna o ícone apropriado para cada período
  IconData _getPeriodIcon(DashboardPeriod period) {
    switch (period) {
      case DashboardPeriod.thisWeek:
      case DashboardPeriod.lastWeek:
        return Icons.view_week_outlined;
      case DashboardPeriod.thisMonth:
      case DashboardPeriod.lastMonth:
        return Icons.calendar_view_month_outlined;
      case DashboardPeriod.last30Days:
        return Icons.date_range_outlined;
      case DashboardPeriod.last3Months:
        return Icons.calendar_view_month_outlined;
      case DashboardPeriod.thisYear:
        return Icons.calendar_today_outlined;
      case DashboardPeriod.custom:
        return Icons.tune_outlined;
    }
  }
} 