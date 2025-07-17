-- Script simplificado para retornar apenas os emails cadastrados e seus user_ids

SELECT 
  id AS user_id,
  email,
  name
FROM profiles
WHERE LOWER(email) IN (
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
ORDER BY email; 