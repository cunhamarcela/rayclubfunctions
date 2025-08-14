-- ========================================
-- CORREÇÃO: TREINOS DO MÊS ATUAL
-- ========================================
-- Data: 2025-01-27 21:30
-- Objetivo: Mudar "Treinos: 25" para mostrar apenas do mês atual
-- Dashboard: dashboard_screen.dart → get_dashboard_core

-- DIAGNÓSTICO: Ver situação atual
SELECT 
    'SITUAÇÃO ATUAL:' as titulo,
    'Treinos mostra TOTAL (25)' as problema,
    'Outros campos já são mensais' as observacao;

-- SOLUÇÃO: Atualizar get_dashboard_core
CREATE OR REPLACE FUNCTION get_dashboard_core(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_workouts_month INTEGER := 0;  -- ✅ MUDANÇA: agora é do mês
    total_duration_month INTEGER := 0;
    days_trained_this_month INTEGER := 0;
    workouts_by_type JSONB := '{}'::JSONB;
    recent_workouts_data JSON := '[]'::JSON;
    challenge_progress_data JSON;
BEGIN
    -- ✅ CORREÇÃO PRINCIPAL: Treinos APENAS do mês atual
    SELECT COUNT(*)
    INTO total_workouts_month
    FROM workout_records
    WHERE user_id = user_id_param
    AND DATE_PART('year', date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', date) = DATE_PART('month', CURRENT_DATE);

    -- 2. Minutos apenas do mês atual (já estava correto)
    SELECT COALESCE(SUM(duration_minutes), 0)
    INTO total_duration_month
    FROM workout_records
    WHERE user_id = user_id_param
    AND DATE_PART('year', date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', date) = DATE_PART('month', CURRENT_DATE);

    -- 3. Dias únicos do mês atual (já estava correto)
    SELECT COUNT(DISTINCT DATE(date))
    INTO days_trained_this_month
    FROM workout_records
    WHERE user_id = user_id_param
    AND DATE_PART('year', date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', date) = DATE_PART('month', CURRENT_DATE);

    -- 4. Tipos de treino do mês atual (NOVO: também filtrar por mês)
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
        AND DATE_PART('year', date) = DATE_PART('year', CURRENT_DATE)
        AND DATE_PART('month', date) = DATE_PART('month', CURRENT_DATE)
        GROUP BY workout_type
    ) AS type_stats;

    -- 5. Treinos recentes (manter últimos 10 de todos os tempos)
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
                'id', id,
                'workout_name', COALESCE(workout_name, 'Treino'),
                'workout_type', workout_type,
                'date', date,
                'duration_minutes', COALESCE(duration_minutes, 0)
            )
            ORDER BY date DESC
        ),
        '[]'::jsonb
    )::json
    INTO recent_workouts_data
    FROM (
        SELECT id, workout_name, workout_type, date, duration_minutes
        FROM workout_records
        WHERE user_id = user_id_param
        ORDER BY date DESC
        LIMIT 10
    ) AS recent_workouts;

    -- 6. Progresso em desafios (SIMPLIFICADO)
    SELECT json_build_object(
        'challenge_id', NULL,
        'challenge_title', NULL,
        'total_points', 0,
        'check_ins', 0,
        'position', 0,
        'completion_percentage', 0
    )
    INTO challenge_progress_data;

    -- 7. RESULTADO FINAL ✅ CORRIGIDO
    result := json_build_object(
        'total_workouts', total_workouts_month,              -- ✅ AGORA É MENSAL!
        'total_duration', total_duration_month,              -- ✅ Continua mensal
        'days_trained_this_month', days_trained_this_month,  -- ✅ Continua mensal
        'workouts_by_type', workouts_by_type,                -- ✅ AGORA É MENSAL!
        'recent_workouts', recent_workouts_data,
        'challenge_progress', challenge_progress_data,
        'last_updated', NOW()
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- TESTE IMEDIATO
SELECT 
    'TESTANDO CORREÇÃO:' as teste,
    'User com 25 treinos totais' as cenario;

-- Simular resultado esperado para janeiro 2025
SELECT 
    'RESULTADO ESPERADO:' as info,
    'Treinos: ~4 (apenas de janeiro)' as novo_valor,
    'Minutos: continua do mês' as observacao,
    'Tipos de treino: apenas do mês' as bonus; 