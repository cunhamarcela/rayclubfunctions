-- Script para testar a criação de metas do usuário
-- Data: 2025-01-21 às 14:45
-- Objetivo: Testar se a estrutura da tabela user_goals está funcionando

-- 1. Verificar se a tabela existe e sua estrutura
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'user_goals' 
ORDER BY ordinal_position;

-- 2. Criar uma meta de teste (substitua pelo seu user_id real)
INSERT INTO user_goals (
    user_id,
    title,
    target_value,
    current_value,
    unit,
    goal_type,
    start_date,
    target_date,
    is_completed,
    created_at,
    updated_at
) VALUES (
    auth.uid(), -- Usar o usuário autenticado atual
    'Meta de Teste - Treinar 3x por semana',
    3.0,
    1.0,
    'treinos',
    'workout',
    NOW(),
    NOW() + INTERVAL '7 days',
    false,
    NOW(),
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- 3. Verificar se a meta foi criada
SELECT 
    id,
    title,
    target_value,
    current_value,
    unit,
    goal_type,
    is_completed,
    (current_value / target_value * 100)::DECIMAL(5,2) as progress_percentage,
    created_at
FROM user_goals 
WHERE user_id = auth.uid()
ORDER BY created_at DESC
LIMIT 5;

-- 4. Teste de atualização de progresso
UPDATE user_goals 
SET 
    current_value = 2.0,
    progress_percentage = (2.0 / target_value * 100),
    updated_at = NOW()
WHERE user_id = auth.uid() 
AND title LIKE '%Meta de Teste%';

-- 5. Verificar a atualização
SELECT 
    title,
    target_value,
    current_value,
    progress_percentage,
    is_completed,
    updated_at
FROM user_goals 
WHERE user_id = auth.uid()
AND title LIKE '%Meta de Teste%'; 