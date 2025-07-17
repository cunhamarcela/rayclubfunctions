-- Criar tabela de vídeos de treino
CREATE TABLE IF NOT EXISTS workout_videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    duration VARCHAR(50) NOT NULL, -- Ex: "45 min", "1h 30min"
    duration_minutes INTEGER, -- Duração em minutos para filtros
    difficulty VARCHAR(50) NOT NULL CHECK (difficulty IN ('Iniciante', 'Intermediário', 'Avançado')),
    youtube_url TEXT,
    thumbnail_url TEXT,
    category VARCHAR(100) NOT NULL,
    instructor_name VARCHAR(255),
    description TEXT,
    order_index INTEGER DEFAULT 0,
    is_new BOOLEAN DEFAULT false,
    is_popular BOOLEAN DEFAULT false,
    is_recommended BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Criar índices para melhor performance
CREATE INDEX idx_workout_videos_category ON workout_videos(category);
CREATE INDEX idx_workout_videos_difficulty ON workout_videos(difficulty);
CREATE INDEX idx_workout_videos_order ON workout_videos(order_index);
CREATE INDEX idx_workout_videos_created_at ON workout_videos(created_at DESC);

-- Criar tabela de visualizações de vídeos
CREATE TABLE IF NOT EXISTS workout_video_views (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    video_id UUID NOT NULL REFERENCES workout_videos(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(video_id, user_id)
);

-- Criar índices para visualizações
CREATE INDEX idx_workout_video_views_video ON workout_video_views(video_id);
CREATE INDEX idx_workout_video_views_user ON workout_video_views(user_id);
CREATE INDEX idx_workout_video_views_date ON workout_video_views(viewed_at DESC);

-- Adicionar trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_workout_videos_updated_at 
    BEFORE UPDATE ON workout_videos 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Inserir dados de exemplo para as categorias dos parceiros
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended) VALUES
-- Musculação (Treinos de Musculação)
('Apresentação - Treinos de Musculação', '51 seg', 1, 'Iniciante', 'https://www.youtube.com/watch?v=example1', 'bodybuilding', 'Equipe Treinos de Musculação', 'Conheça nossos instrutores e metodologia', 1, true),
('Treino A - Semana 1', '45 min', 45, 'Iniciante', 'https://www.youtube.com/watch?v=example2', 'bodybuilding', 'Instrutor João', 'Treino completo para iniciantes', 2, false),
('Treino B - Semana 2', '50 min', 50, 'Intermediário', 'https://www.youtube.com/watch?v=example3', 'bodybuilding', 'Instrutor João', 'Evolução do treino básico', 3, false),

-- Pilates (Goya Health Club)
('Introdução ao Pilates', '30 min', 30, 'Iniciante', 'https://www.youtube.com/watch?v=example4', 'pilates', 'Goya Health Club', 'Princípios básicos do Pilates', 1, true),
('Pilates para Core', '40 min', 40, 'Intermediário', 'https://www.youtube.com/watch?v=example5', 'pilates', 'Instrutora Maria', 'Fortalecimento do core', 2, false),

-- Funcional (Fight Fit)
('Treino Funcional Básico', '35 min', 35, 'Iniciante', 'https://www.youtube.com/watch?v=example6', 'functional', 'Fight Fit Team', 'Movimentos funcionais essenciais', 1, true),
('HIIT Funcional', '25 min', 25, 'Avançado', 'https://www.youtube.com/watch?v=example7', 'functional', 'Coach Pedro', 'Treino de alta intensidade', 2, false),

-- Corrida (Bora Assessoria)
('Técnica de Corrida', '20 min', 20, 'Iniciante', 'https://www.youtube.com/watch?v=example8', 'running', 'Bora Assessoria', 'Aprenda a correr corretamente', 1, true),
('Treino Intervalado', '45 min', 45, 'Intermediário', 'https://www.youtube.com/watch?v=example9', 'running', 'Coach Ana', 'Melhore sua velocidade', 2, false),

-- Fisioterapia (The Unit)
('Mobilidade para Iniciantes', '30 min', 30, 'Iniciante', 'https://www.youtube.com/watch?v=example10', 'physiotherapy', 'The Unit', 'Exercícios de mobilidade', 1, true),
('Prevenção de Lesões', '40 min', 40, 'Intermediário', 'https://www.youtube.com/watch?v=example11', 'physiotherapy', 'Dr. Carlos', 'Fortaleça e previna lesões', 2, false);

-- Adicionar políticas RLS
ALTER TABLE workout_videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_video_views ENABLE ROW LEVEL SECURITY;

-- Política para visualizar vídeos (todos podem ver)
CREATE POLICY "Vídeos são públicos" ON workout_videos
    FOR SELECT USING (true);

-- Política para visualizações (usuários podem ver suas próprias visualizações)
CREATE POLICY "Usuários podem ver suas visualizações" ON workout_video_views
    FOR SELECT USING (auth.uid() = user_id);

-- Política para inserir visualizações (usuários podem registrar suas visualizações)
CREATE POLICY "Usuários podem registrar visualizações" ON workout_video_views
    FOR INSERT WITH CHECK (auth.uid() = user_id); 