-- ================================================================
-- SCRIPT DE VERIFICAÇÃO: RECEITAS E SUAS IMAGENS
-- Data: 2025-01-21 21:35
-- Objetivo: Verificar se receitas têm imagens e testar conectividade
-- ================================================================

-- 1. Verificar total de receitas
SELECT 
    COUNT(*) as total_receitas
FROM recipes;

-- 2. Verificar receitas sem imagem
SELECT 
    COUNT(*) as receitas_sem_imagem
FROM recipes 
WHERE image_url IS NULL OR image_url = '';

-- 3. Verificar receitas com imagem
SELECT 
    COUNT(*) as receitas_com_imagem
FROM recipes 
WHERE image_url IS NOT NULL AND image_url != '';

-- 4. Listar primeiras 5 receitas com seus status de imagem
SELECT 
    id,
    title,
    CASE 
        WHEN image_url IS NULL OR image_url = '' THEN '❌ Sem imagem'
        ELSE '✅ Com imagem'
    END as status_imagem,
    CASE 
        WHEN LENGTH(image_url) > 50 THEN LEFT(image_url, 50) || '...'
        ELSE image_url
    END as imagem_preview
FROM recipes 
ORDER BY created_at DESC
LIMIT 5;

-- 5. Se houver receitas sem imagem, aplicar a primeira atualização de teste
UPDATE recipes 
SET image_url = 'https://images.unsplash.com/photo-1601218829154-7db94643a2ee?w=800&h=600&fit=crop&q=80'
WHERE (image_url IS NULL OR image_url = '')
  AND SPLIT_PART(title, ' ', 1) = 'Abobrinha'
  AND EXISTS (
    SELECT 1 FROM recipes 
    WHERE SPLIT_PART(title, ' ', 1) = 'Abobrinha'
    LIMIT 1
  );

-- 6. Verificar novamente o status após atualização de teste
SELECT 
    'Após atualização de teste:' as status,
    COUNT(*) as receitas_com_imagem
FROM recipes 
WHERE image_url IS NOT NULL AND image_url != ''; 