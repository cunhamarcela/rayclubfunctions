-- =====================================================
-- SCRIPT: INSERÇÃO DE VÍDEOS DE RECEITAS DA BRUNA BRAGA
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Inserir vídeos de receitas reais da Bruna Braga na tabela recipes
-- =====================================================

-- 🎥 RECEITA EM VÍDEO 1: Bolo Alagado
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
    'Uma receita especial de bolo alagado da Bruna Braga. Delicioso, macio e perfeito para qualquer ocasião. Aprenda o passo a passo neste vídeo!',
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
    ARRAY[]::TEXT[], -- filter_goal
    ARRAY['Doce'], -- filter_taste
    ARRAY['Sobremesa'], -- filter_meal
    ARRAY[]::TEXT[], -- filter_timing
    ARRAY['Carboidratos'], -- filter_nutrients
    ARRAY['Especial'] -- filter_other
);

-- 🎥 RECEITA EM VÍDEO 2: Gororoba De Banana
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
    'Gororoba De Banana',
    'Receita nutritiva e deliciosa de gororoba de banana da Bruna Braga. Perfeita para um lanche saudável e energético. Fácil de fazer e super saborosa!',
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
    ARRAY['lanche', 'banana', 'saudável', 'energético', 'rápido', 'gororoba', 'fruta'],
    ARRAY['Emagrecimento'], -- filter_goal
    ARRAY['Doce'], -- filter_taste
    ARRAY['Lanche da Tarde'], -- filter_meal
    ARRAY[]::TEXT[], -- filter_timing
    ARRAY['Carboidratos'], -- filter_nutrients
    ARRAY['Rápido', 'Saudável'] -- filter_other
);

-- =====================================================
-- VERIFICAÇÃO DE INSERÇÃO
-- =====================================================

-- Verificar se os vídeos de receitas foram inseridos corretamente
SELECT 
    title,
    content_type,
    video_id,
    category,
    author_name,
    author_type,
    is_featured,
    created_at
FROM recipes 
WHERE author_name = 'Bruna Braga' 
  AND content_type = 'video'
  AND title IN ('Bolo Alagado', 'Gororoba De Banana')
ORDER BY created_at DESC;

-- Contar total de receitas em vídeo da Bruna Braga
SELECT 
    content_type,
    COUNT(*) as total_recipes
FROM recipes 
WHERE author_name = 'Bruna Braga' 
  AND content_type = 'video'
GROUP BY content_type;

-- Contar todas as receitas da Bruna Braga por tipo
SELECT 
    content_type,
    COUNT(*) as total
FROM recipes 
WHERE author_name = 'Bruna Braga'
GROUP BY content_type
ORDER BY content_type;

-- =====================================================
-- MENSAGEM DE SUCESSO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Vídeos de receitas da Bruna Braga inseridos com sucesso!';
    RAISE NOTICE '📱 Aparecerão na aba "Vídeos" da tela de nutrição';
    RAISE NOTICE '🎥 Receitas adicionadas:';
    RAISE NOTICE '   1. 🍰 Bolo Alagado (3uvh72H2uYM) - Sobremesa, preparo: 45min';
    RAISE NOTICE '   2. 🍌 Gororoba De Banana (juZFOCjSJ8I) - Lanche, preparo: 15min';
    RAISE NOTICE '📺 Os usuários poderão assistir as receitas diretamente no app!';
    RAISE NOTICE '🍽️ Receitas reais da Bruna Braga em formato de vídeo';
END $$; 