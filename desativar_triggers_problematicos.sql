-- Script para desativar todos os triggers potencialmente problemáticos
-- Deve ser executado ANTES da função record_challenge_check_in_v2

-- 1. Listar todos os triggers que podem estar causando problemas
DO $$
DECLARE
  trig_name TEXT;
BEGIN
  RAISE NOTICE 'Identificando triggers existentes...';

  -- Exibir triggers na tabela challenge_check_ins
  RAISE NOTICE 'Triggers na tabela challenge_check_ins:';
  FOR trig_name IN (
    SELECT t.trigger_name 
    FROM information_schema.triggers t
    WHERE t.event_object_table = 'challenge_check_ins' 
    AND t.trigger_schema = 'public'
  ) LOOP
    RAISE NOTICE '- %', trig_name;
  END LOOP;
END $$;

-- 2. Desabilitar apenas triggers definidos pelo usuário, não os triggers do sistema
DO $$
DECLARE
  trig_name TEXT;
BEGIN
  -- Identificar e desabilitar cada trigger de usuário individualmente
  FOR trig_name IN (
    SELECT tgname
    FROM pg_trigger
    WHERE tgrelid = 'challenge_check_ins'::regclass
    AND NOT tgisinternal  -- Apenas triggers definidos pelo usuário
  ) LOOP
    EXECUTE format('ALTER TABLE challenge_check_ins DISABLE TRIGGER %I', trig_name);
    RAISE NOTICE 'Trigger % desativado', trig_name;
  END LOOP;
END $$;

-- 3. Lista de triggers específicos conhecidos por causar problemas
-- (Desative manualmente caso identificados entre os ativos)
-- Se necessário, descomente e execute cada linha individualmente:
-- ALTER TABLE challenge_check_ins DISABLE TRIGGER tr_update_user_progress_on_checkin;
-- ALTER TABLE challenge_check_ins DISABLE TRIGGER update_progress_after_checkin;
-- ALTER TABLE challenge_check_ins DISABLE TRIGGER trg_update_progress_on_check_in;
-- ALTER TABLE challenge_check_ins DISABLE TRIGGER trigger_update_challenge_ranking;
-- ALTER TABLE challenge_check_ins DISABLE TRIGGER update_profile_stats_on_checkin_trigger;
-- ALTER TABLE challenge_check_ins DISABLE TRIGGER update_streak_on_checkin;

-- 4. Verificar estado de todos os triggers após a desativação
DO $$
DECLARE
  trigger_record RECORD;
  trigger_count INTEGER := 0;
BEGIN
  RAISE NOTICE 'Os triggers definidos pelo usuário na tabela challenge_check_ins foram desativados.';
  RAISE NOTICE '';
  RAISE NOTICE 'Estado dos triggers após desativação:';
  
  FOR trigger_record IN (
    SELECT 
      t.tgname AS trigger_name, 
      c.relname AS table_name,
      t.tgisinternal AS is_system_trigger,
      t.tgenabled AS status
    FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    WHERE c.relname = 'challenge_check_ins'
    ORDER BY t.tgisinternal, t.tgname
  ) LOOP
    trigger_count := trigger_count + 1;
    RAISE NOTICE 'Trigger % na tabela % [%] está %', 
      trigger_record.trigger_name, 
      trigger_record.table_name,
      CASE WHEN trigger_record.is_system_trigger THEN 'Sistema' ELSE 'Usuário' END,
      CASE WHEN trigger_record.status = 'D' THEN 'DESATIVADO' ELSE 'ATIVADO' END;
  END LOOP;
  
  IF trigger_count = 0 THEN
    RAISE NOTICE 'Nenhum trigger encontrado na tabela challenge_check_ins.';
  END IF;
END $$; 