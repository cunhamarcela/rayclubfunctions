-- ========================================
-- FUNÇÃO GET_DASHBOARD_CORE
-- ========================================
-- Data: 2025-01-22
-- Objetivo: Criar função simplificada para dashboard básico
-- Mudança principal: totalDuration mostra apenas minutos do mês atual

CREATE OR REPLACE FUNCTION get_dashboard_core(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_workouts INTEGER := 0;
    total_duration_month INTEGER := 0;  -- APENAS do mês atual
    total_duration_all_time INTEGER := 0;  -- Total de todos os tempos
    days_trained_this_month INTEGER := 0;
    workouts_by_type JSONB := '{}'::JSONB;
    challenge_progress_data JSON;
    recent_workouts_data JSON;
    last_updated TIMESTAMP;
BEGIN
    -- 1. CALCULAR ESTATÍSTICAS BÁSICAS DO USUÁRIO
    -- Total de treinos de TODOS os tempos (mantém o valor atual de 24)
    SELECT COUNT(*)
    INTO total_workouts
    FROM workout_records wr
    WHERE wr.user_id = user_id_param;

    -- Minutos APENAS do mês atual (esta é a mudança principal)
    SELECT COALESCE(SUM(duration_minutes), 0)
    INTO total_duration_month
    FROM workout_records wr
    WHERE wr.user_id = user_id_param
    AND DATE_PART('year', wr.date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', wr.date) = DATE_PART('month', CURRENT_DATE);

    -- Calcular dias únicos treinados no mês atual
    SELECT COUNT(DISTINCT DATE(wr.date))
    INTO days_trained_this_month
    FROM workout_records wr
    WHERE wr.user_id = user_id_param
    AND DATE_PART('year', wr.date) = DATE_PART('year', CURRENT_DATE)
    AND DATE_PART('month', wr.date) = DATE_PART('month', CURRENT_DATE);

    -- Tipos de treino (baseado em todos os treinos)
    SELECT COALESCE(
        jsonb_object_agg(
            wr.workout_type, 
            type_count
        ), 
        '{}'::jsonb
    )
    INTO workouts_by_type
    FROM (
        SELECT 
            wr.workout_type,
            COUNT(*) as type_count
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        GROUP BY wr.workout_type
    ) type_stats;

    -- 2. BUSCAR PROGRESSO EM DESAFIOS
    -- Buscar o desafio ativo do usuário
    WITH active_challenge AS (
        SELECT 
            c.id as challenge_id,
            c.title,
            c.points as challenge_points
        FROM challenges c
        JOIN challenge_participants cp ON c.id = cp.challenge_id
        WHERE 
            cp.user_id = user_id_param
            AND c.end_date >= CURRENT_DATE
            AND c.active = true
        ORDER BY c.is_official DESC, c.end_date ASC
        LIMIT 1
    )
    SELECT 
        CASE WHEN COUNT(*) > 0 THEN
            json_build_object(
                'challenge_id', ac.challenge_id,
                'challenge_title', ac.title,
                'total_points', COALESCE(cp.points, 0),
                'check_ins', COALESCE(
                    CASE 
                        WHEN cp.check_ins_count IS NOT NULL THEN cp.check_ins_count
                        WHEN cp.total_check_ins IS NOT NULL THEN cp.total_check_ins
                        ELSE 0
                    END, 0
                ),
                'position', COALESCE(cp.position, 0),
                'completion_percentage', COALESCE(cp.completion_percentage, 0)
            )
        ELSE 
            json_build_object(
                'challenge_id', NULL,
                'challenge_title', NULL,
                'total_points', 0,
                'check_ins', 0,
                'position', 0,
                'completion_percentage', 0
            )
        END
    INTO challenge_progress_data
    FROM active_challenge ac
    LEFT JOIN challenge_progress cp ON cp.challenge_id = ac.challenge_id AND cp.user_id = user_id_param;

    -- 3. BUSCAR TREINOS RECENTES
    SELECT COALESCE(
        json_agg(
            json_build_object(
                'id', wr.id,
                'workout_name', COALESCE(wr.workout_name, 'Treino'),
                'workout_type', wr.workout_type,
                'date', wr.date,
                'duration_minutes', COALESCE(wr.duration_minutes, 0)
            )
            ORDER BY wr.date DESC
        ),
        '[]'::json
    )
    INTO recent_workouts_data
    FROM (
        SELECT * FROM workout_records wr
        WHERE wr.user_id = user_id_param
        ORDER BY wr.date DESC
        LIMIT 10
    ) wr;

    -- 4. CONSTRUIR RESULTADO FINAL
    -- IMPORTANTE: total_duration agora é só do mês atual!
    result := json_build_object(
        'total_workouts', total_workouts,
        'total_duration', total_duration_month,  -- MUDANÇA: apenas do mês atual
        'days_trained_this_month', days_trained_this_month,
        'workouts_by_type', workouts_by_type,
        'recent_workouts', recent_workouts_data,
        'challenge_progress', challenge_progress_data,
        'last_updated', NOW()
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================
-- COMENTÁRIOS IMPORTANTES
-- ========================================
/*
✅ MUDANÇA PRINCIPAL:
- total_duration agora calcula APENAS os minutos dos treinos do mês atual
- Antes: todos os treinos de todos os tempos
- Agora: apenas treinos do mês/ano atual

✅ COMPATIBILIDADE:
- Mantém a mesma estrutura JSON esperada pelo DashboardData.fromJson()
- Funciona com o DashboardRepository existente

✅ PERFORMANCE:
- Consultas otimizadas com filtros por data
- Função única sem múltiplas chamadas

✅ APLICAÇÃO:
Execute no SQL Editor do Supabase Dashboard
*/ 