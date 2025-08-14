-- ================================================================
-- SCRIPT SQL: IMAGENS ESPECÍFICAS PARA RECEITAS POPULARES
-- Data: 2025-01-21 21:10
-- Objetivo: Adicionar imagens mais específicas para receitas com base no título completo
-- ================================================================

-- 🎯 IMAGENS ESPECÍFICAS PARA RECEITAS MAIS DETALHADAS
-- ================================================================

-- RECEITAS DE BOLO (10 receitas) - Imagens específicas por tipo
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Bolo Alagado%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Bolo de Banana%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Bolo de Laranja%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1587049433312-d628ae50a8eb?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Bolo de Maçã%';

-- RECEITAS DE CALDO/SOPAS (6 receitas) - Imagens por tipo de sopa
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1476718406336-bb5a9690ee2a?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Caldo de Abóbora%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Caldo de Legumes%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Caldo Verde%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Canja de Galinha%';

-- RECEITAS DE PÃO (6 receitas) - Imagens específicas por tipo
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Pão Caseiro%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1618587786002-f67c82c95778?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Pão de Queijo%';

-- RECEITAS COM BANANA (4 receitas) - Imagens específicas
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Banana Toast%';

-- RECEITAS DE SMOOTHIE/BEBIDAS (3 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Smoothie%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1622597467836-f3285f2131b8?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Suco Verde%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Suchá%';

-- RECEITAS DE SALADA (3 receitas) - Imagens específicas
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Salada de Atum%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Salada de Pepino%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1543339494-b4cd4f7ba686?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Salada Proteica%';

-- RECEITAS DE LASANHA (4 receitas) - Imagens específicas
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1601218829154-7db94643a2ee?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Lasanha de Abobrinha%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1617020671875-a2f8f7a6d7c8?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Lasanha de Berinjela%';

-- RECEITAS DE MUFFIN (4 receitas) - Imagens específicas
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1486427944299-d1955d23e34d?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Muffin de Mirtilo%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Muffin Salgado%';

-- RECEITAS DE PANQUECA (4 receitas) - Imagens específicas
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Panqueca de Cacau%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1584949091830-4aa3deba7ddc?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Panqueca de Espinafre%';

-- RECEITAS DE PATÊ (6 receitas) - Imagens específicas
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Patê de Atum%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Patê de Frango%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1552767059-ce182ead6c1b?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Patê de Ricota%';

-- RECEITAS DE QUICHE (4 receitas) - Imagens específicas
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Quiche de Alho-Poró%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1604908816296-670ad7bfda65?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Quiche Funcional%';

-- RECEITAS DE NHOQUE (4 receitas) - Imagens específicas
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Nhoque de Cenoura%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Nhoque de Mandioquinha%';

-- RECEITAS ESPECIAIS - Imagens únicas
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1593504049359-74330189a345?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Falafel%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Pizza%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Hambúrguer%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1615937691194-95632facedf5?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Coxinha%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1562967914-608f82629710?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Nuggets%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Risoto%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Yakisoba%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1562376552-0d160dcb0e58?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Waffle%';

-- SOBREMESAS ESPECÍFICAS
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1587049433312-d628ae50a8eb?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Brigadeiro%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Beijinho%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Mousse%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1488900128323-21503983a07e?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Picolé%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Sorbet%' OR title LIKE '%Sorvete%';

-- LANCHES E SNACKS
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Barrinha%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1541592106381-b31e98678d49?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Chips%' OR title LIKE '%Snacks%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Biscoito%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Granola%';

-- PRATOS PROTEICOS
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Omelete%' OR title LIKE '%Mexido%' OR title LIKE '%Grãomelete%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Frango Teriyaki%';

-- VEGETAIS E LEGUMES
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1601218829154-7db94643a2ee?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Abobrinha%' OR title LIKE '%Espaguete de Abobrinha%' OR title LIKE '%Ravioli de Abobrinha%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1617020671875-a2f8f7a6d7c8?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Berinjela%' OR title LIKE '%Caponata%' OR title LIKE '%Pastinha de Berinjela%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Batata%' OR title LIKE '%Tomate%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1567219333096-b0265dcef52d?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Crepe%';

-- MOLHOS E ACOMPANHAMENTOS
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1572441713132-179b85845909?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Molho Pesto%' OR title LIKE '%Ragu%';

UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1552767059-ce182ead6c1b?w=800&h=600&fit=crop&q=80'
WHERE title LIKE '%Queijo de Castanhas%';

-- ================================================================
-- ✅ VERIFICAÇÃO FINAL: STATUS DAS IMAGENS ESPECÍFICAS
-- ================================================================
SELECT 
    '✅ IMAGENS ESPECÍFICAS APLICADAS!' as status,
    COUNT(*) as total_receitas,
    COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) as receitas_com_imagem,
    COUNT(CASE WHEN image_url IS NULL OR image_url = '' THEN 1 END) as receitas_sem_imagem,
    ROUND(
        (COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) * 100.0 / COUNT(*)), 
        2
    ) as porcentagem_com_imagem
FROM recipes;

-- ================================================================
-- 📸 AMOSTRA DE RECEITAS COM SUAS IMAGENS
-- ================================================================
SELECT 
    '📸 AMOSTRA DE RECEITAS COM IMAGENS' as secao,
    SPLIT_PART(title, ' ', 1) as primeira_palavra,
    LEFT(title, 40) || CASE WHEN LENGTH(title) > 40 THEN '...' ELSE '' END as titulo_resumido,
    LEFT(image_url, 60) || '...' as url_imagem_resumida,
    category as categoria
FROM recipes 
WHERE image_url IS NOT NULL AND image_url != ''
ORDER BY SPLIT_PART(title, ' ', 1), title
LIMIT 20;

-- ================================================================
-- 🏁 IMAGENS ESPECÍFICAS CONCLUÍDAS
-- ================================================================
SELECT 
    '🏁 PERSONALIZAÇÃO DE IMAGENS CONCLUÍDA!' as resultado,
    'Receitas agora possuem imagens específicas baseadas em seus ingredientes e características únicas' as descricao,
    NOW()::timestamp as data_execucao; 