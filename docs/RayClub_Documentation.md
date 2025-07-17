## Ray Club Documentation

Este documento contém toda a informação essencial para o Ray Club App, incluindo requisitos do projeto, fluxo do aplicativo, stack tecnológico, diretrizes de frontend e backend, e detalhes da implementação. O documento está atualizado com o estado atual do projeto (Março 2024).

---

### 1. Ray Club – Project Requirements Document

**Visão Geral do App:**
Ray Club é um aplicativo mobile para bem-estar, pensado para pessoas que desejam melhorar sua saúde física e mental por meio de treinos, nutrição, desafios gamificados e uma comunidade interativa. O app possibilita o registro de treinos com foto, descrição e templates, além de permitir acesso a receitas nutritivas, benefícios exclusivos – como QR codes para parceiros e cupons. O design é clean, minimalista e pautado em uma estética com tipografia Poppins, cores terrosas e espaçamentos generosos.

**Fluxos de Usuário:**
Ao instalar e iniciar o app, o usuário vê uma tela de onboarding com um único slide introdutório, contendo uma mensagem inspiradora e os botões "Login" e "Criar Conta". Usuários não autenticados só visualizam uma versão limitada da tela Home, que exibe banners rotativos, cards com conteúdos ilustrativos e uma saudação básica. Após fazer login ou criar conta – com opções de email/senha ou login social via Google – o usuário acessa a tela Home completa. Nesta, ele encontra um banner promocional, sua saudação personalizada, um mini dashboard com estatísticas dos treinos (dias treinados, sequência, barra de progresso) e acesso rápido ao "Registrar Treino". A navegação inferior padronizada possibilita a transição para outras áreas do app, como Treinos, Nutrição, Benefícios e Perfil.

**Tech Stack & APIs:**
- **Frontend:**
  - Framework: Flutter
  - Arquitetura: MVVM
  - Gerenciador de Estado: Riverpod
  - Navegação: auto_route
  - Bibliotecas UI: flutter_svg, cached_network_image, carousel_slider, entre outras
  - Comunicação HTTP: Dio (com tratamento de erros e retry)
  - Gerenciamento de ambiente: flutter_dotenv
  - Serialização: Freezed para modelos imutáveis

- **Backend:**
  - Banco de Dados: PostgreSQL (via Supabase)
  - Autenticação: Supabase Auth (implementado com login social Google)
  - Storage: Supabase Storage (bucket "workout_images" com RLS configurado)
  - Segurança: Row Level Security (RLS) implementado para todas as tabelas

**Core Features (Estado Atual):**
- ✅ Onboarding com slide introdutório (100%)
- ✅ Tela de Login/Cadastro com autenticação por email/senha e Google (100%)
- ✅ Home com banner rotativo, dashboard personalizado e categorias de treino (100%)
- ✅ Tela de Treinos com filtros (tempo, tipo, categoria) e detalhamento do treino (100%)
- ✅ Tela de Registro de Treino com upload de foto, descrição e opção de compartilhamento (100%)
- ✅ Tela de Nutrição com receitas e dicas nutricionais (100%)
- ✅ Sistema de Desafios com convites, ranking e progresso (100%)
- ✅ Perfil do usuário com edição de dados e estatísticas (100%)
- ✅ Benefícios: QR codes dinâmicos, cupons promocionais, sistema de expiração (100%)

**In-Scope vs Out-of-Scope:**
- **Incluído e Implementado:** Fluxos completos de onboarding, login, home, treinos, registros, nutrição, desafios, perfil e benefícios; Integração completa com Supabase (Auth, DB, Storage); Stack com Riverpod, Dio com tratamento de erros, auto_route.
- **Incluído mas Pendente:** Analytics e métricas.
- **Fora do escopo:** Feed social/Comunidade, Pagamentos (Stripe, Apple Pay, In-App Purchase); Chat entre usuários em tempo real; CMS para conteúdo dinâmico; Versão Web/PWA.

---

### 2. App Flow Document – Mapa de Navegação (Implementado)

Ao abrir o Ray Club, o usuário é saudado por uma tela de onboarding. Nessa única página introdutória, um slide exibe uma mensagem de incentivo e bem-estar, acompanhado por dois botões destacados: "Login" e "Criar Conta". Ao selecionar uma opção, o app transita para a tela de autenticação.

Na tela de Login, o usuário encontra campos para email e senha, além de uma opção para login por conta Google. Após a autenticação, o app valida a sessão por meio do Supabase Auth e direciona o usuário para a tela Home.

A tela Home possui um banner rotativo com promoções e mensagens motivacionais, seguido por uma saudação personalizada utilizando o primeiro nome do usuário. Imediatamente, um mini dashboard exibe estatísticas como dias treinados e uma barra de progresso. Cards ilustrativos apresentam categorias de treino e conteúdos especiais. Um botão flutuante "Registrar Treino" está disponível para iniciar o processo de registro em qualquer tela com navegação inferior.

Ao selecionar uma categoria ou card de treino, o usuário é direcionado para uma tela de listagem de treinos, que apresenta filtros por tempo e tipo. Cada card exibe uma imagem ilustrativa e uma breve descrição. Ao tocar em um card, o usuário entra na tela de detalhes, onde são apresentadas informações completas, imagens e opções de registro.

Na tela de Registro de Treino, o usuário pode adicionar uma descrição, escolher ou tirar uma foto, selecionar um template e decidir pelo compartilhamento. Outras telas do app incluem Nutrição (exibindo receitas e dicas), Benefícios (com QR codes dinâmicos, cupons e link para grupo VIP) e Perfil (para edição de dados pessoais e configurações).

A navegação geral é facilitada por uma barra inferior fixa, garantindo acesso rápido a todas as seções e transições intuitivas gerenciadas pelo auto_route e o padrão MVVM via Riverpod.

---

### 3. Tech Stack Document (Atualizado)

**Plataforma e Arquitetura:**
- Framework: Flutter
- Arquitetura: MVVM com gerenciamento de estado via Riverpod
- Linguagem: Dart

**Principais Dependências e Bibliotecas:**
- supabase_flutter (v2.3.2): Integração com Supabase para autenticação, banco de dados e storage
- supabase (v2.0.8) & postgrest (v2.0.0): Comunicação com a API do Supabase
- dio (v5.4.0): Requisições HTTP com retry e tratamento avançado de erros
- flutter_dotenv (v5.1.0): Gerenciamento e validação das variáveis de ambiente
- auto_route (v7.8.4): Navegação declarativa
- flutter_riverpod (v2.4.9): Gerenciamento de estado via Riverpod
- freezed (v2.4.5): Geração de código para modelos imutáveis e estados
- google_sign_in (v6.1.6): Login social com Google
- image_picker (v1.0.5): Upload de fotos para treinos
- Outras UI: flutter_svg, cached_network_image, carousel_slider, shimmer, google_fonts
- Testes & Qualidade: flutter_test, bloc_test, flutter_lints, mockito, mocktail

**APIs e Integração:**
- Supabase Docs: [https://supabase.com/docs](https://supabase.com/docs)
- Dio: [https://pub.dev/packages/dio](https://pub.dev/packages/dio)
- Flutter Riverpod: [https://riverpod.dev](https://riverpod.dev)
- auto_route: [https://pub.dev/packages/auto_route](https://pub.dev/packages/auto_route)
- Google Sign-In: [https://pub.dev/packages/google_sign_in](https://pub.dev/packages/google_sign_in)

**Backend e Integração:**
- Banco de Dados: PostgreSQL via Supabase
- Autenticação: Supabase Auth
- Storage: Supabase Storage (bucket "workout_images")
- Segurança: Row Level Security (RLS) implementado em todas as tabelas

---

### 4. Frontend Guidelines (Implementadas)

**Tipografia:**
- Fonte Principal: Poppins (com fallback para System UI)
- Utilize os arquivos de fonte em `assets/fonts` para consistência visual.

**Paleta de Cores:**
- primary: #8B5A2B
- primaryLight: #BB8C61
- primaryDark: #5D3919
- brown: #795548
- textDark: #333333
- textLight: #F5F5F5
- background: #F8F8F8
- cardBackground: branco (Colors.white)
- disabled: #CCCCCC
- success: #4CAF50
- error: #E53935
- warning: #FFB300
- info: #2196F3
- shadow: rgba(0,0,0,0.05)
- offWhite: #FAF9F6

**Espaçamentos e Layout:**
- Padding horizontal padrão: 16px
- Espaçamento vertical: 16–24px
- Cards com borderRadius: 16px
- Botões com borderRadius entre 12 e 20
- Sombra leve com opacidade de 0.05, blurRadius: 10 e offset (0, 4)

**Componentes de UI:**
- Botões elevados para ações principais (ex.: "Registrar Treino")
- Barra de navegação inferior com ícones minimalistas (preferência por Lucide ou MaterialIcons)
- Cards ilustrativos com fundo, bordas arredondadas e gradientes para contraste, quando necessário
- Reutilização de widgets para evitar repetição de código
- Seguir o padrão MVVM com Riverpod, evitando o uso de setState()

---

### 5. Backend Structure Document (Implementado)

**Banco de Dados e Esquema (via Supabase):**
- Tabelas Principais:
  - users: id, name, email, avatar_url, is_subscriber
  - workouts: id, user_id, image_url, description, created_at, is_public
  - challenges: id, title, description, is_official, creator_id, start_date, end_date
  - challenge_participants: id, user_id, challenge_id, points, completion_percentage
  - challenge_invites: id, challenge_id, inviter_id, invitee_id, status
  - content_cards: id, title, subtitle, route_link, icon, category
  - notifications: id, user_id, type, content, read_at
  - coupons: id, title, description, partner, qr_code_url, expires_at
  - nutrition_items: id, name, description, image_url, calories, protein, carbs, fat

**Autenticação e Sessão:**
- Implementado com Supabase Auth para gerenciamento de login e sessão (email/senha e Google)
- Persistência de sessão e verificação de assinante (campo is_subscriber)

**Storage e Regras de Acesso:**
- Bucket "workout_images" implementado para upload de imagens
- Regras de segurança aplicadas para acesso restrito às próprias imagens, com exceção das públicas
- Integração com variáveis de ambiente (.env) evitando hard-coding de chaves

**Lógicas e Triggers:**
- Registro de treino altera a tabela workouts e atualiza pontos na tabela challenge_participants
- Tratamento robusto de erros implementado com AppException e hierarquia de exceções
- Sistema unificado de tratamento de erros para todas as requisições

---

### 6. Status da Implementação (Março 2024)

**Features Completamente Implementadas (100%):**
1. **Estrutura de Projeto MVVM**
   - Diretórios organizados por features
   - Separação clara entre models, repositories, viewmodels e screens
   - Injeção de dependências via Riverpod

2. **Autenticação**
   - Login com email/senha
   - Login social com Google
   - Persistência de sessão
   - Recuperação de senha

3. **Home**
   - Banner rotativo
   - Dashboard personalizado
   - Cards de conteúdo
   - Estatísticas de progresso

4. **Treinos**
   - Listagem com filtros
   - Detalhes de treino
   - Registro com upload de foto
   - Histórico de treinos

5. **Nutrição**
   - Gerenciamento de refeições
   - Detalhamento de macronutrientes
   - Receitas e dicas

6. **Desafios**
   - Sistema de convites
   - Ranking e progresso
   - Filtros e categorias
   - Atualizações de pontuação

7. **Perfil**
   - Visualização de dados
   - Edição de perfil
   - Estatísticas de atividade
   - Configurações

**Features Parcialmente Implementadas:**
1. **Benefícios (~90%)**
   - QR codes implementados
   - Cupons promocionais
   - Falta sistema de expiração

**Próximos Passos:**
1. Completar as funcionalidades restantes (Benefits)
2. Implementar testes para todos os ViewModels
3. Melhorar a experiência offline
4. Otimizar performance e preparar para lançamento

**Próximos Passos:**
1. Implementar testes para todos os ViewModels
2. Melhorar a experiência offline com cache estratégico
3. Otimizar performance e preparar para lançamento
4. Implementar analytics para monitoramento de uso

**Próximos Passos:**
1. Implementar testes para todos os ViewModels
2. Melhorar a experiência offline com cache estratégico
3. Otimizar performance e preparar para lançamento
4. Implementar analytics para monitoramento de uso

**Próximos Passos:**
1. Implementar testes para todos os ViewModels
2. Melhorar a experiência offline com cache estratégico
3. Otimizar performance e preparar para lançamento
4. Implementar analytics para monitoramento de uso