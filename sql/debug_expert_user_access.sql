-- Diagnóstico: Por que usuário EXPERT não vê todos os vídeos?

-- 1. VERIFICAR todos os vídeos e suas configurações
SELECT 
    'ANÁLISE COMPLETA DOS VÍDEOS:' as debug_step;

SELECT 
    instructor_name,
    COUNT(*) as total_videos,
    COUNT(CASE WHEN requires_expert_access = true THEN 1 END) as expert_only,
    COUNT(CASE WHEN requires_expert_access = false OR requires_expert_access IS NULL THEN 1 END) as public_videos
FROM workout_videos 
GROUP BY instructor_name
ORDER BY instructor_name;

-- 2. VERIFICAR especificamente os vídeos de parceiros
SELECT 
    'VÍDEOS DE PARCEIROS (devem ser expert-only):' as debug_step;

SELECT 
    instructor_name,
    title,
    requires_expert_access,
    CASE 
        WHEN requires_expert_access = true THEN '✅ EXPERT-ONLY'
        WHEN requires_expert_access = false THEN '❌ PÚBLICO (deveria ser expert)'
        WHEN requires_expert_access IS NULL THEN '❌ NULL (deveria ser expert)'
    END as status_correto
FROM workout_videos 
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
ORDER BY instructor_name, title;

-- 3. VERIFICAR vídeos que aparecem na tela de treinos
SELECT 
    'VÍDEOS QUE DEVERIAM APARECER PARA EXPERT:' as debug_step;

-- Públicos + Expert-only = todos para expert
SELECT 
    'Públicos (todos veem):' as tipo,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = false OR requires_expert_access IS NULL;

SELECT 
    'Expert-only (só experts veem):' as tipo,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = true;

SELECT 
    'TOTAL que expert deveria ver:' as tipo,
    COUNT(*) as total
FROM workout_videos;

-- 4. CRIAR função para simular acesso de expert
CREATE OR REPLACE FUNCTION simulate_expert_access(expert_user_id UUID)
RETURNS TABLE(
    video_id UUID,
    title TEXT,
    instructor_name TEXT,
    requires_expert_access BOOLEAN,
    would_be_visible BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        wv.id,
        wv.title,
        wv.instructor_name,
        wv.requires_expert_access,
        -- Simular a lógica da política RLS
        CASE
            WHEN (wv.requires_expert_access = false OR wv.requires_expert_access IS NULL) THEN true
            WHEN wv.requires_expert_access = true AND EXISTS (
                SELECT 1 
                FROM user_progress_level upl
                WHERE upl.user_id = expert_user_id
                AND upl.current_level = 'expert'
                AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
            ) THEN true
            ELSE false
        END as would_be_visible
    FROM workout_videos wv
    ORDER BY wv.instructor_name, wv.title;
END;
$$ LANGUAGE plpgsql;

-- 5. BUSCAR ID de um usuário expert para teste
SELECT 
    'USUÁRIO EXPERT PARA SIMULAÇÃO:' as debug_step,
    au.id as expert_id,
    au.email,
    upl.current_level,
    upl.level_expires_at
FROM auth.users au
JOIN user_progress_level upl ON upl.user_id = au.id
WHERE upl.current_level = 'expert'
AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
LIMIT 1;

-- 6. TESTAR com um usuário expert específico
-- Substitua o UUID abaixo pelo ID do usuário expert retornado acima
DO $$
DECLARE
    expert_uuid UUID;
BEGIN
    -- Buscar primeiro usuário expert
    SELECT au.id INTO expert_uuid
    FROM auth.users au
    JOIN user_progress_level upl ON upl.user_id = au.id
    WHERE upl.current_level = 'expert'
    AND (upl.level_expires_at IS NULL OR upl.level_expires_at > now())
    LIMIT 1;
    
    IF expert_uuid IS NOT NULL THEN
        RAISE NOTICE 'Testando com usuário expert: %', expert_uuid;
        
        -- Mostrar resultado da simulação
        PERFORM 'SIMULAÇÃO DE ACESSO PARA EXPERT:' as debug_step;
    END IF;
END $$;

-- 7. VERIFICAR se há problemas com categorias específicas
SELECT 
    'ANÁLISE POR CATEGORIA:' as debug_step;

SELECT 
    wc.name as category_name,
    COUNT(wv.id) as total_videos,
    COUNT(CASE WHEN wv.requires_expert_access = true THEN 1 END) as expert_only
FROM workout_videos wv
LEFT JOIN workout_categories wc ON wc.id = wv.category_id
GROUP BY wc.name, wc.id
ORDER BY wc.name;

-- 8. INSTRUÇÕES ESPECÍFICAS
SELECT 'PRÓXIMOS PASSOS:' as debug_step;
SELECT '1. Execute este script completo' as passo1;
SELECT '2. Verifique se TODOS os vídeos de parceiros estão marcados como expert-only' as passo2;
SELECT '3. Teste no Flutter com console.log do resultado da query' as passo3;
SELECT '4. Verifique se há filtros adicionais no código Flutter' as passo4; 