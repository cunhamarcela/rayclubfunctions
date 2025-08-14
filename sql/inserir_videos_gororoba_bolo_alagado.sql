-- =====================================================
-- SCRIPT: INSERIR VÍDEOS QUE SUMIRAM DA NUTRIÇÃO
-- =====================================================
-- Data: 2025-01-21
-- Objetivo: Adicionar "Gororoba de Banana" e "Bolo Alagado" 
-- URLs: 
--   - Gororoba de Banana: https://youtu.be/juZFOCjSJ8I
--   - Bolo Alagado: https://youtu.be/3uvh72H2uYM
-- =====================================================

-- VERIFICAR SE OS VÍDEOS JÁ EXISTEM
SELECT 
    title, 
    video_id, 
    video_url, 
    content_type,
    author_name,
    created_at
FROM recipes 
WHERE content_type = 'video' 
  AND (title ILIKE '%gororoba%banana%' OR title ILIKE '%bolo%alagado%');

-- DELETAR SE EXISTEM (para evitar duplicatas)
DELETE FROM recipes 
WHERE content_type = 'video' 
  AND (title ILIKE '%gororoba%banana%' OR title ILIKE '%bolo%alagado%');

-- =====================================================
-- INSERIR OS VÍDEOS
-- =====================================================

-- 🎥 VÍDEO 1: Bolo Alagado
INSERT INTO recipes (
    title,
    description,
    category,
    image_url,
    preparation_time_minutes,
    calories,
    servings,
    difficulty,
    rating,
    content_type,
    author_name,
    author_type,
    is_featured,
    video_url,
    video_id,
    video_duration,
    tags,
    filter_goal,
    filter_taste,
    filter_meal,
    filter_timing,
    filter_nutrients,
    filter_other
) VALUES (
    'Bolo Alagado',
    'Uma receita especial de bolo alagado da Bruna Braga. Delicioso, macio e perfeito para qualquer ocasião. Aprenda o passo a passo neste vídeo! ✨',
    'Sobremesa',
    'https://img.youtube.com/vi/3uvh72H2uYM/maxresdefault.jpg',
    45,
    320,
    8,
    'Intermediário',
    5.0,
    'video',
    'Bruna Braga',
    'nutritionist',
    true,
    'https://youtu.be/3uvh72H2uYM',
    '3uvh72H2uYM',
    900, -- 15 minutos estimado
    ARRAY['sobremesa', 'bolo', 'doce', 'especial', 'festa', 'alagado'],
    ARRAY['Emagrecimento']::TEXT[], -- filter_goal
    ARRAY['Doce'], -- filter_taste
    ARRAY['Sobremesa'], -- filter_meal
    ARRAY[]::TEXT[], -- filter_timing
    ARRAY['Carboidratos'], -- filter_nutrients
    ARRAY['Especial'] -- filter_other
);

-- 🎥 VÍDEO 2: Gororoba de Banana  
INSERT INTO recipes (
    title,
    description,
    category,
    image_url,
    preparation_time_minutes,
    calories,
    servings,
    difficulty,
    rating,
    content_type,
    author_name,
    author_type,
    is_featured,
    video_url,
    video_id,
    video_duration,
    tags,
    filter_goal,
    filter_taste,
    filter_meal,
    filter_timing,
    filter_nutrients,
    filter_other
) VALUES (
    'Gororoba de Banana',
    'Receita nutritiva e deliciosa de gororoba de banana da Bruna Braga. Perfeita para um lanche saudável e energético. Fácil de fazer e super saborosa! 🍌',
    'Lanche',
    'https://img.youtube.com/vi/juZFOCjSJ8I/maxresdefault.jpg',
    15,
    280,
    2,
    'Fácil',
    4.8,
    'video',
    'Bruna Braga',
    'nutritionist',
    true,
    'https://youtu.be/juZFOCjSJ8I',
    'juZFOCjSJ8I',
    600, -- 10 minutos estimado
    ARRAY['gororoba', 'banana', 'lanche', 'saudável', 'energético', 'proteico'],
    ARRAY['Emagrecimento', 'Hipertrofia']::TEXT[], -- filter_goal
    ARRAY['Doce'], -- filter_taste
    ARRAY['Lanche da Tarde', 'Café da Manhã'], -- filter_meal
    ARRAY['Pré treino']::TEXT[], -- filter_timing
    ARRAY['Proteínas', 'Carboidratos'], -- filter_nutrients
    ARRAY['Proteico', 'Rápido'] -- filter_other
);

-- =====================================================
-- VERIFICAR SE FORAM INSERIDOS CORRETAMENTE
-- =====================================================

SELECT 
    '✅ VÍDEOS INSERIDOS COM SUCESSO!' as status,
    title,
    video_id,
    video_url,
    content_type,
    author_name,
    is_featured,
    category,
    preparation_time_minutes,
    created_at
FROM recipes 
WHERE content_type = 'video' 
  AND (title ILIKE '%gororoba%banana%' OR title ILIKE '%bolo%alagado%')
ORDER BY title;

-- CONTAR TOTAL DE VÍDEOS DE RECEITAS
SELECT 
    'Total de vídeos de receitas:' as info,
    COUNT(*) as total
FROM recipes 
WHERE content_type = 'video' AND author_type = 'nutritionist'; 