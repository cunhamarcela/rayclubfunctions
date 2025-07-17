-- Script para verificar e reportar todos os triggers ativos na tabela challenge_check_ins
-- Execute este script no SQL Editor do Supabase para evitar confusões futuras

DO $$
DECLARE
    trigger_record RECORD;
    trigger_count INT := 0;
BEGIN
    RAISE NOTICE '======== INÍCIO DA VERIFICAÇÃO DE TRIGGERS EM CHALLENGE_CHECK_INS ========';
    
    -- Listar todos os triggers da tabela challenge_check_ins
    FOR trigger_record IN 
        SELECT tgname AS nome_trigger, pg_get_triggerdef(t.oid) AS definicao
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        WHERE c.relname = 'challenge_check_ins'
          AND NOT t.tgisinternal  -- Ignora triggers internos de FK
    LOOP
        trigger_count := trigger_count + 1;
        RAISE NOTICE 'Trigger encontrado: % - %', trigger_record.nome_trigger, trigger_record.definicao;
    END LOOP;
    
    -- Verificar se existem triggers personalizados que deveriam ser removidos
    FOR trigger_record IN 
        SELECT tgname AS nome_trigger
        FROM pg_trigger t
        JOIN pg_class c ON t.tgrelid = c.oid
        WHERE c.relname = 'challenge_check_ins'
          AND NOT t.tgisinternal
          AND tgname IN (
              'tr_update_user_progress_on_checkin',
              'update_progress_after_checkin',
              'trg_update_progress_on_check_in',
              'update_challenge_progress_on_check_in',
              'update_challenge_progress_on_checkin'
          )
    LOOP
        RAISE WARNING 'ATENÇÃO: Trigger "%" encontrado mas não deveria existir! Considere removê-lo.', 
            trigger_record.nome_trigger;
            
        -- Sugestão de comando para remover
        RAISE NOTICE 'Comando para remoção: ALTER TABLE challenge_check_ins DISABLE TRIGGER %;', 
            trigger_record.nome_trigger;
    END LOOP;
    
    -- Resumo
    IF trigger_count = 0 THEN
        RAISE NOTICE 'Não foram encontrados triggers personalizados na tabela challenge_check_ins.';
        RAISE NOTICE 'Arquitetura atual está correta: atualização de progresso é feita apenas pela função RPC record_challenge_check_in.';
    ELSE
        RAISE NOTICE 'Total de triggers encontrados: %', trigger_count;
        
        IF trigger_count > 4 THEN  -- Assumindo que existem até 4 triggers de FK/constraints normais
            RAISE WARNING 'Número de triggers maior que o esperado. Verifique se há triggers redundantes!';
        END IF;
    END IF;
    
    RAISE NOTICE '======== FIM DA VERIFICAÇÃO ========';
END $$; 