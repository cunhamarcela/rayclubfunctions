-- Adicionar função para permitir que todos os usuários editem seus próprios treinos
-- Esta função usa SECURITY DEFINER para contornar as políticas RLS
-- mas mantém a segurança verificando se o usuário é dono do registro

CREATE OR REPLACE FUNCTION update_workout_and_refresh(
    p_workout_record_id UUID,
    p_user_id UUID,
    p_challenge_id UUID,
    p_workout_name TEXT,
    p_workout_type TEXT,
    p_duration_minutes INTEGER,
    p_date TIMESTAMP WITH TIME ZONE,
    p_notes TEXT DEFAULT '',
    p_workout_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER -- Executa com as permissões do criador da função
AS $$
DECLARE
    result JSONB;
    effective_workout_id UUID;
BEGIN
    -- Verificar se o usuário é o dono do registro
    IF NOT EXISTS (
        SELECT 1 FROM workout_records 
        WHERE id = p_workout_record_id AND user_id = p_user_id
    ) THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Não é possível editar treino que não pertence ao usuário',
            'error_code', 'unauthorized'
        );
    END IF;
    
    -- Usar o workout_id fornecido ou manter o existente
    IF p_workout_id IS NOT NULL THEN
        effective_workout_id := p_workout_id;
    ELSE
        SELECT workout_id INTO effective_workout_id
        FROM workout_records
        WHERE id = p_workout_record_id;
    END IF;
    
    -- Atualizar o registro
    UPDATE workout_records SET
        challenge_id = p_challenge_id,
        workout_id = effective_workout_id,
        workout_name = p_workout_name,
        workout_type = p_workout_type,
        date = p_date,
        duration_minutes = p_duration_minutes,
        notes = p_notes,
        updated_at = NOW()
    WHERE id = p_workout_record_id;
    
    -- Atualizar as estatísticas do dashboard
    PERFORM refresh_dashboard_data(p_user_id);
    
    -- Se tiver challenge_id, atualizar também o progresso do desafio
    IF p_challenge_id IS NOT NULL THEN
        BEGIN
            PERFORM recalculate_challenge_progress(p_user_id, p_challenge_id);
        EXCEPTION WHEN OTHERS THEN
            -- Ignora erros na recalculação do progresso
            NULL;
        END;
    END IF;
    
    -- Retornar sucesso
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Treino atualizado com sucesso',
        'workout_record_id', p_workout_record_id
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', FALSE,
        'message', 'Erro ao atualizar treino: ' || SQLERRM,
        'error_code', SQLSTATE
    );
END;
$$;

-- Adicionar função para permitir que todos os usuários excluam seus próprios treinos
CREATE OR REPLACE FUNCTION delete_workout_and_refresh(
    p_workout_record_id UUID,
    p_user_id UUID,
    p_challenge_id UUID,
    p_workout_id UUID DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER -- Executa com as permissões do criador da função
AS $$
DECLARE
    result JSONB;
BEGIN
    -- Verificar se o usuário é o dono do registro
    IF NOT EXISTS (
        SELECT 1 FROM workout_records 
        WHERE id = p_workout_record_id AND user_id = p_user_id
    ) THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Não é possível excluir treino que não pertence ao usuário',
            'error_code', 'unauthorized'
        );
    END IF;
    
    -- Excluir o registro
    DELETE FROM workout_records
    WHERE id = p_workout_record_id;
    
    -- Atualizar as estatísticas do dashboard
    PERFORM refresh_dashboard_data(p_user_id);
    
    -- Se tiver challenge_id, atualizar também o progresso do desafio
    IF p_challenge_id IS NOT NULL THEN
        BEGIN
            PERFORM recalculate_challenge_progress(p_user_id, p_challenge_id);
        EXCEPTION WHEN OTHERS THEN
            -- Ignora erros na recalculação do progresso
            NULL;
        END;
    END IF;
    
    -- Retornar sucesso
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Treino excluído com sucesso',
        'workout_record_id', p_workout_record_id
    );
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', FALSE,
        'message', 'Erro ao excluir treino: ' || SQLERRM,
        'error_code', SQLSTATE
    );
END;
$$;

-- Garantir que todos os outros usuários possam ver estas funções
GRANT EXECUTE ON FUNCTION update_workout_and_refresh(UUID, UUID, UUID, TEXT, TEXT, INTEGER, TIMESTAMP WITH TIME ZONE, TEXT, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_workout_and_refresh(UUID, UUID, UUID, UUID) TO authenticated;

-- Adicionar comentários para documentação
COMMENT ON FUNCTION update_workout_and_refresh IS 'Função segura para permitir que usuários atualizem seus próprios registros de treinos, independente de serem admins.';
COMMENT ON FUNCTION delete_workout_and_refresh IS 'Função segura para permitir que usuários excluam seus próprios registros de treinos, independente de serem admins.'; 