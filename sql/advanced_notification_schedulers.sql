-- =====================================================
-- SCHEDULERS AVANÇADOS DE NOTIFICAÇÕES - RAY CLUB
-- Sistema completo com múltiplos horários e triggers
-- =====================================================

-- Primeiro, vamos remover os schedulers antigos se existirem
SELECT cron.unschedule('notificacoes_manha');
SELECT cron.unschedule('notificacoes_tarde');
SELECT cron.unschedule('notificacoes_noite');

-- =====================================================
-- SCHEDULERS POR HORÁRIO DO DIA
-- =====================================================

-- MANHÃ - Múltiplos horários para maior alcance
SELECT cron.schedule(
    'notificacoes_manha_7h',
    '0 7 * * *',  -- 7h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "manha"}'::jsonb
    );
    $$
);

SELECT cron.schedule(
    'notificacoes_manha_9h',
    '0 9 * * *',  -- 9h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "manha"}'::jsonb
    );
    $$
);

-- TARDE - Horários estratégicos
SELECT cron.schedule(
    'notificacoes_almoco',
    '0 12 * * *',  -- 12h - Hora do almoço
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "tarde"}'::jsonb
    );
    $$
);

SELECT cron.schedule(
    'notificacoes_tarde_15h',
    '0 15 * * *',  -- 15h - Pausa da tarde
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "tarde"}'::jsonb
    );
    $$
);

-- NOITE - Horários de jantar e reflexão
SELECT cron.schedule(
    'notificacoes_jantar',
    '0 19 * * *',  -- 19h - Hora do jantar
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "noite"}'::jsonb
    );
    $$
);

SELECT cron.schedule(
    'notificacoes_reflexao',
    '0 21 * * *',  -- 21h - Reflexão do dia
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "noite"}'::jsonb
    );
    $$
);

-- =====================================================
-- SCHEDULERS SEMANAIS E ESPECIAIS
-- =====================================================

-- SEGUNDA-FEIRA - Início da semana
SELECT cron.schedule(
    'inicio_semana',
    '0 8 * * 1',  -- Segunda às 8h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "inicio_semana"}'::jsonb
    );
    $$
);

-- QUINTA-FEIRA - Verificação de metas semanais
SELECT cron.schedule(
    'verificacao_metas_semanais',
    '0 18 * * 4',  -- Quinta às 18h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "meta_semanal_risco"}'::jsonb
    );
    $$
);

-- DOMINGO - Preparação para nova semana
SELECT cron.schedule(
    'preparacao_nova_semana',
    '0 19 * * 0',  -- Domingo às 19h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "preparacao_semana"}'::jsonb
    );
    $$
);

-- =====================================================
-- SCHEDULERS COMPORTAMENTAIS
-- =====================================================

-- Verificação de usuários inativos - 3x por dia
SELECT cron.schedule(
    'verificacao_inatividade_manha',
    '30 10 * * *',  -- 10:30h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "sem_treino_1dia"}'::jsonb
    );
    $$
);

SELECT cron.schedule(
    'verificacao_inatividade_tarde',
    '30 16 * * *',  -- 16:30h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "sem_treino_2dias"}'::jsonb
    );
    $$
);

-- =====================================================
-- SCHEDULERS DE CONTEÚDO ESPECIALIZADO
-- =====================================================

-- Promoção de PDFs e eBooks - 2x por semana
SELECT cron.schedule(
    'promocao_ebooks_terca',
    '0 14 * * 2',  -- Terça às 14h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "ebook_hipertrofia"}'::jsonb
    );
    $$
);

SELECT cron.schedule(
    'promocao_ebooks_sexta',
    '0 16 * * 5',  -- Sexta às 16h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "ebook_emagrecimento"}'::jsonb
    );
    $$
);

-- Promoção de novos treinos - Diário às 17h
SELECT cron.schedule(
    'promocao_novos_treinos',
    '0 17 * * *',  -- Todo dia às 17h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "novo_funcional"}'::jsonb
    );
    $$
);

-- =====================================================
-- SCHEDULERS SAZONAIS
-- =====================================================

-- eBooks sazonais - 1x por mês
SELECT cron.schedule(
    'ebook_sazonal_mensal',
    '0 10 1 * *',  -- Todo dia 1 às 10h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{}'::jsonb  -- Deixa a função decidir baseado na estação
    );
    $$
);

-- =====================================================
-- SCHEDULERS DE BENEFÍCIOS
-- =====================================================

-- Promoção de cupons - 2x por semana
SELECT cron.schedule(
    'promocao_cupons_quarta',
    '0 11 * * 3',  -- Quarta às 11h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "novo_cupom"}'::jsonb
    );
    $$
);

SELECT cron.schedule(
    'promocao_cupons_sabado',
    '0 10 * * 6',  -- Sábado às 10h
    $$
    SELECT net.http_post(
        url := 'https://zsbbgchsjiuicwvtrldn.supabase.co/functions/v1/send_push_notifications',
        headers := '{"Authorization": "Bearer ' || current_setting('app.service_role_key') || '", "Content-Type": "application/json"}'::jsonb,
        body := '{"trigger_type": "novo_cupom"}'::jsonb
    );
    $$
);

-- =====================================================
-- VERIFICAR TODOS OS SCHEDULERS CRIADOS
-- =====================================================

SELECT 
    jobname,
    schedule,
    active,
    CASE 
        WHEN jobname LIKE '%manha%' THEN '🌅 Manhã'
        WHEN jobname LIKE '%tarde%' OR jobname LIKE '%almoco%' THEN '🌞 Tarde'
        WHEN jobname LIKE '%noite%' OR jobname LIKE '%jantar%' OR jobname LIKE '%reflexao%' THEN '🌙 Noite'
        WHEN jobname LIKE '%semana%' THEN '📅 Semanal'
        WHEN jobname LIKE '%inatividade%' THEN '🎯 Comportamental'
        WHEN jobname LIKE '%ebook%' OR jobname LIKE '%treino%' THEN '📚 Conteúdo'
        WHEN jobname LIKE '%cupom%' THEN '🎁 Benefícios'
        ELSE '📋 Outros'
    END as categoria,
    CASE 
        WHEN schedule LIKE '%7 %' THEN 'Diário às 7h'
        WHEN schedule LIKE '%8 %' THEN 'Diário às 8h'
        WHEN schedule LIKE '%9 %' THEN 'Diário às 9h'
        WHEN schedule LIKE '%10 %' THEN 'Diário às 10h'
        WHEN schedule LIKE '%11 %' THEN 'Diário às 11h'
        WHEN schedule LIKE '%12 %' THEN 'Diário às 12h'
        WHEN schedule LIKE '%14 %' THEN 'Diário às 14h'
        WHEN schedule LIKE '%15 %' THEN 'Diário às 15h'
        WHEN schedule LIKE '%16 %' THEN 'Diário às 16h'
        WHEN schedule LIKE '%17 %' THEN 'Diário às 17h'
        WHEN schedule LIKE '%18 %' THEN 'Diário às 18h'
        WHEN schedule LIKE '%19 %' THEN 'Diário às 19h'
        WHEN schedule LIKE '%21 %' THEN 'Diário às 21h'
        WHEN schedule LIKE '% 1' THEN 'Segundas-feiras'
        WHEN schedule LIKE '% 2' THEN 'Terças-feiras'
        WHEN schedule LIKE '% 3' THEN 'Quartas-feiras'
        WHEN schedule LIKE '% 4' THEN 'Quintas-feiras'
        WHEN schedule LIKE '% 5' THEN 'Sextas-feiras'
        WHEN schedule LIKE '% 6' THEN 'Sábados'
        WHEN schedule LIKE '% 0' THEN 'Domingos'
        WHEN schedule LIKE '%1 * *' THEN 'Todo dia 1 do mês'
        ELSE schedule
    END as descricao_horario
FROM cron.job 
WHERE jobname LIKE '%notificacoes%' 
   OR jobname LIKE '%verificacao%' 
   OR jobname LIKE '%promocao%'
   OR jobname LIKE '%inicio%'
   OR jobname LIKE '%ebook%'
ORDER BY 
    CASE categoria
        WHEN '🌅 Manhã' THEN 1
        WHEN '🌞 Tarde' THEN 2
        WHEN '🌙 Noite' THEN 3
        WHEN '📅 Semanal' THEN 4
        WHEN '🎯 Comportamental' THEN 5
        WHEN '📚 Conteúdo' THEN 6
        WHEN '🎁 Benefícios' THEN 7
        ELSE 8
    END,
    schedule;

-- =====================================================
-- RESUMO FINAL
-- =====================================================

SELECT 
    COUNT(*) as total_schedulers,
    COUNT(CASE WHEN active = true THEN 1 END) as schedulers_ativos,
    COUNT(CASE WHEN active = false THEN 1 END) as schedulers_inativos
FROM cron.job 
WHERE jobname LIKE '%notificacoes%' 
   OR jobname LIKE '%verificacao%' 
   OR jobname LIKE '%promocao%'
   OR jobname LIKE '%inicio%'
   OR jobname LIKE '%ebook%';

-- =====================================================
-- NOTAS IMPORTANTES
-- =====================================================

/*
SISTEMA COMPLETO DE SCHEDULERS CRIADO! 

📊 RESUMO:
- 🌅 Manhã: 2 horários (7h e 9h)
- 🌞 Tarde: 2 horários (12h e 15h)  
- 🌙 Noite: 2 horários (19h e 21h)
- 📅 Semanais: 3 schedulers específicos
- 🎯 Comportamentais: 2 verificações diárias
- 📚 Conteúdo: 3 promoções por semana
- 🎁 Benefícios: 2 promoções por semana
- 🌿 Sazonais: 1 mensal

TOTAL: ~17 schedulers ativos cobrindo todos os cenários!

🚀 O sistema agora enviará notificações:
- Múltiplas vezes por dia
- Em horários estratégicos
- Baseado em comportamento
- Com conteúdo personalizado
- Sazonalmente relevante

MONITORAMENTO:
- Execute: SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 20;
- Para ver execuções recentes e possíveis erros
*/
