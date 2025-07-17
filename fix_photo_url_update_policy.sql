-- Script para corrigir o problema de atualização da photo_url na tabela profiles

-- 1. Primeiro, vamos verificar as políticas RLS existentes
SELECT 
    policyname,
    cmd,
    qual::text as qual_text,
    with_check::text as with_check_text
FROM pg_policies 
WHERE tablename = 'profiles' 
AND schemaname = 'public';

-- 2. Desabilitar temporariamente RLS para diagnóstico (NÃO fazer em produção sem cuidado)
-- ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;

-- 3. Verificar se existe alguma política específica que restringe photo_url
DROP POLICY IF EXISTS "profiles_update_policy" ON public.profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
DROP POLICY IF EXISTS "Enable update for users based on id" ON public.profiles;

-- 4. Criar nova política de UPDATE que permite atualizar todos os campos incluindo photo_url
CREATE POLICY "Users can update own profile" ON public.profiles
FOR UPDATE 
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- 5. Garantir que não há constraints específicos na coluna photo_url
ALTER TABLE public.profiles 
ALTER COLUMN photo_url DROP NOT NULL;

ALTER TABLE public.profiles 
ALTER COLUMN photo_url TYPE text;

-- 6. Remover qualquer check constraint que possa estar impedindo a atualização
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (
        SELECT conname 
        FROM pg_constraint 
        WHERE conrelid = 'public.profiles'::regclass 
        AND contype = 'c'
        AND pg_get_constraintdef(oid) LIKE '%photo_url%'
    ) LOOP
        EXECUTE 'ALTER TABLE public.profiles DROP CONSTRAINT ' || quote_ident(r.conname);
    END LOOP;
END $$;

-- 7. Garantir que a política de SELECT também está correta
DROP POLICY IF EXISTS "Profiles are viewable by users who created them" ON public.profiles;
DROP POLICY IF EXISTS "Public profiles are viewable by everyone" ON public.profiles;

CREATE POLICY "Users can view own profile" ON public.profiles
FOR SELECT
TO authenticated
USING (auth.uid() = id);

-- 8. Criar política para permitir que usuários vejam perfis públicos (opcional)
CREATE POLICY "Public profiles are viewable by everyone" ON public.profiles
FOR SELECT
TO authenticated
USING (true);

-- 9. Verificar se RLS está habilitado
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 10. Garantir que a coluna profile_image_url também pode ser atualizada (se existir)
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name = 'profiles' 
        AND column_name = 'profile_image_url'
    ) THEN
        ALTER TABLE public.profiles 
        ALTER COLUMN profile_image_url DROP NOT NULL;
        
        ALTER TABLE public.profiles 
        ALTER COLUMN profile_image_url TYPE text;
    END IF;
END $$;

-- 11. Criar função para testar a atualização da foto
CREATE OR REPLACE FUNCTION test_update_photo_url(user_id uuid, new_photo_url text)
RETURNS void AS $$
BEGIN
    UPDATE public.profiles
    SET 
        photo_url = new_photo_url,
        updated_at = now()
    WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 12. Dar permissão para a função
GRANT EXECUTE ON FUNCTION test_update_photo_url(uuid, text) TO authenticated;

-- Verificar o resultado das políticas após as mudanças
SELECT 
    policyname,
    cmd,
    roles
FROM pg_policies 
WHERE tablename = 'profiles' 
AND schemaname = 'public'
ORDER BY cmd, policyname; 