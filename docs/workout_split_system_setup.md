# Sistema Split de Registro de Treinos - Guia de Implementação

Este documento contém as instruções para implementar o novo sistema split de registro de treinos, que separa o registro básico do processamento de ranking e dashboard, tornando o sistema mais resiliente e escalável.

## 1. Configuração do Banco de Dados

### 1.1. Criar Tabelas e Índices

Execute o script SQL abaixo no SQL Editor do Supabase para criar as tabelas necessárias:

```sql
-- Tabela de fila de processamento
CREATE TABLE IF NOT EXISTS workout_processing_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workout_id UUID NOT NULL REFERENCES workout_records(id) ON DELETE CASCADE,
    user_id UUID NOT NULL,
    challenge_id UUID,
    processed_for_ranking BOOLEAN DEFAULT FALSE,
    processed_for_dashboard BOOLEAN DEFAULT FALSE,
    processing_error TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_workout_queue_processing 
ON workout_processing_queue(processed_for_ranking, processed_for_dashboard);

CREATE INDEX IF NOT EXISTS idx_workout_queue_workout_id
ON workout_processing_queue(workout_id);

-- Tabela de logs de erro
CREATE TABLE IF NOT EXISTS check_in_error_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    challenge_id UUID,
    workout_id UUID,
    request_data JSONB,
    response_data JSONB,
    error_message TEXT,
    error_detail TEXT,
    status TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_checkin_error_logs_user
ON check_in_error_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_checkin_error_logs_date
ON check_in_error_logs(created_at);
```

### 1.2. Criar Funções SQL Principais

Abra o arquivo `docs/implementacao_passo_a_passo.md` e execute as seguintes funções SQL exatamente na ordem indicada:

1. `record_workout_basic` (Função de registro básico)
2. `process_workout_for_ranking` (Função de processamento de ranking)
3. `process_workout_for_dashboard` (Função de processamento de dashboard)
4. `record_challenge_check_in_v2` (Função wrapper para compatibilidade)
5. `diagnose_and_recover_workout_records` (Função de diagnóstico)

### 1.3. Criar Funções Adicionais de Diagnóstico

Execute as seguintes funções SQL adicionais:

```sql
-- Função para retry de processamento
CREATE OR REPLACE FUNCTION retry_workout_processing(_workout_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    success BOOLEAN := FALSE;
    wq_record RECORD;
BEGIN
    -- Obter e bloquear registro para evitar concorrência
    SELECT * INTO wq_record 
    FROM workout_processing_queue 
    WHERE workout_id = _workout_id
    FOR UPDATE SKIP LOCKED;
    
    -- Se já está sendo processado por outra sessão, retornar
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- Registrar tentativa administrativa
    INSERT INTO check_in_error_logs(
        user_id,
        challenge_id,
        workout_id,
        error_message,
        status,
        created_at
    ) VALUES (
        wq_record.user_id,
        wq_record.challenge_id,
        _workout_id,
        'Reprocessamento manual por administrador',
        'admin_retry',
        NOW()
    );
    
    -- Tentar processar para ranking e dashboard
    BEGIN
        PERFORM process_workout_for_ranking(_workout_id);
        success := TRUE;
    EXCEPTION WHEN OTHERS THEN
        -- Continuar para tentar dashboard
    END;
    
    BEGIN
        PERFORM process_workout_for_dashboard(_workout_id);
        success := TRUE;
    EXCEPTION WHEN OTHERS THEN
        -- Continuar
    END;
    
    RETURN success;
END;
$$ LANGUAGE plpgsql;

-- Função para resumo de erros por usuário
CREATE OR REPLACE FUNCTION get_error_summary_by_user()
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    error_count BIGINT,
    last_error TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        e.user_id,
        p.name as user_name,
        COUNT(e.id) as error_count,
        MAX(e.created_at) as last_error
    FROM check_in_error_logs e
    LEFT JOIN profiles p ON e.user_id = p.id
    GROUP BY e.user_id, p.name
    ORDER BY error_count DESC;
END;
$$ LANGUAGE plpgsql;
```

## 2. Configuração do Flutter

### 2.1. Modelos

Certifique-se de que os seguintes modelos estejam implementados:

- `WorkoutProcessingStatus` - Status de processamento de um treino
- `CheckInErrorLog` - Log de erros de processamento
- `PendingWorkout` - Para suporte offline futuro
- `WorkoutRecordState` - Estado do registro de treino

### 2.2. Repositórios

Atualize os seguintes repositórios:

- `WorkoutRecordRepository` - Para incluir métodos de processamento
- `AdminRepository` - Para funções administrativas

### 2.3. ViewModel

Atualize o ViewModel para implementar a prevenção de duplicação de envio:

- `WorkoutRecordViewModel` - Com métodos `recordWorkout` e `recordWorkoutWithOfflineSupport`

### 2.4. Componentes UI

Implemente os seguintes componentes UI:

- `WorkoutHistoryItem` - Para exibir status de processamento
- `RecordWorkoutButton` - Com prevenção de duplicação
- `ErrorAdminScreen` - Tela administrativa de diagnóstico

## 3. Rotas e Navegação

Adicione a rota para a tela de administração:

```dart
// Adicionar a rota ao GoRouter ou sistema de rotas utilizado
GoRoute(
  path: '/admin/diagnostics',
  builder: (context, state) => const ErrorAdminScreen(),
),
```

## 4. Testes e Verificações

Após a implementação, realize os seguintes testes:

1. **Teste de registro básico**:
   - Registre um treino e verifique se aparece na fila de processamento
   - Verifique se o histórico mostra o status correto

2. **Teste de prevenção de duplicação**:
   - Clique várias vezes rapidamente no botão de registrar treino
   - Verifique se apenas um registro é criado

3. **Teste de controle de erros**:
   - Tente registrar um treino com duração menor que 45 minutos para forçar um erro
   - Verifique se o erro é registrado e exibido corretamente

4. **Teste de recuperação administrativa**:
   - Acesse a tela administrativa
   - Execute diagnóstico no sistema
   - Tente reprocessar um treino com erro

## 5. FAQ e Solução de Problemas

**P: O que fazer se os registros não estão sendo processados?**
R: Execute a função `diagnose_and_recover_workout_records(1)` para identificar e recuperar registros com problemas no último dia.

**P: Como verificar se há erros no sistema?**
R: Acesse a tela administrativa em `/admin/diagnostics` ou consulte a tabela `check_in_error_logs` diretamente no Supabase.

**P: O que significa o status "Em Análise" no histórico de treinos?**
R: Indica que o treino foi registrado, mas ainda está aguardando processamento completo para atualização de ranking e dashboard.

## 6. Considerações Adicionais

- O sistema mantém compatibilidade total com o código existente através da função wrapper `record_challenge_check_in_v2`
- A prevenção de duplicação impede o usuário de enviar o mesmo treino várias vezes acidentalmente
- A tela de administração permite diagnóstico e recuperação de erros sem necessidade de intervenção técnica
- O sistema está preparado para implementação futura de processamento assíncrono completo

Se precisar de mais informações técnicas detalhadas, consulte o arquivo `docs/implementacao_passo_a_passo.md`. 