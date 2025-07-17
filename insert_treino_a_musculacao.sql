-- Inserir Treino A de Musculação
INSERT INTO workout_videos (
    title,
    description,
    video_url,
    thumbnail_url,
    duration,
    difficulty,
    category,
    instructor,
    is_new,
    is_popular,
    created_at,
    updated_at
) VALUES (
    'Treino A',
    'Primeira semana de treinos de musculação para iniciantes',
    'https://youtu.be/Tb5IqAAJyD8',
    'https://img.youtube.com/vi/Tb5IqAAJyD8/maxresdefault.jpg',
    45, -- 45 minutos
    'Iniciante',
    'd2d2a9b8-d861-47c7-9d26-283539beda24'::varchar, -- ID da categoria Musculação
    'Treinos de Musculação',
    true, -- é novo
    true, -- é popular
    NOW(),
    NOW()
);

-- Atualizar contador de vídeos na categoria
UPDATE workout_categories 
SET "workoutsCount" = "workoutsCount" + 1
WHERE id = 'd2d2a9b8-d861-47c7-9d26-283539beda24';

-- Verificar se foi inserido
SELECT * FROM workout_videos 
WHERE category = 'd2d2a9b8-d861-47c7-9d26-283539beda24'::varchar
ORDER BY created_at DESC;

-- Verificar contador atualizado
SELECT id, name, "workoutsCount" 
FROM workout_categories 
WHERE id = 'd2d2a9b8-d861-47c7-9d26-283539beda24'; 