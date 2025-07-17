-- Script para remover tabela challenge_rankings que está causando ambiguidade
DROP VIEW IF EXISTS challenge_rankings;
DROP MATERIALIZED VIEW IF EXISTS challenge_rankings;
-- Agora execute este script no Supabase Studio SQL
