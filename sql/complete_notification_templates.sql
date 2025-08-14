-- =====================================================
-- SISTEMA COMPLETO DE NOTIFICAÇÕES - RAY CLUB
-- Templates baseados no conteúdo real e comportamento dos usuários
-- =====================================================

-- Primeiro, vamos limpar os templates existentes e recriar com a estrutura completa
TRUNCATE TABLE notification_templates;

-- =====================================================
-- 🌞 NOTIFICAÇÕES POR HORÁRIO DO DIA
-- =====================================================

-- MANHÃ (6h-10h)
INSERT INTO notification_templates (category, trigger_type, title, body) VALUES
('receita', 'manha', 'Bom dia, Ray!', 'Bom dia! Que tal um café da manhã saudável? Veja nossa receita de [nome_receita] 🥣'),
('motivacao', 'manha', 'Energia para o dia!', 'Um novo dia chegou! Que tal começar com um treino energizante? 💪'),
('agua', 'manha', 'Hidrate-se!', 'Comece o dia hidratando seu corpo! Beba um copo de água agora 💧'),
('treino', 'manha', 'Treino matinal', 'Que tal um treino matinal para despertar o corpo? Temos opções de 15 minutos! ⏰'),

-- TARDE (12h-16h) 
('receita', 'tarde', 'Hora do lanche!', 'Hora do lanche? Descubra uma receita leve e gostosa no app 😋'),
('treino', 'tarde', 'Pausa ativa', 'Que tal uma pausa ativa? Um treino rápido pode renovar sua energia! 🔋'),
('pilates', 'tarde', 'Pilates da tarde', 'Relaxe a mente com um Pilates: alongue, respire e fortaleça seu corpo 🧘‍♀️'),
('funcional', 'tarde', 'Treino funcional', 'Movimente o corpo com nosso treino funcional! Sem equipamentos necessários 🏃'),

-- NOITE (18h-21h)
('receita', 'noite', 'Jantar saudável', 'Experimente uma receita leve para o jantar e feche o dia com bem-estar 🥗'),
('reflexao', 'noite', 'Fim de dia', 'Como foi seu dia? Registre seus treinos e veja seu progresso! ⭐'),
('mobilidade', 'noite', 'Relaxamento', 'Sinta-se melhor com um treino de mobilidade: ideal para aliviar tensões 💆'),
('sono', 'noite', 'Boa noite!', 'Lembre-se: um bom sono é essencial para a recuperação. Durma bem! 😴');

-- =====================================================
-- 🎯 NOTIFICAÇÕES BASEADAS EM METAS E PROGRESSO
-- =====================================================

INSERT INTO notification_templates (category, trigger_type, title, body) VALUES
-- Metas semanais
('meta', 'meta_semanal_risco', 'Meta da semana', 'Você está a [x] treinos da sua meta da semana. Ainda dá tempo de conquistar! 🎯'),
('meta', 'meta_semanal_atingida', 'Parabéns!', 'Você completou sua meta semanal! 🎉 Veja seu progresso no dashboard'),
('meta', 'inicio_semana', 'Nova semana', 'Configure suas metas da semana e acompanhe seu progresso no dashboard 📊'),

-- Metas diárias
('meta', 'meta_diaria_risco', 'Meta do dia', 'Faltam [x] treinos para sua meta diária. Você consegue! 💪'),
('meta', 'meta_diaria_atingida', 'Meta do dia!', 'Meta diária conquistada! Continue assim e alcance grandes resultados 🌟'),

-- Progresso geral
('progresso', 'primeira_meta', 'Primeira conquista!', 'Parabéns! Você completou sua primeira meta 🏆 Este é só o começo!'),
('progresso', 'sequencia_perdida', 'Vamos retomar?', 'Sua sequência foi interrompida, mas não desista! Recomeçar faz parte 🔄'),
('progresso', 'sequencia_alta', 'Sequência incrível!', 'Você está com [x] dias consecutivos! Que disciplina inspiradora! 🔥');

-- =====================================================
-- 🎥 NOTIFICAÇÕES POR TIPO DE TREINO
-- =====================================================

INSERT INTO notification_templates (category, trigger_type, title, body) VALUES
-- Pilates
('pilates', 'novo_pilates', 'Novo Pilates!', 'Novo vídeo de Pilates no ar 🧘‍♀️ Alongue, respire e fortaleça seu corpo agora mesmo'),
('pilates', 'pilates_recomendado', 'Pilates para você', 'Baseado no seu perfil, que tal um Pilates relaxante? 🕯️'),

-- Musculação
('musculacao', 'novo_musculacao', 'Treino de força!', 'Já viu nosso treino de musculação de hoje? Curto, direto e potente! 💥'),
('musculacao', 'musculacao_recomendado', 'Hora da força', 'Que tal fortalecer os músculos hoje? Temos treinos de 20 a 45 minutos 🏋️‍♀️'),

-- Funcional
('funcional', 'novo_funcional', 'Treino funcional!', 'Movimente o corpo com nosso treino funcional do dia! Sem equipamentos 🏃'),
('funcional', 'funcional_recomendado', 'Movimento livre', 'Treino funcional: movimentos naturais para um corpo mais ágil 🤸‍♀️'),

-- Mobilidade/Fisioterapia
('mobilidade', 'novo_mobilidade', 'Mobilidade nova!', 'Sinta-se melhor com um treino de mobilidade: ideal para aliviar dores 💆'),
('mobilidade', 'mobilidade_recomendado', 'Cuide do corpo', 'Que tal cuidar das articulações com exercícios de mobilidade? 🦴'),

-- Cardio
('cardio', 'novo_cardio', 'Cardio novo!', 'Acelere o coração com nosso novo treino cardio! Queime calorias e se divirta 🔥'),
('cardio', 'cardio_recomendado', 'Queima de energia', 'Hora de acelerar o metabolismo com um cardio energizante! ⚡');

-- =====================================================
-- 💥 NOTIFICAÇÕES DE DESAFIOS
-- =====================================================

INSERT INTO notification_templates (category, trigger_type, title, body) VALUES
-- Ranking e competição
('desafio', 'ultrapassado', 'Alerta de ranking!', 'Alerta! Você foi ultrapassado no desafio 💢 Registre um treino e recupere sua posição!'),
('desafio', 'subindo_ranking', 'Subindo no ranking!', 'Você está subindo no ranking! Continue assim e chegue ao topo! 📈'),
('desafio', 'top_5', 'Top 5!', 'Você está entre os 5 melhores do desafio! Continue e desbloqueie benefícios 🏆'),
('desafio', 'lider', 'Líder do desafio!', 'Você é o líder do desafio! Mantenha o ritmo e inspire outros participantes 👑'),

-- Participação em desafios
('desafio', 'desafio_sem_treino', 'Desafio ativo', 'Você está no desafio, mas ainda não registrou treino essa semana. Vai deixar barato? 💪'),
('desafio', 'novo_desafio', 'Novo desafio!', 'Um novo desafio começou! Participe e compete com a comunidade Ray 🎯'),
('desafio', 'desafio_terminando', 'Reta final!', 'O desafio termina em breve! Últimas chances de subir no ranking 🏃‍♀️'),

-- Conquistas em desafios
('desafio', 'primeira_posicao', 'Primeiro lugar!', 'Parabéns! Você conquistou o primeiro lugar no desafio! 🥇'),
('desafio', 'podium', 'No pódium!', 'Você terminou no pódium do desafio! Que performance incrível! 🏅'),
('desafio', 'desafio_concluido', 'Desafio concluído!', 'Você completou o desafio! Veja sua colocação final e próximos desafios 🎊');

-- =====================================================
-- 📚 NOTIFICAÇÕES DE CONTEÚDO ESPECIALIZADO
-- =====================================================

INSERT INTO notification_templates (category, trigger_type, title, body) VALUES
-- PDFs e eBooks
('pdf', 'ebook_hipertrofia', 'Guia de Hipertrofia', 'Buscando hipertrofia? Baixe o guia completo de treinos e alimentação para ganho de massa! 📚'),
('pdf', 'ebook_emagrecimento', 'Guia de Emagrecimento', 'Quer acelerar a queima de gordura? Veja nosso guia de emagrecimento saudável 🥦'),
('pdf', 'ebook_vegano', 'Alimentação Vegana', 'Alimentação vegana? Temos um PDF completo com receitas e dicas 🫐🌱'),
('pdf', 'ebook_sazonal_inverno', 'eBook de Inverno', 'O frio chegou! Baixe nosso eBook de receitas e dicas saudáveis para o inverno ❄️'),
('pdf', 'ebook_sazonal_verao', 'eBook de Verão', 'Receitas e dicas para dias mais leves: confira nosso eBook de verão 🌞'),

-- Receitas específicas
('receita', 'nova_receita', 'Nova receita!', 'Tem receita nova no ar! Veja o passo a passo de [nome_receita] no app 👩‍🍳'),
('receita', 'receita_vegana', 'Receita vegana', 'Descobra uma deliciosa receita vegana: saudável e cheia de sabor! 🌱'),
('receita', 'receita_proteica', 'Receita proteica', 'Que tal uma receita rica em proteínas para potencializar seus treinos? 🥩'),
('receita', 'receita_low_carb', 'Receita low carb', 'Receita low carb fresquinha: sabor sem culpa! 🥑');

-- =====================================================
-- 🎯 NOTIFICAÇÕES COMPORTAMENTAIS
-- =====================================================

INSERT INTO notification_templates (category, trigger_type, title, body) VALUES
-- Inatividade
('comportamento', 'sem_treino_1dia', 'Sentimos sua falta!', 'Você não registrou treinos ontem. Que tal uma atividade leve hoje? 💙'),
('comportamento', 'sem_treino_2dias', 'Vamos retomar?', 'Sinto sua falta por aqui! Que tal voltar com um treino leve ou uma receita nova? 🤗'),
('comportamento', 'sem_treino_semana', 'Uma semana sem você', 'Uma semana sem treinos! Que tal recomeçar com algo simples e gostoso? 🌟'),

-- Engajamento positivo
('comportamento', 'treino_curto', 'Cada minuto conta!', 'Parabéns por se mover! Mesmo 20 minutos contam no seu progresso 🌟'),
('comportamento', 'treino_longo', 'Que dedicação!', 'Treino de [x] minutos! Sua dedicação é inspiradora! 💪'),
('comportamento', 'primeiro_treino', 'Primeiro treino!', 'Parabéns pelo seu primeiro treino registrado! Este é o início de uma jornada incrível 🎉'),

-- Hidratação
('agua', 'pouca_agua', 'Hidrate-se mais!', 'Você bebeu pouca água hoje. Que tal um copo agora? Seu corpo agradece! 💧'),
('agua', 'meta_agua', 'Meta de água!', 'Parabéns! Você atingiu sua meta de hidratação hoje! 🏆'),

-- Uso do app
('app', 'primeiro_acesso', 'Bem-vindo(a)!', 'Bem-vindo(a) ao Ray Club! Explore treinos, receitas e desafios incríveis 🚀'),
('app', 'volta_ao_app', 'Que bom te ver!', 'Que bom ter você de volta! Veja as novidades que preparamos 😊'),
('app', 'usuario_ativo', 'Usuário dedicado!', 'Você tem usado o app todos os dias! Que disciplina admirável! 🔥');

-- =====================================================
-- 🎁 NOTIFICAÇÕES DE BENEFÍCIOS E CUPONS
-- =====================================================

INSERT INTO notification_templates (category, trigger_type, title, body) VALUES
-- Cupons e benefícios
('beneficio', 'novo_cupom', 'Novo benefício!', 'Um novo cupom exclusivo está disponível para você! Não perca! 🎁'),
('beneficio', 'cupom_expirando', 'Cupom expirando!', 'Seu cupom expira em breve! Não perca a oportunidade de usar 🏃‍♀️'),
('beneficio', 'cupom_usado', 'Cupom utilizado!', 'Ótima escolha! Seu cupom foi utilizado com sucesso. Aproveite! ✨'),
('beneficio', 'parceiro_novo', 'Nova parceria!', 'Temos um novo parceiro! Descubra benefícios exclusivos para você 🤝'),

-- Comunidade e social
('social', 'novo_post', 'Atividade na comunidade', 'Há novidades no feed! Veja o que a comunidade Ray está compartilhando 👥'),
('social', 'curtida', 'Seu post foi curtido!', 'Alguém curtiu seu post! Veja a interação na comunidade ❤️'),
('social', 'comentario', 'Novo comentário!', 'Você recebeu um comentário no seu post! Veja o que disseram 💬'),
('social', 'seguidor', 'Novo seguidor!', 'Você tem um novo seguidor na comunidade! Sua jornada inspira outros 👏');

-- =====================================================
-- VERIFICAR INSERÇÃO
-- =====================================================

-- Contar templates por categoria
SELECT category, COUNT(*) as total 
FROM notification_templates 
GROUP BY category 
ORDER BY total DESC;

-- Contar templates por trigger_type
SELECT trigger_type, COUNT(*) as total 
FROM notification_templates 
GROUP BY trigger_type 
ORDER BY total DESC;

-- Total geral
SELECT COUNT(*) as total_templates FROM notification_templates;
