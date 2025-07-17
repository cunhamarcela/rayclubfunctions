-- Script para diagnosticar problemas de persistência na tabela profiles
-- Execute este script no SQL Editor do Supabase para verificar possíveis problemas

-- 1. Verificar se há triggers ativos na tabela profiles
SELECT 
    trigger_name,
    event_manipulation,
    action_timing,
    action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'profiles';

-- 2. Verificar se há políticas RLS ativas
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
WHERE tablename = 'profiles';

-- 3. Verificar se há colunas com valores padrão ou gerados
SELECT 
    column_name,
    data_type,
    column_default,
    is_nullable,
    is_identity,
    identity_generation,
    generation_expression
FROM information_schema.columns 
WHERE table_name = 'profiles' 
ORDER BY ordinal_position;

-- 4. Verificar se há funções que podem interferir
SELECT 
    routine_name,
    routine_type,
    routine_definition
FROM information_schema.routines 
WHERE routine_definition ILIKE '%profiles%' 
   OR routine_name ILIKE '%profile%';

-- 5. Verificar se há constraints especiais
SELECT 
    constraint_name,
    constraint_type,
    table_name,
    check_clause
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.check_constraints cc 
    ON tc.constraint_name = cc.constraint_name
WHERE tc.table_name = 'profiles';

-- 6. Teste de inserção e atualização simples
-- ATENÇÃO: Este comando deve ser executado com cuidado
-- Primeiro, vamos criar um usuário de teste

-- Inserir usuário de teste (se não existir)
INSERT INTO profiles (
    id, 
    name, 
    email, 
    created_at, 
    updated_at
) 
VALUES (
    '00000000-0000-0000-0000-000000000001',
    'TESTE INICIAL',
    'teste@exemplo.com',
    NOW(),
    NOW()
) 
ON CONFLICT (id) DO NOTHING;

-- Verificar se inserção funcionou
SELECT id, name, email, updated_at 
FROM profiles 
WHERE id = '00000000-0000-0000-0000-000000000001';

-- Fazer update de teste
UPDATE profiles 
SET 
    name = 'TESTE ATUALIZADO',
    updated_at = NOW()
WHERE id = '00000000-0000-0000-0000-000000000001';

-- Verificar se update funcionou
SELECT id, name, email, updated_at 
FROM profiles 
WHERE id = '00000000-0000-0000-0000-000000000001';

-- 7. Verificar logs de auditoria se existirem
-- (Alguns sistemas têm tabelas de auditoria)
SELECT table_name 
FROM information_schema.tables 
WHERE table_name LIKE '%audit%' 
   OR table_name LIKE '%log%'
   OR table_name LIKE '%history%';

-- 8. Verificar se há extensões que podem interferir
SELECT 
    extname as extension_name,
    extversion as version
FROM pg_extension;

-- 9. Verificar permissions na tabela
SELECT 
    grantee,
    privilege_type,
    is_grantable
FROM information_schema.role_table_grants 
WHERE table_name = 'profiles';

-- 10. Função para criar relatório de diagnóstico
CREATE OR REPLACE FUNCTION diagnose_profile_persistence()
RETURNS TABLE(
    item TEXT,
    status TEXT,
    details TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    trigger_count INTEGER;
    policy_count INTEGER;
    test_result TEXT;
BEGIN
    -- Contar triggers
    SELECT COUNT(*) INTO trigger_count
    FROM information_schema.triggers 
    WHERE event_object_table = 'profiles';
    
    RETURN NEXT ('Triggers', 
                 CASE WHEN trigger_count > 0 THEN 'ENCONTRADOS' ELSE 'NENHUM' END,
                 trigger_count::TEXT || ' trigger(s) encontrado(s)');
    
    -- Contar políticas RLS
    SELECT COUNT(*) INTO policy_count
    FROM pg_policies 
    WHERE tablename = 'profiles';
    
    RETURN NEXT ('Políticas RLS', 
                 CASE WHEN policy_count > 0 THEN 'ATIVAS' ELSE 'NENHUMA' END,
                 policy_count::TEXT || ' política(s) encontrada(s)');
    
    -- Teste de persistência
    BEGIN
        -- Tentar inserir e atualizar registro de teste
        INSERT INTO profiles (
            id, 
            name, 
            email, 
            created_at, 
            updated_at
        ) VALUES (
            '00000000-0000-0000-0000-000000000002',
            'TESTE PERSISTENCIA',
            'persistencia@teste.com',
            NOW(),
            NOW()
        ) ON CONFLICT (id) DO UPDATE SET
            name = 'TESTE PERSISTENCIA ATUALIZADO',
            updated_at = NOW();
        
        -- Verificar se funcionou
        SELECT name INTO test_result
        FROM profiles 
        WHERE id = '00000000-0000-0000-0000-000000000002';
        
        RETURN NEXT ('Teste Persistência', 
                     'SUCESSO',
                     'Dados salvos: ' || COALESCE(test_result, 'NULL'));
        
        -- Limpar teste
        DELETE FROM profiles 
        WHERE id = '00000000-0000-0000-0000-000000000002';
        
    EXCEPTION WHEN OTHERS THEN
        RETURN NEXT ('Teste Persistência', 
                     'ERRO',
                     'Erro: ' || SQLERRM);
    END;
    
    RETURN;
END;
$$;

-- Executar diagnóstico
SELECT * FROM diagnose_profile_persistence();

-- 11. Limpar dados de teste
DELETE FROM profiles 
WHERE id IN (
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000002'
); 