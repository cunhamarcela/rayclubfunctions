-- Script para configurar conta demo para Apple Review
-- Este script cria um usuário de teste com acesso completo ao app

-- 1. Criar usuário de autenticação
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    '961eb325-728d-4ab5-a343-6ffd2674baa8',
    'authenticated',
    'authenticated',
    'review@rayclub.com',
    crypt('AppleReview2025!', gen_salt('bf')),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"name": "Apple Review User", "full_name": "Apple Review User"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
) ON CONFLICT (email) DO UPDATE SET
    encrypted_password = crypt('AppleReview2025!', gen_salt('bf')),
    email_confirmed_at = NOW(),
    updated_at = NOW();

-- 2. Criar perfil completo do usuário
INSERT INTO public.profiles (
    id,
    email,
    name,
    bio,
    role,
    is_admin,
    points,
    streak,
    completed_workouts,
    onboarding_seen,
    goals,
    settings,
    created_at,
    updated_at
) VALUES (
    '961eb325-728d-4ab5-a343-6ffd2674baa8',
    'review@rayclub.com',
    'Apple Review User',
    'Conta de demonstração para revisão da Apple Store',
    'user',
    false,
    2500, -- Pontos altos para mostrar progresso
    14,   -- Streak de 2 semanas
    25,   -- 25 treinos completados
    true, -- Onboarding já visto
    ARRAY['weight_loss', 'muscle_gain', 'endurance']::text[], -- Objetivos variados
    jsonb_build_object(
        'dark_mode', false,
        'notifications', true,
        'email_notifications', true,
        'push_notifications', true,
        'workout_reminders', true,
        'challenge_updates', true,
        'language', 'pt-BR'
    ),
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    bio = EXCLUDED.bio,
    points = EXCLUDED.points,
    streak = EXCLUDED.streak,
    completed_workouts = EXCLUDED.completed_workouts,
    onboarding_seen = EXCLUDED.onboarding_seen,
    goals = EXCLUDED.goals,
    settings = EXCLUDED.settings,
    updated_at = NOW();

-- 3. Configurar progresso do usuário
INSERT INTO public.user_progress (
    user_id,
    points,
    level,
    workouts,
    created_at,
    updated_at
) VALUES (
    '961eb325-728d-4ab5-a343-6ffd2674baa8',
    2500,
    8,    -- Nível alto
    25,   -- 25 workouts
    NOW(),
    NOW()
) ON CONFLICT (user_id) DO UPDATE SET
    points = EXCLUDED.points,
    level = EXCLUDED.level,
    workouts = EXCLUDED.workouts,
    updated_at = NOW();

-- 4. Configurar nível de acesso como EXPERT
INSERT INTO public.user_progress_level (
    user_id,
    level,
    created_at,
    updated_at
) VALUES (
    '961eb325-728d-4ab5-a343-6ffd2674baa8',
    'expert',
    NOW(),
    NOW()
) ON CONFLICT (user_id) DO UPDATE SET
    level = 'expert',
    updated_at = NOW();

-- 5. Adicionar participação em desafios ativos
INSERT INTO public.challenge_progress (
    user_id,
    challenge_id,
    progress,
    completed,
    joined_at,
    updated_at
) 
SELECT 
    '961eb325-728d-4ab5-a343-6ffd2674baa8',
    c.id,
    CASE 
        WHEN c.id = 1 THEN 15 -- Ray 21 - progresso parcial
        ELSE 5 -- Outros desafios - progresso inicial
    END,
    false,
    NOW() - INTERVAL '5 days', -- Participando há 5 dias
    NOW()
FROM public.challenges c
WHERE c.is_active = true
ON CONFLICT (user_id, challenge_id) DO UPDATE SET
    progress = EXCLUDED.progress,
    updated_at = NOW();

-- 6. Adicionar alguns check-ins de exemplo
INSERT INTO public.challenge_check_ins (
    user_id,
    challenge_id,
    workout_id,
    check_in_date,
    created_at
)
SELECT 
    '961eb325-728d-4ab5-a343-6ffd2674baa8',
    1, -- Ray 21
    w.id,
    NOW() - INTERVAL (row_number() OVER ()) || ' days',
    NOW() - INTERVAL (row_number() OVER ()) || ' days'
FROM (
    SELECT id FROM public.workouts 
    WHERE category_id IN (1, 2, 3) -- Diferentes categorias
    LIMIT 10
) w
ON CONFLICT (user_id, challenge_id, check_in_date) DO NOTHING;

-- 7. Adicionar histórico de treinos
INSERT INTO public.workout_records (
    user_id,
    workout_id,
    duration_minutes,
    calories_burned,
    completed_at,
    created_at
)
SELECT 
    '961eb325-728d-4ab5-a343-6ffd2674baa8',
    w.id,
    30 + (random() * 30)::int, -- Duração entre 30-60 min
    200 + (random() * 200)::int, -- Calorias entre 200-400
    NOW() - INTERVAL (row_number() OVER ()) || ' days',
    NOW() - INTERVAL (row_number() OVER ()) || ' days'
FROM (
    SELECT id FROM public.workouts 
    WHERE category_id IN (1, 2, 3, 4) -- Diferentes categorias
    LIMIT 15
) w
ON CONFLICT (user_id, workout_id, completed_at) DO NOTHING;

-- 8. Configurar metas semanais
INSERT INTO public.weekly_goals (
    user_id,
    week_start,
    workout_minutes_goal,
    workout_minutes_current,
    workouts_goal,
    workouts_current,
    created_at,
    updated_at
) VALUES (
    '961eb325-728d-4ab5-a343-6ffd2674baa8',
    date_trunc('week', NOW()),
    300, -- Meta: 5 horas por semana
    180, -- Progresso: 3 horas
    5,   -- Meta: 5 treinos
    3,   -- Progresso: 3 treinos
    NOW(),
    NOW()
) ON CONFLICT (user_id, week_start) DO UPDATE SET
    workout_minutes_goal = EXCLUDED.workout_minutes_goal,
    workout_minutes_current = EXCLUDED.workout_minutes_current,
    workouts_goal = EXCLUDED.workouts_goal,
    workouts_current = EXCLUDED.workouts_current,
    updated_at = NOW();

-- 9. Verificação final - mostrar dados do usuário demo
SELECT 
    'USUÁRIO DEMO CONFIGURADO' as status,
    p.id,
    p.email,
    p.name,
    p.points,
    p.streak,
    p.completed_workouts,
    upl.level as access_level,
    p.onboarding_seen,
    array_length(p.goals, 1) as goals_count
FROM profiles p
LEFT JOIN user_progress_level upl ON upl.user_id = p.id
WHERE p.email = 'review@rayclub.com';

-- 10. Mostrar estatísticas do usuário
SELECT 
    'ESTATÍSTICAS' as info,
    COUNT(DISTINCT wr.id) as total_workouts,
    COUNT(DISTINCT cci.id) as total_checkins,
    COUNT(DISTINCT cp.challenge_id) as challenges_joined,
    SUM(wr.duration_minutes) as total_minutes
FROM profiles p
LEFT JOIN workout_records wr ON wr.user_id = p.id
LEFT JOIN challenge_check_ins cci ON cci.user_id = p.id
LEFT JOIN challenge_progress cp ON cp.user_id = p.id
WHERE p.email = 'review@rayclub.com'
GROUP BY p.id;

-- Informações para a Apple Review:
-- Email: review@rayclub.com
-- Senha: AppleReview2025!
-- 
-- Este usuário tem:
-- ✅ Acesso expert a todo conteúdo
-- ✅ Histórico de treinos e progresso
-- ✅ Participação em desafios
-- ✅ Metas configuradas
-- ✅ Onboarding completo
-- ✅ Configurações personalizadas 