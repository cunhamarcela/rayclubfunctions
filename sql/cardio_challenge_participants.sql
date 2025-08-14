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


