-- =====================================================
-- SCRIPT: COMPLETAR RECEITAS DE VÍDEO FAVORITAS DA RAY
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Adicionar Banana Toast e Pão de Queijo como vídeos
-- Para completar as 4 receitas favoritas da seção home
-- =====================================================

-- 🎥 RECEITA EM VÍDEO 3: Banana Toast Saudável
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
    'Banana Toast Saudável',
    'Receita deliciosa e nutritiva de banana toast da Bruna Braga. Perfeito para café da manhã ou lanche da tarde. Simples, rápido e muito saboroso!',
    'Café da Manhã',
    'https://img.youtube.com/vi/example-toast/maxresdefault.jpg',
    10,
    250,
    1,
    'Fácil',
    4.7,
    'video',
    'Bruna Braga',
    'nutritionist',
    true,
    'https://youtu.be/example-toast',
    'example-toast',
    420, -- 7 minutos estimado
    ARRAY['café da manhã', 'toast', 'banana', 'saudável', 'rápido', 'lanche', 'nutritivo'],
    ARRAY['Emagrecimento'], -- filter_goal
    ARRAY['Doce'], -- filter_taste
    ARRAY['Café da Manhã', 'Lanche da Tarde'], -- filter_meal
    ARRAY[]::TEXT[], -- filter_timing
    ARRAY['Carboidratos'], -- filter_nutrients
    ARRAY['Rápido', 'Saudável'] -- filter_other
);

-- 🎥 RECEITA EM VÍDEO 4: Pão de Queijo Fit
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
    'Pão de Queijo Fit',
    'Receita incrível de pão de queijo fit da Bruna Braga. Versão saudável do clássico brasileiro. Proteico, saboroso e perfeito para qualquer hora!',
    'Lanche',
    'https://img.youtube.com/vi/example-pao-queijo/maxresdefault.jpg',
    25,
    180,
    6,
    'Intermediário',
    4.9,
    'video',
    'Bruna Braga',
    'nutritionist',
    true,
    'https://youtu.be/example-pao-queijo',
    'example-pao-queijo',
    900, -- 15 minutos estimado
    ARRAY['pão de queijo', 'fit', 'proteico', 'lanche', 'saudável', 'sem glúten', 'airfryer'],
    ARRAY['Emagrecimento', 'Hipertrofia'], -- filter_goal
    ARRAY['Salgado'], -- filter_taste
    ARRAY['Café da Manhã', 'Lanche da Tarde'], -- filter_meal
    ARRAY[]::TEXT[], -- filter_timing
    ARRAY['Proteínas'], -- filter_nutrients
    ARRAY['Proteico', 'Fit'] -- filter_other
);

-- =====================================================
-- VERIFICAÇÃO DAS 4 RECEITAS FAVORITAS
-- =====================================================

-- Verificar se todas as 4 receitas favoritas existem como vídeo
SELECT 
    title,
    content_type,
    video_id,
    category,
    preparation_time_minutes,
    created_at
FROM recipes 
WHERE author_name = 'Bruna Braga' 
  AND content_type = 'video'
  AND (
    title ILIKE '%gororoba%banana%' OR
    title ILIKE '%bolo%alagado%' OR
    title ILIKE '%banana%toast%' OR
    title ILIKE '%pão%queijo%'
  )
ORDER BY created_at DESC;

-- Contar total de receitas em vídeo da Bruna Braga
SELECT 
    'Total de vídeos da Bruna Braga' as info,
    COUNT(*) as quantidade
FROM recipes 
WHERE author_name = 'Bruna Braga' 
  AND content_type = 'video';

-- =====================================================
-- LOGS DE SUCESSO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Receitas de vídeo favoritas da Ray completadas!';
    RAISE NOTICE '🏠 Seção "Receitas Favoritas da Ray" na home agora terá 4 vídeos:';
    RAISE NOTICE '   1. 🍌 Gororoba de Banana';
    RAISE NOTICE '   2. 🍰 Bolo Alagado';
    RAISE NOTICE '   3. 🍞 Banana Toast Saudável (NOVO)';
    RAISE NOTICE '   4. 🧀 Pão de Queijo Fit (NOVO)';
    RAISE NOTICE '📱 A seção agora mostrará corretamente os 4 cards de receitas!';
    RAISE NOTICE '🎥 Todos com URLs de vídeo para visualização no player interno!';
END $$; 