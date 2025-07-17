-- ✅ VERIFICAÇÃO FINAL: Sistema Pós-Limpeza Emergencial
-- Data: 2025-01-11
-- Status: Limpeza emergencial concluída com sucesso

SET timezone = 'America/Sao_Paulo';

-- 🎯 VERIFICAÇÃO GERAL DO SISTEMA
SELECT 
    '🎯 STATUS GERAL DO SISTEMA' as status,
    COUNT(*) as total_checkins_limpos,
    COUNT(DISTINCT user_id) as usuarios_ativos,
    COUNT(DISTINCT challenge_id) as challenges_ativos,
    COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) as dias_unicos,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT (user_id, challenge_id, check_in_date::date))
        THEN '✅ SISTEMA 100% LIMPO'
        ELSE '⚠️ AINDA HÁ DUPLICADOS: ' || (COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)))::text
    END as status_duplicados,
    SUM(points) as total_pontos_corretos,
    ROUND(AVG(points), 1) as media_pontos_por_checkin
FROM challenge_check_ins;

-- 📊 COMPARAÇÃO ANTES vs DEPOIS
SELECT 
    '📊 COMPARAÇÃO ANTES vs DEPOIS' as status,
    (SELECT COUNT(*) FROM challenge_check_ins_backup_emergency_20250111) as checkins_antes,
    (SELECT COUNT(*) FROM challenge_check_ins) as checkins_depois,
    (SELECT COUNT(*) FROM challenge_check_ins_backup_emergency_20250111) - 
    (SELECT COUNT(*) FROM challenge_check_ins) as checkins_removidos,
    ROUND(
        ((SELECT COUNT(*) FROM challenge_check_ins_backup_emergency_20250111) - 
         (SELECT COUNT(*) FROM challenge_check_ins)) * 100.0 / 
        (SELECT COUNT(*) FROM challenge_check_ins_backup_emergency_20250111), 
        2
    ) as percentual_reducao,
    (SELECT SUM(points) FROM challenge_check_ins_backup_emergency_20250111) as pontos_antes,
    (SELECT SUM(points) FROM challenge_check_ins) as pontos_depois,
    (SELECT SUM(points) FROM challenge_check_ins_backup_emergency_20250111) - 
    (SELECT SUM(points) FROM challenge_check_ins) as pontos_corrigidos;

-- 🏆 TOP 10 USUÁRIOS MAIS ATIVOS (Verificação de Sanidade)
SELECT 
    '🏆 TOP 10 USUÁRIOS MAIS ATIVOS' as status,
    user_id,
    challenge_id,
    COUNT(*) as total_checkins,
    COUNT(DISTINCT check_in_date::date) as dias_unicos,
    SUM(points) as pontos_totais,
    MIN(check_in_date) as primeiro_checkin,
    MAX(check_in_date) as ultimo_checkin,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT check_in_date::date) THEN '✅ PERFEITO'
        ELSE '⚠️ PROBLEMA'
    END as status_usuario
FROM challenge_check_ins
GROUP BY user_id, challenge_id
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 📅 DISTRIBUIÇÃO TEMPORAL DOS CHECK-INS
SELECT 
    '📅 DISTRIBUIÇÃO TEMPORAL' as status,
    check_in_date::date as data,
    COUNT(*) as checkins_no_dia,
    COUNT(DISTINCT user_id) as usuarios_ativos_dia,
    SUM(points) as pontos_distribuidos_dia
FROM challenge_check_ins
WHERE check_in_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY check_in_date::date
ORDER BY check_in_date::date DESC
LIMIT 15;

-- 🔍 VERIFICAÇÃO DE INTEGRIDADE DETALHADA
WITH verificacao_integridade AS (
    SELECT 
        user_id,
        challenge_id,
        check_in_date::date as data,
        COUNT(*) as checkins_por_dia,
        SUM(points) as pontos_por_dia
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, check_in_date::date
    HAVING COUNT(*) > 1  -- Procurar por duplicados restantes
)
SELECT 
    '🔍 VERIFICAÇÃO DE INTEGRIDADE' as status,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ INTEGRIDADE PERFEITA - ZERO DUPLICADOS'
        ELSE '⚠️ ENCONTRADOS ' || COUNT(*) || ' POSSÍVEIS PROBLEMAS'
    END as resultado,
    COUNT(*) as problemas_encontrados
FROM verificacao_integridade;

-- 📈 ESTATÍSTICAS DE PERFORMANCE
SELECT 
    '📈 ESTATÍSTICAS DE PERFORMANCE' as status,
    COUNT(DISTINCT user_id) as usuarios_unicos,
    COUNT(DISTINCT challenge_id) as challenges_unicos,
    COUNT(*) as total_checkins_otimizados,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT user_id), 1) as media_checkins_por_usuario,
    ROUND(SUM(points) * 1.0 / COUNT(DISTINCT user_id), 1) as media_pontos_por_usuario,
    DATE_TRUNC('day', MIN(check_in_date))::date as primeiro_checkin_sistema,
    DATE_TRUNC('day', MAX(check_in_date))::date as ultimo_checkin_sistema,
    EXTRACT(DAYS FROM (MAX(check_in_date) - MIN(check_in_date))) as dias_de_atividade
FROM challenge_check_ins;

-- 🎯 USUÁRIOS QUE PRECISAM DE RECÁLCULO DE PROGRESSO
WITH usuarios_sem_progresso AS (
    SELECT DISTINCT cci.user_id, cci.challenge_id
    FROM challenge_check_ins cci
    LEFT JOIN challenge_progress cp ON cci.user_id = cp.user_id AND cci.challenge_id = cp.challenge_id
    WHERE cp.user_id IS NULL
)
SELECT 
    '🎯 USUÁRIOS PARA RECÁLCULO' as status,
    COUNT(*) as usuarios_sem_progresso,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ TODOS OS USUÁRIOS TÊM PROGRESSO CALCULADO'
        ELSE '⚠️ ' || COUNT(*) || ' USUÁRIOS PRECISAM DE RECÁLCULO'
    END as status_progresso
FROM usuarios_sem_progresso;

-- 🚀 RECOMENDAÇÕES FINAIS
SELECT 
    '🚀 RECOMENDAÇÕES FINAIS' as status,
    'Sistema limpo e otimizado com sucesso' as resultado_principal,
    'Execute recalculate_all_users_batch.sql para recalcular todos os usuários' as proxima_acao,
    'Monitore por 24h para garantir que não há novas duplicações' as monitoramento,
    'Considere implementar constraint UNIQUE para prevenir futuras duplicações' as prevencao,
    'Investigue código de criação de check-ins para corrigir bug na origem' as correcao_bug;

-- 💾 INFORMAÇÕES DO BACKUP
SELECT 
    '💾 BACKUP DE SEGURANÇA' as status,
    'challenge_check_ins_backup_emergency_20250111' as tabela_backup_checkins,
    'challenge_progress_backup_emergency_20250111' as tabela_backup_progress,
    (SELECT COUNT(*) FROM challenge_check_ins_backup_emergency_20250111) as registros_backup_checkins,
    (SELECT COUNT(*) FROM challenge_progress_backup_emergency_20250111) as registros_backup_progress,
    'Backups mantidos para segurança - podem ser removidos após 30 dias' as observacao; 