-- Script seguro para atualizar/inserir categorias dos parceiros
-- Lida com categorias que já existem no banco

-- 1. Primeiro, vamos ver todas as categorias existentes
SELECT id, name, description, "workoutsCount" 
FROM workout_categories 
ORDER BY name;

-- 2. Atualizar a categoria Musculação que já existe
UPDATE workout_categories 
SET 
  description = 'Treinos de força e hipertrofia',
  order_index = 5
WHERE LOWER(name) = 'musculação';

-- 3. Inserir apenas as categorias que não existem
-- Pilates
INSERT INTO workout_categories (name, description, "workoutsCount", order_index)
SELECT 'Pilates', 'Exercícios de fortalecimento e flexibilidade', 0, 6
WHERE NOT EXISTS (
  SELECT 1 FROM workout_categories WHERE LOWER(name) = 'pilates'
);

-- Funcional
INSERT INTO workout_categories (name, description, "workoutsCount", order_index)
SELECT 'Funcional', 'Treinos funcionais dinâmicos', 0, 7
WHERE NOT EXISTS (
  SELECT 1 FROM workout_categories WHERE LOWER(name) = 'funcional'
);

-- Corrida
INSERT INTO workout_categories (name, description, "workoutsCount", order_index)
SELECT 'Corrida', 'Treinos de corrida e resistência', 0, 8
WHERE NOT EXISTS (
  SELECT 1 FROM workout_categories WHERE LOWER(name) = 'corrida'
);

-- Fisioterapia
INSERT INTO workout_categories (name, description, "workoutsCount", order_index)
SELECT 'Fisioterapia', 'Exercícios terapêuticos e preventivos', 0, 9
WHERE NOT EXISTS (
  SELECT 1 FROM workout_categories WHERE LOWER(name) = 'fisioterapia'
);

-- 4. Verificar o resultado
SELECT id, name, description, "workoutsCount", order_index 
FROM workout_categories 
WHERE LOWER(name) IN ('musculação', 'pilates', 'funcional', 'corrida', 'fisioterapia')
ORDER BY order_index;

-- 5. Agora podemos inserir os vídeos usando os IDs das categorias
-- Primeiro, vamos obter os IDs das categorias
WITH category_ids AS (
  SELECT id, LOWER(name) as name_lower 
  FROM workout_categories 
  WHERE LOWER(name) IN ('musculação', 'pilates', 'funcional', 'corrida', 'fisioterapia')
)
SELECT * FROM category_ids; 