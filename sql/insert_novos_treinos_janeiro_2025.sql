-- =====================================================
-- SCRIPT: INSERÇÃO DE NOVOS TREINOS - JANEIRO 2025
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Inserir 3 novos vídeos de treino conforme solicitado
-- Vídeos: 
--   1. Pilates - Restaurativa (Goya Health Club)
--   2. Musculação Treino A - Semana 3 
--   3. Musculação - Treino D - Semana 3
-- =====================================================

-- Verificar se as categorias existem
SELECT 
    id,
    name,
    description,
    "workoutsCount"
FROM workout_categories 
WHERE id IN (
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1', -- Pilates/Goya
    '495f6111-00f1-4484-974f-5213a5a44ed8'  -- Musculação
)
ORDER BY name;

-- =====================================================
-- INSERÇÃO DOS NOVOS VÍDEOS
-- =====================================================

-- 1. Pilates - Restaurativa (Goya Health Club)
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
    order_index,
    is_new,
    is_popular,
    is_recommended,
    created_at,
    updated_at
) VALUES (
    'Pilates - Restaurativa',
    'Treino de Pilates restaurativo focado em relaxamento, alongamento e fortalecimento suave para recuperação e bem-estar.',
    'https://youtu.be/GuReZ7sCgEk',
    'https://img.youtube.com/vi/GuReZ7sCgEk/maxresdefault.jpg',
    '45 min',
    45,
    'Iniciante',
    'Goya Health Club',
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
    20,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 2. Musculação Treino A - Semana 3
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
    order_index,
    is_new,
    is_popular,
    is_recommended,
    created_at,
    updated_at
) VALUES (
    'Musculação Treino A - Semana 3',
    'Treino de musculação avançado - Treino A da terceira semana com exercícios para desenvolvimento muscular e força.',
    'https://youtu.be/DL6aNyy_SRA',
    'https://img.youtube.com/vi/DL6aNyy_SRA/maxresdefault.jpg',
    '55 min',
    55,
    'Avançado',
    'Treinos de Musculação',
    '495f6111-00f1-4484-974f-5213a5a44ed8',
    30,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- 3. Musculação - Treino D - Semana 3
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
    order_index,
    is_new,
    is_popular,
    is_recommended,
    created_at,
    updated_at
) VALUES (
    'Musculação - Treino D - Semana 3',
    'Treino de musculação avançado - Treino D da terceira semana com foco em desenvolvimento muscular específico.',
    'https://youtu.be/c__Yxm0yxTY',
    'https://img.youtube.com/vi/c__Yxm0yxTY/maxresdefault.jpg',
    '55 min',
    55,
    'Avançado',
    'Treinos de Musculação',
    '495f6111-00f1-4484-974f-5213a5a44ed8',
    31,
    true,
    true,
    true,
    NOW(),
    NOW()
);

-- =====================================================
-- ATUALIZAR CONTADORES DAS CATEGORIAS
-- =====================================================

-- Atualizar contador de vídeos para categoria Pilates
UPDATE workout_categories 
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = 'fe034f6d-aa79-436c-b0b7-7aea572f08c1'
)
WHERE id = 'fe034f6d-aa79-436c-b0b7-7aea572f08c1';

-- Atualizar contador de vídeos para categoria Musculação
UPDATE workout_categories 
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = '495f6111-00f1-4484-974f-5213a5a44ed8'
)
WHERE id = '495f6111-00f1-4484-974f-5213a5a44ed8';

-- =====================================================
-- VERIFICAÇÕES FINAIS
-- =====================================================

-- Verificar se os vídeos foram inseridos corretamente
SELECT 
    id,
    title,
    duration,
    difficulty,
    youtube_url,
    instructor_name,
    (SELECT name FROM workout_categories WHERE id::text = wv.category) as categoria,
    is_new,
    created_at
FROM workout_videos wv
WHERE youtube_url IN (
    'https://youtu.be/GuReZ7sCgEk',
    'https://youtu.be/DL6aNyy_SRA',
    'https://youtu.be/c__Yxm0yxTY'
)
ORDER BY created_at DESC;

-- Verificar contadores atualizados
SELECT 
    id,
    name,
    "workoutsCount",
    description
FROM workout_categories 
WHERE id IN (
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
    '495f6111-00f1-4484-974f-5213a5a44ed8'
)
ORDER BY name;

-- Confirmar total de vídeos por categoria
SELECT 
    wc.name as categoria,
    wc."workoutsCount" as contador_tabela,
    COUNT(wv.id) as contagem_real,
    CASE 
        WHEN wc."workoutsCount" = COUNT(wv.id) THEN '✅ CORRETO' 
        ELSE '❌ DIVERGÊNCIA' 
    END as status
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id::text
WHERE wc.id IN (
    'fe034f6d-aa79-436c-b0b7-7aea572f08c1',
    '495f6111-00f1-4484-974f-5213a5a44ed8'
)
GROUP BY wc.id, wc.name, wc."workoutsCount"
ORDER BY wc.name; 