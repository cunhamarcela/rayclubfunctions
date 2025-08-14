-- ========================================
-- FUNÇÃO: DEFINIR PROGRESSO ABSOLUTO PARA CHECK-INS
-- ========================================
-- Data: 2025-07-28
-- Objetivo: Criar função que DEFINE valor absoluto (não soma) para check-ins de bolinhas
-- Problema: addProgress soma valores, mas para check-ins queremos definir posição absoluta

-- Função para definir progresso absoluto (para check-ins/dias)
CREATE OR REPLACE FUNCTION set_weekly_goal_progress_absolute(
    p_user_id UUID,
    p_absolute_value NUMERIC,
    p_measurement_type TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_goal_id UUID;
    v_current_week_start DATE;
BEGIN
    -- 1. Calcular início da semana atual
    v_current_week_start := date_trunc('week', CURRENT_DATE)::DATE;
    
    -- 2. Buscar meta ativa da semana atual para este usuário e tipo
    SELECT id INTO v_goal_id
    FROM weekly_goals_expanded
    WHERE user_id = p_user_id
      AND week_start_date = v_current_week_start
      AND measurement_type = p_measurement_type
      AND active = true
    ORDER BY created_at DESC
    LIMIT 1;
    
    -- 3. Se não encontrou meta ativa, retornar false
    IF v_goal_id IS NULL THEN
        RAISE LOG 'Nenhuma meta ativa encontrada para user_id: %, measurement_type: %', p_user_id, p_measurement_type;
        RETURN FALSE;
    END IF;
    
    -- 4. DEFINIR valor absoluto (não somar!)
    UPDATE weekly_goals_expanded
    SET 
        current_value = p_absolute_value,
        updated_at = NOW()
    WHERE id = v_goal_id;
    
    -- 5. Verificar se foi atualizado
    IF FOUND THEN
        RAISE LOG 'Progresso absoluto definido com sucesso: goal_id=%, new_value=%', v_goal_id, p_absolute_value;
        RETURN TRUE;
    ELSE
        RAISE LOG 'Falha ao definir progresso absoluto para goal_id: %', v_goal_id;
        RETURN FALSE;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE LOG 'Erro ao definir progresso absoluto: %', SQLERRM;
        RETURN FALSE;
END;
$$;

-- Dar permissões
GRANT EXECUTE ON FUNCTION set_weekly_goal_progress_absolute TO authenticated;

-- Comentário explicativo
COMMENT ON FUNCTION set_weekly_goal_progress_absolute IS 
'Define valor absoluto do progresso de uma meta (usado para check-ins de bolinhas). 
Diferente de update_weekly_goal_progress que SOMA valores, esta função DEFINE o valor total.'; 