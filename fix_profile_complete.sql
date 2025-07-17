-- Script completo para corrigir problemas de perfil
-- Execute este script no Supabase SQL Editor

-- =====================================================
-- 1. VERIFICAR E CRIAR BUCKET DE STORAGE
-- =====================================================

-- Criar bucket se não existir
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO NOTHING;

-- Remover políticas existentes do storage
DROP POLICY IF EXISTS "Users can upload profile images" ON storage.objects;
DROP POLICY IF EXISTS "Profile images are publicly accessible" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their profile images" ON storage.objects;

-- Política para permitir upload de imagens (organizada por pasta do usuário)
CREATE POLICY "Users can upload profile images" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'profile-images' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Política para visualizar imagens (público)
CREATE POLICY "Profile images are publicly accessible" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-images');

-- Política para atualizar imagens próprias
CREATE POLICY "Users can update their profile images" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'profile-images' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Política para deletar imagens próprias
CREATE POLICY "Users can delete their profile images" ON storage.objects
FOR DELETE USING (
    bucket_id = 'profile-images' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- =====================================================
-- 2. CORRIGIR TABELA PROFILES
-- =====================================================

-- Adicionar campos que possam estar ausentes
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS gender TEXT,
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS instagram TEXT,
ADD COLUMN IF NOT EXISTS daily_water_goal INTEGER DEFAULT 8,
ADD COLUMN IF NOT EXISTS daily_workout_goal INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS weekly_workout_goal INTEGER DEFAULT 5,
ADD COLUMN IF NOT EXISTS weight_goal DECIMAL,
ADD COLUMN IF NOT EXISTS height DECIMAL,
ADD COLUMN IF NOT EXISTS current_weight DECIMAL,
ADD COLUMN IF NOT EXISTS preferred_workout_types TEXT[],
ADD COLUMN IF NOT EXISTS photo_url TEXT;

-- =====================================================
-- 3. CORRIGIR POLÍTICAS RLS DA TABELA PROFILES
-- =====================================================

-- Remover todas as políticas conflitantes
DROP POLICY IF EXISTS "Allow individuals update access to own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow admin full access" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_select_any" ON public.profiles;
DROP POLICY IF EXISTS "profiles_select_policy" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_admin" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
DROP POLICY IF EXISTS "profiles_delete_admin" ON public.profiles;
DROP POLICY IF EXISTS "Anyone can read profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow individuals read access to own profile" ON public.profiles;

-- Habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Política simples para SELECT - qualquer usuário autenticado pode ver qualquer perfil
CREATE POLICY "profiles_select" ON public.profiles
FOR SELECT
TO authenticated
USING (true);

-- Política para INSERT - usuário pode criar apenas seu próprio perfil
CREATE POLICY "profiles_insert" ON public.profiles
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Política para UPDATE - usuário pode atualizar apenas seu próprio perfil
CREATE POLICY "profiles_update" ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Política para DELETE - apenas para casos especiais (pode ser removida se não precisar)
CREATE POLICY "profiles_delete" ON public.profiles
FOR DELETE
TO authenticated
USING (auth.uid() = id);

-- =====================================================
-- 4. FUNÇÃO RPC PARA ATUALIZAR FOTO
-- =====================================================

-- Criar ou substituir função para atualizar foto de perfil
CREATE OR REPLACE FUNCTION public.update_user_photo_url(
    p_user_id uuid, 
    p_photo_url text
)
RETURNS jsonb AS $$
DECLARE
    v_result jsonb;
    v_rows_affected INTEGER;
BEGIN
    -- Verificar se o usuário está autenticado
    IF auth.uid() IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Usuário não autenticado'
        );
    END IF;
    
    -- Verificar se o usuário está atualizando seu próprio perfil
    IF auth.uid() != p_user_id THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Você não tem permissão para atualizar este perfil'
        );
    END IF;
    
    -- Atualizar foto de perfil
    UPDATE public.profiles
    SET 
        photo_url = p_photo_url,
        updated_at = now()
    WHERE id = p_user_id;
    
    GET DIAGNOSTICS v_rows_affected = ROW_COUNT;
    
    IF v_rows_affected > 0 THEN
        v_result := jsonb_build_object(
            'success', true,
            'message', 'Foto de perfil atualizada com sucesso',
            'photo_url', p_photo_url
        );
    ELSE
        v_result := jsonb_build_object(
            'success', false,
            'message', 'Perfil não encontrado ou não foi possível atualizar'
        );
    END IF;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dar permissão para usuários autenticados
GRANT EXECUTE ON FUNCTION public.update_user_photo_url(uuid, text) TO authenticated;

-- =====================================================
-- 5. FUNÇÃO PARA VERIFICAR SE USUÁRIO É ADMIN
-- =====================================================

-- Criar função para verificar se usuário é admin (se não existir)
CREATE OR REPLACE FUNCTION public.is_admin(user_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 
        FROM public.profiles 
        WHERE id = user_id 
        AND is_admin = true
    );
EXCEPTION
    WHEN OTHERS THEN
        RETURN false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 6. TRIGGER PARA ATUALIZAR updated_at
-- =====================================================

-- Criar função para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION public.update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Remover trigger existente se houver
DROP TRIGGER IF EXISTS update_profiles_modtime ON public.profiles;

-- Criar trigger para atualizar updated_at automaticamente
CREATE TRIGGER update_profiles_modtime 
    BEFORE UPDATE ON public.profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION public.update_modified_column();

-- =====================================================
-- 7. VERIFICAR RESULTADO
-- =====================================================

-- Verificar políticas criadas
SELECT 
    policyname,
    cmd,
    permissive,
    roles,
    qual,
    with_check
FROM pg_policies 
WHERE tablename = 'profiles' 
AND schemaname = 'public'
ORDER BY cmd, policyname;

-- Verificar buckets de storage
SELECT 
    id,
    name,
    public
FROM storage.buckets 
WHERE id = 'profile-images';

-- Verificar funções criadas
SELECT 
    proname,
    proargnames,
    prosrc
FROM pg_proc 
WHERE proname IN ('update_user_photo_url', 'is_admin', 'update_modified_column');

-- =====================================================
-- 8. DADOS DE TESTE (OPCIONAL)
-- =====================================================

-- Comentário: Para testar, você pode descomentar as linhas abaixo
-- e substituir o UUID pelo ID do seu usuário de teste

/*
-- Testar função de atualização de foto
SELECT public.update_user_photo_url(
    'SEU_USER_ID_AQUI'::uuid, 
    'https://example.com/test-photo.jpg'
);

-- Verificar se o perfil foi atualizado
SELECT id, name, photo_url, updated_at 
FROM public.profiles 
WHERE id = 'SEU_USER_ID_AQUI'::uuid;
*/

-- =====================================================
-- FIM DO SCRIPT
-- =====================================================

SELECT 'Script de correção de perfil executado com sucesso!' as status; 