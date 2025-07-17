# Feature de Eventos

Esta feature implementa o sistema de eventos do Ray Club App, permitindo que usuários visualizem e se inscrevam em eventos.

## Estrutura

### Modelos
- **Event**: Modelo principal que representa um evento
- **EventsState**: Estado da aplicação para gerenciar eventos

### Repositório
- **EventRepository**: Gerencia operações CRUD de eventos no Supabase
- Interface com tratamento de erros usando Dio
- Publicação de eventos usando AppEventBus

### ViewModel
- **EventViewModel**: Gerencia o estado dos eventos seguindo padrão MVVM
- Nunca usa setState(), apenas StateNotifier com Riverpod
- Métodos principais:
  - `loadEvents()`: Carrega lista de eventos
  - `registerForEvent()`: Inscreve usuário em evento
  - `cancelRegistration()`: Cancela inscrição
  - `filterEvents()`: Filtra eventos por tipo

### Telas
- **EventsScreen**: Tela principal que exibe lista de eventos
- Inclui imagem de destaque dos eventos
- Sistema de filtros por tipo
- Pull-to-refresh
- Estados de loading, erro e lista vazia

### Widgets
- **EventCard**: Card para exibir informações de um evento
- Suporte a imagens
- Contador de participantes
- Botão de inscrição

## Navegação

### Rotas
- `/events` - Lista de eventos
- `/events/:eventId` - Detalhes de um evento específico

### Métodos de Navegação
- `AppNavigator.navigateToEvents(context)` - Navega para lista de eventos
- `AppNavigator.navigateToEventDetail(context, eventId)` - Navega para detalhes

## Integração

### Home Screen
O botão "Eventos" no menu lateral e nas ações rápidas navega para a tela de eventos.

### Banco de Dados
Espera-se as seguintes tabelas no Supabase:
- `events` - Tabela principal de eventos
- `event_registrations` - Tabela de inscrições de usuários em eventos

### Funções RPC Esperadas
- `increment_event_attendees(event_id)` - Incrementa contador de participantes
- `decrement_event_attendees(event_id)` - Decrementa contador de participantes

## Testes

Testes básicos implementados em `test/features/events/screens/events_screen_test.dart`:
- Renderização da tela
- Estados de loading e erro
- Exibição de eventos
- Funcionalidade de filtros
- Pull-to-refresh

## Assets

A tela utiliza a imagem `assets/images/WhatsApp Image 2025-06-05 at 20.37.12.jpeg` como imagem de destaque dos eventos. 