-- Script para criar tabelas ausentes necessárias para a Fase 2 do Ray Club App
-- Execute este script no SQL Editor do Supabase

-- Tabela para rastreamento de consumo de água
CREATE TABLE IF NOT EXISTS water_intake (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    date DATE NOT NULL,
    cups INTEGER NOT NULL DEFAULT 0,
    goal INTEGER NOT NULL DEFAULT 8,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    notes TEXT,
    UNIQUE(user_id, date)
);

-- Criar índices para a tabela water_intake
CREATE INDEX IF NOT EXISTS idx_water_intake_user ON water_intake(user_id);
CREATE INDEX IF NOT EXISTS idx_water_intake_date ON water_intake(date);

-- Criar trigger para atualizar o campo updated_at
CREATE OR REPLACE FUNCTION trigger_update_water_intake_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_water_intake_timestamp
BEFORE UPDATE ON water_intake
FOR EACH ROW
EXECUTE FUNCTION trigger_update_water_intake_timestamp();

-- Tabela para FAQs
CREATE TABLE IF NOT EXISTS faqs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    category TEXT,
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices para a tabela faqs
CREATE INDEX IF NOT EXISTS idx_faqs_category ON faqs(category);
CREATE INDEX IF NOT EXISTS idx_faqs_active ON faqs(is_active);

-- Criar trigger para atualizar o campo updated_at
CREATE TRIGGER update_faqs_timestamp
BEFORE UPDATE ON faqs
FOR EACH ROW
EXECUTE FUNCTION trigger_update_water_intake_timestamp();

-- Tabela para tutoriais
CREATE TABLE IF NOT EXISTS tutorials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT,
    content TEXT NOT NULL,
    image_url TEXT,
    video_url TEXT,
    category TEXT,
    order_index INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices para a tabela tutorials
CREATE INDEX IF NOT EXISTS idx_tutorials_category ON tutorials(category);
CREATE INDEX IF NOT EXISTS idx_tutorials_active ON tutorials(is_active);

-- Criar trigger para atualizar o campo updated_at
CREATE TRIGGER update_tutorials_timestamp
BEFORE UPDATE ON tutorials
FOR EACH ROW
EXECUTE FUNCTION trigger_update_water_intake_timestamp();

-- Tabela para posts sociais
CREATE TABLE IF NOT EXISTS posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id),
    content TEXT NOT NULL,
    image_url TEXT,
    challenge_id UUID REFERENCES challenges(id),
    workout_id TEXT,
    workout_name TEXT,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_name TEXT,
    user_photo_url TEXT
);

-- Criar índices para a tabela posts
CREATE INDEX IF NOT EXISTS idx_posts_user ON posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_challenge ON posts(challenge_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON posts(created_at DESC);

-- Criar trigger para atualizar o campo updated_at
CREATE TRIGGER update_posts_timestamp
BEFORE UPDATE ON posts
FOR EACH ROW
EXECUTE FUNCTION trigger_update_water_intake_timestamp();

-- Tabela para comentários em posts
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    user_name TEXT,
    user_photo_url TEXT
);

-- Criar índices para a tabela comments
CREATE INDEX IF NOT EXISTS idx_comments_post ON comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user ON comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at DESC);

-- Criar trigger para atualizar o campo updated_at
CREATE TRIGGER update_comments_timestamp
BEFORE UPDATE ON comments
FOR EACH ROW
EXECUTE FUNCTION trigger_update_water_intake_timestamp();

-- Tabela para curtidas em posts
CREATE TABLE IF NOT EXISTS likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(post_id, user_id)
);

-- Criar índices para a tabela likes
CREATE INDEX IF NOT EXISTS idx_likes_post ON likes(post_id);
CREATE INDEX IF NOT EXISTS idx_likes_user ON likes(user_id);

-- Criar trigger para atualizar a contagem de curtidas em posts
CREATE OR REPLACE FUNCTION trigger_update_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts
        SET likes_count = likes_count + 1
        WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts
        SET likes_count = likes_count - 1
        WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_likes_count
AFTER INSERT OR DELETE ON likes
FOR EACH ROW
EXECUTE FUNCTION trigger_update_likes_count();

-- Criar trigger para atualizar a contagem de comentários em posts
CREATE OR REPLACE FUNCTION trigger_update_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts
        SET comments_count = comments_count + 1
        WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts
        SET comments_count = comments_count - 1
        WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_comments_count
AFTER INSERT OR DELETE ON comments
FOR EACH ROW
EXECUTE FUNCTION trigger_update_comments_count();

-- Tabela para formulário de contato
CREATE TABLE IF NOT EXISTS contact_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    subject TEXT NOT NULL,
    message TEXT NOT NULL,
    status TEXT DEFAULT 'pending', -- pending, processing, resolved, archived
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    admin_notes TEXT
);

-- Criar índices para a tabela contact_messages
CREATE INDEX IF NOT EXISTS idx_contact_messages_user ON contact_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_contact_messages_status ON contact_messages(status);

-- Criar trigger para atualizar o campo updated_at
CREATE TRIGGER update_contact_messages_timestamp
BEFORE UPDATE ON contact_messages
FOR EACH ROW
EXECUTE FUNCTION trigger_update_water_intake_timestamp();

-- Políticas de segurança (Row Level Security)

-- Políticas para water_intake
ALTER TABLE water_intake ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem ver apenas seus próprios registros de água"
ON water_intake FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem inserir seus próprios registros de água"
ON water_intake FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios registros de água"
ON water_intake FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem excluir seus próprios registros de água"
ON water_intake FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Políticas para faqs
ALTER TABLE faqs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Qualquer pessoa pode ver FAQs ativas"
ON faqs FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "Administradores podem gerenciar FAQs"
ON faqs FOR ALL
TO authenticated
USING (is_admin(auth.uid()));

-- Políticas para tutorials
ALTER TABLE tutorials ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Qualquer pessoa pode ver tutoriais ativos"
ON tutorials FOR SELECT
TO public
USING (is_active = true);

CREATE POLICY "Administradores podem gerenciar tutoriais"
ON tutorials FOR ALL
TO authenticated
USING (is_admin(auth.uid()));

-- Políticas para posts
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Qualquer pessoa pode ver posts"
ON posts FOR SELECT
TO public
USING (true);

CREATE POLICY "Usuários podem criar seus próprios posts"
ON posts FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios posts"
ON posts FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem excluir seus próprios posts"
ON posts FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Políticas para comments
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Qualquer pessoa pode ver comentários"
ON comments FOR SELECT
TO public
USING (true);

CREATE POLICY "Usuários podem criar seus próprios comentários"
ON comments FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem atualizar seus próprios comentários"
ON comments FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem excluir seus próprios comentários"
ON comments FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Políticas para likes
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Qualquer pessoa pode ver curtidas"
ON likes FOR SELECT
TO public
USING (true);

CREATE POLICY "Usuários podem criar suas próprias curtidas"
ON likes FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuários podem remover suas próprias curtidas"
ON likes FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Políticas para contact_messages
ALTER TABLE contact_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuários podem ver suas próprias mensagens de contato"
ON contact_messages FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Usuários podem criar mensagens de contato"
ON contact_messages FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Administradores podem gerenciar mensagens de contato"
ON contact_messages FOR ALL
TO authenticated
USING (is_admin(auth.uid())); 