-- =====================================================
-- SISTEMA COMPLETO DE NOTIFICAÇÕES - RAY CLUB
-- =====================================================

-- 1. Criar tabela de templates de notificações
CREATE TABLE IF NOT EXISTS public.notification_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category TEXT NOT NULL,         -- Ex: 'receita', 'desafio', 'pdf', 'treino'
  trigger_type TEXT NOT NULL,     -- Ex: 'manha', 'sem_treino', 'ultrapassado'
  title TEXT,                     -- Opcional
  body TEXT NOT NULL,             -- Mensagem da notificação
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Adicionar campo fcm_token à tabela profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS fcm_token TEXT;

-- 3. Inserir templates de notificações
INSERT INTO public.notification_templates (category, trigger_type, title, body)
VALUES 
-- Notificações de manhã
('receita', 'manha', 'Bom dia, Ray!', 'Que tal um café da manhã saudável? Veja nossa receita especial para começar o dia com energia! 🥣'),
('motivacao', 'manha', 'Hora de brilhar!', 'Um novo dia chegou! Que tal registrar um treino e conquistar seus objetivos? 💪'),
('agua', 'manha', 'Hidrate-se!', 'Lembre-se de beber água! Comece o dia hidratando seu corpo 💧'),

-- Notificações de tarde
('treino', 'tarde', 'Pausa para o treino!', 'Que tal uma pausa para se exercitar? Seus músculos vão agradecer! 🏃‍♀️'),
('receita', 'tarde', 'Lanche saudável', 'Hora do lanche! Confira nossas opções saudáveis para manter a energia 🍎'),
('desafio', 'tarde', 'Desafio em andamento', 'Como está seu desafio hoje? Registre seu progresso e mantenha-se no topo! 🏆'),

-- Notificações de noite
('reflexao', 'noite', 'Fim de dia', 'Como foi seu dia? Registre seus treinos e veja seu progresso! ⭐'),
('receita', 'noite', 'Jantar nutritivo', 'Hora do jantar! Que tal uma refeição balanceada para encerrar o dia? 🍽️'),
('sono', 'noite', 'Boa noite!', 'Lembre-se: um bom sono é essencial para a recuperação muscular. Durma bem! 😴'),

-- Notificações comportamentais
('treino', 'sem_treino', 'Sentimos sua falta!', 'Você não registrou treinos hoje. Que tal uma atividade rápida? Seu corpo agradece! 💪'),
('desafio', 'ultrapassado', 'Alerta de ranking!', 'Você foi ultrapassado no desafio! Registre um treino agora e recupere sua posição! 💢'),
('meta', 'meta_atingida', 'Parabéns!', 'Meta atingida! Você está no caminho certo. Continue assim! 🎉'),
('agua', 'pouca_agua', 'Hidrate-se mais!', 'Você bebeu pouca água hoje. Que tal um copo agora? 💧'),

-- Notificações de conteúdo
('pdf', 'hipertrofia', 'Guia de Hipertrofia', 'Buscando ganhar massa? Baixe nosso guia completo de treinos e alimentação! 📚'),
('pdf', 'emagrecimento', 'Guia de Emagrecimento', 'Quer perder peso de forma saudável? Confira nosso guia especializado! 📖'),
('video', 'novo_treino', 'Novo treino disponível!', 'Um novo vídeo de treino foi adicionado! Venha conferir 🎥'),
('receita', 'nova_receita', 'Nova receita!', 'Uma deliciosa receita foi adicionada ao app. Não perca! 👩‍🍳'),

-- Notificações de comunidade
('social', 'novo_post', 'Atividade na comunidade', 'Há novidades no feed! Veja o que a comunidade Ray está compartilhando 👥'),
('social', 'curtida', 'Seu post foi curtido!', 'Alguém curtiu seu post! Veja a interação na comunidade ❤️'),
('beneficio', 'novo_cupom', 'Novo benefício!', 'Um novo cupom exclusivo está disponível para você! 🎁'),
('beneficio', 'cupom_expirando', 'Cupom expirando!', 'Seu cupom expira em breve! Não perca a oportunidade de usar 🏃‍♀️')

ON CONFLICT DO NOTHING;

-- 4. Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_notification_templates_trigger_type 
ON public.notification_templates(trigger_type);

CREATE INDEX IF NOT EXISTS idx_notification_templates_category 
ON public.notification_templates(category);

CREATE INDEX IF NOT EXISTS idx_profiles_fcm_token 
ON public.profiles(fcm_token) WHERE fcm_token IS NOT NULL;

-- 5. Habilitar RLS na tabela notification_templates
ALTER TABLE public.notification_templates ENABLE ROW LEVEL SECURITY;

-- Política para permitir leitura dos templates (para a função)
CREATE POLICY "notification_templates_select_policy" ON public.notification_templates
FOR SELECT USING (true);

-- 6. Função para buscar templates por trigger_type
CREATE OR REPLACE FUNCTION get_notification_templates(p_trigger_type TEXT)
RETURNS TABLE (
  id UUID,
  category TEXT,
  trigger_type TEXT,
  title TEXT,
  body TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    nt.id,
    nt.category,
    nt.trigger_type,
    nt.title,
    nt.body
  FROM notification_templates nt
  WHERE nt.trigger_type = p_trigger_type;
END;
$$;

-- 7. Função para buscar usuários com FCM token
CREATE OR REPLACE FUNCTION get_users_with_fcm_token()
RETURNS TABLE (
  id UUID,
  fcm_token TEXT,
  name TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.fcm_token,
    p.name
  FROM profiles p
  WHERE p.fcm_token IS NOT NULL 
    AND p.fcm_token != '';
END;
$$;

-- 8. Comentários para documentação
COMMENT ON TABLE notification_templates IS 'Templates de notificações para envio automático baseado em triggers';
COMMENT ON COLUMN notification_templates.category IS 'Categoria da notificação (receita, treino, desafio, etc.)';
COMMENT ON COLUMN notification_templates.trigger_type IS 'Tipo de trigger que ativa a notificação (manha, tarde, noite, sem_treino, etc.)';
COMMENT ON COLUMN notification_templates.title IS 'Título da notificação (opcional)';
COMMENT ON COLUMN notification_templates.body IS 'Corpo da mensagem da notificação';

COMMENT ON COLUMN profiles.fcm_token IS 'Token FCM para envio de notificações push';

-- 9. Verificar se tudo foi criado corretamente
DO $$
BEGIN
  -- Verificar se a tabela foi criada
  IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'notification_templates') THEN
    RAISE NOTICE 'Tabela notification_templates criada com sucesso';
  END IF;
  
  -- Verificar se o campo fcm_token foi adicionado
  IF EXISTS (SELECT FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'fcm_token') THEN
    RAISE NOTICE 'Campo fcm_token adicionado à tabela profiles com sucesso';
  END IF;
  
  -- Contar templates inseridos
  DECLARE
    template_count INTEGER;
  BEGIN
    SELECT COUNT(*) INTO template_count FROM notification_templates;
    RAISE NOTICE 'Total de templates inseridos: %', template_count;
  END;
END $$;
