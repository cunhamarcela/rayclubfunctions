// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/core/theme/app_colors.dart';
import 'package:ray_club_app/core/widgets/app_bar_leading.dart';
import 'package:ray_club_app/features/events/viewmodels/event_view_model.dart';

/// Tela de detalhes do evento
@RoutePage()
class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  
  const EventDetailScreen({
    super.key,
    @PathParam('eventId') required this.eventId,
  });

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar detalhes do evento quando a tela inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventViewModelProvider.notifier).getEventById(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventViewModelProvider);
    final selectedEvent = eventsState.selectedEvent;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1E7),
        elevation: 0,
        leading: const AppBarLeading(),
        title: Text(
          selectedEvent?.title ?? 'Detalhes do Evento',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
            fontFamily: 'CenturyGothic',
          ),
        ),
        centerTitle: false,
      ),
      body: eventsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBF8F5C)),
              ),
            )
          : eventsState.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ops! Algo deu errado',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          eventsState.errorMessage!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(eventViewModelProvider.notifier).getEventById(widget.eventId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBF8F5C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : selectedEvent == null
                  ? const Center(
                      child: Text(
                        'Evento não encontrado',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagem do evento
                          if (selectedEvent.imageUrl != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 20),
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
                                child: Image.network(
                                  selectedEvent.imageUrl!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: double.infinity,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.event,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                          // Título do evento
                          Text(
                            selectedEvent.title,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                              fontFamily: 'CenturyGothic',
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Informações básicas
                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            label: 'Data',
                            value: _formatDate(selectedEvent.startDate),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.access_time,
                            label: 'Horário',
                            value: _formatTime(selectedEvent.startDate),
                          ),
                          const SizedBox(height: 8),
                          if (selectedEvent.location != null)
                            _buildInfoRow(
                              icon: Icons.location_on,
                              label: 'Local',
                              value: selectedEvent.location!,
                            ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            icon: Icons.people,
                            label: 'Participantes',
                            value: '${selectedEvent.currentAttendees} inscritos',
                          ),
                          const SizedBox(height: 24),

                          // Descrição
                          const Text(
                            'Descrição',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedEvent.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 100), // Espaço para o botão flutuante
                        ],
                      ),
                    ),
      floatingActionButton: selectedEvent != null
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () => _onRegisterTap(selectedEvent),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBF8F5C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Inscrever-se no Evento',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFBF8F5C),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _onRegisterTap(selectedEvent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Inscrição'),
        content: Text('Deseja se inscrever no evento "${selectedEvent.title}"?'),
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
                    .registerForEvent(eventId: selectedEvent.id);
                
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