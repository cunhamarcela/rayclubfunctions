-- ========================================
-- CONECTAR TREINOS AO SISTEMA WEEKLY GOALS
-- ========================================
-- Data: 2025-01-27 21:55
-- Objetivo: Garantir que treinos completados atualizem automaticamente a meta semanal

-- 1. CRIAR TRIGGER PARA ATUALIZAR WEEKLY GOALS AUTOMATICAMENTE
CREATE OR REPLACE FUNCTION update_weekly_goal_on_workout()
RETURNS TRIGGER AS $$
BEGIN
    -- Só processar se o treino foi completado
    IF NEW.is_completed = true AND NEW.duration_minutes > 0 THEN
        -- Adicionar minutos à meta semanal
        PERFORM add_workout_minutes_to_goal(
            NEW.user_id, 
            NEW.duration_minutes
        );
        
        -- Log para debug
        RAISE LOG 'Weekly goal atualizada: user_id=%, minutos=+%', 
            NEW.user_id, NEW.duration_minutes;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger na tabela workout_records
DROP TRIGGER IF EXISTS workout_completed_update_weekly_goal ON workout_records;

CREATE TRIGGER workout_completed_update_weekly_goal
    AFTER INSERT OR UPDATE ON workout_records
    FOR EACH ROW
    WHEN (NEW.is_completed = true AND NEW.duration_minutes > 0)
    EXECUTE FUNCTION update_weekly_goal_on_workout();

-- 2. FUNÇÃO PARA SINCRONIZAR DADOS EXISTENTES
CREATE OR REPLACE FUNCTION sync_existing_workouts_to_weekly_goals()
RETURNS TEXT AS $$
DECLARE
    v_current_week_start DATE;
    v_current_week_end DATE;
    v_user_record RECORD;
    v_total_minutes INTEGER;
    v_users_updated INTEGER := 0;
BEGIN
    -- Calcular semana atual
    v_current_week_start := date_trunc('week', CURRENT_DATE)::date;
    v_current_week_end := v_current_week_start + interval '6 days';
    
    -- Para cada usuário com treinos na semana atual
    FOR v_user_record IN 
        SELECT 
            user_id,
            SUM(duration_minutes) as total_minutes
        FROM workout_records 
        WHERE is_completed = true 
        AND duration_minutes > 0
        AND DATE(date) >= v_current_week_start 
        AND DATE(date) <= v_current_week_end
        GROUP BY user_id
    LOOP
        -- Garantir que existe meta semanal
        PERFORM get_or_create_weekly_goal(v_user_record.user_id);
        
        -- Atualizar current_minutes para o total real da semana
        UPDATE weekly_goals 
        SET current_minutes = v_user_record.total_minutes,
            completed = v_user_record.total_minutes >= goal_minutes
        WHERE user_id = v_user_record.user_id 
        AND week_start_date = v_current_week_start;
        
        v_users_updated := v_users_updated + 1;
        
        RAISE LOG 'Sincronizado usuário %: % minutos', 
            v_user_record.user_id, v_user_record.total_minutes;
    END LOOP;
    
    RETURN format('Sincronizados %s usuários com dados da semana atual', v_users_updated);
END;
$$ LANGUAGE plpgsql;

-- 3. EXECUTAR SINCRONIZAÇÃO INICIAL
SELECT sync_existing_workouts_to_weekly_goals();

-- 4. VERIFICAR RESULTADO PARA USUÁRIO ESPECÍFICO
SELECT 
    'VERIFICAÇÃO PÓS-SINCRONIZAÇÃO:' as titulo,
    'User: 01d4a292-1873-4af6-948b-a55eed56d6b9' as usuario;

SELECT 
    'DADOS ATUAIS WEEKLY GOAL:' as secao,
    goal_minutes,
    current_minutes,
    (current_minutes::float / goal_minutes::float * 100)::int as percentage,
    completed,
    week_start_date,
    week_end_date
FROM weekly_goals 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
AND week_start_date = date_trunc('week', CURRENT_DATE)::date;

-- Comparar com treinos reais da semana
SELECT 
    'TREINOS DA SEMANA ATUAL:' as secao,
    COUNT(*) as total_treinos,
    SUM(duration_minutes) as total_minutos
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid
AND is_completed = true
AND DATE(date) >= date_trunc('week', CURRENT_DATE)::date
AND DATE(date) <= (date_trunc('week', CURRENT_DATE)::date + interval '6 days')::date;

-- 5. STATUS FINAL
SELECT 
    'STATUS FINAL:' as titulo,
    '✅ Trigger criado para novos treinos' as acao1,
    '✅ Dados existentes sincronizados' as acao2,
    '✅ Sistema conectado Dashboard ↔ Weekly Goals' as resultado; 