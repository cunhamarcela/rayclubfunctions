-- Script para configurar ambiente de teste com workouts no Supabase
-- Execute este script no SQL Editor do Supabase

-- Verifica se as tabelas já existem, caso contrário, cria-as
BEGIN;

-- Certifique-se de que a extensão UUID está habilitada
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Tabela de treinos (se não existir)
CREATE TABLE IF NOT EXISTS workouts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT,
  image_url TEXT,
  type TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL,
  difficulty TEXT NOT NULL,
  equipment JSONB DEFAULT '[]',
  sections JSONB DEFAULT '[]',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  creator_id UUID REFERENCES auth.users(id),
  is_public BOOLEAN DEFAULT TRUE
);

-- Tabela de categorias de treinos (se não existir)
CREATE TABLE IF NOT EXISTS workout_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  image_url TEXT,
  order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS (Segurança em Nível de Linha)
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_categories ENABLE ROW LEVEL SECURITY;

-- Criar políticas RLS que permitam acesso aos dados durante testes
CREATE POLICY IF NOT EXISTS "Workouts são visíveis para todos"
  ON workouts FOR SELECT USING (true);

CREATE POLICY IF NOT EXISTS "Categorias são visíveis para todos"
  ON workout_categories FOR SELECT USING (true);

-- Dados de categorias para teste
INSERT INTO workout_categories (name, description, image_url, order)
VALUES 
  ('Cardio', 'Treinos para melhorar sua capacidade cardiovascular', 'https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/categories/cardio.png', 1),
  ('Força', 'Treinos focados no aumento de força muscular', 'https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/categories/strength.png', 2),
  ('Yoga', 'Treinos para melhorar flexibilidade e equilíbrio', 'https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/categories/yoga.png', 3),
  ('HIIT', 'Treinos intervalados de alta intensidade', 'https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/categories/hiit.png', 4),
  ('Funcional', 'Treinos com movimentos naturais do corpo', 'https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/categories/functional.png', 5)
ON CONFLICT (name) DO NOTHING;

-- Dados de exemplo para treinos
INSERT INTO workouts (title, description, type, duration_minutes, difficulty, image_url, equipment, sections)
VALUES
  (
    'Cardio Intenso',
    'Treino cardiovascular de alta intensidade para queima calórica',
    'Cardio',
    30,
    'Avançado',
    'https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/workouts/cardio.jpg',
    '["Corda", "Tênis"]',
    '[
      {
        "name": "Aquecimento",
        "exercises": [
          {
            "id": "ex-001",
            "name": "Polichinelos",
            "detail": "Exercício de aquecimento completo",
            "sets": 1,
            "reps": 20,
            "rest_seconds": 30,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/jumping_jacks.jpg"
          },
          {
            "id": "ex-002",
            "name": "Corrida no lugar",
            "detail": "Simule uma corrida parado no mesmo lugar",
            "sets": 1,
            "duration": 60,
            "rest_seconds": 30,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/running_place.jpg"
          }
        ]
      },
      {
        "name": "Circuito Principal",
        "exercises": [
          {
            "id": "ex-003",
            "name": "Pular corda",
            "detail": "Pule corda em ritmo acelerado",
            "sets": 3,
            "duration": 60,
            "rest_seconds": 30,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/jump_rope.jpg"
          },
          {
            "id": "ex-004",
            "name": "Burpees",
            "detail": "Exercício completo com agachamento, prancha e salto",
            "sets": 3,
            "reps": 15,
            "rest_seconds": 60,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/burpee.jpg"
          }
        ]
      }
    ]'
  ),
  (
    'Treino de Força - Membros Superiores',
    'Treino focado em desenvolvimendo de força para braços, costas e ombros',
    'Força',
    45,
    'Intermediário',
    'https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/workouts/strength.jpg',
    '["Halteres", "Barra"]',
    '[
      {
        "name": "Aquecimento",
        "exercises": [
          {
            "id": "ex-005",
            "name": "Rotação de ombros",
            "detail": "Movimento circular com os ombros para aquecimento",
            "sets": 1,
            "reps": 20,
            "rest_seconds": 0,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/shoulder_rotation.jpg"
          },
          {
            "id": "ex-006",
            "name": "Flexões de parede",
            "detail": "Versão simplificada de flexão para aquecimento",
            "sets": 1,
            "reps": 15,
            "rest_seconds": 30,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/wall_pushups.jpg"
          }
        ]
      },
      {
        "name": "Parte Principal",
        "exercises": [
          {
            "id": "ex-007",
            "name": "Supino com halteres",
            "detail": "Deitado com costas apoiadas, empurre os halteres para cima",
            "sets": 4,
            "reps": 12,
            "rest_seconds": 90,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/dumbbell_bench.jpg"
          },
          {
            "id": "ex-008",
            "name": "Remada curvada",
            "detail": "Com tronco inclinado, puxe os halteres em direção ao abdômen",
            "sets": 4,
            "reps": 12,
            "rest_seconds": 90,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/bent_row.jpg"
          }
        ]
      }
    ]'
  ),
  (
    'Yoga para Iniciantes',
    'Sequência de posturas de yoga para relaxamento e flexibilidade',
    'Yoga',
    20,
    'Iniciante',
    'https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/workouts/yoga.jpg',
    '["Tapete"]',
    '[
      {
        "name": "Pranayama",
        "exercises": [
          {
            "id": "ex-009",
            "name": "Respiração profunda",
            "detail": "Técnica de respiração lenta e profunda",
            "sets": 1,
            "duration": 180,
            "rest_seconds": 0,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/deep_breathing.jpg"
          }
        ]
      },
      {
        "name": "Asanas",
        "exercises": [
          {
            "id": "ex-010",
            "name": "Postura da montanha",
            "detail": "Posição ereta com pés juntos e mãos ao lado do corpo",
            "sets": 1,
            "duration": 60,
            "rest_seconds": 10,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/mountain_pose.jpg"
          },
          {
            "id": "ex-011",
            "name": "Postura do cachorro olhando para baixo",
            "detail": "Mãos e pés no chão formando um triângulo com o corpo",
            "sets": 1,
            "duration": 60,
            "rest_seconds": 10,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/downward_dog.jpg"
          }
        ]
      }
    ]'
  ),
  (
    'HIIT Express',
    'Treino intervalado curto e intenso para máxima queima calórica',
    'HIIT',
    15,
    'Intermediário',
    'https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/workouts/hiit.jpg',
    '[]',
    '[
      {
        "name": "Aquecimento",
        "exercises": [
          {
            "id": "ex-012",
            "name": "Marcha no lugar",
            "detail": "Marcha rápida elevando os joelhos",
            "sets": 1,
            "duration": 60,
            "rest_seconds": 0,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/high_knees.jpg"
          }
        ]
      },
      {
        "name": "Circuito HIIT",
        "exercises": [
          {
            "id": "ex-013",
            "name": "Mountain climbers",
            "detail": "Em posição de prancha, traga os joelhos alternadamente ao peito",
            "sets": 4,
            "duration": 30,
            "rest_seconds": 10,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/mountain_climbers.jpg"
          },
          {
            "id": "ex-014",
            "name": "Agachamento com salto",
            "detail": "Agache e salte explosivamente para cima",
            "sets": 4,
            "duration": 30,
            "rest_seconds": 10,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/jump_squat.jpg"
          }
        ]
      }
    ]'
  ),
  (
    'Treino Funcional Completo',
    'Treino baseado em movimentos naturais para melhorar força e mobilidade',
    'Funcional',
    40,
    'Intermediário',
    'https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/workouts/functional.jpg',
    '["Kettlebell", "Caixa de salto"]',
    '[
      {
        "name": "Mobilidade",
        "exercises": [
          {
            "id": "ex-015",
            "name": "Mobilidade de quadril",
            "detail": "Movimentos circulares com o quadril",
            "sets": 1,
            "reps": 10,
            "rest_seconds": 0,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/hip_mobility.jpg"
          },
          {
            "id": "ex-016",
            "name": "World\'s greatest stretch",
            "detail": "Alongamento completo para todo o corpo",
            "sets": 1,
            "reps": 6,
            "rest_seconds": 0,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/greatest_stretch.jpg"
          }
        ]
      },
      {
        "name": "Circuito Funcional",
        "exercises": [
          {
            "id": "ex-017",
            "name": "Swing com kettlebell",
            "detail": "Movimento pendular com kettlebell",
            "sets": 3,
            "reps": 15,
            "rest_seconds": 45,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/kettlebell_swing.jpg"
          },
          {
            "id": "ex-018",
            "name": "Box jumps",
            "detail": "Saltos sobre caixa",
            "sets": 3,
            "reps": 10,
            "rest_seconds": 45,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/box_jump.jpg"
          }
        ]
      }
    ]'
  )
ON CONFLICT DO NOTHING;

COMMIT; 