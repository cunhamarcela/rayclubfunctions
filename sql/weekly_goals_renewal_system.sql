-- ========================================
-- SISTEMA DE RENOVAÇÃO SEMANAL DAS METAS
-- ========================================
-- Data: 2025-07-28
-- Objetivo: Garantir que metas sejam zeradas automaticamente toda semana

-- 1. Função para renovar metas da semana
CREATE OR REPLACE FUNCTION renew_weekly_goals()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_week_start DATE;
    v_previous_week_start DATE;
BEGIN
    -- Calcular início da semana atual e anterior
    v_current_week_start := date_trunc('week', CURRENT_DATE)::DATE;
    v_previous_week_start := v_current_week_start - INTERVAL '7 days';
    
    -- Log da operação
    RAISE LOG 'Iniciando renovação semanal de metas. Semana atual: %, Semana anterior: %', 
              v_current_week_start, v_previous_week_start;
    
    -- 1. Marcar metas da semana anterior como inativas
    UPDATE weekly_goals_expanded 
    SET 
        active = false,
        updated_at = NOW()
    WHERE week_start_date = v_previous_week_start
      AND active = true;
    
    -- 2. Criar novas metas para a semana atual baseadas nas metas da semana anterior
    INSERT INTO weekly_goals_expanded (
        user_id, 
        goal_type, 
        measurement_type, 
        goal_title, 
        goal_description, 
        target_value, 
        current_value, 
        unit_label, 
        week_start_date, 
        week_end_date, 
        completed, 
        active,
        created_at,
        updated_at
    )
    SELECT 
        user_id,
        goal_type,
        measurement_type,
        goal_title,
        goal_description,
        target_value,
        0 as current_value, -- ZERADA PARA A NOVA SEMANA
        unit_label,
        v_current_week_start as week_start_date,
        (v_current_week_start + INTERVAL '6 days')::DATE as week_end_date,
        false as completed, -- RESETADA PARA NOVA SEMANA
        true as active,
        NOW() as created_at,
        NOW() as updated_at
    FROM weekly_goals_expanded
    WHERE week_start_date = v_previous_week_start
      AND active = false -- Usar as que acabamos de desativar
    ON CONFLICT (user_id, week_start_date, goal_type, goal_title) 
    DO NOTHING; -- Evitar duplicatas caso já existam metas para esta semana
    
    -- Log de conclusão
    RAISE LOG 'Renovação semanal concluída com sucesso.';
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE LOG 'ERRO na renovação semanal: %', SQLERRM;
        RAISE;
END;
$$;

-- 2. Função para verificar e renovar metas se necessário
CREATE OR REPLACE FUNCTION check_and_renew_goals()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_week_start DATE;
    v_active_goals_count INTEGER;
BEGIN
    v_current_week_start := date_trunc('week', CURRENT_DATE)::DATE;
    
    -- Verificar se existem metas ativas para a semana atual
    SELECT COUNT(*) INTO v_active_goals_count
    FROM weekly_goals_expanded 
    WHERE week_start_date = v_current_week_start 
      AND active = true;
    
    -- Se não há metas para a semana atual, renovar
    IF v_active_goals_count = 0 THEN
        RAISE LOG 'Nenhuma meta ativa para a semana atual. Iniciando renovação...';
        PERFORM renew_weekly_goals();
    ELSE
        RAISE LOG 'Metas já existem para a semana atual (%). Renovação não necessária.', v_active_goals_count;
    END IF;
END;
$$;

-- 3. Dar permissões
GRANT EXECUTE ON FUNCTION renew_weekly_goals TO authenticated;
GRANT EXECUTE ON FUNCTION check_and_renew_goals TO authenticated;

-- 4. Comentários para uso
COMMENT ON FUNCTION renew_weekly_goals() IS 'Renova metas semanais, zerando progresso e criando novas para a semana atual';
COMMENT ON FUNCTION check_and_renew_goals() IS 'Verifica se precisa renovar metas e executa se necessário'; 