-- Script para corrigir o problema específico das políticas RLS conflitantes na tabela profiles

-- 1. Primeiro, vamos remover TODAS as políticas existentes da tabela profiles
DROP POLICY IF EXISTS "Admins can update profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow admin full access" ON public.profiles;
DROP POLICY IF EXISTS "Allow individuals read access to own profile" ON public.profiles;
DROP POLICY IF EXISTS "Allow individuals update access to own profile" ON public.profiles;
DROP POLICY IF EXISTS "Anyone can read profiles" ON public.profiles;

-- 2. Verificar se existe a função is_admin
CREATE OR REPLACE FUNCTION public.is_admin(user_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.profiles 
        WHERE id = user_id 
        AND is_admin = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Criar políticas limpas e não conflitantes

-- Política de SELECT - Qualquer usuário autenticado pode ver qualquer perfil
CREATE POLICY "profiles_select_policy" ON public.profiles
FOR SELECT
TO authenticated
USING (true);

-- Política de UPDATE - Usuário pode atualizar apenas seu próprio perfil (incluindo photo_url)
CREATE POLICY "profiles_update_own" ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Política de UPDATE para admins - Admin pode atualizar qualquer perfil
CREATE POLICY "profiles_update_admin" ON public.profiles
FOR UPDATE
TO authenticated
USING (is_admin(auth.uid()))
WITH CHECK (is_admin(auth.uid()));

-- Política de INSERT - Apenas para novos usuários criarem seu próprio perfil
CREATE POLICY "profiles_insert_own" ON public.profiles
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Política de DELETE - Apenas admins podem deletar perfis
CREATE POLICY "profiles_delete_admin" ON public.profiles
FOR DELETE
TO authenticated
USING (is_admin(auth.uid()));

-- 4. Garantir que RLS está habilitado
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 5. Criar função alternativa para atualizar photo_url (caso as políticas ainda deem problema)
CREATE OR REPLACE FUNCTION public.update_user_photo_url(
    p_user_id uuid, 
    p_photo_url text
)
RETURNS jsonb AS $$
DECLARE
    v_result jsonb;
BEGIN
    -- Verificar se o usuário está atualizando seu próprio perfil
    IF auth.uid() != p_user_id AND NOT is_admin(auth.uid()) THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Você não tem permissão para atualizar este perfil'
        );
    END IF;
    
    -- Atualizar ambas as colunas de foto para compatibilidade
    UPDATE public.profiles
    SET 
        photo_url = p_photo_url,
        profile_image_url = p_photo_url,
        updated_at = now()
    WHERE id = p_user_id;
    
    IF FOUND THEN
        v_result := jsonb_build_object(
            'success', true,
            'message', 'Foto de perfil atualizada com sucesso',
            'photo_url', p_photo_url
        );
    ELSE
        v_result := jsonb_build_object(
            'success', false,
            'message', 'Perfil não encontrado'
        );
    END IF;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Dar permissão para a função
GRANT EXECUTE ON FUNCTION public.update_user_photo_url(uuid, text) TO authenticated;

-- 7. Verificar as políticas após as mudanças
SELECT 
    policyname,
    cmd,
    permissive,
    roles,
    qual::text as qual_text,
    with_check::text as with_check_text
FROM pg_policies 
WHERE tablename = 'profiles' 
AND schemaname = 'public'
ORDER BY cmd, policyname;

-- 8. Testar se a função update_modified_column existe e está funcionando
SELECT 
    proname,
    prosrc
FROM pg_proc
WHERE proname = 'update_modified_column';

-- 9. Se a função não existir, criá-la
CREATE OR REPLACE FUNCTION public.update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 10. Verificar resultado final
SELECT 
    'Políticas RLS reconfiguradas com sucesso!' as status,
    count(*) as total_policies
FROM pg_policies 
WHERE tablename = 'profiles'; 