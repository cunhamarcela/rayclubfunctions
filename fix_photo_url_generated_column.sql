-- Script para corrigir o problema da coluna photo_url gerada

-- 1. Verificar se photo_url é realmente uma coluna gerada
SELECT 
    column_name,
    data_type,
    is_generated,
    generation_expression
FROM information_schema.columns
WHERE table_name = 'profiles' 
AND table_schema = 'public'
AND column_name IN ('photo_url', 'profile_image_url');

-- 2. Se photo_url for gerada, vamos usar o campo base para atualização
-- Primeiro, verificar qual campo é usado para gerar photo_url
SELECT 
    column_name,
    is_generated,
    generation_expression
FROM information_schema.columns
WHERE table_name = 'profiles' 
AND table_schema = 'public'
AND is_generated = 'ALWAYS';

-- 3. Criar função que atualiza o campo correto (não gerado)
CREATE OR REPLACE FUNCTION public.update_user_photo_path(
    p_user_id uuid, 
    p_photo_path text
)
RETURNS jsonb AS $$
DECLARE
    v_result jsonb;
    v_updated_count int;
BEGIN
    -- Verificar autenticação
    IF auth.uid() IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Usuário não autenticado'
        );
    END IF;
    
    -- Verificar permissão
    IF auth.uid() != p_user_id THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Sem permissão para atualizar este perfil'
        );
    END IF;
    
    -- Tentar atualizar profile_image_url (campo base, não gerado)
    UPDATE public.profiles
    SET 
        profile_image_url = p_photo_path,
        updated_at = now()
    WHERE id = p_user_id;
    
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    
    IF v_updated_count > 0 THEN
        v_result := jsonb_build_object(
            'success', true,
            'message', 'Foto de perfil atualizada com sucesso',
            'photo_path', p_photo_path
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

-- 4. Dar permissão para a função
GRANT EXECUTE ON FUNCTION public.update_user_photo_path(uuid, text) TO authenticated;

-- 5. Função alternativa que atualiza ambos os campos possíveis
CREATE OR REPLACE FUNCTION public.safe_update_user_photo(
    p_user_id uuid, 
    p_photo_url text
)
RETURNS jsonb AS $$
DECLARE
    v_result jsonb;
    v_updated_count int;
    v_columns_updated text[];
BEGIN
    -- Verificar autenticação
    IF auth.uid() IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Usuário não autenticado'
        );
    END IF;
    
    -- Verificar permissão
    IF auth.uid() != p_user_id THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Sem permissão para atualizar este perfil'
        );
    END IF;
    
    -- Tentar atualizar campos não-gerados disponíveis
    BEGIN
        -- Primeiro tentar profile_image_url
        UPDATE public.profiles
        SET 
            profile_image_url = p_photo_url,
            updated_at = now()
        WHERE id = p_user_id;
        
        GET DIAGNOSTICS v_updated_count = ROW_COUNT;
        
        IF v_updated_count > 0 THEN
            v_columns_updated := array_append(v_columns_updated, 'profile_image_url');
        END IF;
        
    EXCEPTION WHEN OTHERS THEN
        -- Se falhar, continuar para próxima tentativa
        NULL;
    END;
    
    -- Se nenhum campo foi atualizado, tentar outros campos possíveis
    IF v_updated_count = 0 THEN
        BEGIN
            -- Tentar um campo photo_path se existir
            UPDATE public.profiles
            SET 
                photo_path = p_photo_url,
                updated_at = now()
            WHERE id = p_user_id;
            
            GET DIAGNOSTICS v_updated_count = ROW_COUNT;
            
            IF v_updated_count > 0 THEN
                v_columns_updated := array_append(v_columns_updated, 'photo_path');
            END IF;
            
        EXCEPTION WHEN OTHERS THEN
            -- Se esse campo também não existir, continuar
            NULL;
        END;
    END IF;
    
    IF v_updated_count > 0 THEN
        v_result := jsonb_build_object(
            'success', true,
            'message', 'Foto de perfil atualizada com sucesso',
            'photo_url', p_photo_url,
            'columns_updated', v_columns_updated
        );
    ELSE
        v_result := jsonb_build_object(
            'success', false,
            'message', 'Não foi possível atualizar a foto. Todos os campos parecem ser gerados automaticamente.',
            'attempted_columns', array['profile_image_url', 'photo_path']
        );
    END IF;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Dar permissão para a função
GRANT EXECUTE ON FUNCTION public.safe_update_user_photo(uuid, text) TO authenticated; 