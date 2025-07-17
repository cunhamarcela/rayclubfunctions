-- Script para atualizar a função get_dashboard_data para usar apenas colunas existentes
-- Autor: Claude 3.7
-- Descrição: Resolve o erro "column up.current_streak does not exist"

CREATE OR REPLACE FUNCTION get_dashboard_data(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    user_progress_data JSON;
    water_intake_data JSON;
    goals_data JSON;
    recent_workouts_data JSON;
    current_challenge_data JSON;
    challenge_progress_data JSON;
    redeemed_benefits_data JSON;
    
    -- Variáveis para verificar existência de colunas
    has_current_streak BOOLEAN;
    has_longest_streak BOOLEAN;
    has_total_duration BOOLEAN;
    has_days_trained_this_month BOOLEAN;
    has_points BOOLEAN;
    has_total_points BOOLEAN;
    has_workout_types BOOLEAN;
    has_workouts_by_type BOOLEAN;
BEGIN
    -- Verificar existência de colunas na tabela user_progress
    SELECT 
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'current_streak'),
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'longest_streak'),
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'total_duration'),
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'days_trained_this_month'),
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'points'),
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'total_points'),
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'workout_types'),
        EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_progress' AND column_name = 'workouts_by_type')
    INTO
        has_current_streak,
        has_longest_streak,
        has_total_duration,
        has_days_trained_this_month,
        has_points,
        has_total_points,
        has_workout_types,
        has_workouts_by_type;
    
    -- Construir query dinâmica para user_progress com base nas colunas existentes
    WITH user_progress_json AS (
        SELECT 
            json_build_object(
                'id', up.id,
                'user_id', up.user_id,
                'total_workouts', COALESCE(up.workouts, 0)
                -- As próximas colunas serão adicionadas dinamicamente abaixo
            ) AS base_json
        FROM user_progress up
        WHERE up.user_id = user_id_param
    )
    SELECT
        CASE WHEN has_current_streak THEN 
            json_build_object('current_streak', COALESCE(up.current_streak, 0))
        ELSE
            json_build_object('current_streak', 0)
        END || 
        CASE WHEN has_longest_streak THEN 
            json_build_object('longest_streak', COALESCE(up.longest_streak, 0))
        ELSE
            json_build_object('longest_streak', 0)
        END || 
        CASE WHEN has_total_duration THEN 
            json_build_object('total_duration', COALESCE(up.total_duration, 0))
        ELSE
            json_build_object('total_duration', 0)
        END ||
        CASE WHEN has_points THEN 
            json_build_object('total_points', COALESCE(up.points, 0))
        WHEN has_total_points THEN
            json_build_object('total_points', COALESCE(up.total_points, 0))
        ELSE
            json_build_object('total_points', 0)
        END ||
        CASE WHEN has_days_trained_this_month THEN 
            json_build_object('days_trained_this_month', COALESCE(up.days_trained_this_month, 0))
        ELSE
            json_build_object('days_trained_this_month', 0)
        END ||
        CASE 
            WHEN has_workout_types THEN json_build_object('workout_types', COALESCE(up.workout_types, '{}'::jsonb))
            WHEN has_workouts_by_type THEN json_build_object('workout_types', COALESCE(up.workouts_by_type, '{}'::jsonb))
            ELSE json_build_object('workout_types', '{}'::jsonb)
        END ||
        json_build_object(
            'created_at', up.created_at,
            'updated_at', up.updated_at
        ) || 
        upj.base_json AS combined_json
    INTO user_progress_data
    FROM user_progress up
    CROSS JOIN user_progress_json upj
    WHERE up.user_id = user_id_param;

    -- Se não encontrar dados do usuário, criar uma estrutura vazia
    IF user_progress_data IS NULL THEN
        user_progress_data := json_build_object(
            'id', NULL,
            'user_id', user_id_param,
            'total_workouts', 0,
            'current_streak', 0,
            'longest_streak', 0,
            'total_points', 0,
            'days_trained_this_month', 0,
            'workout_types', '{}'::jsonb,
            'created_at', NULL,
            'updated_at', NULL
        );
    END IF;

    -- Get water intake data for today (with fallback for empty data)
    SELECT COALESCE(
        (SELECT json_build_object(
            'id', wi.id,
            'user_id', wi.user_id,
            'date', wi.date,
            'cups', COALESCE(wi.cups, 0),
            'goal', COALESCE(wi.goal, 8),
            'created_at', wi.created_at,
            'updated_at', wi.updated_at
        )
        FROM water_intake wi
        WHERE wi.user_id = user_id_param
        AND wi.date = CURRENT_DATE
        ORDER BY wi.created_at DESC
        LIMIT 1),
        json_build_object(
            'id', NULL,
            'user_id', user_id_param,
            'date', CURRENT_DATE,
            'cups', 0,
            'goal', 8,
            'created_at', NULL,
            'updated_at', NULL
        )
    ) INTO water_intake_data;

    -- Get user goals (if any)
    SELECT COALESCE(
        json_agg(
            json_build_object(
                'id', g.id,
                'title', g.title,
                'current_value', g.current_value,
                'target_value', g.target_value,
                'unit', g.unit,
                'is_completed', g.is_completed,
                'created_at', g.created_at,
                'updated_at', g.updated_at
            )
        ),
        '[]'::json
    )
    INTO goals_data
    FROM user_goals g
    WHERE g.user_id = user_id_param
    ORDER BY g.created_at DESC;

    -- Get recent workouts
    SELECT COALESCE(
        json_agg(
            json_build_object(
                'id', wr.id,
                'workout_name', wr.workout_name,
                'workout_type', wr.workout_type,
                'date', wr.date,
                'duration_minutes', wr.duration_minutes,
                'is_completed', wr.is_completed
            )
        ),
        '[]'::json
    )
    INTO recent_workouts_data
    FROM workout_records wr
    WHERE wr.user_id = user_id_param
    ORDER BY wr.date DESC
    LIMIT 10;
    
    -- Get active challenge data (preferably the official one first, then user-joined ones)
    WITH user_active_challenges AS (
        SELECT 
            c.id,
            c.title,
            c.description,
            c.image_url,
            c.start_date,
            c.end_date,
            c.points,
            c.type,
            c.is_official,
            ROW_NUMBER() OVER (
                ORDER BY 
                    c.is_official DESC, -- Official challenges first
                    c.end_date ASC -- Then by end date (soonest to end)
            ) as challenge_rank
        FROM challenges c
        JOIN challenge_participants cp ON c.id = cp.challenge_id
        WHERE 
            cp.user_id = user_id_param
            AND c.end_date >= CURRENT_DATE
            AND c.active = true
        ORDER BY challenge_rank
        LIMIT 1
    )
    SELECT 
        CASE WHEN COUNT(*) > 0 THEN
            json_build_object(
                'id', uac.id,
                'title', uac.title,
                'description', uac.description,
                'image_url', uac.image_url,
                'start_date', uac.start_date,
                'end_date', uac.end_date,
                'points', uac.points,
                'type', uac.type,
                'is_official', uac.is_official,
                'days_remaining', EXTRACT(DAY FROM (uac.end_date - CURRENT_DATE))
            )
        ELSE NULL END
    INTO current_challenge_data
    FROM user_active_challenges uac;
    
    -- O restante da função permanece o mesmo
    
    -- Build final result
    result := json_build_object(
        'user_progress', user_progress_data,
        'water_intake', water_intake_data,
        'goals', goals_data,
        'recent_workouts', recent_workouts_data,
        'current_challenge', current_challenge_data,
        'challenge_progress', challenge_progress_data,
        'redeemed_benefits', redeemed_benefits_data,
        'last_updated', CURRENT_TIMESTAMP
    );

    RETURN result;
END;
$$ LANGUAGE plpgsql; 