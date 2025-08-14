# 🎨 Showcase Completo - Widgets de Metas Semanais

**Data:** 2025-01-27  
**Objetivo:** Demonstrar todas as opções de widgets disponíveis  
**Autor:** IA Assistant

---

## 🏗️ **Arsenal Completo de Widgets**

### **1. 🎯 Widget Principal - WeeklyGoalProgressSummaryWidget**

```dart
const WeeklyGoalProgressSummaryWidget()
```

**Visual:**
```
┌─────────────────────────────────────────────┐
│ 🎯 Meta da Semana                      71%  │
│ 🏋️ Projeto Bruna Braga                      │
│                                             │
│ 5 / 7 dias                  2 dias restantes│
│ ▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
│                                             │
│ 📈 Quase lá! Você consegue! 💪              │
│                                             │
│                              ✅ Concluída   │
└─────────────────────────────────────────────┘
```

**Estados:**
- **Sem meta:** Convite para criar
- **Com progresso:** Barra + estatísticas
- **Meta atingida:** Badge verde "Concluída"

---

### **2. 📊 Widget de Estatísticas - WeeklyGoalStatsWidget**

```dart
const WeeklyGoalStatsWidget()
```

**Visual:**
```
┌──────────────────────────────────────────────┐
│ 🔥     📊      ⏰                            │
│ 3 sem  85%    2 dias                        │
│ Sequência Taxa Restante                     │
└──────────────────────────────────────────────┘
```

**Dados:**
- **🔥 Sequência:** Semanas consecutivas com meta atingida
- **📊 Taxa:** Porcentagem geral de conclusão
- **⏰ Restante:** O que falta para atingir meta atual

---

### **3. 📱 Widget Mini - WeeklyGoalProgressMiniWidget**

```dart
const WeeklyGoalProgressMiniWidget()
```

**Visual:**
```
┌─────────────────────────────────────┐
│ 🏋️ Meta de Musculação          67% │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░            │
└─────────────────────────────────────┘
```

**Uso:** Rodapé, sidebar, ou como widget secundário

---

### **4. 📈 Widget de Evolução - WeeklyGoalEvolutionChartWidget**

```dart
const WeeklyGoalEvolutionChartWidget()
```

**Visual:**
```
┌───────────────────────────────────────────────┐
│ Evolução das Metas                         📊 │
│                                               │
│     85%  71%  92%  78%                       │
│     ██   ██   ██   ██                        │
│     ██   ██   ██   ██                        │
│     ██   ░░   ██   ██                        │
│     ██   ░░   ██   ░░                        │
│   Sem1 Sem2 Sem3 Sem4                       │
│    ●    ●    ●    ●                         │
│                                               │
│ ┌─────────────────────────────────────────┐   │
│ │ ✅ 3/4  📊 81%  🔥 2                   │   │
│ │ Concluídas Média Sequência              │   │
│ └─────────────────────────────────────────┘   │
└───────────────────────────────────────────────┘
```

**Características:**
- Barras das últimas 4 semanas
- Cores: Verde (100%+), Laranja (70%+), Cinza (<70%)
- Resumo com estatísticas

---

### **5. 📊 Widget de Tendência - WeeklyGoalTrendWidget**

```dart
const WeeklyGoalTrendWidget()
```

**Visual:**
```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ 📈 +15%      │  │ ➡️ Estável    │  │ 📉 -8%       │
└──────────────┘  └──────────────┘  └──────────────┘
   Melhorando        Estável          Piorando
```

**Cores:**
- 🟢 Verde: Melhorando (+5% ou mais)
- 🔵 Azul: Estável (-5% a +5%)
- 🔴 Vermelho: Piorando (-5% ou menos)

---

## 🎨 **Combinações Populares**

### **Dashboard Completo:**
```dart
Column(
  children: [
    WeeklyGoalProgressSummaryWidget(),    // Widget principal
    WeeklyGoalStatsWidget(),              // Estatísticas
    WeeklyGoalEvolutionChartWidget(),     // Gráfico de evolução
    // ... outros widgets do dashboard
  ],
)
```

### **Dashboard Compacto:**
```dart
Column(
  children: [
    WeeklyGoalProgressSummaryWidget(),    // Widget principal
    WeeklyGoalStatsWidget(),              // Apenas estatísticas
    // ... resto do dashboard
  ],
)
```

### **Header com Tendência:**
```dart
Row(
  children: [
    Expanded(child: YourTitle()),
    WeeklyGoalTrendWidget(),              // Tendência
  ],
)
```

### **Rodapé Informativo:**
```dart
Column(
  children: [
    // ... conteúdo principal
    WeeklyGoalProgressMiniWidget(),       // Mini no final
  ],
)
```

---

## 📱 **Exemplos por Tipo de Meta**

### **Projeto Bruna Braga (7 dias):**
```
┌─────────────────────────────────────────────┐
│ 🎯 Meta da Semana                      71%  │
│ 🏋️ Projeto Bruna Braga                      │
│                                             │
│ 5 / 7 dias                  2 dias restantes│
│ ▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
│                                             │
│ 📈 Quase lá! Você consegue! 💪              │
└─────────────────────────────────────────────┘
```

### **Meta de Cardio (150 min):**
```
┌─────────────────────────────────────────────┐
│ 🎯 Meta da Semana                      67%  │
│ ❤️ Meta de Cardio                           │
│                                             │
│ 100 / 150 min               3 dias restantes│
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
│                                             │
│ 📈 Metade do caminho! Continue assim! 🌟    │
└─────────────────────────────────────────────┘
```

### **Meta Personalizada (5 km):**
```
┌─────────────────────────────────────────────┐
│ 🎯 Meta da Semana                      40%  │
│ 🏃 Correr no Parque                         │
│                                             │
│ 2 / 5 km                    4 dias restantes│
│ ▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
│                                             │
│ 📈 Bom começo! Vamos em frente! 🚀          │
└─────────────────────────────────────────────┘
```

---

## 🎯 **Estados dos Widgets**

### **1. Estado Inicial (Sem Meta):**
```
┌─────────────────────────────────────────────┐
│           🚩                                │
│                                             │
│        Defina sua meta semanal              │
│                                             │
│ Toque para escolher entre Bruna Braga,     │
│ Cardio, Musculação ou criar personalizada  │
└─────────────────────────────────────────────┘
```

### **2. Estado Carregando:**
```
┌─────────────────────────────────────────────┐
│                                             │
│                   ⭕                       │
│               Carregando...                 │
│                                             │
└─────────────────────────────────────────────┘
```

### **3. Meta em Progresso:**
```
┌─────────────────────────────────────────────┐
│ 🎯 Meta da Semana                      45%  │
│ 💪 Meta de Musculação                       │
│                                             │
│ 81 / 180 min                5 dias restantes│
│ ▓▓▓▓▓▓▓▓▓░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   │
│                                             │
│ 📈 Bom começo! Vamos em frente! 🚀          │
└─────────────────────────────────────────────┘
```

### **4. Meta Atingida:**
```
┌─────────────────────────────────────────────┐
│ 🎯 Meta da Semana                     100%  │
│ 🏋️ Projeto Bruna Braga                      │
│                                             │
│ 7 / 7 dias                   1 dia restante │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   │
│                                             │
│ 🎉 Parabéns! Meta conquistada! ✨     ✅    │
└─────────────────────────────────────────────┘
```

---

## 🚀 **Como Implementar Cada Combinação**

### **Dashboard Motivacional Completo:**
```dart
class MotivationalDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header com saudação
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Olá! Como está seu progresso? 👋'),
                WeeklyGoalTrendWidget(),  // Tendência
              ],
            ),
          ),
          
          // Widget principal de meta
          WeeklyGoalProgressSummaryWidget(),
          
          // Estatísticas rápidas
          WeeklyGoalStatsWidget(),
          
          // Gráfico de evolução
          WeeklyGoalEvolutionChartWidget(),
          
          // ... resto do seu dashboard
        ],
      ),
    );
  }
}
```

### **Dashboard Minimalista:**
```dart
class MinimalDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Apenas o essencial
        WeeklyGoalProgressSummaryWidget(),
        
        // Seus widgets existentes
        YourExistingContent(),
        
        // Mini widget no final
        WeeklyGoalProgressMiniWidget(),
      ],
    );
  }
}
```

### **Header com Estatísticas:**
```dart
class StatsHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Dashboard'),
              WeeklyGoalTrendWidget(),
            ],
          ),
          SizedBox(height: 8),
          WeeklyGoalStatsWidget(),
        ],
      ),
    );
  }
}
```

---

## 🎨 **Personalização Visual**

### **Cores Automáticas:**
- **🩷 Projeto Bruna Braga:** Pink (#E91E63)
- **❤️ Cardio:** Vermelho (#F44336)
- **💙 Musculação:** Azul (#2196F3)
- **⚪ Personalizada:** Cinza (#9E9E9E)

### **Progressão de Cores:**
- **0-25%:** Cor do tipo da meta
- **25-50%:** Laranja
- **50-80%:** Verde claro
- **80-100%:** Verde

### **Estados de Conclusão:**
- **< 100%:** Ícone de tendência
- **= 100%:** Badge "Concluída" verde
- **> 100%:** Ícone de celebração

---

## ✅ **Checklist de Implementação**

### **Arquivos Necessários:**
- ✅ `weekly_goal_progress_summary_widget.dart`
- ✅ `weekly_goal_evolution_chart_widget.dart`
- ✅ `dashboard_with_goals_widget.dart`

### **Providers Necessários:**
- ✅ `weeklyGoalExpandedViewModelProvider`
- ✅ `currentWeeklyGoalProvider`
- ✅ `weeklyGoalStatsProvider`

### **Integração:**
- ✅ Sistema de banco expandido
- ✅ Modelos Flutter atualizados
- ✅ ViewModels com Riverpod
- ✅ Widgets responsivos

**🚀 Tudo pronto para uma experiência motivacional completa!** ✨ 