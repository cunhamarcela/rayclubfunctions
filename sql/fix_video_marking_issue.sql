-- ========================================
-- CORREÇÃO: ALGUNS VÍDEOS FORAM MARCADOS INCORRETAMENTE
-- ========================================

-- 1. PRIMEIRO: LIBERAR TODOS OS VÍDEOS (VOLTAR AO ESTADO ORIGINAL)
UPDATE workout_videos 
SET requires_expert_access = false,
    updated_at = CURRENT_TIMESTAMP;

-- 2. VERIFICAR QUANTOS VÍDEOS TEMOS E DE QUAIS INSTRUTORES
SELECT 
    '=== TODOS OS INSTRUTORES ===' as info;

SELECT 
    instructor_name,
    COUNT(*) as quantidade_videos
FROM workout_videos 
GROUP BY instructor_name
ORDER BY COUNT(*) DESC;

-- 3. MARCAR APENAS OS VÍDEOS DOS PARCEIROS ESPECÍFICOS
UPDATE workout_videos 
SET requires_expert_access = true,
    updated_at = CURRENT_TIMESTAMP
WHERE instructor_name IN (
    'Treinos de Musculação',
    'Treinos de musculação', -- Variação com m minúsculo
    'Goya Health Club',
    'Fight Fit', 
    'Bora Assessoria',
    'The Unit'
);

-- 4. VERIFICAR O RESULTADO
SELECT 
    '=== RESULTADO APÓS CORREÇÃO ===' as info;

-- Contagem geral
SELECT 
    COUNT(*) as total_videos,
    COUNT(*) FILTER (WHERE requires_expert_access = true) as expert_only_videos,
    COUNT(*) FILTER (WHERE requires_expert_access = false) as public_videos
FROM workout_videos;

-- Por instrutor (apenas dos parceiros)
SELECT 
    instructor_name,
    COUNT(*) as total_videos,
    COUNT(*) FILTER (WHERE requires_expert_access = true) as expert_only,
    COUNT(*) FILTER (WHERE requires_expert_access = false) as public
FROM workout_videos
WHERE instructor_name IN (
    'Treinos de Musculação', 'Treinos de musculação',
    'Goya Health Club', 'Fight Fit', 
    'Bora Assessoria', 'The Unit'
)
GROUP BY instructor_name;

-- Vídeos que NÃO são dos parceiros (devem ser públicos)
SELECT 
    '=== OUTROS INSTRUTORES (DEVEM SER PÚBLICOS) ===' as info;

SELECT 
    instructor_name,
    COUNT(*) as quantidade,
    COUNT(*) FILTER (WHERE requires_expert_access = true) as expert_only,
    COUNT(*) FILTER (WHERE requires_expert_access = false) as public
FROM workout_videos
WHERE instructor_name NOT IN (
    'Treinos de Musculação', 'Treinos de musculação',
    'Goya Health Club', 'Fight Fit', 
    'Bora Assessoria', 'The Unit'
) 
   OR instructor_name IS NULL
GROUP BY instructor_name
ORDER BY COUNT(*) DESC;

-- 5. TESTAR ACESSO PARA VOCÊ
SELECT 
    '=== TESTE SEU ACESSO ===' as info;

-- Função deve retornar TRUE para você
SELECT 
    user_has_workout_library_access() as voce_tem_acesso;

-- Vídeos que você consegue ver
SELECT 
    COUNT(*) as videos_visiveis_para_voce
FROM workout_videos
WHERE (
    requires_expert_access = false
    OR 
    (requires_expert_access = true AND user_has_workout_library_access())
);

-- Alguns exemplos de vídeos dos parceiros
SELECT 
    wv.title,
    wv.instructor_name,
    wv.requires_expert_access,
    CASE 
        WHEN requires_expert_access = false THEN '✅ Público'
        WHEN requires_expert_access = true AND user_has_workout_library_access() THEN '✅ Expert - Acessível'
        ELSE '❌ Bloqueado'
    END as status_para_voce
FROM workout_videos wv
WHERE wv.instructor_name IN (
    'Treinos de Musculação', 'Treinos de musculação',
    'Goya Health Club', 'Fight Fit', 
    'Bora Assessoria', 'The Unit'
)
LIMIT 10;

-- 6. ESTATÍSTICAS FINAIS
SELECT 
    '=== ESTATÍSTICAS FINAIS ===' as info;

SELECT 
    'Total de vídeos' as metrica,
    COUNT(*)::text as valor
FROM workout_videos
UNION ALL
SELECT 
    'Vídeos dos parceiros (bloqueados)',
    COUNT(*)::text
FROM workout_videos 
WHERE requires_expert_access = true
UNION ALL
SELECT 
    'Vídeos públicos (liberados)',
    COUNT(*)::text
FROM workout_videos 
WHERE requires_expert_access = false
UNION ALL
SELECT 
    'Vídeos que você vê como expert',
    COUNT(*)::text
FROM workout_videos
WHERE (
    requires_expert_access = false
    OR 
    (requires_expert_access = true AND user_has_workout_library_access())
);

-- 7. TESTE RÁPIDO DOS CENÁRIOS
SELECT test_access_scenarios(); 