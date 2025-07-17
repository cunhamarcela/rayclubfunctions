-- Script para atualizar contagens e verificar resultado
-- Use após inserir os vídeos

-- 1. Atualizar contagem de vídeos por categoria
-- Fazendo cast do id (UUID) para varchar para comparar com category (varchar)
UPDATE workout_categories 
SET "workoutsCount" = (
  SELECT COUNT(*) 
  FROM workout_videos 
  WHERE category = workout_categories.id::varchar
)
WHERE id IN (
  'd2d2a9b8-d861-47c7-9d26-283539beda24'::uuid, -- Musculação
  'fe034f6d-aa79-436c-b0b7-7aea572f08c1'::uuid, -- Pilates
  '43eb2044-38cf-4193-848c-da46fd7e9cb4'::uuid, -- Funcional
  '07754890-b092-4386-be56-bb088a2a96f1'::uuid, -- Corrida
  'da178dba-ae94-425a-aaed-133af7b1bb0f'::uuid  -- Fisioterapia
);

-- 2. Verificar resultado final
SELECT 
  wc.name as categoria,
  wc."workoutsCount" as total_videos,
  COUNT(wv.id) as videos_inseridos
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id::varchar
WHERE wc.id IN (
  'd2d2a9b8-d861-47c7-9d26-283539beda24'::uuid,
  'fe034f6d-aa79-436c-b0b7-7aea572f08c1'::uuid,
  '43eb2044-38cf-4193-848c-da46fd7e9cb4'::uuid,
  '07754890-b092-4386-be56-bb088a2a96f1'::uuid,
  'da178dba-ae94-425a-aaed-133af7b1bb0f'::uuid
)
GROUP BY wc.id, wc.name, wc."workoutsCount"
ORDER BY wc.name;

-- 3. Listar todos os vídeos dos parceiros
SELECT 
  wv.title,
  wv.instructor_name,
  wv.duration,
  wv.difficulty,
  wc.name as category_name
FROM workout_videos wv
JOIN workout_categories wc ON wv.category = wc.id::varchar
WHERE wv.instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
ORDER BY wc.name, wv.order_index; 