-- Script para verificar treinos com imagens no banco
-- Buscar treinos que têm imagens (não null e não vazio)

-- 1. Contar total de treinos
SELECT 'Total de treinos' as tipo, COUNT(*) as quantidade
FROM workout_records;

-- 2. Contar treinos com image_urls não null
SELECT 'Treinos com image_urls não null' as tipo, COUNT(*) as quantidade  
FROM workout_records 
WHERE image_urls IS NOT NULL;

-- 3. Contar treinos com image_urls como array vazio
SELECT 'Treinos com image_urls = []' as tipo, COUNT(*) as quantidade
FROM workout_records 
WHERE image_urls = '[]'::jsonb;

-- 4. Contar treinos que realmente têm imagens
SELECT 'Treinos com imagens reais' as tipo, COUNT(*) as quantidade
FROM workout_records 
WHERE image_urls IS NOT NULL 
  AND image_urls != '[]'::jsonb 
  AND jsonb_array_length(image_urls) > 0;

-- 5. Mostrar exemplos de treinos com imagens (se existirem)
SELECT 
  id, 
  workout_name, 
  image_urls,
  jsonb_array_length(image_urls) as num_images,
  created_at
FROM workout_records 
WHERE image_urls IS NOT NULL 
  AND image_urls != '[]'::jsonb 
  AND jsonb_array_length(image_urls) > 0
ORDER BY created_at DESC
LIMIT 5;

-- 6. Verificar estrutura da coluna image_urls
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'workout_records' 
  AND column_name = 'image_urls'; 