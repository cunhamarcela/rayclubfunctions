-- =====================================================
-- SCRIPT: INSERÇÃO DE VÍDEO ADICIONAL DE MUSCULAÇÃO
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Inserir 1 vídeo adicional de musculação
-- URL: https://youtu.be/2E8sn_7uzo4
-- Instrutor: Treinos de musculação
-- Category UUID: 495f6111-00f1-4484-974f-5213a5a44ed8
-- =====================================================

-- Verificação inicial: qual categoria tem esse UUID
SELECT 
    id,
    name,
    description,
    "workoutsCount"
FROM workout_categories 
WHERE id = '495f6111-00f1-4484-974f-5213a5a44ed8';

-- =====================================================
-- INSERÇÃO DO VÍDEO ADICIONAL
-- =====================================================

-- Vídeo de Musculação Adicional
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
    'Treino de Musculação Completo',
    'Treino completo de musculação focado no desenvolvimento de força e hipertrofia muscular. Exercícios estruturados para máximos resultados.',
    'https://youtu.be/2E8sn_7uzo4',
    'https://img.youtube.com/vi/2E8sn_7uzo4/maxresdefault.jpg',
    '50 min',
    50,
    'Intermediário',
    'Treinos de musculação',
    '495f6111-00f1-4484-974f-5213a5a44ed8',
    1,
    true,
    false,
    false,
    NOW(),
    NOW()
);

-- =====================================================
-- ATUALIZAÇÃO DA CATEGORIA
-- =====================================================

-- Atualizar contagem de vídeos na categoria
UPDATE workout_categories 
SET 
    "workoutsCount" = (
        SELECT COUNT(*) 
        FROM workout_videos 
        WHERE category = '495f6111-00f1-4484-974f-5213a5a44ed8'
    ),
    updated_at = NOW()
WHERE id = '495f6111-00f1-4484-974f-5213a5a44ed8';

-- =====================================================
-- VERIFICAÇÕES FINAIS
-- =====================================================

-- 1. Verificar se o vídeo foi inserido corretamente
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
WHERE title = 'Treino de Musculação Completo'
ORDER BY created_at DESC;

-- 2. Verificar total de vídeos na categoria
SELECT 
    COUNT(*) as total_videos
FROM workout_videos 
WHERE category = '495f6111-00f1-4484-974f-5213a5a44ed8';

-- 3. Verificar contagem atualizada na tabela de categorias
SELECT 
    id,
    name,
    "workoutsCount",
    updated_at
FROM workout_categories 
WHERE id = '495f6111-00f1-4484-974f-5213a5a44ed8';

-- 4. Listar todos os vídeos da categoria
SELECT 
    title,
    instructor_name,
    duration,
    difficulty,
    is_new,
    DATE(created_at) as data_criacao
FROM workout_videos 
WHERE category = '495f6111-00f1-4484-974f-5213a5a44ed8'
ORDER BY created_at DESC;

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================
-- ✅ Script usando UUID da categoria específica
-- ✅ Instrutor: "Treinos de musculação" (conforme especificado)
-- ✅ URL do YouTube: 2E8sn_7uzo4
-- ✅ Thumbnail automática do YouTube
-- ✅ Vídeo marcado como novo (is_new=true)
-- ✅ Duração estimada: 50 min (baseada em treinos de musculação)
-- ✅ Contagem da categoria atualizada automaticamente
-- ===================================================== 