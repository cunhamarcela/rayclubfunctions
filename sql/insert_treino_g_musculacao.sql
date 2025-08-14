-- =====================================================
-- SCRIPT: INSERÇÃO DO TREINO G DE MUSCULAÇÃO
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Inserir Treino G com vídeo e PDF associado
-- =====================================================

-- =====================================================
-- PARTE 1: INSERIR TREINO G NA TABELA WORKOUT_VIDEOS
-- =====================================================

-- Inserir o Treino G de Musculação
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
    has_pdf_materials,
    created_at,
    updated_at
) VALUES (
    'Treino G',
    'Treino completo de musculação - Treino G com exercícios específicos para desenvolvimento muscular progressivo.',
    'https://youtu.be/EXEMPLO_TREINO_G', -- ⚠️ SUBSTITUA PELA URL REAL DO YOUTUBE
    'https://img.youtube.com/vi/EXEMPLO_TREINO_G/maxresdefault.jpg', -- ⚠️ SERÁ ATUALIZADA AUTOMATICAMENTE
    '50 min',
    50,
    'Intermediário',
    'Treinos de Musculação',
    'Musculação',
    16, -- Próximo order_index
    true,
    true,
    true,
    true, -- Tem PDF disponível
    NOW(),
    NOW()
);

-- =====================================================
-- PARTE 2: ASSOCIAR PDF NA TABELA MATERIALS
-- =====================================================

-- Inserir material PDF para o Treino G
INSERT INTO materials (
    title,
    description,
    material_type,
    material_context,
    file_path,
    author_name,
    workout_video_id,
    order_index,
    is_featured,
    requires_expert_access,
    created_at,
    updated_at
)
SELECT 
    'Manual Treino G - PDF',
    'Material de apoio completo para o Treino G de musculação com exercícios específicos e progressão.',
    'pdf',
    'workout',
    'musculacao/TREINO G.pdf',
    'Treinos de Musculação',
    wv.id,
    1,
    true,
    false,
    NOW(),
    NOW()
FROM workout_videos wv
WHERE wv.title = 'Treino G'
  AND (wv.category = 'Musculação' OR wv.instructor_name = 'Treinos de Musculação')
  AND wv.created_at >= NOW() - INTERVAL '1 minute' -- Apenas o que foi inserido agora
LIMIT 1;

-- =====================================================
-- PARTE 3: VERIFICAÇÕES
-- =====================================================

-- Verificar se o Treino G foi inserido corretamente
SELECT 
    id,
    title,
    youtube_url,
    category,
    instructor_name,
    difficulty,
    duration,
    has_pdf_materials,
    created_at
FROM workout_videos 
WHERE title = 'Treino G'
  AND instructor_name = 'Treinos de Musculação'
ORDER BY created_at DESC;

-- Verificar se o material PDF foi associado
SELECT 
    m.id,
    m.title,
    m.file_path,
    wv.title as workout_title,
    wv.instructor_name,
    m.created_at
FROM materials m
JOIN workout_videos wv ON m.workout_video_id = wv.id
WHERE wv.title = 'Treino G'
  AND wv.instructor_name = 'Treinos de Musculação'
  AND m.material_type = 'pdf'
ORDER BY m.created_at DESC;

-- Contagem total de treinos de musculação
SELECT 
    COUNT(*) as total_treinos_musculacao
FROM workout_videos 
WHERE category = 'Musculação' 
   OR instructor_name = 'Treinos de Musculação';

-- =====================================================
-- PARTE 4: ATUALIZAR CONTAGEM DA CATEGORIA
-- =====================================================

-- Atualizar contagem na categoria Musculação
UPDATE workout_categories 
SET workoutsCount = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = 'Musculação' 
       OR instructor_name = 'Treinos de Musculação'
)
WHERE LOWER(name) = 'musculação';

-- Verificar contagem atualizada
SELECT 
    name,
    workoutsCount,
    updated_at
FROM workout_categories 
WHERE LOWER(name) = 'musculação';

COMMIT;

-- =====================================================
-- INSTRUÇÕES PARA COMPLETAR A CONFIGURAÇÃO:
-- =====================================================

-- 1. ⚠️ AÇÃO NECESSÁRIA: Substitua 'EXEMPLO_TREINO_G' pela URL real do YouTube do Treino G
-- 
-- Exemplo de comando para atualizar:
-- UPDATE workout_videos 
-- SET youtube_url = 'https://youtu.be/SUA_URL_REAL_AQUI',
--     thumbnail_url = 'https://img.youtube.com/vi/SUA_URL_REAL_AQUI/maxresdefault.jpg'
-- WHERE title = 'Treino G' AND instructor_name = 'Treinos de Musculação';
--
-- 2. ✅ O PDF já está configurado: musculacao/TREINO G.pdf
-- 3. ✅ A home será atualizada automaticamente via HomeWorkoutProvider
-- 4. ✅ A tela de treinos mostrará o novo treino automaticamente 