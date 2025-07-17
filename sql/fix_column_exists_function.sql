-- Primeiro excluir a função existente
DROP FUNCTION IF EXISTS public.column_exists(text, text);

-- Agora criar a função corrigida
CREATE OR REPLACE FUNCTION public.column_exists(
  table_name text,
  column_name text
) RETURNS boolean AS $$
DECLARE
  column_exists boolean;
BEGIN
  -- Qualificar todas as referências a colunas com o nome da tabela/alias para evitar ambiguidade
  SELECT EXISTS (
    SELECT 1
    FROM information_schema.columns AS cols
    WHERE cols.table_schema = 'public'
      AND cols.table_name = table_name
      AND cols.column_name = column_name
  ) INTO column_exists;
  
  RETURN column_exists;
END;
$$ LANGUAGE plpgsql; 