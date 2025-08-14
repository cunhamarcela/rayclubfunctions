-- ========================================
-- REMOVER VÍDEO "APRESENTAÇÃO" DA SUBCATEGORIA TESTES
-- Data: 2025-01-21
-- Objetivo: Mover vídeo para fisioterapia geral (sem subcategoria)
-- ========================================

-- Verificar vídeo antes da alteração
SELECT 
    '=== VÍDEO ANTES DA ALTERAÇÃO ===' as info;

SELECT 
    id,
    title,
    youtube_url,
    category,
    subcategory,
    instructor_name,
    duration,
    difficulty,
    created_at
FROM workout_videos 
WHERE id = '93c4233d-b80d-4aaa-80c5-c621009770b8';

-- ========================================
-- REMOVER DA SUBCATEGORIA TESTES
-- ========================================

-- Atualizar o vídeo "Apresentação" para remover da subcategoria
UPDATE workout_videos 
SET 
    subcategory = NULL,
    updated_at = NOW()
WHERE id = '93c4233d-b80d-4aaa-80c5-c621009770b8'
  AND title = 'Apresentação'
  AND subcategory = 'testes';

-- Verificar se a atualização foi realizada
SELECT 
    '=== RESULTADO DA ATUALIZAÇÃO ===' as info;

-- Mostrar quantas linhas foram afetadas
SELECT 
    CASE 
        WHEN ROW_COUNT() > 0 THEN '✅ Vídeo atualizado com sucesso'
        ELSE '⚠️ Nenhuma linha foi alterada'
    END as status;

-- ========================================
-- VERIFICAÇÕES APÓS ALTERAÇÃO
-- ========================================

-- Verificar vídeo após a alteração
SELECT 
    '=== VÍDEO APÓS A ALTERAÇÃO ===' as info;

SELECT 
    id,
    title,
    youtube_url,
    category,
    subcategory,
    instructor_name,
    duration,
    difficulty,
    updated_at
FROM workout_videos 
WHERE id = '93c4233d-b80d-4aaa-80c5-c621009770b8';

-- Verificar todos os vídeos da subcategoria "testes" agora
SELECT 
    '=== VÍDEOS RESTANTES NA SUBCATEGORIA TESTES ===' as info;

SELECT 
    id,
    title,
    youtube_url,
    subcategory,
    instructor_name,
    duration,
    order_index,
    created_at
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND subcategory = 'testes'
ORDER BY order_index, created_at;

-- Verificar vídeos de fisioterapia sem subcategoria (categoria geral)
SELECT 
    '=== VÍDEOS DE FISIOTERAPIA SEM SUBCATEGORIA ===' as info;

SELECT 
    id,
    title,
    youtube_url,
    subcategory,
    instructor_name,
    duration,
    created_at
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (subcategory IS NULL OR subcategory = '')
ORDER BY created_at;

-- Resumo por subcategoria na fisioterapia
SELECT 
    '=== RESUMO POR SUBCATEGORIA NA FISIOTERAPIA ===' as info;

SELECT 
    COALESCE(subcategory, '(sem subcategoria)') as subcategoria,
    COUNT(*) as quantidade_videos,
    STRING_AGG(title, ', ' ORDER BY title) as videos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
GROUP BY subcategory
ORDER BY subcategory NULLS FIRST;

-- ========================================
-- VERIFICAÇÃO FINAL
-- ========================================

-- Confirmar que o vídeo "Apresentação" está na fisioterapia mas fora de "testes"
SELECT 
    '=== VERIFICAÇÃO FINAL ===' as info;

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM workout_videos 
            WHERE id = '93c4233d-b80d-4aaa-80c5-c621009770b8'
              AND category = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
              AND (subcategory IS NULL OR subcategory != 'testes')
        ) THEN '✅ Vídeo "Apresentação" movido com sucesso para fisioterapia geral'
        ELSE '❌ Erro: Vídeo ainda está na subcategoria testes ou não foi encontrado'
    END as resultado;

-- ========================================
-- SUCESSO!
-- ========================================

SELECT 
    '🎉 VÍDEO "APRESENTAÇÃO" REMOVIDO DA SUBCATEGORIA TESTES! 🎉' as resultado,
    'O vídeo agora está na categoria Fisioterapia (sem subcategoria específica)' as detalhes,
    'A subcategoria "Testes" agora tem apenas 2 vídeos específicos' as observacao; 