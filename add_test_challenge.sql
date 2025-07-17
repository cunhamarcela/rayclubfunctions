-- Verificar se já existem desafios com is_official = true
SELECT id, title, is_official, start_date, end_date
FROM challenges 
WHERE is_official = true;

-- Criar um novo desafio ativo agora para testes
INSERT INTO challenges (
  title, 
  description, 
  start_date, 
  end_date, 
  is_official,
  image_url
) VALUES (
  'Desafio Ray Club de Teste', 
  'Este é um desafio de teste criado automaticamente para verificar se o app está funcionando corretamente.',
  (CURRENT_TIMESTAMP - interval '1 day')::timestamptz, 
  (CURRENT_TIMESTAMP + interval '3 days')::timestamptz,
  true,
  'https://cdn.pixabay.com/photo/2016/03/27/23/00/weight-lifting-1284616_960_720.jpg'
) RETURNING id, title, start_date, end_date, is_official; 