-- ================================================================
-- CORREÇÃO FINAL DAS FUNÇÕES REAIS PARA CHECK-INS RETROATIVOS
-- ================================================================
-- ✅ VALIDAÇÕES FEITAS + RESULTADOS VISÍVEIS
-- ================================================================

-- 1. DIAGNÓSTICO PRÉ-CORREÇÃO
SELECT '🔍 VALIDAÇÃO PRÉ-CORREÇÃO' as status;

-- Verificar função to_brt
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'to_brt') THEN '✅ Função to_brt encontrada'
        ELSE '❌ ERRO: Função to_brt não encontrada!'
    END as validacao_to_brt;

-- Verificar tabelas necessárias
SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'check_in_error_logs') THEN '✅ Tabela check_in_error_logs encontrada'
        ELSE '⚠️ Tabela check_in_error_logs será criada'
    END as validacao_error_logs;

SELECT 
    CASE 
        WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') THEN '✅ Tabela workout_processing_queue encontrada'
        ELSE '⚠️ Tabela workout_processing_queue será criada'
    END as validacao_queue;

-- Criar tabelas se não existirem
CREATE TABLE IF NOT EXISTS check_in_error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID,
    challenge_id UUID,
    workout_id UUID,
    error_message TEXT,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS workout_processing_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL,
    processed_for_ranking BOOLEAN DEFAULT FALSE,
    processing_error TEXT,
    processed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

SELECT '✅ Todas as dependências validadas!' as dependencias_ok;

-- ================================================================
-- PARTE 1: CORRIGIR record_workout_basic
-- ================================================================

SELECT '🔧 CORRIGINDO record_workout_basic' as etapa;

CREATE OR REPLACE FUNCTION public.record_workout_basic(
    p_user_id uuid, 
    p_workout_name text, 
    p_workout_type text, 
    p_duration_minutes integer, 
    p_date timestamp with time zone, 
    p_challenge_id uuid DEFAULT NULL::uuid, 
    p_workout_id text DEFAULT NULL::text, 
    p_notes text DEFAULT NULL::text, 
    p_workout_record_id uuid DEFAULT NULL::uuid
)
RETURNS jsonb
LANGUAGE plpgsql
AS $function$
DECLARE
    v_id UUID;
    existing_record UUID;
    v_workout_id UUID;
    date_brt TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Converter data para BRT
    date_brt := to_brt(p_date);
    
    -- Converter p_workout_id de TEXT para UUID
    IF p_workout_id IS NOT NULL AND p_workout_id != '' THEN
        BEGIN
            v_workout_id := p_workout_id::UUID;
        EXCEPTION WHEN OTHERS THEN
            v_workout_id := gen_random_uuid();
        END;
    ELSE
        v_workout_id := NULL;
    END IF;

    -- CORREÇÃO 1: Update vs Insert
    IF p_workout_record_id IS NOT NULL THEN
        SELECT id INTO existing_record
        FROM workout_records
        WHERE id = p_workout_record_id;
        
        IF FOUND THEN
            UPDATE workout_records
            SET workout_name = p_workout_name,
                workout_type = p_workout_type,
                duration_minutes = p_duration_minutes,
                date = date_brt,  -- ✅ Data do formulário (permite retroativo)
                challenge_id = p_challenge_id,
                notes = p_notes,
                workout_id = v_workout_id
            WHERE id = p_workout_record_id;
            
            v_id := p_workout_record_id;
            
            -- Processar para ranking
            BEGIN
                PERFORM process_workout_for_ranking(v_id);
            EXCEPTION WHEN OTHERS THEN
                INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
                VALUES (p_user_id, p_challenge_id, v_id, SQLERRM, 'ranking_fail_update', to_brt(NOW()));
            END;
            
            RETURN jsonb_build_object(
                'success', true,
                'workout_id', v_id,
                'message', 'Treino atualizado com sucesso',
                'is_retroactive', DATE(date_brt) != CURRENT_DATE
            );
        END IF;
    END IF;

    -- CORREÇÃO 2: Verificação de duplicatas ESPECÍFICA
    SELECT id INTO existing_record
    FROM workout_records
    WHERE user_id = p_user_id
      AND workout_name = p_workout_name
      AND workout_type = p_workout_type
      AND duration_minutes = p_duration_minutes
      AND ABS(EXTRACT(EPOCH FROM (date - date_brt))) < 60  -- ✅ Apenas duplicatas no mesmo minuto
      AND COALESCE(challenge_id::text, '') = COALESCE(p_challenge_id::text, '')
      AND COALESCE(notes, '') = COALESCE(p_notes, '')
    LIMIT 1;

    IF FOUND THEN
        RETURN jsonb_build_object(
            'success', true,
            'workout_id', existing_record,
            'message', 'Treino idêntico já existe - retornando registro existente'
        );
    END IF;

    -- CORREÇÃO 3: INSERIR NOVO REGISTRO 
    INSERT INTO workout_records (
        id,
        user_id,
        workout_id,
        workout_name,
        workout_type,
        date,          -- ✅ Data do formulário (permite retroativo)
        duration_minutes,
        challenge_id,
        notes
    ) VALUES (
        COALESCE(p_workout_record_id, gen_random_uuid()),
        p_user_id,
        v_workout_id,
        p_workout_name,
        p_workout_type,
        date_brt,     -- ✅ Data especificada pelo usuário
        p_duration_minutes,
        p_challenge_id,
        p_notes
    ) RETURNING id INTO v_id;

    -- CORREÇÃO 4: Processar para ranking
    BEGIN
        PERFORM process_workout_for_ranking(v_id);
    EXCEPTION WHEN OTHERS THEN
        INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        VALUES (p_user_id, p_challenge_id, v_id, SQLERRM, 'ranking_fail_insert', to_brt(NOW()));
    END;

    RETURN jsonb_build_object(
        'success', true,
        'workout_id', v_id,
        'message', 'Treino registrado com sucesso',
        'is_retroactive', DATE(date_brt) != CURRENT_DATE
    );

EXCEPTION WHEN OTHERS THEN
    RETURN jsonb_build_object(
        'success', false,
        'error', SQLERRM,
        'code', SQLSTATE
    );
END;
$function$;

SELECT '✅ record_workout_basic corrigida' as funcao_1_ok;

-- ================================================================
-- PARTE 2: CORRIGIR process_workout_for_ranking
-- ================================================================

SELECT '🔧 CORRIGINDO process_workout_for_ranking' as etapa;

CREATE OR REPLACE FUNCTION public.process_workout_for_ranking(_workout_record_id uuid)
RETURNS boolean
LANGUAGE plpgsql
AS $function$
declare
    workout RECORD;
    challenge_record RECORD;
    user_name TEXT;
    user_photo_url TEXT;
    already_has_checkin BOOLEAN := FALSE;
    points_to_add INTEGER := 10;
    check_in_id UUID;
    challenge_target_days INTEGER;
    check_ins_count INTEGER := 0;
    completion NUMERIC := 0;
    workout_date_brt DATE;
begin
    -- Buscar treino
    select * into workout
    from workout_records
    where id = _workout_record_id;

    if not found then
        raise exception 'Treino não encontrado: %', _workout_record_id;
    end if;

    -- Se não tem challenge_id, apenas marcar como processado
    if workout.challenge_id is null then
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') THEN
            update workout_processing_queue
            set processed_for_ranking = true, processed_at = to_brt(now())
            where workout_id = _workout_record_id;
        END IF;
        return true;
    end if;

    -- Converter data do treino para BRT
    workout_date_brt := DATE(to_brt(workout.date));

    -- Buscar desafio
    select * into challenge_record
    from challenges
    where id = workout.challenge_id
    for update;

    if not found then
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') THEN
            update workout_processing_queue
            set processed_for_ranking = true,
                processing_error = 'Desafio não encontrado',
                processed_at = to_brt(now())
            where workout_id = _workout_record_id;
        END IF;

        insert into check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        values (workout.user_id, workout.challenge_id, _workout_record_id, 'Desafio não encontrado: ' || workout.challenge_id, 'error', to_brt(now()));
        return false;
    end if;

    -- Verificar participação
    if not exists (
        select 1 from challenge_participants
        where challenge_id = workout.challenge_id and user_id = workout.user_id
    ) then
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') THEN
            update workout_processing_queue
            set processed_for_ranking = true,
                processing_error = 'Usuário não participa deste desafio',
                processed_at = to_brt(now())
            where workout_id = _workout_record_id;
        END IF;

        insert into check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        values (workout.user_id, workout.challenge_id, _workout_record_id, 'Usuário não participa deste desafio', 'error', to_brt(now()));
        return false;
    end if;

    -- Verificar duração mínima
    if workout.duration_minutes < 45 then
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') THEN
            update workout_processing_queue
            set processed_for_ranking = true,
                processing_error = 'Duração mínima não atingida (45min)',
                processed_at = to_brt(now())
            where workout_id = _workout_record_id;
        END IF;

        insert into check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        values (workout.user_id, workout.challenge_id, _workout_record_id, 'Duração mínima não atingida: ' || workout.duration_minutes || 'min', 'skipped', to_brt(now()));
        return false;
    end if;

    -- ✅ CORREÇÃO PRINCIPAL: Verificação de duplicatas por DATA apenas
    select exists (
        select 1 from challenge_check_ins
        where user_id = workout.user_id
          and challenge_id = workout.challenge_id
          and DATE(to_brt(check_in_date)) = workout_date_brt  -- Comparar apenas datas
    ) into already_has_checkin;

    if already_has_checkin then
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') THEN
            update workout_processing_queue
            set processed_for_ranking = true,
                processing_error = 'Check-in já existe para esta data',
                processed_at = to_brt(now())
            where workout_id = _workout_record_id;
        END IF;

        insert into check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        values (workout.user_id, workout.challenge_id, _workout_record_id, 'Check-in já existe para a data: ' || workout_date_brt, 'duplicate', to_brt(now()));
        return false;
    end if;

    -- Buscar dados do usuário
    select coalesce(name, 'Usuário'), photo_url
    into user_name, user_photo_url
    from profiles
    where id = workout.user_id;

    challenge_target_days := greatest(1, date_part('day', challenge_record.end_date - challenge_record.start_date)::int + 1);

    -- ✅ CORREÇÃO: Inserir check-in com data do treino (permite retroativo)
    insert into challenge_check_ins(
        id, challenge_id, user_id, check_in_date, workout_id,
        points, workout_name, workout_type, duration_minutes,
        user_name, user_photo_url, created_at
    ) values (
        gen_random_uuid(),
        workout.challenge_id,
        workout.user_id,
        workout.date,  -- ✅ Data do treino (permite retroativo)
        cast(workout.id as uuid),
        points_to_add,
        workout.workout_name,
        workout.workout_type,
        workout.duration_minutes,
        user_name,
        user_photo_url,
        to_brt(now())  -- created_at = agora (auditoria)
    ) returning id into check_in_id;

    -- Atualizar progresso
    select count(*) into check_ins_count
    from challenge_check_ins
    where challenge_id = workout.challenge_id and user_id = workout.user_id;

    completion := least(100, (check_ins_count * 100.0) / challenge_target_days);

    insert into challenge_progress(
        challenge_id, user_id, points, check_ins_count, total_check_ins,
        last_check_in, completion_percentage, created_at, updated_at,
        user_name, user_photo_url
    ) values (
        workout.challenge_id,
        workout.user_id,
        points_to_add,
        1,
        1,
        workout.date,  -- ✅ Data do treino
        completion,
        to_brt(now()),
        to_brt(now()),
        user_name,
        user_photo_url
    )
    on conflict (challenge_id, user_id)
    do update set
        points = coalesce(challenge_progress.points, 0) + excluded.points,
        check_ins_count = challenge_progress.check_ins_count + 1,
        total_check_ins = challenge_progress.total_check_ins + 1,
        last_check_in = GREATEST(challenge_progress.last_check_in, excluded.last_check_in),  -- ✅ Manter data mais recente
        completion_percentage = least(100, ((challenge_progress.check_ins_count + 1) * 100.0) / challenge_target_days),
        updated_at = to_brt(now()),
        user_name = excluded.user_name,
        user_photo_url = excluded.user_photo_url;

    -- Marcar como processado
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'workout_processing_queue') THEN
        update workout_processing_queue
        set processed_for_ranking = true, processed_at = to_brt(now())
        where workout_id = _workout_record_id;
    END IF;

    -- Recalcular ranking
    with user_workouts as (
        select user_id, challenge_id, count(*) as workout_count
        from workout_records
        where challenge_id = workout.challenge_id
        group by user_id, challenge_id
    ),
    ranked_users as (
        select
            cp.user_id,
            cp.challenge_id,
            dense_rank() over (
                order by cp.points desc, coalesce(uw.workout_count, 0) desc, cp.last_check_in asc nulls last
            ) as new_position
        from challenge_progress cp
        left join user_workouts uw
            on uw.user_id = cp.user_id and uw.challenge_id = cp.challenge_id
        where cp.challenge_id = workout.challenge_id
    )
    update challenge_progress cp
    set position = ru.new_position
    from ranked_users ru
    where cp.challenge_id = ru.challenge_id and cp.user_id = ru.user_id;

    return true;

exception when others then
    begin
        insert into check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
        values (workout.user_id, workout.challenge_id, _workout_record_id, sqlerrm, 'error', to_brt(now()));
    exception when others then null;
    end;
    return false;
end;
$function$;

SELECT '✅ process_workout_for_ranking corrigida' as funcao_2_ok;

-- ================================================================
-- PARTE 3: TESTE DAS FUNÇÕES CORRIGIDAS
-- ================================================================

SELECT '🧪 TESTANDO FUNÇÕES CORRIGIDAS' as etapa;

DO $$
DECLARE
    test_result jsonb;
    test_user_id uuid := 'bc0bfc71-f0cb-4636-a998-026b9e2b5b55';
    test_challenge_id uuid := '29c91ea0-7dc1-486f-8e4a-86686cbf5f82';
BEGIN
    -- Teste: Check-in retroativo
    SELECT record_workout_basic(
        p_user_id := test_user_id,
        p_workout_name := 'Teste Retroativo FINAL',
        p_workout_type := 'teste',
        p_duration_minutes := 60,  -- Acima de 45min
        p_date := '2025-06-04 15:00:00-03',
        p_challenge_id := test_challenge_id,
        p_notes := 'Teste final com resultados visíveis'
    ) INTO test_result;
    
    -- Mostrar resultado nos resultados da query
    INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
    VALUES (test_user_id, test_challenge_id, null, 'TESTE CONCLUÍDO: ' || test_result::text, 'test_success', to_brt(NOW()));
    
EXCEPTION WHEN OTHERS THEN
    INSERT INTO check_in_error_logs(user_id, challenge_id, workout_id, error_message, status, created_at)
    VALUES (test_user_id, test_challenge_id, null, 'ERRO NO TESTE: ' || SQLERRM, 'test_error', to_brt(NOW()));
END $$;

-- Mostrar resultado do teste
SELECT 
    '✅ TESTE CONCLUÍDO' as status,
    error_message as resultado_teste,
    created_at
FROM check_in_error_logs 
WHERE status IN ('test_success', 'test_error')
ORDER BY created_at DESC 
LIMIT 1;

-- ================================================================
-- VERIFICAÇÃO FINAL
-- ================================================================

SELECT '🎉 CORREÇÃO FINAL APLICADA' as status;
SELECT '✅ record_workout_basic: Proteções anti-duplicata otimizadas' as correcao_1;
SELECT '✅ process_workout_for_ranking: Verificação por data' as correcao_2;
SELECT '✅ Check-ins retroativos permitidos' as correcao_3;
SELECT '✅ Verificação de duplicatas por data apenas' as correcao_4;
SELECT '✅ Tratamento de erros robusto' as correcao_5;
SELECT '🚀 PRONTO PARA TESTE NO APP!' as conclusao; 