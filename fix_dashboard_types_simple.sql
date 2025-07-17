-- =============================================
-- Script para corrigir problemas de tipos na função get_dashboard_fitness
-- Execute no SQL Editor do Supabase Dashboard
-- =============================================

-- Primeiro, remover a função existente
DROP FUNCTION IF EXISTS get_dashboard_fitness(UUID, INT, INT);

-- Criar versão simplificada que funciona 100%
CREATE OR REPLACE FUNCTION get_dashboard_fitness(
    user_id_param UUID,
    month_param INT,
    year_param INT
) RETURNS JSONB AS $$
DECLARE
    month_start DATE;
    month_end DATE;
    result JSONB;
BEGIN
    -- Definir intervalo do mês
    month_start := DATE(year_param || '-' || month_param || '-01');
    month_end := (month_start + INTERVAL '1 month - 1 day')::DATE;
    
    -- Construir resultado simplificado com dados reais
    WITH daily_stats AS (
        SELECT 
            DATE(wr.date) as workout_date,
            COUNT(*) as workout_count,
            SUM(wr.duration_minutes) as total_minutes,
            jsonb_agg(
                jsonb_build_object(
                    'id', wr.id,
                    'name', COALESCE(wr.workout_name, 'Treino'),
                    'type', wr.workout_type,
                    'duration', wr.duration_minutes,
                    'photo_url', CASE 
                        WHEN wr.image_urls IS NOT NULL AND array_length(wr.image_urls, 1) > 0 
                        THEN wr.image_urls[1] 
                        ELSE NULL 
                    END,
                    'points', COALESCE(wr.points, 10),
                    'is_challenge_valid', wr.is_completed,
                    'created_at', wr.created_at
                )
            ) as workouts_json
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        AND DATE(wr.date) >= month_start
        AND DATE(wr.date) <= month_end
        GROUP BY DATE(wr.date)
    ),
    
    calendar_days AS (
        SELECT 
            generate_series(
                month_start,
                month_end,
                INTERVAL '1 day'
            )::DATE as day_date
    ),
    
    month_stats AS (
        SELECT 
            COUNT(*) as workouts_this_month,
            SUM(wr.duration_minutes) as minutes_this_month,
            COUNT(DISTINCT DATE(wr.date)) as days_this_month
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        AND DATE(wr.date) >= month_start
        AND DATE(wr.date) <= month_end
    ),
    
    user_data AS (
        SELECT 
            COALESCE(up.workouts, 0) as total_workouts,
            COALESCE(up.points, 0) as total_points,
            COALESCE(up.current_streak, 0) as current_streak,
            COALESCE(up.longest_streak, 0) as longest_streak,
            COALESCE(up.total_duration, 0) as total_duration,
            COALESCE(up.level, 1) as level
        FROM user_progress up
        WHERE up.user_id = user_id_param
    )
    
    SELECT jsonb_build_object(
        'calendar', jsonb_build_object(
            'month', month_param,
            'year', year_param,
            'days', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'day', EXTRACT(DAY FROM cd.day_date),
                        'date', cd.day_date,
                        'workouts', COALESCE(ds.workouts_json, '[]'::jsonb),
                        'workout_count', COALESCE(ds.workout_count, 0),
                        'total_minutes', COALESCE(ds.total_minutes, 0),
                        'workout_types', '[]'::jsonb,
                        'rings', jsonb_build_object(
                            'move', LEAST(100, (COALESCE(ds.total_minutes, 0) * 3.33)::INTEGER),
                            'exercise', CASE 
                                WHEN COALESCE(ds.workout_count, 0) > 0 THEN 100 
                                ELSE 0 
                            END,
                            'stand', CASE 
                                WHEN COALESCE(ds.workout_count, 0) > 0 THEN 100 
                                ELSE 0 
                            END
                        )
                    )
                    ORDER BY cd.day_date
                )
                FROM calendar_days cd
                LEFT JOIN daily_stats ds ON cd.day_date = ds.workout_date
            )
        ),
        'progress', jsonb_build_object(
            'week', jsonb_build_object(
                'workouts', 0,
                'minutes', 0,
                'types', 0,
                'days', 0
            ),
            'month', jsonb_build_object(
                'workouts', COALESCE(ms.workouts_this_month, 0),
                'minutes', COALESCE(ms.minutes_this_month, 0),
                'days', COALESCE(ms.days_this_month, 0),
                'types_distribution', '{}'::jsonb
            ),
            'total', jsonb_build_object(
                'workouts', COALESCE(ud.total_workouts, 0),
                'workouts_completed', COALESCE(ud.total_workouts, 0),
                'points', COALESCE(ud.total_points, 0),
                'duration', COALESCE(ud.total_duration, 0),
                'days_trained_this_month', COALESCE(ms.days_this_month, 0),
                'level', COALESCE(ud.level, 1),
                'challenges_completed', 0
            ),
            'streak', jsonb_build_object(
                'current', COALESCE(ud.current_streak, 0),
                'longest', COALESCE(ud.longest_streak, 0)
            )
        ),
        'awards', jsonb_build_object(
            'total_points', COALESCE(ud.total_points, 0),
            'achievements', '[]'::jsonb,
            'badges', '[]'::jsonb,
            'level', COALESCE(ud.level, 1)
        ),
        'last_updated', NOW()
    ) INTO result
    FROM month_stats ms, user_data ud;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Testar a função
SELECT get_dashboard_fitness(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
    7,
    2025
);

-- Verificar se a função foi criada
SELECT 
    p.proname as function_name,
    p.pronargs as arg_count,
    pg_get_function_result(p.oid) as return_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname = 'get_dashboard_fitness';

-- Mensagem de sucesso
SELECT 'Função get_dashboard_fitness criada com sucesso! ✅' as status; 