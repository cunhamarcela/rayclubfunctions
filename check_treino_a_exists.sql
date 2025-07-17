-- Verificar se já existe um vídeo com título "Treino A"
SELECT id, title, video_url, category, created_at 
FROM workout_videos 
WHERE title = 'Treino A';

-- Verificar todos os vídeos de musculação
SELECT id, title, video_url, duration, difficulty, is_new, is_popular
FROM workout_videos 
WHERE category = 'd2d2a9b8-d861-47c7-9d26-283539beda24'::varchar
ORDER BY created_at DESC; 