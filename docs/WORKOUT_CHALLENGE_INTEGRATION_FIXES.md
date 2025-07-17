# Correção da Integração entre Treinos e Desafios

Este documento descreve as correções implementadas para resolver problemas na integração entre o registro de treinos e a atualização de progresso em desafios no aplicativo Ray Club.

## Problemas Corrigidos

### 1. Erro de ambiguidade de coluna 
- **Problema**: A consulta SQL estava referenciando a coluna `check_ins_count` sem especificar a tabela, resultando em ambiguidade.
- **Solução**: Qualificamos a coluna com o nome da tabela (`challenge_progress.check_ins_count`).

### 2. Erro ao buscar progresso do usuário
- **Problema**: Às vezes, existiam múltiplos registros de progresso para o mesmo usuário e desafio, causando o erro "JSON object requested, multiple (or no) rows returned".
- **Solução**: Implementamos uma verificação prévia para detectar registros duplicados, mantendo apenas o mais recente e removendo os demais. Além disso, substituímos o método `.single()` por `.maybeSingle()` para evitar exceções.

### 3. Erro no registro de check-in
- **Problema**: A comparação de datas para verificar check-ins existentes estava usando operadores inadequados, gerando o erro "operator does not exist: timestamp with time zone ~~* unknown".
- **Solução**: Adicionamos uma coluna `formatted_date` padronizada (YYYY-MM-DD) para comparações consistentes e criamos índices apropriados para consultas mais eficientes.

### 4. Erros no processamento de treinos para desafios
- **Problema**: Falhas em um desafio estavam interrompendo o processamento de outros desafios.
- **Solução**: Reorganizamos o código para tratar exceções individualmente para cada desafio, permitindo que o processo continue mesmo quando um desafio específico falha.

## Mudanças na Estrutura do Banco de Dados

Foi adicionada uma nova coluna `formatted_date` à tabela `challenge_check_ins` para armazenar a data em formato YYYY-MM-DD, facilitando consultas e evitando problemas com fusos horários.

### Migração SQL

O arquivo de migração `migrations/sql/20250413_add_formatted_date_to_challenge_check_ins.sql` contém os seguintes comandos:

1. Adicionar a coluna `formatted_date` (VARCHAR(10))
2. Preencher valores existentes com dados formatados a partir de `check_in_date`
3. Criar índices para otimizar consultas:
   - Índice na coluna `formatted_date`
   - Índice único composto em `(user_id, challenge_id, formatted_date)` para evitar duplicatas
4. Criar um trigger para preencher automaticamente `formatted_date` em novos registros

## Como Aplicar as Alterações

### 1. Aplicar a Migração SQL no Supabase

Execute o arquivo de migração no painel do Supabase:

1. Acesse o projeto no [Console do Supabase](https://app.supabase.io)
2. Navegue até "SQL Editor" 
3. Copie o conteúdo de `migrations/sql/20250413_add_formatted_date_to_challenge_check_ins.sql`
4. Execute o script

### 2. Atualizar as Permissões de RLS (Row Level Security)

Verifique se as políticas RLS estão corretamente configuradas para a nova coluna:

```sql
ALTER POLICY "Usuários podem ler seus próprios check-ins" 
ON challenge_check_ins FOR SELECT 
USING (auth.uid() = user_id);

ALTER POLICY "Usuários podem criar seus próprios check-ins" 
ON challenge_check_ins FOR INSERT 
WITH CHECK (auth.uid() = user_id);
```

### 3. Limpar Dados Inconsistentes (Opcional)

Se necessário, você pode executar este comando para remover registros de progresso duplicados:

```sql
WITH ranked_progress AS (
  SELECT 
    id,
    user_id,
    challenge_id,
    ROW_NUMBER() OVER (
      PARTITION BY user_id, challenge_id 
      ORDER BY last_updated DESC NULLS LAST, created_at DESC NULLS LAST
    ) as rn
  FROM challenge_progress
)
DELETE FROM challenge_progress 
WHERE id IN (
  SELECT id FROM ranked_progress WHERE rn > 1
);
```

## Verificação da Correção

Após aplicar as alterações, você pode confirmar que a integração está funcionando corretamente:

1. Registre um novo treino
2. Verifique se o treino aparece no histórico
3. Verifique se os pontos foram adicionados aos desafios ativos
4. Confirme que o progresso do usuário foi atualizado na tela de desafios

## Considerações Futuras

Para melhorar ainda mais a robustez da integração:

1. Implementar transações para garantir que operações relacionadas sejam executadas como uma unidade atômica
2. Adicionar mais validação de dados antes de tentar operações no banco
3. Considerar a implementação de um sistema de filas para processar check-ins de desafios em background
4. Melhorar o feedback ao usuário sobre pontos ganhos e progresso em desafios 