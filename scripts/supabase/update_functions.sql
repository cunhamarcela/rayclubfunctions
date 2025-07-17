-- Script para atualizar ou criar funções necessárias para o backend do Ray Club App
-- Execute este script no SQL Editor do Supabase

-- Remover funções existentes para evitar erros de alteração de parâmetros
DROP FUNCTION IF EXISTS get_current_streak(uuid, uuid);
DROP FUNCTION IF EXISTS calculate_user_ranking();
DROP FUNCTION IF EXISTS get_user_challenge_stats(uuid);
DROP FUNCTION IF EXISTS calculate_total_user_progress(uuid);
DROP FUNCTION IF EXISTS search_challenges(text, text, text, text, text, integer, integer);
DROP FUNCTION IF EXISTS get_group_ranking(uuid);
DROP FUNCTION IF EXISTS has_checked_in_today(uuid, uuid);
DROP FUNCTION IF EXISTS create_challenge_group(text, text, uuid, uuid);
DROP FUNCTION IF EXISTS add_member_to_group(uuid, uuid);
DROP FUNCTION IF EXISTS remove_member_from_group(uuid, uuid);

-- Função para calcular o streak atual (sequência consecutiva) de check-ins do usuário num desafio
CREATE OR REPLACE FUNCTION get_current_streak(user_id_param uuid, challenge_id_param uuid)
RETURNS integer AS $$
DECLARE
    streak integer := 0;
    last_date date := NULL;
    current_date date := CURRENT_DATE;
    check_date date;
    dates_array date[];
    i integer;
BEGIN
    -- Coletar todas as datas de check-in do usuário para o desafio específico
    SELECT ARRAY_AGG(check_in_date::date ORDER BY check_in_date DESC)
    INTO dates_array
    FROM challenge_check_ins
    WHERE user_id = user_id_param AND challenge_id = challenge_id_param;
    
    -- Se não houver check-ins, retornar 0
    IF dates_array IS NULL THEN
        RETURN 0;
    END IF;
    
    -- Verificar se o último check-in foi hoje ou ontem (para manter o streak)
    IF dates_array[1] = current_date OR dates_array[1] = current_date - 1 THEN
        -- Começar a contar o streak
        streak := 1;
        last_date := dates_array[1];
        
        -- Percorrer o array de datas para contar dias consecutivos
        FOR i IN 2..array_length(dates_array, 1) LOOP
            -- Se a diferença for exatamente 1 dia, incrementar o streak
            IF last_date - dates_array[i] = 1 THEN
                streak := streak + 1;
                last_date := dates_array[i];
            -- Se for o mesmo dia, ignorar (múltiplos check-ins no mesmo dia)
            ELSIF last_date = dates_array[i] THEN
                CONTINUE;
            -- Se a sequência for quebrada, parar
            ELSE
                EXIT;
            END IF;
        END LOOP;
        
        RETURN streak;
    ELSE
        -- Se o último check-in foi há mais de 1 dia, o streak foi perdido
        RETURN 0;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Função para calcular ranking de usuários com base em pontos
CREATE OR REPLACE FUNCTION calculate_user_ranking()
RETURNS TABLE (
    user_id uuid,
    username text,
    photo_url text,
    points integer,
    ranking integer
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        up.user_id,
        p.full_name AS username,
        p.avatar_url AS photo_url,
        up.points,
        RANK() OVER (ORDER BY up.points DESC) AS ranking
    FROM 
        user_progress up
    LEFT JOIN 
        profiles p ON p.id = up.user_id
    ORDER BY 
        ranking;
END;
$$ LANGUAGE plpgsql;

-- Função para obter estatísticas de desafio para um usuário específico
CREATE OR REPLACE FUNCTION get_user_challenge_stats(user_id_param uuid)
RETURNS TABLE (
    total_challenges integer,
    completed_challenges integer,
    in_progress_challenges integer,
    total_points integer,
    highest_streak integer
) AS $$
DECLARE
    total integer;
    completed integer;
    in_progress integer;
    points integer;
    max_streak integer;
BEGIN
    -- Total de desafios em que o usuário está participando
    SELECT COUNT(*) INTO total
    FROM challenge_participants
    WHERE user_id = user_id_param;
    
    -- Desafios completados
    SELECT COUNT(*) INTO completed
    FROM challenge_participants
    WHERE user_id = user_id_param AND status = 'completed';
    
    -- Desafios em andamento
    SELECT COUNT(*) INTO in_progress
    FROM challenge_participants
    WHERE user_id = user_id_param AND status = 'active';
    
    -- Total de pontos acumulados
    SELECT COALESCE(SUM(points), 0) INTO points
    FROM challenge_progress
    WHERE user_id = user_id_param;
    
    -- Maior streak
    SELECT COALESCE(MAX(consecutive_days), 0) INTO max_streak
    FROM challenge_progress
    WHERE user_id = user_id_param;
    
    RETURN QUERY SELECT total, completed, in_progress, points, max_streak;
END;
$$ LANGUAGE plpgsql;

-- Função para calcular o progresso total do usuário
CREATE OR REPLACE FUNCTION calculate_total_user_progress(user_id_param uuid)
RETURNS jsonb AS $$
DECLARE
    result jsonb;
BEGIN
    SELECT 
        jsonb_build_object(
            'total_points', up.points,
            'challenges_completed', up.challenges_completed,
            'workouts_completed', up.workouts_completed,
            'highest_streak', COALESCE(MAX(cp.consecutive_days), 0),
            'total_challenges', COUNT(DISTINCT cp.challenge_id),
            'total_check_ins', COUNT(cci.id),
            'total_water_intake', COALESCE((SELECT SUM(amount) FROM water_intake WHERE user_id = user_id_param), 0),
            'badges', (SELECT COUNT(*) FROM badges WHERE user_id = user_id_param),
            'ranking', (SELECT ranking FROM calculate_user_ranking() WHERE user_id = user_id_param LIMIT 1)
        ) INTO result
    FROM 
        user_progress up
    LEFT JOIN 
        challenge_progress cp ON cp.user_id = up.user_id
    LEFT JOIN 
        challenge_check_ins cci ON cci.user_id = up.user_id
    WHERE 
        up.user_id = user_id_param
    GROUP BY
        up.points, up.challenges_completed, up.workouts_completed;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Função para pesquisa de desafios com filtros
CREATE OR REPLACE FUNCTION search_challenges(
    search_term text DEFAULT NULL,
    category_filter text DEFAULT NULL,
    status_filter text DEFAULT NULL,
    sort_by text DEFAULT 'created_at',
    sort_order text DEFAULT 'desc',
    limit_param integer DEFAULT 20,
    offset_param integer DEFAULT 0
)
RETURNS TABLE (
    id uuid,
    title text,
    description text,
    image_url text,
    category text,
    difficulty text,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    requirements jsonb,
    participants integer,
    status text,
    created_at timestamp with time zone
) AS $$
DECLARE
    query_text text;
    where_clause text := '';
    order_clause text;
BEGIN
    -- Construir cláusula WHERE com base nos filtros
    IF search_term IS NOT NULL AND search_term <> '' THEN
        where_clause := where_clause || ' AND (title ILIKE ''%' || search_term || '%'' OR description ILIKE ''%' || search_term || '%'')';
    END IF;
    
    IF category_filter IS NOT NULL AND category_filter <> '' THEN
        where_clause := where_clause || ' AND category = ''' || category_filter || '''';
    END IF;
    
    IF status_filter IS NOT NULL AND status_filter <> '' THEN
        where_clause := where_clause || ' AND status = ''' || status_filter || '''';
    END IF;
    
    -- Construir cláusula ORDER BY
    order_clause := ' ORDER BY ' || sort_by || ' ' || sort_order;
    
    -- Construir e executar a query completa
    query_text := '
        SELECT 
            id, title, description, image_url, category, difficulty,
            start_date, end_date, requirements, participants, status, created_at
        FROM 
            challenges
        WHERE 
            1=1' || where_clause || order_clause || '
        LIMIT ' || limit_param || ' OFFSET ' || offset_param;
    
    RETURN QUERY EXECUTE query_text;
END;
$$ LANGUAGE plpgsql;

-- Função para obter o ranking de um grupo específico
CREATE OR REPLACE FUNCTION get_group_ranking(group_id_param uuid)
RETURNS TABLE (
    id uuid,
    user_id uuid,
    username text,
    photo_url text,
    challenge_id uuid,
    points integer,
    consecutive_days integer,
    total_check_ins integer,
    last_check_in timestamp with time zone,
    ranking integer
) AS $$
DECLARE
    challenge_id_var uuid;
    member_ids uuid[];
BEGIN
    -- Obter o challenge_id e os membros do grupo
    SELECT challenge_id, member_ids INTO challenge_id_var, member_ids
    FROM challenge_groups
    WHERE id = group_id_param;
    
    IF challenge_id_var IS NULL THEN
        RAISE EXCEPTION 'Grupo não encontrado ou sem desafio associado';
    END IF;
    
    -- Retornar ranking apenas dos membros do grupo
    RETURN QUERY
    SELECT 
        cp.id,
        cp.user_id,
        p.full_name AS username,
        p.avatar_url AS photo_url,
        cp.challenge_id,
        cp.points,
        cp.consecutive_days,
        cp.total_check_ins,
        cp.last_check_in,
        RANK() OVER (ORDER BY cp.points DESC) AS ranking
    FROM 
        challenge_progress cp
    LEFT JOIN 
        profiles p ON p.id = cp.user_id
    WHERE 
        cp.challenge_id = challenge_id_var
        AND cp.user_id = ANY(member_ids)
    ORDER BY 
        ranking;
END;
$$ LANGUAGE plpgsql;

-- Função para verificar se um usuário fez check-in hoje para um desafio específico
CREATE OR REPLACE FUNCTION has_checked_in_today(
    _user_id uuid,
    _challenge_id uuid
)
RETURNS boolean AS $$
DECLARE
    check_in_exists boolean;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM challenge_check_ins
        WHERE user_id = _user_id
        AND challenge_id = _challenge_id
        AND check_in_date::date = CURRENT_DATE
    ) INTO check_in_exists;
    
    RETURN check_in_exists;
END;
$$ LANGUAGE plpgsql;

-- Função para criar um novo grupo de desafio
CREATE OR REPLACE FUNCTION create_challenge_group(
    _name text,
    _description text,
    _creator_id uuid,
    _challenge_id uuid
)
RETURNS uuid AS $$
DECLARE
    new_group_id uuid;
BEGIN
    INSERT INTO challenge_groups (
        name,
        description,
        creator_id,
        challenge_id,
        member_ids,
        created_at,
        updated_at
    ) VALUES (
        _name,
        _description,
        _creator_id,
        _challenge_id,
        ARRAY[_creator_id], -- Criador é automaticamente o primeiro membro
        NOW(),
        NOW()
    ) RETURNING id INTO new_group_id;
    
    RETURN new_group_id;
END;
$$ LANGUAGE plpgsql;

-- Função para adicionar um membro a um grupo
CREATE OR REPLACE FUNCTION add_member_to_group(
    _group_id uuid,
    _user_id uuid
)
RETURNS boolean AS $$
DECLARE
    success boolean := false;
BEGIN
    -- Verifica se o usuário já é membro do grupo
    IF NOT EXISTS (
        SELECT 1 FROM challenge_groups
        WHERE id = _group_id
        AND _user_id = ANY(member_ids)
    ) THEN
        -- Adiciona o usuário ao array de membros
        UPDATE challenge_groups
        SET member_ids = array_append(member_ids, _user_id),
            updated_at = NOW()
        WHERE id = _group_id;
        
        success := true;
    END IF;
    
    RETURN success;
END;
$$ LANGUAGE plpgsql;

-- Função para remover um membro de um grupo
CREATE OR REPLACE FUNCTION remove_member_from_group(
    _group_id uuid,
    _user_id uuid
)
RETURNS boolean AS $$
DECLARE
    success boolean := false;
    creator_id_var uuid;
BEGIN
    -- Obter o ID do criador do grupo
    SELECT creator_id INTO creator_id_var
    FROM challenge_groups
    WHERE id = _group_id;
    
    -- Não permitir remover o criador do grupo
    IF _user_id = creator_id_var THEN
        RAISE EXCEPTION 'O criador do grupo não pode ser removido';
    END IF;
    
    -- Remove o usuário do array de membros
    UPDATE challenge_groups
    SET member_ids = array_remove(member_ids, _user_id),
        updated_at = NOW()
    WHERE id = _group_id
    AND _user_id = ANY(member_ids);
    
    IF FOUND THEN
        success := true;
    END IF;
    
    RETURN success;
END;
$$ LANGUAGE plpgsql; 