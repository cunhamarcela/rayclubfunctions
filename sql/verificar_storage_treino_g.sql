-- =====================================================
-- SCRIPT: VERIFICAR STORAGE DO TREINO G
-- =====================================================
-- Data: 2025-01-21
-- Objetivo: Verificar se o arquivo PDF do Treino G existe no storage
-- =====================================================

-- 1. VERIFICAR ARQUIVOS DE MUSCULAÇÃO NO STORAGE
SELECT 
  'ARQUIVOS PDF MUSCULAÇÃO NO STORAGE:' as info,
  name,
  bucket_id,
  CASE 
    WHEN name LIKE '%TREINO G%' THEN '🎯 TREINO G'
    WHEN name LIKE '%TREINO A%' THEN 'Treino A'
    WHEN name LIKE '%TREINO B%' THEN 'Treino B'
    WHEN name LIKE '%TREINO C%' THEN 'Treino C'
    WHEN name LIKE '%TREINO D%' THEN 'Treino D'
    WHEN name LIKE '%TREINO E%' THEN 'Treino E'
    WHEN name LIKE '%TREINO F%' THEN 'Treino F'
    ELSE 'Outro'
  END as treino_tipo,
  created_at,
  updated_at
FROM storage.objects 
WHERE bucket_id = 'materials'
  AND name LIKE '%musculacao%'
  AND name LIKE '%.pdf'
ORDER BY 
  CASE 
    WHEN name LIKE '%TREINO A%' THEN 1
    WHEN name LIKE '%TREINO B%' THEN 2
    WHEN name LIKE '%TREINO C%' THEN 3
    WHEN name LIKE '%TREINO D%' THEN 4
    WHEN name LIKE '%TREINO E%' THEN 5
    WHEN name LIKE '%TREINO F%' THEN 6
    WHEN name LIKE '%TREINO G%' THEN 7
    ELSE 8
  END;

-- 2. VERIFICAR ESPECIFICAMENTE SE TREINO G EXISTE
SELECT 
  'VERIFICAÇÃO TREINO G STORAGE:' as info,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM storage.objects 
      WHERE bucket_id = 'materials' 
      AND name = 'musculacao/TREINO G.pdf'
    ) 
    THEN '✅ ARQUIVO TREINO G.pdf EXISTE NO STORAGE' 
    ELSE '❌ ARQUIVO TREINO G.pdf NÃO ENCONTRADO NO STORAGE' 
  END as status_arquivo;

-- 3. VERIFICAR VARIAÇÕES DO NOME DO ARQUIVO
SELECT 
  'POSSÍVEIS VARIAÇÕES TREINO G:' as info,
  name,
  bucket_id,
  created_at
FROM storage.objects 
WHERE bucket_id = 'materials'
  AND (
    LOWER(name) LIKE '%treino g%' OR
    UPPER(name) LIKE '%TREINO G%' OR
    name LIKE '%G.pdf' OR
    name LIKE '%g.pdf'
  );

-- 4. VERIFICAR TODOS OS ARQUIVOS PDF DE TREINO
SELECT 
  'TODOS OS PDFs DE TREINO:' as info,
  name,
  CASE 
    WHEN UPPER(name) LIKE '%TREINO A%' THEN 'A ✅'
    WHEN UPPER(name) LIKE '%TREINO B%' THEN 'B ✅'
    WHEN UPPER(name) LIKE '%TREINO C%' THEN 'C ✅'
    WHEN UPPER(name) LIKE '%TREINO D%' THEN 'D ✅'
    WHEN UPPER(name) LIKE '%TREINO E%' THEN 'E ✅'
    WHEN UPPER(name) LIKE '%TREINO F%' THEN 'F ✅'
    WHEN UPPER(name) LIKE '%TREINO G%' THEN 'G ✅'
    ELSE 'Outro'
  END as treino_identificado,
  created_at
FROM storage.objects 
WHERE bucket_id = 'materials'
  AND name LIKE '%musculacao%'
  AND name LIKE '%.pdf'
ORDER BY name;

-- 5. SCRIPT PARA INSERIR ARQUIVO NO STORAGE (SE NECESSÁRIO)
-- Este é um template - você precisará fazer o upload manual do arquivo primeiro

/*
-- EXEMPLO DE INSERT NO STORAGE (apenas se o arquivo foi uploadado)
INSERT INTO storage.objects (
  bucket_id,
  name,
  owner,
  created_at,
  updated_at,
  last_accessed_at,
  metadata
)
VALUES (
  'materials',
  'musculacao/TREINO G.pdf',
  auth.uid(),
  NOW(),
  NOW(),
  NOW(),
  '{"eTag": "\"example-etag\"", "size": 1024000, "mimetype": "application/pdf", "cacheControl": "max-age=3600"}'
);
*/

-- 6. RESUMO FINAL DO STORAGE
SELECT 
  'RESUMO STORAGE MUSCULAÇÃO:' as info,
  COUNT(*) as total_arquivos_pdf,
  COUNT(*) FILTER (WHERE UPPER(name) LIKE '%TREINO A%') as treino_a,
  COUNT(*) FILTER (WHERE UPPER(name) LIKE '%TREINO B%') as treino_b,
  COUNT(*) FILTER (WHERE UPPER(name) LIKE '%TREINO C%') as treino_c,
  COUNT(*) FILTER (WHERE UPPER(name) LIKE '%TREINO D%') as treino_d,
  COUNT(*) FILTER (WHERE UPPER(name) LIKE '%TREINO E%') as treino_e,
  COUNT(*) FILTER (WHERE UPPER(name) LIKE '%TREINO F%') as treino_f,
  COUNT(*) FILTER (WHERE UPPER(name) LIKE '%TREINO G%') as treino_g,
  CASE 
    WHEN COUNT(*) FILTER (WHERE UPPER(name) LIKE '%TREINO G%') > 0 
    THEN '✅ TREINO G PRESENTE NO STORAGE'
    ELSE '❌ TREINO G AUSENTE NO STORAGE - FAZER UPLOAD'
  END as status_treino_g
FROM storage.objects 
WHERE bucket_id = 'materials'
  AND name LIKE '%musculacao%'
  AND name LIKE '%.pdf';

-- Orientação para próximos passos
SELECT 
  'PRÓXIMOS PASSOS:' as info,
  'Se o arquivo não existir no storage, você precisará fazer o upload do arquivo TREINO G.pdf para a pasta musculacao/ no bucket materials' as orientacao; 