-- Script para remover categorias duplicadas e indesejadas
-- Remove: Cardio, Yoga, HIIT conforme solicitado

-- 1. Primeiro, vamos verificar quais categorias existem atualmente
SELECT id, name, "workoutsCount", order_index 
FROM workout_categories 
ORDER BY order_index;

-- 2. Backup dos dados que serão removidos (para recuperação se necessário)
CREATE TABLE IF NOT EXISTS workout_categories_backup AS 
SELECT * FROM workout_categories 
WHERE LOWER(name) IN ('cardio', 'yoga', 'hiit');

-- 3. Backup dos vídeos associados às categorias que serão removidas
CREATE TABLE IF NOT EXISTS workout_videos_backup AS 
SELECT wv.* FROM workout_videos wv
JOIN workout_categories wc ON wv.category::uuid = wc.id
WHERE LOWER(wc.name) IN ('cardio', 'yoga', 'hiit');

-- 4. Remover vídeos associados às categorias que serão deletadas
DELETE FROM workout_videos 
WHERE category::uuid IN (
    SELECT id FROM workout_categories 
    WHERE LOWER(name) IN ('cardio', 'yoga', 'hiit')
);

-- 5. Remover as categorias indesejadas
DELETE FROM workout_categories 
WHERE LOWER(name) IN ('cardio', 'yoga', 'hiit');

-- 6. Reorganizar a ordem das categorias restantes
UPDATE workout_categories SET order_index = 1 WHERE LOWER(name) = 'musculação';
UPDATE workout_categories SET order_index = 2 WHERE LOWER(name) = 'funcional';
UPDATE workout_categories SET order_index = 3 WHERE LOWER(name) = 'pilates';
UPDATE workout_categories SET order_index = 4 WHERE LOWER(name) = 'força';
UPDATE workout_categories SET order_index = 5 WHERE LOWER(name) = 'flexibilidade';
UPDATE workout_categories SET order_index = 6 WHERE LOWER(name) = 'corrida';
UPDATE workout_categories SET order_index = 7 WHERE LOWER(name) = 'fisioterapia';
UPDATE workout_categories SET order_index = 8 WHERE LOWER(name) = 'alongamento';

-- 7. Verificar resultado final
SELECT id, name, "workoutsCount", order_index 
FROM workout_categories 
ORDER BY order_index;

-- 8. Atualizar contadores de vídeos para as categorias restantes
UPDATE workout_categories 
SET "workoutsCount" = (
    SELECT COUNT(*) 
    FROM workout_videos 
    WHERE category::uuid = workout_categories.id
);

-- 9. Verificação final com contadores atualizados
SELECT 
    wc.name,
    wc."workoutsCount",
    wc.order_index,
    COUNT(wv.id) as videos_reais
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category::uuid = wc.id
GROUP BY wc.id, wc.name, wc."workoutsCount", wc.order_index
ORDER BY wc.order_index;

COMMIT; 