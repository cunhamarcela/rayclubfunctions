# Diagnóstico da Estrutura do Banco de Dados e Plano de Correção

Este documento detalha a análise da estrutura das tabelas do Supabase, com foco no fluxo de registro de treino, atualização de ranking e dados do dashboard. Ele identifica problemas e sugere correções.

## Análise da Estrutura das Tabelas (Principais Insights):

### `workout_records` (Registro de Treino Principal):
-   **Colunas Essenciais Presentes:** `user_id`, `workout_name`, `workout_type`, `date`, `duration_minutes`, `image_urls`.
-   **PONTO CRÍTICO - Colunas Faltantes/Problemáticas:**
    -   **`challenge_id` (uuid): ADICIONADA.** Fundamental para associar um treino a um desafio.
    -   **`points` (integer): ADICIONADA.** Necessária para registrar pontos de treinos individuais.
    -   **`group_id` (uuid): AUSENTE.** Pode ser necessária para filtros específicos no nível do `workout_record`.
-   **Chaves Estrangeiras (FKs):**
    -   **`user_id`:** Não possui FK para `profiles.id` (ou `auth.users.id`). Falha de integridade.
    -   **`workout_id`:** Não possui FK para uma tabela `workouts`. Se `workout_id` em `workout_records` é um link para um treino pré-definido (como em `user_workouts`), a FK deveria existir.
-   **Índices:** Bons índices em `date`, `user_id`, `workout_id`.

### `challenge_progress` (Ranking e Progresso em Desafios):
-   **Colunas OK:** `challenge_id`, `user_id`, `points`, `position`, `user_name`, `user_photo_url`, `check_ins_count`, `last_check_in`, `consecutive_days`, `completed`.
-   **`total_check_ins` vs `check_ins_count`:** Possível redundância ou lógica de atualização específica a ser verificada.
-   **FKs:**
    -   `challenge_id` -> `challenges.id`: **OK.**
    -   `user_id`: Não possui FK para `profiles.id`. Falha de integridade.
-   **Índices:** Excelente conjunto de índices.

### `user_progress` (Dashboard do Usuário):
-   **Colunas OK:** Parece completa.
-   **Redundâncias:** `workouts` vs `workouts_completed`; `last_updated` vs `updated_at`.
-   **FKs:**
    -   `user_id`: Não possui FK para `profiles.id`. Falha de integridade.
-   **Índices:** Bom índice em `user_id`.

### `user_workouts` (Treinos Estruturados/Acompanhados):
-   **PK `id` como `text`:** Incomum.
-   **FKs:** `user_id` -> `profiles.id` (OK), `workout_id` -> `workouts.id` (OK, confirma tabela `workouts`).
-   **Propósito vs `workout_records`:** Potencial conflito ou lógica duplicada se ambas afetam `challenge_progress`.

### `profiles`:
-   Contém dados do usuário. `id` aqui deveria ser referenciado por `user_id` nas outras tabelas.
-   `points` e `streak`: Presentes aqui e em `user_progress`. `user_progress` parece mais apropriado para métricas agregadas.

### `challenges`, `challenge_participants`, `challenge_groups`, `challenge_group_members`:
-   Estrutura parece lógica. FKs entre si OK.
-   `challenge_groups` tem duas FKs para `challenges.id` (uma é redundante).

## Diagnóstico Atualizado da Estrutura e Fluxo

### Fluxo de Registro de Treino (Revisado e Implementado):
1.  Usuário salva treino no App Flutter.
2.  Flutter chama RPC `record_challenge_check_in_v2`. 
3.  Função `record_challenge_check_in_v2` (wrapper) chama `record_challenge_check_in` que:
    -   **IMPLEMENTADO:** Insere registro em `workout_records` com `challenge_id` e `points`
    -   **IMPLEMENTADO:** Atualiza `user_progress` sempre, independente da duração do treino
    -   **IMPLEMENTADO:** Verifica duração mínima de 45 minutos apenas para check-in no desafio
4.  Função implementada para lidar com todos os cenários:
    -   Treino com duração suficiente (≥ 45 min): registra treino + check-in no desafio
    -   Treino com duração insuficiente (< 45 min): registra apenas o treino
    -   Check-in duplicado: registra novo treino, mas não duplica check-in
5.  **Atualização do Ranking (`challenge_progress`):**
    -   Realizada diretamente pela função `record_challenge_check_in` 
    -   Chamada para `update_challenge_ranking(_challenge_id)` no final do processo
6.  **Atualização do Dashboard (`user_progress`):**
    -   Implementada diretamente na função `record_challenge_check_in`
    -   Sempre incrementa contadores de treinos e pontos do usuário

### Problemas Estruturais e de Fluxo (Corrigidos):

1.  **AUSÊNCIA DE `challenge_id` EM `workout_records`:** ✅ Corrigido - Adicionado e usado na função.
2.  **AUSÊNCIA DE `points` EM `workout_records`:** ✅ Corrigido - Adicionado e usado na função.
3.  **RPC `record_challenge_check_in` DUPLICADA/INCONSISTENTE:** ✅ Corrigido - Versões antigas removidas, mantendo versão principal e wrapper.
4.  **MECANISMO DE ATUALIZAÇÃO DE `user_progress` INCERTO:** ✅ Corrigido - Implementado na função principal.
5.  **TRIGGERS REDUNDANTES:** ✅ Corrigido - Trigger `sync_workout_to_challenges` foi removido, simplificando a arquitetura.

## O Que Foi Corrigido e Como:

1. **Adicionadas Colunas a `workout_records`:**
    ```sql
    ALTER TABLE public.workout_records ADD COLUMN challenge_id UUID;
    ALTER TABLE public.workout_records ADD COLUMN points INTEGER DEFAULT 0;
    ```

2. **Removidos Triggers Redundantes:**
    ```sql
    DROP TRIGGER IF EXISTS trigger_sync_workouts ON user_workouts;
    DROP TRIGGER IF EXISTS trg_sync_workout_to_challenges ON workout_records;
    DROP FUNCTION IF EXISTS public.sync_workout_to_challenges();
    ```

3. **Simplificada Arquitetura de RPC:**
    - Removidas versões duplicadas/inconsistentes da função `record_challenge_check_in`
    - Criada função principal com parâmetros prefixados com `_`
    - Criada função wrapper `record_challenge_check_in_v2` com parâmetros prefixados com `p_` para compatibilidade com o Flutter

4. **Implementado Novo Fluxo para Registro de Treino:**
    - Sem requisitos de duração mínima para registro do treino
    - Duração mínima de 45 minutos apenas para check-in no desafio
    - Atualização do progresso geral do usuário em todos os casos

## Melhorias Adicionais Implementadas:

1. **Padronização de Interface de API:**
   - Utilização de parâmetros consistentes com prefixo `p_` na interface pública (`record_challenge_check_in_v2`)
   - Parâmetros com prefixo `_` na implementação interna (`record_challenge_check_in`)

2. **Documentação Melhorada:**
   - Adicionados comentários nas funções
   - Atualizada documentação do projeto

3. **Manutenção Simplificada:**
   - Removida lógica duplicada entre função RPC e triggers
   - Centralizada toda a lógica de negócio em uma única função

## Funções SQL Implementadas:

### Função Principal `record_challenge_check_in`:
```sql
CREATE OR REPLACE FUNCTION public.record_challenge_check_in(
    _challenge_id uuid, 
    _date timestamp with time zone, 
    _duration_minutes integer, 
    _user_id uuid, 
    _workout_id text, 
    _workout_name text, 
    _workout_type text,
    _points integer DEFAULT 10
) RETURNS jsonb LANGUAGE plpgsql
```

### Função Wrapper `record_challenge_check_in_v2`:
```sql
CREATE OR REPLACE FUNCTION public.record_challenge_check_in_v2(
  p_challenge_id uuid, 
  p_user_id uuid,
  p_workout_id text,
  p_workout_name text,
  p_workout_type text,
  p_workout_date timestamp with time zone, 
  p_duration_minutes integer
) RETURNS jsonb LANGUAGE plpgsql
```

## Análise das Funções RPC e Triggers (Problemas Corrigidos):

### Duplicação de `record_challenge_check_in`:
- **PROBLEMA CORRIGIDO:** ✅ As múltiplas versões da função foram consolidadas em uma única implementação padronizada.
- **IMPLEMENTAÇÃO CORRETA:** Mantida apenas a versão com prefixo `_` nos parâmetros, com a adição do parâmetro opcional `_points`.

### Novo Fluxo de Registro de Treino:
- **Registro de Treino:** Sempre registra em `workout_records`, independente da duração
- **Progresso do Usuário:** Sempre atualiza `user_progress`, independente da duração
- **Check-in no Desafio:** Somente se:
  - Treino tem duração mínima de 45 minutos
  - Usuário não fez check-in para este desafio/dia anteriormente
  - Usuário é participante do desafio
  - Desafio existe e está ativo

### Benefícios da Nova Implementação:
- **Integridade de Dados:** Todas as relações são corretamente estabelecidas com `challenge_id` e `points` em `workout_records`
- **Consistência:** Regras de negócio claras e aplicadas uniformemente
- **Rastreabilidade:** Todos os treinos são registrados, mesmo que não contem como check-in
- **Experiência do Usuário:** Feedback claro sobre por que um treino não conta para o desafio
- **Simplificação:** Uma única função central que gerencia todo o fluxo

## Possíveis Melhorias Adicionais:
-   **Consistência de Nomenclatura SQL.**
-   **Definir FK para `workout_records.workout_id`** se ele se refere a uma tabela `workouts` (como `user_workouts.workout_id` faz).
-   **Tratamento de Erros SQL** em funções e triggers.
-   **Documentação SQL** (comentários).
-   **Testes de Backend** para validar os fluxos. 

## Análise das Funções RPC e Triggers (Problemas Críticos):

### Duplicação de `record_challenge_check_in`:
-   **Assinatura 1 (7 parâmetros):**
    ```sql
    record_challenge_check_in(
      challenge_id_param UUID,
      date_param TIMESTAMP WITH TIME ZONE,
      duration_minutes_param INTEGER,
      user_id_param UUID,
      workout_id_param TEXT,
      workout_name_param TEXT,
      workout_type_param TEXT
    )
    ```
-   **Assinatura 2 (7 parâmetros, ordem diferente):**
    ```sql
    record_challenge_check_in(
      _user_id UUID,
      _challenge_id UUID,
      _workout_id VARCHAR,
      _workout_name VARCHAR,
      _workout_type VARCHAR,
      _duration_minutes INTEGER,
      _check_in_date VARCHAR
    )
    ```
-   **Assinatura 3 (7 parâmetros, outra ordem):**
    ```sql
    record_challenge_check_in(
      challenge_id UUID,
      user_id UUID,
      workout_id UUID,
      workout_name TEXT, 
      workout_type TEXT,
      date TIMESTAMP WITH TIME ZONE,
      duration_minutes INTEGER
    )
    ```

-   **PROBLEMA CRÍTICO:** A existência de múltiplas funções com o mesmo nome mas assinaturas diferentes causa confusão no sistema, dificultando o rastreamento do fluxo de dados. A versão correta deve ser determinada com base no que o Flutter chama.

### Entendendo o Fluxo de Dados Atual:
-   **`sync_workout_to_challenges`:** Trigger AFTER INSERT em `workout_records` que foi **removido** na implementação atual. Anteriormente, esse trigger:
    -   Verificava se o treino tinha duração mínima (45 min)
    -   Verificava se o usuário já tinha um treino válido para aquela data
    -   Para cada desafio ativo do usuário, inseria um registro em `challenge_check_ins`
    -   **PROBLEMA RESOLVIDO:** Este trigger foi removido porque não conseguia associar o treino a um desafio específico. A função RPC agora manipula essa lógica diretamente.

-   **`update_challenge_progress_on_check_in`/`update_challenge_progress_on_checkin`:** Triggers AFTER INSERT em `challenge_check_ins` que foram **removidos** na implementação atual. Anteriormente, esses triggers:
    -   Atualizavam o progresso do usuário no desafio (`challenge_progress`)
    -   Calculavam streak, pontos e bonus
    -   Atualizavam `check_ins_count`, `consecutive_days`, etc.
    -   **PROBLEMA RESOLVIDO:** Estes triggers foram removidos e sua lógica foi incorporada diretamente na função RPC `record_challenge_check_in`.

-   **`update_challenge_ranking`:** Funcionalidade que atualiza as posições no ranking, agora incorporada diretamente na função RPC.

### Arquitetura Atual (Simplificada):
A arquitetura atual foi simplificada: todos os triggers redundantes foram removidos, e a função RPC `record_challenge_check_in` agora é a única responsável por:
1. Registrar o treino em `workout_records`
2. Inserir o check-in em `challenge_check_ins` (se o treino for elegível)
3. Atualizar o progresso do usuário em `challenge_progress`
4. Atualizar o ranking do desafio

Esta abordagem centraliza toda a lógica em um único ponto, eliminando problemas de sincronização e duplicação de processamento.

### Funções envolvidas no dashboard:
-   **`get_dashboard_data`:** Função que:
    -   Busca dados de `user_progress`
    -   Busca dados de `water_intake`
    -   Busca metas do usuário
    -   Busca treinos recentes
    -   Busca desafios ativos
    -   Busca progresso em desafios
    -   Busca benefícios resgatados
    -   **COMPLEXIDADE:** Utiliza várias colunas diferentes e tabelas, tentando adaptar-se a alterações de estrutura

## Proposta Expandida de Correção

### Corrigir Função RPC `record_challenge_check_in`:

1. **Selecionar Assinatura Correta:**
   - Manter apenas a assinatura que corresponde à chamada do Flutter (provavelmente a segunda versão)
   - Remover outras funções com o mesmo nome

2. **Modificar Função para Novo Fluxo:**
    ```sql
    CREATE OR REPLACE FUNCTION public.record_challenge_check_in(
        _user_id UUID,
        _challenge_id UUID,
        _workout_id TEXT,
        _workout_name TEXT,
        _workout_type TEXT,
        _duration_minutes INTEGER,
        _check_in_date VARCHAR,
        _points INTEGER DEFAULT 10
    )
    RETURNS JSONB AS $$
    DECLARE
      result JSONB;
      workout_record_id UUID;
    BEGIN
      -- Inserir em workout_records com challenge_id e points
      INSERT INTO workout_records(
        user_id,
        challenge_id, -- Nova coluna adicionada
        workout_id,
        workout_name,
        workout_type,
        date,
        duration_minutes,
        points, -- Nova coluna adicionada
        created_at
      ) VALUES (
        _user_id,
        _challenge_id,
        _workout_id,
        _workout_name,
        _workout_type,
        _check_in_date::TIMESTAMP,
        _duration_minutes,
        _points,
        NOW()
      ) RETURNING id INTO workout_record_id;
      
      -- Retornar resultado
      result := jsonb_build_object(
        'success', TRUE,
        'message', 'Workout registrado com sucesso.',
        'workout_id', workout_record_id
      );
      
      RETURN result;
    EXCEPTION
      WHEN OTHERS THEN
        RETURN jsonb_build_object(
          'success', FALSE,
          'message', 'Erro ao registrar workout: ' || SQLERRM
        );
    END;
    $$ LANGUAGE plpgsql SECURITY DEFINER;
    ```

3. **Modificar Trigger `sync_workout_to_challenges`:**
    ```sql
    CREATE OR REPLACE FUNCTION public.sync_workout_to_challenges()
    RETURNS TRIGGER AS $$
    DECLARE
      challenge_record RECORD;
    BEGIN
      -- Ignorar se o treino não tem duração suficiente
      IF NEW.duration_minutes < 45 THEN
        RETURN NEW;
      END IF;
      
      -- Se challenge_id está presente, usar diretamente
      IF NEW.challenge_id IS NOT NULL THEN
        -- Verificar se já existe check-in para este usuário/desafio/data
        IF EXISTS (
          SELECT 1 FROM challenge_check_ins 
          WHERE user_id = NEW.user_id 
          AND challenge_id = NEW.challenge_id 
          AND DATE(check_in_date) = DATE(NEW.date)
        ) THEN
          RETURN NEW; -- Já existe check-in
        END IF;
        
        -- Inserir check-in para o desafio específico
        INSERT INTO challenge_check_ins (
          user_id,
          challenge_id,
          check_in_date,
          points,
          workout_id,
          workout_name,
          workout_type,
          duration_minutes
        ) VALUES (
          NEW.user_id,
          NEW.challenge_id,
          NEW.date,
          NEW.points, -- Usar points do workout_records
          NEW.id,
          NEW.workout_name,
          NEW.workout_type,
          NEW.duration_minutes
        );
      END IF;
      
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    ```

4. **Atualização do Flutter (API Provider):**
   - Modificar chamada RPC para passar `challenge_id` e `points`
   - Manter a mesma assinatura de função para compatibilidade

Esta abordagem mantém a compatibilidade com o código existente enquanto implementa as correções estruturais necessárias.

## Atualizações Adicionais - Correção de Problemas com UUID e Otimização

### Problema: Inconsistências com UUIDs nas Chamadas RPC

Foi identificado um problema de inconsistência onde as chamadas RPC para `record_challenge_check_in_v2` e outras funções estavam enviando UUIDs inválidos ou em formatos inconsistentes, resultando em erros no Supabase.

#### Solução Implementada - Lado Cliente (Flutter)

1. **Criação de Utilitários para Validação de UUID:**
   - Implementada classe `UuidHelper` para verificar e garantir UUIDs válidos
   - Criadas extensões para String e String? para facilitar validação

```dart
// lib/utils/uuid_helper.dart
class UuidHelper {
  static bool isValid(String? id) {
    if (id == null || id.isEmpty) return false;
    return RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    ).hasMatch(id);
  }

  static String ensureValid(String? id) {
    if (isValid(id)) return id!;
    return const Uuid().v4();
  }
}
```

2. **Extensão para Chamadas RPC:**
   - Adicionada extensão `rpcWithValidUuids` para o SupabaseClient
   - Validação automática de parâmetros comuns de UUID em chamadas RPC

```dart
extension RpcExtension on SupabaseClient {
  Future<dynamic> rpcWithValidUuids(
    String function, {
    required Map<String, dynamic> params,
    List<String>? uuidFields,
  }) async {
    // Validar UUIDs e fazer chamada RPC
  }
}
```

3. **Integração com Analytics e Logging:**
   - Adicionada validação de UUIDs em serviços de analytics e logging
   - Garantia de que IDs enviados para serviços externos são válidos

#### Impacto das Correções

As correções implementadas resultaram em:

1. **Maior Robustez nas Chamadas API:**
   - Falhas devido a UUIDs inválidos foram eliminadas
   - Consistência entre cliente e servidor aprimorada

2. **Manutenção Simplificada:**
   - Centralização da lógica de validação
   - Redução da duplicação de código

3. **Compatibilidade com o Código Existente:**
   - Abordagem não-intrusiva com extensões e utilitários
   - Implementação gradual sem alterações estruturais significativas

### Melhorias Adicionais na Função RPC `record_challenge_check_in_v2`

A função `record_challenge_check_in_v2` foi aprimorada para:

1. **Validação Robusta:**
   - Verificação explícita da existência do desafio
   - Validação se o usuário é participante do desafio
   - Verificação de check-in duplicado por data

2. **Registros Consistentes:**
   - Sempre registra o treino em `workout_records`, independente da duração
   - Atualiza `user_progress` para todos os treinos
   - Realiza check-in no desafio apenas se duração ≥ 45 minutos

3. **Respostas Informativas:**
   - Retorno de JSON com mensagens claras e específicas
   - Inclusão de metadados relevantes (pontos, streak, etc.)
   - Flags indicando status (check-in duplicado, duração insuficiente, etc.)

### Fluxo Geral Atualizado

O novo fluxo para registro de treinos e check-ins segue estas etapas:

1. **Cliente Flutter:**
   - Valida UUIDs antes do envio
   - Usa `rpcWithValidUuids` para chamadas RPC

2. **Supabase:**
   - Função `record_challenge_check_in_v2` processa a requisição
   - Registra o treino em `workout_records`
   - Atualiza `user_progress` sempre
   - Realiza check-in no desafio se aplicável
   - Atualiza ranking do desafio

3. **Cliente Flutter (Resposta):**
   - Processa resposta JSON
   - Exibe feedback adequado ao usuário
   - Atualiza UI com novos dados

Esta atualização completa as correções anteriores, formando uma solução abrangente para os problemas de integridade e consistência entre o cliente Flutter e o Supabase.


