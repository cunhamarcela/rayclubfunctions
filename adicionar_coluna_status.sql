-- Script para adicionar uma coluna 'status' à tabela challenge_check_ins
-- Isso serve como solução temporária para resolver o erro "record 'new' has no field 'status'"

-- 1. Verificar se a coluna já existe para evitar erros
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'challenge_check_ins' 
    AND column_name = 'status'
    AND table_schema = 'public'
  ) THEN
    -- Se a coluna não existe, adicioná-la
    EXECUTE 'ALTER TABLE challenge_check_ins ADD COLUMN status TEXT DEFAULT ''completed''';
    RAISE NOTICE 'Coluna "status" adicionada à tabela challenge_check_ins com valor padrão "completed".';
  ELSE
    RAISE NOTICE 'A coluna "status" já existe na tabela challenge_check_ins.';
  END IF;
END $$;

-- 2. Atualizar os registros existentes para ter um valor consistente
UPDATE challenge_check_ins
SET status = 'completed'
WHERE status IS NULL OR status = '';

-- 3. Verificar se os triggers que usam esta coluna estão ativos
DO $$
DECLARE
  trigger_info RECORD;
BEGIN
  RAISE NOTICE 'Triggers na tabela challenge_check_ins que podem usar a coluna status:';
  
  FOR trigger_info IN (
    SELECT 
      t.tgname AS trigger_name,
      CASE WHEN t.tgenabled <> 'D' THEN 'ATIVO' ELSE 'DESATIVADO' END AS status
    FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    WHERE c.relname = 'challenge_check_ins'
    AND NOT t.tgisinternal
    ORDER BY t.tgname
  ) LOOP
    RAISE NOTICE 'Trigger: % | Status: %', trigger_info.trigger_name, trigger_info.status;
  END LOOP;
END $$;

-- Nota: Esta é uma solução paliativa. O ideal seria identificar e corrigir
-- todos os triggers e funções que estão tentando acessar essa coluna.
-- Depois de corrigir definitivamente o problema, você pode remover esta coluna
-- usando: ALTER TABLE challenge_check_ins DROP COLUMN status; 