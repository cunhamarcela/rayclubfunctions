-- ========================================
-- VERIFICAÇÃO RÁPIDA DE ESTRUTURA
-- ========================================

-- 1. LISTAR TODAS AS TABELAS RELACIONADAS A WORKOUT E USER
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public'
  AND (table_name LIKE '%workout%' OR table_name LIKE '%user%' OR table_name LIKE '%category%')
ORDER BY table_name;

-- 2. ESTRUTURA DETALHADA DAS TABELAS PRINCIPAIS
SELECT 
    '=== WORKOUT_VIDEOS ===' as table_info,
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'workout_videos'
ORDER BY ordinal_position;

-- 3. ESTRUTURA USER_PROGRESS_LEVEL
SELECT 
    '=== USER_PROGRESS_LEVEL ===' as table_info,
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_progress_level'
ORDER BY ordinal_position;

-- 4. ESTRUTURA WORKOUT_CATEGORIES (SE EXISTIR)
SELECT 
    '=== WORKOUT_CATEGORIES ===' as table_info,
    column_name,
    data_type,
    character_maximum_length,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'workout_categories'
ORDER BY ordinal_position;

-- 5. SAMPLE DATA - WORKOUT_VIDEOS
SELECT 
    '=== SAMPLE WORKOUT_VIDEOS ===' as data_info;
    
SELECT 
    id,
    title,
    category,
    instructor_name,
    pg_typeof(category) as category_type
FROM workout_videos 
LIMIT 5;

-- 6. SAMPLE DATA - USER_PROGRESS_LEVEL
SELECT 
    '=== SAMPLE USER_PROGRESS_LEVEL ===' as data_info;
    
SELECT 
    user_id,
    current_level,
    unlocked_features,
    level_expires_at
FROM user_progress_level 
LIMIT 5;

-- 7. SAMPLE DATA - WORKOUT_CATEGORIES (SE EXISTIR)
SELECT 
    '=== SAMPLE WORKOUT_CATEGORIES ===' as data_info;
    
SELECT *
FROM workout_categories 
LIMIT 5; 