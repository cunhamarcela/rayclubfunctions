-- Script completo para configurar o usuário de teste da Apple Review
-- ID do usuário: 961eb325-728d-4ab5-a343-6ffd2674baa8
-- Email: review@rayclub.com

-- 1. Verificar se o usuário existe
SELECT id, email, created_at FROM auth.users WHERE email = 'review@rayclub.com';

-- 2. Inserir/Atualizar o perfil do usuário
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
    created_at,
    updated_at
) VALUES (
    '961eb325-728d-4ab5-a343-6ffd2674baa8',
    'review@rayclub.com',
    'Apple Review User',
    'Conta de teste para revisão da Apple',
    'user',
    false,
    1000, -- Pontos iniciais
    7,    -- Streak de 7 dias
    10,   -- 10 treinos completados
    true, -- Onboarding já visto
    NOW(),
    NOW()
) ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    bio = EXCLUDED.bio,
    points = EXCLUDED.points,
    streak = EXCLUDED.streak,
    completed_workouts = EXCLUDED.completed_workouts,
    onboarding_seen = EXCLUDED.onboarding_seen,
    updated_at = NOW();

-- 3. Inserir na tabela user_progress
INSERT INTO public.user_progress (
    user_id,
    points,
    level,
    workouts,
    created_at,
    updated_at
) VALUES (
    '961eb325-728d-4ab5-a343-6ffd2674baa8',
    1000,
    5,    -- Nível alto
    10,   -- 10 workouts
    NOW(),
    NOW()
) ON CONFLICT (user_id) DO UPDATE SET
    points = EXCLUDED.points,
    level = EXCLUDED.level,
    workouts = EXCLUDED.workouts,
    updated_at = NOW();

-- 4. Inserir na tabela user_progress_level como EXPERT
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

-- 5. Verificar se tudo foi inserido corretamente
SELECT 
    'Perfil:' as tabela,
    p.id,
    p.email,
    p.name,
    p.points,
    p.streak,
    p.completed_workouts
FROM profiles p
WHERE p.id = '961eb325-728d-4ab5-a343-6ffd2674baa8'

UNION ALL

SELECT 
    'Progress:' as tabela,
    up.user_id as id,
    p.email,
    p.name,
    up.points,
    up.level as streak,
    up.workouts as completed_workouts
FROM user_progress up
JOIN profiles p ON p.id = up.user_id
WHERE up.user_id = '961eb325-728d-4ab5-a343-6ffd2674baa8'

UNION ALL

SELECT 
    'Level:' as tabela,
    upl.user_id as id,
    p.email,
    p.name,
    0 as points,
    upl.level::text as streak,
    0 as completed_workouts
FROM user_progress_level upl
JOIN profiles p ON p.id = upl.user_id
WHERE upl.user_id = '961eb325-728d-4ab5-a343-6ffd2674baa8';

-- 6. Garantir que o usuário tenha acesso a conteúdo expert
-- Adicionar algumas metas de exemplo
UPDATE profiles 
SET goals = ARRAY['weight_loss', 'muscle_gain', 'endurance']::text[]
WHERE id = '961eb325-728d-4ab5-a343-6ffd2674baa8';

-- 7. Adicionar configurações de notificação
UPDATE profiles 
SET settings = jsonb_build_object(
    'dark_mode', false,
    'notifications', true,
    'email_notifications', true,
    'push_notifications', true,
    'workout_reminders', true,
    'challenge_updates', true
)
WHERE id = '961eb325-728d-4ab5-a343-6ffd2674baa8';

-- 8. Verificação final completa
SELECT 
    p.id,
    p.email,
    p.name,
    p.role,
    p.points,
    p.streak,
    p.completed_workouts,
    upl.level as access_level,
    p.onboarding_seen,
    p.created_at
FROM profiles p
LEFT JOIN user_progress_level upl ON upl.user_id = p.id
WHERE p.email = 'review@rayclub.com';

-- Resultado esperado:
-- O usuário review@rayclub.com deve estar:
-- ✅ Na tabela profiles com dados completos
-- ✅ Na tabela user_progress com pontos e nível
-- ✅ Na tabela user_progress_level como 'expert'
-- ✅ Com acesso total ao conteúdo do app 