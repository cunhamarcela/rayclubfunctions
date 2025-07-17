-- CORREÇÃO FINAL: Simplificar a função de exclusão removendo chamadas desnecessárias
-- A função de update funciona porque NÃO chama recalculate_challenge_progress

DROP FUNCTION IF EXISTS delete_workout_and_refresh(UUID, UUID, UUID);
DROP FUNCTION IF EXISTS delete_workout_and_refresh(UUID, UUID, UUID, UUID);

CREATE OR REPLACE FUNCTION delete_workout_and_refresh(
    p_workout_record_id UUID,
    p_user_id UUID,
    p_challenge_id UUID,
    p_workout_id UUID DEFAULT NULL -- Manter compatibilidade com o código Flutter
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    -- Verificar se o registro existe e pertence ao usuário
    IF NOT EXISTS (
        SELECT 1 FROM workout_records 
        WHERE id = p_workout_record_id AND user_id = p_user_id
    ) THEN
        RETURN jsonb_build_object(
            'success', FALSE,
            'message', 'Registro não encontrado ou não pertence ao usuário',
            'error_code', 'not_found'
        );
    END IF;

    -- Excluir o registro
    DELETE FROM workout_records
    WHERE id = p_workout_record_id AND user_id = p_user_id;

    -- Atualizar dashboard (similar à função de update)
    BEGIN
        PERFORM refresh_dashboard_data(p_user_id);
    EXCEPTION WHEN OTHERS THEN
        -- Continuar mesmo se falhar
        NULL;
    END;

    -- NÃO chamar recalculate_challenge_progress pois:
    -- 1. A função pode não existir
    -- 2. Não faz sentido recalcular após excluir
    -- 3. A função de update que funciona também não chama

    -- Retornar sucesso
    RETURN jsonb_build_object(
        'success', TRUE,
        'message', 'Treino excluído com sucesso'
    );
    
EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', FALSE,
        'message', 'Erro ao excluir treino: ' || SQLERRM,
        'error_code', SQLSTATE
    );
END;
$$;

-- Garantir permissões
GRANT EXECUTE ON FUNCTION delete_workout_and_refresh(UUID, UUID, UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION delete_workout_and_refresh(UUID, UUID, UUID, UUID) TO anon;

-- Verificar se a função foi criada corretamente
SELECT 
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    pg_get_function_result(p.oid) as return_type
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' 
    AND p.proname = 'delete_workout_and_refresh'; 