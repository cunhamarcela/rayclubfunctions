// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/widgets/app_bar_leading.dart';
import 'package:ray_club_app/features/events/models/event.dart';
import 'package:ray_club_app/features/events/viewmodels/event_view_model.dart';
import 'package:ray_club_app/features/events/widgets/event_card.dart';

/// Tela principal de eventos
@RoutePage()
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String? selectedFilter;

  @override
  void initState() {
    super.initState();
    // Carregar eventos quando a tela inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventViewModelProvider.notifier).loadEvents();
    });
  }

  /// Abre o link do Ingresse para compra de ingressos
  Future<void> _openEventLink() async {
    const url = 'https://embedstore.ingresse.com/tickets/www.ingresse.com/event/83740?coupon=DesafioDaRay';
    
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1E7),
        elevation: 0,
        leading: const AppBarLeading(),
        title: const Text(
          'Eventos',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            fontFamily: 'CenturyGothic',
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Imagem ocupando a maior parte da tela
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/WhatsApp Image 2025-06-05 at 20.37.12.jpeg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Eventos Ray Club',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Botão para comprar ingressos
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openEventLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBF8F5C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.confirmation_number),
                    SizedBox(width: 8),
                    Text(
                      'Comprar Ingressos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Filtrar Eventos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Todos os eventos'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedFilter = null;
                });
                ref.read(eventViewModelProvider.notifier).loadEvents();
              },
            ),
            ListTile(
              leading: const Icon(Icons.fitness_center),
              title: const Text('Fitness'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedFilter = 'Fitness';
                });
                ref.read(eventViewModelProvider.notifier).filterEvents(type: 'fitness');
              },
            ),
            ListTile(
              leading: const Icon(Icons.self_improvement),
              title: const Text('Bem-estar'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedFilter = 'Bem-estar';
                });
                ref.read(eventViewModelProvider.notifier).filterEvents(type: 'wellness');
              },
            ),
            ListTile(
              leading: const Icon(Icons.sports),
              title: const Text('Esportes'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedFilter = 'Esportes';
                });
                ref.read(eventViewModelProvider.notifier).filterEvents(type: 'sports');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _onEventTap(Event event) {
    context.router.pushNamed('/events/${event.id}');
  }

  void _onRegisterTap(Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Inscrição'),
        content: Text('Deseja se inscrever no evento "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(eventViewModelProvider.notifier)
                    .registerForEvent(eventId: event.id);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inscrição realizada com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao se inscrever: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBF8F5C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
} 