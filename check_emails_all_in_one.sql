-- Script completo que executa todas as verificações de uma vez
-- Retorna múltiplos resultados em uma única execução

WITH email_list AS (
  SELECT unnest(ARRAY[
    'isabelacribeiro122@gmail.com',
    'camilacorreaviana@hotmail.com',
    'isabelamedeiros01@yahoo.com.br',
    'anarezende.rezende@gmail.com',
    'raquelmqz@gmail.com',
    'anarezende.rezende@gmail.com',
    'brunalorenavp@icloud.com',
    'criisiinhaa.27@gmail.com',
    'mylenax.matos25@gmail.com',
    'anavitoria.galmeida@gmail.com',
    'anavitoria.galmeida@gmail.com',
    'fernandaabreupsico@gmail.com',
    'lorranamsobreira@gmail.com',
    'jenniamaral.f@gmail.com',
    'izabellarodrigues91@yahoo.com.br',
    'gabrielamarcoal@gmail.com',
    'bellabahillon@gmail.com',
    'flaviamartins8979@gmail.com',
    'carolisss9@icloud.com',
    'isabelagsfonseca@icloud.com'
  ]) AS email
),
email_check AS (
  SELECT 
    el.email AS email_verificado,
    p.id AS user_id,
    p.email AS email_cadastrado,
    p.name,
    p.created_at,
    CASE 
      WHEN p.email IS NOT NULL THEN true
      ELSE false
    END AS cadastrado
  FROM email_list el
  LEFT JOIN profiles p ON LOWER(el.email) = LOWER(p.email)
),
summary AS (
  SELECT 
    COUNT(DISTINCT CASE WHEN cadastrado THEN email_cadastrado END) AS emails_cadastrados,
    COUNT(DISTINCT email_verificado) AS total_emails_verificados,
    COUNT(DISTINCT CASE WHEN NOT cadastrado THEN email_verificado END) AS emails_nao_cadastrados
  FROM email_check
)
-- Resultado combinado
SELECT 
  'RESUMO' as tipo_resultado,
  NULL::uuid as user_id,
  'Total de emails cadastrados: ' || emails_cadastrados || 
  ' | Total verificados: ' || total_emails_verificados || 
  ' | Não cadastrados: ' || emails_nao_cadastrados as info,
  NULL as email,
  NULL as name,
  NULL::timestamp as created_at
FROM summary

UNION ALL

SELECT 
  'CADASTRADO' as tipo_resultado,
  user_id,
  'Usuário encontrado' as info,
  email_cadastrado as email,
  name,
  created_at
FROM email_check
WHERE cadastrado = true

UNION ALL

SELECT 
  'NAO_CADASTRADO' as tipo_resultado,
  NULL::uuid as user_id,
  'Email não encontrado' as info,
  email_verificado as email,
  NULL as name,
  NULL::timestamp as created_at
FROM email_check
WHERE cadastrado = false

ORDER BY 
  CASE tipo_resultado 
    WHEN 'RESUMO' THEN 1
    WHEN 'CADASTRADO' THEN 2
    WHEN 'NAO_CADASTRADO' THEN 3
  END,
  email; 