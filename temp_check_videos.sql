-- Verificar vídeos de fisioterapia por subcategoria
SELECT 
    title,
    subcategory,
    order_index,
    CASE 
        WHEN title ILIKE '%mobilidade%' THEN 'deveria ser: mobilidade'
        WHEN title ILIKE '%teste%' THEN 'deveria ser: testes'
        WHEN title ILIKE '%estabilidade%' THEN 'deveria ser: estabilidade'
        ELSE 'categoria ok'
    END as categoria_correta
FROM workout_videos 
WHERE category = 'da178dba-ae94-425a-aaed-133af7b1bb0f' -- Fisioterapia
  AND (title ILIKE '%mobilidade%' OR title ILIKE '%teste%')
ORDER BY subcategory, order_index;
