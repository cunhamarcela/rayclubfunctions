-- =====================================================
-- SCRIPT: VERIFICAR ARQUIVO BENEFICIOS.PDF NO STORAGE
-- =====================================================
-- Data: 2025-01-21 às 23:50
-- Objetivo: Verificar se beneficios.pdf existe no bucket materials
-- Contexto: Implementação da tela de visualização PDF para usuários EXPERT
-- =====================================================

-- 1. VERIFICAR SE O BUCKET MATERIALS EXISTE
SELECT 
  'STATUS DO BUCKET MATERIALS:' as info,
  name,
  public,
  created_at,
  updated_at
FROM storage.buckets 
WHERE name = 'materials';

-- 2. LISTAR TODAS AS PASTAS NO BUCKET MATERIALS
SELECT DISTINCT
  'PASTAS EXISTENTES NO BUCKET:' as info,
  SPLIT_PART(name, '/', 1) as pasta,
  COUNT(*) as arquivos_na_pasta
FROM storage.objects 
WHERE bucket_id = 'materials'
  AND name LIKE '%/%'
GROUP BY SPLIT_PART(name, '/', 1)
ORDER BY pasta;

-- 3. VERIFICAR SE ARQUIVO BENEFICIOS.PDF EXISTE (CAMINHOS POSSÍVEIS)
SELECT 
  'VERIFICAÇÃO DO ARQUIVO BENEFICIOS.PDF:' as info,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM storage.objects 
      WHERE bucket_id = 'materials' 
      AND name = 'beneficios/beneficios.pdf'
    ) 
    THEN '✅ ARQUIVO beneficios/beneficios.pdf EXISTE' 
    ELSE '❌ ARQUIVO beneficios/beneficios.pdf NÃO ENCONTRADO' 
  END as status_beneficios_beneficios,

  CASE 
    WHEN EXISTS (
      SELECT 1 FROM storage.objects 
      WHERE bucket_id = 'materials' 
      AND name = 'beneficios.pdf'
    ) 
    THEN '✅ ARQUIVO beneficios.pdf EXISTE (RAIZ)' 
    ELSE '❌ ARQUIVO beneficios.pdf NÃO ENCONTRADO (RAIZ)' 
  END as status_beneficios_raiz,

  CASE 
    WHEN EXISTS (
      SELECT 1 FROM storage.objects 
      WHERE bucket_id = 'materials' 
      AND LOWER(name) LIKE '%beneficio%'
    ) 
    THEN '⚠️ ARQUIVO COM PALAVRA BENEFICIO ENCONTRADO' 
    ELSE '❌ NENHUM ARQUIVO COM PALAVRA BENEFICIO' 
  END as status_palavra_beneficio;

-- 4. BUSCAR POR VARIAÇÕES DO NOME BENEFÍCIOS
SELECT 
  'ARQUIVOS COM PALAVRA BENEFÍCIO:' as info,
  name,
  bucket_id,
  owner,
  created_at,
  metadata
FROM storage.objects 
WHERE bucket_id = 'materials'
  AND (
    LOWER(name) LIKE '%beneficio%' OR
    LOWER(name) LIKE '%benefit%' OR
    LOWER(name) LIKE '%parceiro%' OR
    LOWER(name) LIKE '%partner%'
  )
ORDER BY name;

-- 5. LISTAR TODOS OS ARQUIVOS PDF NO BUCKET
SELECT 
  'TODOS OS PDFs NO BUCKET:' as info,
  name,
  CASE 
    WHEN name LIKE '%musculacao%' THEN '💪 Musculação'
    WHEN name LIKE '%corrida%' THEN '🏃 Corrida'
    WHEN name LIKE '%nutrition%' THEN '🥗 Nutrição'
    WHEN name LIKE '%beneficio%' THEN '🎁 BENEFÍCIOS'
    ELSE '📄 Outros'
  END as categoria,
  created_at
FROM storage.objects 
WHERE bucket_id = 'materials'
  AND LOWER(name) LIKE '%.pdf'
ORDER BY 
  CASE 
    WHEN name LIKE '%beneficio%' THEN 1
    WHEN name LIKE '%musculacao%' THEN 2
    WHEN name LIKE '%corrida%' THEN 3
    WHEN name LIKE '%nutrition%' THEN 4
    ELSE 5
  END,
  name;

-- 6. CONTAR ARQUIVOS POR TIPO
SELECT 
  'ESTATÍSTICAS DO BUCKET:' as info,
  COUNT(*) as total_arquivos,
  COUNT(*) FILTER (WHERE LOWER(name) LIKE '%.pdf') as total_pdfs,
  COUNT(*) FILTER (WHERE name LIKE '%musculacao%') as arquivos_musculacao,
  COUNT(*) FILTER (WHERE name LIKE '%corrida%') as arquivos_corrida,
  COUNT(*) FILTER (WHERE name LIKE '%nutrition%') as arquivos_nutrition,
  COUNT(*) FILTER (WHERE LOWER(name) LIKE '%beneficio%') as arquivos_beneficios
FROM storage.objects 
WHERE bucket_id = 'materials';

-- 7. VERIFICAR POLÍTICAS DE ACESSO DO BUCKET
SELECT 
  'POLÍTICAS DE ACESSO AO STORAGE:' as info,
  policyname,
  tablename,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname LIKE '%materials%';

-- =====================================================
-- INSTRUÇÕES PARA PRÓXIMOS PASSOS
-- =====================================================

-- SE O ARQUIVO NÃO EXISTIR, VOCÊ DEVE:
-- 1. Fazer upload do arquivo beneficios.pdf para uma das seguintes localizações:
--    - beneficios/beneficios.pdf (RECOMENDADO - caminho usado no código)
--    - beneficios.pdf (alternativa)
--
-- 2. No Supabase Dashboard:
--    - Ir para Storage > materials
--    - Criar pasta "beneficios" (se não existir)
--    - Upload do arquivo "beneficios.pdf"
--
-- 3. Verificar permissões:
--    - O arquivo deve ser acessível por usuários autenticados
--    - RLS deve permitir leitura do bucket materials
--
-- 4. Testar no app:
--    - Login como usuário EXPERT
--    - Navegar para tela de Benefícios
--    - Verificar se o PDF carrega corretamente

SELECT 
  'PRÓXIMO PASSO:' as acao,
  'Se o arquivo beneficios/beneficios.pdf não existir, faça upload no Supabase Storage > materials > beneficios/' as instrucao; 