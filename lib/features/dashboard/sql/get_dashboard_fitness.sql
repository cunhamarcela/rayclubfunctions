-- ========================================
-- LIMPEZA COMPLETA DAS FUNÇÕES ANTIGAS
-- ========================================

-- Remover todas as versões possíveis da função get_dashboard_fitness
DROP FUNCTION IF EXISTS get_dashboard_fitness(UUID);
DROP FUNCTION IF EXISTS get_dashboard_fitness(UUID, DATE);
DROP FUNCTION IF EXISTS get_dashboard_fitness(UUID, INT);
DROP FUNCTION IF EXISTS get_dashboard_fitness(UUID, INT, INT);
DROP FUNCTION IF EXISTS get_dashboard_fitness(UUID, DATE, DATE);

-- Remover todas as versões possíveis da função get_day_details
DROP FUNCTION IF EXISTS get_day_details(UUID, DATE);
DROP FUNCTION IF EXISTS get_day_details(UUID, TIMESTAMP);

-- Garantir que não há nenhuma função com nome similar
DROP FUNCTION IF EXISTS get_fitness_dashboard(UUID, INT, INT);
DROP FUNCTION IF EXISTS dashboard_fitness(UUID, INT, INT);

-- ========================================
-- CRIAÇÃO DAS NOVAS FUNÇÕES
-- ========================================

-- Função otimizada para dashboard fitness com calendário e estatísticas
-- Utiliza user_progress para dados agregados e workout_records para detalhes do calendário
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
    
    -- CALENDÁRIO: Dados detalhados por dia do mês
    WITH daily_workouts AS (
        SELECT 
            DATE(wr.date) as workout_date,
            COUNT(*) as workout_count,
            SUM(wr.duration_minutes) as total_minutes,
            ARRAY_AGG(DISTINCT wr.workout_type) as workout_types,
            json_agg(
                json_build_object(
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
    
    -- ESTATÍSTICAS: Dados da semana atual
    week_stats AS (
        SELECT 
            COUNT(*) as workouts_this_week,
            SUM(wr.duration_minutes) as minutes_this_week,
            COUNT(DISTINCT wr.workout_type) as types_this_week,
            COUNT(DISTINCT DATE(wr.date)) as days_this_week
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        AND DATE(wr.date) >= CURRENT_DATE - INTERVAL '6 days'
        AND DATE(wr.date) <= CURRENT_DATE
    ),
    
    -- ESTATÍSTICAS: Dados do mês atual (corrigido)
    month_stats AS (
        SELECT 
            workouts_this_month,
            minutes_this_month,
            days_this_month,
            COALESCE(workout_types_distribution, '{}'::json) as workout_types_distribution
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
                    json_object_agg(workout_type, type_minutes),
                    '{}'::json
                ) as workout_types_distribution
            FROM (
                SELECT 
                    wr.workout_type,
                    SUM(wr.duration_minutes) as type_minutes
                FROM workout_records wr
                WHERE wr.user_id = user_id_param
                AND DATE(wr.date) >= month_start
                AND DATE(wr.date) <= month_end
                GROUP BY wr.workout_type
            ) type_counts
        ) type_stats
    ),
    
    -- DADOS AGREGADOS: Da tabela user_progress (usando campos corretos)
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
    SELECT json_build_object(
        'calendar', json_build_object(
            'month', month_param,
            'year', year_param,
            'days', (
                SELECT json_agg(
                    json_build_object(
                        'day', EXTRACT(DAY FROM cd.day_date),
                        'date', cd.day_date,
                        'workouts', COALESCE(dw.workouts, '[]'::json),
                        'workout_count', COALESCE(dw.workout_count, 0),
                        'total_minutes', COALESCE(dw.total_minutes, 0),
                        'workout_types', COALESCE(array_to_json(dw.workout_types), '[]'::json),
                        'rings', json_build_object(
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
        'progress', json_build_object(
            'week', json_build_object(
                'workouts', COALESCE(ws.workouts_this_week, 0),
                'minutes', COALESCE(ws.minutes_this_week, 0),
                'types', COALESCE(ws.types_this_week, 0),
                'days', COALESCE(ws.days_this_week, 0)
            ),
            'month', json_build_object(
                'workouts', COALESCE(ms.workouts_this_month, 0),
                'minutes', COALESCE(ms.minutes_this_month, 0),
                'days', COALESCE(ms.days_this_month, 0),
                'types_distribution', COALESCE(ms.workout_types_distribution, '{}')
            ),
            'total', json_build_object(
                'workouts', COALESCE(upd.total_workouts, 0),
                'workouts_completed', COALESCE(upd.workouts_completed, 0),
                'points', COALESCE(upd.total_points, 0),
                'duration', COALESCE(upd.total_duration, 0),
                'days_trained_this_month', COALESCE(upd.days_trained_this_month, 0),
                'level', COALESCE(upd.level, 1),
                'challenges_completed', COALESCE(upd.challenges_completed, 0)
            ),
            'streak', json_build_object(
                'current', COALESCE(upd.current_streak, 0),
                'longest', COALESCE(upd.longest_streak, 0)
            )
        ),
        'awards', json_build_object(
            'total_points', COALESCE(upd.total_points, 0),
            'achievements', COALESCE(upd.achievements::json, '[]'::json),
            'badges', '[]'::json,
            'level', COALESCE(upd.level, 1)
        ),
        'last_updated', COALESCE(upd.last_updated, NOW())
    ) INTO result
    FROM week_stats ws, month_stats ms, user_progress_data upd;
    
    -- Fallback se não há dados de progresso
    IF result IS NULL THEN
        result := json_build_object(
            'calendar', json_build_object(
                'month', month_param,
                'year', year_param,
                'days', '[]'::json
            ),
            'progress', json_build_object(
                'week', json_build_object(
                    'workouts', 0,
                    'minutes', 0,
                    'types', 0,
                    'days', 0
                ),
                'month', json_build_object(
                    'workouts', 0,
                    'minutes', 0,
                    'days', 0,
                    'types_distribution', '{}'::json
                ),
                'total', json_build_object(
                    'workouts', 0,
                    'workouts_completed', 0,
                    'points', 0,
                    'duration', 0,
                    'days_trained_this_month', 0,
                    'level', 1,
                    'challenges_completed', 0
                ),
                'streak', json_build_object(
                    'current', 0,
                    'longest', 0
                )
            ),
            'awards', json_build_object(
                'total_points', 0,
                'achievements', '[]'::json,
                'badges', '[]'::json,
                'level', 1
            ),
            'last_updated', NOW()
        );
    END IF;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ===========================
-- FUNÇÃO AUXILIAR: Detalhes de um dia específico
-- ===========================
CREATE OR REPLACE FUNCTION get_day_details(
    user_id_param UUID,
    date_param DATE
) RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    WITH day_workouts AS (
        SELECT 
            wr.id,
            wr.workout_name,
            wr.workout_type,
            wr.duration_minutes,
            wr.image_urls,
            wr.is_completed,
            wr.points,
            wr.created_at
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        AND DATE(wr.date) = date_param
        ORDER BY wr.created_at
    )
    
    SELECT json_build_object(
        'date', date_param,
        'total_workouts', (SELECT COUNT(*) FROM day_workouts),
        'total_minutes', (SELECT COALESCE(SUM(duration_minutes), 0) FROM day_workouts),
        'total_points', (SELECT COALESCE(SUM(COALESCE(points, 10)), 0) FROM day_workouts),
        'workouts', (
            SELECT COALESCE(
                json_agg(
                    json_build_object(
                        'id', dw.id,
                        'name', COALESCE(dw.workout_name, 'Treino'),
                        'type', dw.workout_type,
                        'duration', dw.duration_minutes,
                        'photo_url', CASE 
                            WHEN dw.image_urls IS NOT NULL AND array_length(dw.image_urls, 1) > 0 
                            THEN dw.image_urls[1] 
                            ELSE NULL 
                        END,
                        'points', COALESCE(dw.points, 10),
                        'is_challenge_valid', dw.is_completed,
                        'created_at', dw.created_at
                    )
                    ORDER BY dw.created_at
                ),
                '[]'::json
            )
            FROM day_workouts dw
        )
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- VERIFICAÇÃO FINAL
-- ========================================

-- Verificar se as funções foram criadas corretamente
SELECT 
    p.proname as function_name,
    p.pronargs as arg_count,
    pg_get_function_result(p.oid) as return_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN ('get_dashboard_fitness', 'get_day_details')
ORDER BY p.proname;

-- Mensagem de sucesso
SELECT 'Funções get_dashboard_fitness e get_day_details criadas com sucesso!' as status; 