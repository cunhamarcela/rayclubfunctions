-- ========================================
-- SCRIPT DE INVESTIGAÇÃO - ESTRUTURA DE VÍDEOS E USUÁRIOS
-- ========================================

-- 1. INVESTIGAR ESTRUTURA DA TABELA WORKOUT_VIDEOS
SELECT 
    '=== ESTRUTURA DA TABELA WORKOUT_VIDEOS ===' as info;

-- Verificar colunas da tabela workout_videos
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'workout_videos' 
ORDER BY ordinal_position;

-- 2. AMOSTRAS DE DADOS DOS VÍDEOS
SELECT 
    '=== AMOSTRAS DE DADOS DOS VÍDEOS ===' as info;

-- Ver alguns registros para entender a estrutura
SELECT 
    id,
    title,
    category,
    instructor_name,
    duration,
    difficulty,
    created_at
FROM workout_videos 
LIMIT 10;

-- 3. INVESTIGAR CATEGORIAS
SELECT 
    '=== ANÁLISE DAS CATEGORIAS ===' as info;

-- Ver todas as categorias únicas
SELECT 
    category,
    COUNT(*) as quantidade_videos,
    array_agg(DISTINCT instructor_name) as instrutores
FROM workout_videos 
GROUP BY category 
ORDER BY quantidade_videos DESC;

-- 4. VERIFICAR SE EXISTE TABELA DE CATEGORIAS SEPARADA
SELECT 
    '=== VERIFICANDO TABELA DE CATEGORIAS ===' as info;

-- Listar todas as tabelas que contêm 'category' no nome
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_name LIKE '%category%' 
   OR table_name LIKE '%categories%'
ORDER BY table_name;

-- 5. SE EXISTE TABELA WORKOUT_CATEGORIES, INVESTIGAR
SELECT 
    '=== ESTRUTURA WORKOUT_CATEGORIES (SE EXISTIR) ===' as info;

-- Tentar ver a estrutura da tabela de categorias
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'workout_categories' 
ORDER BY ordinal_position;

-- 6. VER DADOS DA TABELA DE CATEGORIAS (SE EXISTIR)
SELECT 
    '=== DADOS DAS CATEGORIAS (SE EXISTIR) ===' as info;

-- Tentar buscar dados das categorias
SELECT *
FROM workout_categories
LIMIT 10;

-- 7. VERIFICAR RELAÇÃO ENTRE WORKOUT_VIDEOS E CATEGORIAS
SELECT 
    '=== RELAÇÃO VÍDEOS X CATEGORIAS ===' as info;

-- Tentar fazer join para ver se category é um ID que referencia outra tabela
SELECT 
    wv.id as video_id,
    wv.title,
    wv.category as category_field,
    wc.id as category_id,
    wc.name as category_name
FROM workout_videos wv
LEFT JOIN workout_categories wc ON wv.category = wc.id::varchar
   OR wv.category = wc.id::text
   OR wv.category::uuid = wc.id
LIMIT 10;

-- 8. INVESTIGAR TABELA USER_PROGRESS_LEVEL
SELECT 
    '=== ESTRUTURA USER_PROGRESS_LEVEL ===' as info;

-- Ver estrutura da tabela de níveis de usuário
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_progress_level' 
ORDER BY ordinal_position;

-- 9. AMOSTRAS DE DADOS DOS USUÁRIOS
SELECT 
    '=== AMOSTRAS DE NÍVEIS DE USUÁRIOS ===' as info;

-- Ver alguns registros de usuários
SELECT 
    user_id,
    current_level,
    level_expires_at,
    unlocked_features,
    created_at,
    updated_at
FROM user_progress_level 
LIMIT 10;

-- 10. ANÁLISE DOS NÍVEIS DE USUÁRIOS
SELECT 
    '=== ANÁLISE DOS NÍVEIS DE USUÁRIOS ===' as info;

-- Contar usuários por nível
SELECT 
    current_level,
    COUNT(*) as quantidade_usuarios,
    COUNT(*) FILTER (WHERE level_expires_at IS NULL) as permanentes,
    COUNT(*) FILTER (WHERE level_expires_at > NOW()) as ativos,
    COUNT(*) FILTER (WHERE level_expires_at <= NOW()) as expirados
FROM user_progress_level 
GROUP BY current_level;

-- 11. FEATURES DISPONÍVEIS POR NÍVEL
SELECT 
    '=== FEATURES POR NÍVEL ===' as info;

-- Ver features únicas por nível
SELECT 
    current_level,
    unnest(unlocked_features) as feature,
    COUNT(*) as usuarios_com_feature
FROM user_progress_level 
GROUP BY current_level, unnest(unlocked_features)
ORDER BY current_level, feature;

-- 12. VERIFICAR VÍDEOS DOS PARCEIROS ESPECÍFICOS
SELECT 
    '=== VÍDEOS DOS PARCEIROS ===' as info;

-- Buscar vídeos que podem ser dos parceiros mencionados
SELECT 
    id,
    title,
    instructor_name,
    category,
    created_at
FROM workout_videos 
WHERE instructor_name ILIKE '%musculação%'
   OR instructor_name ILIKE '%goya%'
   OR instructor_name ILIKE '%fight%'
   OR instructor_name ILIKE '%bora%'
   OR instructor_name ILIKE '%unit%'
   OR instructor_name ILIKE '%pilates%'
   OR instructor_name ILIKE '%funcional%'
   OR instructor_name ILIKE '%corrida%'
   OR instructor_name ILIKE '%fisioterapia%'
ORDER BY instructor_name, created_at;

-- 13. INVESTIGAR POLÍTICAS RLS ATUAIS
SELECT 
    '=== POLÍTICAS RLS WORKOUT_VIDEOS ===' as info;

-- Ver políticas atuais na tabela workout_videos
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- 14. VERIFICAR SE RLS ESTÁ HABILITADO
SELECT 
    '=== STATUS RLS ===' as info;

-- Verificar se Row Level Security está habilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity,
    forcerowsecurity
FROM pg_tables 
WHERE tablename IN ('workout_videos', 'user_progress_level');

-- 15. RESUMO FINAL
SELECT 
    '=== RESUMO PARA ANÁLISE ===' as info;

SELECT 
    'Total de vídeos' as metrica,
    COUNT(*)::text as valor
FROM workout_videos
UNION ALL
SELECT 
    'Categorias únicas',
    COUNT(DISTINCT category)::text
FROM workout_videos
UNION ALL
SELECT 
    'Instrutores únicos',
    COUNT(DISTINCT instructor_name)::text
FROM workout_videos
UNION ALL
SELECT 
    'Total de usuários',
    COUNT(*)::text
FROM user_progress_level
UNION ALL
SELECT 
    'Usuários basic',
    COUNT(*)::text
FROM user_progress_level 
WHERE current_level = 'basic'
UNION ALL
SELECT 
    'Usuários expert',
    COUNT(*)::text
FROM user_progress_level 
WHERE current_level = 'expert'; 