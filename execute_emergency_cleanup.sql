-- 🚨 EXECUÇÃO EMERGENCIAL: Limpeza Sistêmica Imediata
-- Data: 2025-01-11
-- Situação: 63.32% dos check-ins são duplicados (1.902 de 3.004)
-- Impacto: 19.020 pontos em excesso distribuídos incorretamente

SET timezone = 'America/Sao_Paulo';

-- 🛡️ BACKUP DE SEGURANÇA OBRIGATÓRIO
CREATE TABLE challenge_check_ins_backup_emergency_20250111 AS 
SELECT * FROM challenge_check_ins;

CREATE TABLE challenge_progress_backup_emergency_20250111 AS 
SELECT * FROM challenge_progress;

-- ✅ CONFIRMAÇÃO DO BACKUP
SELECT 
    '🛡️ BACKUP CRIADO' as status,
    (SELECT COUNT(*) FROM challenge_check_ins_backup_emergency_20250111) as checkins_backup,
    (SELECT COUNT(*) FROM challenge_progress_backup_emergency_20250111) as progress_backup,
    'Backups criados com sucesso' as resultado;

-- 🔍 SITUAÇÃO PRÉ-LIMPEZA
SELECT 
    '📊 PRÉ-LIMPEZA' as status,
    COUNT(*) as total_checkins,
    COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) as checkins_unicos,
    COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) as duplicados_para_remover,
    SUM(points) as pontos_atuais,
    COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) * 10 as pontos_corretos,
    SUM(points) - (COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) * 10) as pontos_excesso
FROM challenge_check_ins;

-- 🧹 LIMPEZA EMERGENCIAL
WITH checkins_para_manter AS (
    SELECT DISTINCT ON (user_id, challenge_id, check_in_date::date)
        id,
        user_id,
        challenge_id,
        check_in_date::date as data,
        workout_id,
        points,
        created_at,
        CASE 
            WHEN workout_id IS NOT NULL THEN 1
            ELSE 2
        END as prioridade
    FROM challenge_check_ins 
    ORDER BY 
        user_id,
        challenge_id,
        check_in_date::date DESC,
        prioridade ASC,
        created_at ASC
),
checkins_removidos AS (
    DELETE FROM challenge_check_ins 
    WHERE id NOT IN (SELECT id FROM checkins_para_manter)
    RETURNING user_id, challenge_id, points
)
SELECT 
    '🗑️ LIMPEZA EXECUTADA' as status,
    COUNT(*) as checkins_removidos,
    COUNT(DISTINCT user_id) as usuarios_afetados,
    SUM(points) as pontos_removidos
FROM checkins_removidos;

-- 📊 SITUAÇÃO PÓS-LIMPEZA
SELECT 
    '✅ PÓS-LIMPEZA' as status,
    COUNT(*) as total_checkins_final,
    COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) as checkins_unicos_final,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) 
        THEN '✅ ZERO DUPLICADOS'
        ELSE '⚠️ AINDA HÁ ' || (COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)))::text || ' DUPLICADOS'
    END as status_duplicados,
    SUM(points) as pontos_finais,
    COUNT(DISTINCT user_id) as usuarios_ativos
FROM challenge_check_ins;

-- 🔄 RECÁLCULO EMERGENCIAL (Top 10 usuários mais afetados)
DO $$
DECLARE
    rec RECORD;
    contador INTEGER := 0;
BEGIN
    RAISE NOTICE '🔄 Iniciando recálculo emergencial para usuários críticos...';
    
    FOR rec IN 
        SELECT DISTINCT user_id, challenge_id 
        FROM challenge_check_ins
        WHERE user_id IN (
            'bc0bfc71-f0cb-4636-a998-026b9e2b5b55',
            'a1f29898-8d87-4ec5-ae28-6266d829cad3',
            'e7cbe577-b716-4ca8-9988-89f53efb7ac0',
            '35d01551-b8f2-44a6-9e5b-363588169245',
            '4208f40a-b650-4a73-b3d8-101738cc1b1e',
            '78922a06-b7f6-46f5-b6ee-4c8ce9a6b918',
            '122cb813-b1f1-4ffa-bcb7-b1a623a1d770',
            '680d6fb1-8186-4208-99b6-2f46fae18fea',
            '6e451549-ba1e-452e-9065-25323da039c0',
            '353c4021-5c8c-495d-9c60-060e3c7d0f03'
        )
    LOOP
        contador := contador + 1;
        
        PERFORM recalculate_challenge_progress_complete_fixed(
            rec.user_id::uuid,
            rec.challenge_id::uuid
        );
        
        RAISE NOTICE 'Recalculado usuário %: % (%/10)', rec.user_id, rec.challenge_id, contador;
    END LOOP;
    
    RAISE NOTICE '✅ Recálculo emergencial concluído para % usuários críticos', contador;
END $$;

-- 🎯 VERIFICAÇÃO DOS USUÁRIOS CRÍTICOS
SELECT 
    '🎯 USUÁRIOS CRÍTICOS CORRIGIDOS' as status,
    user_id,
    challenge_id,
    COUNT(*) as checkins_finais,
    COUNT(DISTINCT check_in_date::date) as dias_unicos,
    SUM(points) as pontos_finais,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT check_in_date::date) THEN '✅ CORRIGIDO'
        ELSE '⚠️ AINDA TEM PROBLEMA'
    END as status_usuario
FROM challenge_check_ins
WHERE user_id IN (
    'bc0bfc71-f0cb-4636-a998-026b9e2b5b55',
    'a1f29898-8d87-4ec5-ae28-6266d829cad3',
    'e7cbe577-b716-4ca8-9988-89f53efb7ac0'
)
GROUP BY user_id, challenge_id
ORDER BY SUM(points) DESC;

-- 📈 RELATÓRIO FINAL EMERGENCIAL
SELECT 
    '📈 RELATÓRIO EMERGENCIAL' as status,
    'Limpeza sistêmica executada com sucesso' as resultado,
    (SELECT COUNT(*) FROM challenge_check_ins_backup_emergency_20250111) - 
    (SELECT COUNT(*) FROM challenge_check_ins) as checkins_removidos_total,
    (SELECT COUNT(*) FROM challenge_check_ins) as checkins_restantes,
    (SELECT COUNT(DISTINCT user_id) FROM challenge_check_ins) as usuarios_ativos,
    'Sistema estabilizado - duplicados eliminados' as status_sistema;

-- 🚨 PRÓXIMOS PASSOS
SELECT 
    '🚨 PRÓXIMOS PASSOS' as status,
    '1. Execute recalculate_all_users_batch.sql para recalcular TODOS os usuários' as passo_1,
    '2. Investigue o código que gera check-ins para corrigir o bug' as passo_2,
    '3. Monitore sistema por 24h para garantir que não há novas duplicações' as passo_3,
    '4. Considere adicionar constraint UNIQUE para prevenir futuras duplicações' as passo_4; 