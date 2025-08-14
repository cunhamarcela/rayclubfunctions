-- Ray Club — Correção da função get_cardio_ranking
-- Filtra treinos apenas após a data de entrada no desafio para consistência

-- 1. Remover função existente
DROP FUNCTION IF EXISTS public.get_cardio_ranking(timestamptz, timestamptz, integer, integer);

-- 2. Criar função corrigida que considera data de entrada no desafio
CREATE OR REPLACE FUNCTION public.get_cardio_ranking(
    date_from timestamptz DEFAULT NULL,
    date_to   timestamptz DEFAULT NULL,
    _limit    integer     DEFAULT NULL,
    _offset   integer     DEFAULT NULL
)
RETURNS TABLE (
    user_id uuid,
    full_name text,
    avatar_url text,
    total_cardio_minutes integer
)
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    WITH bounds AS (
      SELECT
        CASE WHEN date_from IS NULL THEN NULL
             ELSE ((date_from AT TIME ZONE 'America/Sao_Paulo') AT TIME ZONE 'UTC') END AS from_utc,
        CASE WHEN date_to   IS NULL THEN NULL
             ELSE ((date_to   AT TIME ZONE 'America/Sao_Paulo') AT TIME ZONE 'UTC') END AS to_utc,
        COALESCE(_limit, 200)  AS lim,
        COALESCE(_offset, 0)   AS off
    )
    SELECT
        wr.user_id,
        p.name AS full_name,
        COALESCE(p.photo_url, p.profile_image_url) AS avatar_url,
        SUM(wr.duration_minutes)::int AS total_cardio_minutes
    FROM public.workout_records wr
    JOIN public.profiles p ON p.id = wr.user_id
    JOIN public.cardio_challenge_participants ccp ON ccp.user_id = wr.user_id AND ccp.active = true
    CROSS JOIN bounds b
    WHERE
        wr.duration_minutes IS NOT NULL
        AND wr.duration_minutes > 0
        AND (LOWER(wr.workout_type) = 'cardio' OR wr.workout_type = 'Cardio')
        -- NOVA CONDIÇÃO: Apenas treinos após entrada no desafio
        AND wr.date >= ccp.joined_at
        -- Filtros de período (se especificados)
        AND (b.from_utc IS NULL OR wr.date >= b.from_utc)
        AND (b.to_utc   IS NULL OR wr.date <  b.to_utc)
    GROUP BY wr.user_id, p.name, COALESCE(p.photo_url, p.profile_image_url)
    HAVING SUM(wr.duration_minutes) > 0
    ORDER BY total_cardio_minutes DESC, p.name ASC, wr.user_id ASC
    LIMIT (SELECT lim FROM bounds)
    OFFSET (SELECT off FROM bounds);
$$;

-- 3. Configurar permissões
REVOKE ALL ON FUNCTION public.get_cardio_ranking(timestamptz, timestamptz, integer, integer) FROM public;
GRANT EXECUTE ON FUNCTION public.get_cardio_ranking(timestamptz, timestamptz, integer, integer) TO authenticated;

-- 4. Testar função corrigida
SELECT 'Resultado após correção:' as info;
SELECT user_id, full_name, total_cardio_minutes FROM public.get_cardio_ranking();

-- 5. Verificar dados de participação para debug
SELECT 'Participantes e suas datas de entrada:' as info;
SELECT user_id, joined_at, active FROM public.cardio_challenge_participants ORDER BY joined_at DESC;

