-- Inserir os novos vídeos: Treino B, C e D
-- Vídeos do canal "Treinos de Musculação"

-- Primeiro, vamos buscar o ID da categoria Musculação
-- Assumindo que ela já existe no banco

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
    videos.title,
    videos.duration,
    videos.duration_minutes,
    videos.difficulty,
    videos.youtube_url,
    videos.thumbnail_url,
    (SELECT id FROM workout_categories WHERE LOWER(name) = 'musculação' LIMIT 1),
    videos.instructor_name,
    videos.description,
    videos.order_index,
    videos.is_recommended,
    videos.is_new,
    videos.is_popular
FROM (
    VALUES 
    -- Treino B
    (
        'Treino B - Musculação', 
        '45 min', 
        45, 
        'Intermediário', 
        'https://youtu.be/2E8sn_7uzo4', 
        'https://img.youtube.com/vi/2E8sn_7uzo4/maxresdefault.jpg',
        'Treinos de Musculação', 
        'Treino B completo de musculação - Sequência progressiva para desenvolvimento muscular', 
        10, 
        true,
        true,
        true
    ),
    -- Treino C  
    (
        'Treino C - Musculação', 
        '50 min', 
        50, 
        'Intermediário', 
        'https://youtu.be/pBPJMkU5dUI', 
        'https://img.youtube.com/vi/pBPJMkU5dUI/maxresdefault.jpg',
        'Treinos de Musculação', 
        'Treino C completo de musculação - Foco em hipertrofia e força', 
        11, 
        true,
        true,
        true
    ),
    -- Treino D
    (
        'Treino D - Musculação', 
        '55 min', 
        55, 
        'Avançado', 
        'https://youtu.be/_XtunUnkn9s', 
        'https://img.youtube.com/vi/_XtunUnkn9s/maxresdefault.jpg',
        'Treinos de Musculação', 
        'Treino D avançado de musculação - Desafie seus limites com técnicas avançadas', 
        12, 
        true,
        true,
        true
    )
) AS videos(
    title, duration, duration_minutes, difficulty, youtube_url, thumbnail_url,
    instructor_name, description, order_index, is_recommended, is_new, is_popular
)
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'musculação');

-- Atualizar contagem de vídeos na categoria Musculação
UPDATE workout_categories 
SET workoutsCount = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category = (SELECT id FROM workout_categories WHERE LOWER(name) = 'musculação' LIMIT 1)
)
WHERE LOWER(name) = 'musculação';

-- Verificar se os vídeos foram inseridos corretamente
SELECT 
    wv.title,
    wv.duration,
    wv.youtube_url,
    wv.thumbnail_url,
    wv.instructor_name,
    wc.name as categoria
FROM workout_videos wv
JOIN workout_categories wc ON wv.category = wc.id
WHERE wv.instructor_name = 'Treinos de Musculação'
ORDER BY wv.order_index; 