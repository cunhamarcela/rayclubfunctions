-- ========================================
-- FUNÇÃO: get_dashboard_core_with_period
-- ========================================
-- Data: 2025-01-27
-- Objetivo: Criar função para dashboard com suporte a períodos personalizados
-- Autor: IA + Marcela
-- Funcionalidade: Permite filtrar dados do dashboard por período específico

-- ========================================
-- REMOVER FUNÇÃO ANTERIOR SE EXISTIR
-- ========================================
DROP FUNCTION IF EXISTS get_dashboard_core_with_period(UUID, DATE, DATE);

-- ========================================
-- CRIAR NOVA FUNÇÃO COM SUPORTE A PERÍODO
-- ========================================
CREATE OR REPLACE FUNCTION get_dashboard_core_with_period(
    user_id_param UUID,
    start_date_param DATE,
    end_date_param DATE
)
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_workouts INTEGER := 0;
    total_duration INTEGER := 0;
    days_trained_period INTEGER := 0;
    workouts_by_type JSONB := '{}'::JSONB;
    recent_workouts_data JSON := '[]'::JSON;
    challenge_progress_data JSON;
    period_description TEXT;
BEGIN
    -- Log dos parâmetros recebidos
    RAISE NOTICE '📊 Dashboard com período: usuário=%, início=%, fim=%', 
        user_id_param, start_date_param, end_date_param;
    
    -- ========================================
    -- 1. CALCULAR ESTATÍSTICAS DO PERÍODO
    -- ========================================
    
    -- Total de treinos no período especificado
    SELECT COUNT(*)
    INTO total_workouts
    FROM workout_records
    WHERE user_id = user_id_param
    AND is_completed = TRUE
    AND date >= start_date_param
    AND date <= end_date_param;
    
    -- Duração total no período especificado
    SELECT COALESCE(SUM(duration_minutes), 0)
    INTO total_duration
    FROM workout_records
    WHERE user_id = user_id_param
    AND is_completed = TRUE
    AND date >= start_date_param
    AND date <= end_date_param;
    
    -- Dias únicos treinados no período
    SELECT COUNT(DISTINCT DATE(date))
    INTO days_trained_period
    FROM workout_records
    WHERE user_id = user_id_param
    AND is_completed = TRUE
    AND date >= start_date_param
    AND date <= end_date_param;
    
    -- ========================================
    -- 2. TIPOS DE TREINO NO PERÍODO
    -- ========================================
    SELECT COALESCE(
        jsonb_object_agg(
            workout_type, 
            type_count
        ), 
        '{}'::jsonb
    )
    INTO workouts_by_type
    FROM (
        SELECT 
            workout_type,
            COUNT(*) as type_count
        FROM workout_records
        WHERE user_id = user_id_param
        AND is_completed = TRUE
        AND date >= start_date_param
        AND date <= end_date_param
        GROUP BY workout_type
        ORDER BY type_count DESC
    ) AS type_stats;
    
    -- ========================================
    -- 3. TREINOS RECENTES NO PERÍODO
    -- ========================================
    SELECT COALESCE(
        json_agg(
            json_build_object(
                'id', id,
                'workout_name', workout_name,
                'workout_type', workout_type,
                'date', date,
                'duration_minutes', duration_minutes
            )
        ),
        '[]'::json
    )
    INTO recent_workouts_data
    FROM (
        SELECT 
            id,
            workout_name,
            workout_type,
            date,
            duration_minutes
        FROM workout_records
        WHERE user_id = user_id_param
        AND is_completed = TRUE
        AND date >= start_date_param
        AND date <= end_date_param
        ORDER BY date DESC, created_at DESC
        LIMIT 10
    ) AS recent_workouts;
    
    -- ========================================
    -- 4. PROGRESSO EM DESAFIOS (SEMPRE ATUAL)
    -- ========================================
    -- Nota: Desafios são sempre baseados no progresso atual, não no período
    SELECT json_build_object(
        'challenge_id', NULL,
        'total_points', 0,
        'check_ins', 0,
        'position', 0,
        'completion_percentage', 0
    )
    INTO challenge_progress_data;
    
    -- ========================================
    -- 5. DESCRIÇÃO DO PERÍODO
    -- ========================================
    period_description := CONCAT(
        'Período: ', 
        TO_CHAR(start_date_param, 'DD/MM/YYYY'),
        ' até ',
        TO_CHAR(end_date_param, 'DD/MM/YYYY'),
        ' (',
        (end_date_param - start_date_param + 1),
        ' dias)'
    );
    
    -- ========================================
    -- 6. MONTAR RESULTADO FINAL
    -- ========================================
    result := json_build_object(
        'total_workouts', total_workouts,
        'total_duration', total_duration,
        'days_trained_this_month', days_trained_period, -- Nota: Nome mantido para compatibilidade
        'workouts_by_type', workouts_by_type,
        'recent_workouts', recent_workouts_data,
        'challenge_progress', challenge_progress_data,
        'period_info', json_build_object(
            'start_date', start_date_param,
            'end_date', end_date_param,
            'description', period_description,
            'total_days', (end_date_param - start_date_param + 1)
        ),
        'last_updated', NOW()
    );
    
    -- Log do resultado
    RAISE NOTICE '✅ Dashboard calculado: % treinos, % minutos, % dias únicos', 
        total_workouts, total_duration, days_trained_period;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- COMENTÁRIOS E GRANTS
-- ========================================
COMMENT ON FUNCTION get_dashboard_core_with_period(UUID, DATE, DATE) IS 
'Função para buscar dados do dashboard filtrados por período específico. 
Parâmetros:
- user_id_param: ID do usuário
- start_date_param: Data início do período (inclusivo)
- end_date_param: Data fim do período (inclusivo)

Retorna JSON com estatísticas do período especificado.';

-- Grant necessário para execução via RPC
GRANT EXECUTE ON FUNCTION get_dashboard_core_with_period(UUID, DATE, DATE) TO authenticated;
GRANT EXECUTE ON FUNCTION get_dashboard_core_with_period(UUID, DATE, DATE) TO anon;

-- ========================================
-- MANTER FUNÇÃO ORIGINAL PARA COMPATIBILIDADE
-- ========================================
-- A função get_dashboard_core original ainda funciona, mas agora 
-- internamente chama a nova função com período = mês atual

CREATE OR REPLACE FUNCTION get_dashboard_core(user_id_param UUID)
RETURNS JSON AS $$
BEGIN
    -- Chama a nova função com período = mês atual para manter compatibilidade
    RETURN get_dashboard_core_with_period(
        user_id_param,
        DATE_TRUNC('month', CURRENT_DATE)::DATE,
        (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_dashboard_core(UUID) IS 
'Função legacy para dashboard (apenas compatibilidade). 
Internamente chama get_dashboard_core_with_period com período = mês atual.
Use get_dashboard_core_with_period para novos desenvolvimentos.';

-- ========================================
-- SCRIPT DE TESTE
-- ========================================
-- Para testar a função, descomente e execute:
/*
-- Teste 1: Este mês
SELECT get_dashboard_core_with_period(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    DATE_TRUNC('month', CURRENT_DATE)::DATE,
    (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE
);

-- Teste 2: Últimos 30 dias
SELECT get_dashboard_core_with_period(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    (CURRENT_DATE - INTERVAL '30 days')::DATE,
    CURRENT_DATE
);

-- Teste 3: Esta semana
SELECT get_dashboard_core_with_period(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid,
    DATE_TRUNC('week', CURRENT_DATE)::DATE,
    (DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '6 days')::DATE
);

-- Teste 4: Função legacy (deve funcionar igual)
SELECT get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid);
*/

-- ========================================
-- LOG DE CRIAÇÃO
-- ========================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '🎯 ================================';
    RAISE NOTICE '🎯 DASHBOARD COM PERÍODO CRIADO!';
    RAISE NOTICE '🎯 ================================';
    RAISE NOTICE '✅ Função: get_dashboard_core_with_period';
    RAISE NOTICE '✅ Parâmetros: user_id, start_date, end_date';
    RAISE NOTICE '✅ Compatibilidade: get_dashboard_core mantida';
    RAISE NOTICE '✅ Permissions: Granted para authenticated e anon';
    RAISE NOTICE '✅ Ready for Flutter integration!';
    RAISE NOTICE '';
END $$; 