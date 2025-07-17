-- Criação de tabela e funções para análise de uso e otimização de desempenho
-- Esta estrutura permite monitorar o desempenho e uso da aplicação na Fase 4

-- Tabela para armazenar métricas de uso e desempenho
CREATE TABLE IF NOT EXISTS usage_analytics (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,      -- Tipo de evento (page_view, api_call, error, etc)
  resource_type TEXT,            -- Tipo de recurso associado (challenge, benefit, etc)
  resource_id TEXT,              -- ID do recurso específico, se aplicável
  device_info JSONB,             -- Informações sobre o dispositivo
  performance_metrics JSONB,     -- Métricas de desempenho (tempo de carregamento, etc)
  error_info JSONB,              -- Informações detalhadas de erros, se aplicável
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  session_id TEXT,               -- ID de sessão para agrupar eventos
  app_version TEXT               -- Versão do aplicativo
);

-- Índices para consultas eficientes
CREATE INDEX IF NOT EXISTS idx_usage_analytics_user ON usage_analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_usage_analytics_event ON usage_analytics(event_type);
CREATE INDEX IF NOT EXISTS idx_usage_analytics_resource ON usage_analytics(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_usage_analytics_session ON usage_analytics(session_id);
CREATE INDEX IF NOT EXISTS idx_usage_analytics_date ON usage_analytics(created_at);

-- Função para registrar um evento de análise
CREATE OR REPLACE FUNCTION record_analytics_event(
  p_user_id UUID,
  p_event_type TEXT,
  p_resource_type TEXT DEFAULT NULL,
  p_resource_id TEXT DEFAULT NULL,
  p_device_info JSONB DEFAULT NULL,
  p_performance_metrics JSONB DEFAULT NULL,
  p_error_info JSONB DEFAULT NULL,
  p_session_id TEXT DEFAULT NULL,
  p_app_version TEXT DEFAULT NULL
) RETURNS UUID AS $$
DECLARE
  new_id UUID;
BEGIN
  INSERT INTO usage_analytics (
    user_id,
    event_type,
    resource_type,
    resource_id,
    device_info,
    performance_metrics,
    error_info,
    session_id,
    app_version
  ) VALUES (
    p_user_id,
    p_event_type,
    p_resource_type,
    p_resource_id,
    p_device_info,
    p_performance_metrics,
    p_error_info,
    p_session_id,
    p_app_version
  ) RETURNING id INTO new_id;
  
  RETURN new_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para obter métricas de desempenho por tipo de recurso
CREATE OR REPLACE FUNCTION get_performance_metrics(
  p_resource_type TEXT,
  p_start_date TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  p_end_date TIMESTAMP WITH TIME ZONE DEFAULT NULL
) RETURNS TABLE (
  resource_id TEXT,
  avg_load_time FLOAT,
  p95_load_time FLOAT,
  error_rate FLOAT,
  total_views BIGINT
) AS $$
BEGIN
  RETURN QUERY
  WITH 
    -- Filtra os eventos pelo período especificado
    filtered_events AS (
      SELECT * FROM usage_analytics
      WHERE resource_type = p_resource_type
        AND (p_start_date IS NULL OR created_at >= p_start_date)
        AND (p_end_date IS NULL OR created_at <= p_end_date)
    ),
    
    -- Calcula tempos de carregamento
    load_times AS (
      SELECT 
        resource_id,
        (performance_metrics->>'loadTime')::FLOAT AS load_time
      FROM filtered_events
      WHERE event_type = 'page_view'
        AND performance_metrics IS NOT NULL
        AND performance_metrics->>'loadTime' IS NOT NULL
    ),
    
    -- Conta erros
    errors AS (
      SELECT 
        resource_id,
        COUNT(*) AS error_count
      FROM filtered_events
      WHERE event_type = 'error'
      GROUP BY resource_id
    ),
    
    -- Conta visualizações totais
    views AS (
      SELECT 
        resource_id,
        COUNT(*) AS view_count
      FROM filtered_events
      WHERE event_type = 'page_view'
      GROUP BY resource_id
    )
    
  -- Combina os resultados em uma única tabela
  SELECT 
    l.resource_id,
    AVG(l.load_time) AS avg_load_time,
    PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY l.load_time) AS p95_load_time,
    COALESCE(e.error_count, 0)::FLOAT / NULLIF(v.view_count, 0) AS error_rate,
    v.view_count AS total_views
  FROM load_times l
  LEFT JOIN errors e ON l.resource_id = e.resource_id
  JOIN views v ON l.resource_id = v.resource_id
  GROUP BY l.resource_id, e.error_count, v.view_count
  ORDER BY v.view_count DESC;
END;
$$ LANGUAGE plpgsql;

-- Função para identificar recursos que devem ser pré-carregados com base no uso
CREATE OR REPLACE FUNCTION get_frequently_accessed_resources(
  p_user_id UUID,
  p_limit INT DEFAULT 10
) RETURNS TABLE (
  resource_type TEXT,
  resource_id TEXT,
  access_count BIGINT,
  last_accessed TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    resource_type,
    resource_id,
    COUNT(*) AS access_count,
    MAX(created_at) AS last_accessed
  FROM usage_analytics
  WHERE user_id = p_user_id
    AND event_type = 'page_view'
    AND resource_type IS NOT NULL
    AND resource_id IS NOT NULL
    AND created_at > now() - INTERVAL '7 days'
  GROUP BY resource_type, resource_id
  ORDER BY access_count DESC, last_accessed DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Função para limpar dados de análise antigos (manter por 90 dias)
CREATE OR REPLACE FUNCTION clean_old_analytics_data()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM usage_analytics
  WHERE created_at < now() - INTERVAL '90 days'
  RETURNING COUNT(*) INTO deleted_count;
  
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Configura RLS (Row Level Security) para a tabela
ALTER TABLE usage_analytics ENABLE ROW LEVEL SECURITY;

-- Política para permitir que usuários inserem apenas seus próprios eventos
CREATE POLICY usage_analytics_insert_policy 
ON usage_analytics 
FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Política para permitir que usuários vejam apenas seus próprios eventos
CREATE POLICY usage_analytics_select_policy 
ON usage_analytics 
FOR SELECT 
USING (auth.uid() = user_id OR auth.uid() IN (
  SELECT user_id FROM profiles WHERE is_admin = true
)); 