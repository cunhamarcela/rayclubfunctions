-- Script para criar um desafio de teste de 3 dias
-- ATENÇÃO: Este script apagará TODOS os desafios existentes e seus dados relacionados!
-- Como usar: Copie e execute no Console SQL do Supabase

-- 1. Primeiro, apagar tabelas relacionadas (na ordem correta para respeitar chaves estrangeiras)

-- Limpar check-ins de desafios
DELETE FROM challenge_check_ins;

-- Limpar progresso de desafios
DELETE FROM challenge_progress;

-- Limpar participantes de desafios
DELETE FROM challenge_participants;

-- Limpar bônus de desafios (se existir)
DELETE FROM challenge_bonuses WHERE TRUE;

-- Por fim, limpar a tabela de desafios
DELETE FROM challenges;

-- 2. Criar um novo desafio de teste com duração de 3 dias
INSERT INTO challenges (
  id,
  title, 
  description, 
  start_date, 
  end_date, 
  image_url, 
  type, 
  points,
  is_official, 
  active,
  created_at, 
  updated_at
) 
VALUES (
  gen_random_uuid(), -- Gera um UUID aleatório
  'Desafio de Teste (3 dias)', 
  'Este é um desafio de teste com duração de 3 dias criado para fins de teste da exibição de desafios no dashboard.', 
  CURRENT_TIMESTAMP, -- Data inicial = agora
  CURRENT_TIMESTAMP + INTERVAL '3 days', -- Data final = agora + 3 dias
  'https://picsum.photos/seed/rayclub/800/600', -- Imagem aleatória
  'workout', 
  100,
  TRUE, -- É oficial
  TRUE, -- Está ativo
  CURRENT_TIMESTAMP, 
  CURRENT_TIMESTAMP
) RETURNING id, title, start_date, end_date; 