-- ========================================
-- DEBUG SIMPLES: IDENTIFICAR PROBLEMA DE AUTENTICAÇÃO
-- ========================================

-- 1. VERIFICAR SE VOCÊ ESTÁ AUTENTICADO
SELECT 
    '=== TESTE DE AUTENTICAÇÃO ===' as debug_step,
    auth.uid() as seu_user_id,
    CASE 
        WHEN auth.uid() IS NULL THEN 'PROBLEMA: Não está autenticado no Supabase'
        ELSE 'OK: Está autenticado'
    END as status_auth;

-- 2. LISTAR TODOS OS USUÁRIOS NA TABELA (SEM FILTRO)
SELECT 
    '=== TODOS OS USUÁRIOS NA TABELA ===' as debug_step;

SELECT 
    user_id,
    current_level,
    created_at
FROM user_progress_level 
ORDER BY created_at DESC
LIMIT 10;

-- 3. BUSCAR SEU USER_ID MANUALMENTE
-- Pegue seu user_id da tabela auth.users ou profiles
SELECT 
    '=== BUSCAR SEU USER_ID ===' as debug_step;

-- Tentar encontrar na tabela profiles
SELECT 
    id as user_id,
    email,
    name
FROM profiles
ORDER BY created_at DESC
LIMIT 10;

-- Tentar encontrar na tabela auth.users (pode não funcionar)
SELECT 
    id as user_id,
    email,
    created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 10;

-- 4. CRIAR SEU REGISTRO SE NÃO EXISTIR
-- Substitua 'SEU-USER-ID-AQUI' pelo seu ID real
/*
INSERT INTO user_progress_level (
    user_id, 
    current_level, 
    unlocked_features,
    level_expires_at,
    created_at,
    updated_at
) VALUES (
    'SEU-USER-ID-AQUI'::UUID,  -- SUBSTITUA PELO SEU ID
    'expert',
    ARRAY[
        'basic_workouts', 'profile', 'basic_challenges', 'workout_recording',
        'enhanced_dashboard', 'nutrition_guide', 'workout_library', 
        'advanced_tracking', 'detailed_reports'
    ],
    NULL,
    NOW(),
    NOW()
) ON CONFLICT (user_id) DO UPDATE SET
    current_level = 'expert',
    unlocked_features = ARRAY[
        'basic_workouts', 'profile', 'basic_challenges', 'workout_recording',
        'enhanced_dashboard', 'nutrition_guide', 'workout_library', 
        'advanced_tracking', 'detailed_reports'
    ],
    updated_at = NOW();
*/

-- 5. TESTAR COM UM USER_ID ESPECÍFICO
-- Execute isso substituindo pelo seu user_id real
/*
SELECT 
    user_id,
    current_level,
    unlocked_features,
    'workout_library' = ANY(unlocked_features) as tem_workout_library
FROM user_progress_level 
WHERE user_id = 'SEU-USER-ID-AQUI'::UUID;
*/ 