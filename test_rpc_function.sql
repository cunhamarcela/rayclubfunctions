-- Script para testar a função record_challenge_check_in_v2 localmente
-- Habilitar saída detalhada
SET client_min_messages TO DEBUG;

-- Wrapper de teste com tratamento de erros e logs
DO $$
DECLARE
    v_user_id UUID := '01d4a292-1873-4af6-948b-a55eed56d6b9'; -- Substitua por um ID de usuário válido
    v_challenge_id UUID := '61cf61f4-0325-476e-8ab2-481bf84fd8a4'; -- Substitua por um ID de desafio válido
    v_workout_id UUID := '00000000-0000-0000-0000-000000000003'; -- Substitua por um ID de treino válido
    result RECORD;
BEGIN
    RAISE NOTICE 'Iniciando teste da função record_challenge_check_in_v2';
    RAISE NOTICE 'Parâmetros: user_id=%, challenge_id=%, workout_id=%', 
                 v_user_id, v_challenge_id, v_workout_id;
    
    -- Iniciar uma transação explícita
    BEGIN
        -- Chamar a função e capturar o resultado
        SELECT * FROM public.record_challenge_check_in_v2(
            v_user_id, 
            v_challenge_id,
            v_workout_id
        ) INTO result;
        
        RAISE NOTICE 'Função executada com sucesso. Resultado: %', result;
        
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Erro ao executar a função: % (SQLSTATE: %)', 
                     SQLERRM, SQLSTATE;
        
        -- Informações adicionais de diagnóstico
        RAISE NOTICE 'Contexto completo do erro:';
        RAISE NOTICE '%', pg_exception_context();
    END;
    
    RAISE NOTICE 'Teste concluído';
END $$;

-- Para verificar logs de transação (opcional, executar separadamente)
-- SELECT * FROM pg_stat_activity WHERE backend_type = 'client backend' ORDER BY query_start DESC LIMIT 10; 