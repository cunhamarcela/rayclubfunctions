-- Verificação rápida de vídeos públicos

-- 1. CONTAGEM GERAL
SELECT 
    'RESUMO GERAL:' as info,
    COUNT(*) as total_videos,
    COUNT(CASE WHEN requires_expert_access = true THEN 1 END) as expert_only,
    COUNT(CASE WHEN requires_expert_access = false THEN 1 END) as publicos_false,
    COUNT(CASE WHEN requires_expert_access IS NULL THEN 1 END) as publicos_null
FROM workout_videos;

-- 2. VERIFICAR se há vídeos públicos
SELECT 
    'VÍDEOS PÚBLICOS ENCONTRADOS:' as info,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = false OR requires_expert_access IS NULL;

-- 3. LISTAR alguns vídeos públicos (se existirem)
SELECT 
    title,
    instructor_name,
    category,
    requires_expert_access
FROM workout_videos 
WHERE requires_expert_access = false OR requires_expert_access IS NULL
LIMIT 5;

-- 4. DISTRIBUIÇÃO POR CATEGORIA
SELECT 
    category,
    COUNT(*) as total,
    COUNT(CASE WHEN requires_expert_access = true THEN 1 END) as expert_only,
    COUNT(CASE WHEN requires_expert_access = false OR requires_expert_access IS NULL THEN 1 END) as publicos
FROM workout_videos 
GROUP BY category
ORDER BY category;

-- 5. DIAGNÓSTICO DO PROBLEMA
SELECT 
    CASE 
        WHEN (SELECT COUNT(*) FROM workout_videos WHERE requires_expert_access = false OR requires_expert_access IS NULL) = 0 
        THEN '❌ PROBLEMA: Não há vídeos públicos! Só experts deveriam ver algo.'
        ELSE '✅ OK: Há vídeos públicos disponíveis.'
    END as diagnostico; 