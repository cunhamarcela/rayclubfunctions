# Guia para Documentação do Esquema Supabase (Ray Club App)

Este documento descreve como obter e organizar informações sobre o esquema atual do banco de dados Supabase para o projeto Ray Club App.

## Esquema Atual do Banco de Dados

O esquema do banco de dados foi atualizado na Fase 2 da implementação com as seguintes modificações principais:

1. **Remoção de tabelas redundantes**:
   - A tabela `profile` foi removida, consolidando todos os dados na tabela `profiles`

2. **Novas tabelas adicionadas**:
   - `water_intake`: Para rastreamento de consumo de água
   - `faqs` e `tutorials`: Para sistema de ajuda e tutoriais
   - `posts`, `comments`, `likes`: Para funcionalidades sociais
   - `contact_messages`: Para sistema de contato com administradores

3. **Funções SQL atualizadas**:
   - Funções para cálculo de streak, ranking e estatísticas
   - Funções para filtro de grupos em rankings
   - Funções para gerenciamento de grupos de desafios

4. **Triggers atualizados**:
   - Trigger para atualização de progresso em check-ins
   - Triggers para atualização de contadores (likes, comments, participants)

## Como Aplicar os Scripts de Atualização

Para aplicar todas as atualizações realizadas na Fase 2, execute os seguintes scripts no SQL Editor do Supabase, na ordem apresentada:

1. **Atualizar Funções SQL**:
   ```sql
   -- Execute o arquivo update_functions.sql
   ```

2. **Atualizar Triggers SQL**:
   ```sql
   -- Execute o arquivo update_triggers.sql
   ```

3. **Criar Tabelas Ausentes**:
   ```sql
   -- Execute o arquivo create_missing_tables.sql
   ```

4. **Alterar Tabelas Existentes**:
   ```sql
   -- Execute o arquivo alter_existing_tables.sql
   ```

## Como Verificar o Esquema Atualizado

Para verificar se todas as alterações foram aplicadas com sucesso:

1. **Verificar Tabelas**:
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public' 
   ORDER BY table_name;
   ```

2. **Verificar Funções**:
   ```sql
   SELECT routine_name 
   FROM information_schema.routines 
   WHERE routine_schema = 'public' 
   ORDER BY routine_name;
   ```

3. **Verificar Triggers**:
   ```sql
   SELECT trigger_name, event_manipulation, action_statement
   FROM information_schema.triggers
   WHERE trigger_schema = 'public'
   ORDER BY trigger_name;
   ```

## Como Obter as Informações Completas do Esquema

1. Acesse o painel do Supabase (Supabase Dashboard) do seu projeto
2. Navegue até a seção **SQL Editor**
3. Crie uma nova consulta clicando em **New query**
4. Copie e cole o conteúdo do arquivo `scripts/extract_supabase_schema.sql`
5. Execute a consulta clicando em **Run**
6. Cada consulta terá seus resultados exibidos em uma tabela separada
7. Para cada tabela de resultados:
   - Clique no botão **Download** para salvar os resultados em formato CSV
   - Ou clique no botão de cópia para copiar os resultados em formato tabular

## Recursos Principais Implementados na Fase 2

### 1. Rastreamento de Consumo de Água
- Tabela `water_intake` para armazenar registros diários
- Campos para metas personalizadas e contagem de copos
- Políticas RLS para garantir que usuários vejam apenas seus próprios dados

### 2. Sistema de Ajuda e Tutoriais
- FAQs organizadas por categorias
- Tutoriais com suporte a texto, imagens e vídeos
- Sistema de ordenação para controlar a exibição

### 3. Funcionalidades Sociais
- Posts com suporte a texto e imagens
- Comentários em posts
- Sistema de curtidas
- Contadores automáticos de likes e comentários

### 4. Filtragem de Grupos em Rankings
- Função `get_group_ranking(group_id)` para filtrar rankings por grupo
- Funções para criar grupos e gerenciar membros
- Atualização automática de rankings quando há check-ins

### 5. Sistema de Contato
- Formulário para envio de mensagens ao suporte
- Rastreamento de status das mensagens
- Suporte para mensagens anônimas e identificadas

## Próximos Passos Recomendados

Para futuras fases de implementação, recomenda-se:

1. **Implementar Caching**: Configurar regras de cache para funções de ranking e progresso
2. **Otimizar Consultas**: Revisar e otimizar as consultas com maior volume de dados
3. **Documentar API**: Criar documentação completa para todas as funções RPC disponíveis
4. **Testes de Performance**: Realizar testes de desempenho com volume crescente de dados
5. **Backup Automático**: Configurar rotinas de backup automatizadas para os dados críticos

## Organizando a Documentação do Esquema

Após obter todas as informações, crie um documento estruturado com o seguinte formato:

```markdown
# Esquema de Banco de Dados do Ray Club App

## 1. Tabelas e Contagens

[Tabela com nomes das tabelas, contagem de registros e descrições]

## 2. Estrutura Detalhada de Tabelas

### 2.1 Tabela: [Nome da Tabela 1]

[Tabela com colunas, tipos de dados, restrições, etc.]

### 2.2 Tabela: [Nome da Tabela 2]

[Tabela com colunas, tipos de dados, restrições, etc.]

## 3. Relações entre Tabelas

### 3.1 Chaves Primárias
[Listagem de chaves primárias]

### 3.2 Chaves Estrangeiras
[Listagem de chaves estrangeiras e suas relações]

## 4. Índices
[Listagem de índices importantes]

## 5. Triggers e Funções
[Listagem de triggers e funções relevantes]

## 6. Políticas de Segurança (RLS)
[Listagem de políticas de segurança por linha]

## 7. Storage Buckets
[Listagem de buckets de armazenamento]

## 8. Tipos Personalizados
[Listagem de ENUMs e outros tipos personalizados]

## 9. Estatísticas de Tamanho
[Tabelas por tamanho]
```

## Dicas para Análise

Ao analisar o esquema, preste atenção especial a:

1. **Consistência de Nomes**: Verifique se as tabelas e colunas seguem um padrão consistente de nomenclatura.

2. **Integridade Referencial**: Confirme se todas as relações necessárias estão implementadas com chaves estrangeiras.

3. **Tipos de Dados**: Verifique se os tipos de dados são apropriados para cada coluna (ex: usar UUID vs. integers para IDs).

4. **Políticas de Segurança**: Confirme se existem políticas RLS adequadas para proteger os dados.

5. **Índices**: Verifique se existem índices adequados para consultas frequentes.

6. **Documentação**: Observe se há descrições (comentários) nas tabelas e colunas principais.

## Estruturas Esperadas

Com base no plano de implementação e correções da Fase 1, espera-se encontrar as seguintes estruturas:

- Tabela de perfis de usuário (`user_profiles`)
- Tabela de desafios (`challenges`)
- Tabela de participação em desafios (`challenge_participants`)
- Tabela de check-ins de desafios (`challenge_check_ins`)
- Tabela de benefícios e cupons (`benefits`, `coupons`)
- Tabela de FAQ e tutoriais (`faqs`, `tutorials`)
- Tabela de configurações de usuário (`user_settings`)
- Tabelas relacionadas a dados de água e progressos (`water_intake`, `user_progress`)
- Tabelas para funcionalidades sociais (`posts`, `comments`, `likes`, etc.)

Caso alguma dessas estruturas esteja ausente ou incompleta, será necessário incluí-la no plano de implementação da Fase 2. 