# Corrigindo Erro de Coluna Ausente no Supabase

## Problema Identificado

Ao tentar registrar treinos, o aplicativo está encontrando o seguinte erro:

```
flutter: ❌ Erro do Supabase: PostgrestException(message: Could not find the 'image_urls' column of 'workout_records' in the schema cache, code: PGRST204, details: Bad Request, hint: null)
flutter: ❌ Erro ao salvar registro de treino: AppException [PGRST204]: Erro ao criar registro de treino no Supabase
```

Este erro ocorre porque o modelo `WorkoutRecord` do aplicativo espera uma coluna `image_urls` na tabela `workout_records`, mas esta coluna não existe no banco de dados Supabase.

Após análise adicional, identificamos que também pode estar faltando a coluna `updated_at`, que é mencionada no esquema documentado mas não aparece no script de criação da tabela.

## Solução

### Opção 1: Adicionar as colunas no Supabase SQL Editor

1. Acesse o painel do Supabase para seu projeto
2. Vá para a seção **SQL Editor**
3. Crie uma nova query e execute o seguinte SQL:

```sql
-- Verificar se as colunas existem e adicionar se necessário
DO $$
BEGIN
    -- Verificar e adicionar image_urls
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'workout_records'
        AND column_name = 'image_urls'
    ) THEN
        ALTER TABLE workout_records ADD COLUMN image_urls TEXT[] DEFAULT '{}';
        RAISE NOTICE 'Coluna image_urls adicionada com sucesso';
    ELSE
        RAISE NOTICE 'A coluna image_urls já existe';
    END IF;
    
    -- Verificar e adicionar updated_at
    IF NOT EXISTS (
        SELECT 1
        FROM information_schema.columns
        WHERE table_name = 'workout_records'
        AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE workout_records ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        
        -- Criar trigger para atualizar automaticamente
        CREATE OR REPLACE FUNCTION update_workout_records_updated_at()
        RETURNS TRIGGER AS $$
        BEGIN
            NEW.updated_at = NOW();
            RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;

        DROP TRIGGER IF EXISTS trigger_update_workout_records_updated_at ON workout_records;
        CREATE TRIGGER trigger_update_workout_records_updated_at
        BEFORE UPDATE ON workout_records
        FOR EACH ROW
        EXECUTE FUNCTION update_workout_records_updated_at();
        
        RAISE NOTICE 'Coluna updated_at e trigger adicionados com sucesso';
    ELSE
        RAISE NOTICE 'A coluna updated_at já existe';
    END IF;
END $$;
```

### Opção 2: Usando o script de migração completo

Foi criado um script de migração que adiciona todas as colunas faltantes:

1. Acesse o arquivo `scripts/migrations/add_missing_workout_columns.sql` no projeto
2. Copie o conteúdo deste arquivo
3. Cole no SQL Editor do Supabase e execute

Este script verifica e adiciona as seguintes colunas, caso não existam:
- `image_urls` (TEXT[] - array de URLs)
- `updated_at` (TIMESTAMP WITH TIME ZONE - com trigger para atualização automática)
- `completion_status` (TEXT - status de conclusão do treino)

### Opção 3: Alternativa temporária no código

Se você não puder modificar o banco de dados imediatamente, uma solução temporária é modificar o código para não enviar os campos ausentes:

1. Abra o arquivo `lib/features/workout/models/workout_record_adapter.dart`
2. Localize o método `toDatabaseJson`
3. Remova ou comente as linhas que adicionam campos ausentes

## Verificação

Após aplicar a correção, você pode verificar se as colunas foram adicionadas executando:

```sql
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'workout_records';
```

## Prevenção de Problemas Futuros

Para evitar esse tipo de problema no futuro:

1. Sempre verifique se há correspondência entre os modelos no código e as tabelas no banco de dados
2. Implemente verificações de compatibilidade de schema durante a inicialização do aplicativo
3. Mantenha a documentação `SUPABASE_SCHEMA.md` atualizada quando houver mudanças no esquema
4. Considere usar ferramentas de migração para garantir que o esquema evolua de forma consistente

## Observações

- A coluna `image_urls` é definida como um array de texto (`TEXT[]`) para armazenar múltiplas URLs de imagens
- A coluna `updated_at` inclui um trigger para atualização automática quando um registro é modificado
- O valor padrão para `image_urls` é um array vazio (`'{}'`)
- O valor padrão para `completion_status` é `'completed'`
- O valor padrão para `updated_at` é o timestamp atual (`NOW()`)
- Esta correção está alinhada com o esquema documentado em `doc/SUPABASE_SCHEMA.md` 