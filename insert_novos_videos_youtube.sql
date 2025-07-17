-- Script para inserir os novos vídeos do YouTube nas categorias corretas
-- Conforme solicitado no documento anexo

-- ============================================================================
-- PARTE 1: VÍDEOS DE TREINO (workout_videos)
-- ============================================================================

-- 1. PILATES - Goya Health Club
INSERT INTO workout_videos (
    title, 
    duration, 
    duration_minutes, 
    difficulty, 
    youtube_url, 
    thumbnail_url,
    category, 
    instructor_name, 
    description, 
    order_index, 
    is_recommended,
    is_new,
    is_popular
)
SELECT 
    'Pilates Goyá Full body com caneleiras',
    '45 min',
    45,
    'Intermediário',
    'https://youtu.be/4rOQ2wbHnVU',
    'https://img.youtube.com/vi/4rOQ2wbHnVU/maxresdefault.jpg',
    (SELECT id FROM workout_categories WHERE LOWER(name) = 'pilates' LIMIT 1),
    'Goya Health Club',
    'Treino completo de Pilates com caneleiras para fortalecimento e tonificação',
    10,
    true,
    true,
    true
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'pilates');

-- 2. MUSCULAÇÃO - Treino E
INSERT INTO workout_videos (
    title, 
    duration, 
    duration_minutes, 
    difficulty, 
    youtube_url, 
    thumbnail_url,
    category, 
    instructor_name, 
    description, 
    order_index, 
    is_recommended,
    is_new,
    is_popular
)
VALUES (
    'Musculação - Treino E',
    '55 min',
    55,
    'Avançado',
    'https://youtu.be/9DuQ5lBul3k',
    'https://img.youtube.com/vi/9DuQ5lBul3k/maxresdefault.jpg',
    'd2d2a9b8-d861-47c7-9d26-283539beda24', -- ID da categoria Musculação
    'Treinos de Musculação',
    'Treino E avançado de musculação - Sequência avançada para desenvolvimento muscular',
    15,
    true,
    true,
    true
);

-- 3. FIGHT FIT - Técnica
INSERT INTO workout_videos (
    title, 
    duration, 
    duration_minutes, 
    difficulty, 
    youtube_url, 
    thumbnail_url,
    category, 
    instructor_name, 
    description, 
    order_index, 
    is_recommended,
    is_new,
    is_popular
)
SELECT 
    'FightFit - Técnica',
    '40 min',
    40,
    'Intermediário',
    'https://youtu.be/t172SCu4QU0',
    'https://img.youtube.com/vi/t172SCu4QU0/maxresdefault.jpg',
    (SELECT id FROM workout_categories WHERE LOWER(name) = 'funcional' LIMIT 1),
    'Fight Fit',
    'Treino técnico do FightFit focado em aperfeiçoamento de movimentos',
    4,
    true,
    true,
    true
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'funcional');

-- ============================================================================
-- PARTE 2: VÍDEOS DE NUTRIÇÃO (recipes) - APENAS VÍDEOS
-- ============================================================================

-- 4. NUTRIÇÃO - Pão de queijo
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
    nutritionist_tip,
    tags,
    nutritional_info,
    filter_goal,
    filter_taste,
    filter_meal,
    filter_timing,
    filter_nutrients,
    filter_other
) VALUES (
    'Pão de Queijo Fit',
    'Receita saudável de pão de queijo - Assista ao vídeo para aprender',
    'Lanches',
    'https://img.youtube.com/vi/VBBILcu5DH8/maxresdefault.jpg',
    30,
    120,
    8,
    'Fácil',
    4.8,
    'video',
    'Bruna Braga',
    'nutritionist',
    true,
    'https://youtu.be/VBBILcu5DH8',
    'VBBILcu5DH8',
    1800, -- 30 minutos em segundos
    'Assista ao vídeo para aprender a fazer esta versão saudável!',
    ARRAY['pão de queijo', 'fit', 'lanche saudável'],
    '{"Proteínas": "8g", "Carboidratos": "18g", "Gorduras": "6g", "Fibras": "2g"}'::jsonb,
    ARRAY['Emagrecimento'],
    ARRAY['Salgado'],
    ARRAY['Café da Manhã', 'Lanche da Tarde'],
    ARRAY[]::TEXT[],
    ARRAY['Carboidratos', 'Proteínas'],
    ARRAY[]::TEXT[]
);

-- 5. NUTRIÇÃO - Banana toast
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
    nutritionist_tip,
    tags,
    nutritional_info,
    filter_goal,
    filter_taste,
    filter_meal,
    filter_timing,
    filter_nutrients,
    filter_other
) VALUES (
    'Banana Toast Saudável',
    'Toast nutritivo com banana - Assista ao vídeo para aprender',
    'Café da Manhã',
    'https://img.youtube.com/vi/nN4d1jraU20/maxresdefault.jpg',
    10,
    220,
    1,
    'Fácil',
    4.9,
    'video',
    'Bruna Braga',
    'nutritionist',
    true,
    'https://youtu.be/nN4d1jraU20',
    'nN4d1jraU20',
    600, -- 10 minutos em segundos
    'Assista ao vídeo para aprender esta combinação perfeita!',
    ARRAY['banana toast', 'café da manhã', 'rápido'],
    '{"Proteínas": "8g", "Carboidratos": "35g", "Gorduras": "8g", "Fibras": "5g"}'::jsonb,
    ARRAY['Emagrecimento', 'Hipertrofia'],
    ARRAY['Doce'],
    ARRAY['Café da Manhã'],
    ARRAY['Pré treino'],
    ARRAY['Carboidratos', 'Proteínas'],
    ARRAY[]::TEXT[]
);

-- ============================================================================
-- PARTE 3: ATUALIZAÇÕES FINAIS
-- ============================================================================

-- Atualizar contagem de vídeos por categoria de treino
UPDATE workout_categories wc
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos wv 
    WHERE wv.category = wc.id
)
WHERE wc.id IN (
    SELECT DISTINCT category 
    FROM workout_videos 
    WHERE youtube_url IN (
        'https://youtu.be/4rOQ2wbHnVU',
        'https://youtu.be/9DuQ5lBul3k', 
        'https://youtu.be/t172SCu4QU0'
    )
);

-- Verificar se os vídeos foram inseridos corretamente
SELECT 
    'TREINOS' as tipo,
    wv.title,
    wv.duration,
    wv.youtube_url,
    wv.instructor_name,
    wc.name as categoria
FROM workout_videos wv
JOIN workout_categories wc ON wv.category = wc.id
WHERE wv.youtube_url IN (
    'https://youtu.be/4rOQ2wbHnVU',
    'https://youtu.be/9DuQ5lBul3k', 
    'https://youtu.be/t172SCu4QU0'
)

UNION ALL

SELECT 
    'RECEITAS' as tipo,
    r.title,
    CONCAT(r.preparation_time_minutes::text, ' min') as duration,
    r.video_url,
    r.author_name as instructor_name,
    r.category as categoria
FROM recipes r
WHERE r.video_url IN (
    'https://youtu.be/VBBILcu5DH8',
    'https://youtu.be/nN4d1jraU20'
)
ORDER BY tipo, title; 