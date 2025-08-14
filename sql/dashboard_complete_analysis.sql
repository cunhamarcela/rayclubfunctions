-- ========================================
-- ANÁLISE COMPLETA DOS DASHBOARDS
-- ========================================
-- Data: 2025-01-27 21:25
-- Descoberta: Temos 3 DASHBOARDS diferentes!

-- 1. MAPEAMENTO DASHBOARDS → FUNÇÕES
SELECT 
    'MAPEAMENTO COMPLETO:' as titulo;

SELECT 
    'DASHBOARD EXISTENTE' as tipo,
    'DashboardScreen' as tela_flutter,
    'dashboard_screen.dart' as arquivo,
    'get_dashboard_core' as funcao_sql,
    '✅ FUNÇÃO EXISTE' as status_banco,
    '✅ EM USO' as status_flutter,
    'Dashboard normal/principal' as observacao
UNION ALL
SELECT 
    'DASHBOARD EXISTENTE',
    'FitnessDashboardScreen',
    'fitness_dashboard_screen.dart',
    'get_dashboard_fitness',
    '✅ FUNÇÃO EXISTE',
    '✅ EM USO',
    'Dashboard específico de fitness'
UNION ALL
SELECT 
    'DASHBOARD EXISTENTE',
    'DashboardEnhancedScreen',
    'dashboard_enhanced_screen.dart',
    'get_dashboard_data',
    '✅ FUNÇÃO EXISTE',
    '✅ EM USO',
    'Dashboard aprimorado/completo'
UNION ALL
SELECT 
    '🚨 PROBLEMA',
    'DashboardService (não usado)',
    'dashboard_service.dart',
    'get_user_dashboard_stats',
    '❌ FUNÇÃO NÃO EXISTE',
    '❌ NÃO É USADO',
    'Código legado ou futuro?';

-- 2. VERIFICAR QUAL DASHBOARD PRECISA DE DADOS MENSAIS
SELECT 
    'ANÁLISE DE REQUISITO:' as secao,
    'Qual dashboard você quer ajustar?' as pergunta,
    'Mensal vs Total' as diferenca;

-- Opção 1: Dashboard Normal (get_dashboard_core)
SELECT 
    'OPÇÃO 1 - DASHBOARD NORMAL:' as opcao,
    'get_dashboard_core já retorna DADOS MENSAIS' as situacao_atual,
    'JÁ ATENDE O REQUISITO' as conclusao;

-- Opção 2: Dashboard Fitness (get_dashboard_fitness)
SELECT 
    'OPÇÃO 2 - DASHBOARD FITNESS:' as opcao,
    'Verificar se get_dashboard_fitness retorna mensal ou total' as situacao_atual,
    'PODE PRECISAR AJUSTE' as conclusao;

-- Opção 3: Dashboard Enhanced (get_dashboard_data)
SELECT 
    'OPÇÃO 3 - DASHBOARD ENHANCED:' as opcao,
    'Verificar se get_dashboard_data retorna mensal ou total' as situacao_atual,
    'PODE PRECISAR AJUSTE' as conclusao;

-- 3. RECOMENDAÇÃO
SELECT 
    'RECOMENDAÇÃO:' as titulo,
    'Especificar QUAL dashboard ajustar' as acao_necessaria,
    'get_user_dashboard_stats parece ser código não usado' as observacao_importante; 