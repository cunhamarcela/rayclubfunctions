# Sistema de Metas Semanais - Guia de Configuração

## 📋 Visão Geral

O sistema de metas semanais permite que os usuários definam suas próprias metas de tempo de treino por semana. As metas são renovadas automaticamente toda segunda-feira e o progresso é acompanhado em tempo real.

## 🚀 Configuração no Supabase

### 1. Execute o SQL de criação

Execute o arquivo `sql/create_weekly_goals_system.sql` no editor SQL do Supabase para criar:

- Tabela `weekly_goals`
- Funções de gerenciamento
- Políticas RLS
- Índices de performance

### 2. Configure o Cron Job (Importante!)

Para que as metas sejam renovadas automaticamente toda segunda-feira, configure um cron job no Supabase:

1. Vá para **Database > Extensions**
2. Habilite a extensão `pg_cron` se ainda não estiver habilitada
3. Execute o seguinte SQL para criar o job:

```sql
-- Criar job para resetar metas semanais toda segunda-feira às 00:00
SELECT cron.schedule(
    'reset-weekly-goals',           -- nome do job
    '0 0 * * 1',                   -- toda segunda-feira à meia-noite
    $$SELECT reset_old_weekly_goals();$$
);

-- Para verificar se o job foi criado:
SELECT * FROM cron.job;

-- Para remover o job (se necessário):
SELECT cron.unschedule('reset-weekly-goals');
```

### 3. Integração com Sistema de Treinos

Para que os minutos de treino sejam automaticamente adicionados às metas semanais, adicione um trigger:

```sql
-- Trigger para atualizar meta semanal quando um treino é registrado
CREATE OR REPLACE FUNCTION update_weekly_goal_on_workout()
RETURNS TRIGGER AS $$
BEGIN
    -- Adicionar minutos do treino à meta semanal
    IF NEW.duration_minutes IS NOT NULL AND NEW.duration_minutes > 0 THEN
        PERFORM add_workout_minutes_to_goal(NEW.user_id, NEW.duration_minutes);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger na tabela de treinos (ajuste o nome da tabela conforme necessário)
CREATE TRIGGER update_weekly_goal_after_workout
    AFTER INSERT ON workouts
    FOR EACH ROW
    EXECUTE FUNCTION update_weekly_goal_on_workout();
```

## 🎯 Funcionalidades

### Para o Usuário

1. **Escolher Meta Predefinida**:
   - Iniciante: 1 hora/semana
   - Leve: 2 horas/semana
   - Moderado: 3 horas/semana (padrão)
   - Ativo: 5 horas/semana
   - Intenso: 7 horas/semana
   - Atleta: 10 horas/semana

2. **Meta Personalizada**:
   - Entre 30 minutos e 24 horas por semana

3. **Acompanhamento**:
   - Barra de progresso visual
   - Porcentagem de conclusão
   - Indicador de meta atingida
   - Calendário semanal com dias treinados

### Renovação Automática

- Toda segunda-feira às 00:00
- Mantém a mesma meta da semana anterior
- Zera o contador de minutos
- Cria nova entrada no histórico

## 📱 Uso no App

### Widget de Seleção de Meta

```dart
// Mostrar seletor de meta em modal
WeeklyGoalSelectorWidget(
  onGoalUpdated: () {
    // Callback após atualização
  },
)
```

### Dashboard de Progresso

```dart
// Widget completo com calendário e progresso
const WeeklyProgressDashboard()
```

### Acessar dados via ViewModel

```dart
// No seu widget
final goalState = ref.watch(weeklyGoalViewModelProvider);

// Meta atual
final currentGoal = goalState.currentGoal;

// Atualizar meta
ref.read(weeklyGoalViewModelProvider.notifier).updateGoal(300); // 5 horas
```

## 🔧 Manutenção

### Verificar Jobs Ativos

```sql
-- Ver todos os jobs do cron
SELECT * FROM cron.job;

-- Ver histórico de execuções
SELECT * FROM cron.job_run_details 
WHERE jobname = 'reset-weekly-goals' 
ORDER BY start_time DESC 
LIMIT 10;
```

### Resetar Meta Manualmente

```sql
-- Para um usuário específico
SELECT reset_old_weekly_goals();

-- Para criar nova meta para usuário específico
SELECT get_or_create_weekly_goal('user-uuid-here');
```

## 📊 Monitoramento

### Queries Úteis

```sql
-- Ver metas da semana atual
SELECT 
    u.email,
    wg.goal_minutes,
    wg.current_minutes,
    wg.percentage_completed,
    wg.completed
FROM weekly_goals wg
JOIN auth.users u ON u.id = wg.user_id
WHERE wg.week_start_date = date_trunc('week', CURRENT_DATE)::date
ORDER BY wg.percentage_completed DESC;

-- Estatísticas gerais
SELECT 
    COUNT(*) as total_users,
    AVG(goal_minutes) as avg_goal_minutes,
    AVG(current_minutes) as avg_current_minutes,
    COUNT(*) FILTER (WHERE completed = true) as completed_goals,
    ROUND(AVG(percentage_completed), 2) as avg_completion_rate
FROM weekly_goals
WHERE week_start_date = date_trunc('week', CURRENT_DATE)::date;
```

## 🐛 Troubleshooting

### Meta não está sendo criada automaticamente

1. Verifique se o cron job está ativo
2. Verifique logs de erro: `SELECT * FROM cron.job_run_details WHERE status = 'failed'`
3. Execute manualmente: `SELECT reset_old_weekly_goals()`

### Minutos não estão sendo contabilizados

1. Verifique se o trigger está criado na tabela de treinos
2. Verifique se o campo `duration_minutes` está sendo preenchido
3. Teste manualmente: `SELECT add_workout_minutes_to_goal('user-id', 30)`

### Performance lenta

1. Verifique se os índices foram criados
2. Execute `ANALYZE weekly_goals;` para atualizar estatísticas
3. Considere particionar a tabela por mês se houver muitos dados históricos 