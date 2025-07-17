-- Script completo para configurar vídeos dos parceiros
-- Compatível com a estrutura real da tabela workout_categories

-- PARTE 1: CATEGORIAS
-- ==================

-- 1.1 Atualizar a categoria Musculação existente
UPDATE workout_categories 
SET description = 'Treinos de força e hipertrofia'
WHERE LOWER(name) = 'musculação';

-- 1.2 Inserir categorias que não existem
INSERT INTO workout_categories (name, description, "workoutsCount")
SELECT 'Pilates', 'Exercícios de fortalecimento e flexibilidade', 0
WHERE NOT EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'pilates');

INSERT INTO workout_categories (name, description, "workoutsCount")
SELECT 'Funcional', 'Treinos funcionais dinâmicos', 0
WHERE NOT EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'funcional');

INSERT INTO workout_categories (name, description, "workoutsCount")
SELECT 'Corrida', 'Treinos de corrida e resistência', 0
WHERE NOT EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'corrida');

INSERT INTO workout_categories (name, description, "workoutsCount")
SELECT 'Fisioterapia', 'Exercícios terapêuticos e preventivos', 0
WHERE NOT EXISTS (SELECT 1 FROM workout_categories WHERE LOWER(name) = 'fisioterapia');

-- 1.3 Verificar categorias criadas
SELECT id, name FROM workout_categories 
WHERE LOWER(name) IN ('musculação', 'pilates', 'funcional', 'corrida', 'fisioterapia');

-- PARTE 2: VÍDEOS
-- ===============

-- 2.1 Limpar vídeos antigos dos parceiros (opcional)
DELETE FROM workout_videos 
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit');

-- 2.2 Inserir vídeos dos parceiros

-- MUSCULAÇÃO (usando o ID conhecido)
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

-- PILATES
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação Pilates', '15 min', 15, 'Iniciante', 
  'https://youtu.be/nhD9ITCBTVU', id, 'Goya Health Club', 
  'Introdução aos benefícios e técnicas do Pilates', 1, true
FROM workout_categories WHERE LOWER(name) = 'pilates';

INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Mobilidade', '25 min', 25, 'Iniciante', 
  'https://youtu.be/gDB5n3kSRqI', id, 'Goya Health Club', 
  'Pilates básico para iniciantes', 2, false
FROM workout_categories WHERE LOWER(name) = 'pilates';

-- FUNCIONAL
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação Fight Fit', '12 min', 12, 'Iniciante', 
  'https://youtu.be/gcLeeRlqoFM', id, 'Fight Fit', 
  'Conheça o conceito Fight Fit e seus benefícios', 1, true
FROM workout_categories WHERE LOWER(name) = 'funcional';

INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Abdominal', '30 min', 30, 'Iniciante', 
  'https://youtu.be/RCywus6kVPk', id, 'Fight Fit', 
  'Treino funcional básico com elementos de luta', 2, false
FROM workout_categories WHERE LOWER(name) = 'funcional';

INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Técnica', '40 min', 40, 'Intermediário', 
  'https://youtu.be/t172SCu4QU0', id, 'Fight Fit', 
  'Treino completo para todo o corpo', 3, false
FROM workout_categories WHERE LOWER(name) = 'funcional';

-- CORRIDA
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação', '8 min', 8, 'Iniciante', 
  'https://youtu.be/E6xtScc3pYk', id, 'Bora Assessoria', 
  'Conheça a Bora Assessoria e metodologia de treino', 1, true
FROM workout_categories WHERE LOWER(name) = 'corrida';

-- FISIOTERAPIA
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended)
SELECT 
  'Apresentação', '10 min', 10, 'Iniciante', 
  'https://youtu.be/Q_dlMnGgIPo', id, 'The Unit', 
  'Introdução à fisioterapia preventiva no esporte', 1, true
FROM workout_categories WHERE LOWER(name) = 'fisioterapia';

-- PARTE 3: ATUALIZAÇÕES FINAIS
-- ============================

-- 3.1 Marcar vídeos como novos e populares
UPDATE workout_videos SET is_new = true 
WHERE instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit');

UPDATE workout_videos SET is_popular = true 
WHERE is_recommended = true 
AND instructor_name IN ('Treinos de Musculação', 'Goya Health Club', 'Fight Fit', 'Bora Assessoria', 'The Unit');

-- 3.2 Atualizar contagem de vídeos por categoria
UPDATE workout_categories wc
SET "workoutsCount" = (
  SELECT COUNT(*) FROM workout_videos wv WHERE wv.category = wc.id
)
WHERE LOWER(name) IN ('musculação', 'pilates', 'funcional', 'corrida', 'fisioterapia');

-- 3.3 Verificar resultado final
SELECT 
  wc.name as categoria,
  wc."workoutsCount" as total_videos,
  COUNT(wv.id) as videos_inseridos
FROM workout_categories wc
LEFT JOIN workout_videos wv ON wv.category = wc.id
WHERE LOWER(wc.name) IN ('musculação', 'pilates', 'funcional', 'corrida', 'fisioterapia')
GROUP BY wc.id, wc.name, wc."workoutsCount"
ORDER BY wc.name; 