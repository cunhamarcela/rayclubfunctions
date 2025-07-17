-- Script para aplicar todas as migrações

-- Iniciar transação
BEGIN;

-- Informativo
RAISE NOTICE 'Iniciando aplicação de migrações...';

-- Carregar as funções de atualização em tempo real para o dashboard
\i migrations/001_dashboard_refresh.sql

-- Finalizar transação
COMMIT;

RAISE NOTICE 'Migrações aplicadas com sucesso!'; 