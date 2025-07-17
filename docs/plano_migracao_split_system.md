# Plano de Migração - Sistema Split de Registro de Treinos

## Sumário Executivo

Este documento detalha o plano completo para migração do sistema de registro de treinos do Ray Club App, implementando uma arquitetura split mais resiliente. O plano inclui todas as etapas desde modificações no banco de dados até implementação da interface de usuário, garantindo robustez, transparência e rastreabilidade.

## Contexto e Motivação

O sistema atual utiliza uma única função monolítica `record_challenge_check_in_v2` que:
1. Registra o treino
2. Atualiza o ranking de desafios
3. Atualiza o dashboard do usuário

Esta abordagem apresenta limitações:
- Ponto único de falha (uma falha afeta todo o processo)
- Tempos de resposta imprevisíveis
- Dificuldade de diagnóstico e recuperação
- Alta contenção de recursos no banco de dados

## Arquitetura Proposta

A nova arquitetura implementa um modelo split que:
1. Separa o registro de treino do processamento
2. Garante rastreabilidade completa
3. Permite recuperação automática de falhas
4. Mantém compatibilidade total com o código existente

![Arquitetura Split](https://via.placeholder.com/800x400?text=Arquitetura+Split+System)

## 1. Implementações no Banco de Dados

### 1.1. Novas Tabelas

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

### 1.2. Novas Funções

#### 1.2.1. Função de Registro Básico
```sql
CREATE OR REPLACE FUNCTION record_workout_basic(
    _user_id UUID,
    _workout_name TEXT,
    _workout_type TEXT,
    _duration_minutes INTEGER,
    _date TIMESTAMP WITH TIME ZONE,
    _challenge_id UUID DEFAULT NULL,
    _workout_id TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
-- Corpo da função (ver docs/sql/workout_migration_functions.sql)
$$ LANGUAGE plpgsql;
```

#### 1.2.2. Função de Processamento para Ranking
```sql
CREATE OR REPLACE FUNCTION process_workout_for_ranking(
    _workout_record_id UUID
)
RETURNS BOOLEAN AS $$
-- Corpo da função (ver docs/sql/workout_migration_functions.sql)
$$ LANGUAGE plpgsql;
```

#### 1.2.3. Função de Processamento para Dashboard
```sql
CREATE OR REPLACE FUNCTION process_workout_for_dashboard(
    _workout_record_id UUID
)
RETURNS BOOLEAN AS $$
-- Corpo da função (ver docs/sql/workout_migration_functions.sql)
$$ LANGUAGE plpgsql;
```

#### 1.2.4. Função Wrapper para Compatibilidade
```sql
CREATE OR REPLACE FUNCTION record_challenge_check_in_v2(
    _challenge_id uuid, 
    _date timestamp with time zone, 
    _duration_minutes integer, 
    _user_id uuid, 
    _workout_id text, 
    _workout_name text, 
    _workout_type text
)
RETURNS jsonb AS $$
-- Corpo da função (ver docs/sql/workout_migration_functions.sql)
$$ LANGUAGE plpgsql;
```

#### 1.2.5. Função de Diagnóstico e Recuperação
```sql
CREATE OR REPLACE FUNCTION diagnose_and_recover_workout_records(
    days_back INTEGER DEFAULT 7
)
RETURNS JSONB AS $$
-- Corpo da função (ver docs/sql/workout_migration_functions.sql)
$$ LANGUAGE plpgsql;
```

#### 1.2.6. Função de Retry com Controle de Concorrência
```sql
CREATE OR REPLACE FUNCTION retry_workout_processing(_workout_id UUID)
RETURNS BOOLEAN AS $$
-- Corpo da função (ver docs/sql/workout_migration_functions.sql)
$$ LANGUAGE plpgsql;
```

#### 1.2.7. Função para Resumo de Erros por Usuário
```sql
CREATE OR REPLACE FUNCTION get_error_summary_by_user()
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    error_count BIGINT,
    last_error TIMESTAMP WITH TIME ZONE
) AS $$
-- Corpo da função (ver docs/sql/workout_migration_functions.sql)
$$ LANGUAGE plpgsql;
```

## 2. Modelos de Dados Flutter

### 2.1. WorkoutProcessingStatus
```dart
class WorkoutProcessingStatus {
  final String id;
  final String workoutId;
  final bool processedForRanking;
  final bool processedForDashboard;
  final String? processingError;
  final DateTime createdAt;
  final DateTime? processedAt;
  
  bool get isFullyProcessed => 
    processedForRanking && processedForDashboard;
    
  String get statusText {
    if (isFullyProcessed) return '✅ Processado';
    if (!processedForRanking && !processedForDashboard) return '⌛ Em Análise';
    return '🔄 Processamento parcial';
  }
  
  Color get statusColor {
    if (isFullyProcessed) return Colors.green;
    return Colors.amber;
  }
  
  WorkoutProcessingStatus.fromJson(Map<String, dynamic> json)
    : id = json['id'],
      workoutId = json['workout_id'],
      processedForRanking = json['processed_for_ranking'] ?? false,
      processedForDashboard = json['processed_for_dashboard'] ?? false,
      processingError = json['processing_error'],
      createdAt = DateTime.parse(json['created_at']),
      processedAt = json['processed_at'] != null 
        ? DateTime.parse(json['processed_at']) 
        : null;
}
```

### 2.2. CheckInErrorLog
```dart
class CheckInErrorLog {
  final String id;
  final String userId;
  final String? challengeId;
  final String? workoutId;
  final Map<String, dynamic>? requestData;
  final Map<String, dynamic>? responseData;
  final String errorMessage;
  final String? errorDetail;
  final String status; // 'error', 'duplicate', 'skipped', 'recovery_failed', 'admin_retry'
  final DateTime createdAt;
  
  String get statusFormatted {
    switch (status) {
      case 'error': return 'Erro';
      case 'duplicate': return 'Duplicado';
      case 'skipped': return 'Ignorado';
      case 'recovery_failed': return 'Falha na recuperação';
      case 'admin_retry': return 'Reprocessamento manual';
      default: return status;
    }
  }
  
  Color get statusColor {
    switch (status) {
      case 'error': return Colors.red;
      case 'duplicate': return Colors.orange;
      case 'skipped': return Colors.blue;
      case 'recovery_failed': return Colors.deepPurple;
      case 'admin_retry': return Colors.teal;
      default: return Colors.grey;
    }
  }
  
  // Construtor e método fromJson
  // ...
}
```

### 2.3. Atualização do Modelo WorkoutRecord
```dart
class WorkoutRecord {
  // Campos existentes...
  final String id;
  final String workoutId;
  final String workoutName;
  final String workoutType;
  final DateTime date;
  final int durationMinutes;
  final int points;
  
  // Novo campo
  WorkoutProcessingStatus? processingStatus;
  
  // Getters para facilitar o uso na UI
  bool get isFullyProcessed => 
      processingStatus == null || 
      (processingStatus!.processedForRanking && processingStatus!.processedForDashboard);
      
  String get statusText => isFullyProcessed 
      ? "✅ Processado" 
      : "⌛ Em Análise";
      
  Color get statusColor => isFullyProcessed 
      ? Colors.green 
      : Colors.amber;
      
  // Getters para tratamento de erros
  String? get processingErrorMessage => 
      processingStatus?.processingError;
      
  bool get hasFailed => 
      processingStatus != null && 
      processingStatus!.processingError != null &&
      !isFullyProcessed;
}
```

## 3. Implementações de Repository

### 3.1. WorkoutRecordRepository
```dart
class WorkoutRecordRepository {
  final SupabaseClient _supabase;
  
  WorkoutRecordRepository(this._supabase);
  
  // Atualizado para incluir status de processamento com tratamento robusto
  Future<List<WorkoutRecord>> getUserWorkouts(String userId) async {
    final response = await _supabase
      .from('workout_records')
      .select('''
        *,
        processing:workout_processing_queue(
          id, workout_id, processed_for_ranking, processed_for_dashboard,
          processing_error, created_at, processed_at
        )
      ''')
      .eq('user_id', userId)
      .order('date', ascending: false);
    
    return (response as List).map((json) {
      final workout = WorkoutRecord.fromJson(json);
      
      // Verificar se tem dados de processamento de forma segura
      if (json['processing'] is List && json['processing'].isNotEmpty) {
        try {
          workout.processingStatus = WorkoutProcessingStatus.fromJson(
            json['processing'][0]
          );
        } catch (e) {
          // Falha silenciosa - garante que a UI continua funcionando
          debugPrint('Erro ao fazer parse do status: $e');
        }
      }
      
      return workout;
    }).toList();
  }
  
  // Outros métodos
  // ...
}
```

### 3.2. AdminRepository
```dart
class AdminRepository {
  final SupabaseClient _supabase;
  
  AdminRepository(this._supabase);
  
  // Funções de diagnóstico
  Future<Map<String, dynamic>> runSystemDiagnostics({int daysBack = 7}) async {
    final response = await _supabase
      .rpc('diagnose_and_recover_workout_records', 
        params: {'days_back': daysBack});
    
    return response;
  }
  
  // Função para retry de processamento
  Future<bool> retryProcessingForWorkout(String workoutId) async {
    final response = await _supabase.rpc(
      'retry_workout_processing',
      params: {'_workout_id': workoutId}
    );
    
    return response == true;
  }
  
  // Outros métodos
  // ...
}
```

## 4. Implementações de UI

### 4.1. Indicador de Status no Histórico de Treinos
```dart
class WorkoutHistoryItem extends StatelessWidget {
  final WorkoutRecord workout;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      // Implementação do cartão com indicador de status
      // ...
      
      // Exemplo do indicador de status
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: workout.statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: workout.statusColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!workout.isFullyProcessed)
              SizedBox(
                width: 12, height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: workout.statusColor,
                ),
              ),
            if (!workout.isFullyProcessed) SizedBox(width: 4),
            Text(
              workout.statusText,
              style: TextStyle(
                fontSize: 12,
                color: workout.statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      
      // Mensagem de erro quando aplicável
      if (workout.hasFailed)
        // Implementação da mensagem de erro
        // ...
    );
  }
}
```

### 4.2. Prevenção de Duplicação em Botões de Envio
```dart
class RecordWorkoutButton extends ConsumerWidget {
  final WorkoutParams params;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordState = ref.watch(workoutRecordProvider);
    
    return ElevatedButton(
      onPressed: recordState.isSubmitting 
        ? null  // Botão desabilitado quando isSubmitting=true
        : () => ref.read(workoutRecordProvider.notifier).recordWorkout(params),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14),
      ),
      child: recordState.isSubmitting
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white,
                ),
              ),
              SizedBox(width: 8),
              Text('Registrando...'),
            ],
          )
        : Text('Registrar Treino'),
    );
  }
}
```

### 4.3. Tela Administrativa de Erros
```dart
class ErrorAdminScreen extends StatefulWidget {
  @override
  State<ErrorAdminScreen> createState() => _ErrorAdminScreenState();
}

class _ErrorAdminScreenState extends State<ErrorAdminScreen> with SingleTickerProviderStateMixin {
  // Implementação da tela de diagnóstico
  // ...
}
```

## 5. Ordem de Implementação

1. **Fase 1**: Implementar as tabelas e funções SQL no Supabase
   - Ver seção 1.1 e 1.2

2. **Fase 2**: Criar e atualizar modelos no Flutter
   - Ver seção 2.1, 2.2 e 2.3

3. **Fase 3**: Implementar métodos de repository
   - Ver seção 3.1 e 3.2

4. **Fase 4**: Implementar ViewModels com prevenção de duplicação
   - WorkoutRecordViewModel com controle de estado

5. **Fase 5**: Implementar UI melhorada
   - Ver seção 4.1, 4.2 e 4.3

## 6. Testes e Verificações

1. **Verificar processamento de treinos**:
   - Registrar um treino e verificar se ele aparece na fila de processamento
   - Verificar se o histórico mostra o status correto
   - Verificar se a atualização de status é visível

2. **Verificar prevenção de duplicação**:
   - Tentar registrar o mesmo treino rapidamente várias vezes
   - Verificar se apenas um registro é criado

3. **Verificar recuperação de erros**:
   - Forçar um erro (treino muito curto)
   - Verificar se o erro é registrado corretamente
   - Verificar se a tela de admin mostra o erro
   - Testar o reprocessamento

## 7. Considerações Especiais

### 7.1. Controle de Concorrência
Implementamos proteções específicas para evitar condições de corrida:
- Uso de FOR UPDATE SKIP LOCKED em consultas de banco de dados
- Bloqueio explícito em operações administrativas
- Prevenção de duplicação no frontend para evitar múltiplos envios

### 7.2. Rastreabilidade
Todos os eventos são registrados para auditoria e diagnóstico:
- Registros de processamento com timestamps
- Logs detalhados de erros
- Status de reprocessamento administrativo

### 7.3. Segurança para Falhas
O sistema foi projetado com múltiplas camadas de resiliência:
- Separação de responsabilidades (registro vs. processamento)
- Capacidade de reprocessamento manual
- Diagnóstico automatizado

### 7.4. Transparência
O usuário tem visibilidade clara do status do sistema:
- Indicadores visuais de status em tempo real
- Mensagens claras em caso de falha
- Feedback imediato ao registrar treinos

## 8. Benefícios Esperados

1. **Redução de erros**: A separação de processos isola falhas
2. **Melhor experiência do usuário**: Feedback mais rápido e transparente
3. **Manutenção simplificada**: Diagnóstico e correção facilitados
4. **Performance melhorada**: Menor tempo de bloqueio no banco
5. **Escalabilidade**: Preparação para implementação futura de processamento assíncrono

## 9. Documentação Relacionada

- **Código SQL completo**: [docs/sql/workout_migration_functions.sql](sql/workout_migration_functions.sql)
- **Guia de Implementação**: [docs/implementacao_passo_a_passo.md](implementacao_passo_a_passo.md)
- **Visão Geral do Sistema**: [docs/workout_recording_system_migration.md](workout_recording_system_migration.md)

## 10. Contato e Suporte

Para dúvidas ou suporte durante a implementação, entre em contato com:
- Marcel Acunha - Desenvolvedor Principal 