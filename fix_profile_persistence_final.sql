-- Script para corrigir problemas de persistência do perfil
-- Execute este script no SQL Editor do Supabase

-- 1. Criar função segura para update de perfil
CREATE OR REPLACE FUNCTION safe_update_profile(
    p_user_id uuid,
    p_name text DEFAULT NULL,
    p_phone text DEFAULT NULL,
    p_instagram text DEFAULT NULL,
    p_gender text DEFAULT NULL,
    p_bio text DEFAULT NULL,
    p_birth_date text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result jsonb;
    v_updated_count int;
    v_update_data jsonb := '{}';
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
    
    -- Construir dados de update dinamicamente
    IF p_name IS NOT NULL THEN
        v_update_data := v_update_data || jsonb_build_object('name', p_name);
    END IF;
    
    IF p_phone IS NOT NULL THEN
        v_update_data := v_update_data || jsonb_build_object('phone', p_phone);
    END IF;
    
    IF p_instagram IS NOT NULL THEN
        v_update_data := v_update_data || jsonb_build_object('instagram', p_instagram);
    END IF;
    
    IF p_gender IS NOT NULL THEN
        v_update_data := v_update_data || jsonb_build_object('gender', p_gender);
    END IF;
    
    IF p_bio IS NOT NULL THEN
        v_update_data := v_update_data || jsonb_build_object('bio', p_bio);
    END IF;
    
    IF p_birth_date IS NOT NULL THEN
        v_update_data := v_update_data || jsonb_build_object('birth_date', p_birth_date::timestamptz);
    END IF;
    
    -- Sempre atualizar timestamp
    v_update_data := v_update_data || jsonb_build_object('updated_at', now());
    
    -- Executar update usando jsonb_to_record para garantir tipos corretos
    UPDATE public.profiles
    SET 
        name = COALESCE((v_update_data->>'name'), name),
        phone = COALESCE((v_update_data->>'phone'), phone),
        instagram = COALESCE((v_update_data->>'instagram'), instagram),
        gender = COALESCE((v_update_data->>'gender'), gender),
        bio = COALESCE((v_update_data->>'bio'), bio),
        birth_date = COALESCE((v_update_data->>'birth_date')::timestamptz, birth_date),
        updated_at = now()
    WHERE id = p_user_id;
    
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    
    IF v_updated_count > 0 THEN
        v_result := jsonb_build_object(
            'success', true,
            'message', 'Perfil atualizado com sucesso',
            'updated_fields', v_update_data,
            'rows_affected', v_updated_count
        );
    ELSE
        v_result := jsonb_build_object(
            'success', false,
            'message', 'Perfil não encontrado ou não foi possível atualizar'
        );
    END IF;
    
    RETURN v_result;
END;
$$;

-- 2. Dar permissões para a função
GRANT EXECUTE ON FUNCTION safe_update_profile TO authenticated;

-- 3. Verificar e corrigir triggers problemáticos
DO $$
DECLARE
    trigger_count INTEGER;
BEGIN
    -- Contar quantos triggers de update_modified_column existem
    SELECT COUNT(*) INTO trigger_count
    FROM information_schema.triggers 
    WHERE event_object_table = 'profiles'
      AND action_statement LIKE '%update_modified_column%'
      AND event_manipulation = 'UPDATE'
      AND action_timing = 'BEFORE';
    
    -- Se houver mais de 1 trigger duplicado, remover o extra
    IF trigger_count > 1 THEN
        -- Manter apenas um dos triggers (o primeiro encontrado)
        DROP TRIGGER IF EXISTS update_profiles_modtime ON profiles;
        
        RAISE NOTICE 'Trigger duplicado update_profiles_modtime removido';
    END IF;
END $$;

-- 4. Garantir que existe pelo menos um trigger de updated_at
DO $$
BEGIN
    -- Verificar se existe algum trigger para updated_at
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.triggers 
        WHERE event_object_table = 'profiles'
          AND action_statement LIKE '%update_modified_column%'
          AND event_manipulation = 'UPDATE'
          AND action_timing = 'BEFORE'
    ) THEN
        -- Criar trigger se não existir
        CREATE TRIGGER set_profiles_updated_at_safe
            BEFORE UPDATE ON profiles
            FOR EACH ROW
            EXECUTE FUNCTION update_modified_column();
            
        RAISE NOTICE 'Trigger de updated_at criado';
    END IF;
END $$;

-- 5. Criar função de diagnóstico rápido
CREATE OR REPLACE FUNCTION diagnose_profile_update(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result jsonb;
    v_profile_exists boolean;
    v_photo_url_type text;
    v_triggers_count integer;
BEGIN
    -- Verificar se perfil existe
    SELECT EXISTS(SELECT 1 FROM profiles WHERE id = p_user_id) INTO v_profile_exists;
    
    -- Verificar tipo da coluna photo_url
    SELECT 
        CASE 
            WHEN generation_expression IS NOT NULL THEN 'GENERATED'
            ELSE 'NORMAL'
        END
    INTO v_photo_url_type
    FROM information_schema.columns 
    WHERE table_name = 'profiles' 
      AND column_name = 'photo_url';
    
    -- Contar triggers
    SELECT COUNT(*) INTO v_triggers_count
    FROM information_schema.triggers 
    WHERE event_object_table = 'profiles'
      AND event_manipulation = 'UPDATE';
    
    v_result := jsonb_build_object(
        'user_exists', v_profile_exists,
        'photo_url_type', v_photo_url_type,
        'triggers_count', v_triggers_count,
        'recommendations', jsonb_build_array(
            CASE 
                WHEN v_photo_url_type = 'GENERATED' 
                THEN 'Use profile_image_url em vez de photo_url para updates'
                ELSE 'photo_url pode ser atualizada diretamente'
            END,
            CASE 
                WHEN v_triggers_count > 3 
                THEN 'Muitos triggers - possível conflito'
                ELSE 'Número normal de triggers'
            END
        )
    );
    
    RETURN v_result;
END;
$$;

-- 6. Dar permissões
GRANT EXECUTE ON FUNCTION diagnose_profile_update TO authenticated;

-- 7. Teste a função (remova os comentários para testar)
-- SELECT diagnose_profile_update(auth.uid());

-- 8. Exemplo de uso da função segura
-- SELECT safe_update_profile(
--     auth.uid(),
--     p_name := 'Novo Nome',
--     p_phone := '(11) 99999-9999'
-- );

-- 9. Verificar se todas as funções foram criadas
SELECT 
    routine_name,
    routine_type,
    security_type
FROM information_schema.routines 
WHERE routine_name IN ('safe_update_profile', 'diagnose_profile_update')
ORDER BY routine_name; 