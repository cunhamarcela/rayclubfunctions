-- Script para testar a criação de metas do usuário (CORRIGIDO)
-- Data: 2025-01-21 às 15:00
-- Objetivo: Testar se a estrutura da tabela user_goals está funcionando

-- 1. Primeiro, vamos buscar um user_id válido na tabela de usuários
SELECT 
    id as user_id, 
    email,
    created_at
FROM auth.users 
LIMIT 5;

-- 2. Para o teste, vamos usar uma das abordagens:
-- OPÇÃO A: Selecionar o primeiro usuário disponível e inserir manualmente
-- OPÇÃO B: Usar o código abaixo substituindo 'SEU_USER_ID_AQUI' por um ID real

-- Exemplo de inserção com user_id fixo (substitua pelo ID real):
/*
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
    'SEU_USER_ID_AQUI', -- Substitua por um user_id real da consulta acima
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
);
*/

-- 3. Verificar metas existentes
SELECT 
    id,
    user_id,
    title,
    target_value,
    current_value,
    unit,
    goal_type,
    is_completed,
    created_at
FROM user_goals 
ORDER BY created_at DESC 
LIMIT 10;

-- 4. Se você quiser usar uma abordagem mais segura com uma função:
CREATE OR REPLACE FUNCTION create_test_goal_for_first_user()
RETURNS TABLE(
    result_message TEXT,
    goal_id UUID,
    user_id UUID
) AS $$
DECLARE
    first_user_id UUID;
    new_goal_id UUID;
BEGIN
    -- Buscar o primeiro usuário
    SELECT id INTO first_user_id 
    FROM auth.users 
    LIMIT 1;
    
    IF first_user_id IS NULL THEN
        RETURN QUERY SELECT 'Nenhum usuário encontrado'::TEXT, NULL::UUID, NULL::UUID;
        RETURN;
    END IF;
    
    -- Inserir a meta de teste
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
        first_user_id,
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
    ) RETURNING id INTO new_goal_id;
    
    RETURN QUERY SELECT 
        'Meta criada com sucesso!'::TEXT, 
        new_goal_id, 
        first_user_id;
END;
$$ LANGUAGE plpgsql;

-- Para executar a função:
-- SELECT * FROM create_test_goal_for_first_user(); 