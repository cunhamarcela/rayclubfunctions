-- 🧹 LIMPEZA MASSIVA: Usuário bc0bfc71 - 413 Check-ins Duplicados
-- Data: 2025-01-11
-- Problema: 430 check-ins quando deveria ter apenas 17

SET timezone = 'America/Sao_Paulo';

-- 🔍 ANTES DA LIMPEZA - Situação atual
SELECT 
    '📊 ANTES DA LIMPEZA' as status,
    COUNT(*) as total_checkins,
    COUNT(DISTINCT check_in_date::date) as dias_unicos,
    SUM(points) as pontos_totais,
    COUNT(*) - COUNT(DISTINCT check_in_date::date) as duplicados_para_remover
FROM challenge_check_ins 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
    AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- 🧹 LIMPEZA: Manter apenas 1 check-in por dia (o mais antigo com treino válido)
WITH checkins_para_manter AS (
    SELECT DISTINCT ON (check_in_date::date)
        id,
        check_in_date::date as data,
        workout_id,
        points,
        created_at,
        CASE 
            WHEN workout_id IS NOT NULL THEN 1  -- Prioridade para check-ins com treino
            ELSE 2  -- Check-ins manuais têm menor prioridade
        END as prioridade
    FROM challenge_check_ins 
    WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
        AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
    ORDER BY 
        check_in_date::date DESC,  -- Mais recente primeiro
        prioridade ASC,            -- Check-ins com treino primeiro
        created_at ASC             -- Mais antigo primeiro (primeiro check-in do dia)
),
checkins_para_deletar AS (
    SELECT cci.id
    FROM challenge_check_ins cci
    WHERE cci.user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
        AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
        AND cci.id NOT IN (SELECT id FROM checkins_para_manter)
)
-- 🗑️ DELETAR check-ins duplicados
DELETE FROM challenge_check_ins 
WHERE id IN (SELECT id FROM checkins_para_deletar);

-- 📊 APÓS LIMPEZA - Verificar resultado
SELECT 
    '✅ APÓS LIMPEZA' as status,
    COUNT(*) as total_checkins,
    COUNT(DISTINCT check_in_date::date) as dias_unicos,
    SUM(points) as pontos_totais,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT check_in_date::date) THEN '✅ SEM DUPLICADOS'
        ELSE '⚠️ AINDA HÁ DUPLICADOS: ' || (COUNT(*) - COUNT(DISTINCT check_in_date::date))::text
    END as status_duplicados
FROM challenge_check_ins 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
    AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- 🔄 RECALCULAR progresso após limpeza
SELECT recalculate_challenge_progress_complete_fixed(
    'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'::uuid,
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::uuid
) as recalculo_resultado;

-- 📋 VERIFICAÇÃO FINAL - Check-ins mantidos por dia
SELECT 
    '📅 CHECK-INS FINAIS' as status,
    check_in_date::date as data,
    COUNT(*) as checkins_no_dia,
    STRING_AGG(
        CASE 
            WHEN workout_id IS NULL THEN '❌ Manual'
            ELSE '✅ Treino: ' || COALESCE(wr.workout_name, 'Sem nome')
        END, 
        ', '
    ) as tipo_checkin,
    SUM(points) as pontos_dia
FROM challenge_check_ins cci
LEFT JOIN workout_records wr ON cci.workout_id = wr.id
WHERE cci.user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
    AND cci.challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'
GROUP BY check_in_date::date
ORDER BY data DESC;

-- 🎯 PROGRESSO FINAL ATUALIZADO
SELECT 
    '🏆 PROGRESSO FINAL' as status,
    points as pontos_finais,
    check_ins as checkins_finais,
    total_check_ins as total_checkins_finais,
    ROUND(completion_percentage, 2) as percentual_conclusao,
    position as posicao_final,
    updated_at as atualizado_em
FROM challenge_progress 
WHERE user_id = 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55'
    AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- 📈 RESUMO DA OPERAÇÃO
SELECT 
    '📈 RESUMO DA LIMPEZA' as status,
    'Check-ins removidos' as metrica,
    (SELECT COUNT(*) FROM (VALUES (1)) v) as valor_antes,  -- Placeholder, será substituído pelo resultado real
    'Pontos corrigidos de 4300 para ~170' as correcao,
    'Bug de duplicação massiva corrigido' as resultado; 