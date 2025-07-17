// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/subscription/providers/subscription_providers.dart';
import 'package:ray_club_app/features/subscription/widgets/premium_feature_gate.dart';

class AppBottomNav extends ConsumerStatefulWidget {
  const AppBottomNav({Key? key}) : super(key: key);

  @override
  ConsumerState<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends ConsumerState<AppBottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _navigateToTab(index);
  }

  void _navigateToTab(int index) {
    final navigator = Navigator.of(context);
    
    switch (index) {
      case 0:
        navigator.pushNamedAndRemoveUntil('/home', (route) => false);
        break;
      case 1:
        navigator.pushNamedAndRemoveUntil('/workouts', (route) => false);
        break;
      case 2:
        navigator.pushNamedAndRemoveUntil('/challenges', (route) => false);
        break;
      case 3:
        // Verificar acesso antes de navegar para benefícios
        final hasAccess = ref.read(featureAccessProvider('detailed_reports')).valueOrNull ?? false;
        if (hasAccess) {
          navigator.pushNamedAndRemoveUntil('/benefits', (route) => false);
        } else {
          // Mostrar diálogo de bloqueio profissional
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (dialogContext) => Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6A5ACD),
                      Color(0xFF9370DB),
                      Color(0xFFBA55D3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Benefícios Exclusivos',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Continue evoluindo para desbloquear acesso aos benefícios exclusivos dos nossos parceiros.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6A5ACD),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Entendi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        break;
      case 4:
        navigator.pushNamedAndRemoveUntil('/profile', (route) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: _buildNavItems(),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.fitness_center_outlined),
        activeIcon: Icon(Icons.fitness_center),
        label: 'Treinos',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.emoji_events_outlined),
        activeIcon: Icon(Icons.emoji_events),
        label: 'Desafios',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.card_giftcard_outlined),
        activeIcon: Icon(Icons.card_giftcard),
        label: 'Benefícios',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];
  }
} 
