-- =====================================================
-- ANÁLISE E CORREÇÃO DE INCONSISTÊNCIAS DE DATAS
-- =====================================================
-- Este script analisa as inconsistências encontradas e corrige
-- apenas aquelas que são realmente problemáticas

-- =====================================================
-- PARTE 1: ANÁLISE DETALHADA DAS INCONSISTÊNCIAS
-- =====================================================

-- Analisar inconsistências em workout_records
CREATE OR REPLACE FUNCTION analyze_workout_records_inconsistencies()
RETURNS TABLE (
    analysis_type TEXT,
    count_records INTEGER,
    percentage DECIMAL,
    details TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    total_records INTEGER;
    same_day INTEGER;
    one_day_diff INTEGER;
    two_day_diff INTEGER;
    more_than_two_days INTEGER;
    future_dates INTEGER;
BEGIN
    -- Contar total
    SELECT COUNT(*) INTO total_records FROM workout_records;
    
    -- Analisar diferenças de datas
    SELECT 
        COUNT(CASE WHEN DATE(created_at) = DATE(date) THEN 1 END),
        COUNT(CASE WHEN DATE(created_at) - DATE(date) = 1 THEN 1 END),
        COUNT(CASE WHEN DATE(created_at) - DATE(date) = 2 THEN 1 END),
        COUNT(CASE WHEN DATE(created_at) - DATE(date) > 2 THEN 1 END),
        COUNT(CASE WHEN DATE(date) > DATE(created_at) THEN 1 END)
    INTO same_day, one_day_diff, two_day_diff, more_than_two_days, future_dates
    FROM workout_records;
    
    RETURN QUERY SELECT 
        'Mesmo dia (correto)' as analysis_type,
        same_day as count_records,
        ROUND((same_day * 100.0) / total_records, 2) as percentage,
        'created_at e date no mesmo dia' as details;
    
    RETURN QUERY SELECT 
        'Um dia de diferença' as analysis_type,
        one_day_diff as count_records,
        ROUND((one_day_diff * 100.0) / total_records, 2) as percentage,
        'Possível check-in retroativo de 1 dia (normal)' as details;
    
    RETURN QUERY SELECT 
        'Dois dias de diferença' as analysis_type,
        two_day_diff as count_records,
        ROUND((two_day_diff * 100.0) / total_records, 2) as percentage,
        'Check-in retroativo de 2 dias' as details;
    
    RETURN QUERY SELECT 
        'Mais de 2 dias' as analysis_type,
        more_than_two_days as count_records,
        ROUND((more_than_two_days * 100.0) / total_records, 2) as percentage,
        'Check-ins muito antigos - podem ser problemáticos' as details;
        
    RETURN QUERY SELECT 
        'Datas futuras' as analysis_type,
        future_dates as count_records,
        ROUND((future_dates * 100.0) / total_records, 2) as percentage,
        'ERRO: treino registrado para data futura' as details;
    
END;
$$;

-- Analisar inconsistências em challenge_check_ins
CREATE OR REPLACE FUNCTION analyze_challenge_checkins_inconsistencies()
RETURNS TABLE (
    analysis_type TEXT,
    count_records INTEGER,
    percentage DECIMAL,
    details TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    total_records INTEGER;
    same_day INTEGER;
    one_day_diff INTEGER;
    two_day_diff INTEGER;
    more_than_two_days INTEGER;
    future_dates INTEGER;
BEGIN
    -- Contar total
    SELECT COUNT(*) INTO total_records FROM challenge_check_ins;
    
    -- Analisar diferenças de datas
    SELECT 
        COUNT(CASE WHEN DATE(created_at) = DATE(check_in_date) THEN 1 END),
        COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) = 1 THEN 1 END),
        COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) = 2 THEN 1 END),
        COUNT(CASE WHEN DATE(created_at) - DATE(check_in_date) > 2 THEN 1 END),
        COUNT(CASE WHEN DATE(check_in_date) > DATE(created_at) THEN 1 END)
    INTO same_day, one_day_diff, two_day_diff, more_than_two_days, future_dates
    FROM challenge_check_ins;
    
    RETURN QUERY SELECT 
        'Mesmo dia (correto)' as analysis_type,
        same_day as count_records,
        ROUND((same_day * 100.0) / total_records, 2) as percentage,
        'created_at e check_in_date no mesmo dia' as details;
    
    RETURN QUERY SELECT 
        'Um dia de diferença' as analysis_type,
        one_day_diff as count_records,
        ROUND((one_day_diff * 100.0) / total_records, 2) as percentage,
        'Possível check-in retroativo de 1 dia (normal)' as details;
    
    RETURN QUERY SELECT 
        'Dois dias de diferença' as analysis_type,
        two_day_diff as count_records,
        ROUND((two_day_diff * 100.0) / total_records, 2) as percentage,
        'Check-in retroativo de 2 dias' as details;
    
    RETURN QUERY SELECT 
        'Mais de 2 dias' as analysis_type,
        more_than_two_days as count_records,
        ROUND((more_than_two_days * 100.0) / total_records, 2) as percentage,
        'Check-ins muito antigos - podem ser problemáticos' as details;
        
    RETURN QUERY SELECT 
        'Datas futuras' as analysis_type,
        future_dates as count_records,
        ROUND((future_dates * 100.0) / total_records, 2) as percentage,
        'ERRO: check-in registrado para data futura' as details;
    
END;
$$;

-- =====================================================
-- PARTE 2: IDENTIFICAR PROBLEMAS REAIS
-- =====================================================

-- Função para identificar registros com problemas reais de timezone
CREATE OR REPLACE FUNCTION identify_problematic_records()
RETURNS TABLE (
    table_name TEXT,
    problem_type TEXT,
    record_count INTEGER,
    sample_ids TEXT[]
) 
LANGUAGE plpgsql
AS $$
DECLARE
    workout_future_count INTEGER;
    workout_future_ids TEXT[];
    checkin_future_count INTEGER;
    checkin_future_ids TEXT[];
    workout_old_count INTEGER;
    workout_old_ids TEXT[];
    checkin_old_count INTEGER;
    checkin_old_ids TEXT[];
BEGIN
    -- Problemas em workout_records - datas futuras (ERROR REAL)
    SELECT 
        COUNT(*),
        ARRAY_AGG(id::TEXT)
    INTO workout_future_count, workout_future_ids
    FROM workout_records 
    WHERE DATE(date) > DATE(created_at)
    LIMIT 10;
    
    RETURN QUERY SELECT 
        'workout_records' as table_name,
        'Datas futuras (ERRO)' as problem_type,
        workout_future_count as record_count,
        COALESCE(workout_future_ids, ARRAY[]::TEXT[]) as sample_ids;
    
    -- Problemas em challenge_check_ins - datas futuras (ERROR REAL)
    SELECT 
        COUNT(*),
        ARRAY_AGG(id::TEXT)
    INTO checkin_future_count, checkin_future_ids
    FROM challenge_check_ins 
    WHERE DATE(check_in_date) > DATE(created_at)
    LIMIT 10;
    
    RETURN QUERY SELECT 
        'challenge_check_ins' as table_name,
        'Datas futuras (ERRO)' as problem_type,
        checkin_future_count as record_count,
        COALESCE(checkin_future_ids, ARRAY[]::TEXT[]) as sample_ids;
    
    -- Registros muito antigos (possivelmente problemáticos)
    SELECT 
        COUNT(*),
        ARRAY_AGG(id::TEXT)
    INTO workout_old_count, workout_old_ids
    FROM workout_records 
    WHERE DATE(created_at) - DATE(date) > 7 -- Mais de 7 dias de diferença
    LIMIT 10;
    
    RETURN QUERY SELECT 
        'workout_records' as table_name,
        'Mais de 7 dias antigos' as problem_type,
        workout_old_count as record_count,
        COALESCE(workout_old_ids, ARRAY[]::TEXT[]) as sample_ids;
    
    SELECT 
        COUNT(*),
        ARRAY_AGG(id::TEXT)
    INTO checkin_old_count, checkin_old_ids
    FROM challenge_check_ins 
    WHERE DATE(created_at) - DATE(check_in_date) > 7 -- Mais de 7 dias de diferença
    LIMIT 10;
    
    RETURN QUERY SELECT 
        'challenge_check_ins' as table_name,
        'Mais de 7 dias antigos' as problem_type,
        checkin_old_count as record_count,
        COALESCE(checkin_old_ids, ARRAY[]::TEXT[]) as sample_ids;
    
END;
$$;

-- =====================================================
-- PARTE 3: CORRIGIR PROBLEMAS REAIS
-- =====================================================

-- Função para corrigir datas futuras (ERROR real)
CREATE OR REPLACE FUNCTION fix_future_dates()
RETURNS TABLE (
    table_name TEXT,
    fixed_count INTEGER,
    description TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    workout_fixed_count INTEGER;
    checkin_fixed_count INTEGER;
BEGIN
    -- Corrigir workout_records com datas futuras
    -- Ajustar date para created_at quando date > created_at
    UPDATE workout_records 
    SET date = created_at
    WHERE DATE(date) > DATE(created_at);
    
    GET DIAGNOSTICS workout_fixed_count = ROW_COUNT;
    
    RETURN QUERY SELECT 
        'workout_records' as table_name,
        workout_fixed_count as fixed_count,
        'Datas futuras corrigidas para created_at' as description;
    
    -- Corrigir challenge_check_ins com datas futuras
    -- Ajustar check_in_date para created_at quando check_in_date > created_at
    UPDATE challenge_check_ins 
    SET 
        check_in_date = created_at,
        brt_date = DATE(created_at)
    WHERE DATE(check_in_date) > DATE(created_at);
    
    GET DIAGNOSTICS checkin_fixed_count = ROW_COUNT;
    
    RETURN QUERY SELECT 
        'challenge_check_ins' as table_name,
        checkin_fixed_count as fixed_count,
        'Datas futuras corrigidas para created_at' as description;
    
END;
$$;

-- =====================================================
-- PARTE 4: ATUALIZAR CAMPOS BRT_DATE
-- =====================================================

-- Função para garantir que brt_date está correto em challenge_check_ins
CREATE OR REPLACE FUNCTION update_brt_dates()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    updated_count INTEGER;
BEGIN
    -- Atualizar brt_date para garantir consistência
    UPDATE challenge_check_ins 
    SET brt_date = DATE(check_in_date)
    WHERE brt_date IS NULL 
    OR brt_date != DATE(check_in_date);
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    
    RETURN 'brt_date atualizado em ' || updated_count || ' registros';
END;
$$;

-- =====================================================
-- PARTE 5: EXECUTAR ANÁLISE E CORREÇÕES
-- =====================================================

SELECT '=== ANÁLISE DETALHADA DE workout_records ===' as section;
SELECT * FROM analyze_workout_records_inconsistencies();

SELECT '=== ANÁLISE DETALHADA DE challenge_check_ins ===' as section;
SELECT * FROM analyze_challenge_checkins_inconsistencies();

SELECT '=== IDENTIFICAÇÃO DE PROBLEMAS REAIS ===' as section;
SELECT * FROM identify_problematic_records();

SELECT '=== CORRIGINDO DATAS FUTURAS (ERROS REAIS) ===' as section;
SELECT * FROM fix_future_dates();

SELECT '=== ATUALIZANDO BRT_DATE ===' as section;
SELECT update_brt_dates();

-- =====================================================
-- PARTE 6: VERIFICAÇÃO FINAL APÓS CORREÇÕES
-- =====================================================

SELECT '=== VERIFICAÇÃO FINAL APÓS CORREÇÕES ===' as section;

SELECT 
    'Análise workout_records (APÓS CORREÇÃO)' as tabela,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN DATE(created_at) = DATE(date) THEN 1 END) as datas_consistentes,
    COUNT(CASE WHEN DATE(created_at) != DATE(date) THEN 1 END) as datas_inconsistentes,
    COUNT(CASE WHEN DATE(date) > DATE(created_at) THEN 1 END) as datas_futuras_restantes
FROM workout_records
UNION ALL
SELECT 
    'Análise challenge_check_ins (APÓS CORREÇÃO)' as tabela,
    COUNT(*) as total_registros,
    COUNT(CASE WHEN DATE(created_at) = DATE(check_in_date) THEN 1 END) as datas_consistentes,
    COUNT(CASE WHEN DATE(created_at) != DATE(check_in_date) THEN 1 END) as datas_inconsistentes,
    COUNT(CASE WHEN DATE(check_in_date) > DATE(created_at) THEN 1 END) as datas_futuras_restantes
FROM challenge_check_ins;

-- =====================================================
-- RESUMO FINAL
-- =====================================================
/*
ANÁLISE E CORREÇÕES APLICADAS:

1. ANÁLISE DETALHADA:
   ✓ Identificação de tipos de inconsistências
   ✓ Diferenciação entre retroativos legítimos e erros reais
   ✓ Percentuais e contagens por categoria

2. CORREÇÕES APLICADAS:
   ✓ Datas futuras corrigidas (erros reais)
   ✓ brt_date atualizado para consistência
   ✓ Mantidos check-ins retroativos legítimos

3. CLASSIFICAÇÃO DE INCONSISTÊNCIAS:
   ✅ LEGÍTIMAS: Check-ins retroativos (1-7 dias atrás)
   ❌ PROBLEMÁTICAS: Datas futuras (corrigidas)
   ⚠️  ATENÇÃO: Muito antigos (>7 dias) - revisão manual

4. RESULTADO:
   - Erros reais corrigidos
   - Check-ins retroativos preservados
   - Sistema consistente e funcional
*/

SELECT 'ANÁLISE E CORREÇÃO DE INCONSISTÊNCIAS CONCLUÍDA!' as final_status; 