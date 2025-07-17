# Atualização em Tempo Real do Dashboard

## Visão Geral

Este documento descreve a implementação de uma solução híbrida para atualização em tempo real do dashboard do Ray Club App. A solução combina múltiplas abordagens para garantir uma experiência consistente e confiável para o usuário.

## Componentes da Solução

### 1. Funções SQL 

- **Função de Refresh Explícito**: Nova função `refresh_dashboard_data` que permite forçar uma atualização completa dos dados do dashboard para um usuário específico.
- **Modificação da Função de Check-in**: Adicionada notificação de eventos ao final da função `record_challenge_check_in` para informar quando um treino é registrado.

### 2. Suporte a Eventos PostgreSQL

- Utilização de `pg_notify` para emitir eventos quando dados relevantes ao dashboard são alterados.
- O formato do evento contém o ID do usuário e informações sobre a ação realizada.

### 3. Listener em Tempo Real na Aplicação

- Implementação de um listener no `DashboardViewModel` que escuta eventos do banco de dados.
- Configuração do listener durante a inicialização do aplicativo e após login.

### 4. Força Atualização Explícita

- Método `forceRefresh()` no `DashboardViewModel` para situações onde é necessário garantir atualização completa.
- Chamada direta após o registro de um treino no `WorkoutRecordViewModel`.

## Guia de Instalação

### 1. Aplicar Migração SQL

Execute o script SQL para criar/modificar as funções necessárias:

```bash
cd sql
psql -U seu_usuario -d seu_banco -f apply_migrations.sql
```

Alternativamente, execute diretamente no painel de administração do Supabase:

1. Acesse o painel do Supabase
2. Vá para SQL Editor
3. Cole o conteúdo de `sql/migrations/001_dashboard_refresh.sql`
4. Execute o script

### 2. Verificar Permissões

Certifique-se que as funções RPC podem ser executadas pelo cliente anônimo:

```sql
GRANT EXECUTE ON FUNCTION refresh_dashboard_data(UUID) TO anon, authenticated;
```

### 3. Ativar Eventos no Supabase

Verifique se os eventos em tempo real estão ativados no Supabase:

1. Acesse o painel do Supabase
2. Vá para Database > Replication
3. Certifique-se que "Realtime" está ativado
4. Na seção "Events" ative "Database events" e "Broadcast events"

## Como Funciona

1. **Registro de Treino**:
   - Quando um usuário registra um treino, o `WorkoutRecordViewModel` salva o treino e chama `dashboardViewModel.forceRefresh()`
   - A função SQL `record_challenge_check_in` emite um evento via `pg_notify`

2. **Recepção de Eventos**:
   - O `DashboardViewModel` está escutando eventos da tabela `workout_records`
   - Quando um evento é recebido, o método `refreshData()` é chamado para atualizar o dashboard

3. **Inicialização do App**:
   - Durante a inicialização e após login, `setupDashboardUpdateListener()` configura a escuta de eventos
   - A classe `app_startup.dart` gerencia a inicialização de componentes dependentes de autenticação

## Depuração

Para verificar se os eventos estão sendo recebidos, observe os logs do aplicativo:
- `📢 Evento de workout recebido: [detalhes]`
- `📢 Notificação de atualização para dashboard recebida`
- `🔄 Atualizando dados do dashboard`

Se não estiver recebendo eventos, verifique:
1. Se os eventos estão ativados no Supabase
2. Se há permissão para executar as funções RPC
3. Se o canal está subscrito corretamente

## Benefícios desta Abordagem

- **Múltiplos Caminhos para Atualização**: Combina atualizações explícitas e reativas
- **Baixa Latência**: Eventos em tempo real permitem atualizações instantâneas
- **Confiabilidade**: Atualização forçada como fallback quando necessário
- **Eficiência**: Utiliza sistemas nativos do PostgreSQL para notificações
- **Manutenibilidade**: Componentes bem segregados e com responsabilidades claras 