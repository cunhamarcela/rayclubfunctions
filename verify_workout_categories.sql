-- Verificar se existem categorias na tabela
SELECT COUNT(*) as total_categories FROM workout_categories;

-- Listar todas as categorias
SELECT 
    id,
    name,
    description,
    "imageUrl",
    "workoutsCount",
    "order",
    "colorHex",
    created_at,
    updated_at
FROM workout_categories
ORDER BY "order", name;

-- Verificar se há categorias dos parceiros
SELECT * FROM workout_categories 
WHERE name IN ('Musculação', 'Pilates', 'Funcional', 'Corrida', 'Fisioterapia')
ORDER BY name; 