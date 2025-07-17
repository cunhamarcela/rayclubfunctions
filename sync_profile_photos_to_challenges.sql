-- Script para sincronizar fotos de perfil dos desafios com a tabela profiles
-- Este script deve ser executado quando o usuário atualizar sua foto de perfil

-- 1. Função para sincronizar foto de um usuário específico
CREATE OR REPLACE FUNCTION sync_user_photo_to_challenges(p_user_id uuid)
RETURNS void AS $$
DECLARE
    v_photo_url text;
BEGIN
    -- Buscar a foto atual do usuário
    SELECT photo_url INTO v_photo_url
    FROM public.profiles
    WHERE id = p_user_id;
    
    -- Atualizar todos os registros de progresso deste usuário
    UPDATE public.challenge_progress
    SET 
        user_photo_url = v_photo_url,
        updated_at = now()
    WHERE user_id = p_user_id;
    
    -- Log da operação
    RAISE NOTICE 'Foto sincronizada para usuário % em % registros de desafio', 
                 p_user_id, 
                 (SELECT count(*) FROM public.challenge_progress WHERE user_id = p_user_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Função para sincronizar todas as fotos (caso necessário)
CREATE OR REPLACE FUNCTION sync_all_photos_to_challenges()
RETURNS void AS $$
DECLARE
    sync_count integer := 0;
BEGIN
    -- Atualizar todas as fotos de perfil nos desafios
    UPDATE public.challenge_progress cp
    SET 
        user_photo_url = p.photo_url,
        updated_at = now()
    FROM public.profiles p
    WHERE cp.user_id = p.id
    AND (cp.user_photo_url IS DISTINCT FROM p.photo_url);
    
    GET DIAGNOSTICS sync_count = ROW_COUNT;
    
    RAISE NOTICE 'Sincronizadas % fotos de perfil nos desafios', sync_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Trigger para sincronização automática quando a foto do perfil for atualizada
CREATE OR REPLACE FUNCTION trigger_sync_photo_to_challenges()
RETURNS trigger AS $$
BEGIN
    -- Sincronizar apenas se a photo_url foi alterada
    IF OLD.photo_url IS DISTINCT FROM NEW.photo_url THEN
        PERFORM sync_user_photo_to_challenges(NEW.id);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar o trigger se não existir
DROP TRIGGER IF EXISTS profiles_photo_sync_trigger ON public.profiles;
CREATE TRIGGER profiles_photo_sync_trigger
    AFTER UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION trigger_sync_photo_to_challenges();

-- 4. Executar sincronização inicial para garantir consistência
SELECT sync_all_photos_to_challenges();

-- 5. Dar permissões
GRANT EXECUTE ON FUNCTION sync_user_photo_to_challenges(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION sync_all_photos_to_challenges() TO authenticated; 