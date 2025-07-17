-- =====================================================
-- SCRIPT: INSERÇÃO DE VÍDEOS FIGHT FIT
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Inserir 2 novos vídeos Fight Fit
-- Vídeos: Mobilidade e Superiores + Cardio
-- Instrutor: Fight Fit
-- Category UUID: 43eb2044-38cf-4193-848c-da46fd7e9cb4
-- =====================================================

-- Verificação inicial: qual categoria tem esse UUID
SELECT 
    id,
    name,
    description,
    "workoutsCount"
FROM workout_categories 
WHERE id = '43eb2044-38cf-4193-848c-da46fd7e9cb4';

-- =====================================================
-- INSERÇÃO DOS NOVOS VÍDEOS FIGHT FIT
-- =====================================================

-- 1. Mobilidade - Fight Fit
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
    'Mobilidade',
    'Treino de mobilidade com exercícios específicos para melhorar flexibilidade, amplitude de movimento e prevenção de lesões.',
    'https://youtu.be/DsRvYpEUuuM',
    'https://img.youtube.com/vi/DsRvYpEUuuM/maxresdefault.jpg',
    '30 min',
    30,
    'Iniciante',
    'Fight Fit',
    '43eb2044-38cf-4193-848c-da46fd7e9cb4',
    1,
    true,
    false,
    false,
    NOW(),
    NOW()
);

-- 2. Superiores + Cardio - Fight Fit
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
    'Superiores + Cardio',
    'Treino intenso combinando exercícios para membros superiores com cardio. Fortalecimento e condicionamento cardiovascular.',
    'https://youtu.be/XRl2edEW4Gs',
    'https://img.youtube.com/vi/XRl2edEW4Gs/maxresdefault.jpg',
    '45 min',
    45,
    'Intermediário',
    'Fight Fit',
    '43eb2044-38cf-4193-848c-da46fd7e9cb4',
    2,
    true,
    false,
    false,
    NOW(),
    NOW()
);

-- =====================================================
-- ATUALIZAÇÃO DA CATEGORIA
-- =====================================================

-- Atualizar contagem de vídeos na categoria Fight Fit
UPDATE workout_categories 
SET 
    "workoutsCount" = (
        SELECT COUNT(*) 
        FROM workout_videos 
        WHERE category = '43eb2044-38cf-4193-848c-da46fd7e9cb4'
    ),
    updated_at = NOW()
WHERE id = '43eb2044-38cf-4193-848c-da46fd7e9cb4';

-- =====================================================
-- VERIFICAÇÕES FINAIS
-- =====================================================

-- 1. Verificar se os vídeos foram inseridos corretamente
SELECT 
    id,
    title,
    youtube_url,
    instructor_name,
    category,
    difficulty,
    duration,
    duration_minutes,
    is_new,
    created_at
FROM workout_videos 
WHERE title IN ('Mobilidade', 'Superiores + Cardio')
ORDER BY created_at DESC;

-- 2. Verificar total de vídeos na categoria Fight Fit
SELECT 
    COUNT(*) as total_videos
FROM workout_videos 
WHERE category = '43eb2044-38cf-4193-848c-da46fd7e9cb4';

-- 3. Verificar contagem atualizada na tabela de categorias
SELECT 
    id,
    name,
    "workoutsCount",
    updated_at
FROM workout_categories 
WHERE id = '43eb2044-38cf-4193-848c-da46fd7e9cb4';

-- 4. Listar todos os vídeos da categoria Fight Fit
SELECT 
    title,
    instructor_name,
    duration,
    difficulty,
    is_new,
    DATE(created_at) as data_criacao
FROM workout_videos 
WHERE category = '43eb2044-38cf-4193-848c-da46fd7e9cb4'
ORDER BY created_at DESC;

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================
-- ✅ Script usando UUID da categoria (não nome)
-- ✅ Instrutor: Fight Fit (conforme especificado)
-- ✅ URLs do YouTube: DsRvYpEUuuM e XRl2edEW4Gs
-- ✅ Thumbnails automáticas do YouTube
-- ✅ Vídeos marcados como novos (is_new=true)
-- ✅ Duração estimada baseada no tipo de treino
-- ✅ Contagem da categoria atualizada automaticamente
-- ===================================================== 