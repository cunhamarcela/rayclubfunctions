-- Atualizar o esquema da tabela workout_records para permitir tanto a nomenclatura camelCase (usada no Flutter) 
-- quanto a snake_case (preferida pelo PostgreSQL)

-- Criação de uma view/função para fazer o mapeamento entre os campos
CREATE OR REPLACE FUNCTION map_json_fields()
RETURNS TRIGGER AS $$
BEGIN
    -- Mapear campos camelCase -> snake_case
    NEW.user_id = NEW.userId;
    NEW.workout_id = NEW.workoutId;
    NEW.workout_name = NEW.workoutName;
    NEW.workout_type = NEW.workoutType;
    NEW.duration_minutes = NEW.durationMinutes;
    NEW.is_completed = NEW.isCompleted;
    NEW.created_at = NEW.createdAt;
    
    -- Remover os campos camelCase originais para que não sejam salvos no banco
    NEW.userId = NULL;
    NEW.workoutId = NULL;
    NEW.workoutName = NULL;
    NEW.workoutType = NULL;
    NEW.durationMinutes = NULL;
    NEW.isCompleted = NULL;
    NEW.createdAt = NULL;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para mapear os campos na inserção
DROP TRIGGER IF EXISTS map_camel_case_fields ON workout_records;
CREATE TRIGGER map_camel_case_fields
BEFORE INSERT ON workout_records
FOR EACH ROW
EXECUTE FUNCTION map_json_fields();

-- Adicionar um exemplo para testar
-- INSERT INTO workout_records (
--   id, userId, workoutName, workoutType, date, durationMinutes, isCompleted, notes
-- ) VALUES (
--   uuid_generate_v4(), 
--   '01d4a292-1873-4af6-948b-a55eed56d6b9',
--   'Teste Manual', 
--   'Funcional', 
--   NOW(), 
--   30, 
--   TRUE, 
--   'Teste direto do SQL'
-- ); 