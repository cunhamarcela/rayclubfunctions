-- Teste corrigido - usando 'category' ao invés de 'category_id'

-- 1. CONTAR vídeos total
SELECT 'VÍDEOS TOTAL NO BANCO:' as tipo, COUNT(*) as total
FROM workout_videos;

-- 2. CONTAR por tipo de acesso
SELECT 
    'Expert-only (parceiros):' as tipo,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = true;

SELECT 
    'Públicos:' as tipo,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = false OR requires_expert_access IS NULL;

-- 3. VERIFICAR se há vídeos públicos (que TODOS deveriam ver)
SELECT 
    'VÍDEOS PÚBLICOS (todos podem ver):' as debug_step;

SELECT 
    title,
    instructor_name,
    category,
    requires_expert_access
FROM workout_videos 
WHERE requires_expert_access = false OR requires_expert_access IS NULL
ORDER BY category, instructor_name, title
LIMIT 10;

-- 4. ANÁLISE POR CATEGORIA (usando campo 'category' correto)
SELECT 
    'ANÁLISE POR CATEGORIA:' as debug_step;

SELECT 
    category,
    COUNT(*) as total_videos,
    COUNT(CASE WHEN requires_expert_access = true THEN 1 END) as expert_only,
    COUNT(CASE WHEN requires_expert_access = false OR requires_expert_access IS NULL THEN 1 END) as public_videos
FROM workout_videos 
GROUP BY category
ORDER BY category;

-- 5. VERIFICAR estrutura da tabela
SELECT 
    'ESTRUTURA DA TABELA:' as debug_step;

SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'workout_videos' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 6. MOSTRAR categorias que aparecem no Flutter
SELECT 
    'CATEGORIAS DISPONÍVEIS:' as debug_step;

SELECT DISTINCT 
    category,
    COUNT(*) as videos_count
FROM workout_videos 
GROUP BY category
ORDER BY category;

-- 7. PROBLEMA PROVÁVEL: Flutter filtra por categoria e some os vídeos
SELECT 
    'PROBLEMA IDENTIFICADO:' as debug_step;

SELECT 'O Flutter provavelmente faz consultas como:' as explicacao1;
SELECT 'supabase.from("workout_videos").select().eq("category", "alguma_categoria")' as explicacao2;
SELECT 'Se a categoria específica só tem vídeos expert-only, usuários basic não veem nada' as explicacao3;
SELECT 'E se não há vídeos públicos naquela categoria, experts também não veem nada' as explicacao4;

-- 8. TESTE ESPECÍFICO: Verificar categoria por categoria
SELECT 
    'TESTE POR CATEGORIA ESPECÍFICA:' as debug_step;

-- Categorias que provavelmente aparecem no Flutter
SELECT 
    category,
    'Expert pode ver:' as tipo,
    COUNT(CASE WHEN requires_expert_access = true OR requires_expert_access = false OR requires_expert_access IS NULL THEN 1 END) as total_for_expert
FROM workout_videos 
WHERE category IN ('musculacao', 'corrida', 'pilates', 'funcional', 'fisioterapia', 'fight fit')
GROUP BY category;

SELECT 
    category,
    'Basic pode ver:' as tipo,
    COUNT(CASE WHEN requires_expert_access = false OR requires_expert_access IS NULL THEN 1 END) as total_for_basic
FROM workout_videos 
WHERE category IN ('musculacao', 'corrida', 'pilates', 'funcional', 'fisioterapia', 'fight fit')
GROUP BY category; 