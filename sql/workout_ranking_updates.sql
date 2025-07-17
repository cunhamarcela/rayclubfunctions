-- Função para recalcular o progresso de um usuário em um desafio específico
create or replace function recalculate_challenge_progress(p_user_id uuid, p_challenge_id uuid)
returns void as $$
declare
  total_points int;
  total_check_ins int;
  last_check_in timestamp;
begin
  -- Calcula os totais baseados nos workout_records
  select
    coalesce(sum(points), 0),
    count(*),
    max(date)
  into total_points, total_check_ins, last_check_in
  from workout_records
  where user_id = p_user_id
    and challenge_id = p_challenge_id
    and points > 0;

  -- Atualiza a tabela challenge_progress
  update challenge_progress
  set
    points = total_points,
    check_ins_count = total_check_ins,
    last_check_in = last_check_in,
    last_updated = now()
  where user_id = p_user_id and challenge_id = p_challenge_id;
  
  -- Insere o registro se não existir
  if not found then
    insert into challenge_progress (
      id, 
      challenge_id, 
      user_id, 
      points, 
      check_ins_count, 
      last_check_in, 
      last_updated,
      created_at
    )
    values (
      uuid_generate_v4(),
      p_challenge_id,
      p_user_id,
      total_points,
      total_check_ins,
      last_check_in,
      now(),
      now()
    );
  end if;
end;
$$ language plpgsql;

-- Trigger para atualizar challenge_progress quando workout_records for alterado
create or replace function trg_reprocess_challenge_progress()
returns trigger as $$
begin
  -- Se for delete, usa valores da linha excluída
  if (TG_OP = 'DELETE') then
    perform recalculate_challenge_progress(old.user_id, old.challenge_id);
    return old;
  else
    -- Se for update, utiliza valores da nova linha
    perform recalculate_challenge_progress(new.user_id, new.challenge_id);
    return new;
  end if;
end;
$$ language plpgsql;

-- Remove o trigger se já existir
drop trigger if exists trg_update_progress_after_workout_edit on workout_records;

-- Cria o trigger para atualizar o progresso após edição ou exclusão de treino
create trigger trg_update_progress_after_workout_edit
after update or delete on workout_records
for each row
when (old.challenge_id is not null)
execute function trg_reprocess_challenge_progress();

-- Adicionar uma função exposta via RPC para recalcular manualmente
create or replace function public.recalculate_challenge_progress(
  p_user_id uuid,
  p_challenge_id uuid
)
returns json
language plpgsql
security definer
as $$
declare
  result json;
begin
  -- Chama a função interna
  perform recalculate_challenge_progress(p_user_id, p_challenge_id);
  
  -- Retorna o resultado atualizado
  select json_build_object(
    'success', true,
    'message', 'Challenge progress recalculated successfully',
    'user_id', p_user_id,
    'challenge_id', p_challenge_id,
    'recalculated_at', now()
  ) into result;
  
  return result;
exception when others then
  return json_build_object(
    'success', false,
    'message', 'Error recalculating challenge progress: ' || SQLERRM,
    'user_id', p_user_id,
    'challenge_id', p_challenge_id
  );
end;
$$; 