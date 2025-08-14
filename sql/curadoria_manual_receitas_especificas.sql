-- ================================================================
-- CURADORIA MANUAL: RECEITAS ESPECÍFICAS
-- Data: 2025-01-21 22:30
-- Objetivo: Corrigir casos específicos que a categorização automática não acerta
-- ================================================================

-- 🎯 ESTRATÉGIA MANUAL PARA CASOS ESPECIAIS:
-- Receitas com nomes únicos ou que podem gerar confusão

-- ================================================================
-- RECEITAS ESPECIAIS: MAPEAMENTO MANUAL PRECISO
-- ================================================================

-- Toast de Banana - Imagem específica de toast com banana
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%BANANA TOAST%';

-- Gororoba de Banana - Prato brasileiro típico
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%GOROROBA%';

-- Pão de Queijo - Imagem específica do pão de queijo brasileiro
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%PÃO DE QUEIJO%';

-- Falafel - Imagem específica de falafel
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1593266986925-dd0fcd07838b?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%FALAFEL%';

-- Caponata - Imagem específica de caponata de berinjela
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%CAPONATA%';

-- Queijo de Castanhas - Imagem de queijo vegano
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1452195100486-9cc805987862?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%QUEIJO DE CASTANHA%';

-- Ragu de Cogumelos - Imagem específica de ragu
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1610057099431-d73a1c9d2f2f?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%RAGU%';

-- Mexido de Tofu - Imagem específica de tofu mexido
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1607532941433-304659e8198a?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%MEXIDO DE TOFU%';

-- Chips de Batata Doce - Imagem específica
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1576867757603-05b134ebc379?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%CHIPS DE BATATA DOCE%';

-- Granola Caseira - Imagem específica de granola
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571212515416-6b3d7bbdc6f8?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%GRANOLA%';

-- Muffin de Mirtilo - Imagem específica de muffin com blueberry
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1426869981800-95ebf51ce900?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%MUFFIN%' AND UPPER(title) LIKE '%MIRTILO%';

-- Biscoito de Banana - Imagem específica
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1481391319762-47dff72954d9?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%BISCOITO%' AND UPPER(title) LIKE '%BANANA%';

-- ================================================================
-- CORREÇÕES PARA RECEITAS QUE PODEM TER CONFLITO
-- ================================================================

-- Abobrinha Recheada - Imagem específica de abobrinha recheada
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1558305043-1d7b04f69a93?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%ABOBRINHA RECHEADA%';

-- Berinjela Recheada - Imagem específica
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1572441991636-12169d09ae83?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%BERINJELA RECHEADA%';

-- Pizza de Clara de Ovo - Imagem específica
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571407970349-bc81e7e96d47?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%PIZZA DE CLARA%';

-- Barrinha de Proteína - Imagem específica
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1582654506769-0678d93bd5d0?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%BARRINHA%';

-- Sorvete de Iogurte - Imagem específica
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1497034825429-c343d7c6a68f?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%SORVETE%';

-- ================================================================
-- VERIFICAÇÃO DAS RECEITAS MANUAIS
-- ================================================================

-- Listar receitas que receberam curadoria manual
SELECT 
    '🎨 RECEITAS COM CURADORIA MANUAL' as categoria,
    title,
    image_url,
    CASE 
        WHEN UPPER(title) LIKE '%BANANA TOAST%' THEN 'Toast com Banana'
        WHEN UPPER(title) LIKE '%GOROROBA%' THEN 'Gororoba Brasileira'
        WHEN UPPER(title) LIKE '%PÃO DE QUEIJO%' THEN 'Pão de Queijo'
        WHEN UPPER(title) LIKE '%FALAFEL%' THEN 'Falafel'
        WHEN UPPER(title) LIKE '%CAPONATA%' THEN 'Caponata'
        WHEN UPPER(title) LIKE '%QUEIJO DE CASTANHA%' THEN 'Queijo Vegano'
        WHEN UPPER(title) LIKE '%RAGU%' THEN 'Ragu'
        WHEN UPPER(title) LIKE '%MEXIDO DE TOFU%' THEN 'Tofu Mexido'
        WHEN UPPER(title) LIKE '%CHIPS DE BATATA DOCE%' THEN 'Chips'
        WHEN UPPER(title) LIKE '%GRANOLA%' THEN 'Granola'
        WHEN UPPER(title) LIKE '%BISCOITO%' AND UPPER(title) LIKE '%BANANA%' THEN 'Biscoito de Banana'
        WHEN UPPER(title) LIKE '%ABOBRINHA RECHEADA%' THEN 'Abobrinha Recheada'
        WHEN UPPER(title) LIKE '%BERINJELA RECHEADA%' THEN 'Berinjela Recheada'
        WHEN UPPER(title) LIKE '%PIZZA DE CLARA%' THEN 'Pizza Proteica'
        WHEN UPPER(title) LIKE '%BARRINHA%' THEN 'Barrinha Proteica'
        WHEN UPPER(title) LIKE '%SORVETE%' THEN 'Sorvete Saudável'
        ELSE 'Curadoria Manual'
    END as tipo_curadoria
FROM recipes
WHERE 
    UPPER(title) LIKE '%BANANA TOAST%' OR
    UPPER(title) LIKE '%GOROROBA%' OR
    UPPER(title) LIKE '%PÃO DE QUEIJO%' OR
    UPPER(title) LIKE '%FALAFEL%' OR
    UPPER(title) LIKE '%CAPONATA%' OR
    UPPER(title) LIKE '%QUEIJO DE CASTANHA%' OR
    UPPER(title) LIKE '%RAGU%' OR
    UPPER(title) LIKE '%MEXIDO DE TOFU%' OR
    UPPER(title) LIKE '%CHIPS DE BATATA DOCE%' OR
    UPPER(title) LIKE '%GRANOLA%' OR
    (UPPER(title) LIKE '%BISCOITO%' AND UPPER(title) LIKE '%BANANA%') OR
    UPPER(title) LIKE '%ABOBRINHA RECHEADA%' OR
    UPPER(title) LIKE '%BERINJELA RECHEADA%' OR
    UPPER(title) LIKE '%PIZZA DE CLARA%' OR
    UPPER(title) LIKE '%BARRINHA%' OR
    UPPER(title) LIKE '%SORVETE%'
ORDER BY title;

-- ================================================================
-- TEMPLATE PARA MAIS CORREÇÕES MANUAIS
-- ================================================================

-- Use este template para adicionar mais correções específicas:
/*
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/FOTO_ID_AQUI?w=400&h=300&fit=crop'
WHERE title = 'TÍTULO_EXATO_DA_RECEITA';
*/

-- ================================================================
-- PRÓXIMOS PASSOS:
-- 1. Execute primeiro: sql/estrategia_imagens_segura_categorizada.sql
-- 2. Depois execute este script para correções específicas
-- 3. Verifique os resultados no app
-- 4. Adicione mais correções manuais conforme necessário
-- ================================================================ 