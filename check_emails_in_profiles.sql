-- Script para verificar quais emails estão cadastrados na tabela profiles
-- e retornar os user_ids correspondentes

-- CONSULTA 1: Lista completa com status de cada email
WITH email_list AS (
  SELECT unnest(ARRAY[
    'isabelacribeiro122@gmail.com',
    'camilacorreaviana@hotmail.com',
    'isabelamedeiros01@yahoo.com.br',
    'anarezende.rezende@gmail.com',
    'raquelmqz@gmail.com',
    'anarezende.rezende@gmail.com', -- duplicado, mas vamos manter para verificação
    'brunalorenavp@icloud.com',
    'criisiinhaa.27@gmail.com',
    'mylenax.matos25@gmail.com',
    'anavitoria.galmeida@gmail.com',
    'anavitoria.galmeida@gmail.com', -- duplicado
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
)
SELECT 
  p.id AS user_id,
  p.email,
  p.name,
  p.created_at,
  CASE 
    WHEN p.email IS NOT NULL THEN 'Cadastrado'
    ELSE 'Não cadastrado'
  END AS status
FROM email_list el
LEFT JOIN profiles p ON LOWER(el.email) = LOWER(p.email)
ORDER BY 
  CASE WHEN p.email IS NOT NULL THEN 0 ELSE 1 END, -- Cadastrados primeiro
  el.email;

-- CONSULTA 2: Resumo estatístico (execute separadamente)
/*
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
)
SELECT 
  COUNT(DISTINCT p.email) AS emails_cadastrados,
  COUNT(DISTINCT el.email) AS total_emails_verificados,
  COUNT(DISTINCT el.email) - COUNT(DISTINCT p.email) AS emails_nao_cadastrados
FROM email_list el
LEFT JOIN profiles p ON LOWER(el.email) = LOWER(p.email);
*/

-- CONSULTA 3: Lista apenas os emails cadastrados (execute separadamente)
/*
SELECT 
  p.id AS user_id,
  p.email,
  p.name
FROM profiles p
WHERE LOWER(p.email) IN (
  'isabelacribeiro122@gmail.com',
  'camilacorreaviana@hotmail.com',
  'isabelamedeiros01@yahoo.com.br',
  'anarezende.rezende@gmail.com',
  'raquelmqz@gmail.com',
  'brunalorenavp@icloud.com',
  'criisiinhaa.27@gmail.com',
  'mylenax.matos25@gmail.com',
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
)
ORDER BY p.email;
*/ 