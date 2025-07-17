-- TESTE DAS FUNÇÕES DE ATUALIZAÇÃO E EXCLUSÃO CORRIGIDAS
-- Execute este script para validar as correções

-- IDs de teste
-- User ID: 01d4a292-1873-4af6-948b-a55eed56d6b9
-- Challenge ID: 29c91ea0-7dc1-486f-8e4a-86686cbf5f82

-- ===================================================
-- 1. VERIFICAR ESTADO ATUAL
-- ===================================================

SELECT 'ESTADO INICIAL:' as info;

-- Verificar workout_records
SELECT 'workout_records:' as tipo, 
       COUNT(*) as total
FROM workout_records 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- Verificar challenge_check_ins
SELECT 'challenge_check_ins:' as tipo,
       COUNT(*) as total
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- Verificar challenge_progress
SELECT 'challenge_progress:' as tipo,
       points, check_ins_count, total_check_ins, completion_percentage
FROM challenge_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- ===================================================
-- 2. CRIAR UM TREINO PARA TESTAR EDIÇÃO
-- ===================================================

SELECT 'CRIANDO TREINO PARA TESTE:' as info;

SELECT record_workout_basic(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID, -- p_user_id
    'Treino Para Testar Edição',                   -- p_workout_name
    'Funcional',                                   -- p_workout_type
    55,                                            -- p_duration_minutes (>= 45)
    NOW() - INTERVAL '1 hour',                     -- p_date (1 hora atrás)
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID, -- p_challenge_id
    NULL,                                          -- p_workout_id
    'Treino criado para teste de edição',         -- p_notes
    NULL                                           -- p_workout_record_id
) as resultado_criacao;

-- Pegar o ID do treino criado
DO $$
DECLARE
    test_workout_id UUID;
    update_result JSONB;
    delete_result JSONB;
BEGIN
    -- Buscar o último treino criado
    SELECT id INTO test_workout_id
    FROM workout_records 
    WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
      AND workout_name = 'Treino Para Testar Edição'
    ORDER BY created_at DESC 
    LIMIT 1;
    
    IF test_workout_id IS NOT NULL THEN
        RAISE NOTICE 'TREINO ENCONTRADO PARA TESTE: %', test_workout_id;
        
        -- ===================================================
        -- 3. TESTAR FUNÇÃO DE ATUALIZAÇÃO
        -- ===================================================
        
        RAISE NOTICE 'TESTANDO ATUALIZAÇÃO...';
        
        SELECT update_workout_and_refresh(
            test_workout_id,                               -- p_workout_record_id
            '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID, -- p_user_id
            '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID, -- p_challenge_id
            'Treino Editado - Teste',                      -- p_workout_name
            'Musculação',                                  -- p_workout_type
            65,                                            -- p_duration_minutes
            NOW() - INTERVAL '30 minutes',                -- p_date
            'Treino editado via função corrigida',        -- p_notes
            NULL                                           -- p_workout_id
        ) INTO update_result;
        
        RAISE NOTICE 'RESULTADO DA ATUALIZAÇÃO: %', update_result;
        
        -- Verificar se a atualização funcionou
        IF (update_result->>'success')::boolean = true THEN
            RAISE NOTICE '✅ ATUALIZAÇÃO FUNCIONOU!';
            
            -- Verificar challenge_check_ins atualizado
            PERFORM 1 FROM challenge_check_ins 
            WHERE workout_id = test_workout_id
              AND workout_name = 'Treino Editado - Teste'
              AND workout_type = 'Musculação'
              AND duration_minutes = 65;
              
            IF FOUND THEN
                RAISE NOTICE '✅ Challenge check-in foi atualizado corretamente!';
            ELSE
                RAISE NOTICE '❌ Challenge check-in NÃO foi atualizado!';
            END IF;
        ELSE
            RAISE NOTICE '❌ ERRO NA ATUALIZAÇÃO: %', update_result->>'message';
        END IF;
        
        -- ===================================================
        -- 4. TESTAR FUNÇÃO DE EXCLUSÃO
        -- ===================================================
        
        RAISE NOTICE 'TESTANDO EXCLUSÃO...';
        
        SELECT delete_workout_and_refresh(
            test_workout_id,                               -- p_workout_record_id
            '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID, -- p_user_id
            '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID, -- p_challenge_id
            NULL                                           -- p_workout_id
        ) INTO delete_result;
        
        RAISE NOTICE 'RESULTADO DA EXCLUSÃO: %', delete_result;
        
        -- Verificar se a exclusão funcionou
        IF (delete_result->>'success')::boolean = true THEN
            RAISE NOTICE '✅ EXCLUSÃO FUNCIONOU!';
            
            -- Verificar se o workout foi removido
            PERFORM 1 FROM workout_records WHERE id = test_workout_id;
            IF NOT FOUND THEN
                RAISE NOTICE '✅ Workout foi removido do banco!';
            ELSE
                RAISE NOTICE '❌ Workout ainda existe no banco!';
            END IF;
            
            -- Verificar se challenge_check_ins foi removido
            PERFORM 1 FROM challenge_check_ins WHERE workout_id = test_workout_id;
            IF NOT FOUND THEN
                RAISE NOTICE '✅ Challenge check-in foi removido!';
            ELSE
                RAISE NOTICE '❌ Challenge check-in ainda existe!';
            END IF;
        ELSE
            RAISE NOTICE '❌ ERRO NA EXCLUSÃO: %', delete_result->>'message';
        END IF;
        
    ELSE
        RAISE NOTICE '❌ TREINO NÃO ENCONTRADO PARA TESTE!';
    END IF;
END $$;

-- ===================================================
-- 5. VERIFICAR ESTADO FINAL
-- ===================================================

SELECT 'ESTADO FINAL:' as info;

-- Verificar challenge_progress final
SELECT 'challenge_progress FINAL:' as tipo,
       points, check_ins_count, total_check_ins, completion_percentage, updated_at
FROM challenge_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- Verificar contagem final de check-ins
SELECT 'CONTAGEM FINAL de check-ins:' as tipo,
       COUNT(*) as total
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'; 