-- Script para verificar categorias existentes e inserir vídeos dos parceiros

-- 1. Primeiro, vamos ver quais categorias já existem
SELECT id, name, description FROM workout_categories ORDER BY name;

-- 2. Se as categorias dos parceiros não existirem, você pode criá-las com:
/*
INSERT INTO workout_categories (name, description, color, workouts_count, order_index)
VALUES 
  ('Musculação', 'Treinos de força e hipertrofia', '#5C6BC0', 0, 5),
  ('Pilates', 'Exercícios de fortalecimento e flexibilidade', '#DDA0DD', 0, 6),
  ('Funcional', 'Treinos funcionais dinâmicos', '#FF7043', 0, 7),
  ('Corrida', 'Treinos de corrida e resistência', '#26A69A', 0, 8),
  ('Fisioterapia', 'Exercícios terapêuticos e preventivos', '#78909C', 0, 9);
*/

-- 3. Limpar vídeos existentes (opcional - comente se quiser manter os existentes)
-- TRUNCATE TABLE workout_videos CASCADE;

-- 4. Inserir vídeos dos parceiros
-- Substitua os UUIDs abaixo pelos IDs reais das categorias do passo 1

-- Exemplo: Se a categoria "Musculação" tem o ID 'abc123...', use:
/*
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES
  ('Apresentação', '51 seg', 1, 'Iniciante', 'https://youtu.be/Ej0Tz0Ym5Ow', 'abc123...', 'Treinos de Musculação', 'Conheça nossos instrutores e metodologia', 1, true);
*/

-- Template para inserir vídeos (substitua CATEGORY_ID_HERE pelo UUID real):

-- TREINOS DE MUSCULAÇÃO
/*
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES
  ('Apresentação', '51 seg', 1, 'Iniciante', 'https://youtu.be/Ej0Tz0Ym5Ow', 'CATEGORY_ID_HERE', 'Treinos de Musculação', 'Conheça nossos instrutores e metodologia', 1, true);
*/

-- GOYA HEALTH CLUB (PILATES)
/*
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES
  ('Apresentação Pilates', '15 min', 15, 'Iniciante', 'https://youtu.be/nhD9ITCBTVU', 'CATEGORY_ID_HERE', 'Goya Health Club', 'Introdução aos benefícios e técnicas do Pilates', 1, true),
  ('Mobilidade', '25 min', 25, 'Iniciante', 'https://youtu.be/gDB5n3kSRqI', 'CATEGORY_ID_HERE', 'Goya Health Club', 'Pilates básico para iniciantes', 2, false);
*/

-- FIGHT FIT (FUNCIONAL)
/*
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES
  ('Apresentação Fight Fit', '12 min', 12, 'Iniciante', 'https://youtu.be/gcLeeRlqoFM', 'CATEGORY_ID_HERE', 'Fight Fit', 'Conheça o conceito Fight Fit e seus benefícios', 1, true),
  ('Abdominal', '30 min', 30, 'Iniciante', 'https://youtu.be/RCywus6kVPk', 'CATEGORY_ID_HERE', 'Fight Fit', 'Treino funcional básico com elementos de luta', 2, false),
  ('Técnica', '40 min', 40, 'Intermediário', 'https://youtu.be/t172SCu4QU0', 'CATEGORY_ID_HERE', 'Fight Fit', 'Treino completo para todo o corpo', 3, false);
*/

-- BORA ASSESSORIA (CORRIDA)
/*
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES
  ('Apresentação', '8 min', 8, 'Iniciante', 'https://youtu.be/E6xtScc3pYk', 'CATEGORY_ID_HERE', 'Bora Assessoria', 'Conheça a Bora Assessoria e metodologia de treino', 1, true);
*/

-- THE UNIT (FISIOTERAPIA)
/*
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
VALUES
  ('Apresentação', '10 min', 10, 'Iniciante', 'https://youtu.be/Q_dlMnGgIPo', 'CATEGORY_ID_HERE', 'The Unit', 'Introdução à fisioterapia preventiva no esporte', 1, true);
*/

-- 5. Após inserir, marcar vídeos como novos e populares
/*
UPDATE workout_videos SET is_new = true WHERE created_at > NOW() - INTERVAL '30 days';
UPDATE workout_videos SET is_popular = true WHERE is_recommended = true;
*/

-- 6. Atualizar contagem de vídeos por categoria
/*
UPDATE workout_categories wc
SET workouts_count = (
  SELECT COUNT(*) 
  FROM workout_videos wv 
  WHERE wv.category = wc.id
);
*/

-- 7. Verificar resultado
/*
SELECT 
  wv.title,
  wv.instructor_name,
  wc.name as category_name
FROM workout_videos wv
JOIN workout_categories wc ON wc.id = wv.category
ORDER BY wc.name, wv.order_index;
*/ 