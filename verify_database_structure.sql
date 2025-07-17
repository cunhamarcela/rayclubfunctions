-- Script para verificar estrutura do banco de dados Supabase
-- Autor: Claude 3.7
-- Descrição: Verifica se as colunas esperadas pelo código existem no banco de dados

-- Função para verificar existência de tabelas e colunas
CREATE OR REPLACE FUNCTION check_database_structure()
RETURNS TEXT AS $$
DECLARE
    result TEXT := '';
    table_exists BOOLEAN;
    column_exists BOOLEAN;
    tables_to_check TEXT[] := ARRAY[
        'user_progress', 'water_intake', 'challenges', 'challenge_participants', 
        'challenge_progress', 'workout_records', 'benefits', 'user_benefits', 
        'user_goals'
    ];
    current_table TEXT;
    column_list TEXT;
BEGIN
    result := result || 'DATABASE STRUCTURE VERIFICATION' || E'\n';
    result := result || '===============================' || E'\n\n';
    
    -- Verificar existência das tabelas
    result := result || 'TABLES STATUS:' || E'\n';
    result := result || '-------------' || E'\n';
    
    FOREACH current_table IN ARRAY tables_to_check LOOP
        SELECT EXISTS (
            SELECT FROM information_schema.tables 
            WHERE table_name = current_table
        ) INTO table_exists;
        
        IF table_exists THEN
            result := result || '✅ ' || current_table || ' (exists)' || E'\n';
            
            -- Listar colunas para a tabela
            SELECT string_agg(column_name, ', ') 
            FROM information_schema.columns 
            WHERE table_name = current_table
            INTO column_list;
            
            result := result || '   Columns: ' || column_list || E'\n\n';
        ELSE
            result := result || '❌ ' || current_table || ' (missing)' || E'\n\n';
        END IF;
    END LOOP;
    
    -- Verificar colunas específicas que estão causando problemas
    result := result || 'CRITICAL COLUMNS:' || E'\n';
    result := result || '----------------' || E'\n';
    
    -- Verificar user_progress.current_streak
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'current_streak'
    ) INTO column_exists;
    
    IF column_exists THEN
        result := result || '✅ user_progress.current_streak (exists)' || E'\n';
    ELSE
        result := result || '❌ user_progress.current_streak (missing)' || E'\n';
    END IF;
    
    -- Verificar user_progress.total_duration
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'total_duration'
    ) INTO column_exists;
    
    IF column_exists THEN
        result := result || '✅ user_progress.total_duration (exists)' || E'\n';
    ELSE
        result := result || '❌ user_progress.total_duration (missing)' || E'\n';
    END IF;
    
    -- Verificar user_progress.points vs total_points
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'points'
    ) INTO column_exists;
    
    IF column_exists THEN
        result := result || '✅ user_progress.points (exists)' || E'\n';
    ELSE
        result := result || '❌ user_progress.points (missing)' || E'\n';
    END IF;
    
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'total_points'
    ) INTO column_exists;
    
    IF column_exists THEN
        result := result || '✅ user_progress.total_points (exists)' || E'\n';
    ELSE
        result := result || '❌ user_progress.total_points (missing)' || E'\n';
    END IF;
    
    -- Verificar challenge_progress.check_ins_count vs total_check_ins
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'challenge_progress' AND column_name = 'check_ins_count'
    ) INTO column_exists;
    
    IF column_exists THEN
        result := result || '✅ challenge_progress.check_ins_count (exists)' || E'\n';
    ELSE
        result := result || '❌ challenge_progress.check_ins_count (missing)' || E'\n';
    END IF;
    
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'challenge_progress' AND column_name = 'total_check_ins'
    ) INTO column_exists;
    
    IF column_exists THEN
        result := result || '✅ challenge_progress.total_check_ins (exists)' || E'\n';
    ELSE
        result := result || '❌ challenge_progress.total_check_ins (missing)' || E'\n';
    END IF;
    
    -- Sugerir correções
    result := result || E'\n';
    result := result || 'RECOMMENDATION:' || E'\n';
    result := result || '--------------' || E'\n';
    result := result || 'Execute os seguintes comandos SQL para corrigir problemas encontrados:' || E'\n\n';
    
    -- Verificar se precisa adicionar current_streak em user_progress
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'current_streak'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        result := result || '-- Adicionar coluna current_streak à tabela user_progress' || E'\n';
        result := result || 'ALTER TABLE user_progress ADD COLUMN current_streak INTEGER DEFAULT 0;' || E'\n\n';
    END IF;
    
    -- Verificar se precisa adicionar total_duration em user_progress
    SELECT EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_name = 'user_progress' AND column_name = 'total_duration'
    ) INTO column_exists;
    
    IF NOT column_exists THEN
        result := result || '-- Adicionar coluna total_duration à tabela user_progress' || E'\n';
        result := result || 'ALTER TABLE user_progress ADD COLUMN total_duration INTEGER DEFAULT 0;' || E'\n\n';
    END IF;
    
    -- Verificar se devemos alterar a função get_dashboard_data
    result := result || '-- Atualizar função get_dashboard_data para usar colunas existentes' || E'\n';
    result := result || 'CREATE OR REPLACE FUNCTION get_dashboard_data(user_id_param UUID) ...' || E'\n';
    
    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Executar a função para gerar o relatório
SELECT check_database_structure(); 