-- ================================================================
-- CORREÇÃO ESPECÍFICA: IMAGENS PROBLEMÁTICAS
-- Data: 2025-01-21 23:15
-- Problema: Receitas com imagens incoerentes (hambúrguer em suflê) e sem imagem
-- Objetivo: Corrigir especificamente cada receita problemática
-- ================================================================

-- 🎯 CORREÇÕES ESPECÍFICAS BASEADAS NA TELA DO APP:

-- ================================================================
-- ETAPA 1: VERIFICAR SITUAÇÃO ATUAL DAS RECEITAS PROBLEMÁTICAS
-- ================================================================

-- Verificar receitas que aparecem na tela com problemas
SELECT 
    '🔍 RECEITAS PROBLEMÁTICAS NA TELA' as categoria,
    title,
    image_url,
    CASE 
        WHEN image_url IS NULL OR image_url = '' THEN 'SEM IMAGEM'
        WHEN image_url LIKE '%hamburger%' OR image_url LIKE '%burger%' THEN 'IMAGEM DE HAMBÚRGUER (INCORRETA)'
        ELSE 'IMAGEM DEFINIDA'
    END as status_imagem
FROM recipes
WHERE title IN (
    'Suflê de Legumes',
    'Waffle Funcional', 
    'Suflê Vegano',
    'Torta de Liquidificador Super Rápida'
)
ORDER BY title;

-- ================================================================
-- ETAPA 2: CORREÇÕES ESPECÍFICAS POR RECEITA
-- ================================================================

-- 🥄 Suflê de Legumes - Imagem específica de suflê de vegetais
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1574653090-77fe4f75fcda?w=400&h=300&fit=crop'
WHERE title = 'Suflê de Legumes';

-- 🧇 Waffle Funcional - Imagem específica de waffle saudável
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1562834049-b88a5a5d3c5d?w=400&h=300&fit=crop'
WHERE title = 'Waffle Funcional';

-- 🌱 Suflê Vegano - Imagem específica de suflê vegano
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1565299507177-b0ac66763828?w=400&h=300&fit=crop'
WHERE title = 'Suflê Vegano';

-- 🥧 Torta de Liquidificador - Imagem específica de torta salgada
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1571197150572-3a6b7c5b3b64?w=400&h=300&fit=crop'
WHERE title LIKE 'Torta de Liquidificador%';

-- ================================================================
-- ETAPA 3: CORREÇÕES ADICIONAIS PARA OUTRAS RECEITAS PROBLEMÁTICAS
-- ================================================================

-- Verificar se há outras receitas com imagens de hambúrguer que não deveriam ter
SELECT 
    '🍔 OUTRAS RECEITAS COM IMAGEM DE HAMBÚRGUER' as categoria,
    title,
    image_url
FROM recipes
WHERE (image_url LIKE '%hamburger%' OR image_url LIKE '%burger%')
  AND title NOT LIKE '%Hambúrguer%'
  AND title NOT LIKE '%Burger%';

-- Corrigir receitas que não são hambúrguer mas têm imagem de hambúrguer
UPDATE recipes 
SET image_url = CASE
    -- Molhos e patês
    WHEN title LIKE '%Molho%' OR title LIKE '%Patê%' OR title LIKE '%Pastinha%' 
        THEN 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop'
    -- Sopas e caldos
    WHEN title LIKE '%Sopa%' OR title LIKE '%Caldo%' 
        THEN 'https://images.unsplash.com/photo-1547592180-85f173990554?w=400&h=300&fit=crop'
    -- Bolos e doces
    WHEN title LIKE '%Bolo%' OR title LIKE '%Doce%' OR title LIKE '%Mousse%'
        THEN 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=300&fit=crop'
    -- Snacks e aperitivos
    WHEN title LIKE '%Snack%' OR title LIKE '%Chip%' 
        THEN 'https://images.unsplash.com/photo-1559058922-a46d78e70833?w=400&h=300&fit=crop'
    -- Bebidas
    WHEN title LIKE '%Suco%' OR title LIKE '%Smoothie%' OR title LIKE '%Suchá%'
        THEN 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400&h=300&fit=crop'
    -- Vegetais e saladas
    WHEN title LIKE '%Salada%' OR title LIKE '%Vegetal%' OR title LIKE '%Abobrinha%' OR title LIKE '%Berinjela%'
        THEN 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop'
    -- Fallback genérico para pratos saudáveis
    ELSE 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop'
END
WHERE (image_url LIKE '%hamburger%' OR image_url LIKE '%burger%')
  AND title NOT LIKE '%Hambúrguer%'
  AND title NOT LIKE '%Burger%';

-- ================================================================
-- ETAPA 4: GARANTIR QUE NENHUMA RECEITA FIQUE SEM IMAGEM
-- ================================================================

-- Aplicar fallback para receitas sem imagem
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop'
WHERE image_url IS NULL OR image_url = '';

-- ================================================================
-- ETAPA 5: VERIFICAÇÃO FINAL
-- ================================================================

-- Verificar se as receitas problemáticas foram corrigidas
SELECT 
    '✅ RECEITAS CORRIGIDAS' as categoria,
    title,
    CASE 
        WHEN image_url IS NULL OR image_url = '' THEN '❌ SEM IMAGEM'
        WHEN image_url LIKE '%hamburger%' OR image_url LIKE '%burger%' THEN '🍔 HAMBÚRGUER'
        ELSE '✅ IMAGEM APROPRIADA'
    END as status_final,
    SUBSTRING(image_url, 1, 50) as url_parcial
FROM recipes
WHERE title IN (
    'Suflê de Legumes',
    'Waffle Funcional', 
    'Suflê Vegano',
    'Torta de Liquidificador Super Rápida'
)
ORDER BY title;

-- Verificar cobertura total de imagens
SELECT 
    '📊 STATUS FINAL GERAL' as categoria,
    COUNT(*) as total_receitas,
    COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) as com_imagem,
    COUNT(CASE WHEN image_url IS NULL OR image_url = '' THEN 1 END) as sem_imagem,
    ROUND(
        COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) * 100.0 / COUNT(*), 
        1
    ) as percentual_cobertura
FROM recipes;

-- Verificar se ainda há receitas não-hambúrguer com imagem de hambúrguer
SELECT 
    '🔍 VERIFICAÇÃO: IMAGENS INCOERENTES RESTANTES' as categoria,
    COUNT(*) as receitas_com_imagem_incorreta
FROM recipes
WHERE (image_url LIKE '%hamburger%' OR image_url LIKE '%burger%')
  AND title NOT LIKE '%Hambúrguer%'
  AND title NOT LIKE '%Burger%';

-- ================================================================
-- 🎯 RESULTADO ESPERADO:
-- - Suflê de Legumes: Imagem de suflê de vegetais
-- - Waffle Funcional: Imagem de waffle saudável  
-- - Suflê Vegano: Imagem de suflê vegano
-- - Torta de Liquidificador: Imagem de torta salgada
-- - 100% cobertura de imagens apropriadas
-- ================================================================ 