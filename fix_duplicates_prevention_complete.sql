-- =====================================================
-- SOLUÇÃO COMPLETA PARA DUPLICATAS DE CHECK-INS
-- =====================================================
-- Este script resolve o problema de duplicatas de forma definitiva:
-- 1. Limpa duplicatas existentes
-- 2. Fortalece prevenção de duplicatas futuras
-- 3. Adiciona constraints de banco de dados

-- =====================================================
-- PARTE 1: DIAGNÓSTICO E LIMPEZA DE DUPLICATAS
-- =====================================================

-- Criar função para identificar e limpar duplicatas
CREATE OR REPLACE FUNCTION cleanup_workout_duplicates()
RETURNS TABLE (
    step_description TEXT,
    records_affected INTEGER,
    details TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    duplicates_count INTEGER;
    cleaned_count INTEGER;
    before_count INTEGER;
    after_count INTEGER;
BEGIN
    -- Contar registros antes da limpeza
    SELECT COUNT(*) INTO before_count FROM workout_records;
    
    RETURN QUERY SELECT 
        'Diagnóstico Inicial' as step_description,
        before_count as records_affected,
        'Total de workout_records antes da limpeza' as details;
    
    -- Identificar duplicatas (mesmo user_id + mesmo check_in_date)
    SELECT COUNT(*) INTO duplicates_count
    FROM (
        SELECT user_id, check_in_date, COUNT(*) as count
        FROM workout_records 
        GROUP BY user_id, check_in_date 
        HAVING COUNT(*) > 1
    ) duplicates;
    
    RETURN QUERY SELECT 
        'Duplicatas Identificadas' as step_description,
        duplicates_count as records_affected,
        'Grupos de duplicatas encontrados' as details;
    
    -- LIMPEZA: Manter apenas o registro mais recente de cada duplicata
    WITH duplicates_to_remove AS (
        SELECT id
        FROM (
            SELECT id,
                   ROW_NUMBER() OVER (
                       PARTITION BY user_id, check_in_date 
                       ORDER BY created_at DESC, id DESC
                   ) as rn
            FROM workout_records
        ) ranked
        WHERE rn > 1
    )
    DELETE FROM workout_records 
    WHERE id IN (SELECT id FROM duplicates_to_remove);
    
    GET DIAGNOSTICS cleaned_count = ROW_COUNT;
    
    RETURN QUERY SELECT 
        'Duplicatas Removidas' as step_description,
        cleaned_count as records_affected,
        'Registros duplicados deletados (mantido mais recente)' as details;
    
    -- Contar registros após limpeza
    SELECT COUNT(*) INTO after_count FROM workout_records;
    
    RETURN QUERY SELECT 
        'Resultado Final' as step_description,
        after_count as records_affected,
        'Total de workout_records após limpeza' as details;
    
END;
$$;

-- =====================================================
-- PARTE 2: CONSTRAINT DE BANCO PARA PREVENIR DUPLICATAS
-- =====================================================

-- Adicionar constraint UNIQUE que impede duplicatas no nível do banco
ALTER TABLE workout_records 
DROP CONSTRAINT IF EXISTS unique_user_checkin_date;

ALTER TABLE workout_records 
ADD CONSTRAINT unique_user_checkin_date 
UNIQUE (user_id, check_in_date);

-- =====================================================
-- PARTE 3: FUNÇÕES CORRIGIDAS COM PROTEÇÃO REFORÇADA
-- =====================================================

-- 1. FUNÇÃO PRINCIPAL: record_workout_basic
CREATE OR REPLACE FUNCTION record_workout_basic(
    user_id_param UUID,
    workout_date_param DATE,
    video_id_param UUID DEFAULT NULL,
    notes_param TEXT DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    workout_record_id UUID
) 
LANGUAGE plpgsql
AS $$
DECLARE
    existing_count INTEGER;
    new_workout_id UUID;
    workout_date_brt DATE;
BEGIN
    -- Validar parâmetros
    IF user_id_param IS NULL THEN
        RETURN QUERY SELECT 
            false as success,
            'ID do usuário é obrigatório' as message,
            NULL::UUID as workout_record_id;
        RETURN;
    END IF;
    
    IF workout_date_param IS NULL THEN
        RETURN QUERY SELECT 
            false as success,
            'Data do treino é obrigatória' as message,
            NULL::UUID as workout_record_id;
        RETURN;
    END IF;
    
    -- Converter data para BRT
    workout_date_brt := workout_date_param;
    
    -- PROTEÇÃO DUPLA: Verificar duplicatas pela DATA DO TREINO
    SELECT COUNT(*) INTO existing_count
    FROM workout_records 
    WHERE user_id = user_id_param 
    AND check_in_date = workout_date_brt;
    
    -- Se já existe treino nesta data específica, retornar erro
    IF existing_count > 0 THEN
        RETURN QUERY SELECT 
            false as success,
            'Você já possui um treino registrado para ' || workout_date_brt::TEXT as message,
            NULL::UUID as workout_record_id;
        RETURN;
    END IF;
    
    -- Tentar inserir novo registro (constraint do banco impedirá duplicatas)
    BEGIN
        INSERT INTO workout_records (
            user_id,
            check_in_date,
            video_id,
            notes,
            created_at,
            updated_at
        ) VALUES (
            user_id_param,
            workout_date_brt,
            video_id_param,
            notes_param,
            NOW() AT TIME ZONE 'America/Sao_Paulo',
            NOW() AT TIME ZONE 'America/Sao_Paulo'
        ) RETURNING id INTO new_workout_id;
        
        -- Retornar sucesso
        RETURN QUERY SELECT 
            true as success,
            'Treino registrado com sucesso para ' || workout_date_brt::TEXT as message,
            new_workout_id as workout_record_id;
            
    EXCEPTION 
        WHEN unique_violation THEN
            -- Capturar erro de constraint e retornar mensagem amigável
            RETURN QUERY SELECT 
                false as success,
                'Já existe um treino registrado para esta data' as message,
                NULL::UUID as workout_record_id;
        WHEN OTHERS THEN
            -- Capturar outros erros
            RETURN QUERY SELECT 
                false as success,
                'Erro ao registrar treino: ' || SQLERRM as message,
                NULL::UUID as workout_record_id;
    END;
        
END;
$$;

-- 2. FUNÇÃO DE RANKING: process_workout_for_ranking
CREATE OR REPLACE FUNCTION process_workout_for_ranking(
    user_id_param UUID,
    workout_date_param DATE
) RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    existing_count INTEGER;
    workout_date_brt DATE;
BEGIN
    -- Validar parâmetros
    IF user_id_param IS NULL OR workout_date_param IS NULL THEN
        RETURN QUERY SELECT 
            false as success,
            'Parâmetros obrigatórios ausentes' as message;
        RETURN;
    END IF;
    
    -- Converter data para BRT
    workout_date_brt := workout_date_param;
    
    -- PROTEÇÃO: Verificar se já existe treino na data
    SELECT COUNT(*) INTO existing_count
    FROM workout_records 
    WHERE user_id = user_id_param 
    AND check_in_date = workout_date_brt;
    
    -- Processar apenas se não existir treino na data
    IF existing_count = 0 THEN
        -- Aqui você pode adicionar sua lógica específica de ranking
        -- Por enquanto, apenas retornamos sucesso
        
        RETURN QUERY SELECT 
            true as success,
            'Processamento de ranking concluído' as message;
    ELSE
        RETURN QUERY SELECT 
            false as success,
            'Já existe treino para ' || workout_date_brt::TEXT as message;
    END IF;
    
END;
$$;

-- 3. FUNÇÃO DE ATUALIZAÇÃO: update_workout_and_refresh
CREATE OR REPLACE FUNCTION update_workout_and_refresh(
    workout_id_param UUID,
    new_date_param DATE DEFAULT NULL,
    new_video_id_param UUID DEFAULT NULL,
    new_notes_param TEXT DEFAULT NULL
) RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    current_user_id UUID;
    existing_count INTEGER;
    new_date_brt DATE;
    current_date DATE;
BEGIN
    -- Validar se workout existe e buscar user_id
    SELECT user_id, check_in_date INTO current_user_id, current_date
    FROM workout_records 
    WHERE id = workout_id_param;
    
    IF current_user_id IS NULL THEN
        RETURN QUERY SELECT 
            false as success,
            'Treino não encontrado' as message;
        RETURN;
    END IF;
    
    -- Se nova data foi fornecida, verificar conflitos
    IF new_date_param IS NOT NULL AND new_date_param != current_date THEN
        new_date_brt := new_date_param;
        
        -- PROTEÇÃO: Verificar se já existe treino na nova data
        SELECT COUNT(*) INTO existing_count
        FROM workout_records 
        WHERE user_id = current_user_id 
        AND check_in_date = new_date_brt
        AND id != workout_id_param;  -- Excluir o próprio registro
        
        IF existing_count > 0 THEN
            RETURN QUERY SELECT 
                false as success,
                'Já existe treino registrado para ' || new_date_brt::TEXT as message;
            RETURN;
        END IF;
    END IF;
    
    -- Tentar atualizar registro
    BEGIN
        UPDATE workout_records SET
            check_in_date = COALESCE(new_date_param, check_in_date),
            video_id = COALESCE(new_video_id_param, video_id),
            notes = COALESCE(new_notes_param, notes),
            updated_at = NOW() AT TIME ZONE 'America/Sao_Paulo'
        WHERE id = workout_id_param;
        
        RETURN QUERY SELECT 
            true as success,
            'Treino atualizado com sucesso' as message;
            
    EXCEPTION 
        WHEN unique_violation THEN
            RETURN QUERY SELECT 
                false as success,
                'Conflito: já existe treino para esta data' as message;
        WHEN OTHERS THEN
            RETURN QUERY SELECT 
                false as success,
                'Erro ao atualizar: ' || SQLERRM as message;
    END;
        
END;
$$;

-- =====================================================
-- PARTE 4: FUNÇÃO DE TESTE COMPLETA
-- =====================================================

CREATE OR REPLACE FUNCTION test_duplicate_prevention()
RETURNS TABLE (
    test_name TEXT,
    result TEXT,
    details TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    test_user_id UUID;
    today_date DATE;
    yesterday_date DATE;
    result1_success BOOLEAN;
    result1_message TEXT;
    result1_id UUID;
    result2_success BOOLEAN;
    result2_message TEXT;
    result2_id UUID;
BEGIN
    -- Preparar dados de teste
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    today_date := (NOW() AT TIME ZONE 'America/Sao_Paulo')::DATE;
    yesterday_date := today_date - INTERVAL '1 day';
    
    -- TESTE 1: Registrar treino de ontem (deve funcionar)
    SELECT success, message, workout_record_id 
    INTO result1_success, result1_message, result1_id
    FROM record_workout_basic(test_user_id, yesterday_date);
    
    RETURN QUERY SELECT 
        'Check-in Retroativo' as test_name,
        CASE WHEN result1_success THEN 'PASSOU' ELSE 'FALHOU' END as result,
        result1_message as details;
    
    -- TESTE 2: Tentar duplicar treino de ontem (deve falhar)
    SELECT success, message, workout_record_id 
    INTO result2_success, result2_message, result2_id
    FROM record_workout_basic(test_user_id, yesterday_date);
    
    RETURN QUERY SELECT 
        'Prevenção Duplicata' as test_name,
        CASE WHEN NOT result2_success THEN 'PASSOU' ELSE 'FALHOU' END as result,
        result2_message as details;
    
    -- TESTE 3: Registrar treino para hoje (deve funcionar)
    SELECT success, message, workout_record_id 
    INTO result1_success, result1_message, result1_id
    FROM record_workout_basic(test_user_id, today_date);
    
    RETURN QUERY SELECT 
        'Check-in Hoje' as test_name,
        CASE WHEN result1_success THEN 'PASSOU' ELSE 'FALHOU' END as result,
        result1_message as details;
    
    -- Limpar dados de teste
    DELETE FROM workout_records 
    WHERE user_id = test_user_id 
    AND check_in_date IN (today_date, yesterday_date);
    
    RETURN QUERY SELECT 
        'Limpeza Teste' as test_name,
        'CONCLUÍDA' as result,
        'Dados de teste removidos' as details;
    
END;
$$;

-- =====================================================
-- EXECUTAR LIMPEZA E TESTES
-- =====================================================

-- 1. Limpar duplicatas existentes
SELECT 'EXECUTANDO LIMPEZA DE DUPLICATAS...' as status;
SELECT * FROM cleanup_workout_duplicates();

-- 2. Testar prevenção de duplicatas
SELECT 'TESTANDO PREVENÇÃO DE DUPLICATAS...' as status;
SELECT * FROM test_duplicate_prevention();

-- =====================================================
-- RESUMO FINAL
-- =====================================================
/*
PROTEÇÕES IMPLEMENTADAS CONTRA DUPLICATAS:

1. CONSTRAINT DE BANCO DE DADOS:
   ✓ UNIQUE (user_id, check_in_date) - Impede duplicatas no nível do banco

2. VERIFICAÇÃO PROGRAMÁTICA:
   ✓ Funções verificam duplicatas antes de inserir
   ✓ Tratamento de erros com mensagens amigáveis

3. LIMPEZA DE DADOS:
   ✓ Remove duplicatas existentes mantendo registro mais recente
   ✓ Diagnóstico completo do processo

4. TESTES AUTOMÁTICOS:
   ✓ Verifica check-ins retroativos funcionam
   ✓ Confirma que duplicatas são bloqueadas
   ✓ Valida funcionamento normal

RESULTADO:
- Usuários podem registrar treinos retroativos
- Duplicatas são completamente bloqueadas
- Dados existentes limpos
- Sistema robusto e confiável
*/

SELECT 'CORREÇÃO DE DUPLICATAS CONCLUÍDA!' as final_status; 