-- =====================================================
-- SCRIPT: INSERIR EBOOK DE VERÃO PARA NUTRIÇÃO
-- =====================================================
-- Data: Janeiro 2025
-- Descrição: Adicionar "Ebook de Verao.pdf" na seção materiais da tela de nutrição
-- Arquivo: Ebook de Verao.pdf (já disponível no bucket materials)
-- =====================================================

-- =====================================================
-- PARTE 1: VERIFICAR SE O ARQUIVO EXISTE NO STORAGE
-- =====================================================

-- Verificar se o bucket materials existe
SELECT name, public 
FROM storage.buckets 
WHERE name = 'materials';

-- Listar arquivos no bucket para confirmar o ebook
SELECT name, metadata 
FROM storage.objects 
WHERE bucket_id = 'materials' 
  AND name ILIKE '%ebook%verao%' OR name ILIKE '%Ebook de Verao%';

-- =====================================================
-- PARTE 2: INSERIR EBOOK NA TABELA MATERIALS
-- =====================================================

-- Inserir o Ebook de Verão como material de nutrição
INSERT INTO materials (
    title,
    description,
    material_type,
    material_context,
    file_path,
    author_name,
    order_index,
    is_featured,
    requires_expert_access,
    created_at,
    updated_at
) VALUES (
    'Ebook de Verão ☀️',
    'Guia completo com receitas leves e refrescantes para os dias mais quentes. Inclui dicas de hidratação, lanches saudáveis e refeições nutritivas perfeitas para o verão.',
    'ebook',
    'nutrition',
    'Ebook de Verao.pdf',
    'Ray Club',
    1, -- Primeira posição na lista de materiais
    true, -- Destacar como material em destaque
    false, -- Acessível para todos os usuários
    NOW(),
    NOW()
);

-- =====================================================
-- PARTE 3: VERIFICAR SE O MATERIAL FOI INSERIDO
-- =====================================================

-- Verificar se o material foi criado corretamente
SELECT 
    id,
    title,
    description,
    material_type,
    material_context,
    file_path,
    author_name,
    order_index,
    is_featured,
    requires_expert_access,
    created_at
FROM materials 
WHERE material_context = 'nutrition' 
  AND title ILIKE '%ebook%verão%'
ORDER BY order_index ASC, created_at DESC;

-- Contar total de materiais de nutrição
SELECT 
    'Total de materiais de nutrição' as info,
    COUNT(*) as quantidade
FROM materials 
WHERE material_context = 'nutrition';

-- =====================================================
-- PARTE 4: VERIFICAR POLÍTICAS RLS
-- =====================================================

-- Verificar se as políticas RLS permitem acesso aos materiais
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'materials';

-- =====================================================
-- LOGS DE SUCESSO
-- =====================================================

DO $$
BEGIN
    RAISE NOTICE '✅ Ebook de Verão adicionado com sucesso!';
    RAISE NOTICE '📚 Material: Ebook de Verão ☀️';
    RAISE NOTICE '🥗 Contexto: Nutrição';
    RAISE NOTICE '📄 Tipo: Ebook (PDF)';
    RAISE NOTICE '⭐ Status: Em destaque na primeira posição';
    RAISE NOTICE '🌍 Acesso: Disponível para todos os usuários';
    RAISE NOTICE '📱 Visualização: Disponível na aba "Materiais" da tela de nutrição';
END $$; 