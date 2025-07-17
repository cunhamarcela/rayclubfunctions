-- Script para testar o fluxo completo de conclusão de treino
SET client_min_messages TO DEBUG;

DO $$
DECLARE
    v_user_id UUID;
    v_challenge_id UUID;
    v_workout_id UUID;
    v_result RECORD;
BEGIN
    -- 1. Configuração - Obter IDs existentes para teste
    -- Obter um usuário válido
    SELECT id INTO v_user_id FROM auth.users LIMIT 1;
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Nenhum usuário encontrado na tabela auth.users';
    END IF;
    
    -- Obter um desafio válido (ativo)
    SELECT id INTO v_challenge_id 
    FROM public.challenges 
    WHERE now() BETWEEN start_date AND end_date
    LIMIT 1;
    IF v_challenge_id IS NULL THEN
        RAISE EXCEPTION 'Nenhum desafio ativo encontrado';
    END IF;
    
    -- Obter um treino válido
    SELECT id INTO v_workout_id 
    FROM public.workouts 
    LIMIT 1;
    IF v_workout_id IS NULL THEN
        RAISE EXCEPTION 'Nenhum treino encontrado';
    END IF;
    
    -- Log de início
    RAISE NOTICE '======= INICIANDO TESTE DE CONCLUSÃO DE TREINO =======';
    RAISE NOTICE 'User ID: %', v_user_id;
    RAISE NOTICE 'Challenge ID: %', v_challenge_id;
    RAISE NOTICE 'Workout ID: %', v_workout_id;
    
    -- 2. Testar função record_challenge_check_in_v2
    RAISE NOTICE '------- Testando record_challenge_check_in_v2 -------';
    BEGIN
        SELECT * FROM public.record_challenge_check_in_v2(
            v_user_id, 
            v_challenge_id,
            v_workout_id
        ) INTO v_result;
        
        RAISE NOTICE 'Função executada com sucesso: %', v_result;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro: % (SQLSTATE: %)', SQLERRM, SQLSTATE;
        RAISE NOTICE 'Contexto: %', pg_exception_context();
        
        -- Informações de diagnóstico - verificar estado atual
        RAISE NOTICE 'Estado atual da participação no desafio:';
        BEGIN
            RAISE NOTICE '%', (
                SELECT json_build_object(
                    'challenge_id', c.id,
                    'user_id', cp.user_id,
                    'workouts_completed', cp.workouts_completed,
                    'last_check_in', cp.last_check_in,
                    'points', cp.points
                )
                FROM public.challenge_participants cp
                JOIN public.challenges c ON c.id = cp.challenge_id
                WHERE cp.user_id = v_user_id AND cp.challenge_id = v_challenge_id
            );
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Não foi possível obter informações da participação: %', SQLERRM;
        END;
        
        -- Verificar registros de treino
        RAISE NOTICE 'Registros de treino existentes:';
        BEGIN
            RAISE NOTICE '%', (
                SELECT json_agg(json_build_object(
                    'workout_id', workout_id,
                    'completed_at', completed_at
                ))
                FROM public.workout_records
                WHERE user_id = v_user_id
                ORDER BY completed_at DESC
                LIMIT 5
            );
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Não foi possível obter registros de treino: %', SQLERRM;
        END;
    END;
    
    RAISE NOTICE '======= TESTE CONCLUÍDO =======';
END $$; 