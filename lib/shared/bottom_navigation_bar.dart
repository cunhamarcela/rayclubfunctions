// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/router/app_router.dart';
import 'package:ray_club_app/features/home/widgets/register_exercise_sheet.dart';

class SharedBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const SharedBottomNavigationBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a more visible bottom navigation with custom styling
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context, 
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                index: 0,
                currentIndex: currentIndex,
                onTap: () => context.router.replace(const HomeRoute()),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.fitness_center_outlined,
                selectedIcon: Icons.fitness_center,
                label: 'Treinos',
                index: 1,
                currentIndex: currentIndex,
                onTap: () => context.router.replaceNamed(AppRoutes.workout),
              ),
              _buildCenterButton(context),
              _buildNavItem(
                context: context,
                icon: Icons.restaurant_menu_outlined,
                selectedIcon: Icons.restaurant_menu,
                label: 'Nutrição',
                index: 3,
                currentIndex: currentIndex,
                onTap: () => context.router.replaceNamed(AppRoutes.nutrition),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.emoji_events_outlined,
                selectedIcon: Icons.emoji_events,
                label: 'Desafio',
                index: 4,
                currentIndex: currentIndex,
                onTap: () => context.router.replaceNamed(AppRoutes.challengeCompleted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = index == currentIndex;
    final selectedColor = const Color(0xFFEE583F); // Definição da cor #EE583F
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? selectedColor : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? selectedColor : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterButton(BuildContext context) {
    return GestureDetector(
      onTap: () => showRegisterExerciseSheet(context, challengeId: null),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            'assets/images/logos/app/check_8.png',
            width: 28,
            height: 28,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
} 
