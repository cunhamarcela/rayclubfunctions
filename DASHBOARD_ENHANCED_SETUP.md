# Dashboard Enhanced - Guia de Configuração

## 📋 Resumo das Mudanças

O Dashboard Enhanced foi criado para suportar funcionalidades avançadas como:
- ✅ Rastreamento de nutrição (calorias, proteínas, carboidratos, gorduras)
- ✅ Sistema de metas personalizadas
- ✅ Consumo de água atualizado
- ✅ Benefícios resgatados
- ✅ Progresso em desafios

## 🗄️ Configuração do Banco de Dados

### 1. Execute o Script SQL

Execute o arquivo `update_dashboard_function_complete.sql` no Supabase SQL Editor:

```bash
# O script irá:
1. Criar a tabela nutrition_tracking
2. Ajustar tabelas user_goals e water_intake
3. Atualizar a função get_dashboard_data
4. Criar funções auxiliares
5. Configurar permissões RLS
```

### 2. Verificar Tabelas Criadas

As seguintes tabelas devem existir:
- `nutrition_tracking` - Nova tabela para dados de nutrição
- `user_goals` - Atualizada com campos current_value, target_value, is_completed
- `water_intake` - Atualizada com campos cups e goal

## 🚀 Como Usar no App

### 1. Acessar Dashboard Enhanced

1. Abra o app
2. Toque no menu hambúrguer (☰)
3. Selecione **"Dashboard Enhanced"**

### 2. Funcionalidades Disponíveis

**📊 Resumo do Dia**
- Treinos realizados
- Sequência atual
- Pontos totais

**💧 Controle de Água**
- Meta diária (padrão: 8 copos)
- Botões + e - para incrementar/decrementar
- Progress visual

**🍎 Nutrição**
- Calorias consumidas vs meta
- Macronutrientes (proteínas, carboidratos, gorduras)
- Modal de registro rápido

**🎯 Metas**
- Lista de metas ativas
- Progress de cada meta
- Marcar como completa

**🏆 Desafio Atual**
- Informações do desafio ativo
- Progresso e posição
- Dias restantes

**🎁 Benefícios Resgatados**
- Últimos 5 benefícios ativos
- Códigos de resgate
- Datas de expiração

## 📱 Estrutura Técnica

### Arquivos Principais

```
lib/features/dashboard/
├── screens/
│   ├── dashboard_screen.dart          # Dashboard original
│   └── dashboard_enhanced_screen.dart # Dashboard enhanced ✨
├── viewmodels/
│   ├── dashboard_view_model.dart
│   └── dashboard_enhanced_view_model.dart ✨
├── repositories/
│   ├── dashboard_repository.dart
│   └── dashboard_repository_enhanced.dart ✨
├── models/
│   └── dashboard_data_enhanced.dart ✨
└── widgets/
    ├── water_intake_widget.dart
    ├── goals_widget.dart
    ├── nutrition_tracking_widget.dart ✨
    └── redeemed_benefits_widget.dart
```

### Fluxo de Dados

```
DashboardEnhancedScreen
    ↓
DashboardEnhancedViewModel
    ↓
DashboardRepositoryEnhanced
    ↓
Supabase RPC: get_dashboard_data()
    ↓
JSON com todos os dados agregados
```

## 🔧 Funções SQL Criadas

### get_dashboard_data(user_id_param UUID)
Função principal que retorna todos os dados do dashboard:
- user_progress
- water_intake
- goals
- recent_workouts
- current_challenge
- challenge_progress
- redeemed_benefits
- **nutrition_data** ✨

### update_nutrition_tracking(...)
Função para atualizar dados de nutrição:
- Insere ou atualiza registro do dia
- Suporte a UPSERT (ON CONFLICT)
- Retorna dados atualizados em JSON

## 🎨 Diferenças Visuais

### Dashboard Original
- Foco em treinos e desafios
- Layout simples
- Dados básicos

### Dashboard Enhanced ✨
- **Layout moderno** com gradientes
- **Widgets interativos** (água, nutrição)
- **Dados completos** de wellness
- **Animações** e transições
- **Ações rápidas** via modais

## ⚡ Performance

- **Função SQL única** para todos os dados
- **Cache automático** via Riverpod
- **Refresh manual** disponível
- **Fallbacks** para dados ausentes

## 🔒 Segurança

- **RLS habilitado** em todas as tabelas
- **Políticas específicas** por usuário
- **Validação de UUID** nos parâmetros
- **SECURITY DEFINER** nas funções

## 🐛 Troubleshooting

### Erro: "get_dashboard_data not found"
```sql
-- Verificar se a função existe
SELECT * FROM information_schema.routines 
WHERE routine_name = 'get_dashboard_data';

-- Re-executar o script se necessário
```

### Dashboard não carrega dados
1. Verificar autenticação do usuário
2. Verificar logs do Supabase
3. Testar função SQL diretamente
4. Verificar políticas RLS

### Erro de permissão
```sql
-- Verificar se o usuário tem permissão
GRANT EXECUTE ON FUNCTION get_dashboard_data(UUID) TO authenticated;
```

## 📈 Próximos Passos

1. **Integração com Apple Health** (iOS)
2. **Notificações push** para metas
3. **Relatórios semanais** automáticos
4. **Sharing social** de conquistas
5. **IA para sugestões** personalizadas

---

## 📞 Suporte

Se encontrar problemas:
1. Verificar logs do Flutter/Supabase
2. Testar função SQL no Editor
3. Verificar permissões RLS
4. Contactar a equipe de desenvolvimento 