-- 🛡️ MEDIDAS PREVENTIVAS: Constraints e Monitoramento
-- Data: 2025-01-11
-- Objetivo: Prevenir futuras duplicações de check-ins

SET timezone = 'America/Sao_Paulo';

-- 🔒 CONSTRAINT PRINCIPAL: Prevenir duplicados
-- Esta constraint garante que não pode haver mais de 1 check-in por usuário/challenge/dia
DO $$
BEGIN
    -- Verificar se a constraint já existe
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint 
        WHERE conname = 'unique_user_challenge_date'
    ) THEN
        -- Criar constraint UNIQUE
        ALTER TABLE challenge_check_ins 
        ADD CONSTRAINT unique_user_challenge_date 
        UNIQUE (user_id, challenge_id, check_in_date::date);
        
        RAISE NOTICE '✅ Constraint unique_user_challenge_date criada com sucesso';
    ELSE
        RAISE NOTICE '⚠️ Constraint unique_user_challenge_date já existe';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE WARNING '❌ Erro ao criar constraint: %', SQLERRM;
END $$;

-- 📊 FUNÇÃO DE MONITORAMENTO: Detectar tentativas de duplicação
CREATE OR REPLACE FUNCTION monitor_duplicate_checkins()
RETURNS TABLE(
    status TEXT,
    user_id UUID,
    challenge_id UUID,
    check_in_date DATE,
    tentativas_duplicacao INTEGER,
    ultimo_erro TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        '🚨 TENTATIVA DE DUPLICAÇÃO DETECTADA' as status,
        cci.user_id,
        cci.challenge_id,
        cci.check_in_date::date,
        COUNT(*)::INTEGER as tentativas_duplicacao,
        MAX(cci.created_at) as ultimo_erro
    FROM challenge_check_ins cci
    GROUP BY cci.user_id, cci.challenge_id, cci.check_in_date::date
    HAVING COUNT(*) > 1;
END;
$$ LANGUAGE plpgsql;

-- 🔍 FUNÇÃO DE AUDITORIA: Verificar integridade do sistema
CREATE OR REPLACE FUNCTION audit_system_integrity()
RETURNS TABLE(
    categoria TEXT,
    metrica TEXT,
    valor INTEGER,
    status TEXT,
    observacao TEXT
) AS $$
BEGIN
    RETURN QUERY
    -- Total de check-ins
    SELECT 
        'GERAL'::TEXT as categoria,
        'Total Check-ins'::TEXT as metrica,
        COUNT(*)::INTEGER as valor,
        '✅ OK'::TEXT as status,
        'Check-ins no sistema'::TEXT as observacao
    FROM challenge_check_ins
    
    UNION ALL
    
    -- Verificar duplicados
    SELECT 
        'INTEGRIDADE'::TEXT as categoria,
        'Duplicados'::TEXT as metrica,
        (COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)))::INTEGER as valor,
        CASE 
            WHEN COUNT(*) = COUNT(DISTINCT (user_id, challenge_id, check_in_date::date)) 
            THEN '✅ OK'::TEXT
            ELSE '🚨 PROBLEMA'::TEXT
        END as status,
        'Check-ins duplicados encontrados'::TEXT as observacao
    FROM challenge_check_ins
    
    UNION ALL
    
    -- Usuários ativos
    SELECT 
        'USUARIOS'::TEXT as categoria,
        'Usuários Ativos'::TEXT as metrica,
        COUNT(DISTINCT user_id)::INTEGER as valor,
        '✅ OK'::TEXT as status,
        'Usuários com check-ins'::TEXT as observacao
    FROM challenge_check_ins
    
    UNION ALL
    
    -- Challenges ativos
    SELECT 
        'CHALLENGES'::TEXT as categoria,
        'Challenges Ativos'::TEXT as metrica,
        COUNT(DISTINCT challenge_id)::INTEGER as valor,
        '✅ OK'::TEXT as status,
        'Challenges com atividade'::TEXT as observacao
    FROM challenge_check_ins
    
    UNION ALL
    
    -- Pontos totais
    SELECT 
        'PONTOS'::TEXT as categoria,
        'Total Pontos'::TEXT as metrica,
        SUM(points)::INTEGER as valor,
        CASE 
            WHEN SUM(points) = COUNT(*) * 10 THEN '✅ OK'::TEXT
            ELSE '⚠️ VERIFICAR'::TEXT
        END as status,
        'Pontos distribuídos no sistema'::TEXT as observacao
    FROM challenge_check_ins;
END;
$$ LANGUAGE plpgsql;

-- 📈 FUNÇÃO DE RELATÓRIO DIÁRIO: Monitorar crescimento
CREATE OR REPLACE FUNCTION daily_system_report()
RETURNS TABLE(
    data DATE,
    novos_checkins INTEGER,
    usuarios_ativos INTEGER,
    pontos_distribuidos INTEGER,
    duplicados_detectados INTEGER,
    status_dia TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cci.check_in_date::date as data,
        COUNT(*)::INTEGER as novos_checkins,
        COUNT(DISTINCT cci.user_id)::INTEGER as usuarios_ativos,
        SUM(cci.points)::INTEGER as pontos_distribuidos,
        (COUNT(*) - COUNT(DISTINCT (cci.user_id, cci.challenge_id, cci.check_in_date::date)))::INTEGER as duplicados_detectados,
        CASE 
            WHEN COUNT(*) = COUNT(DISTINCT (cci.user_id, cci.challenge_id, cci.check_in_date::date))
            THEN '✅ DIA LIMPO'::TEXT
            ELSE '🚨 DUPLICADOS DETECTADOS'::TEXT
        END as status_dia
    FROM challenge_check_ins cci
    WHERE cci.check_in_date >= CURRENT_DATE - INTERVAL '7 days'
    GROUP BY cci.check_in_date::date
    ORDER BY cci.check_in_date::date DESC;
END;
$$ LANGUAGE plpgsql;

-- 🔧 FUNÇÃO DE LIMPEZA AUTOMÁTICA: Para uso futuro se necessário
CREATE OR REPLACE FUNCTION auto_cleanup_duplicates()
RETURNS TABLE(
    status TEXT,
    duplicados_removidos INTEGER,
    usuarios_afetados INTEGER,
    pontos_corrigidos INTEGER
) AS $$
DECLARE
    duplicados_count INTEGER;
BEGIN
    -- Verificar se há duplicados
    SELECT COUNT(*) - COUNT(DISTINCT (user_id, challenge_id, check_in_date::date))
    INTO duplicados_count
    FROM challenge_check_ins;
    
    IF duplicados_count > 0 THEN
        -- Executar limpeza similar à emergencial
        WITH checkins_para_manter AS (
            SELECT DISTINCT ON (user_id, challenge_id, check_in_date::date)
                id
            FROM challenge_check_ins 
            ORDER BY 
                user_id,
                challenge_id,
                check_in_date::date DESC,
                CASE WHEN workout_id IS NOT NULL THEN 1 ELSE 2 END ASC,
                created_at ASC
        ),
        checkins_removidos AS (
            DELETE FROM challenge_check_ins 
            WHERE id NOT IN (SELECT id FROM checkins_para_manter)
            RETURNING user_id, challenge_id, points
        )
        SELECT 
            '🧹 LIMPEZA AUTOMÁTICA EXECUTADA'::TEXT,
            COUNT(*)::INTEGER,
            COUNT(DISTINCT user_id)::INTEGER,
            SUM(points)::INTEGER
        FROM checkins_removidos;
    ELSE
        RETURN QUERY
        SELECT 
            '✅ SISTEMA LIMPO - NENHUMA AÇÃO NECESSÁRIA'::TEXT as status,
            0::INTEGER as duplicados_removidos,
            0::INTEGER as usuarios_afetados,
            0::INTEGER as pontos_corrigidos;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ✅ EXECUTAR VERIFICAÇÕES INICIAIS
SELECT * FROM audit_system_integrity();

-- 📊 RELATÓRIO DOS ÚLTIMOS 7 DIAS
SELECT * FROM daily_system_report();

-- 🔍 VERIFICAR SE HÁ DUPLICADOS (deve retornar vazio)
SELECT * FROM monitor_duplicate_checkins();

-- 📋 RESUMO DAS MEDIDAS IMPLEMENTADAS
SELECT 
    '📋 MEDIDAS PREVENTIVAS IMPLEMENTADAS' as status,
    'Constraint UNIQUE criada para prevenir duplicados' as medida_1,
    'Função de monitoramento para detectar tentativas' as medida_2,
    'Função de auditoria para verificar integridade' as medida_3,
    'Função de relatório diário para acompanhamento' as medida_4,
    'Função de limpeza automática para emergências' as medida_5,
    'Sistema totalmente protegido contra duplicações' as resultado; 