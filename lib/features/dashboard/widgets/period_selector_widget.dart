// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/dashboard/models/dashboard_period.dart';
import 'package:ray_club_app/features/dashboard/viewmodels/dashboard_view_model.dart';

/// Widget para seleção de período do dashboard
class PeriodSelectorWidget extends ConsumerStatefulWidget {
  const PeriodSelectorWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<PeriodSelectorWidget> createState() => _PeriodSelectorWidgetState();
}

class _PeriodSelectorWidgetState extends ConsumerState<PeriodSelectorWidget> {
  /// Mostra o date picker para período personalizado
  Future<void> _showCustomDatePicker() async {
    final viewModel = ref.read(dashboardViewModelProvider.notifier);
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
      helpText: 'Selecione o período',
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
    final viewModel = ref.watch(dashboardViewModelProvider.notifier);
    final selectedPeriod = viewModel.selectedPeriod;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFFF38638),
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Período:',
                style: TextStyle(
                  fontFamily: 'Century',
                  fontSize: 14,
                  color: Color(0xFF4D4D4D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
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
                      Icons.keyboard_arrow_down,
                      color: Color(0xFFF38638),
                    ),
                    dropdownColor: Colors.white,
                    items: viewModel.availablePeriods.map((period) {
                      return DropdownMenuItem<DashboardPeriod>(
                        value: period,
                        child: Text(
                          period.displayName,
                          style: const TextStyle(
                            fontFamily: 'Century',
                            fontSize: 14,
                            color: Color(0xFF4D4D4D),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (DashboardPeriod? newPeriod) async {
                      if (newPeriod == null) return;
                      
                      if (newPeriod == DashboardPeriod.custom) {
                        await _showCustomDatePicker();
                      } else {
                        await viewModel.updatePeriod(newPeriod);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          // Mostrar descrição do período se não for custom
          if (!viewModel.isCustomPeriod) ...[
            const SizedBox(height: 4),
            Text(
              viewModel.currentPeriodDescription,
              style: const TextStyle(
                fontFamily: 'Century',
                fontSize: 12,
                color: Color(0xFF8D8D8D),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          // Mostrar range customizado se for custom
          if (viewModel.isCustomPeriod && viewModel.customRange != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF38638).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFF38638).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    viewModel.customRange!.formattedRange,
                    style: const TextStyle(
                      fontFamily: 'Century',
                      fontSize: 12,
                      color: Color(0xFFF38638),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${viewModel.customRange!.durationInDays} dias)',
                  style: const TextStyle(
                    fontFamily: 'Century',
                    fontSize: 12,
                    color: Color(0xFF8D8D8D),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _showCustomDatePicker,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF38638).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.edit_calendar,
                      color: Color(0xFFF38638),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
} 