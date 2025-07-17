# Dashboard Enhanced - Fluxo Completo

## 🏗️ Arquitetura de Dois Módulos

### 1. **Dashboard Core** (Existente)
- Usa `get_dashboard_core`
- Apenas dados de treinos e desafios
- Já está funcional e não será alterado

### 2. **Dashboard Enhanced** (Novo)
- Usa `get_dashboard_data`
- Dados completos: água, metas, benefícios, etc.
- Completamente separado do core

## 📊 Fluxo de Dados Completo

### 1. **Captação de Dados do Usuário**

#### A. **Água** (`WaterIntakeScreen`)
```
Usuário → Tela de Água → Botões +/- → ViewModel → Supabase
```
- Usuário clica em adicionar/remover copo
- ViewModel atualiza estado local (resposta rápida)
- Salva no Supabase (tabela `water_intake`)
- Se atingir meta: registra conquista e dá pontos

#### B. **Metas** (Futuro: `GoalsScreen`)
```
Usuário → Criar Meta → Definir valores → Salvar → user_goals
```
- Usuário cria metas personalizadas
- Define valor atual e meta
- Acompanha progresso
- Marca como completa quando atingir

#### C. **Benefícios** (Já existe no app)
- Usuário resgata benefício
- Registro salvo em `redeemed_benefits`
- Aparece automaticamente no dashboard

### 2. **Armazenamento no Supabase**

#### Tabelas Utilizadas:
- `water_intake`: Consumo diário de água
- `user_goals`: Metas do usuário
- `user_progress`: Progresso geral
- `workout_records`: Treinos
- `challenges`: Desafios
- `challenge_progress`: Progresso em desafios
- `redeemed_benefits`: Benefícios resgatados

### 3. **Função get_dashboard_data**

```sql
-- A função agrega dados de várias tabelas:
1. user_progress (treinos, pontos, streak)
2. water_intake (consumo do dia)
3. user_goals (metas ativas)
4. workout_records (últimos 10 treinos)
5. challenges + challenge_progress (desafio ativo)
6. redeemed_benefits (últimos 5 benefícios)
```

### 4. **Fluxo no Flutter**

```dart
// 1. Tela chama ViewModel
DashboardEnhancedScreen → dashboardEnhancedViewModelProvider

// 2. ViewModel chama Repository
DashboardEnhancedViewModel → DashboardRepositoryEnhanced

// 3. Repository chama Supabase RPC
repository.getDashboardData() → supabase.rpc('get_dashboard_data')

// 4. Dados retornam e são convertidos
JSON → DashboardDataEnhanced (modelo)

// 5. UI é atualizada
AsyncValue.data(dashboardData) → Widgets renderizam
```

## 🎯 Benefícios da Separação

1. **Não quebra nada existente**: Dashboard core continua funcionando
2. **Desenvolvimento incremental**: Podemos adicionar features uma por vez
3. **Testes isolados**: Cada módulo pode ser testado separadamente
4. **Performance**: Usuário escolhe qual dashboard usar

## 🚀 Como Implementar

### 1. **Adicionar rotas**
```dart
// No app_router.dart
@MaterialAutoRoute(page: DashboardEnhancedScreen),
@MaterialAutoRoute(page: WaterIntakeScreen),
```

### 2. **Adicionar entrada no menu**
```dart
// Adicionar botão para "Wellness Dashboard"
// Pode ser no drawer ou na home
```

### 3. **Criar telas de captação**
- ✅ WaterIntakeScreen (criada)
- 🔜 GoalsScreen
- 🔜 NutritionScreen

### 4. **Widgets do Dashboard**
Criar os widgets que faltam:
```dart
water_intake_widget.dart      // Widget compacto de água
goals_widget.dart            // Lista de metas
redeemed_benefits_widget.dart // Benefícios resgatados
```

## 📱 Experiência do Usuário

1. **Entrada de Dados Simples**
   - Telas dedicadas para cada tipo de dado
   - Interface intuitiva com feedback visual
   - Salvamento automático

2. **Dashboard Unificado**
   - Visão geral de todos os dados
   - Widgets interativos
   - Pull to refresh

3. **Gamificação**
   - Pontos por atingir metas
   - Badges e conquistas
   - Ranking e competição

## 🔒 Segurança

- Todos os dados são filtrados por `user_id`
- RLS (Row Level Security) no Supabase
- Validação de dados no cliente e servidor

## 🎨 Design Consistente

- Mesma paleta de cores do app
- Componentes reutilizáveis
- Animações suaves
- Feedback visual para ações 