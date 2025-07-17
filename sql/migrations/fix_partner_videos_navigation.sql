-- Script para corrigir os vídeos dos parceiros no banco de dados

-- 1. Limpar todos os vídeos existentes para evitar duplicatas
TRUNCATE TABLE workout_videos CASCADE;

-- 2. Primeiro, vamos verificar quais categorias já existem e criar as que faltam
-- Inserir categorias dos parceiros se não existirem
INSERT INTO workout_categories (name, description, color, workouts_count, order_index)
VALUES 
  ('Musculação', 'Treinos de força e hipertrofia', '#5C6BC0', 0, 5),
  ('Pilates', 'Exercícios de fortalecimento e flexibilidade', '#DDA0DD', 0, 6),
  ('Funcional', 'Treinos funcionais dinâmicos', '#FF7043', 0, 7),
  ('Corrida', 'Treinos de corrida e resistência', '#26A69A', 0, 8),
  ('Fisioterapia', 'Exercícios terapêuticos e preventivos', '#78909C', 0, 9)
ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  color = EXCLUDED.color,
  order_index = EXCLUDED.order_index;

-- 3. Buscar os IDs das categorias criadas
WITH category_ids AS (
  SELECT id, LOWER(name) as category_key FROM workout_categories 
  WHERE name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia')
)
-- 4. Inserir vídeos usando os IDs corretos das categorias
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  v.title,
  v.duration,
  v.duration_minutes,
  v.difficulty,
  v.youtube_url,
  c.id as category,
  v.instructor_name,
  v.description,
  v.order_index,
  v.is_recommended
FROM (
  -- TREINOS DE MUSCULAÇÃO
  VALUES
  ('Apresentação', '51 seg', 1, 'Iniciante', 'https://youtu.be/Ej0Tz0Ym5Ow', 'musculação', 'Treinos de Musculação', 'Conheça nossos instrutores e metodologia', 1, true),
  
  -- GOYA HEALTH CLUB (PILATES)
  ('Apresentação Pilates', '15 min', 15, 'Iniciante', 'https://youtu.be/nhD9ITCBTVU', 'pilates', 'Goya Health Club', 'Introdução aos benefícios e técnicas do Pilates', 1, true),
  ('Mobilidade', '25 min', 25, 'Iniciante', 'https://youtu.be/gDB5n3kSRqI', 'pilates', 'Goya Health Club', 'Pilates básico para iniciantes', 2, false),
  
  -- FIGHT FIT (FUNCIONAL)
  ('Apresentação Fight Fit', '12 min', 12, 'Iniciante', 'https://youtu.be/gcLeeRlqoFM', 'funcional', 'Fight Fit', 'Conheça o conceito Fight Fit e seus benefícios', 1, true),
  ('Abdominal', '30 min', 30, 'Iniciante', 'https://youtu.be/RCywus6kVPk', 'funcional', 'Fight Fit', 'Treino funcional básico com elementos de luta', 2, false),
  ('Técnica', '40 min', 40, 'Intermediário', 'https://youtu.be/t172SCu4QU0', 'funcional', 'Fight Fit', 'Treino completo para todo o corpo', 3, false),
  
  -- BORA ASSESSORIA (CORRIDA)
  ('Apresentação', '8 min', 8, 'Iniciante', 'https://youtu.be/E6xtScc3pYk', 'corrida', 'Bora Assessoria', 'Conheça a Bora Assessoria e metodologia de treino', 1, true),
  
  -- THE UNIT (FISIOTERAPIA)
  ('Apresentação', '10 min', 10, 'Iniciante', 'https://youtu.be/Q_dlMnGgIPo', 'fisioterapia', 'The Unit', 'Introdução à fisioterapia preventiva no esporte', 1, true)
) AS v(title, duration, duration_minutes, difficulty, youtube_url, category_key, instructor_name, description, order_index, is_recommended)
JOIN category_ids c ON c.category_key = v.category_key;

-- 5. Marcar vídeos como novos e populares
UPDATE workout_videos SET is_new = true WHERE created_at > NOW() - INTERVAL '30 days';
UPDATE workout_videos SET is_popular = true WHERE is_recommended = true;

-- 6. Atualizar contagem de vídeos por categoria
UPDATE workout_categories wc
SET workouts_count = (
  SELECT COUNT(*) 
  FROM workout_videos wv 
  WHERE wv.category = wc.id
)
WHERE wc.name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia');

-- 7. Verificar resultado
SELECT 
  wc.id,
  wc.name,
  wc.workouts_count,
  COUNT(wv.id) as actual_count
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id
WHERE wc.name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia')
GROUP BY wc.id, wc.name, wc.workouts_count
ORDER BY wc.order_index; 