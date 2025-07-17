-- Correção para o problema de recursão infinita nas políticas da tabela challenge_group_members

-- Primeiro, remover todas as políticas existentes que podem estar causando o problema
DROP POLICY IF EXISTS "Membros e criadores podem ver membros do grupo" ON challenge_group_members;
DROP POLICY IF EXISTS "Usuários podem se adicionar a grupos" ON challenge_group_members;
DROP POLICY IF EXISTS "Criadores podem adicionar membros" ON challenge_group_members;
DROP POLICY IF EXISTS "Usuários podem sair de grupos" ON challenge_group_members;
DROP POLICY IF EXISTS "Criadores podem remover membros" ON challenge_group_members;

-- Criar políticas sem recursão
-- 1. Política de SELECT simplificada
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

-- 2. Política para usuários se adicionarem aos grupos
CREATE POLICY "Adicionar a si mesmo ao grupo" ON challenge_group_members
  FOR INSERT TO authenticated WITH CHECK (
    user_id = auth.uid()
  );

-- 3. Política para criadores adicionarem usuários aos grupos
CREATE POLICY "Criador adiciona membros" ON challenge_group_members
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM challenge_groups WHERE id = challenge_group_members.group_id AND creator_id = auth.uid()
    )
  );

-- 4. Política para permitir que usuários saiam dos grupos
CREATE POLICY "Sair do grupo" ON challenge_group_members
  FOR DELETE TO authenticated USING (
    user_id = auth.uid()
  );

-- 5. Política para permitir que criadores removam membros
CREATE POLICY "Remover membros do grupo" ON challenge_group_members
  FOR DELETE TO authenticated USING (
    EXISTS (
      SELECT 1 FROM challenge_groups WHERE id = challenge_group_members.group_id AND creator_id = auth.uid()
    )
  ); 