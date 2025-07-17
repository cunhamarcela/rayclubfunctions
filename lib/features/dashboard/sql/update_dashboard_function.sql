-- Atualização da função get_dashboard_data para incluir campos obrigatórios no desafio
-- Principais correções:
-- 1. Adicionar creator_id no objeto JSON do desafio
-- 2. Garantir que todos os campos obrigatórios do modelo Challenge estejam presentes
-- 3. Melhorar tratamento de casos nulos

CREATE OR REPLACE FUNCTION get_dashboard_data(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
    user_progress_data JSON;
    current_challenge_data JSON;
    challenge_progress_data JSON;
    redeemed_benefits_data JSON;
    water_intake_data JSON;
    goals_data JSON;
    recent_workouts_data JSON;
    challenge_id_var UUID;
BEGIN
    -- Get user progress data
    SELECT json_build_object(
        'id', COALESCE(up.id::text, ''),
        'user_id', COALESCE(up.user_id::text, ''),
        'total_workouts', COALESCE(up.total_workouts, 0),
        'current_streak', COALESCE(up.current_streak, 0),
        'longest_streak', COALESCE(up.longest_streak, 0),
        'total_points', COALESCE(up.points, 0),
        'days_trained_this_week', COALESCE(up.days_trained_this_week, 0),
        'days_trained_this_month', COALESCE(up.days_trained_this_month, 0),
        'workout_types', COALESCE(up.workout_types, '{}'::JSONB)
    )
    INTO user_progress_data
    FROM user_progress up
    WHERE up.user_id = user_id_param;

    -- Fallback para user_progress nulo
    IF user_progress_data IS NULL THEN
        user_progress_data := json_build_object(
            'id', '',
            'user_id', user_id_param,
            'total_workouts', 0,
            'current_streak', 0,
            'longest_streak', 0,
            'total_points', 0,
            'days_trained_this_week', 0,
            'days_trained_this_month', 0,
            'workout_types', '{}'::JSONB
        );
    END IF;

    -- Get water intake data
    SELECT json_build_object(
        'id', wi.id,
        'user_id', wi.user_id,
        'date', wi.date,
        'cups', COALESCE(wi.cups, 0),
        'goal', COALESCE(wi.goal, 8),
        'glass_size', COALESCE(wi.glass_size, 250),
        'created_at', wi.created_at,
        'updated_at', wi.updated_at
    )
    INTO water_intake_data
    FROM water_intake wi
    WHERE 
        wi.user_id = user_id_param
        AND wi.date = CURRENT_DATE;

    -- Get recent workouts data
    WITH ordered_workouts AS (
        SELECT 
            wr.id,
            wr.workout_name,
            wr.workout_type,
            wr.date,
            wr.duration_minutes,
            wr.is_completed
        FROM workout_records wr
        WHERE wr.user_id = user_id_param
        ORDER BY wr.date DESC
        LIMIT 10
    )
    SELECT COALESCE(
        (SELECT json_agg(
            json_build_object(
                'id', COALESCE(ow.id::text, ''),
                'workout_name', COALESCE(ow.workout_name, ''),
                'workout_type', COALESCE(ow.workout_type, ''),
                'date', ow.date,
                'duration_minutes', COALESCE(ow.duration_minutes, 0),
                'is_completed', COALESCE(ow.is_completed, false)
            )
        ) FROM ordered_workouts ow),
        '[]'::json
    ) INTO recent_workouts_data;
    
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
            c.creator_id,  -- Adicionado campo creator_id
            c.requirements, -- Adicionado campo requirements
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
            (SELECT json_build_object(
                'id', COALESCE(uac.id::text, ''),
                'title', COALESCE(uac.title, ''),
                'description', COALESCE(uac.description, ''),
                'image_url', COALESCE(uac.image_url, ''),
                'start_date', uac.start_date,
                'end_date', uac.end_date,
                'points', COALESCE(uac.points, 0),
                'type', COALESCE(uac.type, ''),
                'is_official', COALESCE(uac.is_official, false),
                'creator_id', COALESCE(uac.creator_id, ''), -- Incluído campo creator_id
                'requirements', COALESCE(uac.requirements, '[]'), -- Incluído campo requirements
                'days_remaining', EXTRACT(DAY FROM (uac.end_date - CURRENT_DATE))
            ) FROM user_active_challenges uac WHERE uac.challenge_rank = 1)
        ELSE NULL END
    INTO current_challenge_data
    FROM user_active_challenges;
    
    -- Get challenge progress for the current challenge
    SELECT 
        CASE WHEN current_challenge_data IS NOT NULL THEN
            (SELECT json_build_object(
                'id', COALESCE(cp.id::text, ''),
                'user_id', COALESCE(cp.user_id::text, ''),
                'challenge_id', COALESCE(cp.challenge_id::text, ''),
                'points', COALESCE(cp.points, 0),
                'position', COALESCE(cp.position, 0),
                'total_check_ins', COALESCE(
                    CASE 
                        WHEN cp.check_ins_count IS NOT NULL THEN cp.check_ins_count
                        WHEN cp.total_check_ins IS NOT NULL THEN cp.total_check_ins
                        ELSE 0
                    END,
                    0
                ),
                'consecutive_days', COALESCE(cp.consecutive_days, 0),
                'completion_percentage', 
                    CASE 
                        WHEN (current_challenge_data->>'points')::int > 0 THEN
                            (COALESCE(cp.points, 0)::float / (current_challenge_data->>'points')::float) * 100
                        ELSE 0
                    END
            )
            FROM challenge_progress cp
            WHERE 
                cp.challenge_id = (current_challenge_data->>'id')::uuid
                AND cp.user_id = user_id_param)
        ELSE NULL END
    INTO challenge_progress_data;
    
    -- Get redeemed benefits
    WITH ordered_benefits AS (
        SELECT 
            rb.id,
            rb.benefit_id,
            b.title as benefit_title,
            b.image_url as benefit_image_url,
            rb.redeemed_at,
            rb.expiration_date,
            rb.code as redemption_code
        FROM redeemed_benefits rb
        JOIN benefits b ON rb.benefit_id = b.id
        WHERE 
            rb.user_id = user_id_param
            AND rb.status = 'active'
        ORDER BY rb.redeemed_at DESC
        LIMIT 5
    )
    SELECT COALESCE(
        (SELECT json_agg(
            json_build_object(
                'id', ob.id,
                'benefit_id', ob.benefit_id,
                'title', ob.benefit_title,
                'image_url', ob.benefit_image_url,
                'redeemed_at', ob.redeemed_at,
                'expiration_date', ob.expiration_date,
                'redemption_code', ob.redemption_code
            )
        ) FROM ordered_benefits ob),
        '[]'::json
    ) INTO redeemed_benefits_data;

    -- Get active goals (if implemented)
    goals_data := '[]'::json;

    -- Return final combined dashboard data
    RETURN json_build_object(
        'user_progress', user_progress_data,
        'current_challenge', current_challenge_data,
        'challenge_progress', challenge_progress_data,
        'redeemed_benefits', redeemed_benefits_data,
        'water_intake', water_intake_data,
        'goals', goals_data,
        'recent_workouts', recent_workouts_data
    );
END;
$$ LANGUAGE plpgsql; 