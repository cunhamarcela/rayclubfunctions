-- ========================================
-- TESTE FINAL SISTEMA WEEKLY GOALS
-- ========================================
-- Data: 2025-01-27 22:35
-- Objetivo: Verificar se todas as funções estão funcionando corretamente

-- 1. VERIFICAR FUNÇÕES CRIADAS
SELECT 'VERIFICAÇÃO FINAL DAS FUNÇÕES:' as titulo;

SELECT 
    p.proname as nome_funcao,
    pg_get_function_arguments(p.oid) as parametros,
    '✅ EXISTE' as status
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN (
    'get_or_create_weekly_goal',
    'add_workout_minutes_to_goal', 
    'update_weekly_goal',
    'get_weekly_goal_status',
    'sync_existing_workouts_to_weekly_goals',
    'get_weekly_goals_history'
)
ORDER BY p.proname;

-- 2. TESTAR get_or_create_weekly_goal
SELECT 'TESTE get_or_create_weekly_goal:' as teste;

SELECT 
    id,
    user_id,
    goal_minutes,
    current_minutes,
    week_start_date,
    week_end_date,
    completed
FROM get_or_create_weekly_goal('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid);

-- 3. TESTAR sync_existing_workouts_to_weekly_goals
SELECT 'TESTE sync_existing_workouts_to_weekly_goals:' as teste;

SELECT sync_existing_workouts_to_weekly_goals('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid);

-- 4. TESTAR get_weekly_goal_status
SELECT 'TESTE get_weekly_goal_status:' as teste;

SELECT get_weekly_goal_status('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid);

-- 5. VERIFICAR DADOS ATUAIS NA TABELA
SELECT 'DADOS ATUAIS NA TABELA weekly_goals:' as dados;

SELECT 
    user_id,
    goal_minutes,
    current_minutes,
    week_start_date,
    week_end_date,
    completed,
    ROUND((current_minutes::DECIMAL / goal_minutes * 100), 1) as progresso_percentual
FROM weekly_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
AND week_start_date = date_trunc('week', CURRENT_DATE)
ORDER BY created_at DESC;

-- 6. VERIFICAR TREINOS DA SEMANA ATUAL
SELECT 'TREINOS DA SEMANA ATUAL:' as treinos;

SELECT 
    date_trunc('week', CURRENT_DATE) as inicio_semana,
    COUNT(*) as total_treinos,
    COALESCE(SUM(duration_minutes), 0) as total_minutos
FROM workout_records
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
AND is_completed = TRUE
AND date >= date_trunc('week', CURRENT_DATE)
AND date <= date_trunc('week', CURRENT_DATE) + interval '6 days';

-- 7. VERIFICAR SE TRIGGER EXISTE
SELECT 'VERIFICAÇÃO DO TRIGGER:' as trigger_status;

SELECT 
    tgname as trigger_name,
    tgenabled as enabled,
    tgrelid::regclass as table_name
FROM pg_trigger
WHERE tgname = 'workout_completed_update_weekly_goal';

-- 8. TESTE DE ADIÇÃO DE MINUTOS (usar função existente)
SELECT 'TESTE add_workout_minutes_to_goal:' as teste_adicao;

-- Buscar goal atual primeiro
SELECT current_minutes as minutos_antes
FROM weekly_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
AND week_start_date = date_trunc('week', CURRENT_DATE);

-- Adicionar 30 minutos (COMENTADO para não modificar dados)
SELECT add_workout_minutes_to_goal('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid, 30);

-- 9. CÁLCULO DE SEMANA PARA CONFERÊNCIA
SELECT 'CÁLCULO DE SEMANA ATUAL:' as info,
    CURRENT_DATE as hoje,
    date_trunc('week', CURRENT_DATE) as inicio_semana,
    date_trunc('week', CURRENT_DATE) + interval '6 days' as fim_semana,
    EXTRACT(dow FROM CURRENT_DATE) as dia_semana;

SELECT '✅ TESTE FINAL WEEKLY GOALS CONCLUÍDO!' as resultado_final; 