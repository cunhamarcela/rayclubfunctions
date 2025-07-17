-- Criar tabela de materiais
CREATE TABLE materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    material_type TEXT NOT NULL CHECK (material_type IN ('pdf', 'ebook', 'guide', 'document')),
    material_context TEXT NOT NULL CHECK (material_context IN ('workout', 'nutrition', 'general')),
    file_path TEXT NOT NULL,
    file_size INTEGER,
    thumbnail_url TEXT,
    author_name TEXT,
    workout_video_id UUID REFERENCES workout_videos(id),
    order_index INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    requires_expert_access BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar índices
CREATE INDEX idx_materials_context ON materials(material_context);
CREATE INDEX idx_materials_workout_video ON materials(workout_video_id);
CREATE INDEX idx_materials_featured ON materials(is_featured);

-- Criar bucket no Storage
INSERT INTO storage.buckets (id, name, public) VALUES ('materials', 'materials', false);

-- Configurar RLS
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;

-- Política para leitura (usuários autenticados)
CREATE POLICY "Allow authenticated users to read materials" ON materials
    FOR SELECT USING (auth.role() = 'authenticated');

-- Política para acesso expert (se necessário)
CREATE POLICY "Allow expert access to restricted materials" ON materials
    FOR SELECT USING (
        NOT requires_expert_access OR
        EXISTS (
            SELECT 1 FROM profiles
            WHERE profiles.user_id = auth.uid()
            AND profiles.subscription_level = 'expert'
        )
    ); 