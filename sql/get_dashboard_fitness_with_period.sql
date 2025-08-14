-- ========================================
-- FUNÇÃO: get_dashboard_fitness_with_period
-- ========================================
-- Data: 2025-01-28 (Corrigido)
-- Objetivo: Criar função para dashboard fitness com suporte a filtros de período
-- Autor: IA + Marcela
-- Funcionalidade: Dashboard fitness com calendário e estatísticas filtradas por período
-- CORREÇÃO: Buscar pontos reais das tabelas de desafios, não calcular fictícios

-- ========================================
-- REMOVER FUNÇÃO ANTERIOR SE EXISTIR
-- ========================================
DROP FUNCTION IF EXISTS get_dashboard_fitness_with_period(UUID, DATE, DATE);

-- ========================================
-- CRIAR NOVA FUNÇÃO COM SUPORTE A FILTROS DE PERÍODO
-- ========================================
CREATE OR REPLACE FUNCTION get_dashboard_fitness_with_period(
    user_id_param UUID,
    start_date_param DATE,
    end_date_param DATE
)
RETURNS JSON AS $$
DECLARE
    result JSON;
    calendar_data JSON;
    progress_data JSON;
    awards_data JSON;
    period_start DATE := start_date_param;
    period_end DATE := end_date_param;
    
    -- Estatísticas do período
    total_workouts INTEGER := 0;
    total_minutes INTEGER := 0;
    total_points INTEGER := 0;
    days_trained INTEGER := 0;

BEGIN
    -- Log dos parâmetros recebidos
    RAISE NOTICE '🏃‍♂️ Dashboard Fitness com período: usuário=%, início=%, fim=%', 
        user_id_param, start_date_param, end_date_param;
    
    -- ========================================
    -- 1. CALCULAR ESTATÍSTICAS DO PERÍODO
    -- ========================================
    
    -- Total de treinos no período
    SELECT COUNT(*)
    INTO total_workouts
    FROM workout_records
    WHERE user_id = user_id_param
    AND is_completed = TRUE
    AND date >= period_start
    AND date <= period_end;
    
    -- Total de minutos no período
    SELECT COALESCE(SUM(duration_minutes), 0)
    INTO total_minutes
    FROM workout_records
    WHERE user_id = user_id_param
    AND is_completed = TRUE
    AND date >= period_start
    AND date <= period_end;
    
    -- 🔧 PONTOS REAIS: Buscar pontos de check-ins e bônus de desafios no período
    SELECT COALESCE(SUM(points_total), 0)
    INTO total_points
    FROM (
        -- Pontos de check-ins no período
        SELECT COALESCE(SUM(points), 0) as points_total
        FROM challenge_check_ins
        WHERE user_id = user_id_param
        AND check_in_date >= period_start
        AND check_in_date <= period_end
        
        UNION ALL
        
        -- Pontos de bônus no período
        SELECT COALESCE(SUM(bonus_points), 0) as points_total
        FROM challenge_bonuses
        WHERE user_id = user_id_param
        AND awarded_at >= period_start
        AND awarded_at <= period_end
    ) as all_points;
    
    -- Dias únicos treinados no período
    SELECT COUNT(DISTINCT DATE(date))
    INTO days_trained
    FROM workout_records
    WHERE user_id = user_id_param
    AND is_completed = TRUE
    AND date >= period_start
    AND date <= period_end;
    
    -- ========================================
    -- 2. DADOS DO CALENDÁRIO (PERÍODO)
    -- ========================================
    
    -- Gerar dados do calendário para o período especificado
    WITH calendar_days AS (
        SELECT 
            generate_series(
                period_start::date,
                period_end::date,
                '1 day'::interval
            )::date AS day_date
    ),
    daily_stats AS (
        SELECT 
            cd.day_date,
            EXTRACT(DAY FROM cd.day_date)::int as day_number,
            COALESCE(COUNT(wr.id), 0)::int as workout_count,
            COALESCE(SUM(wr.duration_minutes), 0)::int as total_minutes,
            COALESCE(ARRAY_AGG(DISTINCT wr.workout_type) FILTER (WHERE wr.workout_type IS NOT NULL), ARRAY[]::text[]) as workout_types,
            COALESCE(
                JSON_AGG(
                    JSON_BUILD_OBJECT(
                        'id', wr.id::text,
                        'name', wr.workout_name,
                        'type', wr.workout_type,
                        'duration', wr.duration_minutes,
                        'photo_url', CASE WHEN array_length(wr.image_urls, 1) > 0 THEN wr.image_urls[1] ELSE null END,
                        'points', COALESCE(checkin_points.daily_points, 0), -- Pontos reais do dia
                        'is_challenge_valid', wr.is_completed,
                        'created_at', wr.created_at
                    )
                ) FILTER (WHERE wr.id IS NOT NULL),
                '[]'::json
            ) as workouts,
            -- Pontos reais do dia (check-ins + bônus)
            COALESCE(checkin_points.daily_points, 0) as day_points,
            -- Cálculo dos anéis de progresso
            CASE 
                WHEN COUNT(wr.id) > 0 THEN 100.0 
                ELSE 0.0 
            END as move_ring,
            CASE 
                WHEN SUM(wr.duration_minutes) >= 30 THEN 100.0
                WHEN SUM(wr.duration_minutes) > 0 THEN (SUM(wr.duration_minutes) * 100.0 / 30.0)
                ELSE 0.0 
            END as exercise_ring,
            CASE 
                WHEN COUNT(wr.id) FILTER (WHERE wr.is_completed = TRUE) > 0 THEN 100.0 
                ELSE 0.0 
            END as stand_ring
        FROM calendar_days cd
        LEFT JOIN workout_records wr ON DATE(wr.date) = cd.day_date 
            AND wr.user_id = user_id_param 
            AND wr.is_completed = TRUE
        -- Juntar pontos reais do dia (check-ins + bônus)
        LEFT JOIN (
            SELECT 
                DATE(check_in_date) as day_date,
                COALESCE(SUM(points), 0) + COALESCE(SUM(bonus_points), 0) as daily_points
            FROM (
                SELECT DATE(check_in_date) as check_in_date, points, 0 as bonus_points
                FROM challenge_check_ins
                WHERE user_id = user_id_param
                
                UNION ALL
                
                SELECT DATE(awarded_at) as check_in_date, 0 as points, bonus_points
                FROM challenge_bonuses
                WHERE user_id = user_id_param
            ) daily_points_union
            GROUP BY DATE(check_in_date)
        ) checkin_points ON checkin_points.day_date = cd.day_date
        GROUP BY cd.day_date, checkin_points.daily_points
        ORDER BY cd.day_date
    )
    SELECT JSON_BUILD_OBJECT(
        'month', EXTRACT(MONTH FROM period_start)::int,
        'year', EXTRACT(YEAR FROM period_start)::int,
        'days', JSON_AGG(
            JSON_BUILD_OBJECT(
                'day', ds.day_number,
                'date', ds.day_date,
                'workout_count', ds.workout_count,
                'total_minutes', ds.total_minutes,
                'workout_types', ds.workout_types,
                'workouts', ds.workouts,
                'rings', JSON_BUILD_OBJECT(
                    'move', ds.move_ring,
                    'exercise', ds.exercise_ring,
                    'stand', ds.stand_ring
                )
            ) ORDER BY ds.day_date
        )
    ) INTO calendar_data
    FROM daily_stats ds;
    
    -- ========================================
    -- 3. DADOS DE PROGRESSO
    -- ========================================
    
    -- Calcular progresso da semana, mês e totais
    WITH week_stats AS (
        SELECT 
            COALESCE(COUNT(*), 0)::int as workouts,
            COALESCE(SUM(duration_minutes), 0)::int as minutes,
            COALESCE(COUNT(DISTINCT workout_type), 0)::int as types,
            COALESCE(COUNT(DISTINCT DATE(date)), 0)::int as days
        FROM workout_records
        WHERE user_id = user_id_param
        AND is_completed = TRUE
        AND date >= DATE_TRUNC('week', CURRENT_DATE)
        AND date < DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '1 week'
    ),
    month_stats AS (
        SELECT 
            total_workouts as workouts,
            total_minutes as minutes,
            days_trained as days,
            COALESCE(
                jsonb_object_agg(workout_type, type_count),
                '{}'::jsonb
            ) as types_distribution
        FROM (
            SELECT 
                workout_type,
                COUNT(*) as type_count
            FROM workout_records
            WHERE user_id = user_id_param
            AND is_completed = TRUE
            AND date >= period_start
            AND date <= period_end
            GROUP BY workout_type
        ) type_counts
    ),
    total_stats AS (
        SELECT 
            COALESCE(COUNT(*), 0)::int as total_workouts,
            COALESCE(COUNT(*) FILTER (WHERE is_completed = TRUE), 0)::int as workouts_completed,
            total_points as total_points, -- Pontos reais já calculados
            COALESCE(SUM(duration_minutes), 0)::int as total_duration,
            days_trained as days_trained_this_month,
            1 as level, -- Placeholder
            0 as challenges_completed -- Placeholder
        FROM workout_records
        WHERE user_id = user_id_param
        AND date >= period_start
        AND date <= period_end
    ),
    streak_stats AS (
        -- Calcular streak simples baseado nos últimos dias
        SELECT 
            COALESCE(
                (SELECT COUNT(DISTINCT DATE(date))
                 FROM workout_records 
                 WHERE user_id = user_id_param 
                 AND is_completed = TRUE
                 AND date >= CURRENT_DATE - INTERVAL '7 days'), 
                0
            )::int as current_streak,
            COALESCE(
                (SELECT MAX(daily_count)
                 FROM (
                     SELECT COUNT(DISTINCT DATE(date)) as daily_count
                     FROM workout_records 
                     WHERE user_id = user_id_param 
                     AND is_completed = TRUE
                     GROUP BY DATE_TRUNC('week', date)
                 ) weekly_counts), 
                0
            )::int as longest_streak
    )
    SELECT JSON_BUILD_OBJECT(
        'week', JSON_BUILD_OBJECT(
            'workouts', ws.workouts,
            'minutes', ws.minutes,
            'types', ws.types,
            'days', ws.days
        ),
        'month', JSON_BUILD_OBJECT(
            'workouts', ms.workouts,
            'minutes', ms.minutes,
            'days', ms.days,
            'types_distribution', ms.types_distribution
        ),
        'total', JSON_BUILD_OBJECT(
            'workouts', ts.total_workouts,
            'workouts_completed', ts.workouts_completed,
            'points', ts.total_points,
            'duration', ts.total_duration,
            'days_trained_this_month', ts.days_trained_this_month,
            'level', ts.level,
            'challenges_completed', ts.challenges_completed
        ),
        'streak', JSON_BUILD_OBJECT(
            'current', ss.current_streak,
            'longest', ss.longest_streak
        )
    ) INTO progress_data
    FROM week_stats ws, month_stats ms, total_stats ts, streak_stats ss;
    
    -- ========================================
    -- 4. DADOS DE PREMIAÇÃO
    -- ========================================
    
    -- Buscar pontos totais do usuário (se disponível na tabela profiles)
    WITH user_points AS (
        SELECT COALESCE(
            CASE 
                WHEN stats IS NOT NULL AND stats ? 'points_earned' 
                THEN (stats->>'points_earned')::int
                ELSE total_points
            END, 
            total_points
        ) as user_total_points
        FROM profiles 
        WHERE id = user_id_param
    )
    SELECT JSON_BUILD_OBJECT(
        'total_points', COALESCE(up.user_total_points, total_points),
        'achievements', '[]'::json,
        'badges', '[]'::json,
        'level', 1
    ) INTO awards_data
    FROM user_points up;
    
    -- ========================================
    -- 5. RESULTADO FINAL
    -- ========================================
    
    SELECT JSON_BUILD_OBJECT(
        'calendar', calendar_data,
        'progress', progress_data,
        'awards', awards_data,
        'last_updated', NOW()
    ) INTO result;
    
    RAISE NOTICE '✅ Dashboard fitness com período gerado com sucesso';
    RAISE NOTICE '📊 - Total de treinos: %', total_workouts;
    RAISE NOTICE '⏱️ - Total de minutos: %', total_minutes;
    RAISE NOTICE '💰 - Total de pontos (reais): %', total_points;
    RAISE NOTICE '📅 - Dias treinados: %', days_trained;
    
    RETURN result;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '❌ Erro na função get_dashboard_fitness_with_period: %', SQLERRM;
        RAISE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER; 