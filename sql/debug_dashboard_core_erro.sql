-- ========================================
-- DEBUG: IDENTIFICAR ERRO NA CORREÇÃO
-- ========================================
-- Execute este script para identificar o problema

-- 1. VERIFICAR SE A FUNÇÃO ATUAL EXISTE
SELECT 
    '🔍 VERIFICAÇÃO INICIAL' as secao;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_dashboard_core') 
        THEN '✅ Função get_dashboard_core existe'
        ELSE '❌ Função get_dashboard_core NÃO existe'
    END as status_funcao;

-- 2. TESTE SIMPLES DA FUNÇÃO ATUAL (se existir)
SELECT 
    '🧪 TESTE DA FUNÇÃO ATUAL' as secao;

-- Tentar executar a função e capturar resultado ou erro
WITH function_test AS (
    SELECT 
        CASE 
            WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'get_dashboard_core')
            THEN 'existe'
            ELSE 'nao_existe'
        END as funcao_status
)
SELECT 
    ft.funcao_status,
    CASE 
        WHEN ft.funcao_status = 'existe' THEN
            CASE 
                WHEN (SELECT get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid) IS NOT NULL)
                THEN '✅ Função executa normalmente'
                ELSE '❌ Função retorna NULL'
            END
        ELSE '❌ Função não existe'
    END as resultado_teste,
    CASE 
        WHEN ft.funcao_status = 'existe' THEN
            (SELECT get_dashboard_core('01d4a292-1873-4af6-948b-a55eed56d6b9'::uuid)->>'total_duration')::int
        ELSE NULL
    END as minutos_atuais
FROM function_test ft;

-- 3. VERIFICAR ESTRUTURA DAS TABELAS NECESSÁRIAS
SELECT 
    '📊 VERIFICAÇÃO DAS TABELAS' as secao;

-- Verificar se workout_records existe e tem dados
SELECT 
    'workout_records' as tabela,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_records')
        THEN '✅ Existe'
        ELSE '❌ Não existe'
    END as status,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_records')
        THEN (SELECT COUNT(*)::text FROM workout_records WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9')
        ELSE '0'
    END as qtd_registros

UNION ALL

-- Verificar challenges
SELECT 
    'challenges' as tabela,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenges')
        THEN '✅ Existe'
        ELSE '❌ Não existe'
    END as status,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenges')
        THEN (SELECT COUNT(*)::text FROM challenges)
        ELSE '0'
    END as qtd_registros

UNION ALL

-- Verificar challenge_participants
SELECT 
    'challenge_participants' as tabela,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_participants')
        THEN '✅ Existe'
        ELSE '❌ Não existe'
    END as status,
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'challenge_participants')
        THEN (SELECT COUNT(*)::text FROM challenge_participants WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9')
        ELSE '0'
    END as qtd_registros;

-- 4. TESTE DE QUERY SIMPLES
SELECT 
    '🧪 TESTE DE QUERY BÁSICA' as secao;

-- Testar queries básicas que usamos na função
SELECT 
    'CONTAGEM DE TREINOS' as teste,
    COUNT(*) as total_treinos
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'

UNION ALL

SELECT 
    'MINUTOS MÊS ATUAL' as teste,
    COALESCE(SUM(duration_minutes), 0) as total_treinos
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND DATE_PART('year', date) = DATE_PART('year', CURRENT_DATE)
AND DATE_PART('month', date) = DATE_PART('month', CURRENT_DATE)

UNION ALL

SELECT 
    'DIAS ÚNICOS MÊS ATUAL' as teste,
    COUNT(DISTINCT DATE(date)) as total_treinos
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
AND DATE_PART('year', date) = DATE_PART('year', CURRENT_DATE)
AND DATE_PART('month', date) = DATE_PART('month', CURRENT_DATE);

-- 5. MOSTRAR INFORMAÇÕES DO SISTEMA
SELECT 
    '⚙️ INFORMAÇÕES DO SISTEMA' as secao;

SELECT 
    CURRENT_DATE as data_atual,
    DATE_PART('year', CURRENT_DATE) as ano_atual,
    DATE_PART('month', CURRENT_DATE) as mes_atual,
    version() as versao_postgres; 