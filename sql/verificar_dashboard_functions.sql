-- ========================================
-- DIAGNÓSTICO DASHBOARD FUNCTIONS
-- ========================================
-- Data: 2025-01-27
-- Objetivo: Verificar correspondência entre Flutter e Supabase

-- 1. VERIFICAR QUAIS FUNÇÕES EXISTEM
SELECT 
    'DIAGNÓSTICO FUNÇÕES DASHBOARD' as titulo;

-- 2. FUNÇÕES CHAMADAS PELO FLUTTER
SELECT 
    'FUNÇÕES CHAMADAS PELO FLUTTER:' as secao,
    'get_user_dashboard_stats' as funcao_flutter,
    'dashboard_service.dart' as arquivo,
    'NÃO EXISTE NO BANCO' as status
UNION ALL
SELECT 
    '',
    'get_dashboard_core',
    'dashboard_repository.dart',
    'EXISTE NO BANCO'
UNION ALL
SELECT 
    '',
    'get_dashboard_data',
    'dashboard_repository_enhanced.dart',
    'EXISTE NO BANCO';

-- 3. VERIFICAR SE AS FUNÇÕES EXISTEM NO BANCO
SELECT 
    'VERIFICAÇÃO NO BANCO:' as secao,
    p.proname as nome_funcao,
    CASE 
        WHEN p.proname = 'get_user_dashboard_stats' THEN '❌ CHAMADA PELO FLUTTER MAS NÃO EXISTE'
        WHEN p.proname = 'get_dashboard_core' THEN '✅ EXISTE E É USADA'
        WHEN p.proname = 'get_dashboard_data' THEN '✅ EXISTE E É USADA'
        ELSE '⚠️ EXISTE MAS NÃO É USADA'
    END as status_uso
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname LIKE '%dashboard%'
ORDER BY p.proname;

-- 4. VERIFICAR PARÂMETROS DAS FUNÇÕES EXISTENTES
SELECT 
    'PARÂMETROS DAS FUNÇÕES:' as secao,
    p.proname as funcao,
    pg_get_function_arguments(p.oid) as parametros,
    pg_get_function_result(p.oid) as retorno
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public'
AND p.proname IN ('get_dashboard_core', 'get_dashboard_data')
ORDER BY p.proname;

-- 5. DIAGNÓSTICO DO PROBLEMA
SELECT 
    'PROBLEMA IDENTIFICADO:' as diagnostico,
    'get_user_dashboard_stats NÃO EXISTE' as problema,
    'Criar função ou mudar Flutter para usar get_dashboard_core' as solucao;

-- 6. VERIFICAR ESTRUTURA ATUAL DO get_dashboard_core
SELECT 
    'ESTRUTURA get_dashboard_core:' as info,
    'Retorna dados MENSAIS (já ajustado)' as observacao;

-- 7. OPÇÕES DE SOLUÇÃO
SELECT 
    'OPÇÕES DE SOLUÇÃO:' as opcoes,
    '1. Criar get_user_dashboard_stats chamando get_dashboard_core' as opcao1
UNION ALL
SELECT 
    '',
    '2. Alterar Flutter para usar get_dashboard_core' as opcao2
UNION ALL
SELECT 
    '',
    '3. Criar alias get_user_dashboard_stats -> get_dashboard_core' as opcao3; 