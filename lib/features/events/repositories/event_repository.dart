// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'package:ray_club_app/core/events/app_event_bus.dart';
import 'package:ray_club_app/core/providers/supabase_providers.dart';
import 'package:ray_club_app/features/events/models/event.dart';
import 'package:ray_club_app/utils/log_utils.dart';

/// Interface para o repositório de eventos
abstract class IEventRepository {
  Future<List<Event>> getEvents({Map<String, dynamic>? filters});
  Future<Event> getEventById(String eventId);
  Future<Event> createEvent(Event event);
  Future<Event> updateEvent(Event event);
  Future<void> deleteEvent(String eventId);
  Future<void> registerForEvent({required String eventId, required String userId});
  Future<void> cancelRegistration({required String eventId, required String userId});
  Future<List<Event>> getUserEvents(String userId);
}

/// Repositório para gerenciar eventos
class EventRepository implements IEventRepository {
  final SupabaseClient _client;
  final AppEventBus _eventBus;
  final Dio _dio;
  
  static const String _logTag = 'EventRepository';

  EventRepository({
    required SupabaseClient client,
    required AppEventBus eventBus,
    required Dio dio,
  }) : _client = client,
       _eventBus = eventBus,
       _dio = dio;

  @override
  Future<List<Event>> getEvents({Map<String, dynamic>? filters}) async {
    try {
      LogUtils.info('Buscando eventos', tag: _logTag, data: {'filters': filters});
      
      var queryBuilder = _client
          .from('events')
          .select()
          .eq('is_active', true);
      
      // Aplicar filtros se fornecidos
      if (filters != null) {
        if (filters.containsKey('type') && filters['type'] != null) {
          queryBuilder = queryBuilder.eq('type', filters['type']);
        }
        if (filters.containsKey('location') && filters['location'] != null) {
          queryBuilder = queryBuilder.ilike('location', '%${filters['location']}%');
        }
        if (filters.containsKey('startDate') && filters['startDate'] != null) {
          queryBuilder = queryBuilder.gte('start_date', filters['startDate']);
        }
      }
      
      final response = await queryBuilder.order('start_date', ascending: true);
      
      final events = (response as List)
          .map((item) => Event.fromJson(item))
          .toList();
      
      LogUtils.info('Eventos carregados com sucesso', tag: _logTag, data: {'count': events.length});
      
      return events;
    } on PostgrestException catch (e) {
      LogUtils.error('Erro PostgreSQL ao buscar eventos', tag: _logTag, error: e);
      throw Exception('Erro ao carregar eventos: ${e.message}');
    } catch (e) {
      LogUtils.error('Erro inesperado ao buscar eventos', tag: _logTag, error: e);
      throw Exception('Erro inesperado ao carregar eventos');
    }
  }

  @override
  Future<Event> getEventById(String eventId) async {
    try {
      LogUtils.info('Buscando evento por ID', tag: _logTag, data: {'eventId': eventId});
      
      final response = await _client
          .from('events')
          .select()
          .eq('id', eventId)
          .single();
      
      final event = Event.fromJson(response);
      
      LogUtils.info('Evento encontrado', tag: _logTag, data: {'eventId': eventId, 'title': event.title});
      
      return event;
    } on PostgrestException catch (e) {
      LogUtils.error('Erro PostgreSQL ao buscar evento', tag: _logTag, error: e);
      throw Exception('Evento não encontrado: ${e.message}');
    } catch (e) {
      LogUtils.error('Erro inesperado ao buscar evento', tag: _logTag, error: e);
      throw Exception('Erro inesperado ao carregar evento');
    }
  }

  @override
  Future<Event> createEvent(Event event) async {
    try {
      LogUtils.info('Criando novo evento', tag: _logTag, data: {'title': event.title});
      
      final eventData = event.toJson();
      eventData.remove('id'); // Remove ID para deixar o Supabase gerar
      
      final response = await _client
          .from('events')
          .insert(eventData)
          .select()
          .single();
      
      final createdEvent = Event.fromJson(response);
      
      // Publicar evento de criação
      _eventBus.publish(
        AppEvent.custom(
          name: 'event_created',
          data: {
            'eventId': createdEvent.id,
            'title': createdEvent.title,
          },
        ),
      );
      
      LogUtils.info('Evento criado com sucesso', tag: _logTag, data: {'eventId': createdEvent.id});
      
      return createdEvent;
    } on PostgrestException catch (e) {
      LogUtils.error('Erro PostgreSQL ao criar evento', tag: _logTag, error: e);
      throw Exception('Erro ao criar evento: ${e.message}');
    } catch (e) {
      LogUtils.error('Erro inesperado ao criar evento', tag: _logTag, error: e);
      throw Exception('Erro inesperado ao criar evento');
    }
  }

  @override
  Future<Event> updateEvent(Event event) async {
    try {
      LogUtils.info('Atualizando evento', tag: _logTag, data: {'eventId': event.id});
      
      final eventData = event.toJson();
      eventData['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('events')
          .update(eventData)
          .eq('id', event.id)
          .select()
          .single();
      
      final updatedEvent = Event.fromJson(response);
      
      LogUtils.info('Evento atualizado com sucesso', tag: _logTag, data: {'eventId': event.id});
      
      return updatedEvent;
    } on PostgrestException catch (e) {
      LogUtils.error('Erro PostgreSQL ao atualizar evento', tag: _logTag, error: e);
      throw Exception('Erro ao atualizar evento: ${e.message}');
    } catch (e) {
      LogUtils.error('Erro inesperado ao atualizar evento', tag: _logTag, error: e);
      throw Exception('Erro inesperado ao atualizar evento');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      LogUtils.info('Deletando evento', tag: _logTag, data: {'eventId': eventId});
      
      await _client
          .from('events')
          .delete()
          .eq('id', eventId);
      
      LogUtils.info('Evento deletado com sucesso', tag: _logTag, data: {'eventId': eventId});
    } on PostgrestException catch (e) {
      LogUtils.error('Erro PostgreSQL ao deletar evento', tag: _logTag, error: e);
      throw Exception('Erro ao deletar evento: ${e.message}');
    } catch (e) {
      LogUtils.error('Erro inesperado ao deletar evento', tag: _logTag, error: e);
      throw Exception('Erro inesperado ao deletar evento');
    }
  }

  @override
  Future<void> registerForEvent({required String eventId, required String userId}) async {
    try {
      LogUtils.info('Registrando usuário no evento', tag: _logTag, data: {'eventId': eventId, 'userId': userId});
      
      await _client
          .from('event_registrations')
          .insert({
            'event_id': eventId,
            'user_id': userId,
            'registered_at': DateTime.now().toIso8601String(),
          });
      
      // Incrementar contador de participantes
      await _client.rpc('increment_event_attendees', params: {'event_id': eventId});
      
      LogUtils.info('Usuário registrado no evento com sucesso', tag: _logTag, data: {'eventId': eventId, 'userId': userId});
    } on PostgrestException catch (e) {
      LogUtils.error('Erro PostgreSQL ao registrar no evento', tag: _logTag, error: e);
      throw Exception('Erro ao se inscrever no evento: ${e.message}');
    } catch (e) {
      LogUtils.error('Erro inesperado ao registrar no evento', tag: _logTag, error: e);
      throw Exception('Erro inesperado ao se inscrever no evento');
    }
  }

  @override
  Future<void> cancelRegistration({required String eventId, required String userId}) async {
    try {
      LogUtils.info('Cancelando registro no evento', tag: _logTag, data: {'eventId': eventId, 'userId': userId});
      
      await _client
          .from('event_registrations')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);
      
      // Decrementar contador de participantes
      await _client.rpc('decrement_event_attendees', params: {'event_id': eventId});
      
      LogUtils.info('Registro cancelado com sucesso', tag: _logTag, data: {'eventId': eventId, 'userId': userId});
    } on PostgrestException catch (e) {
      LogUtils.error('Erro PostgreSQL ao cancelar registro', tag: _logTag, error: e);
      throw Exception('Erro ao cancelar inscrição: ${e.message}');
    } catch (e) {
      LogUtils.error('Erro inesperado ao cancelar registro', tag: _logTag, error: e);
      throw Exception('Erro inesperado ao cancelar inscrição');
    }
  }

  @override
  Future<List<Event>> getUserEvents(String userId) async {
    try {
      LogUtils.info('Buscando eventos do usuário', tag: _logTag, data: {'userId': userId});
      
      final response = await _client
          .from('event_registrations')
          .select('events(*)')
          .eq('user_id', userId);
      
      final events = (response as List)
          .map((item) => Event.fromJson(item['events']))
          .toList();
      
      LogUtils.info('Eventos do usuário carregados', tag: _logTag, data: {'userId': userId, 'count': events.length});
      
      return events;
    } on PostgrestException catch (e) {
      LogUtils.error('Erro PostgreSQL ao buscar eventos do usuário', tag: _logTag, error: e);
      throw Exception('Erro ao carregar seus eventos: ${e.message}');
    } catch (e) {
      LogUtils.error('Erro inesperado ao buscar eventos do usuário', tag: _logTag, error: e);
      throw Exception('Erro inesperado ao carregar seus eventos');
    }
  }
}

/// Provider para o repositório de eventos
final eventRepositoryProvider = Provider<IEventRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final eventBus = ref.watch(appEventBusProvider);
  final dio = Dio(); // Configurar conforme necessário
  
  return EventRepository(
    client: client,
    eventBus: eventBus,
    dio: dio,
  );
}); 