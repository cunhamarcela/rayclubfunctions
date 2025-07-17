-- Script para inserir vídeos dos parceiros
-- Usa os IDs das categorias que já existem no banco

-- 1. Limpar vídeos antigos dos parceiros (opcional)
-- DELETE FROM workout_videos WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit');

-- 2. Inserir vídeos dos parceiros

-- TREINOS DE MUSCULAÇÃO
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES (
  'Apresentação', 
  '51 seg', 
  1, 
  'Iniciante', 
  'https://youtu.be/Ej0Tz0Ym5Ow', 
  'd2d2a9b8-d861-47c7-9d26-283539beda24', -- ID da categoria Musculação
  'Treinos de Musculação', 
  'Conheça nossos instrutores e metodologia', 
  1, 
  true
);

-- GOYA HEALTH CLUB (PILATES) - Precisamos do ID da categoria Pilates primeiro
-- Se Pilates foi criada, use o ID retornado. Por enquanto, vamos usar uma subquery
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação Pilates', 
  '15 min', 
  15, 
  'Iniciante', 
  'https://youtu.be/nhD9ITCBTVU', 
  id,
  'Goya Health Club', 
  'Introdução aos benefícios e técnicas do Pilates', 
  1, 
  true
FROM workout_categories WHERE LOWER(name) = 'pilates';

INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Mobilidade', 
  '25 min', 
  25, 
  'Iniciante', 
  'https://youtu.be/gDB5n3kSRqI', 
  id,
  'Goya Health Club', 
  'Pilates básico para iniciantes', 
  2, 
  false
FROM workout_categories WHERE LOWER(name) = 'pilates';

-- FIGHT FIT (FUNCIONAL)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação Fight Fit', 
  '12 min', 
  12, 
  'Iniciante', 
  'https://youtu.be/gcLeeRlqoFM', 
  id,
  'Fight Fit', 
  'Conheça o conceito Fight Fit e seus benefícios', 
  1, 
  true
FROM workout_categories WHERE LOWER(name) = 'funcional';

INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Abdominal', 
  '30 min', 
  30, 
  'Iniciante', 
  'https://youtu.be/RCywus6kVPk', 
  id,
  'Fight Fit', 
  'Treino funcional básico com elementos de luta', 
  2, 
  false
FROM workout_categories WHERE LOWER(name) = 'funcional';

INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Técnica', 
  '40 min', 
  40, 
  'Intermediário', 
  'https://youtu.be/t172SCu4QU0', 
  id,
  'Fight Fit', 
  'Treino completo para todo o corpo', 
  3, 
  false
FROM workout_categories WHERE LOWER(name) = 'funcional';

-- BORA ASSESSORIA (CORRIDA)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação', 
  '8 min', 
  8, 
  'Iniciante', 
  'https://youtu.be/E6xtScc3pYk', 
  id,
  'Bora Assessoria', 
  'Conheça a Bora Assessoria e metodologia de treino', 
  1, 
  true
FROM workout_categories WHERE LOWER(name) = 'corrida';

-- THE UNIT (FISIOTERAPIA)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação', 
  '10 min', 
  10, 
  'Iniciante', 
  'https://youtu.be/Q_dlMnGgIPo', 
  id,
  'The Unit', 
  'Introdução à fisioterapia preventiva no esporte', 
  1, 
  true
FROM workout_categories WHERE LOWER(name) = 'fisioterapia';

-- 3. Marcar vídeos como novos e populares
UPDATE workout_videos SET is_new = true WHERE created_at > NOW() - INTERVAL '30 days';
UPDATE workout_videos SET is_popular = true WHERE is_recommended = true;

-- 4. Atualizar contagem de vídeos por categoria
UPDATE workout_categories wc
SET "workoutsCount" = (
  SELECT COUNT(*) 
  FROM workout_videos wv 
  WHERE wv.category = wc.id
);

-- 5. Verificar vídeos inseridos
SELECT 
  wv.title,
  wv.instructor_name,
  wc.name as category_name
FROM workout_videos wv
JOIN workout_categories wc ON wc.id = wv.category
WHERE wv.instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit')
ORDER BY wc.name, wv.order_index; 