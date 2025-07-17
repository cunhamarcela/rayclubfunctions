-- Verificar políticas RLS da tabela profiles
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
WHERE tablename = 'profiles' 
AND schemaname = 'public'
AND (qual::text LIKE '%photo_url%' OR with_check::text LIKE '%photo_url%');

-- Verificar constraints da tabela profiles
SELECT 
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'public.profiles'::regclass
AND pg_get_constraintdef(oid) LIKE '%photo_url%';

-- Verificar triggers na tabela profiles
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE event_object_table = 'profiles'
AND event_object_schema = 'public';

-- Verificar definição da coluna photo_url
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default,
    character_maximum_length
FROM information_schema.columns
WHERE table_name = 'profiles' 
AND table_schema = 'public'
AND column_name IN ('photo_url', 'profile_image_url');

-- Verificar se há check constraints específicos
SELECT 
    tc.constraint_name,
    tc.constraint_type,
    cc.check_clause
FROM information_schema.table_constraints tc
JOIN information_schema.check_constraints cc 
    ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name = 'profiles' 
AND tc.table_schema = 'public';

-- Verificar políticas RLS gerais da tabela profiles
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual::text as qual_text,
    with_check::text as with_check_text
FROM pg_policies 
WHERE tablename = 'profiles' 
AND schemaname = 'public'
ORDER BY policyname; 