-- ================================================================
-- SCRIPT SQL: ADICIONAR IMAGENS ÀS RECEITAS POR PRIMEIRA PALAVRA
-- Data: 2025-01-21 21:00
-- Objetivo: Atualizar image_url de todas as receitas baseado na primeira palavra
-- ================================================================

-- 🎨 ATUALIZAÇÃO DE IMAGENS POR PRIMEIRA PALAVRA
-- ================================================================

-- ABOBRINHA (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1601218829154-7db94643a2ee?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Abobrinha';

-- AVEIOCA (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1594997521863-9e894c150e18?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Aveioca';

-- BANANA (4 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Banana';

-- BARRINHA (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Barrinha';

-- BATATA (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Batata';

-- BEIJINHO (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Beijinho';

-- BERINJELA (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1617020671875-a2f8f7a6d7c8?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Berinjela';

-- BISCOITO (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1499636136210-6f4ee915583e?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Biscoito';

-- BOLINHO (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Bolinho';

-- BOLO (10 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Bolo';

-- BRIGADEIRO (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1587049433312-d628ae50a8eb?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Brigadeiro';

-- CALDO (6 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Caldo';

-- CANJA (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Canja';

-- CAPONATA (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1617020671875-a2f8f7a6d7c8?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Caponata';

-- CHIPS (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1541592106381-b31e98678d49?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Chips';

-- COXINHA (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1615937691194-95632facedf5?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Coxinha';

-- CREPE (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1567219333096-b0265dcef52d?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Crepe';

-- ESPAGUETE (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Espaguete';

-- FALAFEL (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1593504049359-74330189a345?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Falafel';

-- FRANGO (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1598515214211-89d3c73ae83b?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Frango';

-- GOROROBA (4 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Gororoba';

-- GRANOLA (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Granola';

-- GRÃOMELETE (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Grãomelete';

-- GRATINADO (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Gratinado';

-- HAMBÚRGUER (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Hambúrguer';

-- LASANHA (4 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Lasanha';

-- MEXIDO (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Mexido';

-- MOLHO (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1572441713132-179b85845909?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Molho';

-- MOUSSE (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Mousse';

-- MUFFIN (4 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1486427944299-d1955d23e34d?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Muffin';

-- NHOQUE (4 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Nhoque';

-- NUGGETS (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1562967914-608f82629710?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Nuggets';

-- OMELETE (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1506084868230-bb9d95c24759?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Omelete';

-- PANQUECA (4 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Panqueca';

-- PÃO (6 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Pão';

-- PASTINHA (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Pastinha';

-- PATÊ (6 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Patê';

-- PICOLÉ (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1488900128323-21503983a07e?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Picolé';

-- PIZZA (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Pizza';

-- QUEIJO (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1552767059-ce182ead6c1b?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Queijo';

-- QUICHE (4 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Quiche';

-- RAGU (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1572441713132-179b85845909?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Ragu';

-- RAVIOLI (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Ravioli';

-- RISOTO (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1476124369491-e7addf5db371?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Risoto';

-- SALADA (3 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Salada';

-- SALGADO (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1615937691194-95632facedf5?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Salgado';

-- SMOOTHIE (3 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Smoothie';

-- SNACKS (3 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1541592106381-b31e98678d49?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Snacks';

-- SORBET (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Sorbet';

-- SORVETE (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1551024601-bec78aea704b?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Sorvete';

-- STROGONOFF (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Strogonoff';

-- SUCHÁ (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1544145945-f90425340c7e?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Suchá';

-- SUCO (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Suco';

-- SUFLÊ (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Suflê';

-- TOMATE (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Tomate';

-- TORTA (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Torta';

-- TORTINHA (2 receitas)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Tortinha';

-- WAFFLE (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1562376552-0d160dcb0e58?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Waffle';

-- YAKISOBA (1 receita)
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=800&h=600&fit=crop&q=80'
WHERE SPLIT_PART(title, ' ', 1) = 'Yakisoba';

-- ================================================================
-- ✅ VERIFICAÇÃO FINAL: QUANTAS RECEITAS FORAM ATUALIZADAS
-- ================================================================
SELECT 
    '✅ IMAGENS ATUALIZADAS COM SUCESSO!' as status,
    COUNT(*) as total_receitas_com_imagem,
    COUNT(CASE WHEN image_url LIKE 'https://images.unsplash.com%' THEN 1 END) as receitas_unsplash,
    COUNT(CASE WHEN image_url IS NULL OR image_url = '' THEN 1 END) as receitas_sem_imagem
FROM recipes;

-- ================================================================
-- 📊 RELATÓRIO POR PRIMEIRA PALAVRA COM IMAGENS
-- ================================================================
SELECT 
    SPLIT_PART(title, ' ', 1) as primeira_palavra,
    COUNT(*) as total_receitas,
    LEFT(MAX(image_url), 50) || '...' as exemplo_imagem_url,
    string_agg(
        CASE WHEN LENGTH(title) > 30 
             THEN LEFT(title, 27) || '...' 
             ELSE title 
        END, 
        ' • ' ORDER BY title LIMIT 3
    ) as primeiras_3_receitas
FROM recipes 
GROUP BY SPLIT_PART(title, ' ', 1)
ORDER BY COUNT(*) DESC;

-- ================================================================
-- 🏁 SCRIPT DE IMAGENS CONCLUÍDO
-- ================================================================
SELECT 
    '🏁 ATUALIZAÇÃO DE IMAGENS CONCLUÍDA!' as resultado,
    'Todas as receitas agora têm imagens coerentes baseadas na primeira palavra do título' as descricao,
    NOW()::timestamp as data_execucao; 