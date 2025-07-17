-- TESTE DAS FUNÇÕES EXISTENTES CORRIGIDAS
-- Testa as mesmas funções que já estão sendo usadas no código
-- Apenas valida se a lógica foi corrigida

-- IDs de teste
-- User ID: 01d4a292-1873-4af6-948b-a55eed56d6b9
-- Challenge ID: 29c91ea0-7dc1-486f-8e4a-86686cbf5f82

-- ===================================================
-- 1. VERIFICAR ESTADO INICIAL
-- ===================================================

SELECT 'TESTANDO FUNÇÕES EXISTENTES CORRIGIDAS:' as info;

-- Verificar challenge_progress antes
SELECT 'challenge_progress ANTES:' as tipo,
       points, check_ins_count, total_check_ins, completion_percentage
FROM challenge_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- ===================================================
-- 2. TESTAR recalculate_challenge_progress CORRIGIDA
-- ===================================================

SELECT 'TESTANDO recalculate_challenge_progress:' as info;

-- Chamar a função existente (agora corrigida)
DO $$
BEGIN
    PERFORM recalculate_challenge_progress(
        '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID,
        '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID
    );
    RAISE NOTICE '✅ Função recalculate_challenge_progress executada';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '❌ Erro na função: %', SQLERRM;
END $$;

-- Verificar resultado
SELECT 'challenge_progress APÓS recálculo:' as tipo,
       points, check_ins_count, total_check_ins, completion_percentage, updated_at
FROM challenge_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- ===================================================
-- 3. CRIAR TREINO PARA TESTAR update_workout_and_refresh
-- ===================================================

SELECT 'CRIANDO TREINO PARA TESTE DE EDIÇÃO:' as info;

SELECT record_workout_basic(
    '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID, -- p_user_id
    'Treino Para Testar Edição Existing',          -- p_workout_name
    'Funcional',                                   -- p_workout_type
    55,                                            -- p_duration_minutes (>= 45)
    NOW() - INTERVAL '2 hours',                    -- p_date (2 horas atrás)
    '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID, -- p_challenge_id
    NULL,                                          -- p_workout_id
    'Treino criado para teste das funções existentes', -- p_notes
    NULL                                           -- p_workout_record_id
) as resultado_criacao;

-- ===================================================
-- 4. TESTAR update_workout_and_refresh (EXISTENTE)
-- ===================================================

DO $$
DECLARE
    test_workout_id UUID;
    update_result JSONB;
    delete_result JSONB;
BEGIN
    -- Buscar o treino criado
    SELECT id INTO test_workout_id
    FROM workout_records 
    WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
      AND workout_name = 'Treino Para Testar Edição Existing'
    ORDER BY created_at DESC 
    LIMIT 1;
    
    IF test_workout_id IS NOT NULL THEN
        RAISE NOTICE 'TREINO ENCONTRADO: %', test_workout_id;
        
        -- Testar update_workout_and_refresh (função existente corrigida)
        RAISE NOTICE 'TESTANDO update_workout_and_refresh...';
        
        SELECT update_workout_and_refresh(
            test_workout_id,                               -- p_workout_record_id
            '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID, -- p_user_id
            '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID, -- p_challenge_id
            'Treino Editado - Função Existente',           -- p_workout_name
            'Musculação',                                  -- p_workout_type
            65,                                            -- p_duration_minutes
            NOW() - INTERVAL '1 hour',                     -- p_date
            'Editado via função existente corrigida',     -- p_notes
            NULL                                           -- p_workout_id
        ) INTO update_result;
        
        RAISE NOTICE 'RESULTADO UPDATE: %', update_result;
        
        -- Verificar se funcionou
        IF (update_result->>'success')::boolean = true THEN
            RAISE NOTICE '✅ update_workout_and_refresh FUNCIONOU!';
            
            -- Verificar se challenge_check_ins foi atualizado
            PERFORM 1 FROM challenge_check_ins 
            WHERE workout_id = test_workout_id
              AND workout_name = 'Treino Editado - Função Existente'
              AND workout_type = 'Musculação';
              
            IF FOUND THEN
                RAISE NOTICE '✅ Challenge check-in foi atualizado!';
            ELSE
                RAISE NOTICE '❌ Challenge check-in NÃO foi atualizado!';
            END IF;
        ELSE
            RAISE NOTICE '❌ ERRO NO UPDATE: %', update_result->>'message';
        END IF;
        
        -- ===================================================
        -- 5. TESTAR delete_workout_and_refresh (EXISTENTE)
        -- ===================================================
        
        RAISE NOTICE 'TESTANDO delete_workout_and_refresh...';
        
        SELECT delete_workout_and_refresh(
            test_workout_id,                               -- p_workout_record_id
            '01d4a292-1873-4af6-948b-a55eed56d6b9'::UUID, -- p_user_id
            '29c91ea0-7dc1-486f-8e4a-86686cbf5f82'::UUID, -- p_challenge_id
            NULL                                           -- p_workout_id
        ) INTO delete_result;
        
        RAISE NOTICE 'RESULTADO DELETE: %', delete_result;
        
        -- Verificar se funcionou
        IF (delete_result->>'success')::boolean = true THEN
            RAISE NOTICE '✅ delete_workout_and_refresh FUNCIONOU!';
            
            -- Verificar se workout foi removido
            PERFORM 1 FROM workout_records WHERE id = test_workout_id;
            IF NOT FOUND THEN
                RAISE NOTICE '✅ Workout removido do banco!';
            ELSE
                RAISE NOTICE '❌ Workout ainda existe!';
            END IF;
            
            -- Verificar se challenge_check_ins foi removido
            PERFORM 1 FROM challenge_check_ins WHERE workout_id = test_workout_id;
            IF NOT FOUND THEN
                RAISE NOTICE '✅ Challenge check-in removido!';
            ELSE
                RAISE NOTICE '❌ Challenge check-in ainda existe!';
            END IF;
        ELSE
            RAISE NOTICE '❌ ERRO NO DELETE: %', delete_result->>'message';
        END IF;
        
    ELSE
        RAISE NOTICE '❌ TREINO NÃO ENCONTRADO!';
    END IF;
END $$;

-- ===================================================
-- 6. VERIFICAR ESTADO FINAL
-- ===================================================

SELECT 'RESULTADO FINAL:' as info;

-- Verificar challenge_progress final
SELECT 'challenge_progress FINAL:' as tipo,
       points, check_ins_count, total_check_ins, completion_percentage, updated_at
FROM challenge_progress 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

-- Verificar contagem atual de check-ins
SELECT 'CONTAGEM FINAL de check-ins:' as tipo,
       COUNT(*) as total
FROM challenge_check_ins 
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND challenge_id = '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';

SELECT '✅ TESTE DAS FUNÇÕES EXISTENTES CONCLUÍDO!' as status; 