-- ========================================
-- ATUALIZAR SUBCATEGORIA: FORTALECIMENTO → ESTABILIDADE
-- Data: 2025-01-21
-- Objetivo: Alterar nome da subcategoria no banco de dados
-- ========================================

-- Verificar vídeos atuais com subcategoria 'fortalecimento'
SELECT 
    '=== VÍDEOS COM SUBCATEGORIA FORTALECIMENTO ===' as info;

SELECT 
    id,
    title,
    subcategory,
    youtube_url,
    created_at
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND subcategory = 'fortalecimento'
ORDER BY title;

-- Verificar estrutura atual de todas as subcategorias
SELECT 
    '=== ESTRUTURA ATUAL DE SUBCATEGORIAS ===' as info;

SELECT 
    COALESCE(subcategory, '(sem subcategoria)') as subcategoria,
    COUNT(*) as quantidade_videos,
    STRING_AGG(title, ', ' ORDER BY title) as videos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
GROUP BY subcategory
ORDER BY subcategoria;

-- ========================================
-- ATUALIZAÇÃO: FORTALECIMENTO → ESTABILIDADE
-- ========================================

-- Atualizar todos os vídeos de 'fortalecimento' para 'estabilidade'
UPDATE workout_videos 
SET 
    subcategory = 'estabilidade',
    updated_at = NOW()
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND subcategory = 'fortalecimento';

-- Verificar quantos registros foram atualizados
SELECT 
    '=== RESULTADO DA ATUALIZAÇÃO ===' as info,
    'Vídeos atualizados de fortalecimento para estabilidade' as descricao;

-- ========================================
-- VERIFICAÇÕES PÓS-ATUALIZAÇÃO
-- ========================================

-- Verificar se ainda existem vídeos com 'fortalecimento'
SELECT 
    '=== VERIFICAÇÃO: AINDA EXISTEM FORTALECIMENTO? ===' as info;

SELECT 
    COUNT(*) as videos_fortalecimento_restantes
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND subcategory = 'fortalecimento';

-- Verificar nova estrutura de subcategorias
SELECT 
    '=== NOVA ESTRUTURA DE SUBCATEGORIAS ===' as info;

SELECT 
    COALESCE(subcategory, '(sem subcategoria)') as subcategoria,
    COUNT(*) as quantidade_videos,
    STRING_AGG(title, ', ' ORDER BY title) as videos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
GROUP BY subcategory
ORDER BY subcategoria;

-- Verificar especificamente os vídeos de estabilidade
SELECT 
    '=== VÍDEOS NA SUBCATEGORIA ESTABILIDADE ===' as info;

SELECT 
    title,
    youtube_url,
    duration,
    difficulty,
    order_index
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND subcategory = 'estabilidade'
ORDER BY order_index, title;

-- ========================================
-- SUCESSO!
-- ========================================

SELECT 
    '🎉 SUBCATEGORIA ATUALIZADA COM SUCESSO! 🎉' as resultado,
    'Todos os vídeos de "fortalecimento" agora são "estabilidade"' as descricao,
    'Interface Flutter já está alinhada!' as status; 