-- =====================================================
-- ANÁLISE TEMPORAL PROFUNDA DOS REGISTROS ANTIGOS
-- =====================================================
-- Este script investiga os registros "muito antigos" para determinar
-- se são check-ins retroativos legítimos ou problemas sistêmicos

-- =====================================================
-- PARTE 1: ANÁLISE DE DISTRIBUIÇÃO TEMPORAL
-- =====================================================

-- Analisar distribuição de diferenças de dias em challenge_check_ins
CREATE OR REPLACE FUNCTION analyze_temporal_distribution_checkins()
RETURNS TABLE (
    days_difference INTEGER,
    record_count BIGINT,
    percentage DECIMAL,
    classification TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    total_records BIGINT;
BEGIN
    SELECT COUNT(*) INTO total_records FROM challenge_check_ins;
    
    RETURN QUERY
    WITH daily_diffs AS (
        SELECT 
            DATE(created_at) - DATE(check_in_date) as diff_days,
            COUNT(*) as count
        FROM challenge_check_ins
        GROUP BY DATE(created_at) - DATE(check_in_date)
        ORDER BY diff_days
    )
    SELECT 
        diff_days as days_difference,
        count as record_count,
        ROUND((count * 100.0) / total_records, 2) as percentage,
        CASE 
            WHEN diff_days = 0 THEN '✅ IDEAL'
            WHEN diff_days BETWEEN 1 AND 2 THEN '🟡 NORMAL RETROATIVO'
            WHEN diff_days BETWEEN 3 AND 7 THEN '🟠 RETROATIVO ACEITÁVEL'
            WHEN diff_days BETWEEN 8 AND 30 THEN '⚠️ MUITO ANTIGO'
            WHEN diff_days > 30 THEN '❌ SUSPEITO'
            WHEN diff_days < 0 THEN '🚨 FUTURO (ERRO)'
            ELSE '❓ INDEFINIDO'
        END as classification
    FROM daily_diffs;
    
END;
$$;

-- Analisar distribuição de diferenças de dias em workout_records
CREATE OR REPLACE FUNCTION analyze_temporal_distribution_workouts()
RETURNS TABLE (
    days_difference INTEGER,
    record_count BIGINT,
    percentage DECIMAL,
    classification TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    total_records BIGINT;
BEGIN
    SELECT COUNT(*) INTO total_records FROM workout_records;
    
    RETURN QUERY
    WITH daily_diffs AS (
        SELECT 
            DATE(created_at) - DATE(date) as diff_days,
            COUNT(*) as count
        FROM workout_records
        GROUP BY DATE(created_at) - DATE(date)
        ORDER BY diff_days
    )
    SELECT 
        diff_days as days_difference,
        count as record_count,
        ROUND((count * 100.0) / total_records, 2) as percentage,
        CASE 
            WHEN diff_days = 0 THEN '✅ IDEAL'
            WHEN diff_days BETWEEN 1 AND 2 THEN '🟡 NORMAL RETROATIVO'
            WHEN diff_days BETWEEN 3 AND 7 THEN '🟠 RETROATIVO ACEITÁVEL'
            WHEN diff_days BETWEEN 8 AND 30 THEN '⚠️ MUITO ANTIGO'
            WHEN diff_days > 30 THEN '❌ SUSPEITO'
            WHEN diff_days < 0 THEN '🚨 FUTURO (ERRO)'
            ELSE '❓ INDEFINIDO'
        END as classification
    FROM daily_diffs;
    
END;
$$;

-- =====================================================
-- PARTE 2: ANÁLISE DE PADRÕES TEMPORAIS SUSPEITOS
-- =====================================================

-- Identificar possíveis problemas sistêmicos
CREATE OR REPLACE FUNCTION identify_systematic_issues()
RETURNS TABLE (
    issue_type TEXT,
    table_name TEXT,
    affected_records BIGINT,
    details TEXT,
    sample_data TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    checkin_30_plus BIGINT;
    workout_30_plus BIGINT;
    checkin_same_pattern_count BIGINT;
    workout_same_pattern_count BIGINT;
    checkin_bulk_dates TEXT;
    workout_bulk_dates TEXT;
BEGIN
    -- Contar registros com mais de 30 dias de diferença
    SELECT COUNT(*) INTO checkin_30_plus
    FROM challenge_check_ins 
    WHERE DATE(created_at) - DATE(check_in_date) > 30;
    
    SELECT COUNT(*) INTO workout_30_plus
    FROM workout_records 
    WHERE DATE(created_at) - DATE(date) > 30;
    
    -- Identificar padrões de bulk insert (muitos registros na mesma data)
    SELECT COUNT(*) INTO checkin_same_pattern_count
    FROM (
        SELECT DATE(created_at), COUNT(*) as daily_count
        FROM challenge_check_ins
        WHERE DATE(created_at) - DATE(check_in_date) > 7
        GROUP BY DATE(created_at)
        HAVING COUNT(*) > 10 -- Mais de 10 registros no mesmo dia
    ) bulk_patterns;
    
    SELECT COUNT(*) INTO workout_same_pattern_count
    FROM (
        SELECT DATE(created_at), COUNT(*) as daily_count
        FROM workout_records
        WHERE DATE(created_at) - DATE(date) > 7
        GROUP BY DATE(created_at)
        HAVING COUNT(*) > 10 -- Mais de 10 registros no mesmo dia
    ) bulk_patterns;
    
    -- Obter amostras de datas com padrões suspeitos
    SELECT STRING_AGG(DISTINCT DATE(created_at)::TEXT, ', ' ORDER BY DATE(created_at)::TEXT) INTO checkin_bulk_dates
    FROM (
        SELECT DATE(created_at)
        FROM challenge_check_ins
        WHERE DATE(created_at) - DATE(check_in_date) > 7
        GROUP BY DATE(created_at)
        HAVING COUNT(*) > 10
        LIMIT 5
    ) sample_dates;
    
    SELECT STRING_AGG(DISTINCT DATE(created_at)::TEXT, ', ' ORDER BY DATE(created_at)::TEXT) INTO workout_bulk_dates
    FROM (
        SELECT DATE(created_at)
        FROM workout_records
        WHERE DATE(created_at) - DATE(date) > 7
        GROUP BY DATE(created_at)
        HAVING COUNT(*) > 10
        LIMIT 5
    ) sample_dates;
    
    -- Retornar resultados
    RETURN QUERY SELECT 
        'Registros muito antigos (>30 dias)' as issue_type,
        'challenge_check_ins' as table_name,
        checkin_30_plus as affected_records,
        'Possível migração de dados ou problema sistêmico' as details,
        'Requer investigação manual' as sample_data;
    
    RETURN QUERY SELECT 
        'Registros muito antigos (>30 dias)' as issue_type,
        'workout_records' as table_name,
        workout_30_plus as affected_records,
        'Possível migração de dados ou problema sistêmico' as details,
        'Requer investigação manual' as sample_data;
    
    RETURN QUERY SELECT 
        'Padrões de inserção em massa' as issue_type,
        'challenge_check_ins' as table_name,
        checkin_same_pattern_count as affected_records,
        'Dias com >10 registros retroativos - possível bulk insert' as details,
        COALESCE(checkin_bulk_dates, 'Nenhum encontrado') as sample_data;
    
    RETURN QUERY SELECT 
        'Padrões de inserção em massa' as issue_type,
        'workout_records' as table_name,
        workout_same_pattern_count as affected_records,
        'Dias com >10 registros retroativos - possível bulk insert' as details,
        COALESCE(workout_bulk_dates, 'Nenhum encontrado') as sample_data;
    
END;
$$;

-- =====================================================
-- PARTE 3: ANÁLISE DE REGISTRO POR PERÍODO
-- =====================================================

-- Analisar quando os registros "problemáticos" foram criados
CREATE OR REPLACE FUNCTION analyze_creation_patterns()
RETURNS TABLE (
    creation_period TEXT,
    table_name TEXT,
    total_records BIGINT,
    problematic_records BIGINT,
    problematic_percentage DECIMAL
) 
LANGUAGE plpgsql
AS $$
BEGIN
    -- Análise por mês para challenge_check_ins
    RETURN QUERY
    WITH monthly_checkins AS (
        SELECT 
            TO_CHAR(created_at, 'YYYY-MM') as month_year,
            COUNT(*) as total,
            COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) > 7 THEN 1 END) as problematic
        FROM challenge_check_ins
        GROUP BY TO_CHAR(created_at, 'YYYY-MM')
        ORDER BY month_year DESC
    )
    SELECT 
        month_year as creation_period,
        'challenge_check_ins' as table_name,
        total as total_records,
        problematic as problematic_records,
        ROUND((problematic * 100.0) / NULLIF(total, 0), 2) as problematic_percentage
    FROM monthly_checkins
    WHERE total > 0;
    
    -- Análise por mês para workout_records
    RETURN QUERY
    WITH monthly_workouts AS (
        SELECT 
            TO_CHAR(created_at, 'YYYY-MM') as month_year,
            COUNT(*) as total,
            COUNT(CASE WHEN DATE(created_at) - DATE(date) > 7 THEN 1 END) as problematic
        FROM workout_records
        GROUP BY TO_CHAR(created_at, 'YYYY-MM')
        ORDER BY month_year DESC
    )
    SELECT 
        month_year as creation_period,
        'workout_records' as table_name,
        total as total_records,
        problematic as problematic_records,
        ROUND((problematic * 100.0) / NULLIF(total, 0), 2) as problematic_percentage
    FROM monthly_workouts
    WHERE total > 0;
    
END;
$$;

-- =====================================================
-- PARTE 4: RECOMENDAÇÕES DE CORREÇÃO
-- =====================================================

-- Função para gerar recomendações baseadas na análise
CREATE OR REPLACE FUNCTION generate_correction_recommendations()
RETURNS TABLE (
    recommendation_type TEXT,
    priority TEXT,
    description TEXT,
    sql_action TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    checkin_very_old BIGINT;
    workout_very_old BIGINT;
    checkin_bulk_days BIGINT;
    workout_bulk_days BIGINT;
BEGIN
    -- Contar registros muito antigos
    SELECT COUNT(*) INTO checkin_very_old
    FROM challenge_check_ins 
    WHERE DATE(created_at) - DATE(check_in_date) > 30;
    
    SELECT COUNT(*) INTO workout_very_old
    FROM workout_records 
    WHERE DATE(created_at) - DATE(date) > 30;
    
    -- Contar dias com padrões de bulk
    SELECT COUNT(*) INTO checkin_bulk_days
    FROM (
        SELECT DATE(created_at)
        FROM challenge_check_ins
        WHERE DATE(created_at) - DATE(check_in_date) > 7
        GROUP BY DATE(created_at)
        HAVING COUNT(*) > 10
    ) bulk_days;
    
    SELECT COUNT(*) INTO workout_bulk_days
    FROM (
        SELECT DATE(created_at)
        FROM workout_records
        WHERE DATE(created_at) - DATE(date) > 7
        GROUP BY DATE(created_at)
        HAVING COUNT(*) > 10
    ) bulk_days;
    
    -- Gerar recomendações baseadas nos achados
    IF checkin_very_old > 100 THEN
        RETURN QUERY SELECT 
            'Correção de registros muito antigos' as recommendation_type,
            'ALTA' as priority,
            'Há ' || checkin_very_old || ' check-ins com >30 dias - possível migração incorreta' as description,
            'Investigar e possivelmente corrigir datas de check-ins muito antigos' as sql_action;
    END IF;
    
    IF workout_very_old > 100 THEN
        RETURN QUERY SELECT 
            'Correção de treinos muito antigos' as recommendation_type,
            'ALTA' as priority,
            'Há ' || workout_very_old || ' treinos com >30 dias - possível migração incorreta' as description,
            'Investigar e possivelmente corrigir datas de treinos muito antigos' as sql_action;
    END IF;
    
    IF checkin_bulk_days > 5 THEN
        RETURN QUERY SELECT 
            'Investigar padrões de bulk insert' as recommendation_type,
            'MÉDIA' as priority,
            'Há ' || checkin_bulk_days || ' dias com >10 check-ins retroativos - possível bulk insert' as description,
            'Analisar se são migrações legítimas ou problemas sistêmicos' as sql_action;
    END IF;
    
    -- Sempre incluir recomendação de melhoria futura
    RETURN QUERY SELECT 
        'Melhoria na validação' as recommendation_type,
        'BAIXA' as priority,
        'Implementar validação para limitar check-ins retroativos (ex: máximo 7 dias)' as description,
        'Adicionar constraint ou validação no app para limitar retroativos' as sql_action;
    
END;
$$;

-- =====================================================
-- EXECUTAR ANÁLISES COMPLETAS
-- =====================================================

SELECT '=== DISTRIBUIÇÃO TEMPORAL - CHALLENGE CHECK-INS ===' as section;
SELECT * FROM analyze_temporal_distribution_checkins();

SELECT '=== DISTRIBUIÇÃO TEMPORAL - WORKOUT RECORDS ===' as section;
SELECT * FROM analyze_temporal_distribution_workouts();

SELECT '=== IDENTIFICAÇÃO DE PROBLEMAS SISTÊMICOS ===' as section;
SELECT * FROM identify_systematic_issues();

SELECT '=== PADRÕES DE CRIAÇÃO POR PERÍODO ===' as section;
SELECT * FROM analyze_creation_patterns() 
ORDER BY creation_period DESC;

SELECT '=== RECOMENDAÇÕES DE CORREÇÃO ===' as section;
SELECT * FROM generate_correction_recommendations();

-- =====================================================
-- RESUMO EXECUTIVO
-- =====================================================
/*
ANÁLISE TEMPORAL PROFUNDA - RESUMO:

1. DISTRIBUIÇÃO TEMPORAL:
   ✓ Mostra distribuição exata de diferenças de dias
   ✓ Classifica registros por legitimidade
   ✓ Identifica padrões suspeitos

2. PROBLEMAS SISTÊMICOS:
   ✓ Registros muito antigos (>30 dias)
   ✓ Padrões de inserção em massa
   ✓ Possíveis migrações incorretas

3. PADRÕES DE CRIAÇÃO:
   ✓ Análise por período (mensal)
   ✓ Identificação de quando problemas ocorreram
   ✓ Percentual de problemas por período

4. RECOMENDAÇÕES:
   ✓ Priorização de correções
   ✓ Ações específicas recomendadas
   ✓ Melhorias futuras

OBJETIVO:
- Determinar se inconsistências são legítimas ou sistêmicas
- Gerar plano de ação para correções
- Melhorar validações futuras
*/

SELECT 'ANÁLISE TEMPORAL PROFUNDA CONCLUÍDA!' as final_status; 