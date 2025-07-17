# 🎯 Sistema de Metas por Categoria e Gráficos de Evolução

**Data:** 15 de Janeiro de 2025  
**Objetivo:** Permitir que usuários definam metas específicas por tipo de treino e visualizem evolução semanal  
**Autor:** IA Assistant

---

## ✅ **O que foi implementado**

### 📊 **Backend (SQL)**
- ✅ **Tabela `workout_category_goals`**: Armazena metas específicas por categoria
- ✅ **Funções SQL** otimizadas:
  - `get_or_create_category_goal()`: Obtém ou cria meta com valores padrão
  - `set_category_goal()`: Define/atualiza meta para categoria
  - `add_workout_minutes_to_category()`: Adiciona minutos automaticamente
  - `get_user_category_goals()`: Lista metas ativas do usuário
  - `get_weekly_evolution_by_category()`: Evolução semanal de uma categoria
- ✅ **Trigger automático**: Atualiza metas quando treinos são registrados
- ✅ **RLS Policies**: Segurança por usuário

### 🎯 **Modelos Flutter**
- ✅ **WorkoutCategoryGoal**: Modelo principal com helpers visuais
- ✅ **WeeklyEvolution**: Dados de evolução semanal
- ✅ **Métodos utilitários**: Formatação, cores, mensagens motivacionais

### 🏗️ **Arquitetura MVVM + Riverpod**
- ✅ **WorkoutCategoryGoalsRepository**: Comunicação com Supabase
- ✅ **Providers**: Estado reativo com Riverpod
- ✅ **Tratamento de erros**: AppException padronizado

### 📈 **Gráficos com fl_chart**
- ✅ **WeeklyEvolutionChart**: Gráfico de linha interativo
- ✅ **Animações**: Transições suaves e tooltip informativos
- ✅ **Cores temáticas**: Baseadas na categoria de treino
- ✅ **Estados vazios**: Placeholders quando não há dados

### 🎨 **Interface (UI)**
- ✅ **SetCategoryGoalModal**: Modal intuitivo para definir metas
- ✅ **EnhancedDashboardWidget**: Widget principal integrado
- ✅ **Cards de progresso**: Barras animadas e badges de conquista
- ✅ **Ações rápidas**: Botões para criar metas e ver gráficos

---

## 🚀 **Como usar**

### **1. Definir uma Meta**
```dart
// O usuário pode:
// 1. Clicar em "Nova Meta" no dashboard
// 2. Escolher categoria (Corrida, Yoga, Funcional, etc.)
// 3. Definir minutos por semana (ex: 120 min)
// 4. Salvar a meta

// Exemplo programático:
final repository = ref.read(workoutCategoryGoalsRepositoryProvider);
await repository.setCategoryGoal('corrida', 120); // 2 horas por semana
```

### **2. Visualizar Progresso**
```dart
// As metas aparecem automaticamente no dashboard com:
// - Barra de progresso visual
// - Minutos atuais vs meta
// - Percentual completado  
// - Mensagem motivacional
// - Badge de "Meta Atingida!" quando completa

// Estado é gerenciado via Riverpod:
final goalsAsync = ref.watch(workoutCategoryGoalsProvider);
```

### **3. Acompanhar Evolução**
```dart
// Gráfico semanal mostra:
// - Linha de progresso (minutos realizados)
// - Linha de meta (pontilhada)
// - Pontos verdes para semanas completas
// - Tooltip com detalhes ao tocar

// Widget do gráfico:
WeeklyEvolutionChart(
  evolutionData: evolutionData,
  category: 'corrida',
  height: 280,
)
```

### **4. Integração Automática**
```dart
// Quando o usuário registra um treino:
// 1. Trigger SQL detecta o novo workout_record
// 2. Chama add_workout_minutes_to_category() automaticamente
// 3. Atualiza current_minutes da meta correspondente
// 4. Marca como completed se atingir a meta
// 5. UI se atualiza automaticamente via Riverpod
```

---

## 📋 **Próximos Passos**

### **📦 Deploy (Pendente)**
1. **Aplicar migração SQL**:
   ```sql
   -- Executar sql/create_workout_category_goals.sql no Supabase
   ```

2. **Integrar no dashboard principal**:
   ```dart
   // Adicionar EnhancedDashboardWidget como nova aba ou seção
   ```

3. **Testar fluxo completo**:
   - ✅ Criar meta por categoria
   - ✅ Registrar treino correspondente
   - ✅ Verificar atualização automática
   - ✅ Visualizar gráfico de evolução

### **🧪 Testes Recomendados**
```dart
// 1. Teste de criação de meta
testCreateCategoryGoal() async {
  final goal = await repository.setCategoryGoal('yoga', 90);
  expect(goal.category, 'yoga');
  expect(goal.goalMinutes, 90);
}

// 2. Teste de atualização automática  
testAutoUpdateOnWorkout() async {
  // Criar meta de 60min de funcional
  await repository.setCategoryGoal('funcional', 60);
  
  // Simular treino de 30min de funcional
  // Verificar se current_minutes = 30
}

// 3. Teste de evolução semanal
testWeeklyEvolution() async {
  final evolution = await repository.getWeeklyEvolution('corrida');
  expect(evolution.length, greaterThan(0));
}
```

---

## 🎨 **Características Visuais**

### **🎯 Cores por Categoria**
```dart
'corrida' → '#FF6B6B' (Vermelho)
'yoga' → '#4ECDC4' (Verde-azulado)  
'funcional' → '#FF8E53' (Laranja)
'natacao' → '#45B7D1' (Azul)
'ciclismo' → '#9B59B6' (Roxo)
```

### **🔤 Formatação Amigável**
```dart
90 minutos → "1h 30min"
120 minutos → "2h"
60 minutos → "1h"
```

### **💬 Mensagens Motivacionais**
```dart
100% → "Parabéns! Meta atingida! 🎉"
80-99% → "Quase lá! Você consegue! 💪"
50-79% → "Metade do caminho feito! 🔥"
25-49% → "Bom começo! Continue assim! ✨"
0-24% → "Todo progresso conta! 🌱"
```

---

## 🔧 **Detalhes Técnicos**

### **🗄️ Estrutura da Tabela**
```sql
workout_category_goals (
  id UUID,
  user_id UUID,
  category TEXT,           -- 'corrida', 'yoga', 'funcional'
  goal_minutes INTEGER,    -- Meta em minutos (ex: 120)
  current_minutes INTEGER, -- Progresso atual (ex: 60)
  week_start_date DATE,    -- Início da semana
  week_end_date DATE,      -- Fim da semana
  is_active BOOLEAN,       -- Permite desativar sem deletar
  completed BOOLEAN,       -- Se atingiu a meta
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

### **⚡ Trigger Automático**
```sql
-- Executado automaticamente após INSERT em workout_records
CREATE TRIGGER update_category_goals_on_workout_trigger
    AFTER INSERT ON workout_records
    FOR EACH ROW
    EXECUTE FUNCTION update_category_goals_on_workout();
```

### **🔒 Segurança (RLS)**
```sql
-- Usuários só veem suas próprias metas
CREATE POLICY "Users can view own category goals" 
ON workout_category_goals FOR SELECT 
USING (auth.uid() = user_id);
```

---

## 🎯 **Exemplos de Uso**

### **Cenário 1: Usuária quer correr 2h por semana**
1. Abre modal "Nova Meta"
2. Seleciona "Corrida 🏃‍♀️" 
3. Define 120 minutos
4. Salva a meta
5. A cada corrida registrada, progresso atualiza automaticamente

### **Cenário 2: Verificar evolução do yoga**
1. Meta definida: 90min de yoga/semana
2. Gráfico mostra últimas 8 semanas
3. Linha verde: minutos realizados
4. Linha pontilhada: meta (90min)
5. Pontos verdes nas semanas que atingiu a meta

### **Cenário 3: Múltiplas metas ativas**
1. Corrida: 120min/semana
2. Yoga: 60min/semana  
3. Funcional: 90min/semana
4. Dashboard mostra todas com progresso individual
5. Gráfico foca na categoria mais ativa

---

**📌 Feature: Sistema completo de metas por categoria de treino**  
**🗓️ Data:** 2025-01-15 às 00:10  
**🧠 Autor/IA:** IA Assistant  
**📄 Contexto:** Implementação completa de backend, frontend, gráficos e interface para metas semanais específicas por tipo de treino 