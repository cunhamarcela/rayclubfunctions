-- Script para investigar onde um campo "status" está sendo referenciado no banco de dados
-- Executa uma análise aprofundada para encontrar referências ao campo "status"
-- em triggers, funções, views e outros objetos do banco de dados

-- 1. Verificar definições de triggers que contêm referência a "status"
DO $$
DECLARE
  trigger_info RECORD;
  trigger_src TEXT;
BEGIN
  RAISE NOTICE '=== INVESTIGAÇÃO DE REFERÊNCIAS AO CAMPO STATUS ===';
  RAISE NOTICE '';
  RAISE NOTICE '1. TRIGGERS QUE REFERENCIAM "STATUS":';
  
  FOR trigger_info IN (
    SELECT 
      t.tgname AS trigger_name,
      c.relname AS table_name,
      pg_get_triggerdef(t.oid) AS trigger_definition
    FROM pg_trigger t
    JOIN pg_class c ON c.oid = t.tgrelid
    ORDER BY c.relname, t.tgname
  ) LOOP
    trigger_src := trigger_info.trigger_definition;
    
    IF trigger_src ILIKE '%status%' OR 
       trigger_src ILIKE '%new.status%' OR 
       trigger_src ILIKE '%old.status%' THEN
      RAISE NOTICE 'Tabela: % | Trigger: %', trigger_info.table_name, trigger_info.trigger_name;
      RAISE NOTICE 'Definição: %', trigger_src;
      RAISE NOTICE '---';
    END IF;
  END LOOP;
END $$;

-- 2. Verificar funções que contêm referência a "status"
DO $$
DECLARE
  function_info RECORD;
  function_src TEXT;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '2. FUNÇÕES QUE REFERENCIAM "STATUS":';
  
  FOR function_info IN (
    SELECT 
      p.proname AS function_name,
      n.nspname AS schema_name,
      p.oid
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
    ORDER BY n.nspname, p.proname
  ) LOOP
    BEGIN
      -- Usar TRY/CATCH para evitar erros
      SELECT pg_get_functiondef(function_info.oid) INTO function_src;
      
      IF function_src ILIKE '%status%' OR 
         function_src ILIKE '%new.status%' OR 
         function_src ILIKE '%old.status%' THEN
        RAISE NOTICE 'Esquema: % | Função: %', function_info.schema_name, function_info.function_name;
        RAISE NOTICE 'Definição (primeiros 200 caracteres): %', substring(function_src, 1, 200) || '...';
        RAISE NOTICE '---';
      END IF;
    EXCEPTION WHEN OTHERS THEN
      -- Silenciosamente ignorar erros de definição de função
      NULL;
    END;
  END LOOP;
END $$;

-- 3. Verificar views que contêm referência a "status"
DO $$
DECLARE
  view_info RECORD;
  view_src TEXT;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '3. VIEWS QUE REFERENCIAM "STATUS":';
  
  FOR view_info IN (
    SELECT 
      c.relname AS view_name,
      n.nspname AS schema_name,
      pg_get_viewdef(c.oid) AS view_definition
    FROM pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid
    WHERE c.relkind = 'v' -- 'v' é para view
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
    ORDER BY n.nspname, c.relname
  ) LOOP
    view_src := view_info.view_definition;
    
    IF view_src ILIKE '%status%' THEN
      RAISE NOTICE 'Esquema: % | View: %', view_info.schema_name, view_info.view_name;
      RAISE NOTICE 'Definição (primeiros 200 caracteres): %', substring(view_src, 1, 200) || '...';
      RAISE NOTICE '---';
    END IF;
  END LOOP;
END $$;

-- 4. Verificar colunas "status" em tabelas relacionadas a check-ins e desafios
DO $$
DECLARE
  column_info RECORD;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '4. COLUNAS "STATUS" EM TABELAS RELACIONADAS:';
  
  FOR column_info IN (
    SELECT 
      c.table_name,
      c.column_name,
      c.data_type,
      c.column_default,
      c.is_nullable
    FROM information_schema.columns c
    WHERE c.column_name ILIKE '%status%'
    AND c.table_schema = 'public'
    ORDER BY c.table_name, c.column_name
  ) LOOP
    RAISE NOTICE 'Tabela: % | Coluna: % | Tipo: % | Default: % | Nullable: %', 
      column_info.table_name, 
      column_info.column_name, 
      column_info.data_type,
      COALESCE(column_info.column_default, 'NULL'),
      column_info.is_nullable;
  END LOOP;
END $$;

-- 5. Verificar referências específicas em funções relacionadas a check-ins
DO $$
DECLARE
  function_info RECORD;
  function_src TEXT;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '5. FUNÇÕES RELACIONADAS A CHECK-INS:';
  
  FOR function_info IN (
    SELECT 
      p.proname AS function_name,
      n.nspname AS schema_name,
      p.oid
    FROM pg_proc p
    JOIN pg_namespace n ON p.pronamespace = n.oid
    WHERE (p.proname ILIKE '%check%in%' OR 
           p.proname ILIKE '%checkin%' OR
           p.proname ILIKE '%challenge%')
    AND n.nspname NOT IN ('pg_catalog', 'information_schema')
    ORDER BY n.nspname, p.proname
  ) LOOP
    BEGIN
      -- Tentar obter a definição de função com tratamento de erro
      SELECT pg_get_functiondef(function_info.oid) INTO function_src;
      
      -- Mostrar a função e extrair (se possível) texto com referência a 'status'
      RAISE NOTICE 'Esquema: % | Função: %', function_info.schema_name, function_info.function_name;
      
      IF function_src ILIKE '%status%' THEN
        RAISE NOTICE 'CONTÉM REFERÊNCIA A STATUS! Trecho: %', 
          substring(function_src from position('status' in lower(function_src))-20 for 60);
      END IF;
      
      RAISE NOTICE '---';
    EXCEPTION WHEN OTHERS THEN
      -- Ignorar silenciosamente erros
      NULL;
    END;
  END LOOP;
END $$;

-- Instruções para interpretar os resultados:
-- 1. Procure por triggers que mencionam "new.status" - estes são os mais prováveis causadores do erro
-- 2. Verifique funções relacionadas a check-ins que tentam acessar esse campo
-- 3. Confirme se há alguma coluna "status" em tabelas que a função utiliza
-- 4. Uma vez identificada a origem, você pode:
--    - Desabilitar o trigger específico
--    - Modificar a função para lidar com a ausência do campo
--    - Adicionar temporariamente o campo status à tabela 