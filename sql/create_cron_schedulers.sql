-- =====================================================
-- CRIAR SCHEDULERS DE NOTIFICAÇÕES VIA SQL
-- Ray Club - Como o menu Scheduler não apareceu, vamos usar SQL
-- =====================================================

-- Habilitar extensão pg_cron se não estiver habilitada
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- =====================================================
-- SCHEDULER 1: NOTIFICAÇÕES DA MANHÃ (8h)
-- =====================================================

SELECT cron.schedule(
    'notificacoes_manha',           -- Nome do job
    '0 8 * * *',                    -- Todo dia às 8h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "manha"}'::jsonb
    );
    $$
);

-- =====================================================
-- SCHEDULER 2: NOTIFICAÇÕES DA TARDE (15h)
-- =====================================================

SELECT cron.schedule(
    'notificacoes_tarde',           -- Nome do job
    '0 15 * * *',                   -- Todo dia às 15h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "tarde"}'::jsonb
    );
    $$
);

-- =====================================================
-- SCHEDULER 3: NOTIFICAÇÕES DA NOITE (20h)
-- =====================================================

SELECT cron.schedule(
    'notificacoes_noite',           -- Nome do job
    '0 20 * * *',                   -- Todo dia às 20h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "noite"}'::jsonb
    );
    $$
);

-- =====================================================
-- VERIFICAR SE OS JOBS FORAM CRIADOS
-- =====================================================

-- Listar todos os cron jobs
SELECT 
    jobid,
    schedule,
    command,
    nodename,
    nodeport,
    database,
    username,
    active,
    jobname
FROM cron.job 
ORDER BY jobid;

-- =====================================================
-- COMANDOS ÚTEIS PARA GERENCIAR OS SCHEDULERS
-- =====================================================

-- Para remover um scheduler (se necessário):
-- SELECT cron.unschedule('notificacoes_manha');
-- SELECT cron.unschedule('notificacoes_tarde');
-- SELECT cron.unschedule('notificacoes_noite');

-- Para ver o histórico de execuções:
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;

-- Para verificar se pg_cron está habilitado:
-- SELECT * FROM pg_extension WHERE extname = 'pg_cron';

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================

/*
1. Execute este SQL no SQL Editor do Supabase Dashboard
2. Os schedulers serão criados automaticamente
3. Eles chamarão a função send_push_notifications nos horários definidos
4. Para verificar se funcionou, execute: SELECT * FROM cron.job;
5. Os logs de execução ficam em: SELECT * FROM cron.job_run_details;
*/
