-- =====================================================================================
-- SCRIPT: CORREÇÃO DE CHECK-INS PRÉ-DESAFIO (VERSÃO SUPABASE)
-- Descrição: Remove APENAS check-ins registrados antes do início oficial do desafio
-- Compatível com: Supabase PostgreSQL
-- Problema: 101 check-ins inválidos gerando 1010 pontos incorretos para 92 usuários
-- =====================================================================================

DO $$
DECLARE
    challenge_uuid UUID := '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID;
    challenge_start_date TIMESTAMP WITH TIME ZONE := '2025-05-26 00:00:00-03'::TIMESTAMP WITH TIME ZONE;
    usuarios_afetados INTEGER;
    checkins_removidos INTEGER;
    pontos_removidos INTEGER;
BEGIN
    RAISE NOTICE '🚀 INICIANDO CORREÇÃO DE CHECK-INS PRÉ-DESAFIO';
    RAISE NOTICE '📅 Desafio ID: %', challenge_uuid;
    RAISE NOTICE '📅 Data início oficial: %', challenge_start_date;
    RAISE NOTICE '';

    -- ETAPA 1: Análise inicial dos check-ins inválidos
    RAISE NOTICE '🔍 ETAPA 1: ANÁLISE DE CHECK-INS INVÁLIDOS';
    
    SELECT COUNT(DISTINCT user_id), COUNT(*), COALESCE(SUM(points), 0)
    INTO usuarios_afetados, checkins_removidos, pontos_removidos
    FROM challenge_check_ins 
    WHERE challenge_id = challenge_uuid 
    AND check_in_date < challenge_start_date;
    
    RAISE NOTICE '👥 Usuários afetados: %', usuarios_afetados;
    RAISE NOTICE '📊 Check-ins inválidos: %', checkins_removidos;
    RAISE NOTICE '💰 Pontos indevidos: %', pontos_removidos;
    RAISE NOTICE '';

    -- Verificar se há check-ins para remover
    IF checkins_removidos = 0 THEN
        RAISE NOTICE '✅ Nenhum check-in inválido encontrado. Sistema já está correto!';
        RETURN;
    END IF;

    -- ETAPA 2: Backup dos dados que serão removidos
    RAISE NOTICE '💾 ETAPA 2: CRIANDO BACKUP DOS DADOS';
    
    -- Criar tabela de backup se não existir
    CREATE TABLE IF NOT EXISTS challenge_check_ins_backup_pre_challenge (
        LIKE challenge_check_ins INCLUDING ALL,
        backup_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
        backup_reason TEXT DEFAULT 'pre_challenge_fix'
    );

    -- Inserir dados no backup
    INSERT INTO challenge_check_ins_backup_pre_challenge 
    (id, user_id, challenge_id, check_in_date, points, workout_id, created_at, updated_at, backup_timestamp, backup_reason)
    SELECT 
        id, user_id, challenge_id, check_in_date, points, workout_id, created_at, updated_at, 
        NOW(), 'pre_challenge_fix'
    FROM challenge_check_ins 
    WHERE challenge_id = challenge_uuid 
    AND check_in_date < challenge_start_date;
    
    GET DIAGNOSTICS checkins_removidos = ROW_COUNT;
    RAISE NOTICE '✅ Backup criado: % registros salvos', checkins_removidos;
    RAISE NOTICE '';

    -- ETAPA 3: Remover check-ins inválidos
    RAISE NOTICE '🗑️ ETAPA 3: REMOVENDO CHECK-INS INVÁLIDOS';
    
    DELETE FROM challenge_check_ins 
    WHERE challenge_id = challenge_uuid 
    AND check_in_date < challenge_start_date;
    
    GET DIAGNOSTICS checkins_removidos = ROW_COUNT;
    RAISE NOTICE '✅ Check-ins removidos: %', checkins_removidos;
    RAISE NOTICE '';

    -- ETAPA 4: Recalcular progresso dos usuários afetados
    RAISE NOTICE '🔄 ETAPA 4: RECALCULANDO PROGRESSO DOS USUÁRIOS';
    
    -- Recalcular progresso para todos os usuários afetados
    UPDATE challenge_progress 
    SET 
        total_check_ins = (
            SELECT COUNT(*) 
            FROM challenge_check_ins 
            WHERE user_id = challenge_progress.user_id AND challenge_id = challenge_uuid
        ),
        total_points = (
            SELECT COALESCE(SUM(points), 0) 
            FROM challenge_check_ins 
            WHERE user_id = challenge_progress.user_id AND challenge_id = challenge_uuid
        ),
        updated_at = NOW()
    WHERE challenge_id = challenge_uuid
    AND user_id IN (
        SELECT DISTINCT user_id 
        FROM challenge_check_ins_backup_pre_challenge 
        WHERE backup_reason = 'pre_challenge_fix'
    );
    
    RAISE NOTICE '✅ Progresso recalculado para todos os usuários afetados';
    RAISE NOTICE '';

    -- ETAPA 5: Verificação final
    RAISE NOTICE '🔍 ETAPA 5: VERIFICAÇÃO FINAL';
    
    SELECT COUNT(*)
    INTO checkins_removidos
    FROM challenge_check_ins 
    WHERE challenge_id = challenge_uuid 
    AND check_in_date < challenge_start_date;
    
    RAISE NOTICE '📊 Check-ins pré-desafio restantes: % (deve ser 0)', checkins_removidos;
    
    -- Estatísticas finais
    SELECT COUNT(DISTINCT user_id), COUNT(*), COALESCE(SUM(points), 0)
    INTO usuarios_afetados, checkins_removidos, pontos_removidos
    FROM challenge_check_ins 
    WHERE challenge_id = challenge_uuid;
    
    RAISE NOTICE '';
    RAISE NOTICE '📈 ESTATÍSTICAS FINAIS DO DESAFIO:';
    RAISE NOTICE '👥 Usuários participando: %', usuarios_afetados;
    RAISE NOTICE '📊 Check-ins válidos: %', checkins_removidos;
    RAISE NOTICE '💰 Pontos válidos: %', pontos_removidos;
    RAISE NOTICE '';
    RAISE NOTICE '✅ CORREÇÃO CONCLUÍDA COM SUCESSO!';
    
END $$;

-- =====================================================================================
-- CONSULTAS DE VERIFICAÇÃO SIMPLES (Execute após o script)
-- =====================================================================================

-- 1. Verificar se ainda há check-ins pré-desafio
SELECT 
    'Verificação Pós-Correção' as status,
    COUNT(*) as checkins_pre_desafio_restantes,
    COUNT(DISTINCT user_id) as usuarios_afetados
FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
AND check_in_date < '2025-05-26 00:00:00-03';

-- 2. Ver dados do backup criado
SELECT 
    'Dados no Backup' as status,
    COUNT(*) as checkins_backupeados,
    COUNT(DISTINCT user_id) as usuarios_backupeados,
    SUM(points) as pontos_backupeados,
    MIN(check_in_date) as primeiro_checkin_invalido,
    MAX(check_in_date) as ultimo_checkin_invalido
FROM challenge_check_ins_backup_pre_challenge 
WHERE backup_reason = 'pre_challenge_fix';

-- 3. Estatísticas finais do desafio
SELECT 
    'Desafio Limpo' as status,
    COUNT(DISTINCT user_id) as usuarios_participando,
    COUNT(*) as checkins_validos,
    SUM(points) as pontos_validos,
    MIN(check_in_date) as primeiro_checkin_valido,
    MAX(check_in_date) as ultimo_checkin
FROM challenge_check_ins 
WHERE challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'; 