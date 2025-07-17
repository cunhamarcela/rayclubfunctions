-- Script com comandos SQL diretos para obter as políticas RLS
-- Execute estes comandos no SQL Editor do Supabase um por um

-- 1. Listar todas as políticas RLS existentes para a tabela challenge_group_members
SELECT * FROM pg_policies WHERE tablename = 'challenge_group_members';

-- 2. Obter script de criação das políticas RLS para essa tabela
-- (Se você estiver vendo este comentário, copie o comando abaixo e execute-o diretamente)
SELECT 'CREATE POLICY "' || policyname || '" ON ' || schemaname || '.' || tablename || 
       ' FOR ' || cmd || 
       ' TO ' || roles::text || 
       CASE WHEN qual IS NOT NULL THEN ' USING (' || qual || ')' ELSE '' END || 
       CASE WHEN with_check IS NOT NULL THEN ' WITH CHECK (' || with_check || ')' ELSE '' END || ';'
FROM pg_policies 
WHERE tablename = 'challenge_group_members';

-- 3. Alternativa: Verificar diretamente no esquema do Supabase
SELECT policy_definition FROM auth.policies 
WHERE table = 'challenge_group_members' OR table LIKE '%challenge_group_members%';

-- 4. Verificar se a tabela tem RLS habilitado
SHOW ROW LEVEL SECURITY;
SELECT relname, relrowsecurity FROM pg_class WHERE relname = 'challenge_group_members';

-- 5. Como último recurso, você pode tentar usar essa abordagem para extrair definições:
-- (Importante: substitua {sua_tabela} pelo nome real da tabela ao executar)
SELECT
  'CREATE POLICY ' || 
  quote_ident(polname) || 
  ' ON ' || 
  quote_ident(relname) || 
  ' AS ' || 
  CASE 
    WHEN polpermissive THEN 'PERMISSIVE'
    ELSE 'RESTRICTIVE'
  END || 
  ' FOR ' || 
  CASE polcmd
    WHEN 'r' THEN 'SELECT' 
    WHEN 'a' THEN 'INSERT'
    WHEN 'w' THEN 'UPDATE'
    WHEN 'd' THEN 'DELETE'
    WHEN '*' THEN 'ALL'
  END || 
  ' TO ' || 
  CASE WHEN polroles = '{0}' THEN 'PUBLIC' ELSE array_to_string(array(SELECT rolname FROM pg_roles WHERE oid = ANY(polroles)), ', ') END ||
  CASE 
    WHEN polqual IS NOT NULL THEN ' USING (' || pg_get_expr(polqual, polrelid) || ')'
    ELSE ''
  END || 
  CASE 
    WHEN polwithcheck IS NOT NULL THEN ' WITH CHECK (' || pg_get_expr(polwithcheck, polrelid) || ')'
    ELSE ''
  END || ';' as policy_definition
FROM pg_policy
JOIN pg_class ON pg_class.oid = pg_policy.polrelid
WHERE relname = 'challenge_group_members'; 