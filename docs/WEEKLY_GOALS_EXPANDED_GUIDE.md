# 🎯 Sistema de Metas Semanais Expandido

**Data:** 2025-01-27  
**Objetivo:** Sistema completo de metas semanais com opções pré-estabelecidas e personalização  
**Autor:** IA Assistant

---

## ✨ **Novidades Implementadas**

### 🏆 **Metas Pré-Estabelecidas**
1. **Projeto Bruna Braga** - 7 dias consecutivos de treino
2. **Cardio** - Opções de minutos ou dias por semana
3. **Musculação** - Opções de minutos ou dias por semana
4. **Meta Personalizada** - Usuário define tipo, valor e unidade

### 📊 **Tipos de Medição Suportados**
- ⏱️ **Minutos** - Para duração de exercícios
- 📅 **Dias** - Para frequência semanal
- ✅ **Check-ins** - Para confirmações/concluídos
- ⚖️ **Peso** - Para metas de peso corporal
- 🔁 **Repetições** - Para sets/repetições
- 📏 **Distância** - Para quilometragem
- 🎛️ **Personalizado** - Qualquer unidade customizada

---

## 🏗️ **Arquitetura Implementada**

### **1. Banco de Dados**
```sql
-- Tabela expandida com novos campos
CREATE TABLE weekly_goals_expanded (
    id UUID PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id),
    goal_type goal_preset_type,           -- Novo: tipo de preset
    measurement_type goal_measurement_type, -- Novo: tipo de medição
    goal_title VARCHAR(255),              -- Novo: título customizável
    goal_description TEXT,                -- Novo: descrição opcional
    target_value NUMERIC,                 -- Expandido: valor alvo flexível
    current_value NUMERIC,                -- Expandido: progresso flexível
    unit_label VARCHAR(50),               -- Novo: rótulo da unidade
    -- ... outros campos existentes
);
```

### **2. Modelos Flutter**
- `WeeklyGoalExpanded` - Modelo principal expandido
- `GoalPresetType` - Enum para tipos pré-estabelecidos
- `GoalMeasurementType` - Enum para tipos de medição
- `WeeklyGoalExpandedPreset` - Configurações padrão

### **3. Arquitetura MVVM + Riverpod**
- `WeeklyGoalExpandedRepository` - Comunicação com Supabase
- `WeeklyGoalExpandedViewModel` - Gerenciamento de estado
- Múltiplos providers para diferentes aspectos

---

## 🚀 **Como Usar no Dashboard**

### **Implementação Simples**
```dart
// No seu dashboard, substitua o widget atual por:
WeeklyProgressDashboardExpanded()
```

### **Implementação Manual com Controle**
```dart
class MyDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalState = ref.watch(weeklyGoalExpandedViewModelProvider);
    
    return Column(
      children: [
        // Mostrar meta atual
        if (goalState.currentGoal != null)
          GoalProgressCard(goal: goalState.currentGoal!),
        
        // Botão para nova meta
        ElevatedButton(
          onPressed: () => _showGoalSelector(context),
          child: Text('+ Nova Meta'),
        ),
      ],
    );
  }
  
  void _showGoalSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => WeeklyGoalSelectorExpandedWidget(
        onGoalCreated: () => Navigator.pop(context),
      ),
    );
  }
}
```

---

## 🎮 **Funcionalidades Principais**

### **Para o Usuário Final**

#### **1. Metas Rápidas (1 clique)**
- **Projeto Bruna Braga**: Automaticamente configura 7 dias
- **Cardio 150min**: Meta padrão de 150 minutos por semana
- **Cardio 3 dias**: Meta de 3 dias de cardio
- **Musculação 180min**: Meta de 3 horas por semana
- **Musculação 4 dias**: Meta de 4 dias de treino

#### **2. Meta Personalizada**
- Nome customizado ("Correr toda semana")
- Escolha do tipo de medição
- Valor alvo personalizável
- Unidade customizada
- Descrição opcional

#### **3. Acompanhamento Visual**
- Barra de progresso animada
- Porcentagem de conclusão
- Mensagens motivacionais
- Cores dinâmicas baseadas no progresso

### **Para o Sistema**

#### **Sincronização Automática**
```sql
-- Treinos são automaticamente contabilizados
-- Trigger atualiza metas baseado na categoria:
CREATE TRIGGER sync_workout_to_weekly_goals_expanded_trigger
    AFTER INSERT ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION sync_workout_to_weekly_goals_expanded();
```

#### **Reset Semanal**
- Toda segunda-feira às 00:00
- Metas antigas são desativadas
- Sistema pronto para nova semana

---

## 📱 **Interface de Usuário**

### **Dashboard Principal**
```
┌─────────────────────────────────┐
│ 🎯 Metas da Semana    + Nova Meta│
├─────────────────────────────────┤
│ 🏋️ Projeto Bruna Braga          │
│ Complete 7 dias seguindo...     │
│ ▓▓▓▓▓░░░ 71% (5/7 dias)        │
│ Quase lá! Você consegue! 💪     │
├─────────────────────────────────┤
│ Atividade da Semana    5 de 7   │
│ S T Q Q S S D                   │
│ ✓ ✓ ✓ ✓ ✓ 6 7                  │
└─────────────────────────────────┘
```

### **Seletor de Metas**
```
┌─────────────────────────────────┐
│ 🚩 Defina sua Meta Semanal ✨    │
│ Escolha uma meta para se manter │
│ motivado durante a semana 🌱    │
├─────────────────────────────────┤
│ Metas Populares                 │
│                                 │
│ 🏋️ Projeto Bruna Braga          │
│ 7 dias seguindo o programa! 💪  │
│ [7 dias]                        │
├─────────────────────────────────┤
│ Cardio                          │
│ [150min] [3 dias]               │
│                                 │
│ Musculação                      │
│ [180min] [4 dias]               │
├─────────────────────────────────┤
│ ✏️ Meta Personalizada            │
│ Crie sua própria meta customizada│
└─────────────────────────────────┘
```

---

## 🔧 **Configuração e Deploy**

### **1. Aplicar SQL no Supabase**
```bash
# Execute o arquivo SQL expandido
psql -h sua-url-supabase -d postgres -U postgres -f sql/create_weekly_goals_expanded_system.sql
```

### **2. Atualizar Imports**
```dart
// Adicione nos seus imports:
import 'package:ray_club_app/features/goals/models/weekly_goal_expanded.dart';
import 'package:ray_club_app/features/goals/viewmodels/weekly_goal_expanded_view_model.dart';
import 'package:ray_club_app/features/goals/widgets/weekly_goal_selector_expanded_widget.dart';
import 'package:ray_club_app/features/home/widgets/weekly_progress_dashboard_expanded.dart';
```

### **3. Substituir Dashboard**
```dart
// Em vez de:
WeeklyProgressDashboard()

// Use:
WeeklyProgressDashboardExpanded()
```

---

## 🔄 **Compatibilidade**

### **Sistema Legacy**
- ✅ Sistema antigo (`weekly_goals`) continua funcionando
- ✅ Dados existentes preservados
- ✅ Migração gradual possível
- ✅ Rollback seguro disponível

### **Migração Gradual**
```dart
// Provider condicional para teste A/B
final useExpandedGoalsProvider = Provider<bool>((ref) {
  // Retorna true para usuários beta
  return ref.watch(authProvider).currentUser?.isBetaUser ?? false;
});

// Widget condicional
Consumer(
  builder: (context, ref, child) {
    final useExpanded = ref.watch(useExpandedGoalsProvider);
    
    return useExpanded 
        ? WeeklyProgressDashboardExpanded()
        : WeeklyProgressDashboard();
  },
)
```

---

## 📊 **Exemplos de Uso**

### **Criar Meta de Cardio por Código**
```dart
final viewModel = ref.read(weeklyGoalExpandedViewModelProvider.notifier);

// Meta pré-estabelecida
await viewModel.createPresetGoal(GoalPresetType.cardio);

// Meta personalizada
await viewModel.createCustomGoal(
  goalTitle: 'Nadar 3x por semana',
  measurementType: GoalMeasurementType.days,
  targetValue: 3,
  unitLabel: 'dias',
);
```

### **Acompanhar Progresso**
```dart
// Adicionar progresso automaticamente (via trigger)
// Ou manualmente:
await viewModel.addProgress(
  value: 30, // 30 minutos
  measurementType: GoalMeasurementType.minutes,
);
```

### **Exibir Estatísticas**
```dart
Consumer(
  builder: (context, ref, child) {
    final stats = ref.watch(weeklyGoalStatsProvider);
    
    if (stats != null) {
      return Column(
        children: [
          Text('Taxa de conclusão: ${stats['completion_rate']}%'),
          Text('Sequência: ${stats['streak']} semanas'),
          Text('Progresso atual: ${stats['current_week_progress']}%'),
        ],
      );
    }
    
    return CircularProgressIndicator();
  },
)
```

---

## 🎨 **Personalização Visual**

### **Cores por Tipo de Meta**
- 🩷 **Projeto Bruna Braga**: Pink (`#E91E63`)
- ❤️ **Cardio**: Vermelho (`#F44336`)
- 💙 **Musculação**: Azul (`#2196F3`)
- 🔘 **Personalizada**: Cinza (`#9E9E9E`)

### **Ícones Dinâmicos**
- 🏋️ Fitness Center para Bruna Braga
- ❤️ Favorite para Cardio
- 🤸 Sports Gymnastics para Musculação
- ✏️ Edit para Personalizada

### **Mensagens Motivacionais**
```
0-25%:   "Vamos começar juntos! 🌱"
25-50%:  "Bom começo! Vamos em frente! 🚀"
50-80%:  "Metade do caminho! Continue assim! 🌟"
80-99%:  "Quase lá! Você consegue! 💪"
100%+:   "Parabéns! Meta conquistada! ✨"
```

---

## 🚨 **Troubleshooting**

### **Meta não aparece no dashboard**
```dart
// Verificar se o usuário está autenticado
final authState = ref.watch(authProvider);
if (authState.currentUser == null) {
  // Usuário precisa fazer login
}

// Forçar refresh
ref.read(weeklyGoalExpandedViewModelProvider.notifier).refresh();
```

### **Progresso não atualiza automaticamente**
```sql
-- Verificar se o trigger está ativo
SELECT * FROM information_schema.triggers 
WHERE trigger_name = 'sync_workout_to_weekly_goals_expanded_trigger';

-- Verificar função
SELECT proname FROM pg_proc WHERE proname = 'sync_workout_to_weekly_goals_expanded';
```

### **Performance lenta**
```sql
-- Verificar índices
SELECT * FROM pg_indexes WHERE tablename = 'weekly_goals_expanded';

-- Analisar queries
EXPLAIN ANALYZE SELECT * FROM weekly_goals_expanded WHERE user_id = $1;
```

---

## 📈 **Próximos Passos**

### **Funcionalidades Futuras**
- 🏆 Sistema de conquistas por tipo de meta
- 📊 Relatórios detalhados por categoria
- 👥 Metas compartilhadas/grupos
- 🎯 Metas mensais e anuais
- 📱 Notificações personalizadas por tipo

### **Melhorias Técnicas**
- 🔄 Cache local para performance
- 📦 Compressão de dados históricos
- 🔍 Busca e filtros avançados
- 📈 Analytics e métricas detalhadas

---

## ✅ **Status de Implementação**

- ✅ **Banco de dados expandido** (2025-01-27)
- ✅ **Modelos Flutter completos** (2025-01-27)
- ✅ **Repository + ViewModel** (2025-01-27)
- ✅ **Widget de seleção expandido** (2025-01-27)
- ✅ **Dashboard atualizado** (2025-01-27)
- ✅ **Sincronização automática** (2025-01-27)
- ✅ **Sistema de providers** (2025-01-27)
- ✅ **Documentação completa** (2025-01-27)

**🚀 Sistema 100% funcional e pronto para uso!** 