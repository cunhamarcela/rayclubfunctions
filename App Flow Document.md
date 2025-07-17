App Flow Document

Este documento descreve o fluxo completo de navegação e uso do app **Ray Club** de forma detalhada, como um mapa para o desenvolvimento.

---

## Onboarding

Quando o usuário instala e abre o app pela primeira vez, ele vê **um único slide de introdução** com uma mensagem sobre bem-estar e incentivo a cuidar de si mesma. Ao final do slide, há opções para **"Login"** ou **"Criar Conta"**.

Usuários não logados não podem acessar telas internas do app. Eles só vêm a Home com banners e cards limitados.

---

## Login e Cadastro

Usuário pode:
- Entrar com email e senha
- Criar conta com email e senha
- Entrar com Google (login social via Supabase)

---

## Home

Depois de logado, o usuário acessa a **Home**.

Ela possui:
- Banner Promocional rotativo no topo
- Saudacão personalizada com o primeiro nome do usuário
- Mini Dashboard com:
  - Dias de treino na semana
  - Dias consecutivos de treino
  - Progresso com barra visual
  - Botão de registrar treino (também presente na tela de Treinos)
- Categorias de Treino em carrossel (Yoga, Pilates, etc.)
- Treinos populares em cards
- Cards criativos que redirecionam para conteúdos específicos do app ("Treino na Praia", "Receita sem Glúten")
- Seção "Conteúdos para você" com cards ilustrados

---

## Treinos

Tela com listas de treinos divididas por **categorias**:
- Yoga
- Pilates
- Funcional
- HIIT
- Luta
- Cardio
- Express (10min)
- Em casa

Usuário pode **filtrar por tempo** de treino (10, 20, 30+ minutos) ou tipo. Cada treino leva para uma **tela de detalhe**.

---

## Registrar Treino

Ao clicar em "Registrar Treino":
- Abre um modal ou tela com opção de:
  - Adicionar descrição
  - Adicionar foto do treino
  - Escolher um template pré-pronto
  - Escolher se deseja compartilhar esse treino na Comunidade ou apenas registrar

Treinos registrados alimentam o sistema de **Desafios**.

---

## Dieta (Nutrição)

Tela com 3 seções principais:
- Dicas da Nutri
- Receitas da Ray (criativas, simples, saudáveis)
- Receitas especiais com tags (sem glúten, pré-treino, etc.)

Cada item leva para uma **tela de conteúdo detalhado** com imagem ilustrativa, ingredientes e preparo.

---

## Benefícios

Tela dividida em:
- **QR Code** para retirar benefício com parceiros (um por vez)
- **Cupons** promocionais da Ray
- **Grupo VIP** com link para WhatsApp

---

## Comunidade

Feed social fechado com:
- Enquetes criadas pelo app
- Postagens de usuários com:
  - Foto do treino
  - Texto curto
  - Templates
- Opção de curtir, denunciar conteúdo, e compartilhar
- Moderação forte (tudo passa por sistema de segurança)

---

## Perfil

O perfil do usuário possui:
- Nome, email, tipo de conta
- Opções de:
  - Editar dados
  - Trocar senha
  - Sair
  - Acessar configurações

---

## Configurações

Tela com:
- Ativar/desativar notificações
- Sobre o App
- Termos de Uso
- Política de Privacidade

---

## Desafios

### Desafio da Ray
- Aberto para todos os usuários
- Acontece 2x ao ano
- Todos os treinos registrados contam ponto
- Há ranking com:
  - 3 usuários acima do logado
  - 3 abaixo
  - Avatar/nome/pontuação
- Prêmios e conquistas no final

### Subdesafios
- Criados por usuários assinantes
- Privados: acesso só por convite
- Cada treino registrado vale ponto
- Podem ter regras personalizadas
- Há ranking (visualização idêntica)
- Benefícios exclusivos para quem estiver no topo

---

## Notificações

Sistema robusto de notificações para:
- Entrada em desafio
- Perda de liderança
- Convite para subdesafio
- Conteúdo novo
- Cupons ou eventos liberados

Inclui:
- Push Notification
- Badges
- Alertas visuais na Home

---

## Navegação

Barra inferior com 5 abas:
- Início
- Treinos
- Comunidade
- Nutrição
- Perfil

Botão flutuante de "Registrar Treino" nas telas Home e Treinos.

---

