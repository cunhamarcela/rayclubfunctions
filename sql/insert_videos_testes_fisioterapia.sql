-- ========================================
-- INSERIR VÍDEOS DE TESTES - FISIOTERAPIA
-- Data: 2025-01-21
-- Subcategoria: testes
-- ========================================

-- Verificar se a categoria fisioterapia existe
SELECT 
    '=== VERIFICAÇÃO DA CATEGORIA FISIOTERAPIA ===' as info;

SELECT 
    id, 
    name, 
    description,
    "workoutsCount"
FROM workout_categories 
WHERE id = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
   OR LOWER(name) = 'fisioterapia';

-- ========================================
-- INSERÇÃO DOS NOVOS VÍDEOS DE TESTES
-- ========================================

-- 1. Testes Apresentação
INSERT INTO workout_videos (
    title,
    description,
    youtube_url,
    thumbnail_url,
    duration,
    duration_minutes,
    difficulty,
    instructor_name,
    category,
    subcategory,
    order_index,
    is_new,
    is_popular,
    is_recommended,
    created_at,
    updated_at
) VALUES (
    'Testes Apresentação',
    'Apresentação dos principais testes funcionais utilizados em fisioterapia para avaliação e diagnóstico de condições musculoesqueléticas.',
    'https://youtu.be/FWa-yQekzro',
    'https://img.youtube.com/vi/FWa-yQekzro/maxresdefault.jpg',
    '15 min',
    15,
    'Iniciante',
    'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', -- ID da categoria Fisioterapia
    'testes',
    1,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 2. Teste Lombar
INSERT INTO workout_videos (
    title,
    description,
    youtube_url,
    thumbnail_url,
    duration,
    duration_minutes,
    difficulty,
    instructor_name,
    category,
    subcategory,
    order_index,
    is_new,
    is_popular,
    is_recommended,
    created_at,
    updated_at
) VALUES (
    'Teste Lombar',
    'Testes específicos para avaliação da região lombar, incluindo avaliação de mobilidade, estabilidade e identificação de possíveis disfunções.',
    'https://youtu.be/EM0NhEDaSz8',
    'https://img.youtube.com/vi/EM0NhEDaSz8/maxresdefault.jpg',
    '12 min',
    12,
    'Iniciante',
    'The Unit',
    'da178dba-ae94-425a-aaed-133af7b1bb0f', -- ID da categoria Fisioterapia
    'testes',
    2,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- ========================================
-- VERIFICAÇÃO DA INSERÇÃO
-- ========================================

-- Verificar se os vídeos foram inseridos corretamente
SELECT 
    '=== VÍDEOS DE TESTES INSERIDOS ===' as info;

SELECT 
    id,
    title,
    youtube_url,
    subcategory,
    instructor_name,
    duration,
    difficulty,
    created_at
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
  AND subcategory = 'testes'
ORDER BY order_index, created_at;

-- Contar total de vídeos por subcategoria na fisioterapia
SELECT 
    '=== CONTAGEM POR SUBCATEGORIA ===' as info;

SELECT 
    subcategory,
    COUNT(*) as quantidade_videos,
    STRING_AGG(title, ', ' ORDER BY order_index) as videos
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
GROUP BY subcategory
ORDER BY subcategory;

-- Atualizar contador da categoria fisioterapia
UPDATE workout_categories 
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
),
updated_at = NOW()
WHERE id = 'da178dba-ae94-425a-aaed-133af7b1bb0f';

-- Verificação final
SELECT 
    '=== VERIFICAÇÃO FINAL ===' as info;

SELECT 
    wc.name as categoria,
    wc."workoutsCount" as total_videos_categoria,
    COUNT(wv.id) as videos_reais,
    CASE 
        WHEN wc."workoutsCount" = COUNT(wv.id) THEN '✅ Correto'
        ELSE '⚠️ Divergência'
    END as status
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id
WHERE wc.id = 'da178dba-ae94-425a-aaed-133af7b1bb0f'
GROUP BY wc.id, wc.name, wc."workoutsCount";

-- Mostrar URLs dos vídeos inseridos para teste
SELECT 
    '=== URLs PARA TESTE ===' as info;

SELECT 
    title,
    youtube_url,
    thumbnail_url
FROM workout_videos 
WHERE youtube_url IN (
    'https://youtu.be/FWa-yQekzro',
    'https://youtu.be/EM0NhEDaSz8'
);

-- ========================================
-- SUCESSO!
-- ========================================

SELECT 
    '🎉 VÍDEOS DE TESTES ADICIONADOS COM SUCESSO! 🎉' as resultado,
    'Agora você pode testar a subcategoria "Testes" no app' as proximos_passos; 