-- 🔄 RECÁLCULO EM LOTES: Progresso de Todos os Usuários
-- Data: 2025-01-11
-- Objetivo: Recalcular progresso de forma eficiente após limpeza sistêmica

SET timezone = 'America/Sao_Paulo';

-- 📊 USUÁRIOS PARA RECALCULAR
SELECT 
    '📊 USUÁRIOS PARA RECALCULAR' as status,
    COUNT(DISTINCT user_id) as total_usuarios,
    COUNT(DISTINCT challenge_id) as total_challenges,
    COUNT(DISTINCT (user_id, challenge_id)) as combinacoes_usuario_challenge
FROM challenge_check_ins;

-- 🔄 RECÁLCULO EM LOTES - VERSÃO OTIMIZADA
-- Execute este bloco para recalcular todos os usuários
DO $$
DECLARE
    rec RECORD;
    contador INTEGER := 0;
    total INTEGER;
    lote_size INTEGER := 50;  -- Processar 50 usuários por vez
    inicio_tempo TIMESTAMP;
    tempo_lote TIMESTAMP;
    usuarios_processados INTEGER := 0;
BEGIN
    inicio_tempo := clock_timestamp();
    
    -- Contar total de combinações usuário/challenge
    SELECT COUNT(*) INTO total
    FROM (SELECT DISTINCT user_id, challenge_id FROM challenge_check_ins) t;
    
    RAISE NOTICE '🚀 Iniciando recálculo sistêmico para % combinações usuário/challenge...', total;
    RAISE NOTICE '⚙️ Processando em lotes de % usuários', lote_size;
    
    -- Processar cada usuário/challenge
    FOR rec IN 
        SELECT DISTINCT user_id, challenge_id 
        FROM challenge_check_ins
        ORDER BY user_id, challenge_id
    LOOP
        contador := contador + 1;
        
        BEGIN
            -- Recalcular progresso para este usuário/challenge
            PERFORM recalculate_challenge_progress_complete_fixed(
                rec.user_id::uuid,
                rec.challenge_id::uuid
            );
            
            usuarios_processados := usuarios_processados + 1;
            
        EXCEPTION WHEN OTHERS THEN
            -- Log de erro mas continua processamento
            RAISE WARNING 'Erro ao recalcular usuário %: %', rec.user_id, SQLERRM;
        END;
        
        -- Log de progresso e pausa a cada lote
        IF contador % lote_size = 0 THEN
            tempo_lote := clock_timestamp();
            RAISE NOTICE '✅ Lote concluído: %/% usuários (%.1f%%) - Tempo: %s', 
                contador, total, (contador * 100.0 / total),
                (tempo_lote - inicio_tempo);
            
            -- Pequena pausa para não sobrecarregar o banco
            PERFORM pg_sleep(0.1);
        END IF;
    END LOOP;
    
    RAISE NOTICE '🎉 Recálculo sistêmico concluído!';
    RAISE NOTICE '📊 Total processado: % usuários com sucesso', usuarios_processados;
    RAISE NOTICE '⏱️ Tempo total: %', (clock_timestamp() - inicio_tempo);
    
END $$;

-- 📊 VERIFICAÇÃO PÓS-RECÁLCULO
SELECT 
    '📊 VERIFICAÇÃO PÓS-RECÁLCULO' as status,
    COUNT(DISTINCT cp.user_id) as usuarios_com_progresso,
    COUNT(DISTINCT cci.user_id) as usuarios_com_checkins,
    CASE 
        WHEN COUNT(DISTINCT cp.user_id) = COUNT(DISTINCT cci.user_id) 
        THEN '✅ TODOS OS USUÁRIOS TÊM PROGRESSO CALCULADO'
        ELSE '⚠️ FALTAM USUÁRIOS: ' || (COUNT(DISTINCT cci.user_id) - COUNT(DISTINCT cp.user_id))::text
    END as status_cobertura
FROM challenge_progress cp
FULL OUTER JOIN challenge_check_ins cci ON cp.user_id = cci.user_id AND cp.challenge_id = cci.challenge_id;

-- 🎯 USUÁRIOS COM INCONSISTÊNCIAS (se houver)
WITH inconsistencias AS (
    SELECT 
        cp.user_id,
        cp.challenge_id,
        cp.points as pontos_progresso,
        cp.check_ins as checkins_progresso,
        COUNT(cci.id) as checkins_reais,
        SUM(cci.points) as pontos_reais,
        CASE 
            WHEN cp.points != SUM(cci.points) THEN 'PONTOS_DIFERENTES'
            WHEN cp.check_ins != COUNT(cci.id) THEN 'CHECKINS_DIFERENTES'
            ELSE 'OK'
        END as tipo_inconsistencia
    FROM challenge_progress cp
    LEFT JOIN challenge_check_ins cci ON cp.user_id = cci.user_id AND cp.challenge_id = cci.challenge_id
    GROUP BY cp.user_id, cp.challenge_id, cp.points, cp.check_ins
    HAVING cp.points != COALESCE(SUM(cci.points), 0) 
        OR cp.check_ins != COUNT(cci.id)
)
SELECT 
    '🚨 INCONSISTÊNCIAS RESTANTES' as status,
    COUNT(*) as usuarios_com_inconsistencias,
    STRING_AGG(DISTINCT tipo_inconsistencia, ', ') as tipos_problemas
FROM inconsistencias;

-- 📈 ESTATÍSTICAS FINAIS DO SISTEMA
SELECT 
    '📈 ESTATÍSTICAS FINAIS' as status,
    COUNT(DISTINCT user_id) as usuarios_ativos,
    COUNT(DISTINCT challenge_id) as challenges_ativos,
    COUNT(*) as total_checkins_sistema,
    SUM(points) as total_pontos_sistema,
    ROUND(AVG(points), 1) as media_pontos_checkin,
    COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) as dias_unicos_sistema,
    CASE 
        WHEN COUNT(*) = COUNT(DISTINCT (user_id, challenge_id, check_in_date::date))
        THEN '✅ ZERO DUPLICADOS'
        ELSE '⚠️ AINDA HÁ ' || (COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)))::text || ' DUPLICADOS'
    END as status_duplicados_final
FROM challenge_check_ins;

-- 🏆 TOP 10 USUÁRIOS POR PONTOS (Verificação de sanidade)
SELECT 
    '🏆 TOP 10 USUÁRIOS' as status,
    user_id,
    challenge_id,
    points as pontos,
    check_ins as checkins,
    ROUND(completion_percentage, 1) as percentual_conclusao,
    position as posicao,
    updated_at as ultima_atualizacao
FROM challenge_progress
ORDER BY points DESC
LIMIT 10; 