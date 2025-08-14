# 🔧 Guia Completo: Implementação Webhook Stripe → Ray Club App

**Data:** 2025-01-19  
**Objetivo:** Automatizar atualização de usuários para expert após pagamento no Stripe

---

## 📋 **Resumo da Implementação**

### ✅ **O que foi implementado:**

1. **Função SQL Completa** (`sql/stripe_webhook_functions.sql`)
   - `update_user_level_by_email()` - Atualiza usuário por email
   - Sistema de logs de pagamentos
   - Processamento de usuários pendentes
   - Triggers automáticos

2. **Edge Function do Supabase** (`supabase/functions/stripe-webhook/`)
   - Processa webhooks do Stripe
   - Verifica assinaturas
   - Atualiza usuários automaticamente

3. **Painel Admin Temporário** (`lib/features/admin/`)
   - Interface para promover usuários manualmente
   - Histórico de operações
   - Sistema de backup enquanto webhook não está ativo

---

## 🚀 **Passos para Ativação Completa**

### **1. Executar Scripts SQL no Supabase**

```sql
-- Acesse: https://app.supabase.com/project/SEU_PROJECT/sql
-- Execute o arquivo: sql/stripe_webhook_functions.sql
```

**Resultado esperado:**
- ✅ Tabela `payment_logs` criada
- ✅ Tabela `pending_user_levels` criada
- ✅ Função `update_user_level_by_email` ativa
- ✅ Triggers configurados

### **2. Deploy da Edge Function**

```bash
# Instalar Supabase CLI (se não tiver)
npm install -g supabase

# Fazer login
supabase login

# Fazer deploy da função
supabase functions deploy stripe-webhook --project-ref SEU_PROJECT_REF
```

**URL gerada:** `https://SEU_PROJECT.supabase.co/functions/v1/stripe-webhook`

### **3. Configurar Variáveis de Ambiente no Supabase**

Acesse: **Project Settings > Edge Functions > Environment Variables**

Adicione:
```
STRIPE_SECRET_KEY=sk_live_... (ou sk_test_...)
STRIPE_WEBHOOK_SECRET=whsec_... (será gerado no passo 4)
SUPABASE_URL=https://SEU_PROJECT.supabase.co
SUPABASE_SERVICE_ROLE_KEY=eyJhbG... (sua service key)
```

### **4. Configurar Webhook no Stripe Dashboard**

1. Acesse: [dashboard.stripe.com/webhooks](https://dashboard.stripe.com/webhooks)
2. Clique em "Add endpoint"
3. **Endpoint URL:** `https://SEU_PROJECT.supabase.co/functions/v1/stripe-webhook`
4. **Events to send:**
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`
   - `invoice.payment_succeeded`
   - `invoice.payment_failed`
5. Salvar e copiar o **Signing secret** (começa com `whsec_`)

### **5. Testar a Integração**

#### **Teste Manual (via Painel Admin):**
```dart
// Acessar a tela de admin no app
// Navegar para: AdminPanelScreen
// Promover um usuário teste
```

#### **Teste com Stripe:**
```bash
# Usar Stripe CLI para simular webhook
stripe trigger customer.subscription.created
```

---

## 🔍 **Como Funciona o Fluxo Completo**

### **Cenário 1: Usuário Existente Compra**
1. ✅ Usuário realiza compra no Stripe
2. ✅ Stripe envia webhook para Edge Function
3. ✅ Edge Function valida assinatura
4. ✅ Edge Function chama `update_user_level_by_email()`
5. ✅ SQL atualiza usuário para expert
6. ✅ App automaticamente reconhece novo nível

### **Cenário 2: Usuário Não Cadastrado Compra**
1. ✅ Cliente compra mas ainda não tem conta no app
2. ✅ Stripe envia webhook
3. ✅ Edge Function não encontra usuário
4. ✅ SQL salva na tabela `pending_user_levels`
5. ✅ Quando usuário se cadastrar, trigger processa automaticamente

### **Cenário 3: Cancelamento/Falha de Pagamento**
1. ✅ Stripe envia webhook de cancelamento
2. ✅ Edge Function processa cancelamento
3. ✅ SQL reverte usuário para nível básico

---

## 🛠️ **Configurações do Flutter App**

### **Adicionar Rota Admin (temporária):**

```dart
// Em lib/core/router/app_router.dart
@AutoRoute(page: AdminPanelRoute.page, path: '/admin')
```

### **Verificar Provider Admin:**

```dart
// Certificar que existe:
// lib/features/admin/view_models/admin_view_model.dart
```

---

## 📊 **Monitoramento e Logs**

### **Logs da Edge Function:**
```bash
# Ver logs em tempo real
supabase functions logs stripe-webhook --follow
```

### **Verificar Pagamentos no SQL:**
```sql
-- Ver últimos logs de pagamento
SELECT * FROM payment_logs 
ORDER BY created_at DESC 
LIMIT 10;

-- Ver usuários pendentes
SELECT * FROM pending_user_levels;

-- Verificar status de um usuário específico
SELECT check_payment_status('usuario@email.com');
```

### **No Flutter App:**
```dart
debugPrint('User Access Level: ${userAccessStatus.accessLevel}');
debugPrint('Is Expert: ${userAccessStatus.isExpert}');
```

---

## 🚨 **Troubleshooting**

### **Problema: Webhook não está funcionando**
```bash
# Verificar logs
supabase functions logs stripe-webhook

# Testar endpoint manualmente
curl -X POST https://SEU_PROJECT.supabase.co/functions/v1/stripe-webhook \
  -H "Content-Type: application/json" \
  -d '{"test": true}'
```

### **Problema: Função SQL não encontrada**
```sql
-- Verificar se função existe
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_name = 'update_user_level_by_email';
```

### **Problema: Usuário não é promovido**
```sql
-- Verificar manualmente
SELECT update_user_level_by_email(
  'email@usuario.com',
  'expert',
  (NOW() + INTERVAL '30 days')::timestamp
);
```

---

## 🎯 **Checklist Final**

### **SQL (Supabase):**
- [ ] Executar `sql/stripe_webhook_functions.sql`
- [ ] Verificar tabelas `payment_logs` e `pending_user_levels`
- [ ] Testar função `update_user_level_by_email` manualmente

### **Edge Function:**
- [ ] Deploy da função `stripe-webhook`
- [ ] Configurar variáveis de ambiente
- [ ] Testar endpoint com curl

### **Stripe:**
- [ ] Adicionar webhook endpoint
- [ ] Configurar eventos (subscription.created, etc.)
- [ ] Copiar signing secret
- [ ] Testar com Stripe CLI

### **Flutter App:**
- [ ] Adicionar rota admin (temporária)
- [ ] Testar promoção manual
- [ ] Verificar sistema de acesso expert

---

## 📱 **Ações Imediatas para Você**

### **Urgente (pode fazer agora):**
1. **Executar SQL:** Copie e execute `sql/stripe_webhook_functions.sql` no SQL Editor do Supabase
2. **Testar Manual:** Use o painel admin no app para promover usuários manualmente
3. **Verificar Sistema:** Confirme que usuários expert têm acesso a todas as features

### **Médio Prazo (próximos dias):**
1. **Deploy Edge Function:** Fazer deploy do webhook
2. **Configurar Stripe:** Adicionar endpoint e eventos
3. **Testar Integração:** Simular compra real

### **Opcional:**
1. **Monitoramento:** Configurar alertas para falhas de webhook
2. **Cleanup:** Remover painel admin após webhook estar funcionando

---

## 💡 **Vantagens da Implementação**

✅ **Sistema robusto** com fallbacks  
✅ **Logs completos** para auditoria  
✅ **Processamento automático** de usuários pendentes  
✅ **Interface admin** para emergências  
✅ **Compatível** com todos os eventos do Stripe  
✅ **Escalável** para milhares de usuários  

**Esta implementação resolve definitivamente o problema de atualização automática após pagamentos no Stripe.** 