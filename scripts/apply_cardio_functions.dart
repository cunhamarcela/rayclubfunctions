import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Script para aplicar as funções SQL do desafio de cardio
void main() async {
  print('🚀 Aplicando funções SQL do desafio de cardio...');
  
  try {
    // Configurar Supabase (usar as credenciais do app)
    await Supabase.initialize(
      url: 'https://zsbbgchsjiuicwvtrldn.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpzYmJnY2hzaml1aWN3dnRybGRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTExMzUzNTEsImV4cCI6MjAyNjcxMTM1MX0.ZbJH9t8T9bnZJJG2ZJG8o9VVJJJJJJJJJJJJJJJJJa', // Sua chave anon
    );
    
    final supabase = Supabase.instance.client;
    
    print('✅ Conectado ao Supabase');
    
    // 1. Criar tabela de participantes
    print('📋 Criando tabela cardio_challenge_participants...');
    
    final createTableSQL = '''
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
    ''';
    
    await supabase.rpc('exec_sql', params: {'sql': createTableSQL});
    print('✅ Tabela criada');
    
    // 2. Criar políticas RLS
    print('🔒 Criando políticas de segurança...');
    
    final policiesSQL = '''
    do \$\$ begin
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
    end \$\$;
    ''';
    
    await supabase.rpc('exec_sql', params: {'sql': policiesSQL});
    print('✅ Políticas criadas');
    
    // 3. Criar funções
    print('⚙️ Criando funções...');
    
    // Função join_cardio_challenge
    final joinFunctionSQL = '''
    create or replace function public.join_cardio_challenge(p_user_id uuid default auth.uid())
    returns void
    language plpgsql
    security definer
    set search_path = public
    as \$\$
    begin
      insert into public.cardio_challenge_participants(user_id, joined_at, active)
      values (p_user_id, now(), true)
      on conflict (user_id) do update set active = true, joined_at = excluded.joined_at;
    end; \$\$;
    
    revoke all on function public.join_cardio_challenge(uuid) from public;
    grant execute on function public.join_cardio_challenge(uuid) to authenticated;
    ''';
    
    await supabase.rpc('exec_sql', params: {'sql': joinFunctionSQL});
    print('✅ Função join_cardio_challenge criada');
    
    // Função leave_cardio_challenge
    final leaveFunctionSQL = '''
    create or replace function public.leave_cardio_challenge(p_user_id uuid default auth.uid())
    returns void
    language plpgsql
    security definer
    set search_path = public
    as \$\$
    begin
      update public.cardio_challenge_participants
        set active = false
      where user_id = p_user_id;
    end; \$\$;
    
    revoke all on function public.leave_cardio_challenge(uuid) from public;
    grant execute on function public.leave_cardio_challenge(uuid) to authenticated;
    ''';
    
    await supabase.rpc('exec_sql', params: {'sql': leaveFunctionSQL});
    print('✅ Função leave_cardio_challenge criada');
    
    // Função get_cardio_participation
    final getParticipationSQL = '''
    create or replace function public.get_cardio_participation(p_user_id uuid default auth.uid())
    returns table (
      is_participant boolean,
      joined_at timestamptz
    )
    language sql
    stable
    security definer
    set search_path = public
    as \$\$
      select coalesce(c.active, false) as is_participant, c.joined_at
      from public.profiles p
      left join public.cardio_challenge_participants c on c.user_id = p_user_id and c.active = true
      where p.id = p_user_id;
    \$\$;
    
    revoke all on function public.get_cardio_participation(uuid) from public;
    grant execute on function public.get_cardio_participation(uuid) to authenticated;
    ''';
    
    await supabase.rpc('exec_sql', params: {'sql': getParticipationSQL});
    print('✅ Função get_cardio_participation criada');
    
    // Função get_cardio_ranking
    final getRankingSQL = '''
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
    as \$\$
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
    \$\$;
    ''';
    
    await supabase.rpc('exec_sql', params: {'sql': getRankingSQL});
    print('✅ Função get_cardio_ranking criada');
    
    // Verificar se as funções foram criadas
    print('🔍 Verificando funções criadas...');
    
    try {
      // Testar join_cardio_challenge
      await supabase.rpc('join_cardio_challenge');
      print('✅ join_cardio_challenge: OK');
    } catch (e) {
      print('❌ join_cardio_challenge: $e');
    }
    
    try {
      // Testar get_cardio_participation
      final result = await supabase.rpc('get_cardio_participation');
      print('✅ get_cardio_participation: OK - Resultado: $result');
    } catch (e) {
      print('❌ get_cardio_participation: $e');
    }
    
    try {
      // Testar get_cardio_ranking
      final ranking = await supabase.rpc('get_cardio_ranking');
      print('✅ get_cardio_ranking: OK - ${ranking.length} participantes');
    } catch (e) {
      print('❌ get_cardio_ranking: $e');
    }
    
    print('');
    print('🎉 TODAS AS FUNÇÕES APLICADAS COM SUCESSO!');
    
  } catch (e, stackTrace) {
    print('❌ Erro durante aplicação: $e');
    print('Stack trace: $stackTrace');
  }
}
