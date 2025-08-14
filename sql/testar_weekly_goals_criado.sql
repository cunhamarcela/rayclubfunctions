-- ========================================
-- TESTE SISTEMA WEEKLY GOALS APÓS CRIAÇÃO
-- ========================================
-- Data: 2025-01-27 22:20
-- Objetivo: Verificar se tudo foi criado corretamente e sincronizar dados

-- 1. VERIFICAR CRIAÇÃO BEM-SUCEDIDA
SELECT 'VERIFICAÇÃO PÓS-CRIAÇÃO:' as titulo;

-- Verificar tabela
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'weekly_goals')
        THEN '✅ Tabela weekly_goals criada com sucesso'
        ELSE '❌ Tabela weekly_goals não encontrada'
    END as status_tabela;

-- Verificar funções
SELECT 
    'FUNÇÕES CRIADAS:' as secao,
    COUNT(*) as total_funcoes
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN (
    'get_or_create_weekly_goal',
    'add_workout_minutes_to_goal', 
    'update_weekly_goal',
    'sync_existing_workouts_to_weekly_goals',
    'get_weekly_goal_status'
);

-- 2. TESTAR FUNÇÃO get_or_create_weekly_goal PARA USUÁRIO ATIVO
SELECT 'TESTE GET_OR_CREATE_WEEKLY_GOAL:' as teste;

-- Criar weekly goal para usuário de teste
SELECT 
    id,
    user_id,
    goal_minutes,
    current_minutes,
    week_start_date,
    week_end_date,
    completed
FROM get_or_create_weekly_goal('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid);

-- 3. SINCRONIZAR DADOS EXISTENTES DA SEMANA ATUAL
SELECT 'SINCRONIZAÇÃO AUTOMÁTICA:' as secao;

-- Executar sync para dados existentes
SELECT sync_existing_workouts_to_weekly_goals('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid);

-- 4. VERIFICAR STATUS FINAL
SELECT 'STATUS FINAL WEEKLY GOAL:' as resultado;

SELECT get_weekly_goal_status('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid);

-- 5. VERIFICAR DADOS BRUTOS NA TABELA
SELECT 'DADOS DIRETOS DA TABELA:' as dados;

SELECT 
    id,
    goal_minutes,
    current_minutes,
    week_start_date,
    week_end_date,
    completed,
    created_at
FROM weekly_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid;

-- 6. CALCULAR TREINOS DA SEMANA ATUAL MANUALMENTE (para conferir)
SELECT 'CONFERÊNCIA MANUAL - TREINOS DESTA SEMANA:' as conferencia;

SELECT 
    date_trunc('week', CURRENT_DATE) as inicio_semana,
    date_trunc('week', CURRENT_DATE) + interval '6 days' as fim_semana,
    COUNT(*) as total_treinos,
    COALESCE(SUM(duration_minutes), 0) as total_minutos
FROM workout_records
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
AND is_completed = TRUE
AND date >= date_trunc('week', CURRENT_DATE)
AND date <= date_trunc('week', CURRENT_DATE) + interval '6 days';

-- 7. VERIFICAR SE TRIGGER ESTÁ ATIVO
SELECT 'VERIFICAÇÃO TRIGGER:' as trigger_check;

SELECT 
    tgname as trigger_name,
    tgenabled as enabled,
    'workout_records' as table_name
FROM pg_trigger
WHERE tgname = 'workout_completed_update_weekly_goal';

SELECT '✅ TESTE COMPLETO WEEKLY GOALS CONCLUÍDO!' as resultado_final; 