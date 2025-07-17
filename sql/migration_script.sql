-- Ray Club App - Script de Migração para o Supabase
-- Este script cria as tabelas necessárias e configura as políticas de segurança

-- Habilitar extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -------------------------------------------------------------
-- TABELAS PARA FAQ E SUPORTE
-- -------------------------------------------------------------

-- Tabela para FAQs
CREATE TABLE IF NOT EXISTS public.faqs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  category TEXT,
  order_index INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Tabela para mensagens de suporte
CREATE TABLE IF NOT EXISTS public.support_messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  message TEXT NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'resolved')),
  response TEXT,
  response_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- -------------------------------------------------------------
-- TABELAS PARA NOTIFICAÇÕES
-- -------------------------------------------------------------

-- Tabela para notificações
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT NOT NULL,
  read_at TIMESTAMP WITH TIME ZONE,
  action_link TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now() NOT NULL
);

-- Índice para melhorar performance em notificações por usuário
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);

-- -------------------------------------------------------------
-- POLÍTICAS DE SEGURANÇA
-- -------------------------------------------------------------

-- Ativar RLS para todas as tabelas
ALTER TABLE IF EXISTS public.faqs ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.support_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.notifications ENABLE ROW LEVEL SECURITY;

-- Políticas para FAQs (leitura pública, escrita apenas para administradores)
CREATE POLICY IF NOT EXISTS "FAQs são visíveis para todos"
ON public.faqs FOR SELECT
USING (true);

CREATE POLICY IF NOT EXISTS "Apenas administradores podem modificar FAQs"
ON public.faqs FOR INSERT
TO authenticated
WITH CHECK (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = true));

CREATE POLICY IF NOT EXISTS "Apenas administradores podem atualizar FAQs"
ON public.faqs FOR UPDATE
TO authenticated
USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = true));

-- Políticas para mensagens de suporte
CREATE POLICY IF NOT EXISTS "Usuários autenticados podem enviar mensagens de suporte"
ON public.support_messages FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "Administradores podem ver mensagens de suporte"
ON public.support_messages FOR SELECT
TO authenticated
USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = true));

CREATE POLICY IF NOT EXISTS "Administradores podem atualizar mensagens de suporte"
ON public.support_messages FOR UPDATE
TO authenticated
USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = true));

-- Políticas para notificações
CREATE POLICY IF NOT EXISTS "Usuários podem ver suas próprias notificações"
ON public.notifications FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Usuários podem atualizar suas próprias notificações"
ON public.notifications FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Administradores podem criar notificações"
ON public.notifications FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() IN (SELECT id FROM public.users WHERE is_admin = true)
  OR
  auth.uid() = user_id
);

-- -------------------------------------------------------------
-- FUNÇÕES E TRIGGERS
-- -------------------------------------------------------------

-- Função para atualizar o timestamp "updated_at"
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar o "updated_at" nas FAQs
DROP TRIGGER IF EXISTS set_updated_at_faqs ON public.faqs;
CREATE TRIGGER set_updated_at_faqs
BEFORE UPDATE ON public.faqs
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- Trigger para atualizar o "updated_at" nas mensagens de suporte
DROP TRIGGER IF EXISTS set_updated_at_support_messages ON public.support_messages;
CREATE TRIGGER set_updated_at_support_messages
BEFORE UPDATE ON public.support_messages
FOR EACH ROW
EXECUTE FUNCTION public.set_updated_at();

-- -------------------------------------------------------------
-- INSERÇÃO DE DADOS DE EXEMPLO (APENAS PARA DESENVOLVIMENTO)
-- -------------------------------------------------------------

-- Inserir algumas FAQs de exemplo (apenas se a tabela estiver vazia)
INSERT INTO public.faqs (question, answer, category, order_index)
SELECT 
  'Como criar um treino personalizado?', 
  'Para criar um treino personalizado, acesse a seção Treinos, toque no botão "+" no canto inferior direito e selecione "Criar treino". Escolha os exercícios, defina séries e repetições e salve seu treino.',
  'Treinos',
  1
WHERE NOT EXISTS (SELECT 1 FROM public.faqs);

INSERT INTO public.faqs (question, answer, category, order_index)
SELECT 
  'Como participar de um desafio?', 
  'Na seção Desafios, você encontrará desafios disponíveis. Selecione o desafio desejado e toque em "Participar". Você também pode criar seu próprio desafio tocando em "Criar desafio".',
  'Desafios',
  2
WHERE NOT EXISTS (SELECT 1 FROM public.faqs LIMIT 1 OFFSET 1);

INSERT INTO public.faqs (question, answer, category, order_index)
SELECT 
  'Posso usar o app sem internet?', 
  'Sim, o Ray Club funciona offline para a maioria das funcionalidades. Treinos baixados previamente, seu perfil e estatísticas ficam disponíveis. A sincronização ocorre automaticamente quando você se reconectar.',
  'Geral',
  3
WHERE NOT EXISTS (SELECT 1 FROM public.faqs LIMIT 1 OFFSET 2); 