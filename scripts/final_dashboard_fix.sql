-- ==========================================
-- CORREÇÃO DASHBOARD FITNESS - APLICAR NO SUPABASE SQL EDITOR
-- ==========================================

-- Problema: A função estava usando "últimos 7 dias" em vez de "semana atual"
-- Correção: Usar DATE_TRUNC('week', CURRENT_DATE) para semana segunda-domingo

DROP FUNCTION IF EXISTS get_dashboard_fitness(UUID, INT, INT);

CREATE OR REPLACE FUNCTION get_dashboard_fitness(
    user_id_param UUID,
    month_param INT,
    year_param INT
) RETURNS JSONB AS $$
DECLARE
    month_start DATE;
    month_end DATE;
    week_start DATE;
    result JSONB;
BEGIN
    -- Definir intervalo do mês
    month_start := DATE(year_param || '-' || month_param || '-01');
    month_end := (month_start + INTERVAL '1 month - 1 day')::DATE;
    
    -- 🔧 CORREÇÃO: Usar semana atual (segunda-feira a domingo) em vez de últimos 7 dias
    week_start := DATE_TRUNC('week', CURRENT_DATE)::DATE;
    
    -- CALENDÁRIO: Dados detalhados por dia do mês
    WITH daily_workouts AS (
        SELECT 
            DATE(wr.date) as workout_date,
            COUNT(*) as workout_count,
            SUM(wr.duration_minutes) as total_minutes,
            ARRAY_AGG(DISTINCT wr.workout_type) as workout_types,
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
            ) as workouts
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        AND DATE(wr.date) >= month_start
        AND DATE(wr.date) <= month_end
        GROUP BY DATE(wr.date)
    ),
    
    -- 🔧 CORREÇÃO: Dados da semana atual (segunda-feira a domingo)
    week_stats AS (
        SELECT 
            COUNT(*) as workouts_this_week,
            SUM(wr.duration_minutes) as minutes_this_week,
            COUNT(DISTINCT wr.workout_type) as types_this_week,
            COUNT(DISTINCT DATE(wr.date)) as days_this_week
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        AND DATE(wr.date) >= week_start
        AND DATE(wr.date) <= CURRENT_DATE
    ),
    
    -- ESTATÍSTICAS: Dados do mês atual
    month_stats AS (
        SELECT 
            workouts_this_month,
            minutes_this_month,
            days_this_month,
            COALESCE(workout_types_distribution, '{}'::jsonb) as workout_types_distribution
        FROM (
            SELECT 
                COUNT(*) as workouts_this_month,
                SUM(wr.duration_minutes) as minutes_this_month,
                COUNT(DISTINCT DATE(wr.date)) as days_this_month
            FROM workout_records wr
            WHERE wr.user_id = user_id_param
            AND DATE(wr.date) >= month_start
            AND DATE(wr.date) <= month_end
        ) main_stats
        CROSS JOIN (
            SELECT 
                COALESCE(
                    jsonb_object_agg(workout_type, type_count),
                    '{}'::jsonb
                ) as workout_types_distribution
            FROM (
                SELECT 
                    wr.workout_type,
                    COUNT(*) as type_count
                FROM workout_records wr
                WHERE wr.user_id = user_id_param
                AND DATE(wr.date) >= month_start
                AND DATE(wr.date) <= month_end
                GROUP BY wr.workout_type
            ) type_counts
        ) type_stats
    ),
    
    -- DADOS AGREGADOS: Da tabela user_progress
    user_progress_data AS (
        SELECT 
            COALESCE(up.workouts, 0) as total_workouts,
            COALESCE(up.points, 0) as total_points,
            COALESCE(up.current_streak, 0) as current_streak,
            COALESCE(up.longest_streak, 0) as longest_streak,
            COALESCE(up.total_duration, 0) as total_duration,
            COALESCE(up.days_trained_this_month, 0) as days_trained_this_month,
            COALESCE(up.workout_types, '{}'::jsonb) as workout_types,
            COALESCE(up.achievements, '[]'::jsonb) as achievements,
            COALESCE(up.workouts_completed, 0) as workouts_completed,
            COALESCE(up.challenges_completed, 0) as challenges_completed,
            COALESCE(up.level, 1) as level,
            up.last_updated
        FROM user_progress up
        WHERE up.user_id = user_id_param
    ),
    
    -- CALENDÁRIO: Gerar todos os dias do mês
    calendar_days AS (
        SELECT 
            generate_series(
                month_start,
                month_end,
                INTERVAL '1 day'
            )::DATE as day_date
    )
    
    -- RESULTADO FINAL
    SELECT jsonb_build_object(
        'calendar', jsonb_build_object(
            'month', month_param,
            'year', year_param,
            'days', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'day', EXTRACT(DAY FROM cd.day_date),
                        'date', cd.day_date,
                        'workouts', COALESCE(dw.workouts, '[]'::jsonb),
                        'workout_count', COALESCE(dw.workout_count, 0),
                        'total_minutes', COALESCE(dw.total_minutes, 0),
                        'workout_types', COALESCE(array_to_json(dw.workout_types), '[]'::json),
                        'rings', jsonb_build_object(
                            'move', LEAST(100, (COALESCE(dw.total_minutes, 0) * 3.33)::INTEGER),
                            'exercise', CASE 
                                WHEN COALESCE(dw.workout_count, 0) > 0 THEN 100 
                                ELSE 0 
                            END,
                            'stand', CASE 
                                WHEN COALESCE(dw.workout_count, 0) > 0 THEN 100 
                                ELSE 0 
                            END
                        )
                    )
                    ORDER BY cd.day_date
                )
                FROM calendar_days cd
                LEFT JOIN daily_workouts dw ON cd.day_date = dw.workout_date
            )
        ),
        'progress', jsonb_build_object(
            'week', jsonb_build_object(
                'workouts', COALESCE(ws.workouts_this_week, 0),
                'minutes', COALESCE(ws.minutes_this_week, 0),
                'types', COALESCE(ws.types_this_week, 0),
                'days', COALESCE(ws.days_this_week, 0)
            ),
            'month', jsonb_build_object(
                'workouts', COALESCE(ms.workouts_this_month, 0),
                'minutes', COALESCE(ms.minutes_this_month, 0),
                'days', COALESCE(ms.days_this_month, 0),
                'types_distribution', COALESCE(ms.workout_types_distribution, '{}')
            ),
            'total', jsonb_build_object(
                'workouts', COALESCE(upd.total_workouts, 0),
                'workouts_completed', COALESCE(upd.workouts_completed, 0),
                'points', COALESCE(upd.total_points, 0),
                'duration', COALESCE(upd.total_duration, 0),
                'days_trained_this_month', COALESCE(upd.days_trained_this_month, 0),
                'level', COALESCE(upd.level, 1),
                'challenges_completed', COALESCE(upd.challenges_completed, 0)
            ),
            'streak', jsonb_build_object(
                'current', COALESCE(upd.current_streak, 0),
                'longest', COALESCE(upd.longest_streak, 0)
            )
        ),
        'awards', jsonb_build_object(
            'total_points', COALESCE(upd.total_points, 0),
            'achievements', COALESCE(upd.achievements, '[]'::jsonb),
            'badges', '[]'::jsonb,
            'level', COALESCE(upd.level, 1)
        ),
        'last_updated', COALESCE(upd.last_updated, NOW())
    ) INTO result
    FROM week_stats ws, month_stats ms, user_progress_data upd;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ==========================================
-- TESTE DA FUNÇÃO CORRIGIDA
-- ==========================================

-- Testar com julho 2025 (onde estão os treinos)
SELECT get_dashboard_fitness(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
    7,  -- Julho
    2025  -- 2025
);

-- Confirmação
SELECT 'Função get_dashboard_fitness corrigida com sucesso! 🎉' as status; 