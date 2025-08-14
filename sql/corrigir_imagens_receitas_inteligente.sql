-- ================================================================
-- SCRIPT INTELIGENTE: CORREÇÃO COMPLETA DE IMAGENS DAS RECEITAS
-- Data: 2025-01-21 21:50
-- Objetivo: Garantir que 100% das receitas tenham imagens corretas e coerentes
-- ================================================================

-- 🎯 ESTRATÉGIA HIERÁRQUICA:
-- 1. Mapeamento específico por título completo (receitas importantes)
-- 2. Análise semântica por palavras-chave múltiplas
-- 3. Mapeamento por categoria + ingrediente principal
-- 4. Fallback genérico por tipo de refeição
-- 5. Fallback final universal

-- ================================================================
-- ETAPA 1: CURADORIA MANUAL - RECEITAS ESPECÍFICAS IMPORTANTES
-- ================================================================

-- Receitas de café da manhã específicas
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1493770348161-369560ae357d?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%panqueca%' AND title ILIKE '%banana%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%vitamina%' AND title ILIKE '%banana%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1546549032-9571cd6b27df?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%açaí%' OR title ILIKE '%acai%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1562736171-5ac9f0b9b063?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%omelete%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1594997521863-9e894c150e18?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%aveia%' OR title ILIKE '%aveioca%';

-- Receitas com proteínas específicas
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%frango%' AND title ILIKE '%grelhado%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1560781290-7dc94c0f8f6f?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%salmão%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%atum%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1571091655789-405eb7a3a3a8?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%carne%' OR title ILIKE '%bife%';

-- Receitas veganas e vegetarianas
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%salada%' AND (title ILIKE '%verde%' OR title ILIKE '%folhas%');

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1601218829154-7db94643a2ee?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%abobrinha%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1617020671875-a2f8f7a6d7c8?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%berinjela%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%batata%';

-- Sobremesas e doces específicos
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%brigadeiro%' OR title ILIKE '%beijinho%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%bolo%' AND title ILIKE '%chocolate%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1571115764595-644a1f56a55c?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%bolo%' AND title ILIKE '%cenoura%';

UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=800&h=600&fit=crop&q=80'
WHERE title ILIKE '%brownie%' OR title ILIKE '%barra%' OR title ILIKE '%barrinha%';

-- ================================================================
-- ETAPA 2: ANÁLISE SEMÂNTICA POR PALAVRAS-CHAVE MÚLTIPLAS
-- ================================================================

-- Bebidas e smoothies
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (title ILIKE '%suco%' OR title ILIKE '%smoothie%' OR title ILIKE '%vitamina%' OR title ILIKE '%bebida%');

-- Lanches e petiscos
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1621504450181-5d356f61d307?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (title ILIKE '%lanche%' OR title ILIKE '%snack%' OR title ILIKE '%petisco%' OR title ILIKE '%aperitivo%');

-- Sopas e caldos
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (title ILIKE '%sopa%' OR title ILIKE '%caldo%' OR title ILIKE '%canja%');

-- Massas e carboidratos
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1549642085-98c71aa9425c?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (title ILIKE '%macarrão%' OR title ILIKE '%massa%' OR title ILIKE '%espaguete%' OR title ILIKE '%lasanha%');

-- Arroz e grãos
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (title ILIKE '%arroz%' OR title ILIKE '%quinoa%' OR title ILIKE '%risotto%');

-- Pães e padaria
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1549931319-a545dcf3bc73?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (title ILIKE '%pão%' OR title ILIKE '%torrada%' OR title ILIKE '%sanduíche%' OR title ILIKE '%wrap%');

-- ================================================================
-- ETAPA 3: MAPEAMENTO POR CATEGORIA + CONTEXTO
-- ================================================================

-- Café da manhã genérico
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1493770348161-369560ae357d?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND category ILIKE '%café%';

-- Almoço/Jantar genérico
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (category ILIKE '%almoço%' OR category ILIKE '%jantar%' OR category ILIKE '%principal%');

-- Sobremesas genéricas
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1587736783430-44b3715ad2b1?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (category ILIKE '%sobremesa%' OR category ILIKE '%doce%');

-- Lanches genéricos
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1621504450181-5d356f61d307?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (category ILIKE '%lanche%' OR category ILIKE '%snack%');

-- ================================================================
-- ETAPA 4: FALLBACK POR TIPO DE REFEIÇÃO (ANÁLISE DO HORÁRIO/CONTEXTO)
-- ================================================================

-- Receitas com indicadores de café da manhã
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (
    title ILIKE '%matinal%' OR 
    title ILIKE '%manhã%' OR 
    description ILIKE '%café da manhã%'
  );

-- Receitas com indicadores de almoço
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (
    description ILIKE '%almoço%' OR 
    description ILIKE '%refeição principal%'
  );

-- Receitas com indicadores de jantar
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (
    description ILIKE '%jantar%' OR 
    description ILIKE '%noturno%'
  );

-- ================================================================
-- ETAPA 5: FALLBACK FINAL UNIVERSAL
-- ================================================================

-- Receitas veganas/vegetarianas restantes
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (
    description ILIKE '%vegano%' OR 
    description ILIKE '%vegetariano%' OR
    tags && ARRAY['vegano', 'vegetariano']
  );

-- Receitas saudáveis/fitness restantes
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (
    description ILIKE '%saudável%' OR 
    description ILIKE '%fitness%' OR
    description ILIKE '%light%' OR
    tags && ARRAY['saudável', 'fitness', 'light']
  );

-- Receitas de proteína restantes
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '') 
  AND (
    description ILIKE '%proteína%' OR 
    description ILIKE '%protein%' OR
    tags && ARRAY['proteína', 'protein']
  );

-- ================================================================
-- ETAPA 6: FALLBACK ABSOLUTO - IMAGEM PADRÃO ATRATIVA
-- ================================================================

-- Para qualquer receita que ainda não tenha imagem
UPDATE recipes SET image_url = 'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=800&h=600&fit=crop&q=80'
WHERE image_url IS NULL OR image_url = '';

-- ================================================================
-- ETAPA 7: VERIFICAÇÃO FINAL
-- ================================================================

-- Verificar se ainda existem receitas sem imagem
SELECT 
    '✅ VERIFICAÇÃO FINAL' as status,
    COUNT(*) as total_receitas,
    COUNT(CASE WHEN image_url IS NOT NULL AND image_url != '' THEN 1 END) as com_imagem_final,
    COUNT(CASE WHEN image_url IS NULL OR image_url = '' THEN 1 END) as sem_imagem_final,
    CASE 
        WHEN COUNT(CASE WHEN image_url IS NULL OR image_url = '' THEN 1 END) = 0 
        THEN '🎉 SUCESSO: 100% das receitas têm imagens!'
        ELSE '⚠️ ATENÇÃO: Ainda há receitas sem imagem'
    END as resultado
FROM recipes;

-- Mostrar distribuição final de imagens
SELECT 
    '📊 DISTRIBUIÇÃO FINAL' as categoria,
    image_url,
    COUNT(*) as receitas_usando
FROM recipes 
GROUP BY image_url
ORDER BY receitas_usando DESC
LIMIT 10; 