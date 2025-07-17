-- Script para alterar tabelas existentes para corrigir inconsistências na Fase 2 do Ray Club App
-- Execute este script no SQL Editor do Supabase

-- 1. Corrigir conflito entre tabelas profile e profiles
-- Primeiro, recriar a view global_user_ranking para usar a tabela profiles
CREATE OR REPLACE VIEW global_user_ranking AS
SELECT 
    up.user_id,
    p.name AS username,
    COALESCE(p.photo_url, p.profile_image_url) AS avatar_url,
    get_user_points(up.user_id) AS points,
    get_user_workouts(up.user_id) AS total_workouts,
    rank() OVER (ORDER BY (get_user_points(up.user_id)) DESC) AS rank
FROM user_progress up
JOIN profiles p ON (up.user_id = p.id);

-- Agora excluir a tabela redundante profile
DROP TABLE IF EXISTS profile CASCADE;

-- 2. Padronizar campos de controle de data em todas as tabelas
DO $$
DECLARE
    table_rec record;
BEGIN
    FOR table_rec IN 
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename NOT IN ('spatial_ref_sys')  -- Excluir tabelas do sistema
    LOOP
        -- Verificar se a tabela tem a coluna created_at
        IF NOT EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = table_rec.tablename 
            AND column_name = 'created_at'
        ) THEN
            -- Adicionar coluna created_at se não existir
            EXECUTE 'ALTER TABLE ' || table_rec.tablename || ' ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()';
            RAISE NOTICE 'Adicionada coluna created_at à tabela %', table_rec.tablename;
        END IF;
        
        -- Verificar se a tabela tem a coluna updated_at
        IF NOT EXISTS (
            SELECT 1 
            FROM information_schema.columns 
            WHERE table_schema = 'public' 
            AND table_name = table_rec.tablename 
            AND column_name = 'updated_at'
        ) THEN
            -- Adicionar coluna updated_at se não existir
            EXECUTE 'ALTER TABLE ' || table_rec.tablename || ' ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()';
            
            -- Adicionar trigger para atualizar updated_at
            EXECUTE 'CREATE TRIGGER update_' || table_rec.tablename || '_timestamp
                     BEFORE UPDATE ON ' || table_rec.tablename || '
                     FOR EACH ROW
                     EXECUTE FUNCTION update_modified_column()';
            
            RAISE NOTICE 'Adicionada coluna updated_at e trigger à tabela %', table_rec.tablename;
        END IF;
    END LOOP;
END $$;

-- 3. Remover campo redundante participants_count da tabela challenges e unificar para usar apenas participants
-- Primeiro, garantir que o campo participants tenha o valor correto através de um update
UPDATE challenges
SET participants = (
    SELECT COUNT(*) 
    FROM challenge_participants 
    WHERE challenge_participants.challenge_id = challenges.id
)
WHERE EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_schema = 'public' 
    AND table_name = 'challenges' 
    AND column_name = 'participants'
);

-- Remover a coluna redundante
ALTER TABLE challenges DROP COLUMN IF EXISTS participants_count;

-- 4. Adicionar um campo para localImagePath na tabela challenges (conforme correção da Fase 1)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'challenges' 
        AND column_name = 'local_image_path'
    ) THEN
        ALTER TABLE challenges ADD COLUMN local_image_path TEXT;
        RAISE NOTICE 'Campo local_image_path adicionado à tabela challenges';
    ELSE
        RAISE NOTICE 'Campo local_image_path já existe na tabela challenges';
    END IF;
END $$;

-- 5. Adicionar campo is_completed à tabela challenge_participants para rastreamento mais fácil de conclusão
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'challenge_participants' 
        AND column_name = 'is_completed'
    ) THEN
        ALTER TABLE challenge_participants ADD COLUMN is_completed BOOLEAN DEFAULT FALSE;
        RAISE NOTICE 'Campo is_completed adicionado à tabela challenge_participants';
    ELSE
        RAISE NOTICE 'Campo is_completed já existe na tabela challenge_participants';
    END IF;
END $$;

-- 6. Garantir que todos os usuários tenham um registro em user_progress
INSERT INTO user_progress (user_id, points, workouts_completed, challenges_completed, created_at, updated_at)
SELECT id, 0, 0, 0, NOW(), NOW()
FROM auth.users
WHERE NOT EXISTS (
    SELECT 1 FROM user_progress WHERE user_id = auth.users.id
);

-- 7. Atualizar trigger de check-in para considerar os requisitos do desafio
CREATE OR REPLACE FUNCTION update_challenge_progress_on_check_in()
RETURNS TRIGGER AS $$
DECLARE
    challenge_rec record;
    total_check_ins integer;
    completion_percentage numeric;
    required_check_ins integer := 0;
BEGIN
    -- Obter informações do desafio
    SELECT * INTO challenge_rec FROM challenges WHERE id = NEW.challenge_id;
    
    -- Obter número de check-ins requeridos do campo requirements (se existir)
    IF challenge_rec.requirements IS NOT NULL AND challenge_rec.requirements->>'count' IS NOT NULL THEN
        required_check_ins := (challenge_rec.requirements->>'count')::integer;
    END IF;
    
    -- Se não tiver requisitos definidos, utilizar padrão de 30 check-ins
    IF required_check_ins = 0 THEN
        required_check_ins := 30;
    END IF;
    
    -- Calcular total de check-ins e porcentagem de conclusão
    SELECT COUNT(*) INTO total_check_ins
    FROM challenge_check_ins
    WHERE challenge_id = NEW.challenge_id AND user_id = NEW.user_id;
    
    completion_percentage := (total_check_ins::numeric / required_check_ins) * 100;
    IF completion_percentage > 100 THEN
        completion_percentage := 100;
    END IF;
    
    -- Verificar se o desafio foi concluído
    IF completion_percentage >= 100 THEN
        -- Atualizar status do participante para completed
        UPDATE challenge_participants
        SET 
            status = 'completed',
            is_completed = true
        WHERE 
            challenge_id = NEW.challenge_id AND 
            user_id = NEW.user_id;
            
        -- Incrementar contador de desafios concluídos do usuário
        UPDATE user_progress
        SET 
            challenges_completed = challenges_completed + 1,
            updated_at = NOW()
        WHERE 
            user_id = NEW.user_id AND
            NOT EXISTS (
                SELECT 1 
                FROM challenge_progress 
                WHERE challenge_id = NEW.challenge_id AND
                      user_id = NEW.user_id AND
                      completed = true
            );
            
        -- Adicionar pontos de bônus por conclusão (se definidos)
        IF challenge_rec.completion_points IS NOT NULL AND challenge_rec.completion_points > 0 THEN
            UPDATE user_progress
            SET 
                points = points + challenge_rec.completion_points,
                updated_at = NOW()
            WHERE 
                user_id = NEW.user_id;
        END IF;
    END IF;
    
    -- Atualizar progresso do desafio
    INSERT INTO challenge_progress (
        challenge_id, user_id, points, check_ins_count, 
        completion_percentage, last_check_in, user_name, 
        user_photo_url, consecutive_days, completed
    ) VALUES (
        NEW.challenge_id, NEW.user_id, 
        COALESCE((SELECT SUM(points) FROM challenge_check_ins WHERE challenge_id = NEW.challenge_id AND user_id = NEW.user_id), 0),
        total_check_ins, 
        completion_percentage, 
        NEW.check_in_date, 
        NEW.user_name, 
        NEW.user_photo_url,
        (SELECT get_current_streak(NEW.user_id, NEW.challenge_id)),
        (completion_percentage >= 100)
    )
    ON CONFLICT (challenge_id, user_id) DO UPDATE SET
        points = COALESCE((SELECT SUM(points) FROM challenge_check_ins WHERE challenge_id = NEW.challenge_id AND user_id = NEW.user_id), 0),
        check_ins_count = total_check_ins,
        completion_percentage = completion_percentage,
        last_check_in = NEW.check_in_date,
        user_name = COALESCE(NEW.user_name, challenge_progress.user_name),
        user_photo_url = COALESCE(NEW.user_photo_url, challenge_progress.user_photo_url),
        consecutive_days = (SELECT get_current_streak(NEW.user_id, NEW.challenge_id)),
        completed = (completion_percentage >= 100),
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql; 