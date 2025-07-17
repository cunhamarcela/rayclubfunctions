-- Script para inserir apenas as categorias dos parceiros
-- Execute este script primeiro para criar as categorias

-- Inserir categorias dos parceiros
-- Nota: A coluna se chama "workoutsCount" com C maiúsculo, por isso usamos aspas duplas
INSERT INTO workout_categories (name, description, "workoutsCount", order_index)
VALUES 
  ('Musculação', 'Treinos de força e hipertrofia', 0, 5),
  ('Pilates', 'Exercícios de fortalecimento e flexibilidade', 0, 6),
  ('Funcional', 'Treinos funcionais dinâmicos', 0, 7),
  ('Corrida', 'Treinos de corrida e resistência', 0, 8),
  ('Fisioterapia', 'Exercícios terapêuticos e preventivos', 0, 9)
ON CONFLICT (name) DO UPDATE SET
  description = EXCLUDED.description,
  order_index = EXCLUDED.order_index;

-- Verificar se as categorias foram criadas
SELECT id, name, description, "workoutsCount", order_index 
FROM workout_categories 
WHERE name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia')
ORDER BY order_index; 