-- Script para atualizar as tabelas de treinos no Supabase
-- Execute este script no SQL Editor do Supabase
-- Versão simplificada para evitar problemas de sintaxe

-- Certifique-se de que a extensão UUID está habilitada
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Adicionar colunas necessárias (ignora erro se a coluna já existir)
BEGIN;

-- Maneira mais simples: tente adicionar e capture qualquer erro silenciosamente
ALTER TABLE workouts ADD COLUMN sections JSONB DEFAULT '[]';
-- Se der erro, continue com os próximos comandos

ALTER TABLE workouts ADD COLUMN equipment JSONB DEFAULT '[]';
-- Se der erro, continue com os próximos comandos

ALTER TABLE workouts ADD COLUMN is_public BOOLEAN DEFAULT TRUE;
-- Se der erro, continue com os próximos comandos

-- Garantir que as políticas RLS estão configuradas corretamente
ALTER TABLE workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE workout_categories ENABLE ROW LEVEL SECURITY;

-- Criar ou substituir políticas RLS
DROP POLICY IF EXISTS "Workouts são visíveis para todos" ON workouts;
CREATE POLICY "Workouts são visíveis para todos" ON workouts
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Categorias são visíveis para todos" ON workout_categories;
CREATE POLICY "Categorias são visíveis para todos" ON workout_categories
  FOR SELECT USING (true);

-- Atualizar os dados de exemplo nas tabelas
-- Adicionar exercícios a um treino existente como exemplo

-- Atualizar o treino "Treino HIIT para Iniciantes" (se existir)
UPDATE workouts
SET sections = '[
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
    "name": "Circuito HIIT",
    "exercises": [
      {
        "id": "ex-003",
        "name": "Mountain climbers",
        "detail": "Em posição de prancha, traga os joelhos alternadamente ao peito",
        "sets": 4,
        "duration": 30,
        "rest_seconds": 10,
        "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/mountain_climbers.jpg"
      },
      {
        "id": "ex-004",
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
WHERE title = 'Treino HIIT para Iniciantes';

-- Atualizar o treino "Treino de Força para Pernas" (se existir)
UPDATE workouts
SET sections = '[
  {
    "name": "Aquecimento",
    "exercises": [
      {
        "id": "ex-005",
        "name": "Mobilidade de quadril",
        "detail": "Movimentos circulares com o quadril",
        "sets": 1,
        "reps": 10,
        "rest_seconds": 0,
        "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/hip_mobility.jpg"
      },
      {
        "id": "ex-006",
        "name": "Agachamento corporal",
        "detail": "Agachamento simples sem peso para aquecimento",
        "sets": 1,
        "reps": 15,
        "rest_seconds": 0,
        "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/bodyweight_squat.jpg"
      }
    ]
  },
  {
    "name": "Circuito Principal",
    "exercises": [
      {
        "id": "ex-007",
        "name": "Agachamento com barra",
        "detail": "Posicione a barra nos ombros e agache mantendo a coluna reta",
        "sets": 4,
        "reps": 12,
        "rest_seconds": 90,
        "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/barbell_squat.jpg"
      },
      {
        "id": "ex-008",
        "name": "Leg press",
        "detail": "Empurre a plataforma com os pés na posição adequada",
        "sets": 4,
        "reps": 15,
        "rest_seconds": 90,
        "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/leg_press.jpg"
      },
      {
        "id": "ex-009",
        "name": "Cadeira extensora",
        "detail": "Estenda as pernas levantando o peso com os quadríceps",
        "sets": 3,
        "reps": 15,
        "rest_seconds": 60,
        "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/leg_extension.jpg"
      }
    ]
  }
]'
WHERE title = 'Treino de Força para Pernas';

-- Atualizar o treino "Treino de Abdômen em 10 minutos" (se existir)
UPDATE workouts
SET sections = '[
  {
    "name": "Circuito Abdominal",
    "exercises": [
      {
        "id": "ex-010",
        "name": "Crunch abdominal",
        "detail": "Deite-se e flexione o tronco em direção aos joelhos",
        "sets": 3,
        "reps": 20,
        "rest_seconds": 30,
        "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/crunch.jpg"
      },
      {
        "id": "ex-011",
        "name": "Prancha",
        "detail": "Mantenha-se apoiado nos antebraços e pontas dos pés",
        "sets": 3,
        "duration": 45,
        "rest_seconds": 30,
        "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/plank.jpg"
      },
      {
        "id": "ex-012",
        "name": "Russian twist",
        "detail": "Sentado, gire o tronco de um lado para o outro",
        "sets": 3,
        "reps": 30,
        "rest_seconds": 30,
        "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/russian_twist.jpg"
      }
    ]
  }
]'
WHERE title = 'Treino de Abdômen em 10 minutos';

-- Adicionar equipamentos aos treinos existentes
UPDATE workouts SET equipment = '["Corda", "Tênis"]'
WHERE title = 'Treino HIIT para Iniciantes';

UPDATE workouts SET equipment = '["Barra", "Anilhas", "Leg Press", "Cadeira Extensora"]'
WHERE title = 'Treino de Força para Pernas';

UPDATE workouts SET equipment = '["Colchonete"]'
WHERE title = 'Treino de Abdômen em 10 minutos';

-- Para adicionar mais treinos se não existirem, apenas como exemplo
INSERT INTO workouts (title, description, image_url, category, level, duration_minutes, equipment, sections)
VALUES 
  (
    'Treino de Yoga para Relaxamento',
    'Sequência de posturas de yoga para relaxamento e flexibilidade',
    'https://images.unsplash.com/photo-1545205597-3d9d02c29597',
    'yoga',
    'iniciante',
    20,
    '["Tapete de Yoga"]',
    '[
      {
        "name": "Pranayama",
        "exercises": [
          {
            "id": "ex-013",
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
            "id": "ex-014",
            "name": "Postura da montanha",
            "detail": "Posição ereta com pés juntos e mãos ao lado do corpo",
            "sets": 1,
            "duration": 60,
            "rest_seconds": 10,
            "image_url": "https://raw.githubusercontent.com/marcelloc97/ray-club-assets/main/exercises/mountain_pose.jpg"
          },
          {
            "id": "ex-015",
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
  );

COMMIT; 