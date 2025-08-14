-- Ray Club — Cardio Ranking RPC
-- Cria função para obter ranking por minutos de cardio agregados

create or replace function public.get_cardio_ranking(
    date_from timestamptz default null,
    date_to   timestamptz default null,
    _limit    integer     default null,
    _offset   integer     default null
)
returns table (
    user_id uuid,
    full_name text,
    avatar_url text,
    total_cardio_minutes integer
)
language sql
stable
as $$
    with bounds as (
      select
        case when date_from is null then null
             else ((date_from at time zone 'America/Sao_Paulo') at time zone 'UTC') end as from_utc,
        case when date_to   is null then null
             else ((date_to   at time zone 'America/Sao_Paulo') at time zone 'UTC') end as to_utc,
        coalesce(_limit, 200)  as lim,
        coalesce(_offset, 0)   as off
    )
    select
        wr.user_id,
        p.name as full_name,
        coalesce(p.photo_url, p.profile_image_url) as avatar_url,
        sum(wr.duration_minutes)::int as total_cardio_minutes
    from public.workout_records wr
    join public.profiles p on p.id = wr.user_id
    join public.cardio_challenge_participants ccp on ccp.user_id = wr.user_id and ccp.active = true
    cross join bounds b
    where
        wr.duration_minutes is not null
        and wr.duration_minutes > 0
        and (lower(wr.workout_type) = 'cardio' or wr.workout_type = 'Cardio')
        and (b.from_utc is null or wr.date >= b.from_utc)
        and (b.to_utc   is null or wr.date <  b.to_utc)
    group by wr.user_id, p.name, coalesce(p.photo_url, p.profile_image_url)
    having sum(wr.duration_minutes) > 0
    order by total_cardio_minutes desc, p.name asc, wr.user_id asc
    limit (select lim from bounds)
    offset (select off from bounds);
$$;

-- Índices recomendados (execute se necessário):
-- create index if not exists idx_wr_type_date on public.workout_records ((lower(workout_type)), date);
-- create index if not exists idx_wr_user on public.workout_records (user_id);

-- Opção (avaliar RLS/segurança antes de ativar):
-- alter function public.get_cardio_ranking(timestamptz, timestamptz) owner to postgres;
-- revoke all on function public.get_cardio_ranking(timestamptz, timestamptz) from public;
-- grant execute on function public.get_cardio_ranking(timestamptz, timestamptz) to authenticated;
-- alter function public.get_cardio_ranking(timestamptz, timestamptz)
--   security definer set search_path = public;


