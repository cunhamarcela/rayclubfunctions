# 🎯 ALINHAMENTO ESTRUTURAL: CÓDIGO ↔ BANCO DE DADOS

**Data:** 30 de Janeiro de 2025  
**Objetivo:** Garantir perfeita integração entre Flutter e Supabase  
**Status:** 🚧 Em Implementação

## 📋 ESTRUTURA DA TABELA `user_goals`

### ✅ Colunas Obrigatórias

| **Flutter (UnifiedGoal)** | **Supabase (user_goals)** | **Tipo** | **Observações** |
|---------------------------|---------------------------|----------|-----------------|
| `id` | `id` | `UUID` | Chave primária |
| `userId` | `user_id` | `UUID` | FK para `auth.users(id)` |
| `title` | `title` | `TEXT` | Título da meta |
| `description` | `description` | `TEXT` | Descrição (opcional) |
| `type.value` | `type` | `TEXT` | `'workout_category'`, `'custom'`, etc. |
| `category?.displayName` | `category` | `TEXT` | `'Funcional'`, `'Musculação'`, etc. |
| `targetValue` | `target` | `DECIMAL` | Valor alvo da meta |
| `currentValue` | `progress` | `DECIMAL` | Progresso atual |
| `unit.value` | `unit` | `TEXT` | `'minutos'`, `'dias'`, `'sessoes'` |
| `measurementType` | `measurement_type` | `TEXT` | `'minutes'` ou `'days'` |
| `startDate` | `start_date` | `TIMESTAMPTZ` | Data de início |
| `endDate` | `end_date` | `TIMESTAMPTZ` | Data de fim (opcional) |
| `completedAt` | `completed_at` | `TIMESTAMPTZ` | Data de conclusão (opcional) |
| `createdAt` | `created_at` | `TIMESTAMPTZ` | Data de criação |
| `updatedAt` | `updated_at` | `TIMESTAMPTZ` | Data de atualização |

## 🔄 INTEGRAÇÃO COM `workout_records`

### Mapeamento de Tipos de Exercício

```dart
// Flutter: GoalCategory enum
enum GoalCategory {
  funcional('Funcional'),     // workout_records.workout_type = 'Funcional'
  musculacao('Musculação'),   // workout_records.workout_type = 'Musculação'
  pilates('Pilates'),         // workout_records.workout_type = 'Pilates'
  forca('Força'),             // workout_records.workout_type = 'Força'
  alongamento('Alongamento'), // workout_records.workout_type = 'Alongamento'
  corrida('Corrida'),         // workout_records.workout_type = 'Corrida'
  fisioterapia('Fisioterapia'), // workout_records.workout_type = 'Fisioterapia'
  outro('Outro'),             // workout_records.workout_type = 'Outro'
}
```

### Trigger Automático

```sql
-- Função que atualiza metas automaticamente
CREATE OR REPLACE FUNCTION update_goals_from_workout()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.user_goals 
    SET 
        progress = progress + NEW.duration_minutes,
        updated_at = NOW()
    WHERE 
        user_id = NEW.user_id
        AND category = NEW.workout_type  -- ALINHAMENTO CRÍTICO
        AND measurement_type = 'minutes'
        AND completed_at IS NULL;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## 📱 CONVERSÃO DE DADOS

### Flutter → Supabase (`toDatabaseMap`)

```dart
Map<String, dynamic> toDatabaseMap() {
  return {
    'id': id,
    'user_id': userId,
    'title': title,
    'description': description,
    'type': type.value,                    // 'workout_category', 'custom'
    'category': category?.displayName,     // 'Funcional', 'Musculação'
    'target': targetValue,
    'progress': currentValue,
    'unit': unit.value,                    // 'minutos', 'dias'
    'measurement_type': measurementType,   // 'minutes', 'days'
    'start_date': startDate.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
```

### Supabase → Flutter (`fromDatabaseMap`)

```dart
factory UnifiedGoal.fromDatabaseMap(Map<String, dynamic> data) {
  return UnifiedGoal(
    id: data['id'] as String,
    userId: data['user_id'] as String,
    title: data['title'] as String,
    description: data['description'] as String?,
    type: _parseGoalType(data['type'] as String),
    category: GoalCategory.fromString(data['category'] as String?),
    targetValue: (data['target'] as num).toDouble(),
    currentValue: (data['progress'] as num?)?.toDouble() ?? 0.0,
    unit: _parseGoalUnit(data['unit'] as String),
    measurementType: data['measurement_type'] as String? ?? 'minutes',
    startDate: DateTime.parse(data['start_date'] as String),
    endDate: data['end_date'] != null ? DateTime.parse(data['end_date'] as String) : null,
    isCompleted: data['completed_at'] != null,
    completedAt: data['completed_at'] != null ? DateTime.parse(data['completed_at'] as String) : null,
    autoIncrement: true,
    createdAt: DateTime.parse(data['created_at'] as String),
    updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at'] as String) : null,
  );
}
```

## 🎯 FLUXO COMPLETO

### 1. Usuário Cria Meta Pré-definida
```dart
// Flutter
final goal = UnifiedGoal(
  userId: '01d4a292-1873-4af6-948b-a55eed56d6b9',
  title: 'Meta Funcional',
  type: UnifiedGoalType.workoutCategory,
  category: GoalCategory.funcional,  // ← 'Funcional'
  targetValue: 150.0,
  unit: GoalUnit.minutos,
  measurementType: 'minutes',
  // ...
);

// Supabase INSERT
INSERT INTO user_goals (
  user_id, title, type, category, target, unit, measurement_type, ...
) VALUES (
  '01d4a292-1873-4af6-948b-a55eed56d6b9',
  'Meta Funcional',
  'workout_category',
  'Funcional',  -- ← EXATO match com workout_records.workout_type
  150.0,
  'minutos',
  'minutes',
  ...
);
```

### 2. Usuário Registra Treino
```sql
-- Workout registrado
INSERT INTO workout_records (
  user_id, workout_type, duration_minutes, ...
) VALUES (
  '01d4a292-1873-4af6-948b-a55eed56d6b9',
  'Funcional',  -- ← TRIGGER vai encontrar meta com category = 'Funcional'
  45,
  ...
);

-- Trigger automático atualiza meta
UPDATE user_goals 
SET progress = progress + 45  -- 0 + 45 = 45
WHERE user_id = '01d4a292-1873-4af6-948b-a55eed56d6b9'
  AND category = 'Funcional'
  AND measurement_type = 'minutes';
```

## ⚠️ PONTOS CRÍTICOS DE ALINHAMENTO

### 1. **Nomenclatura Exata**
- `workout_records.workout_type` DEVE ser IDÊNTICO a `user_goals.category`
- Valores: `'Funcional'`, `'Musculação'`, `'Pilates'`, etc.

### 2. **Colunas Obrigatórias**
```sql
-- VERIFICAR se existem:
ALTER TABLE user_goals ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE user_goals ADD COLUMN IF NOT EXISTS measurement_type TEXT DEFAULT 'minutes';
```

### 3. **Tipos de Dados**
- `target` e `progress`: `DECIMAL` (não `INTEGER`)
- `measurement_type`: `TEXT` com valores `'minutes'` ou `'days'`
- Todas as datas: `TIMESTAMPTZ`

### 4. **Funções SQL**
```sql
-- OBRIGATÓRIAS para funcionamento:
- update_goals_from_workout()
- register_goal_checkin()
- trigger_update_goals_from_workout (TRIGGER)
```

## 🔧 COMANDOS DE CORREÇÃO

### Garantir Estrutura Correta
```sql
-- 1. Adicionar colunas faltantes
ALTER TABLE user_goals ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE user_goals ADD COLUMN IF NOT EXISTS measurement_type TEXT DEFAULT 'minutes';

-- 2. Verificar dados existentes
SELECT category, COUNT(*) FROM user_goals GROUP BY category;
SELECT workout_type, COUNT(*) FROM workout_records GROUP BY workout_type;

-- 3. Alinhar dados inconsistentes (se necessário)
UPDATE user_goals SET category = 'Funcional' WHERE category = 'functional';
```

## ✅ TESTE DE VALIDAÇÃO

Execute `sql/test_metas_system_fixed.sql` para validar:

1. ✅ Estrutura da tabela
2. ✅ Funções SQL existem
3. ✅ Triggers funcionam
4. ✅ Integração workout → meta
5. ✅ Check-ins manuais
6. ✅ Múltiplos treinos
7. ✅ Seletividade por categoria

---

**🎯 RESULTADO ESPERADO:** Sistema 100% funcional com integração perfeita entre Flutter e Supabase.

