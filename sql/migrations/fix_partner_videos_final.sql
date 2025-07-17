-- Script final para inserir vídeos dos parceiros
-- Baseado na estrutura real da tabela workout_categories

-- 1. Primeiro, vamos verificar quais categorias já existem
SELECT id, name, description FROM workout_categories ORDER BY name;

-- 2. Criar as categorias dos parceiros se não existirem
INSERT INTO workout_categories (name, description, workoutsCount, order_index)
VALUES 
  ('Musculação', 'Treinos de força e hipertrofia', 0, 5),
  ('Pilates', 'Exercícios de fortalecimento e flexibilidade', 0, 6),
  ('Funcional', 'Treinos funcionais dinâmicos', 0, 7),
  ('Corrida', 'Treinos de corrida e resistência', 0, 8),
  ('Fisioterapia', 'Exercícios terapêuticos e preventivos', 0, 9)
ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  order_index = EXCLUDED.order_index;

-- 3. Limpar vídeos existentes (opcional)
-- TRUNCATE TABLE workout_videos CASCADE;

-- 4. Inserir vídeos usando subqueries para buscar os IDs das categorias
-- TREINOS DE MUSCULAÇÃO
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação', 
  '51 seg', 
  1, 
  'Iniciante', 
  'https://youtu.be/Ej0Tz0Ym5Ow', 
  (SELECT id FROM workout_categories WHERE LOWER(name) = 'musculação' LIMIT 1),
  'Treinos de Musculação', 
  'Conheça nossos instrutores e metodologia', 
  1, 
  true
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'musculação');

-- GOYA HEALTH CLUB (PILATES)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação Pilates', 
  '15 min', 
  15, 
  'Iniciante', 
  'https://youtu.be/nhD9ITCBTVU', 
  (SELECT id FROM workout_categories WHERE LOWER(name) = 'pilates' LIMIT 1),
  'Goya Health Club', 
  'Introdução aos benefícios e técnicas do Pilates', 
  1, 
  true
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'pilates');

INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Mobilidade', 
  '25 min', 
  25, 
  'Iniciante', 
  'https://youtu.be/gDB5n3kSRqI', 
  (SELECT id FROM workout_categories WHERE LOWER(name) = 'pilates' LIMIT 1),
  'Goya Health Club', 
  'Pilates básico para iniciantes', 
  2, 
  false
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'pilates');

-- FIGHT FIT (FUNCIONAL)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação Fight Fit', 
  '12 min', 
  12, 
  'Iniciante', 
  'https://youtu.be/gcLeeRlqoFM', 
  (SELECT id FROM workout_categories WHERE LOWER(name) = 'funcional' LIMIT 1),
  'Fight Fit', 
  'Conheça o conceito Fight Fit e seus benefícios', 
  1, 
  true
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'funcional');

INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Abdominal', 
  '30 min', 
  30, 
  'Iniciante', 
  'https://youtu.be/RCywus6kVPk', 
  (SELECT id FROM workout_categories WHERE LOWER(name) = 'funcional' LIMIT 1),
  'Fight Fit', 
  'Treino funcional básico com elementos de luta', 
  2, 
  false
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'funcional');

INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Técnica', 
  '40 min', 
  40, 
  'Intermediário', 
  'https://youtu.be/t172SCu4QU0', 
  (SELECT id FROM workout_categories WHERE LOWER(name) = 'funcional' LIMIT 1),
  'Fight Fit', 
  'Treino completo para todo o corpo', 
  3, 
  false
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'funcional');

-- BORA ASSESSORIA (CORRIDA)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação', 
  '8 min', 
  8, 
  'Iniciante', 
  'https://youtu.be/E6xtScc3pYk', 
  (SELECT id FROM workout_categories WHERE LOWER(name) = 'corrida' LIMIT 1),
  'Bora Assessoria', 
  'Conheça a Bora Assessoria e metodologia de treino', 
  1, 
  true
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'corrida');

-- THE UNIT (FISIOTERAPIA)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação', 
  '10 min', 
  10, 
  'Iniciante', 
  'https://youtu.be/Q_dlMnGgIPo', 
  (SELECT id FROM workout_categories WHERE LOWER(name) = 'fisioterapia' LIMIT 1),
  'The Unit', 
  'Introdução à fisioterapia preventiva no esporte', 
  1, 
  true
WHERE EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'fisioterapia');

-- 5. Marcar vídeos como novos e populares
UPDATE workout_videos SET is_new = true WHERE created_at > NOW() - INTERVAL '30 days';
UPDATE workout_videos SET is_popular = true WHERE is_recommended = true;

-- 6. Atualizar contagem de vídeos por categoria
UPDATE workout_categories wc
SET workoutsCount = (
  SELECT COUNT(*) 
  FROM workout_videos wv 
  WHERE wv.category = wc.id
);

-- 7. Verificar resultado
SELECT 
  wc.id,
  wc.name,
  wc.workoutsCount,
  COUNT(wv.id) as actual_count
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id
GROUP BY wc.id, wc.name, wc.workoutsCount
ORDER BY wc.order_index;

-- 8. Mostrar vídeos inseridos
SELECT 
  wv.title,
  wv.instructor_name,
  wc.name as category_name
FROM workout_videos wv
JOIN workout_categories wc ON wc.id = wv.category
ORDER BY wc.name, wv.order_index; 