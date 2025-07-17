// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:ray_club_app/features/auth/repositories/auth_repository.dart';
import 'package:ray_club_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:ray_club_app/features/events/models/event.dart';
import 'package:ray_club_app/features/events/repositories/event_repository.dart';
import 'package:ray_club_app/utils/log_utils.dart';

/// ViewModel para gerenciar o estado dos eventos
class EventViewModel extends StateNotifier<EventsState> {
  final IEventRepository _repository;
  final IAuthRepository _authRepository;
  
  static const String _logTag = 'EventViewModel';

  EventViewModel({
    required IEventRepository repository,
    required IAuthRepository authRepository,
  })  : _repository = repository,
        _authRepository = authRepository,
        super(const EventsState());

  /// Carrega a lista de eventos
  Future<void> loadEvents({Map<String, dynamic>? filters}) async {
    try {
      LogUtils.info('Carregando eventos', tag: _logTag, data: {'filters': filters});
      
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      final events = await _repository.getEvents(filters: filters);

      state = state.copyWith(
        isLoading: false,
        events: events,
        errorMessage: null,
      );

      LogUtils.info('Eventos carregados com sucesso', tag: _logTag, data: {'count': events.length});
    } catch (e) {
      LogUtils.error('Erro ao carregar eventos', tag: _logTag, error: e);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Cria um novo evento
  Future<Event?> createEvent(Event event) async {
    try {
      LogUtils.info('Criando novo evento', tag: _logTag, data: {'title': event.title});
      
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );

      final createdEvent = await _repository.createEvent(event);

      // Atualizar a lista de eventos
      final updatedEvents = [...state.events, createdEvent];
      
      state = state.copyWith(
        isLoading: false,
        events: updatedEvents,
        successMessage: 'Evento criado com sucesso',
        errorMessage: null,
      );

      LogUtils.info('Evento criado com sucesso', tag: _logTag, data: {'eventId': createdEvent.id});
      
      return createdEvent;
    } catch (e) {
      LogUtils.error('Erro ao criar evento', tag: _logTag, error: e);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        successMessage: null,
      );
      
      rethrow;
    }
  }

  /// Busca um evento por ID
  Future<Event?> getEventById(String eventId) async {
    try {
      LogUtils.info('Buscando evento por ID', tag: _logTag, data: {'eventId': eventId});
      
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      final event = await _repository.getEventById(eventId);

      state = state.copyWith(
        isLoading: false,
        selectedEvent: event,
        errorMessage: null,
      );

      LogUtils.info('Evento encontrado', tag: _logTag, data: {'eventId': eventId, 'title': event.title});
      
      return event;
    } catch (e) {
      LogUtils.error('Erro ao buscar evento', tag: _logTag, error: e);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      
      rethrow;
    }
  }

  /// Inscreve o usuário em um evento
  Future<void> registerForEvent({required String eventId}) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      LogUtils.info('Inscrevendo usuário no evento', tag: _logTag, data: {'eventId': eventId, 'userId': user.id});
      
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );

      await _repository.registerForEvent(eventId: eventId, userId: user.id);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Inscrição realizada com sucesso',
        errorMessage: null,
      );

      // Recarregar eventos para atualizar contadores
      await loadEvents();

      LogUtils.info('Usuário inscrito no evento com sucesso', tag: _logTag, data: {'eventId': eventId, 'userId': user.id});
    } catch (e) {
      LogUtils.error('Erro ao se inscrever no evento', tag: _logTag, error: e);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        successMessage: null,
      );
      
      rethrow;
    }
  }

  /// Cancela a inscrição do usuário em um evento
  Future<void> cancelRegistration({required String eventId}) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      LogUtils.info('Cancelando inscrição no evento', tag: _logTag, data: {'eventId': eventId, 'userId': user.id});
      
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      );

      await _repository.cancelRegistration(eventId: eventId, userId: user.id);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Inscrição cancelada com sucesso',
        errorMessage: null,
      );

      // Recarregar eventos para atualizar contadores
      await loadEvents();

      LogUtils.info('Inscrição cancelada com sucesso', tag: _logTag, data: {'eventId': eventId, 'userId': user.id});
    } catch (e) {
      LogUtils.error('Erro ao cancelar inscrição', tag: _logTag, error: e);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        successMessage: null,
      );
      
      rethrow;
    }
  }

  /// Filtra eventos por tipo
  Future<void> filterEvents({String? type}) async {
    final filters = type != null ? {'type': type} : null;
    await loadEvents(filters: filters);
  }

  /// Carrega os eventos do usuário atual
  Future<void> getUserEvents() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      LogUtils.info('Carregando eventos do usuário', tag: _logTag, data: {'userId': user.id});
      
      state = state.copyWith(
        isLoading: true,
        errorMessage: null,
      );

      final userEvents = await _repository.getUserEvents(user.id);

      state = state.copyWith(
        isLoading: false,
        userEvents: userEvents,
        errorMessage: null,
      );

      LogUtils.info('Eventos do usuário carregados', tag: _logTag, data: {'userId': user.id, 'count': userEvents.length});
    } catch (e) {
      LogUtils.error('Erro ao carregar eventos do usuário', tag: _logTag, error: e);
      
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Limpa mensagens de sucesso e erro
  void clearMessages() {
    state = state.copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }

  /// Limpa o evento selecionado
  void clearSelectedEvent() {
    state = state.copyWith(selectedEvent: null);
  }


}

/// Provider para o EventViewModel
final eventViewModelProvider = StateNotifierProvider<EventViewModel, EventsState>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  
  return EventViewModel(
    repository: repository,
    authRepository: authRepository,
  );
});

/// Provider para carregar eventos automaticamente
final eventsListProvider = FutureProvider<List<Event>>((ref) async {
  final viewModel = ref.read(eventViewModelProvider.notifier);
  await viewModel.loadEvents();
  return ref.watch(eventViewModelProvider).events;
});

/// Provider para eventos do usuário
final userEventsProvider = FutureProvider<List<Event>>((ref) async {
  final viewModel = ref.read(eventViewModelProvider.notifier);
  await viewModel.getUserEvents();
  return ref.watch(eventViewModelProvider).userEvents;
}); 