-- URLs TESTADAS E FUNCIONAIS - CORREÇÃO ESPECÍFICA
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop&q=80' WHERE title = 'Suflê de Legumes';
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop&q=80' WHERE title = 'Waffle Funcional';
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop&q=80' WHERE title = 'Suflê Vegano';
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&h=300&fit=crop&q=80' WHERE title LIKE 'Torta de Liquidificador%';

-- Aplicar fallback para qualquer receita sem imagem
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop&q=80' WHERE image_url IS NULL OR image_url = '';

-- Verificar resultados
SELECT title, image_url FROM recipes WHERE title IN ('Suflê de Legumes', 'Waffle Funcional', 'Suflê Vegano', 'Torta de Liquidificador Super Rápida') ORDER BY title;
