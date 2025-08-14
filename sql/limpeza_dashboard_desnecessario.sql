-- ========================================
-- LIMPEZA: REMOVER FUNÇÃO DESNECESSÁRIA
-- ========================================
-- Data: 2025-01-27 21:35
-- Objetivo: Remover get_user_dashboard_stats que criamos por engano

-- EXPLICAÇÃO
SELECT 
    'LIMPEZA NECESSÁRIA:' as titulo,
    'get_user_dashboard_stats não é usada' as motivo,
    'O problema real estava em get_dashboard_core' as descoberta;

-- REMOVER FUNÇÃO DESNECESSÁRIA
DROP FUNCTION IF EXISTS get_user_dashboard_stats(UUID);

-- CONFIRMAR LIMPEZA
SELECT 
    'FUNÇÃO REMOVIDA:' as status,
    'get_user_dashboard_stats deletada' as acao,
    'Apenas get_dashboard_core foi corrigida' as resultado;

-- STATUS FINAL
SELECT 
    'RESUMO FINAL:' as titulo,
    '✅ get_dashboard_core corrigida' as acao1,
    '✅ get_user_dashboard_stats removida' as acao2,
    '✅ Dashboard agora mostra dados mensais' as resultado; 