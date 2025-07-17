-- ========================================
-- VERIFICAR USUÁRIOS REAIS NO BANCO
-- ========================================
-- Verificar todos os usuários e seus níveis

-- 1. Verificar usuário Marcela (expert)
SELECT 
    '1. USUÁRIO MARCELA (EXPERT):' as info,
    user_id,
    current_level,
    level_expires_at,
    get_user_level(user_id) as function_result
FROM user_progress_level 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9';

-- 2. Verificar usuário atual do app (cecelacunha83@gmail.com)
SELECT 
    '2. USUÁRIO ATUAL DO APP:' as info,
    user_id,
    current_level,
    level_expires_at,
    get_user_level(user_id) as function_result
FROM user_progress_level 
WHERE user_id = '6d789279-a719-4573-9164-2246357b7dbe';

-- 3. Listar TODOS os usuários e seus níveis
SELECT 
    '3. TODOS OS USUÁRIOS:' as info,
    user_id,
    current_level,
    level_expires_at,
    CASE 
        WHEN current_level = 'expert' THEN '🌟 EXPERT'
        WHEN current_level = 'basic' THEN '⚠️ BASIC'
        ELSE '❓ UNKNOWN'
    END as status
FROM user_progress_level 
ORDER BY current_level DESC, user_id;

-- 4. Testar função para ambos usuários
SELECT 
    '4. TESTE FUNÇÃO get_user_level:' as info,
    'Marcela (01d4a292...)' as usuario,
    get_user_level('01d4a292-1873-4af6-948b-a55eed56d6b9') as nivel;

SELECT 
    '4. TESTE FUNÇÃO get_user_level:' as info,
    'App User (6d789279...)' as usuario,
    get_user_level('6d789279-a719-4573-9164-2246357b7dbe') as nivel; 