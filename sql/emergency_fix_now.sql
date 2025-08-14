-- ================================================================
-- FIX EMERGENCIAL IMEDIATO - REMOVER TRIGGER PROBLEMÁTICO
-- EXECUTE ESTE SCRIPT NO SUPABASE SQL EDITOR AGORA MESMO!
-- ================================================================

-- STEP 1: REMOVER O TRIGGER QUE ESTÁ CAUSANDO O ERRO
DROP TRIGGER IF EXISTS trigger_process_pending_on_signup ON profiles CASCADE;

-- STEP 2: VERIFICAR SE FOI REMOVIDO
SELECT 
  CASE 
    WHEN COUNT(*) = 0 THEN '✅ TRIGGER REMOVIDO COM SUCESSO! Cadastros devem funcionar agora.'
    ELSE '❌ Trigger ainda ativo. Execute o comando DROP novamente.'
  END as status
FROM information_schema.triggers 
WHERE trigger_name = 'trigger_process_pending_on_signup';

-- COMENTÁRIO:
-- Após executar este script, teste imediatamente o cadastro.
-- O erro 500 deve desaparecer!
