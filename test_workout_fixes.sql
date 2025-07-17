-- Script para testar as correções na função record_workout_basic
-- Executar no Console SQL do Supabase

-- 1. Verificar se a função existe
SELECT EXISTS (
    SELECT 1 
    FROM pg_proc 
    WHERE proname = 'record_workout_basic'
) AS function_exists;

-- 2. Verificar parâmetros da função (deve incluir p_notes e p_workout_record_id)
SELECT 
    p.proname AS function_name,
    pg_get_function_arguments(p.oid) AS arguments
FROM pg_proc p
WHERE p.proname = 'record_workout_basic';

-- 3. Testar o registro de treino com challenge_id do desafio das embaixadoras
-- Selecione um usuário válido do sistema para o teste
DO $$
DECLARE
    test_user_id UUID;
    test_challenge_id UUID := '0d03fbe2-a290-4681-8656-c985106845c9'; -- ID do desafio das embaixadoras
    result JSONB;
    workout_id UUID;
BEGIN
    -- Obter um usuário válido para teste
    SELECT id INTO test_user_id FROM profiles LIMIT 1;
    
    IF test_user_id IS NULL THEN
        RAISE EXCEPTION 'Nenhum usuário encontrado para teste';
    END IF;
    
    -- Verificar se o desafio existe
    IF NOT EXISTS (SELECT 1 FROM challenges WHERE id = test_challenge_id) THEN
        RAISE EXCEPTION 'Desafio de teste não encontrado. ID: %', test_challenge_id;
    END IF;
    
    RAISE NOTICE 'Iniciando teste com usuário % e desafio %', test_user_id, test_challenge_id;
    
    -- Testar a função com workout_id como texto (simulando erro de tipagem)
    result := record_workout_basic(
        p_user_id := test_user_id,
        p_workout_name := 'Treino de Teste',
        p_workout_type := 'Teste',
        p_duration_minutes := 30,
        p_date := NOW(),
        p_challenge_id := test_challenge_id,
        p_workout_id := 'teste-123-abc',  -- String inválida como UUID
        p_notes := 'Teste de correção de função'
    );
    
    -- Verificar resultado
    RAISE NOTICE 'Resultado: %', result;
    
    IF (result->>'success')::BOOLEAN THEN
        workout_id := (result->>'workout_id')::UUID;
        RAISE NOTICE '✅ Teste bem-sucedido! ID do treino criado: %', workout_id;
        
        -- Verificar se o registro foi realmente criado
        IF EXISTS (SELECT 1 FROM workout_records WHERE id = workout_id) THEN
            RAISE NOTICE '✅ Registro confirmado no banco de dados!';
            
            -- Verificar se o challenge_id foi salvo corretamente
            SELECT challenge_id INTO STRICT test_challenge_id 
            FROM workout_records 
            WHERE id = workout_id;
            
            IF test_challenge_id = '0d03fbe2-a290-4681-8656-c985106845c9' THEN
                RAISE NOTICE '✅ O challenge_id foi salvo corretamente!';
            ELSE
                RAISE NOTICE '❌ O challenge_id não foi salvo corretamente! Valor: %', test_challenge_id;
            END IF;
        ELSE
            RAISE NOTICE '❌ Registro não encontrado na tabela workout_records!';
        END IF;
    ELSE
        RAISE NOTICE '❌ Teste falhou: %', result->>'message';
    END IF;
    
    -- Limpar dados de teste
    DELETE FROM workout_records WHERE id = workout_id;
    RAISE NOTICE 'Dados de teste limpos.';
END $$;

-- 4. Verificar as políticas RLS para upload de imagens
SELECT 
    pol.polname AS policy_name,
    rel.relname AS table_name, 
    pg_catalog.pg_get_expr(pol.polqual, pol.polrelid) AS check_expression
FROM pg_policy pol
JOIN pg_class rel ON rel.oid = pol.polrelid
WHERE rel.relname = 'objects' 
  AND rel.relnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'storage');

-- 5. Testar a configuração do bucket para imagens de treino
SELECT 
    name AS bucket_name, 
    public AS is_public, 
    (SELECT COUNT(*) FROM storage.objects WHERE bucket_id = buckets.id) AS file_count
FROM storage.buckets 
WHERE name = 'workout-images'; 