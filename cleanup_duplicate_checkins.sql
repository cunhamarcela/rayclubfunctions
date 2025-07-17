-- ================================================================
-- LIMPEZA SEGURA DE CHECK-INS DUPLICADOS
-- ================================================================
-- ATENÇÃO: Execute apenas APÓS aplicar fix_real_functions_retroactive_FINAL.sql
-- Este script remove duplicados mantendo o check-in mais antigo
-- ================================================================

SELECT '🧹 INICIANDO LIMPEZA DE DUPLICADOS' as status;

-- ================================================================
-- PARTE 1: BACKUP E VERIFICAÇÃO
-- ================================================================

SELECT '💾 CRIANDO BACKUP DOS DUPLICADOS' as etapa;

-- Criar tabela de backup dos duplicados
CREATE TABLE IF NOT EXISTS backup_duplicate_checkins AS
SELECT 
    cci.*,
    NOW() as backup_created_at,
    'duplicate_removal_' || TO_CHAR(NOW(), 'YYYY_MM_DD_HH24_MI_SS') as backup_reason
FROM challenge_check_ins cci
WHERE EXISTS (
    SELECT 1 
    FROM challenge_check_ins cci2 
    WHERE cci2.user_id = cci.user_id 
    AND cci2.challenge_id = cci.challenge_id
    AND DATE(to_brt(cci2.check_in_date)) = DATE(to_brt(cci.check_in_date))
    AND cci2.id != cci.id
);

SELECT 
    '✅ BACKUP CRIADO' as status,
    COUNT(*) as total_registros_backup
FROM backup_duplicate_checkins;

-- ================================================================
-- PARTE 2: ANÁLISE PRÉ-LIMPEZA
-- ================================================================

SELECT '📊 ANÁLISE PRÉ-LIMPEZA' as etapa;

-- Contar duplicados que serão removidos
WITH duplicados_para_remover AS (
    SELECT 
        id,
        user_id,
        challenge_id,
        DATE(to_brt(check_in_date)) as data_checkin,
        created_at,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, challenge_id, DATE(to_brt(check_in_date))
            ORDER BY created_at ASC  -- Manter o mais antigo
        ) as rn
    FROM challenge_check_ins
)
SELECT 
    '🗑️ REGISTROS PARA REMOÇÃO' as tipo,
    COUNT(*) as total_duplicados_para_remover,
    COUNT(DISTINCT CONCAT(user_id, challenge_id, data_checkin)) as grupos_afetados
FROM duplicados_para_remover
WHERE rn > 1;

-- ================================================================
-- PARTE 3: IMPACTO NO RANKING/PROGRESSO
-- ================================================================

SELECT '📈 ANALISANDO IMPACTO NO PROGRESSO' as etapa;

-- Verificar usuários que terão progresso ajustado
WITH progresso_antes AS (
    SELECT 
        user_id,
        challenge_id,
        COUNT(*) as checkins_atual,
        SUM(points) as pontos_atual
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id
),
progresso_depois AS (
    SELECT 
        user_id,
        challenge_id,
        COUNT(DISTINCT DATE(to_brt(check_in_date))) as checkins_correto,
        COUNT(DISTINCT DATE(to_brt(check_in_date))) * 10 as pontos_correto
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id
)
SELECT 
    '⚖️ USUÁRIOS COM PROGRESSO INFLADO' as tipo,
    COUNT(*) as usuarios_afetados,
    SUM(pa.checkins_atual - pd.checkins_correto) as total_checkins_inflados,
    SUM(pa.pontos_atual - pd.pontos_correto) as total_pontos_inflados
FROM progresso_antes pa
JOIN progresso_depois pd ON (pa.user_id = pd.user_id AND pa.challenge_id = pd.challenge_id)
WHERE pa.checkins_atual > pd.checkins_correto;

-- ================================================================
-- PARTE 4: LIMPEZA DOS DUPLICADOS
-- ================================================================

SELECT '🧽 REMOVENDO DUPLICADOS' as etapa;

-- Remover duplicados (manter apenas o mais antigo)
WITH duplicados_para_remover AS (
    SELECT 
        id,
        ROW_NUMBER() OVER (
            PARTITION BY user_id, challenge_id, DATE(to_brt(check_in_date))
            ORDER BY created_at ASC  -- Manter o mais antigo
        ) as rn
    FROM challenge_check_ins
)
DELETE FROM challenge_check_ins 
WHERE id IN (
    SELECT id 
    FROM duplicados_para_remover 
    WHERE rn > 1
);

-- Verificar resultado
SELECT 
    '✅ DUPLICADOS REMOVIDOS' as status,
    (SELECT COUNT(*) FROM backup_duplicate_checkins) as backup_total,
    (SELECT COUNT(*) FROM challenge_check_ins) as checkins_restantes;

-- ================================================================
-- PARTE 5: RECALCULAR PROGRESSO DOS DESAFIOS
-- ================================================================

SELECT '🔄 RECALCULANDO PROGRESSO' as etapa;

-- Recalcular challenge_progress com dados corretos
WITH progresso_correto AS (
    SELECT 
        cci.challenge_id,
        cci.user_id,
        COUNT(DISTINCT DATE(to_brt(cci.check_in_date))) as check_ins_count_correto,
        COUNT(DISTINCT DATE(to_brt(cci.check_in_date))) * 10 as points_correto,
        MAX(cci.check_in_date) as last_check_in_correto,
        MAX(cci.user_name) as user_name,
        MAX(cci.user_photo_url) as user_photo_url,
        -- Calcular porcentagem com base na duração do desafio
        COALESCE(
            LEAST(100, 
                COUNT(DISTINCT DATE(to_brt(cci.check_in_date))) * 100.0 / 
                GREATEST(1, DATE_PART('day', c.end_date - c.start_date) + 1)
            ), 0
        ) as completion_percentage_correto
    FROM challenge_check_ins cci
    JOIN challenges c ON c.id = cci.challenge_id
    GROUP BY cci.challenge_id, cci.user_id, c.start_date, c.end_date
)
UPDATE challenge_progress cp
SET 
    check_ins_count = pc.check_ins_count_correto,
    total_check_ins = pc.check_ins_count_correto,
    points = pc.points_correto,
    last_check_in = pc.last_check_in_correto,
    completion_percentage = pc.completion_percentage_correto,
    updated_at = to_brt(NOW()),
    user_name = pc.user_name,
    user_photo_url = pc.user_photo_url
FROM progresso_correto pc
WHERE cp.challenge_id = pc.challenge_id 
AND cp.user_id = pc.user_id;

SELECT '✅ PROGRESSO RECALCULADO' as status;

-- ================================================================
-- PARTE 6: RECALCULAR RANKINGS
-- ================================================================

SELECT '🏆 RECALCULANDO RANKINGS' as etapa;

-- Recalcular posições no ranking para cada desafio
WITH rankings_atualizados AS (
    SELECT 
        cp.challenge_id,
        cp.user_id,
        DENSE_RANK() OVER (
            PARTITION BY cp.challenge_id
            ORDER BY cp.points DESC, 
                     cp.check_ins_count DESC, 
                     cp.last_check_in ASC NULLS LAST
        ) as nova_posicao
    FROM challenge_progress cp
)
UPDATE challenge_progress cp
SET 
    position = ra.nova_posicao,
    updated_at = to_brt(NOW())
FROM rankings_atualizados ra
WHERE cp.challenge_id = ra.challenge_id 
AND cp.user_id = ra.user_id;

SELECT '✅ RANKINGS RECALCULADOS' as status;

-- ================================================================
-- PARTE 7: VERIFICAÇÃO FINAL
-- ================================================================

SELECT '🔍 VERIFICAÇÃO FINAL' as etapa;

-- Verificar se ainda existem duplicados
SELECT 
    '❌ DUPLICADOS RESTANTES' as tipo,
    COUNT(*) as grupos_com_duplicados
FROM (
    SELECT 
        user_id,
        challenge_id,
        DATE(to_brt(check_in_date)) as data_checkin,
        COUNT(*) as total_checkins
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, DATE(to_brt(check_in_date))
    HAVING COUNT(*) > 1
) duplicados_restantes;

-- Estatísticas pós-limpeza
SELECT 
    '📊 ESTATÍSTICAS PÓS-LIMPEZA' as tipo,
    COUNT(*) as total_checkins_final,
    COUNT(DISTINCT CONCAT(user_id, challenge_id, DATE(to_brt(check_in_date)))) as checkins_unicos_final,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT CONCAT(user_id, challenge_id, DATE(to_brt(check_in_date)))) 
        THEN 'ZERO DUPLICADOS ✅'
        ELSE 'AINDA HÁ DUPLICADOS ❌'
    END as status_duplicados
FROM challenge_check_ins;

-- ================================================================
-- PARTE 8: LOG DA OPERAÇÃO
-- ================================================================

-- Registrar a operação de limpeza
INSERT INTO check_in_error_logs (
    user_id, 
    challenge_id, 
    workout_id, 
    error_message, 
    status, 
    created_at
) VALUES (
    NULL,
    NULL,
    NULL,
    'LIMPEZA DE DUPLICADOS CONCLUÍDA - ' || (SELECT COUNT(*) FROM backup_duplicate_checkins) || ' registros em backup',
    'cleanup_success',
    to_brt(NOW())
);

-- ================================================================
-- RESUMO FINAL
-- ================================================================

SELECT '🎉 LIMPEZA CONCLUÍDA' as titulo;

SELECT '✅ DUPLICADOS REMOVIDOS' as acao,
'Check-ins duplicados foram removidos mantendo sempre o mais antigo' as descricao;

SELECT '✅ PROGRESSO CORRIGIDO' as acao,
'Tabela challenge_progress recalculada com dados corretos' as descricao;

SELECT '✅ RANKINGS ATUALIZADOS' as acao,
'Posições no ranking recalculadas baseadas no progresso real' as descricao;

SELECT '✅ BACKUP CRIADO' as acao,
'Todos os registros removidos estão na tabela backup_duplicate_checkins' as descricao;

SELECT '🚀 RESULTADO' as acao,
'Sistema limpo e pronto para evitar novos duplicados' as descricao; 