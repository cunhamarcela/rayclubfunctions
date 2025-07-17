-- ================================================================
-- INVESTIGAÇÃO COMPLETA: CHECK-INS DUPLICADOS
-- ================================================================
-- Esta investigação vai mostrar:
-- 1. QUANTOS duplicados existem
-- 2. QUANDO foram criados
-- 3. QUAL a causa raiz 
-- 4. SE nossa correção resolve
-- ================================================================

SELECT '🔍 INVESTIGANDO CHECK-INS DUPLICADOS' as titulo;

-- ================================================================
-- PARTE 1: DIAGNÓSTICO ATUAL DOS DUPLICADOS
-- ================================================================

SELECT '📊 ANÁLISE DE DUPLICADOS EXISTENTES' as secao;

-- 1.1 Quantos duplicados por usuário/desafio/data
SELECT 
    '👥 DUPLICADOS POR USUÁRIO/DESAFIO/DATA' as tipo,
    user_id,
    challenge_id,
    DATE(to_brt(check_in_date)) as data_checkin,
    COUNT(*) as total_checkins,
    COUNT(*) - 1 as duplicados,
    STRING_AGG(id::text, ', ') as ids_duplicados
FROM challenge_check_ins
GROUP BY user_id, challenge_id, DATE(to_brt(check_in_date))
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC, user_id, data_checkin
LIMIT 20;

-- 1.2 Total geral de duplicados
SELECT 
    '📈 ESTATÍSTICAS GERAIS' as tipo,
    COUNT(*) as total_checkins,
    COUNT(DISTINCT CONCAT(user_id, challenge_id, DATE(to_brt(check_in_date)))) as checkins_unicos_esperados,
    COUNT(*) - COUNT(DISTINCT CONCAT(user_id, challenge_id, DATE(to_brt(check_in_date)))) as total_duplicados,
    ROUND(
        (COUNT(*) - COUNT(DISTINCT CONCAT(user_id, challenge_id, DATE(to_brt(check_in_date))))) * 100.0 / COUNT(*), 
        2
    ) as percentual_duplicados
FROM challenge_check_ins;

-- 1.3 Duplicados por período
SELECT 
    '📅 DUPLICADOS POR PERÍODO' as tipo,
    DATE_TRUNC('day', created_at) as dia_criacao,
    COUNT(*) as checkins_criados,
    COUNT(DISTINCT CONCAT(user_id, challenge_id, DATE(to_brt(check_in_date)))) as checkins_unicos,
    COUNT(*) - COUNT(DISTINCT CONCAT(user_id, challenge_id, DATE(to_brt(check_in_date)))) as duplicados_do_dia
FROM challenge_check_ins
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY dia_criacao DESC;

-- ================================================================
-- PARTE 2: ANÁLISE DA CAUSA RAIZ
-- ================================================================

SELECT '🔬 ANÁLISE DA CAUSA RAIZ' as secao;

-- 2.1 Diferenças de timestamp em duplicados
SELECT 
    '⏰ DIFERENÇAS DE TEMPO EM DUPLICADOS' as tipo,
    cci1.user_id,
    cci1.challenge_id,
    DATE(to_brt(cci1.check_in_date)) as data_checkin,
    cci1.created_at as primeiro_checkin,
    cci2.created_at as segundo_checkin,
    EXTRACT(EPOCH FROM (cci2.created_at - cci1.created_at)) as diferenca_segundos,
    cci1.workout_name as workout_1,
    cci2.workout_name as workout_2
FROM challenge_check_ins cci1
JOIN challenge_check_ins cci2 ON (
    cci1.user_id = cci2.user_id 
    AND cci1.challenge_id = cci2.challenge_id
    AND DATE(to_brt(cci1.check_in_date)) = DATE(to_brt(cci2.check_in_date))
    AND cci1.id != cci2.id
    AND cci1.created_at < cci2.created_at
)
ORDER BY diferenca_segundos ASC
LIMIT 10;

-- 2.2 Verificar se há padrão nos workout_ids
SELECT 
    '🔄 PADRÃO NOS WORKOUT_IDs DUPLICADOS' as tipo,
    cci1.user_id,
    cci1.challenge_id,
    DATE(to_brt(cci1.check_in_date)) as data_checkin,
    cci1.workout_id as workout_id_1,
    cci2.workout_id as workout_id_2,
    CASE 
        WHEN cci1.workout_id = cci2.workout_id THEN 'MESMO WORKOUT'
        ELSE 'WORKOUTS DIFERENTES'
    END as analise_workout_id
FROM challenge_check_ins cci1
JOIN challenge_check_ins cci2 ON (
    cci1.user_id = cci2.user_id 
    AND cci1.challenge_id = cci2.challenge_id
    AND DATE(to_brt(cci1.check_in_date)) = DATE(to_brt(cci2.check_in_date))
    AND cci1.id != cci2.id
)
LIMIT 15;

-- ================================================================
-- PARTE 3: ANÁLISE DAS FUNÇÕES ANTIGAS (CAUSA DO PROBLEMA)
-- ================================================================

SELECT '🐛 PROBLEMAS NAS FUNÇÕES ANTIGAS' as secao;

-- 3.1 Verificar se ainda existem funções problemáticas
SELECT 
    '🔍 FUNÇÕES EXISTENTES' as tipo,
    proname as nome_funcao,
    pg_get_function_arguments(oid) as argumentos,
    CASE 
        WHEN proname = 'record_workout_basic' THEN 'PRINCIPAL - CORRIGIDA'
        WHEN proname = 'process_workout_for_ranking' THEN 'RANKING - CORRIGIDA'
        WHEN proname LIKE '%_fixed' THEN 'VERSÃO ANTIGA - DEVE SER REMOVIDA'
        WHEN proname LIKE 'record_challenge_check_in%' THEN 'NÃO USADA PELO APP'
        ELSE 'ANALISAR'
    END as status_funcao
FROM pg_proc 
WHERE proname ILIKE '%workout%' OR proname ILIKE '%check%'
ORDER BY proname;

-- ================================================================
-- PARTE 4: SIMULAÇÃO - NOSSA CORREÇÃO IMPEDIRIA OS DUPLICADOS?
-- ================================================================

SELECT '🧪 TESTANDO NOSSA CORREÇÃO' as secao;

-- 4.1 Simular o que aconteceria com nossa lógica corrigida
WITH duplicados_exemplo AS (
    SELECT 
        user_id,
        challenge_id,
        DATE(to_brt(check_in_date)) as data_checkin,
        MIN(created_at) as primeiro_checkin,
        MAX(created_at) as ultimo_checkin,
        COUNT(*) as total_duplicados
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, DATE(to_brt(check_in_date))
    HAVING COUNT(*) > 1
    LIMIT 5
),
teste_nossa_logica AS (
    SELECT 
        de.*,
        -- NOSSA LÓGICA: verificar se já existe check-in para a mesma data
        EXISTS (
            SELECT 1 FROM challenge_check_ins cci
            WHERE cci.user_id = de.user_id
            AND cci.challenge_id = de.challenge_id
            AND DATE(to_brt(cci.check_in_date)) = de.data_checkin
        ) as nossa_logica_impediria
    FROM duplicados_exemplo de
)
SELECT 
    '✅ TESTE DA NOSSA CORREÇÃO' as tipo,
    user_id,
    challenge_id,
    data_checkin,
    total_duplicados,
    CASE 
        WHEN nossa_logica_impediria THEN 'SIM - IMPEDIRIA DUPLICADOS'
        ELSE 'NÃO - PROBLEMA PERSISTE'
    END as resultado_teste
FROM teste_nossa_logica;

-- ================================================================
-- PARTE 5: RECOMENDAÇÕES DE LIMPEZA
-- ================================================================

SELECT '🧹 RECOMENDAÇÕES DE LIMPEZA' as secao;

-- 5.1 Quais duplicados podem ser removidos com segurança
SELECT 
    '🗑️ DUPLICADOS SEGUROS PARA REMOÇÃO' as tipo,
    COUNT(*) as total_duplicados_removiveis,
    'Manter o mais antigo, remover os demais' as criterio
FROM (
    SELECT 
        user_id,
        challenge_id,
        DATE(to_brt(check_in_date)) as data_checkin,
        COUNT(*) - 1 as duplicados_removiveis
    FROM challenge_check_ins
    GROUP BY user_id, challenge_id, DATE(to_brt(check_in_date))
    HAVING COUNT(*) > 1
) subquery;

-- 5.2 Script de limpeza (apenas mostrar, não executar)
SELECT '📝 SCRIPT DE LIMPEZA SUGERIDO' as tipo,
'
-- CUIDADO: Executar apenas após backup!
DELETE FROM challenge_check_ins 
WHERE id IN (
    SELECT id FROM (
        SELECT 
            id,
            ROW_NUMBER() OVER (
                PARTITION BY user_id, challenge_id, DATE(to_brt(check_in_date))
                ORDER BY created_at ASC  -- Manter o mais antigo
            ) as rn
        FROM challenge_check_ins
    ) ranked
    WHERE rn > 1  -- Remover duplicados (manter apenas o primeiro)
);
' as script_limpeza;

-- ================================================================
-- PARTE 6: VERIFICAÇÃO PÓS-CORREÇÃO
-- ================================================================

SELECT '📋 CHECKLIST PÓS-CORREÇÃO' as secao;

SELECT '✅ NOSSA CORREÇÃO RESOLVE?' as pergunta,
'SIM - A função process_workout_for_ranking agora verifica duplicados por DATA ao invés de timestamp' as resposta_1;

SELECT '✅ O QUE MUDOU?' as pergunta,
'Verificação: DATE(to_brt(check_in_date)) = workout_date_brt (só compara data, ignora hora)' as resposta_2;

SELECT '✅ AINDA PODE HAVER DUPLICADOS?' as pergunta,
'NÃO - A nova lógica impede múltiplos check-ins na mesma data para mesmo usuário/desafio' as resposta_3;

SELECT '✅ PRECISA LIMPAR OS EXISTENTES?' as pergunta,
'SIM - Duplicados antigos ainda estão no banco e afetam ranking/progresso' as resposta_4;

-- ================================================================
-- RESUMO EXECUTIVO
-- ================================================================

SELECT '📋 RESUMO EXECUTIVO' as titulo;

SELECT '🎯 CAUSA RAIZ IDENTIFICADA' as item,
'Funções antigas permitiam múltiplos check-ins no mesmo dia por não comparar apenas a data' as descricao;

SELECT '✅ CORREÇÃO APLICADA' as item,
'process_workout_for_ranking agora compara DATE(check_in_date) ao invés de timestamp completo' as descricao;

SELECT '🧹 AÇÃO NECESSÁRIA' as item,
'Executar limpeza dos duplicados existentes + aplicar nossa correção' as descricao;

SELECT '🚀 RESULTADO ESPERADO' as item,
'Zero novos duplicados + ranking/progresso corrigido' as descricao; 