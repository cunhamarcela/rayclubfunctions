-- Atualizar categorias com imagens padrão
UPDATE workout_categories
SET "imageUrl" = CASE 
    WHEN name = 'Musculação' THEN 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800'
    WHEN name = 'Pilates' THEN 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800'
    WHEN name = 'Funcional' THEN 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800'
    WHEN name = 'Corrida' THEN 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800'
    WHEN name = 'Fisioterapia' THEN 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=800'
    ELSE "imageUrl"
END
WHERE "imageUrl" IS NULL;

-- Verificar o resultado
SELECT id, name, "imageUrl", "workoutsCount" 
FROM workout_categories 
ORDER BY "order", name; 