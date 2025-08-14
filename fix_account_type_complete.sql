-- ========================================
-- FIX COMPLETO: ACCOUNT_TYPE NULL PROBLEM
-- ========================================
-- Data: 07/08/2025 12:26
-- Problema: Usuários com account_type NULL estão tendo acesso liberado
-- Solução: Corrigir triggers, código e dados existentes

-- =============================================
-- 1. CORRIGIR DADOS EXISTENTES
-- =============================================

-- 1.1 Adicionar DEFAULT 'basic' se o campo não tiver
ALTER TABLE profiles ALTER COLUMN account_type SET DEFAULT 'basic';

-- 1.2 Corrigir todos os registros NULL existentes
UPDATE profiles 
SET account_type = 'basic' 
WHERE account_type IS NULL;

-- 1.3 Verificar quantos foram corrigidos
SELECT 
  'CORREÇÃO DE DADOS' as operacao,
  COUNT(*) as total_profiles,
  COUNT(CASE WHEN account_type = 'basic' THEN 1 END) as basic_users,
  COUNT(CASE WHEN account_type = 'expert' THEN 1 END) as expert_users,
  COUNT(CASE WHEN account_type IS NULL THEN 1 END) as null_users
FROM profiles;

-- =============================================
-- 2. CORRIGIR TRIGGER handle_new_user()
-- =============================================

-- 2.1 Dropar trigger existente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- 2.2 Recriar função COMPLETA com account_type
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    user_name text;
    user_email text;
BEGIN
    -- Log de início
    RAISE NOTICE 'handle_new_user: Iniciando para usuário %', NEW.id;
    
    -- Extrair email (garantir que não seja null)
    user_email := COALESCE(NEW.email, 'user-' || NEW.id || '@rayclub.com');
    
    -- Extrair nome do usuário dos metadados
    user_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        NEW.raw_user_meta_data->>'given_name',
        split_part(user_email, '@', 1),
        'Usuário'
    );
    
    RAISE NOTICE 'handle_new_user: Email=%, Nome=%', user_email, user_name;
    
    -- 1. Inserir perfil básico COM account_type = 'basic'
    BEGIN
        INSERT INTO public.profiles (
            id,
            email,
            name,
            account_type,  -- ✅ CAMPO ADICIONADO
            created_at,
            updated_at
        ) VALUES (
            NEW.id,
            user_email,
            user_name,
            'basic',       -- ✅ VALOR EXPLÍCITO
            NOW(),
            NOW()
        ) ON CONFLICT (id) DO UPDATE SET
            email = COALESCE(EXCLUDED.email, profiles.email),
            name = COALESCE(EXCLUDED.name, profiles.name),
            account_type = COALESCE(EXCLUDED.account_type, profiles.account_type, 'basic'), -- ✅ GARANTIR BASIC
            updated_at = NOW();
        
        RAISE NOTICE 'handle_new_user: Perfil criado/atualizado com account_type=basic';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'handle_new_user: Erro ao criar perfil: %', SQLERRM;
    END;
    
    -- 2. Inserir progresso inicial
    BEGIN
        INSERT INTO public.user_progress (
            user_id,
            points,
            level,
            workouts,
            created_at,
            updated_at
        ) VALUES (
            NEW.id,
            0,
            1,
            0,
            NOW(),
            NOW()
        ) ON CONFLICT (user_id) DO UPDATE SET
            updated_at = NOW();
        
        RAISE NOTICE 'handle_new_user: Progresso criado/atualizado com sucesso';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'handle_new_user: Erro ao criar progresso: %', SQLERRM;
    END;
    
    -- 3. Inserir nível de acesso inicial
    BEGIN
        INSERT INTO public.user_progress_level (
            user_id,
            current_level,
            unlocked_features,
            created_at,
            updated_at,
            last_activity
        ) VALUES (
            NEW.id,
            'basic',
            ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'],
            NOW(),
            NOW(),
            NOW()
        ) ON CONFLICT (user_id) DO UPDATE SET
            updated_at = NOW();
        
        RAISE NOTICE 'handle_new_user: Nível de acesso criado com sucesso';
    EXCEPTION
        WHEN OTHERS THEN
            RAISE WARNING 'handle_new_user: Erro ao criar nível: %', SQLERRM;
    END;
    
    RETURN NEW;
EXCEPTION
    WHEN OTHERS THEN
        -- Log do erro mas não falha o trigger
        RAISE WARNING 'Erro geral ao criar usuário %: %', NEW.id, SQLERRM;
        RETURN NEW;
END;
$$;

-- 2.3 Recriar trigger
CREATE TRIGGER on_auth_user_created 
AFTER INSERT ON auth.users 
FOR EACH ROW 
EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- 3. VERIFICAÇÃO FINAL
-- =============================================

-- 3.1 Testar a função (simulação)
SELECT 
  'TRIGGER ATUALIZADO' as status,
  'Trigger handle_new_user() agora inclui account_type = basic' as descricao;

-- 3.2 Verificar estado atual dos dados
SELECT 
  'ESTADO FINAL' as check_name,
  COUNT(*) as total_profiles,
  COUNT(CASE WHEN account_type = 'basic' THEN 1 END) as basic_count,
  COUNT(CASE WHEN account_type = 'expert' THEN 1 END) as expert_count,
  COUNT(CASE WHEN account_type IS NULL THEN 1 END) as null_count,
  CASE 
    WHEN COUNT(CASE WHEN account_type IS NULL THEN 1 END) = 0 
    THEN '✅ OK - SEM NULLS' 
    ELSE '❌ AINDA HÁ NULLS' 
  END as status
FROM profiles;

-- 3.3 Mostrar últimos 5 usuários criados
SELECT 
  id,
  name,
  email,
  account_type,
  created_at
FROM profiles 
ORDER BY created_at DESC 
LIMIT 5;

-- =============================================
-- 4. RESULTADO ESPERADO
-- =============================================

/*
✅ RESULTADO ESPERADO APÓS EXECUÇÃO:

1. ✅ TODOS os registros existentes com account_type NULL → 'basic'
2. ✅ TRIGGER atualizado para sempre criar account_type = 'basic'
3. ✅ DEFAULT definido na coluna para segurança extra
4. ✅ Zero registros NULL na tabela profiles

PRÓXIMO PASSO:
- Atualizar AuthRepository._ensureUserProfile() para incluir account_type
- Testar criação de novo usuário
- Verificar logs para confirmar que account_type não é mais null
*/
