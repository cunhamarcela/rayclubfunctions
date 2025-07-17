-- Script de correção para problemas nos desafios do Ray Club App

-- 1. Corrigir o problema de recursão infinita nas políticas do challenge_group_members
DROP POLICY IF EXISTS "Membros e criadores podem ver membros do grupo" ON challenge_group_members;
DROP POLICY IF EXISTS "Usuários podem se adicionar a grupos" ON challenge_group_members;
DROP POLICY IF EXISTS "Criadores podem adicionar membros" ON challenge_group_members;
DROP POLICY IF EXISTS "Usuários podem sair de grupos" ON challenge_group_members;
DROP POLICY IF EXISTS "Criadores podem remover membros" ON challenge_group_members;

-- Criar políticas sem recursão
CREATE POLICY "Ver membros do grupo" ON challenge_group_members
  FOR SELECT TO authenticated USING (
    user_id = auth.uid() OR
    group_id IN (
      SELECT group_id FROM challenge_group_members WHERE user_id = auth.uid()
    ) OR
    group_id IN (
      SELECT id FROM challenge_groups WHERE creator_id = auth.uid()
    )
  );

CREATE POLICY "Adicionar a si mesmo ao grupo" ON challenge_group_members
  FOR INSERT TO authenticated WITH CHECK (
    user_id = auth.uid()
  );

CREATE POLICY "Criador adiciona membros" ON challenge_group_members
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM challenge_groups WHERE id = challenge_group_members.group_id AND creator_id = auth.uid()
    )
  );

CREATE POLICY "Sair do grupo" ON challenge_group_members
  FOR DELETE TO authenticated USING (
    user_id = auth.uid()
  );

CREATE POLICY "Remover membros do grupo" ON challenge_group_members
  FOR DELETE TO authenticated USING (
    EXISTS (
      SELECT 1 FROM challenge_groups WHERE id = challenge_group_members.group_id AND creator_id = auth.uid()
    )
  );

-- 2. Garantir que a tabela challenge_progress tenha os campos necessários
ALTER TABLE challenge_progress
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

ALTER TABLE challenge_progress
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

ALTER TABLE challenge_progress
ADD COLUMN IF NOT EXISTS check_ins_count INT DEFAULT 0;

ALTER TABLE challenge_progress
ADD COLUMN IF NOT EXISTS last_check_in TIMESTAMP WITH TIME ZONE;

ALTER TABLE challenge_progress
ADD COLUMN IF NOT EXISTS consecutive_days INT DEFAULT 0;

ALTER TABLE challenge_progress
ADD COLUMN IF NOT EXISTS completed BOOLEAN DEFAULT FALSE;

ALTER TABLE challenge_progress
ADD COLUMN IF NOT EXISTS user_name TEXT DEFAULT 'Participante';

ALTER TABLE challenge_progress
ADD COLUMN IF NOT EXISTS user_photo_url TEXT;

-- Certificar que challenge_progress tem os participantes corretos para este desafio
-- (Insere registro de progresso para todos os participantes do desafio que não têm progresso ainda)
INSERT INTO challenge_progress (
  user_id, 
  challenge_id, 
  user_name, 
  user_photo_url, 
  points, 
  check_ins_count, 
  created_at, 
  updated_at, 
  completion_percentage
)
SELECT 
  cp.user_id,
  cp.challenge_id,
  profiles.username,
  profiles.avatar_url,
  0 as points,
  0 as check_ins_count,
  NOW() as created_at,
  NOW() as updated_at,
  0 as completion_percentage
FROM 
  challenge_participants cp
LEFT JOIN 
  challenge_progress prog ON cp.user_id = prog.user_id AND cp.challenge_id = prog.challenge_id
LEFT JOIN
  profiles ON cp.user_id = profiles.id
WHERE 
  prog.id IS NULL
AND
  cp.challenge_id = '1c26ef02-e87d-4fd6-855b-8f968cdad06b';

-- 3. Adicionar trigger para atualização automática do campo updated_at
CREATE OR REPLACE FUNCTION update_challenge_progress_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_challenge_progress_updated_at ON challenge_progress;

CREATE TRIGGER set_challenge_progress_updated_at
BEFORE UPDATE ON challenge_progress
FOR EACH ROW
EXECUTE FUNCTION update_challenge_progress_updated_at(); 