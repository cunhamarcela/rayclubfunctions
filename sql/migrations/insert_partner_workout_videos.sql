-- Limpar dados de exemplo anteriores
DELETE FROM workout_videos WHERE youtube_url LIKE '%example%';

-- Inserir vídeos reais dos parceiros

-- TREINOS DE MUSCULAÇÃO
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended) VALUES
('Apresentação', '51 seg', 1, 'Iniciante', 'https://youtu.be/Ej0Tz0Ym5Ow', 'bodybuilding', 'Treinos de Musculação', 'Conheça nossos instrutores e metodologia', 1, true),
('Treino A - Semana 1', '45 min', 45, 'Iniciante', 'https://youtu.be/Ej0Tz0Ym5Ow', 'bodybuilding', 'Treinos de Musculação', 'Treino completo para iniciantes - Semana 1', 2, false),
('Treino B - Semana 1', '45 min', 45, 'Iniciante', 'https://youtu.be/Ej0Tz0Ym5Ow', 'bodybuilding', 'Treinos de Musculação', 'Treino alternativo para iniciantes - Semana 1', 3, false),
('Treino A - Semana 2', '50 min', 50, 'Intermediário', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'bodybuilding', 'Treinos de Musculação', 'Evolução do treino - Semana 2', 4, false),
('Treino B - Semana 2', '50 min', 50, 'Intermediário', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'bodybuilding', 'Treinos de Musculação', 'Treino alternativo - Semana 2', 5, false),
('Treino A - Semana 3', '55 min', 55, 'Avançado', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'bodybuilding', 'Treinos de Musculação', 'Treino avançado - Semana 3', 6, false),
('Treino B - Semana 3', '55 min', 55, 'Avançado', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'bodybuilding', 'Treinos de Musculação', 'Treino alternativo avançado - Semana 3', 7, false);

-- GOYA HEALTH CLUB (PILATES)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended) VALUES
('Apresentação Pilates', '15 min', 15, 'Iniciante', 'https://youtu.be/nhD9ITCBTVU', 'pilates', 'Goya Health Club', 'Introdução aos benefícios e técnicas do Pilates', 1, true),
('Mobilidade', '25 min', 25, 'Iniciante', 'https://youtu.be/gDB5n3kSRqI', 'pilates', 'Goya Health Club', 'Pilates básico para iniciantes', 2, false),
('Pilates para Flexibilidade', '40 min', 40, 'Intermediário', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'pilates', 'Goya Health Club', 'Melhore sua flexibilidade', 3, false),
('Pilates para Core - Intermediário', '40 min', 40, 'Intermediário', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'pilates', 'Goya Health Club', 'Fortalecimento intermediário do core', 4, false),
('Pilates Avançado', '45 min', 45, 'Avançado', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'pilates', 'Goya Health Club', 'Desafie seus limites', 5, false);

-- FIGHT FIT (FUNCIONAL)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended) VALUES
('Apresentação Fight Fit', '12 min', 12, 'Iniciante', 'https://youtu.be/gcLeeRlqoFM', 'functional', 'Fight Fit', 'Conheça o conceito Fight Fit e seus benefícios', 1, true),
('Abdominal', '30 min', 30, 'Iniciante', 'https://youtu.be/RCywus6kVPk', 'functional', 'Fight Fit', 'Treino funcional básico com elementos de luta', 2, false),
('Técnica', '40 min', 40, 'Intermediário', 'https://youtu.be/t172SCu4QU0', 'functional', 'Fight Fit', 'Treino completo para todo o corpo', 3, false);

-- BORA ASSESSORIA (CORRIDA)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended) VALUES
('Apresentação', '8 min', 8, 'Iniciante', 'https://youtu.be/E6xtScc3pYk', 'running', 'Bora Assessoria', 'Conheça a Bora Assessoria e metodologia de treino', 1, true),
('Técnica de Corrida', '20 min', 20, 'Iniciante', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'running', 'Bora Assessoria', 'Aprenda a correr corretamente', 2, false),
('Aquecimento para Corrida', '15 min', 15, 'Iniciante', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'running', 'Bora Assessoria', 'Prepare seu corpo para correr', 3, false),
('Treino Intervalado', '45 min', 45, 'Intermediário', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'running', 'Bora Assessoria', 'Melhore sua velocidade', 4, false),
('Corrida de Resistência', '60 min', 60, 'Avançado', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'running', 'Bora Assessoria', 'Aumente sua resistência', 5, false),
('Alongamento Pós-Corrida', '20 min', 20, 'Iniciante', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'running', 'Bora Assessoria', 'Recuperação muscular', 6, false);

-- THE UNIT (FISIOTERAPIA)
INSERT INTO workout_videos (title, duration, duration_minutes, difficulty, youtube_url, category, instructor_name, description, order_index, is_recommended) VALUES
('Apresentação', '10 min', 10, 'Iniciante', 'https://youtu.be/Q_dlMnGgIPo', 'physiotherapy', 'The Unit', 'Introdução à fisioterapia preventiva no esporte', 1, true),
('Mobilidade para Iniciantes', '30 min', 30, 'Iniciante', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'physiotherapy', 'The Unit', 'Exercícios básicos de mobilidade', 2, false),
('Prevenção de Lesões - Joelho', '35 min', 35, 'Iniciante', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'physiotherapy', 'The Unit', 'Fortaleça seus joelhos', 3, false),
('Prevenção de Lesões - Coluna', '40 min', 40, 'Intermediário', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'physiotherapy', 'The Unit', 'Cuide da sua coluna', 4, false),
('Mobilidade Avançada', '45 min', 45, 'Avançado', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'physiotherapy', 'The Unit', 'Exercícios avançados de mobilidade', 5, false),
('Recuperação Ativa', '25 min', 25, 'Iniciante', 'https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow', 'physiotherapy', 'The Unit', 'Exercícios de recuperação', 6, false);

-- Marcar alguns vídeos como novos e populares
UPDATE workout_videos SET is_new = true 
WHERE created_at > NOW() - INTERVAL '30 days';

UPDATE workout_videos SET is_popular = true 
WHERE is_recommended = true; 