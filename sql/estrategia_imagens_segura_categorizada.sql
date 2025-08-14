-- ================================================================
-- ESTRATÉGIA SEGURA: IMAGENS POR CATEGORIAS CONSISTENTES
-- Data: 2025-01-21 22:25
-- Problema: Imagens embaralhadas e incoerentes com receitas
-- Solução: Categorização ampla + Imagens genéricas coerentes
-- ================================================================

-- 🎯 ESTRATÉGIA CONSERVADORA:
-- 1. Categorizar receitas por TIPO DE PRATO (não por ingredientes específicos)
-- 2. Usar imagens GENÉRICAS mas sempre COERENTES 
-- 3. Fallback seguro para 100% cobertura
-- 4. Permite verificação e correção manual posterior

-- ================================================================
-- ETAPA 1: BACKUP DE SEGURANÇA
-- ================================================================

-- Backup das imagens atuais (caso precise reverter)
CREATE TABLE recipes_images_backup AS
SELECT id, title, image_url, NOW() as backup_timestamp
FROM recipes;

-- ================================================================
-- ETAPA 2: DEFINIR CATEGORIAS SEGURAS E AMPLAS
-- ================================================================

-- 🥞 CATEGORIA: PANQUECAS E CREPES
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%PANQUECA%' 
   OR UPPER(title) LIKE '%CREPE%'
   OR UPPER(title) LIKE '%AVEIOCA%';

-- 🍰 CATEGORIA: BOLOS E DOCES
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%BOLO%' 
   OR UPPER(title) LIKE '%MUFFIN%'
   OR UPPER(title) LIKE '%BEIJINHO%'
   OR UPPER(title) LIKE '%PRESTÍGIO%'
   OR UPPER(title) LIKE '%MOUSSE%';

-- 🥤 CATEGORIA: BEBIDAS E SMOOTHIES
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%SMOOTHIE%' 
   OR UPPER(title) LIKE '%SUCO%'
   OR UPPER(title) LIKE '%VITAMINA%'
   OR UPPER(title) LIKE '%BEBIDA%';

-- 🍞 CATEGORIA: PÃES E MASSAS
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%PÃO%' 
   OR UPPER(title) LIKE '%MASSA%'
   OR UPPER(title) LIKE '%NHOQUE%'
   OR UPPER(title) LIKE '%ESPAGUETE%'
   OR UPPER(title) LIKE '%LASANHA%'
   OR UPPER(title) LIKE '%RAVIOLI%';

-- 🥗 CATEGORIA: SALADAS E PRATOS LEVES
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%SALADA%' 
   OR UPPER(title) LIKE '%PATÊ%'
   OR UPPER(title) LIKE '%PASTINHA%'
   OR UPPER(title) LIKE '%MOLHO%';

-- 🍲 CATEGORIA: SOPAS E CALDOS
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1547592180-85f173990554?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%CALDO%' 
   OR UPPER(title) LIKE '%SOPA%'
   OR UPPER(title) LIKE '%CANJA%';

-- 🍗 CATEGORIA: PRATOS COM FRANGO
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%FRANGO%' 
   OR UPPER(title) LIKE '%COXINHA%'
   OR UPPER(title) LIKE '%NUGGETS%';

-- 🥚 CATEGORIA: OVOS E OMELETES
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1506806732259-39c2d0268443?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%OMELETE%' 
   OR UPPER(title) LIKE '%OVO%'
   OR UPPER(title) LIKE '%MEXIDO%'
   OR UPPER(title) LIKE '%GRÃOMELETE%';

-- 🍕 CATEGORIA: PIZZAS E QUICHES
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%PIZZA%' 
   OR UPPER(title) LIKE '%QUICHE%'
   OR UPPER(title) LIKE '%TORTINHA%';

-- 🍆 CATEGORIA: VEGETAIS E LEGUMES
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%BERINJELA%' 
   OR UPPER(title) LIKE '%ABOBRINHA%'
   OR UPPER(title) LIKE '%CENOURA%'
   OR UPPER(title) LIKE '%BETERRABA%'
   OR UPPER(title) LIKE '%ESPINAFRE%';

-- 🧄 CATEGORIA: SNACKS E APERITIVOS
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1559058922-a46d78e70833?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%SNACKS%' 
   OR UPPER(title) LIKE '%CHIPS%'
   OR UPPER(title) LIKE '%FALAFEL%'
   OR UPPER(title) LIKE '%HAMBÚRGUER%';

-- 🍌 CATEGORIA: FRUTAS E SOBREMESAS COM FRUTAS
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1490818387583-1baba5e638af?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%BANANA%' 
   OR UPPER(title) LIKE '%MORANGO%'
   OR UPPER(title) LIKE '%FRUTAS%'
   OR UPPER(title) LIKE '%MARACUJÁ%'
   OR UPPER(title) LIKE '%PICOLÉ%'
   OR UPPER(title) LIKE '%SORBET%';

-- 🥥 CATEGORIA: SOBREMESAS E DOCES ELABORADOS
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400&h=300&fit=crop'
WHERE UPPER(title) LIKE '%SORVETE%' 
   OR UPPER(title) LIKE '%GRANOLA%'
   OR UPPER(title) LIKE '%BARRINHA%'
   OR UPPER(title) LIKE '%PROTEÍNA%';

-- ================================================================
-- ETAPA 3: FALLBACK UNIVERSAL PARA RECEITAS SEM CATEGORIA
-- ================================================================

-- Imagem genérica de comida saudável para receitas não categorizadas
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=300&fit=crop'
WHERE image_url IS NULL 
   OR image_url = '' 
   OR image_url = 'https://via.placeholder.com/300x200.png?text=Receita';

-- ================================================================
-- ETAPA 4: VERIFICAÇÃO FINAL
-- ================================================================

-- Verificar cobertura total
SELECT 
    '✅ VERIFICAÇÃO FINAL' as resultado,
    COUNT(*) as total_receitas,
    COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) as com_imagem,
    COUNT(CASE WHEN image_url IS NULL OR image_url = '' THEN 1 END) as sem_imagem,
    ROUND(
        COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) * 100.0 / COUNT(*), 
        2
    ) as percentual_cobertura
FROM recipes;

-- Mostrar distribuição por categorias
SELECT 
    '📊 DISTRIBUIÇÃO POR IMAGEM' as categoria,
    image_url,
    COUNT(*) as receitas_com_esta_imagem
FROM recipes
GROUP BY image_url
ORDER BY COUNT(*) DESC;

-- Listar algumas receitas para verificação manual
SELECT 
    '🔍 AMOSTRA PARA VERIFICAÇÃO' as categoria,
    title,
    CASE 
        WHEN image_url LIKE '%1567620905732%' THEN 'Panquecas/Crepes'
        WHEN image_url LIKE '%1578985545062%' THEN 'Bolos/Doces'
        WHEN image_url LIKE '%1553530666%' THEN 'Bebidas/Smoothies'
        WHEN image_url LIKE '%1509440159596%' THEN 'Pães/Massas'
        WHEN image_url LIKE '%1512621776951%' THEN 'Saladas/Leves'
        WHEN image_url LIKE '%1547592180%' THEN 'Sopas/Caldos'
        WHEN image_url LIKE '%1532550907401%' THEN 'Pratos com Frango'
        WHEN image_url LIKE '%1506806732259%' THEN 'Ovos/Omeletes'
        WHEN image_url LIKE '%1513104890138%' THEN 'Pizzas/Quiches'
        WHEN image_url LIKE '%1540420773420%' THEN 'Vegetais/Legumes'
        WHEN image_url LIKE '%1559058922%' THEN 'Snacks/Aperitivos'
        WHEN image_url LIKE '%1490818387583%' THEN 'Frutas/Sobremesas'
        WHEN image_url LIKE '%1488477181946%' THEN 'Sobremesas Elaboradas'
        WHEN image_url LIKE '%1490645935967%' THEN 'Genérica Saudável'
        ELSE 'Outra categoria'
    END as categoria_atribuida
FROM recipes
ORDER BY title
LIMIT 20;

-- ================================================================
-- ETAPA 5: SCRIPT DE CORREÇÃO MANUAL (PARA CASOS ESPECÍFICOS)
-- ================================================================

-- Use este template para corrigir receitas específicas manualmente:
/*
-- Exemplo: Corrigir receita específica que ficou com categoria errada
UPDATE recipes 
SET image_url = 'URL_CORRETA_AQUI'
WHERE title = 'TÍTULO_EXATO_DA_RECEITA';
*/

-- ================================================================
-- PRÓXIMOS PASSOS:
-- 1. Execute este script
-- 2. Verifique os resultados de distribuição
-- 3. Teste algumas imagens no navegador
-- 4. Faça correções manuais se necessário
-- 5. Teste no app Flutter
-- ================================================================ 