-- SCRIPT RÁPIDO PARA CORRIGIR AS 168 INCONSISTÊNCIAS DETECTADAS
-- Execute este script para limpar check-ins órfãos e recalcular progresso

-- =====================================================
-- 1. MOSTRAR O PROBLEMA ATUAL
-- =====================================================

-- Ver quantos check-ins órfãos existem
SELECT 
    '🔍 DIAGNÓSTICO' as status,
    COUNT(*) as check_ins_orfaos,
    'check-ins sem treino correspondente' as descricao
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON wr.id = cci.workout_id::uuid
WHERE wr.id IS NULL AND cci.workout_id IS NOT NULL;

-- Ver por usuário quantos check-ins órfãos cada um tem
SELECT 
    '👥 POR USUÁRIO' as status,
    p.name as usuario_nome,
    p.email as usuario_email,
    cci.challenge_id,
    COUNT(*) as check_ins_orfaos
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON wr.id = cci.workout_id::uuid
LEFT JOIN profiles p ON p.id = cci.user_id
WHERE wr.id IS NULL AND cci.workout_id IS NOT NULL
GROUP BY p.name, p.email, cci.challenge_id
ORDER BY COUNT(*) DESC;

-- =====================================================
-- 2. LIMPEZA AUTOMÁTICA
-- =====================================================

-- Fazer backup dos dados antes de limpar
CREATE TABLE IF NOT EXISTS challenge_check_ins_backup_orphans AS
SELECT cci.*, 'orphan_backup_' || NOW()::text as backup_reason
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON wr.id = cci.workout_id::uuid
WHERE wr.id IS NULL AND cci.workout_id IS NOT NULL;

-- Mostrar quantos registros foram salvos no backup
SELECT 
    '💾 BACKUP CRIADO' as status,
    COUNT(*) as registros_backup
FROM challenge_check_ins_backup_orphans
WHERE backup_reason LIKE 'orphan_backup_%';

-- Remover check-ins órfãos
WITH deleted_orphans AS (
    DELETE FROM challenge_check_ins cci
    WHERE cci.workout_id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM workout_records wr 
          WHERE wr.id = cci.workout_id::uuid
      )
    RETURNING user_id, challenge_id, id
)
SELECT 
    '🗑️ LIMPEZA CONCLUÍDA' as status,
    COUNT(*) as check_ins_removidos,
    COUNT(DISTINCT user_id) as usuarios_afetados,
    COUNT(DISTINCT challenge_id) as desafios_afetados
FROM deleted_orphans;

-- =====================================================
-- 3. RECALCULAR PROGRESSO PARA TODOS AFETADOS
-- =====================================================

-- Criar função temporária para recalcular em lote
CREATE OR REPLACE FUNCTION recalculate_all_affected_progress()
RETURNS TABLE(
    status TEXT,
    users_processed INTEGER,
    challenges_processed INTEGER,
    errors_count INTEGER
) AS $$
DECLARE
    user_challenge RECORD;
    processed_users INTEGER := 0;
    processed_challenges INTEGER := 0;
    error_count INTEGER := 0;
    recalc_result JSONB;
BEGIN
    -- Encontrar todos os usuários que podem ter sido afetados
    FOR user_challenge IN 
        SELECT DISTINCT cp.user_id, cp.challenge_id
        FROM challenge_progress cp
        WHERE EXISTS (
            SELECT 1 FROM challenges c 
            WHERE c.id = cp.challenge_id 
            AND NOW() BETWEEN c.start_date AND c.end_date  -- Apenas desafios ativos
        )
    LOOP
        BEGIN
            -- Recalcular usando a função corrigida se existir, senão usar uma versão simplificada
            IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'recalculate_challenge_progress_complete_fixed') THEN
                EXECUTE 'SELECT recalculate_challenge_progress_complete_fixed($1, $2)' 
                INTO recalc_result
                USING user_challenge.user_id, user_challenge.challenge_id;
            ELSE
                -- Versão simplificada se a função não existir
                WITH valid_checkins AS (
                    SELECT 
                        COUNT(DISTINCT DATE(check_in_date)) as total_checkins,
                        COUNT(DISTINCT DATE(check_in_date)) * 10 as total_points,
                        MAX(check_in_date) as last_checkin
                    FROM challenge_check_ins cci
                    WHERE cci.user_id = user_challenge.user_id 
                      AND cci.challenge_id = user_challenge.challenge_id
                      AND (cci.workout_id IS NULL OR EXISTS (
                          SELECT 1 FROM workout_records wr 
                          WHERE wr.id = cci.workout_id::uuid
                      ))
                )
                UPDATE challenge_progress
                SET 
                    points = vc.total_points,
                    check_ins_count = vc.total_checkins,
                    total_check_ins = vc.total_checkins,
                    last_check_in = vc.last_checkin,
                    updated_at = NOW()
                FROM valid_checkins vc
                WHERE challenge_id = user_challenge.challenge_id 
                  AND user_id = user_challenge.user_id;
            END IF;
            
            processed_users := processed_users + 1;
            processed_challenges := processed_challenges + 1;
            
        EXCEPTION WHEN OTHERS THEN
            error_count := error_count + 1;
            RAISE LOG 'Erro ao recalcular para user % challenge %: %', 
                      user_challenge.user_id, user_challenge.challenge_id, SQLERRM;
        END;
    END LOOP;
    
    RETURN QUERY SELECT 
        'Recálculo concluído'::TEXT,
        processed_users,
        processed_challenges,
        error_count;
END;
$$ LANGUAGE plpgsql;

-- Executar o recálculo
SELECT * FROM recalculate_all_affected_progress();

-- =====================================================
-- 4. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se ainda há inconsistências
SELECT 
    '✅ VERIFICAÇÃO FINAL' as status,
    COUNT(*) as inconsistencias_restantes
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON wr.id = cci.workout_id::uuid
WHERE wr.id IS NULL AND cci.workout_id IS NOT NULL;

-- Mostrar estatísticas finais
SELECT 
    '📊 ESTATÍSTICAS FINAIS' as status,
    (SELECT COUNT(*) FROM challenge_check_ins) as total_checkins,
    (SELECT COUNT(DISTINCT user_id) FROM challenge_progress) as usuarios_com_progresso,
    (SELECT COUNT(*) FROM challenge_progress WHERE points > 0) as usuarios_com_pontos;

-- Mostrar ranking atualizado do desafio ativo (substitua pelo challenge_id correto)
SELECT 
    '🏆 RANKING ATUALIZADO' as status,
    cp.position,
    COALESCE(p.name, 'Usuário') as nome,
    cp.points,
    cp.check_ins_count
FROM challenge_progress cp
LEFT JOIN profiles p ON p.id = cp.user_id
WHERE cp.challenge_id IN (
    SELECT id FROM challenges 
    WHERE NOW() BETWEEN start_date AND end_date
    LIMIT 1  -- Pega o primeiro desafio ativo
)
AND cp.points > 0
ORDER BY cp.position ASC
LIMIT 10;

-- Limpeza: remover função temporária
DROP FUNCTION IF EXISTS recalculate_all_affected_progress();

SELECT 
    '🎉 CORREÇÃO CONCLUÍDA' as status,
    'Sistema de progresso corrigido e atualizado' as mensagem,
    NOW() as timestamp; 