# Esquema de Banco de Dados do Ray Club App

*Documento atualizado após implementação da Fase 2 em maio de 2025*

## 1. Tabelas e Contagens

| Tabela                   | Descrição |
|--------------------------|-----------|
| workout_records          | Registros de treinos realizados pelos usuários |
| partner_studios          | Academias e estúdios parceiros do aplicativo |
| workout_categories       | Categorias de treinos (ex: cardio, força) |
| workouts                 | Treinos disponíveis na plataforma |
| profiles                 | Perfis de usuários |
| diet_plans               | Planos alimentares |
| challenge_progress       | Progresso dos usuários em desafios |
| challenges               | Desafios disponíveis para os usuários |
| challenge_check_ins      | Check-ins realizados em desafios |
| partner_contents         | Conteúdos fornecidos pelos parceiros |
| challenge_participants   | Participantes de desafios |
| user_progress            | Progresso geral do usuário na plataforma |
| banners                  | Banners promocionais do aplicativo |
| user_workouts            | Relação entre usuários e treinos |
| challenge_invites        | Convites para participação em desafios |
| user_benefits            | Benefícios obtidos pelos usuários |
| benefits                 | Benefícios disponíveis na plataforma |
| challenge_groups         | Grupos de desafios |
| challenge_group_invites  | Convites para grupos de desafios |
| challenge_group_members  | Membros de grupos de desafios |
| user_challenges          | Relação entre usuários e desafios |
| challenge_bonuses        | Bônus de pontos em desafios |
| water_intake             | Registros de consumo de água dos usuários |
| faqs                     | Perguntas frequentes e respostas |
| tutorials                | Tutoriais e conteúdos de ajuda |
| posts                    | Posts sociais dos usuários |
| comments                 | Comentários em posts |
| likes                    | Curtidas em posts |
| contact_messages         | Mensagens de contato dos usuários |

**Nota**: A tabela `profile` foi removida por ser redundante com a tabela `profiles`.

## 2. Estrutura Detalhada de Tabelas Adicionadas na Fase 2

### 2.1 Tabela: water_intake

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID do registro (chave primária) |
| user_id | uuid | NO | null | ID do usuário |
| date | date | NO | null | Data do registro |
| cups | integer | NO | 0 | Número de copos bebidos |
| goal | integer | NO | 8 | Meta diária de copos |
| created_at | timestamp with time zone | YES | now() | Data de criação do registro |
| updated_at | timestamp with time zone | YES | now() | Data de atualização do registro |
| notes | text | YES | null | Observações do usuário |

### 2.2 Tabela: challenges

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID do desafio (chave primária) |
| title | text | NO | null | Título do desafio |
| description | text | NO | null | Descrição do desafio |
| image_url | text | YES | null | URL da imagem do desafio |
| local_image_path | text | YES | null | Caminho da imagem local (temporário durante upload) |
| start_date | timestamp with time zone | NO | null | Data de início do desafio |
| end_date | timestamp with time zone | NO | null | Data de término do desafio |
| type | text | NO | 'normal' | Tipo do desafio (normal, featured, etc) |
| points | integer | NO | 10 | Pontos concedidos por check-in |
| requirements | text[] | YES | '{}' | Requisitos do desafio |
| active | boolean | NO | true | Indica se o desafio está ativo |
| creator_id | uuid | NO | null | ID do criador do desafio |
| is_official | boolean | NO | false | Indica se é um desafio oficial da Ray |
| invited_users | uuid[] | YES | '{}' | IDs de usuários convidados |
| created_at | timestamp with time zone | NO | now() | Data de criação |
| updated_at | timestamp with time zone | NO | now() | Data de atualização |

### 2.3 Tabela: faqs

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID da FAQ (chave primária) |
| question | text | NO | null | Pergunta |
| answer | text | NO | null | Resposta |
| category | text | YES | null | Categoria da pergunta |
| order_index | integer | YES | 0 | Índice para ordenação |
| is_active | boolean | YES | true | Indica se a FAQ está ativa |
| created_at | timestamp with time zone | YES | now() | Data de criação |
| updated_at | timestamp with time zone | YES | now() | Data de atualização |

### 2.4 Tabela: tutorials

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID do tutorial (chave primária) |
| title | text | NO | null | Título do tutorial |
| description | text | YES | null | Descrição do tutorial |
| content | text | NO | null | Conteúdo do tutorial |
| image_url | text | YES | null | URL da imagem |
| video_url | text | YES | null | URL do vídeo |
| category | text | YES | null | Categoria do tutorial |
| order_index | integer | YES | 0 | Índice para ordenação |
| is_active | boolean | YES | true | Indica se o tutorial está ativo |
| created_at | timestamp with time zone | YES | now() | Data de criação |
| updated_at | timestamp with time zone | YES | now() | Data de atualização |

### 2.5 Tabela: posts

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID do post (chave primária) |
| user_id | uuid | NO | null | ID do usuário |
| content | text | NO | null | Conteúdo do post |
| image_url | text | YES | null | URL da imagem |
| challenge_id | uuid | YES | null | ID do desafio relacionado |
| workout_id | text | YES | null | ID do treino relacionado |
| workout_name | text | YES | null | Nome do treino |
| likes_count | integer | YES | 0 | Contagem de curtidas |
| comments_count | integer | YES | 0 | Contagem de comentários |
| created_at | timestamp with time zone | YES | now() | Data de criação |
| updated_at | timestamp with time zone | YES | now() | Data de atualização |
| user_name | text | YES | null | Nome do usuário |
| user_photo_url | text | YES | null | URL da foto do usuário |

### 2.6 Tabela: comments

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID do comentário (chave primária) |
| post_id | uuid | NO | null | ID do post |
| user_id | uuid | NO | null | ID do usuário |
| content | text | NO | null | Conteúdo do comentário |
| created_at | timestamp with time zone | YES | now() | Data de criação |
| updated_at | timestamp with time zone | YES | now() | Data de atualização |
| user_name | text | YES | null | Nome do usuário |
| user_photo_url | text | YES | null | URL da foto do usuário |

### 2.7 Tabela: likes

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID da curtida (chave primária) |
| post_id | uuid | NO | null | ID do post |
| user_id | uuid | NO | null | ID do usuário |
| created_at | timestamp with time zone | YES | now() | Data de criação |

### 2.8 Tabela: contact_messages

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID da mensagem (chave primária) |
| user_id | uuid | YES | null | ID do usuário (pode ser nulo para mensagens anônimas) |
| name | text | NO | null | Nome do remetente |
| email | text | NO | null | Email do remetente |
| subject | text | NO | null | Assunto da mensagem |
| message | text | NO | null | Conteúdo da mensagem |
| status | text | YES | 'pending' | Status (pending, processing, resolved, archived) |
| created_at | timestamp with time zone | YES | now() | Data de criação |
| updated_at | timestamp with time zone | YES | now() | Data de atualização |
| admin_notes | text | YES | null | Notas administrativas |

### 2.9 Tabela: challenge_groups (atualizada)

| Coluna | Tipo | Tamanho | Nulo? | Padrão | Descrição |
|--------|------|---------|-------|--------|-----------|
| id | uuid | null | NO | uuid_generate_v4() | ID do grupo (chave primária) |
| challenge_id | uuid | null | NO | null | ID do desafio |
| creator_id | uuid | null | NO | null | ID do criador |
| name | text | null | NO | null | Nome do grupo |
| description | text | null | YES | null | Descrição do grupo |
| created_at | timestamp with time zone | null | YES | now() | Data de criação |
| updated_at | timestamp with time zone | null | YES | now() | Data de atualização |
| is_public | boolean | null | NO | false | Se o grupo é público ou privado |

### 2.9.1 Tabela: challenge_group_members (NOVA)

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID da relação (chave primária) |
| group_id | uuid | NO | null | ID do grupo de desafio |
| user_id | uuid | NO | null | ID do usuário membro |
| joined_at | timestamp with time zone | NO | now() | Data de entrada no grupo |
| created_at | timestamp with time zone | NO | now() | Data de criação |
| updated_at | timestamp with time zone | NO | now() | Data de atualização |

### 2.10 Tabela: notifications (NOVA)

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID da notificação (chave primária) |
| user_id | uuid | NO | null | ID do usuário |
| title | text | NO | null | Título da notificação |
| message | text | NO | null | Mensagem da notificação |
| type | text | NO | null | Tipo (challenge, workout, system, etc.) |
| related_id | uuid | YES | null | ID do conteúdo relacionado |
| is_read | boolean | NO | false | Se foi lida pelo usuário |
| created_at | timestamp with time zone | NO | now() | Data de criação |
| read_at | timestamp with time zone | YES | null | Data de leitura |
| data | jsonb | YES | '{}' | Dados adicionais específicos do tipo |

## 3. Principais Funções Adicionadas/Atualizadas

### 3.1 Funções de Streak e Pontuação

- `get_current_streak(user_id, challenge_id)`: Calcula o streak atual (dias consecutivos) de check-ins do usuário em um desafio
- `update_challenge_streaks()`: Trigger que atualiza automaticamente o campo consecutive_days quando um check-in é registrado
- `update_modified_column()`: Atualiza automaticamente o campo updated_at
- `calculate_user_ranking()`: Retorna o ranking completo de usuários baseado em pontos
- `get_user_challenge_stats(user_id)`: Retorna estatísticas de desafios para um usuário
- `calculate_total_user_progress(user_id)`: Calcula o progresso geral do usuário

### 3.2 Funções de Busca e Filtro

- `search_challenges(...)`: Busca desafios com diversos filtros
- `get_group_ranking(group_id)`: Obtém o ranking específico de um grupo
- `update_challenge_positions()`: Atualiza automaticamente as posições dos usuários em um desafio quando os pontos mudam
- `has_checked_in_today(user_id, challenge_id)`: Verifica se um usuário já fez check-in hoje

### 3.3 Funções de Gerenciamento de Grupos

- `create_challenge_group(name, description, creator_id, challenge_id)`: Cria um novo grupo de desafio
- `add_member_to_group(group_id, user_id)`: Adiciona um membro a um grupo
- `remove_member_from_group(group_id, user_id)`: Remove um membro de um grupo
- `can_access_group(user_id, group_id)`: Verifica se um usuário tem permissão para acessar um grupo (se é membro ou se o grupo é público)

### 3.4 Funções de Notificações (NOVAS)

- `create_challenge_notification(user_id, challenge_id, title, message, data)`: Cria uma notificação de desafio
- `notify_on_challenge_join()`: Trigger que cria uma notificação quando um usuário entra em um desafio
- `mark_notifications_as_read(notification_ids)`: Marca várias notificações como lidas

### 3.5 Funções de Check-in (ATUALIZADAS)

- `record_challenge_check_in(challenge_id_param, user_id_param, workout_id_param, workout_name_param, workout_type_param, duration_minutes_param, date_param)`: Versão refatorada que não depende de triggers. Esta função gerencia todo o processo de check-in, incluindo:
  - Verificação de check-ins duplicados
  - Cálculo de streak (dias consecutivos)
  - Cálculo de bônus por dias consecutivos
  - Atualização de progresso em desafio
  - Atualização de ranking
  - Registro em participant tables
  - Tratamento seguro de erros

## 4. Principais Triggers Atualizados

- `update_user_progress_on_checkin`: [DESATIVADO] Atualiza o progresso do usuário quando um check-in é registrado
- `update_progress_after_checkin`: [DESATIVADO] Atualiza o progresso do usuário em um desafio
- `trg_update_progress_on_check_in`: [DESATIVADO] Atualiza o progresso quando um check-in é registrado
- `trigger_update_challenge_ranking`: [DESATIVADO] Atualiza o ranking do desafio
- `update_profile_stats_on_checkin_trigger`: [DESATIVADO] Atualiza estatísticas do perfil do usuário
- `update_streak_on_checkin`: [DESATIVADO] Atualiza o streak de dias consecutivos

**Nota**: Estes triggers foram desativados devido a problemas de compatibilidade onde tentavam acessar campos inexistentes. A funcionalidade foi migrada para a função `record_challenge_check_in` refatorada.

### 4.1 Triggers Adicionados na Fase 3

- `update_faqs_last_updated`: Atualiza automaticamente os campos `last_updated` e `updated_by` ao modificar uma FAQ
- `update_tutorials_last_updated`: Atualiza automaticamente os campos `last_updated` e `updated_by` ao modificar um tutorial
- `clean_expired_redemption_codes`: Trigger agendado que marca códigos de resgate expirados como usados

## 5. Melhorias de Esquema

### 5.1 Correções

- Remoção da tabela redundante `profile` (substituída por `profiles`)
- Remoção do campo `participants_count` redundante na tabela `challenges`
- Adição do campo `local_image_path` na tabela `challenges` para suporte a upload de imagens
- Padronização de campos `created_at` e `updated_at` em todas as tabelas
- Implementação de triggers para manter `updated_at` atualizado

### 5.2 Novas Funcionalidades

- Sistema completo de consumo de água com rastreamento e metas
- Sistema completo de FAQ e tutoriais para ajuda ao usuário
- Sistema social com posts, comentários e curtidas
- Sistema de contato para comunicação com administradores
- Sistema aprimorado de grupos para desafios, permitindo filtragem de ranking
- Sistema de notificações para eventos de aplicativo
- Rastreamento de sequências (streaks) em desafios
- Metas de usuário expandidas e estatísticas unificadas

### 5.3 Atualizações na Tabela Profile (NOVO)

A tabela `profiles` foi atualizada com os seguintes campos adicionais:

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| daily_water_goal | integer | YES | 8 | Meta diária de copos de água |
| daily_workout_goal | integer | YES | 1 | Meta diária de treinos |
| weekly_workout_goal | integer | YES | 5 | Meta semanal de treinos |
| weight_goal | decimal(5,2) | YES | null | Meta de peso (kg) |
| height | decimal(5,2) | YES | null | Altura do usuário (cm) |
| current_weight | decimal(5,2) | YES | null | Peso atual (kg) |
| preferred_workout_types | text[] | YES | '{}' | Tipos de treino preferidos |
| stats | jsonb | YES | '{}' | Estatísticas unificadas do usuário |
| is_admin | boolean | NO | false | Indica se o usuário é administrador |

## 6. Políticas de Segurança (RLS)

Todas as novas tabelas têm políticas RLS (Row Level Security) implementadas:

- Tabelas de perfil e progresso: Usuários podem ver/editar apenas seus próprios dados
- Tabelas de conteúdo (FAQ, tutoriais): Visíveis para todos, gerenciáveis por administradores
- Tabelas sociais: Usuários podem criar/editar seu próprio conteúdo, todos podem ver
- Challenge groups: Visibilidade pública, edição apenas pelo criador
- Notificações: Usuários podem ver/marcar como lidas apenas suas próprias notificações

### 6.1 Políticas Específicas Adicionadas (Fase 3)

| Tabela | Política | Tipo | Descrição |
|--------|----------|------|-----------|
| profiles | Anyone can read profiles | SELECT | Qualquer usuário pode ler perfis |
| profiles | Admins can update profiles | UPDATE | Admins podem atualizar qualquer perfil, usuários regulares só o próprio |
| faqs | Anyone can read faqs | SELECT | Qualquer usuário pode ler FAQs |
| faqs | Only admins can insert faqs | INSERT | Apenas administradores podem inserir FAQs |
| faqs | Only admins can update faqs | UPDATE | Apenas administradores podem atualizar FAQs |
| faqs | Only admins can delete faqs | DELETE | Apenas administradores podem excluir FAQs |
| tutorials | Anyone can read tutorials | SELECT | Qualquer usuário pode ler tutoriais |
| tutorials | Only admins can insert tutorials | INSERT | Apenas administradores podem inserir tutoriais |
| tutorials | Only admins can update tutorials | UPDATE | Apenas administradores podem atualizar tutoriais |
| tutorials | Only admins can delete tutorials | DELETE | Apenas administradores podem excluir tutoriais |

## 7. Índices

Adicionados índices para otimizar consultas em todas as novas tabelas:

- Índices de data para consumo de água `(idx_water_intake_date)`
- Índices de categoria para FAQs e tutoriais `(idx_faqs_category, idx_tutorials_category)`
- Índices para consultas sociais `(idx_posts_created_at, idx_comments_post)`
- Índices de pesquisa específicos para cada tabela
- Índice para notificações não lidas `(idx_notifications_user_unread)`

## 8. Conclusão da Fase 2

Com estas alterações, o esquema do banco de dados agora suporta completamente:

1. Rastreamento de consumo de água
2. Sistema de FAQ e tutoriais
3. Funcionalidades sociais
4. Gerenciamento e filtragem de grupos de desafios
5. Cálculo preciso de progresso e rankings em desafios
6. Sistema de notificações para eventos de aplicativo
7. Rastreamento de sequências (streaks) em desafios
8. Metas de usuário expandidas e estatísticas unificadas

Todos os modelos Flutter correspondentes a estas tabelas foram atualizados para manter a consistência entre o backend e o frontend, aplicando o padrão MVVM com Riverpod conforme as diretrizes do projeto.

## 9. Atualizações da Fase 3

### 9.1 Nova Tabela: benefit_redemption_codes

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID do código (chave primária) |
| code | text | NO | null | Código de resgate |
| user_id | uuid | NO | null | ID do usuário |
| benefit_id | uuid | NO | null | ID do benefício |
| created_at | timestamp with time zone | NO | now() | Data de criação |
| used_at | timestamp with time zone | YES | null | Data de uso |
| is_used | boolean | NO | false | Se foi utilizado |
| expires_at | timestamp with time zone | NO | now() + interval '1 day' | Data de expiração |
| device_info | jsonb | YES | null | Informações do dispositivo |
| ip_address | text | YES | null | Endereço IP |
| location_data | jsonb | YES | null | Dados de localização |

### 9.2 Funções Adicionadas para Sistema de Benefícios

- `generate_redemption_code(user_id, benefit_id)`: Gera um código único para resgate de benefício
- `verify_redemption_code(code, benefit_id)`: Verifica se um código de resgate é válido
- `mark_code_as_used(code)`: Marca um código como utilizado
- `clean_expired_redemption_codes()`: Limpa códigos expirados (job agendado)

### 9.3 Melhorias nas Tabelas de FAQs e Tutoriais

#### 9.3.1 Tabela faqs (Campos Adicionados)

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| is_active | boolean | NO | true | Se a FAQ está ativa |
| updated_by | uuid | YES | null | ID do admin que atualizou |
| last_updated | timestamp with time zone | YES | null | Data da última atualização |

#### 9.3.2 Tabela tutorials (Campos Adicionados)

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| is_active | boolean | NO | true | Se o tutorial está ativo |
| is_featured | boolean | NO | false | Se está em destaque |
| updated_by | uuid | YES | null | ID do admin que atualizou |
| last_updated | timestamp with time zone | YES | null | Data da última atualização |
| related_content | jsonb | YES | null | Conteúdo relacionado |

### 9.4 Políticas de Segurança Adicionadas

#### 9.4.1 Políticas para `benefit_redemption_codes`

- `Users can view their own redemption codes`: Usuários podem ver apenas seus próprios códigos
- `Users can insert their own redemption codes`: Usuários podem inserir códigos apenas para si mesmos
- `Users can update their own redemption codes`: Usuários podem atualizar apenas seus próprios códigos

#### 9.4.2 Políticas para `faqs` e `tutorials`

- Novas políticas permitindo que apenas administradores possam criar, atualizar ou remover conteúdo
- Leitura permitida para todos os usuários

### 9.5 Índices de Performance

| Tabela | Índice | Colunas | Descrição |
|--------|--------|---------|-----------|
| benefit_redemption_codes | idx_benefit_redemption_codes_code | code | Busca rápida por código |
| benefit_redemption_codes | idx_benefit_redemption_codes_user | user_id | Busca por códigos do usuário |
| benefit_redemption_codes | idx_benefit_redemption_codes_benefit | benefit_id | Busca por códigos de um benefício |
| benefit_redemption_codes | idx_benefit_redemption_codes_is_used | is_used | Filtrar por códigos não utilizados |
| faqs | idx_faqs_category_active | category, is_active | Busca de FAQs ativas por categoria |
| tutorials | idx_tutorials_category_featured | category, is_featured | Busca de tutoriais em destaque |

## 10. Conclusão da Fase 3

Com estas alterações, o esquema do banco de dados agora suporta completamente:

1. Sistema de geração e validação de códigos de resgate para benefícios
2. Implementação de QR codes para benefícios com segurança e expiração
3. Sistema completo de FAQs dinâmicas com categorização e gerenciamento
4. Sistema de tutoriais com suporte a multimídia e gerenciamento por administradores
5. Melhorias de segurança com políticas de acesso específicas por função
6. Otimizações de performance com novos índices
7. Controle de acesso administrativo com a nova coluna `is_admin` na tabela `profiles`
8. Políticas de segurança granulares para todas as tabelas gerenciáveis por administradores
9. Triggers automáticos para manter metadados de histórico de atualizações

Todas as implementações seguem rigorosamente o padrão MVVM com Riverpod, utilizando Freezed para imutabilidade e tipagem segura. As comunicações com o Supabase estão encapsuladas nas classes de repositório e todos os estados são gerenciados por StateNotifier.

Os scripts de migração da Fase 3 garantem uma atualização segura do banco de dados, com verificações de existência para cada coluna e operações idempotentes, permitindo que sejam executados múltiplas vezes sem risco de corrupção de dados. 

## 11. Tabelas Base Atualizadas

### 11.1 Tabela: workout_records

| Coluna | Tipo | Nulo? | Padrão | Descrição |
|--------|------|-------|--------|-----------|
| id | uuid | NO | uuid_generate_v4() | ID do registro (chave primária) |
| user_id | uuid | NO | null | ID do usuário |
| workout_id | uuid | YES | null | ID do treino (pode ser null para treinos personalizados) |
| workout_name | text | NO | null | Nome do treino realizado |
| workout_type | text | NO | null | Tipo/categoria do treino |
| date | timestamp with time zone | NO | null | Data e hora do treino |
| duration_minutes | integer | NO | null | Duração em minutos |
| is_completed | boolean | NO | true | Se o treino foi completado integralmente |
| completion_status | text | YES | 'completed' | Status de conclusão do treino |
| notes | text | YES | null | Notas ou observações opcionais |
| image_urls | text[] | YES | '{}' | URLs das imagens associadas ao treino |
| created_at | timestamp with time zone | YES | now() | Data de criação do registro |
| updated_at | timestamp with time zone | YES | now() | Data de atualização do registro |

## 12. Conclusão da Fase 4

Com estas implementações, o Ray Club App agora possui:

1. Sistema completo de configurações avançadas com sincronização entre dispositivos
2. Gerenciamento inteligente de cache para melhorar o desempenho
3. Infraestrutura para análise de uso e monitoramento de desempenho
4. Pré-carregamento adaptativo baseado no comportamento do usuário
5. Testes automatizados abrangentes

Todas as implementações seguem rigorosamente o padrão MVVM com Riverpod. O app agora está totalmente otimizado e oferece uma experiência fluida aos usuários, mesmo em condições de rede instáveis. 

## 13. Resolução de Problemas Conhecidos

### 13.1 Resolução do Erro de Check-in em Desafios

**Problema**: A implementação original do registro de check-ins para desafios apresentava um erro onde os triggers tentavam acessar um campo `status` inexistente na tabela `challenge_check_ins`, resultando no erro:
```
PostgrestException(message: record "new" has no field "status", code: 42703)
```

**Solução**: 
1. Desativação de triggers problemáticos que causavam o erro
2. Refatoração da função `record_challenge_check_in` para não depender dos triggers
3. Implementação de toda a lógica de atualização dentro da função RPC, garantindo:
   - Verificação de duplicações
   - Cálculo correto de streaks
   - Atualização adequada de progresso e participantes
   - Recálculo de rankings
   - Tratamento seguro de erros

**Impacto**: O sistema de check-in tornou-se mais robusto e confiável, mantendo total compatibilidade com o aplicativo Flutter existente. Esta abordagem também simplifica o modelo de fluxo de dados, concentrando a lógica em uma única função bem testada e documentada. 