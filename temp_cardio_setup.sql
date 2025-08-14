-- Ray Club — Cardio Challenge Participation

-- Tabela de participação (opt-in)
create table if not exists public.cardio_challenge_participants (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  joined_at timestamptz not null default now(),
  active boolean not null default true
);

-- Índice
create index if not exists idx_ccp_active on public.cardio_challenge_participants(active);

-- RLS
alter table public.cardio_challenge_participants enable row level security;

-- Políticas mínimas (usuário gerencia sua própria inscrição)
do $$ begin
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='cardio_challenge_participants' and policyname='ccp_select_own'
  ) then
    create policy ccp_select_own on public.cardio_challenge_participants
      for select using (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='cardio_challenge_participants' and policyname='ccp_upsert_own'
  ) then
    create policy ccp_upsert_own on public.cardio_challenge_participants
      for insert with check (auth.uid() = user_id);
  end if;
  if not exists (
    select 1 from pg_policies where schemaname='public' and tablename='cardio_challenge_participants' and policyname='ccp_update_own'
  ) then
    create policy ccp_update_own on public.cardio_challenge_participants
      for update using (auth.uid() = user_id);
  end if;
end $$;

-- RPC: entrar no desafio (opt-in)
create or replace function public.join_cardio_challenge(p_user_id uuid default auth.uid())
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.cardio_challenge_participants(user_id, joined_at, active)
  values (p_user_id, now(), true)
  on conflict (user_id) do update set active = true, joined_at = excluded.joined_at;
end; $$;

revoke all on function public.join_cardio_challenge(uuid) from public;
grant execute on function public.join_cardio_challenge(uuid) to authenticated;

-- RPC: sair do desafio (opt-out)
create or replace function public.leave_cardio_challenge(p_user_id uuid default auth.uid())
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.cardio_challenge_participants
    set active = false
  where user_id = p_user_id;
end; $$;

revoke all on function public.leave_cardio_challenge(uuid) from public;
grant execute on function public.leave_cardio_challenge(uuid) to authenticated;

-- RPC: obter participação
create or replace function public.get_cardio_participation(p_user_id uuid default auth.uid())
returns table (
  is_participant boolean,
  joined_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(c.active, false) as is_participant, c.joined_at
  from public.profiles p
  left join public.cardio_challenge_participants c on c.user_id = p_user_id and c.active = true
  where p.id = p_user_id;
$$;

revoke all on function public.get_cardio_participation(uuid) from public;
grant execute on function public.get_cardio_participation(uuid) to authenticated;


-- Ray Club — Cardio Ranking RPC
-- Cria função para obter ranking por minutos de cardio agregados

create or replace function public.get_cardio_ranking(
    date_from timestamptz default null,
    date_to   timestamptz default null,
    _limit    integer     default null,
    _offset   integer     default null
)
returns table (
    user_id, uuid,
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
        and lower(wr.workout_type) = 'cardio'
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


