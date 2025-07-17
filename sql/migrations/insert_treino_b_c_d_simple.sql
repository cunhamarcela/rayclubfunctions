-- Script SUPER SIMPLES para inserir apenas os vídeos
-- Treino B, C e D

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
) VALUES 
-- Treino B
(
    'Treino B - Musculação', 
    '45 min', 
    45, 
    'Intermediário', 
    'https://youtu.be/2E8sn_7uzo4', 
    'https://img.youtube.com/vi/2E8sn_7uzo4/maxresdefault.jpg',
    'Musculação',
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
    'Musculação',
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
    'Musculação',
    'Treinos de Musculação', 
    'Treino D avançado de musculação - Desafie seus limites com técnicas avançadas', 
    12, 
    true,
    true,
    true
);

-- Verificar se foram inseridos
SELECT 
    title,
    duration,
    youtube_url,
    instructor_name,
    category
FROM workout_videos 
WHERE instructor_name = 'Treinos de Musculação'
ORDER BY order_index; 