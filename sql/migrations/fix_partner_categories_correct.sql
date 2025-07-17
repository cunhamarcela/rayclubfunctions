-- Script corrigido para atualizar/inserir categorias dos parceiros
-- Usa apenas as colunas que existem na tabela

-- 1. Primeiro, vamos ver todas as categorias existentes
SELECT id, name, description, "workoutsCount" 
FROM workout_categories 
ORDER BY name;

-- 2. Atualizar a categoria Musculação que já existe
UPDATE workout_categories 
SET description = 'Treinos de força e hipertrofia'
WHERE LOWER(name) = 'musculação';

-- 3. Inserir apenas as categorias que não existem
-- Pilates
INSERT INTO workout_categories (name, description, "workoutsCount")
SELECT 'Pilates', 'Exercícios de fortalecimento e flexibilidade', 0
WHERE NOT EXISTS (
  SELECT 1 FROM workout_categories WHERE LOWER(name) = 'pilates'
);

-- Funcional
INSERT INTO workout_categories (name, description, "workoutsCount")
SELECT 'Funcional', 'Treinos funcionais dinâmicos', 0
WHERE NOT EXISTS (
  SELECT 1 FROM workout_categories WHERE LOWER(name) = 'funcional'
);

-- Corrida
INSERT INTO workout_categories (name, description, "workoutsCount")
SELECT 'Corrida', 'Treinos de corrida e resistência', 0
WHERE NOT EXISTS (
  SELECT 1 FROM workout_categories WHERE LOWER(name) = 'corrida'
);

-- Fisioterapia
INSERT INTO workout_categories (name, description, "workoutsCount")
SELECT 'Fisioterapia', 'Exercícios terapêuticos e preventivos', 0
WHERE NOT EXISTS (
  SELECT 1 FROM workout_categories WHERE LOWER(name) = 'fisioterapia'
);

-- 4. Verificar o resultado
SELECT id, name, description, "workoutsCount"
FROM workout_categories 
WHERE LOWER(name) IN ('musculação', 'pilates', 'funcional', 'corrida', 'fisioterapia')
ORDER BY name;

-- 5. Obter os IDs das categorias para usar na inserção dos vídeos
SELECT id, name 
FROM workout_categories 
WHERE LOWER(name) IN ('musculação', 'pilates', 'funcional', 'corrida', 'fisioterapia'); 