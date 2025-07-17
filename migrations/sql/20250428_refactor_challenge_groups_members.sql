-- Migration: Refatorar tabela challenge_groups para usar uma tabela relacional em vez de array de membros
-- Esta migração:
-- 1. Verifica se a tabela challenge_group_members já existe
-- 2. Cria a tabela challenge_group_members se não existir
-- 3. Migra os dados existentes do array member_ids para a tabela relacional
-- 4. Remove a coluna member_ids da tabela challenge_groups

-- Parte 1: Verificar existência da tabela challenge_group_members
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'challenge_group_members'
    ) THEN
        -- Criar a tabela challenge_group_members
        CREATE TABLE challenge_group_members (
            id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
            group_id UUID NOT NULL REFERENCES challenge_groups(id) ON DELETE CASCADE,
            user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
            joined_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            UNIQUE(group_id, user_id)
        );

        -- Adicionar comentários à tabela e colunas
        COMMENT ON TABLE challenge_group_members IS 'Tabela relacional para membros de grupos de desafio';
        COMMENT ON COLUMN challenge_group_members.id IS 'ID único da relação';
        COMMENT ON COLUMN challenge_group_members.group_id IS 'ID do grupo de desafio';
        COMMENT ON COLUMN challenge_group_members.user_id IS 'ID do usuário membro do grupo';
        COMMENT ON COLUMN challenge_group_members.joined_at IS 'Data de entrada no grupo';
        COMMENT ON COLUMN challenge_group_members.created_at IS 'Data de criação do registro';
        COMMENT ON COLUMN challenge_group_members.updated_at IS 'Data de atualização do registro';

        -- Criar índices para performance
        CREATE INDEX idx_challenge_group_members_group_id ON challenge_group_members(group_id);
        CREATE INDEX idx_challenge_group_members_user_id ON challenge_group_members(user_id);
        CREATE INDEX idx_challenge_group_members_joined_at ON challenge_group_members(joined_at);

        -- Adicionar trigger para atualizar o updated_at
        CREATE TRIGGER set_updated_at
        BEFORE UPDATE ON challenge_group_members
        FOR EACH ROW
        EXECUTE FUNCTION trigger_set_updated_at();

        -- Definir políticas RLS (Row Level Security)
        ALTER TABLE challenge_group_members ENABLE ROW LEVEL SECURITY;

        -- Permitir que membros vejam os grupos aos quais pertencem
        CREATE POLICY "Users can see their group memberships"
        ON challenge_group_members FOR SELECT
        USING (auth.uid() = user_id);

        -- Permitir que administradores de grupos gerenciem membros
        CREATE POLICY "Group creators can manage members"
        ON challenge_group_members FOR ALL
        USING (
            auth.uid() IN (
                SELECT creator_id FROM challenge_groups 
                WHERE id = challenge_group_members.group_id
            )
        );

        -- Permitir que usuários entrem em grupos (se convidados ou grupos públicos)
        CREATE POLICY "Users can join groups"
        ON challenge_group_members FOR INSERT
        WITH CHECK (
            auth.uid() = user_id AND (
                -- Se é um grupo público
                EXISTS (
                    SELECT 1 FROM challenge_groups 
                    WHERE id = challenge_group_members.group_id 
                    AND is_public = true
                )
                OR
                -- Se foi convidado
                EXISTS (
                    SELECT 1 FROM challenge_group_invites 
                    WHERE group_id = challenge_group_members.group_id 
                    AND invitee_id = auth.uid() 
                    AND status = 'pending'
                )
            )
        );

        -- Permitir que usuários saiam de grupos
        CREATE POLICY "Users can leave groups"
        ON challenge_group_members FOR DELETE
        USING (auth.uid() = user_id);

        RAISE NOTICE 'Tabela challenge_group_members criada com sucesso';
    ELSE
        RAISE NOTICE 'Tabela challenge_group_members já existe';
    END IF;
END
$$;

-- Parte 2: Migrar dados do array member_ids para a tabela relacional
DO $$
DECLARE
    group_record RECORD;
    member_id UUID;
BEGIN
    -- Verificar se a coluna member_ids existe na tabela challenge_groups
    IF EXISTS (
        SELECT FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'challenge_groups'
        AND column_name = 'member_ids'
    ) THEN
        -- Processar cada grupo
        FOR group_record IN SELECT id, member_ids FROM challenge_groups LOOP
            -- Processar cada membro no array
            IF group_record.member_ids IS NOT NULL THEN
                FOREACH member_id IN ARRAY group_record.member_ids LOOP
                    -- Inserir na nova tabela relacional, ignorando se já existe
                    BEGIN
                        INSERT INTO challenge_group_members (group_id, user_id)
                        VALUES (group_record.id, member_id)
                        ON CONFLICT (group_id, user_id) DO NOTHING;
                    EXCEPTION WHEN OTHERS THEN
                        RAISE NOTICE 'Erro ao inserir membro % no grupo %: %', 
                                    member_id, group_record.id, SQLERRM;
                    END;
                END LOOP;
            END IF;
        END LOOP;

        RAISE NOTICE 'Dados migrados com sucesso para a tabela challenge_group_members';

        -- Remover a coluna member_ids após migração bem-sucedida
        ALTER TABLE challenge_groups DROP COLUMN IF EXISTS member_ids;
        RAISE NOTICE 'Coluna member_ids removida da tabela challenge_groups';
    ELSE
        RAISE NOTICE 'Coluna member_ids não existe na tabela challenge_groups, nenhuma migração necessária';
    END IF;
END
$$;

-- Parte 3: Adicionar função para contar membros do grupo
CREATE OR REPLACE FUNCTION get_group_members_count(group_id UUID)
RETURNS INTEGER AS $$
    SELECT COUNT(*)::INTEGER FROM challenge_group_members WHERE group_id = $1;
$$ LANGUAGE SQL STABLE;

COMMENT ON FUNCTION get_group_members_count IS 'Retorna o número de membros de um grupo de desafio'; 