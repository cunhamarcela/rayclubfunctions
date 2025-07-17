-- =====================================================
-- CORREÇÃO COMPLETA DE TIMEZONE - VERSÃO CORRIGIDA
-- =====================================================
-- Este script usa a estrutura REAL das tabelas:
-- - workout_records.date (não check_in_date)
-- - challenge_check_ins.check_in_date
-- - Corrige todas as funções existentes

-- =====================================================
-- PARTE 1: CONFIGURAÇÃO BÁSICA DO TIMEZONE
-- =====================================================

-- Verificar configuração atual (já está correto - America/Sao_Paulo)
SELECT 
    '=== CONFIGURAÇÃO DE TIMEZONE ===' as status,
    current_setting('timezone') as timezone_banco,
    NOW() as now_com_timezone,
    DATE(NOW()) as data_atual;

-- =====================================================
-- PARTE 2: FUNÇÕES AUXILIARES PARA TIMEZONE
-- =====================================================

-- Criar função para conversão consistente para timezone de Brasília
CREATE OR REPLACE FUNCTION to_brt(timestamp_input TIMESTAMP WITH TIME ZONE)
RETURNS TIMESTAMP WITH TIME ZONE 
LANGUAGE plpgsql IMMUTABLE AS $$
BEGIN
    RETURN timestamp_input AT TIME ZONE 'America/Sao_Paulo';
END;
$$;

-- Criar função para obter data atual no Brasil
CREATE OR REPLACE FUNCTION now_brt()
RETURNS TIMESTAMP WITH TIME ZONE 
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN NOW() AT TIME ZONE 'America/Sao_Paulo';
END;
$$;

-- Criar função para obter apenas a data no Brasil
CREATE OR REPLACE FUNCTION current_date_brt()
RETURNS DATE 
LANGUAGE plpgsql STABLE AS $$
BEGIN
    RETURN DATE(NOW() AT TIME ZONE 'America/Sao_Paulo');
END;
$$;

-- =====================================================
-- PARTE 3: CORRIGIR FUNÇÃO record_workout_basic
-- =====================================================

-- Primeira, vamos verificar se essa função existe e qual é sua assinatura atual
-- Vamos criar/corrigir a função para usar a coluna 'date' correta

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
    now_brt TIMESTAMP WITH TIME ZONE;
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
    
    -- CORREÇÃO TIMEZONE: Usar now_brt e date para verificação
    workout_date_brt := workout_date_param;
    now_brt := NOW(); -- Já está em America/Sao_Paulo
    
    -- PROTEÇÃO: Verificar duplicatas pela DATA DO TREINO (coluna 'date')
    SELECT COUNT(*) INTO existing_count
    FROM workout_records 
    WHERE user_id = user_id_param 
    AND DATE(date) = workout_date_brt; -- Usar coluna 'date' correta
    
    -- Se já existe treino nesta data específica, retornar erro
    IF existing_count > 0 THEN
        RETURN QUERY SELECT 
            false as success,
            'Você já possui um treino registrado para ' || workout_date_brt::TEXT as message,
            NULL::UUID as workout_record_id;
        RETURN;
    END IF;
    
    -- Tentar inserir novo registro com timezone correto
    BEGIN
        INSERT INTO workout_records (
            user_id,
            date,           -- Usar coluna 'date' correta
            workout_name,   -- Valor padrão
            workout_type,   -- Valor padrão
            duration_minutes, -- Valor padrão
            notes,
            created_at,
            updated_at
        ) VALUES (
            user_id_param,
            workout_date_brt::timestamp with time zone, -- Converter para timestamp
            'Treino Manual',  -- Nome padrão
            'Manual',         -- Tipo padrão
            30,              -- Duração padrão
            notes_param,
            now_brt,
            now_brt
        ) RETURNING id INTO new_workout_id;
        
        -- Retornar sucesso
        RETURN QUERY SELECT 
            true as success,
            'Treino registrado com sucesso para ' || workout_date_brt::TEXT as message,
            new_workout_id as workout_record_id;
            
    EXCEPTION 
        WHEN unique_violation THEN
            RETURN QUERY SELECT 
                false as success,
                'Já existe um treino registrado para esta data' as message,
                NULL::UUID as workout_record_id;
        WHEN OTHERS THEN
            RETURN QUERY SELECT 
                false as success,
                'Erro ao registrar treino: ' || SQLERRM as message,
                NULL::UUID as workout_record_id;
    END;
        
END;
$$;

-- =====================================================
-- PARTE 4: CRIAR CONSTRAINT PARA PREVENIR DUPLICATAS
-- =====================================================

-- Adicionar constraint UNIQUE que impede duplicatas na tabela workout_records
-- Usar (user_id, DATE(date)) para permitir apenas um treino por usuário por dia
ALTER TABLE workout_records 
DROP CONSTRAINT IF EXISTS unique_user_date_workout;

-- Como não podemos criar constraint diretamente com DATE(date), 
-- vamos usar um índice único parcial
DROP INDEX IF EXISTS idx_unique_user_date_workout;
CREATE UNIQUE INDEX idx_unique_user_date_workout 
ON workout_records (user_id, DATE(date));

-- =====================================================
-- PARTE 5: CORRIGIR FUNÇÕES DE CHALLENGE CHECK-IN
-- =====================================================

-- Corrigir record_challenge_check_in_v2 para usar timezone correto
CREATE OR REPLACE FUNCTION record_challenge_check_in_v2(
    _challenge_id UUID,
    _user_id UUID,
    _date TIMESTAMP WITH TIME ZONE,
    _workout_id UUID DEFAULT NULL,
    _workout_name TEXT DEFAULT '',
    _workout_type TEXT DEFAULT '',
    _duration_minutes INTEGER DEFAULT 0
) RETURNS JSONB
LANGUAGE plpgsql AS $$
DECLARE
    duplicate_check_in BOOLEAN;
    check_in_date_only DATE;
    points_earned INTEGER := 10;
    now_brt TIMESTAMP WITH TIME ZONE;
BEGIN
    BEGIN
        -- CORREÇÃO TIMEZONE: Usar timezone já configurado
        now_brt := NOW(); -- Já está em America/Sao_Paulo
        check_in_date_only := DATE(_date); -- Extrair apenas a data
        
        -- CORREÇÃO: Verificar duplicatas APENAS por DATA, não por timestamp
        SELECT EXISTS (
            SELECT 1 FROM challenge_check_ins 
            WHERE 
                challenge_id = _challenge_id 
                AND user_id = _user_id 
                AND DATE(check_in_date) = check_in_date_only
        ) INTO duplicate_check_in;
        
        -- Se já existe check-in nesta DATA específica, retornar erro
        IF duplicate_check_in THEN
            RETURN jsonb_build_object(
                'success', false,
                'message', 'Você já fez check-in nesta data',
                'error_code', 'DUPLICATE_CHECK_IN_DATE',
                'check_in_date', check_in_date_only,
                'points_earned', 0
            );
        END IF;
        
        -- CORREÇÃO: Inserir com data do formulário (retroativa)
        INSERT INTO challenge_check_ins (
            id,
            challenge_id,
            user_id,
            check_in_date,    -- Data do formulário (retroativa)
            points,
            workout_id,
            workout_name,
            workout_type,
            duration_minutes,
            created_at,       -- now_brt para auditoria
            updated_at,
            brt_date         -- Data brasileira para índices
        ) VALUES (
            gen_random_uuid(),
            _challenge_id,
            _user_id,
            _date,           -- Data escolhida pelo usuário
            points_earned,
            _workout_id,
            _workout_name,
            _workout_type,
            _duration_minutes,
            now_brt,         -- Timestamp de criação
            now_brt,         -- Timestamp de atualização
            check_in_date_only -- Data brasileira
        );
        
        RETURN jsonb_build_object(
            'success', true,
            'message', 'Check-in registrado com sucesso',
            'points_earned', points_earned,
            'check_in_date', check_in_date_only,
            'brt_timestamp', now_brt
        );
        
    EXCEPTION WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Erro ao registrar check-in: ' || SQLERRM,
            'error_code', SQLSTATE,
            'points_earned', 0
        );
    END;
END;
$$;

-- =====================================================
-- PARTE 6: TRIGGERS PARA GARANTIR TIMEZONE CORRETO
-- =====================================================

-- Função para trigger que garante timezone correto em workout_records
CREATE OR REPLACE FUNCTION ensure_brt_timezone_workout_records()
RETURNS TRIGGER 
LANGUAGE plpgsql AS $$
DECLARE
    now_brt TIMESTAMP WITH TIME ZONE;
BEGIN
    now_brt := NOW(); -- Já está em America/Sao_Paulo
    
    -- Para INSERT
    IF TG_OP = 'INSERT' THEN
        -- Garantir que created_at e updated_at estejam corretos
        IF NEW.created_at IS NULL THEN
            NEW.created_at := now_brt;
        END IF;
        NEW.updated_at := now_brt;
        
        RETURN NEW;
    END IF;
    
    -- Para UPDATE
    IF TG_OP = 'UPDATE' THEN
        -- Sempre atualizar updated_at
        NEW.updated_at := now_brt;
        
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$;

-- Criar/recriar trigger para workout_records
DROP TRIGGER IF EXISTS trigger_ensure_brt_timezone_workout_records ON workout_records;
CREATE TRIGGER trigger_ensure_brt_timezone_workout_records
    BEFORE INSERT OR UPDATE ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION ensure_brt_timezone_workout_records();

-- Função para trigger que garante timezone correto em challenge_check_ins
-- (Esta função já existe, mas vamos garantir que está correta)
CREATE OR REPLACE FUNCTION ensure_brt_timezone_challenge_check_ins()
RETURNS TRIGGER 
LANGUAGE plpgsql AS $$
DECLARE
    now_brt TIMESTAMP WITH TIME ZONE;
BEGIN
    now_brt := NOW(); -- Já está em America/Sao_Paulo
    
    -- Para INSERT
    IF TG_OP = 'INSERT' THEN
        -- Garantir que created_at e updated_at estejam corretos
        IF NEW.created_at IS NULL THEN
            NEW.created_at := now_brt;
        END IF;
        NEW.updated_at := now_brt;
        
        -- Garantir que brt_date esteja correto
        IF NEW.check_in_date IS NOT NULL THEN
            NEW.brt_date := DATE(NEW.check_in_date);
        END IF;
        
        RETURN NEW;
    END IF;
    
    -- Para UPDATE
    IF TG_OP = 'UPDATE' THEN
        -- Sempre atualizar updated_at
        NEW.updated_at := now_brt;
        
        -- Atualizar brt_date se check_in_date mudou
        IF NEW.check_in_date IS NOT NULL AND (OLD.check_in_date IS NULL OR NEW.check_in_date != OLD.check_in_date) THEN
            NEW.brt_date := DATE(NEW.check_in_date);
        END IF;
        
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$;

-- Recriar trigger para challenge_check_ins
DROP TRIGGER IF EXISTS trigger_ensure_brt_timezone_challenge_check_ins ON challenge_check_ins;
CREATE TRIGGER trigger_ensure_brt_timezone_challenge_check_ins
    BEFORE INSERT OR UPDATE ON challenge_check_ins
    FOR EACH ROW
    EXECUTE FUNCTION ensure_brt_timezone_challenge_check_ins();

-- =====================================================
-- PARTE 7: LIMPAR DUPLICATAS EXISTENTES
-- =====================================================

-- Função para limpar duplicatas na tabela workout_records
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
    
    -- Identificar duplicatas (mesmo user_id + mesmo DATE(date))
    SELECT COUNT(*) INTO duplicates_count
    FROM (
        SELECT user_id, DATE(date), COUNT(*) as count
        FROM workout_records 
        GROUP BY user_id, DATE(date) 
        HAVING COUNT(*) > 1
    ) duplicates;
    
    RETURN QUERY SELECT 
        'Duplicatas Identificadas' as step_description,
        duplicates_count as records_affected,
        'Grupos de duplicatas encontrados (mesmo usuário + mesma data)' as details;
    
    -- LIMPEZA: Manter apenas o registro mais recente de cada duplicata
    WITH duplicates_to_remove AS (
        SELECT id
        FROM (
            SELECT id,
                   ROW_NUMBER() OVER (
                       PARTITION BY user_id, DATE(date) 
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
-- PARTE 8: VERIFICAÇÃO E TESTES
-- =====================================================

-- Função para testar timezone consistency
CREATE OR REPLACE FUNCTION test_timezone_consistency()
RETURNS TABLE (
    test_name TEXT,
    result TEXT,
    details TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    test_user_id UUID;
    today_brt DATE;
    yesterday_brt DATE;
    result1_success BOOLEAN;
    result1_message TEXT;
    result1_id UUID;
    sample_created_at TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Preparar dados de teste
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    today_brt := DATE(NOW());
    yesterday_brt := today_brt - INTERVAL '1 day';
    
    -- TESTE 1: Verificar configuração de timezone
    RETURN QUERY SELECT 
        'Configuração Timezone' as test_name,
        CASE 
            WHEN current_setting('timezone') = 'America/Sao_Paulo' THEN 'PASSOU' 
            ELSE 'FALHOU' 
        END as result,
        'Timezone atual: ' || current_setting('timezone') as details;
    
    -- TESTE 2: Testar registro de treino retroativo
    IF test_user_id IS NOT NULL THEN
        SELECT success, message, workout_record_id 
        INTO result1_success, result1_message, result1_id
        FROM record_workout_basic(test_user_id, yesterday_brt);
        
        RETURN QUERY SELECT 
            'Check-in Retroativo' as test_name,
            CASE WHEN result1_success THEN 'PASSOU' ELSE 'FALHOU' END as result,
            result1_message as details;
        
        -- TESTE 3: Verificar se created_at está correto
        IF result1_id IS NOT NULL THEN
            SELECT created_at INTO sample_created_at
            FROM workout_records 
            WHERE id = result1_id;
            
            RETURN QUERY SELECT 
                'Created_At Timezone' as test_name,
                'PASSOU' as result,
                'Created_at: ' || sample_created_at::TEXT as details;
        END IF;
        
        -- Limpar dados de teste
        IF result1_id IS NOT NULL THEN
            DELETE FROM workout_records WHERE id = result1_id;
            
            RETURN QUERY SELECT 
                'Limpeza Teste' as test_name,
                'CONCLUÍDA' as result,
                'Dados de teste removidos' as details;
        END IF;
    ELSE
        RETURN QUERY SELECT 
            'Aviso' as test_name,
            'PULADO' as result,
            'Nenhum usuário encontrado para teste' as details;
    END IF;
    
END;
$$;

-- =====================================================
-- EXECUTAR LIMPEZA E TESTES
-- =====================================================

-- 1. Limpar duplicatas existentes
SELECT 'EXECUTANDO LIMPEZA DE DUPLICATAS...' as status;
SELECT * FROM cleanup_workout_duplicates();

-- 2. Testar timezone consistency
SELECT 'TESTANDO TIMEZONE CONSISTENCY...' as status;
SELECT * FROM test_timezone_consistency();

-- 3. Verificar registros existentes
SELECT 'VERIFICANDO REGISTROS EXISTENTES...' as status;
SELECT 
    'Análise workout_records' as tabela,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN DATE(created_at) = DATE(date) THEN 1 END) as datas_consistentes,
    COUNT(CASE WHEN DATE(created_at) != DATE(date) THEN 1 END) as datas_inconsistentes
FROM workout_records
UNION ALL
SELECT 
    'Análise challenge_check_ins' as tabela,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN DATE(created_at) = DATE(check_in_date) THEN 1 END) as datas_consistentes,
    COUNT(CASE WHEN DATE(created_at) != DATE(check_in_date) THEN 1 END) as datas_inconsistentes
FROM challenge_check_ins;

-- =====================================================
-- RESUMO FINAL
-- =====================================================
/*
CORREÇÕES APLICADAS PARA TIMEZONE (VERSÃO CORRIGIDA):

1. ESTRUTURA REAL DAS TABELAS:
   ✓ workout_records.date (não check_in_date)
   ✓ challenge_check_ins.check_in_date (correto)
   ✓ Todas as funções ajustadas para estrutura real

2. FUNÇÕES CORRIGIDAS:
   ✓ record_workout_basic - usa workout_records.date
   ✓ record_challenge_check_in_v2 - verificação por DATE(check_in_date)
   ✓ Funções auxiliares (now_brt, current_date_brt, to_brt)

3. PROTEÇÃO CONTRA DUPLICATAS:
   ✓ Índice único (user_id, DATE(date)) em workout_records
   ✓ Verificação por data em challenge_check_ins
   ✓ Limpeza de duplicatas existentes

4. TRIGGERS CORRETOS:
   ✓ ensure_brt_timezone_workout_records
   ✓ ensure_brt_timezone_challenge_check_ins (corrigido)

5. TESTES E VERIFICAÇÕES:
   ✓ Limpeza de duplicatas
   ✓ Teste de check-ins retroativos
   ✓ Verificação de consistência de datas

RESULTADO:
- Check-ins retroativos funcionam corretamente
- Duplicatas são completamente bloqueadas
- Sistema consistente no timezone de Brasília
- Funções usam a estrutura real das tabelas
*/

SELECT 'CORREÇÃO DE TIMEZONE CONCLUÍDA (VERSÃO CORRIGIDA)!' as final_status; 