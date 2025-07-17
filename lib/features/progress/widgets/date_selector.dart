// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/constants/app_padding.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final int daysToShow;

  const DateSelector({
    Key? key,
    required this.selectedDate,
    required this.onDateSelected,
    this.daysToShow = 7,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Generate dates starting from today and going back by daysToShow
    final dates = List.generate(
      daysToShow,
      (index) => DateTime.now().subtract(Duration(days: index)),
    );

    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDate(date, selectedDate);
          
          return _buildDateItem(context, date, isSelected);
        },
      ),
    );
  }

  Widget _buildDateItem(BuildContext context, DateTime date, bool isSelected) {
    final weekdayFormat = DateFormat('E');
    final dayFormat = DateFormat('d');
    
    return GestureDetector(
      onTap: () => onDateSelected(date),
      child: Container(
        width: 60,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekdayFormat.format(date),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayFormat.format(date),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            if (DateTime.now().day == date.day && 
                DateTime.now().month == date.month && 
                DateTime.now().year == date.year) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Today',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
} 