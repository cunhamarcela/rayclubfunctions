-- ================================================================
-- FIX EMERGENCIAL PARA ERRO DE CADASTRO
-- Data: 2025-01-07 12:08
-- Problema: Trigger do Stripe está impedindo cadastros normais
-- Solução: Desabilitar trigger temporariamente
-- ================================================================

-- PASSO 1: REMOVER TRIGGERS PROBLEMÁTICOS
DROP TRIGGER IF EXISTS trigger_process_pending_on_signup ON profiles CASCADE;
DROP TRIGGER IF EXISTS trigger_process_pending_on_signup ON auth.users CASCADE;

-- PASSO 2: VERIFICAR SE OS TRIGGERS FORAM REMOVIDOS
SELECT 
  trigger_name,
  event_object_table,
  trigger_schema
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_process_pending_on_signup';

-- PASSO 3: VERIFICAR FUNÇÕES RELACIONADAS (para debug futuro)
SELECT 
  routine_name,
  routine_type,
  routine_definition
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN (
    'update_user_level_by_email',
    'trigger_process_pending_users'
  );

-- COMENTÁRIO:
-- Após executar este script, o cadastro de usuários deve voltar a funcionar normalmente.
-- O sistema do Stripe pode ser reconfigurado posteriormente, mas sem impedir cadastros básicos.

-- STATUS: PRONTO PARA EXECUÇÃO
SELECT 'Triggers removidos com sucesso! Cadastros devem funcionar agora.' as status;
