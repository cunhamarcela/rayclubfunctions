-- Script para corrigir a recursão infinita nas políticas RLS de challenge_group_members
-- Execute este script no SQL Editor do Supabase

-- 1. Primeiro, remover a política problemática
DROP POLICY IF EXISTS "Ver membros do grupo" ON challenge_group_members;

-- 2. Criar a política corrigida com aliases claros para evitar a recursão infinita
CREATE POLICY "Ver membros do grupo" ON challenge_group_members
FOR SELECT TO public
USING (
  (user_id = auth.uid()) OR 
  (group_id IN (
    SELECT cg.id 
    FROM challenge_groups cg
    WHERE cg.creator_id = auth.uid()
  )) OR 
  (EXISTS (
    SELECT 1 
    FROM challenge_groups AS cg
    JOIN challenge_group_members AS outer_cgm ON cg.id = outer_cgm.group_id
    WHERE outer_cgm.user_id = auth.uid() 
      AND outer_cgm.group_id = challenge_group_members.group_id
  ))
);

-- 3. Verificar se a política foi aplicada corretamente
SELECT * FROM pg_policies WHERE tablename = 'challenge_group_members' AND policyname = 'Ver membros do grupo'; 