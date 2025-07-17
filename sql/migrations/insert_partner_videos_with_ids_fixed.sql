-- Script corrigido para inserir vídeos dos parceiros
-- Corrige o problema de tipo de dados (category é varchar, não UUID)

-- 1. Limpar vídeos antigos dos parceiros (opcional)
DELETE FROM workout_videos 
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit');

-- 2. Inserir vídeos dos parceiros

-- MUSCULAÇÃO (ID: d2d2a9b8-d861-47c7-9d26-283539beda24)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES (
  'Apresentação', 
  '51 seg', 
  1, 
  'Iniciante', 
  'https://youtu.be/Ej0Tz0Ym5Ow', 
  'd2d2a9b8-d861-47c7-9d26-283539beda24',
  'Treinos de Musculação', 
  'Conheça nossos instrutores e metodologia', 
  1, 
  true
);

-- PILATES (ID: fe034f6d-aa79-436c-b0b7-7aea572f08c1)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES 
  ('Apresentação Pilates', '15 min', 15, 'Iniciante', 'https://youtu.be/nhD9ITCBTVU', 
   'fe034f6d-aa79-436c-b0b7-7aea572f08c1', 'Goya Health Club', 
   'Introdução aos benefícios e técnicas do Pilates', 1, true),
  ('Mobilidade', '25 min', 25, 'Iniciante', 'https://youtu.be/gDB5n3kSRqI', 
   'fe034f6d-aa79-436c-b0b7-7aea572f08c1', 'Goya Health Club', 
   'Pilates básico para iniciantes', 2, false);

-- FUNCIONAL (ID: 43eb2044-38cf-4193-848c-da46fd7e9cb4)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES 
  ('Apresentação Fight Fit', '12 min', 12, 'Iniciante', 'https://youtu.be/gcLeeRlqoFM', 
   '43eb2044-38cf-4193-848c-da46fd7e9cb4', 'Fight Fit', 
   'Conheça o conceito Fight Fit e seus benefícios', 1, true),
  ('Abdominal', '30 min', 30, 'Iniciante', 'https://youtu.be/RCywus6kVPk', 
   '43eb2044-38cf-4193-848c-da46fd7e9cb4', 'Fight Fit', 
   'Treino funcional básico com elementos de luta', 2, false),
  ('Técnica', '40 min', 40, 'Intermediário', 'https://youtu.be/t172SCu4QU0', 
   '43eb2044-38cf-4193-848c-da46fd7e9cb4', 'Fight Fit', 
   'Treino completo para todo o corpo', 3, false);

-- CORRIDA (ID: 07754890-b092-4386-be56-bb088a2a96f1)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES (
  'Apresentação', 
  '8 min', 
  8, 
  'Iniciante', 
  'https://youtu.be/E6xtScc3pYk', 
  '07754890-b092-4386-be56-bb088a2a96f1',
  'Bora Assessoria', 
  'Conheça a Bora Assessoria e metodologia de treino', 
  1, 
  true
);

-- FISIOTERAPIA (ID: da178dba-ae94-425a-aaed-133af7b1bb0f)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES (
  'Apresentação', 
  '10 min', 
  10, 
  'Iniciante', 
  'https://youtu.be/Q_dlMnGgIPo', 
  'da178dba-ae94-425a-aaed-133af7b1bb0f',
  'The Unit', 
  'Introdução à fisioterapia preventiva no esporte', 
  1, 
  true
);

-- 3. Marcar vídeos como novos e populares
UPDATE workout_videos SET is_new = true 
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit');

UPDATE workout_videos SET is_popular = true 
WHERE is_recommended = true 
AND instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit');

-- 4. Atualizar contagem de vídeos por categoria
-- Corrigido: fazendo cast do id para varchar para comparar com category
UPDATE workout_categories 
SET "workoutsCount" = (
  SELECT COUNT(*) FROM workout_videos WHERE category = workout_categories.id::varchar
)
WHERE id IN (
  'd2d2a9b8-d861-47c7-9d26-283539beda24'::uuid, -- Musculação
  'fe034f6d-aa79-436c-b0b7-7aea572f08c1'::uuid, -- Pilates
  '43eb2044-38cf-4193-848c-da46fd7e9cb4'::uuid, -- Funcional
  '07754890-b092-4386-be56-bb088a2a96f1'::uuid, -- Corrida
  'da178dba-ae94-425a-aaed-133af7b1bb0f'::uuid  -- Fisioterapia
);

-- 5. Verificar resultado final
-- Corrigido: fazendo cast do id para varchar para comparar com category
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

-- 6. Verificar vídeos inseridos
SELECT 
  wv.title,
  wv.instructor_name,
  wc.name as category_name
FROM workout_videos wv
JOIN workout_categories wc ON wv.category = wc.id::varchar
WHERE wv.instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
ORDER BY wc.name, wv.order_index; 