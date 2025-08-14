-- =====================================================
-- DASHBOARD DE MONITORAMENTO DE NOTIFICAÇÕES - RAY CLUB
-- Queries para acompanhar performance e engajamento
-- =====================================================

-- =====================================================
-- VIEW: RESUMO GERAL DE NOTIFICAÇÕES
-- =====================================================

CREATE OR REPLACE VIEW notification_dashboard_summary AS
SELECT 
    -- Estatísticas gerais
    COUNT(*) as total_notifications,
    COUNT(CASE WHEN DATE(created_at) = CURRENT_DATE THEN 1 END) as notifications_today,
    COUNT(CASE WHEN created_at >= date_trunc('week', NOW()) THEN 1 END) as notifications_this_week,
    COUNT(CASE WHEN created_at >= date_trunc('month', NOW()) THEN 1 END) as notifications_this_month,
    
    -- Por status
    COUNT(CASE WHEN read_at IS NOT NULL THEN 1 END) as notifications_read,
    COUNT(CASE WHEN read_at IS NULL THEN 1 END) as notifications_unread,
    ROUND(
        (COUNT(CASE WHEN read_at IS NOT NULL THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
    ) as read_rate_percentage,
    
    -- Usuários únicos
    COUNT(DISTINCT user_id) as unique_users_notified,
    
    -- Médias
    ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT user_id), 2) as avg_notifications_per_user,
    ROUND(
        COUNT(CASE WHEN DATE(created_at) = CURRENT_DATE THEN 1 END)::NUMERIC / 
        NULLIF(COUNT(DISTINCT CASE WHEN DATE(created_at) = CURRENT_DATE THEN user_id END), 0), 2
    ) as avg_notifications_per_user_today
    
FROM notifications
WHERE created_at >= NOW() - INTERVAL '30 days';  -- Últimos 30 dias

-- =====================================================
-- VIEW: PERFORMANCE POR TIPO DE NOTIFICAÇÃO
-- =====================================================

CREATE OR REPLACE VIEW notification_performance_by_type AS
SELECT 
    type,
    data->>'trigger_type' as trigger_type,
    COUNT(*) as total_sent,
    COUNT(CASE WHEN read_at IS NOT NULL THEN 1 END) as total_read,
    COUNT(CASE WHEN read_at IS NULL THEN 1 END) as total_unread,
    ROUND(
        (COUNT(CASE WHEN read_at IS NOT NULL THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
    ) as read_rate_percentage,
    COUNT(DISTINCT user_id) as unique_users,
    ROUND(COUNT(*)::NUMERIC / COUNT(DISTINCT user_id), 2) as avg_per_user,
    MIN(created_at) as first_sent,
    MAX(created_at) as last_sent,
    
    -- Tempo médio para leitura (em horas)
    ROUND(
        AVG(EXTRACT(EPOCH FROM (read_at - created_at)) / 3600)::NUMERIC, 2
    ) as avg_hours_to_read
    
FROM notifications
WHERE created_at >= NOW() - INTERVAL '7 days'  -- Última semana
GROUP BY type, data->>'trigger_type'
ORDER BY total_sent DESC;

-- =====================================================
-- VIEW: PERFORMANCE POR HORÁRIO DE ENVIO
-- =====================================================

CREATE OR REPLACE VIEW notification_performance_by_hour AS
SELECT 
    EXTRACT(HOUR FROM created_at) as hour_of_day,
    COUNT(*) as total_sent,
    COUNT(CASE WHEN read_at IS NOT NULL THEN 1 END) as total_read,
    ROUND(
        (COUNT(CASE WHEN read_at IS NOT NULL THEN 1 END)::NUMERIC / COUNT(*)) * 100, 2
    ) as read_rate_percentage,
    COUNT(DISTINCT user_id) as unique_users,
    
    -- Tempo médio para leitura
    ROUND(
        AVG(EXTRACT(EPOCH FROM (read_at - created_at)) / 3600)::NUMERIC, 2
    ) as avg_hours_to_read,
    
    -- Classificação do horário
    CASE 
        WHEN EXTRACT(HOUR FROM created_at) BETWEEN 6 AND 10 THEN '🌅 Manhã'
        WHEN EXTRACT(HOUR FROM created_at) BETWEEN 11 AND 16 THEN '🌞 Tarde'
        WHEN EXTRACT(HOUR FROM created_at) BETWEEN 17 AND 21 THEN '🌙 Noite'
        ELSE '🌃 Madrugada'
    END as period_name
    
FROM notifications
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY EXTRACT(HOUR FROM created_at)
ORDER BY hour_of_day;

-- =====================================================
-- VIEW: TOP USUÁRIOS MAIS ENGAJADOS
-- =====================================================

CREATE OR REPLACE VIEW top_engaged_users AS
SELECT 
    p.id as user_id,
    p.name,
    p.email,
    COUNT(n.id) as total_notifications_received,
    COUNT(CASE WHEN n.read_at IS NOT NULL THEN 1 END) as total_read,
    COUNT(CASE WHEN n.read_at IS NULL THEN 1 END) as total_unread,
    ROUND(
        (COUNT(CASE WHEN n.read_at IS NOT NULL THEN 1 END)::NUMERIC / COUNT(n.id)) * 100, 2
    ) as read_rate_percentage,
    
    -- Tempo médio de resposta
    ROUND(
        AVG(EXTRACT(EPOCH FROM (n.read_at - n.created_at)) / 60)::NUMERIC, 2
    ) as avg_minutes_to_read,
    
    -- Última atividade
    MAX(n.read_at) as last_notification_read,
    MAX(n.created_at) as last_notification_received,
    
    -- Classificação do usuário
    CASE 
        WHEN COUNT(CASE WHEN n.read_at IS NOT NULL THEN 1 END)::NUMERIC / COUNT(n.id) >= 0.8 THEN '🔥 Super Engajado'
        WHEN COUNT(CASE WHEN n.read_at IS NOT NULL THEN 1 END)::NUMERIC / COUNT(n.id) >= 0.5 THEN '👍 Engajado'
        WHEN COUNT(CASE WHEN n.read_at IS NOT NULL THEN 1 END)::NUMERIC / COUNT(n.id) >= 0.2 THEN '😐 Pouco Engajado'
        ELSE '😴 Inativo'
    END as engagement_level
    
FROM profiles p
JOIN notifications n ON n.user_id = p.id
WHERE n.created_at >= NOW() - INTERVAL '30 days'
GROUP BY p.id, p.name, p.email
HAVING COUNT(n.id) >= 5  -- Pelo menos 5 notificações
ORDER BY read_rate_percentage DESC, total_notifications_received DESC;

-- =====================================================
-- VIEW: ANÁLISE DE SCHEDULERS
-- =====================================================

CREATE OR REPLACE VIEW scheduler_performance AS
SELECT 
    job_name,
    schedule,
    active,
    
    -- Estatísticas de execução
    COUNT(jrd.run_id) as total_executions,
    COUNT(CASE WHEN jrd.status = 'succeeded' THEN 1 END) as successful_executions,
    COUNT(CASE WHEN jrd.status = 'failed' THEN 1 END) as failed_executions,
    
    ROUND(
        (COUNT(CASE WHEN jrd.status = 'succeeded' THEN 1 END)::NUMERIC / 
         NULLIF(COUNT(jrd.run_id), 0)) * 100, 2
    ) as success_rate_percentage,
    
    -- Tempos
    MAX(jrd.end_time) as last_execution,
    AVG(EXTRACT(EPOCH FROM (jrd.end_time - jrd.start_time))) as avg_execution_time_seconds,
    
    -- Próxima execução estimada
    CASE 
        WHEN schedule = '0 7 * * *' THEN 'Diário às 7h'
        WHEN schedule = '0 8 * * *' THEN 'Diário às 8h'
        WHEN schedule = '0 9 * * *' THEN 'Diário às 9h'
        WHEN schedule = '0 12 * * *' THEN 'Diário às 12h'
        WHEN schedule = '0 15 * * *' THEN 'Diário às 15h'
        WHEN schedule = '0 19 * * *' THEN 'Diário às 19h'
        WHEN schedule = '0 21 * * *' THEN 'Diário às 21h'
        ELSE schedule
    END as schedule_description
    
FROM cron.job cj
LEFT JOIN cron.job_run_details jrd ON jrd.job_name = cj.job_name
WHERE cj.job_name LIKE '%notificacoes%' 
   OR cj.job_name LIKE '%verificacao%'
   OR cj.job_name LIKE '%promocao%'
GROUP BY cj.job_name, cj.schedule, cj.active
ORDER BY total_executions DESC;

-- =====================================================
-- QUERIES DE MONITORAMENTO DIÁRIO
-- =====================================================

-- 1. Resumo do dia atual
SELECT 
    '📊 RESUMO DO DIA' as secao,
    * 
FROM notification_dashboard_summary;

-- 2. Performance por tipo hoje
SELECT 
    '📈 PERFORMANCE POR TIPO (HOJE)' as secao,
    type,
    trigger_type,
    total_sent,
    total_read,
    read_rate_percentage || '%' as taxa_leitura
FROM notification_performance_by_type
WHERE first_sent >= CURRENT_DATE
ORDER BY total_sent DESC;

-- 3. Melhores horários para engajamento
SELECT 
    '⏰ MELHORES HORÁRIOS' as secao,
    hour_of_day || 'h' as horario,
    period_name,
    total_sent,
    read_rate_percentage || '%' as taxa_leitura,
    avg_hours_to_read || 'h' as tempo_medio_leitura
FROM notification_performance_by_hour
WHERE total_sent > 0
ORDER BY read_rate_percentage DESC
LIMIT 5;

-- 4. Top 10 usuários mais engajados
SELECT 
    '🏆 TOP USUÁRIOS ENGAJADOS' as secao,
    name,
    engagement_level,
    total_notifications_received,
    read_rate_percentage || '%' as taxa_leitura,
    avg_minutes_to_read || 'min' as tempo_medio_resposta
FROM top_engaged_users
ORDER BY read_rate_percentage DESC
LIMIT 10;

-- 5. Status dos schedulers
SELECT 
    '⚙️ STATUS DOS SCHEDULERS' as secao,
    job_name,
    CASE WHEN active THEN '✅ Ativo' ELSE '❌ Inativo' END as status,
    schedule_description,
    success_rate_percentage || '%' as taxa_sucesso,
    last_execution
FROM scheduler_performance
ORDER BY success_rate_percentage DESC;

-- =====================================================
-- ALERTAS E PROBLEMAS
-- =====================================================

-- Detectar problemas potenciais
SELECT 
    '🚨 ALERTAS' as secao,
    'Scheduler com falhas' as tipo_alerta,
    job_name,
    failed_executions || ' falhas' as detalhes
FROM scheduler_performance
WHERE failed_executions > 0 AND total_executions > 0

UNION ALL

SELECT 
    '🚨 ALERTAS' as secao,
    'Baixo engajamento' as tipo_alerta,
    trigger_type,
    read_rate_percentage || '% de leitura' as detalhes
FROM notification_performance_by_type
WHERE read_rate_percentage < 20 AND total_sent > 10

UNION ALL

SELECT 
    '🚨 ALERTAS' as secao,
    'Usuários inativos' as tipo_alerta,
    COUNT(*)::TEXT || ' usuários' as job_name,
    'Não leem notificações há 7+ dias' as detalhes
FROM profiles p
WHERE p.fcm_token IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM notifications n 
    WHERE n.user_id = p.id 
    AND n.read_at >= NOW() - INTERVAL '7 days'
)
HAVING COUNT(*) > 0;

-- =====================================================
-- FUNÇÃO PARA RELATÓRIO COMPLETO
-- =====================================================

CREATE OR REPLACE FUNCTION generate_notification_report()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    report TEXT := '';
    summary_data RECORD;
    performance_data RECORD;
BEGIN
    -- Cabeçalho
    report := report || E'📱 RELATÓRIO DE NOTIFICAÇÕES - RAY CLUB\n';
    report := report || E'Data: ' || TO_CHAR(NOW(), 'DD/MM/YYYY HH24:MI') || E'\n';
    report := report || E'═══════════════════════════════════════════\n\n';
    
    -- Resumo geral
    SELECT * INTO summary_data FROM notification_dashboard_summary;
    
    report := report || E'📊 RESUMO GERAL:\n';
    report := report || E'• Total de notificações: ' || summary_data.total_notifications || E'\n';
    report := report || E'• Hoje: ' || summary_data.notifications_today || E'\n';
    report := report || E'• Esta semana: ' || summary_data.notifications_this_week || E'\n';
    report := report || E'• Taxa de leitura: ' || summary_data.read_rate_percentage || E'%\n';
    report := report || E'• Usuários únicos: ' || summary_data.unique_users_notified || E'\n\n';
    
    -- Top 3 tipos de notificação
    report := report || E'🏆 TOP 3 TIPOS DE NOTIFICAÇÃO:\n';
    FOR performance_data IN 
        SELECT trigger_type, total_sent, read_rate_percentage 
        FROM notification_performance_by_type 
        ORDER BY total_sent DESC 
        LIMIT 3
    LOOP
        report := report || E'• ' || performance_data.trigger_type || 
                  E': ' || performance_data.total_sent || 
                  E' enviadas (' || performance_data.read_rate_percentage || E'% lidas)\n';
    END LOOP;
    
    report := report || E'\n✅ Relatório gerado com sucesso!';
    
    RETURN report;
END;
$$;

-- =====================================================
-- SCHEDULER PARA RELATÓRIO DIÁRIO
-- =====================================================

SELECT cron.schedule(
    'relatorio_diario_notificacoes',
    '0 23 * * *',  -- Todo dia às 23h
    $$
    -- Aqui você poderia enviar o relatório por email ou salvar em uma tabela
    SELECT generate_notification_report();
    $$
);

-- =====================================================
-- TESTES E EXEMPLOS
-- =====================================================

-- Gerar relatório completo
SELECT generate_notification_report();

-- Ver resumo atual
SELECT * FROM notification_dashboard_summary;

-- Ver performance por tipo
SELECT * FROM notification_performance_by_type LIMIT 10;

-- Ver melhores horários
SELECT * FROM notification_performance_by_hour ORDER BY read_rate_percentage DESC LIMIT 5;

-- Ver top usuários
SELECT * FROM top_engaged_users LIMIT 10;

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================

/*
DASHBOARD DE MONITORAMENTO COMPLETO CRIADO! 

📊 VIEWS CRIADAS:
- notification_dashboard_summary: Resumo geral
- notification_performance_by_type: Performance por tipo
- notification_performance_by_hour: Performance por horário  
- top_engaged_users: Usuários mais engajados
- scheduler_performance: Status dos schedulers

🔍 FUNCIONALIDADES:
- ✅ Métricas de engajamento em tempo real
- ✅ Análise de performance por tipo/horário
- ✅ Identificação de usuários engajados
- ✅ Monitoramento de schedulers
- ✅ Alertas automáticos de problemas
- ✅ Relatório diário automatizado

📈 MÉTRICAS PRINCIPAIS:
- Taxa de leitura por tipo de notificação
- Tempo médio de resposta dos usuários
- Performance dos schedulers
- Horários de maior engajamento
- Usuários mais/menos ativos

🚨 ALERTAS:
- Schedulers com falhas
- Tipos de notificação com baixo engajamento
- Usuários inativos

🎯 RESULTADO:
Sistema completo de monitoramento para otimizar
continuamente a estratégia de notificações!
*/
