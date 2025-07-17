# Ray Club - Project Requirements Document (PRD)

## 🌟 Visão Geral do App
**Ray Club** é um recurso para o seu bem estar. Trata-se de um aplicativo mobile voltado para usuários interessados em treinos, nutrição, desafios e uma comunidade focada em bem-estar físico e mental. O app oferece funcionalidades como registro de treino, desafios gamificados, conteúdos interativos, QR codes de parceiros, receitas, e muito mais – tudo organizado em uma experiência visual minimalista e intuitiva.

---

## 🔄 Fluxo de Usuário (User Flow)
- App inicia na **tela de onboarding**, com 1 slide introdutório.
- Usuários não logados têm acesso apenas à **tela Home**.
- Ao clicar em "Começar" ou outra ação, o usuário é levado para a **tela de login/cadastro**, com opção de login com Google.
- Após logado, o usuário acessa todas as funcionalidades:
  - **Home**: banner, progresso semanal, categorias, conteúdos em destaque, registrar treino
  - **Treinos**: filtrado por tempo e categoria (yoga, pilates, luta, funcional, cardio etc.)
  - **Nutrição**: dicas da nutri, receitas da Ray, receitas funcionais
  - **Benefícios**: cupons, QR codes, comunidade VIP
  - **Desafios**: desafio da Ray e subdesafios privados
  - **Comunidade**: feed seguro com enquetes, templates, compartilhamentos
  - **Perfil**: editar dados, trocar senha, sair, etc.
  - **Configurações**: termos, política, preferências de notificação

---

## 🚀 Tech Stack & APIs
### Frontend:
- **Flutter** com **Riverpod**
- Arquitetura **MVVM**
- Fonte principal: `Poppins`

### Backend:
- **Node.js**
- Banco de dados: **PostgreSQL** via Supabase
- Autenticação: Supabase Auth (inclusive social login)
- Notificações push: previsto via Firebase Messaging (ou similar)

### API de terceiros:
- Supabase
- Firebase (para push notifications)
- WhatsApp (link p/ grupo vip)

---

## 🛌 Funcionalidades Principais
### Core
- Login/cadastro (com Google)
- Registro de treino com foto, descrição e templates
- Feed social com interações limitadas, curtir e denunciar
- Dashboard de progresso semanal com dias marcados
- Cards interativos com redirecionamento para conteúdo
- Navegação inferior entre abas

### Desafios & Gamificação
- Desafio da Ray (2x por ano)
- Subdesafios (criados por assinantes)
  - Entrada por convite
  - Cada treino registrado soma 1 ponto
  - Rankings mostram os 3 acima e abaixo do usuário
  - Sistema de desbloqueio de benefícios p/ ganhadores

### Conteúdo & Categorias
- Categorias de treino com cards e imagem ilustrativa
- Conteúdos como: treino para mães, yoga para calorias, receitas pré-treino com 2 ingredientes, etc.
- Cards sempre com ilustrações, nada realista
- Tela de detalhes para todos os cards clicáveis

### Benefícios
- QR Code dinâmico p/ parceiros
- Cupons exclusivos para assinantes
- Link para grupo VIP no WhatsApp

### Nutrição
- Sessão de receitas e dicas da nutri
- Receitas da Ray

### Comunidade
- Feed com enquetes, templates, postagens
- Compartilhar treino (foto + descrição)
- Moderação de conteúdo e segurança

### Perfil e Configurações
- Editar dados
- Trocar senha
- Sair
- Preferências de notificação
- Termos, política e sobre o app

### Facilitar a troca de imagens de perfil

---

## ✅ Escopo
### Incluído:
- Todo o fluxo de onboarding, login, home, perfis e conteúdos
- Funcionalidades completas de desafio e subdesafio
- Integração com Supabase para auth, DB e storage
- Backend em Node.js com estrutura modular
- Cards com imagem ilustrativa e copy criativa
- QR code e cupons integrados por tela de benefício

### Fora do escopo (por enquanto):
- Chat entre usuários
- CMS para gestão de conteúdo
- Web app (versão mobile apenas)

---

## ⚖️ Estrutura de Usuários
- Usuários gratuitos: acesso limitado
- Assinantes: acesso a todos os conteúdos, subdesafios e benefícios
- Visitantes (não logados): acesso apenas à home (sem ações interativas)

---

## 🚨 Regras de Negócio Importantes
- Cada registro de treino alimenta a pontuação de desafios ativos
- Subdesafios apenas por convite e restritos a assinantes
- Desafios podem oferecer desbloqueios de benefícios
- Notificações push para eventos importantes do desafio (ex: perdeu liderança, novo membro, etc.)

---

## 🌈 Observações de Estilo
- Estética clean, minimalista, foco em tipografia e espaçamento
- Fonte: `Poppins`
- Cards com cantos arredondados (16px), sombra suave, gradientes leves
- Paleta com marrom terroso, verde oliva, tons off-white e cinza claro

