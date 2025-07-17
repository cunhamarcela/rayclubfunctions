-- Script corrigido para inserir os vídeos: Treino B, C e D
-- Correção: usando o nome da categoria ao invés do ID

-- Verificar se a categoria Musculação existe
-- Se não existir, criar
INSERT INTO workout_categories (name, description, workoutsCount, order_index)
VALUES ('Musculação', 'Treinos de força e hipertrofia', 0, 1)
ON CONFLICT (name) DO NOTHING;

-- Inserir os novos vídeos usando o NOME da categoria
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
    'Musculação',  -- Usando o nome da categoria diretamente
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
    'Musculação',  -- Usando o nome da categoria diretamente
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
    'Musculação',  -- Usando o nome da categoria diretamente
    'Treinos de Musculação', 
    'Treino D avançado de musculação - Desafie seus limites com técnicas avançadas', 
    12, 
    true,
    true,
    true
);

-- Atualizar contagem de vídeos na categoria Musculação
UPDATE workout_categories 
SET workoutsCount = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE LOWER(category) = 'musculação'
)
WHERE LOWER(name) = 'musculação';

-- Verificar se os vídeos foram inseridos corretamente
SELECT 
    wv.title,
    wv.duration,
    wv.youtube_url,
    wv.thumbnail_url,
    wv.instructor_name,
    wv.category
FROM workout_videos wv
WHERE wv.instructor_name = 'Treinos de Musculação'
ORDER BY wv.order_index; 