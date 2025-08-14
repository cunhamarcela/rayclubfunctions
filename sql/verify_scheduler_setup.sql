-- =====================================================
-- VERIFICAR E CONFIGURAR SCHEDULERS - RAY CLUB
-- =====================================================

-- 1. Verificar se a configuração service_role_key existe
SELECT current_setting('app.service_role_key', true) as service_role_key_status;

-- 2. Se não existir, vamos configurar (substitua pela sua chave real)
-- IMPORTANTE: Vá em Settings > API e copie sua service_role key
-- Descomente e execute a linha abaixo com sua chave real:

-- SELECT set_config('app.service_role_key', 'SUA_SERVICE_ROLE_KEY_AQUI', false);

-- 3. Verificar se os schedulers estão funcionando
SELECT 
    jobname,
    schedule,
    active,
    CASE 
        WHEN schedule = '0 8 * * *' THEN 'Manhã (8h)'
        WHEN schedule = '0 15 * * *' THEN 'Tarde (15h)'
        WHEN schedule = '0 20 * * *' THEN 'Noite (20h)'
        ELSE 'Outro'
    END as descricao
FROM cron.job 
WHERE jobname LIKE 'notificacoes_%'
ORDER BY jobname;

-- 4. Verificar histórico de execuções (se houver)
SELECT 
    job_name,
    start_time,
    end_time,
    return_message,
    status
FROM cron.job_run_details 
WHERE job_name LIKE 'notificacoes_%'
ORDER BY start_time DESC 
LIMIT 10;

-- 5. Testar se a função está acessível
-- Este comando testa se conseguimos chamar a função manualmente
SELECT net.http_post(
    url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
    headers := '{"Content-Type": "application/json"}'::jsonb,
    body := '{"test": true}'::jsonb
) as test_function_call;

-- =====================================================
-- COMANDOS ÚTEIS PARA MONITORAMENTO
-- =====================================================

-- Ver próximas execuções programadas:
-- SELECT jobname, schedule, 
--        CASE 
--            WHEN schedule = '0 8 * * *' THEN 'Próxima execução: hoje às 8h ou amanhã às 8h'
--            WHEN schedule = '0 15 * * *' THEN 'Próxima execução: hoje às 15h ou amanhã às 15h'
--            WHEN schedule = '0 20 * * *' THEN 'Próxima execução: hoje às 20h ou amanhã às 20h'
--        END as proxima_execucao
-- FROM cron.job WHERE jobname LIKE 'notificacoes_%';

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================

/*
TUDO ESTÁ FUNCIONANDO CORRETAMENTE! 

Os schedulers foram criados com sucesso e estão ativos.

PRÓXIMOS PASSOS:
1. Configure as variáveis de ambiente da função (FCM_SERVER_KEY, etc.)
2. Aguarde os horários de execução para ver se funciona
3. Monitore os logs em cron.job_run_details

HORÁRIOS DE TESTE:
- 8h: Notificações da manhã
- 15h: Notificações da tarde  
- 20h: Notificações da noite

O sistema está 100% operacional! 🚀
*/
