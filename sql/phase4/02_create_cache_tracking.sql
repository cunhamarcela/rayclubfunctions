-- Criação de tabela para rastrear cache de recursos e automatizar invalidação de cache
-- Esta estrutura permite um sistema eficiente de gerenciamento de cache na Fase 4

-- Tabela para rastrear recursos em cache
CREATE TABLE IF NOT EXISTS cache_tracking (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  resource_type TEXT NOT NULL,    -- Tipo de recurso (challenges, benefits, etc)
  resource_id TEXT NOT NULL,      -- ID do recurso específico ou "all" para coleção completa
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  version INT DEFAULT 1 NOT NULL, -- Versão incremental do recurso
  metadata JSONB DEFAULT '{}'     -- Metadados adicionais sobre o recurso
);

-- Índice para busca eficiente por tipo e ID de recurso
CREATE INDEX IF NOT EXISTS idx_cache_tracking_resource 
ON cache_tracking(resource_type, resource_id);

-- Função para atualizar a versão de um recurso em cache
-- Isso permite que o cliente saiba se seu cache está desatualizado
CREATE OR REPLACE FUNCTION update_cache_version(
  p_resource_type TEXT,
  p_resource_id TEXT
) RETURNS INT AS $$
DECLARE
  new_version INT;
BEGIN
  -- Verificar se o registro existe
  PERFORM 1 FROM cache_tracking 
  WHERE resource_type = p_resource_type AND resource_id = p_resource_id;
  
  -- Se existir, atualiza a versão e timestamp
  IF FOUND THEN
    UPDATE cache_tracking 
    SET version = version + 1, 
        last_updated = now()
    WHERE resource_type = p_resource_type AND resource_id = p_resource_id
    RETURNING version INTO new_version;
  -- Se não existir, cria um novo registro
  ELSE
    INSERT INTO cache_tracking (resource_type, resource_id)
    VALUES (p_resource_type, p_resource_id)
    RETURNING version INTO new_version;
  END IF;
  
  -- Também atualiza a coleção "all" para este tipo de recurso
  PERFORM update_collection_cache_version(p_resource_type);
  
  RETURN new_version;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para atualizar a versão de uma coleção inteira
CREATE OR REPLACE FUNCTION update_collection_cache_version(
  p_resource_type TEXT
) RETURNS INT AS $$
DECLARE
  new_version INT;
BEGIN
  -- Verificar se o registro da coleção existe
  PERFORM 1 FROM cache_tracking 
  WHERE resource_type = p_resource_type AND resource_id = 'all';
  
  -- Se existir, atualiza a versão e timestamp
  IF FOUND THEN
    UPDATE cache_tracking 
    SET version = version + 1, 
        last_updated = now()
    WHERE resource_type = p_resource_type AND resource_id = 'all'
    RETURNING version INTO new_version;
  -- Se não existir, cria um novo registro
  ELSE
    INSERT INTO cache_tracking (resource_type, resource_id)
    VALUES (p_resource_type, 'all')
    RETURNING version INTO new_version;
  END IF;
  
  RETURN new_version;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter informações de cache
CREATE OR REPLACE FUNCTION get_cache_info(
  p_resource_type TEXT,
  p_resource_id TEXT DEFAULT NULL
) RETURNS TABLE (
  resource_id TEXT,
  version INT,
  last_updated TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  -- Se resource_id for null, retornar informações da coleção
  IF p_resource_id IS NULL THEN
    RETURN QUERY
    SELECT 
      ct.resource_id,
      ct.version,
      ct.last_updated
    FROM cache_tracking ct
    WHERE ct.resource_type = p_resource_type
    ORDER BY ct.last_updated DESC;
  ELSE
    -- Retornar informações do recurso específico
    RETURN QUERY
    SELECT 
      ct.resource_id,
      ct.version,
      ct.last_updated
    FROM cache_tracking ct
    WHERE ct.resource_type = p_resource_type 
      AND ct.resource_id = p_resource_id;
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Função para verificar se o cache do cliente está atualizado
CREATE OR REPLACE FUNCTION is_cache_valid(
  p_resource_type TEXT,
  p_resource_id TEXT,
  p_client_version INT
) RETURNS BOOLEAN AS $$
DECLARE
  server_version INT;
BEGIN
  -- Obtém a versão do servidor
  SELECT version INTO server_version
  FROM cache_tracking
  WHERE resource_type = p_resource_type AND resource_id = p_resource_id;
  
  -- Se não existir registro ou a versão do cliente for menor, o cache é inválido
  IF server_version IS NULL OR p_client_version < server_version THEN
    RETURN FALSE;
  END IF;
  
  -- Caso contrário, o cache é válido
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar automaticamente o cache ao inserir/atualizar challenges
CREATE OR REPLACE FUNCTION update_challenge_cache_trigger()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualiza a versão do recurso específico
  PERFORM update_cache_version('challenges', NEW.id::TEXT);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER challenge_cache_update_trigger
AFTER INSERT OR UPDATE ON challenges
FOR EACH ROW
EXECUTE FUNCTION update_challenge_cache_trigger();

-- Trigger para atualizar automaticamente o cache ao inserir/atualizar benefícios
CREATE OR REPLACE FUNCTION update_benefit_cache_trigger()
RETURNS TRIGGER AS $$
BEGIN
  -- Atualiza a versão do recurso específico
  PERFORM update_cache_version('benefits', NEW.id::TEXT);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER benefit_cache_update_trigger
AFTER INSERT OR UPDATE ON benefits
FOR EACH ROW
EXECUTE FUNCTION update_benefit_cache_trigger(); 