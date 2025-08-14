# 🔔 Sistema de Notificações Automáticas - Ray Club

## 📋 Visão Geral

O Ray Club implementa um sistema completo de notificações automáticas que combina:
- **Notificações in-app** via Supabase Realtime (quando o app está aberto)
- **Notificações push** via Firebase Cloud Messaging (mesmo com app fechado)
- **Agendamento automático** baseado em horários e comportamentos do usuário

## 🏗️ Arquitetura do Sistema

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   Supabase       │    │   Firebase FCM  │
│                 │    │                  │    │                 │
│ • FCM Token     │───▶│ • Edge Function  │───▶│ • Push Delivery │
│ • Realtime      │    │ • Scheduler      │    │ • Device Target │
│ • Local Notif   │    │ • Templates DB   │    │ • Payload       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🗄️ Estrutura do Banco de Dados

### Tabela: `notification_templates`

Armazena os templates de notificações categorizados por tipo de trigger:

```sql
CREATE TABLE notification_templates (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  category TEXT NOT NULL,         -- 'receita', 'desafio', 'pdf', 'treino'
  trigger_type TEXT NOT NULL,     -- 'manha', 'sem_treino', 'ultrapassado'
  title TEXT,                     -- Título opcional
  body TEXT NOT NULL,             -- Mensagem da notificação
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
```

### Campo: `profiles.fcm_token`

Campo adicionado à tabela `profiles` para armazenar o token FCM de cada usuário:

```sql
ALTER TABLE profiles ADD COLUMN fcm_token TEXT;
```

## 📱 Tipos de Notificações

### 🌅 Notificações por Horário

| Horário | Trigger Type | Exemplos |
|---------|--------------|----------|
| 6h-12h  | `manha`      | Receitas de café da manhã, motivação |
| 12h-17h | `tarde`      | Lembretes de treino, lanches saudáveis |
| 17h-22h | `noite`      | Reflexões, receitas de jantar |

### 🎯 Notificações Comportamentais

| Comportamento | Trigger Type | Descrição |
|---------------|--------------|-----------|
| Sem treino hoje | `sem_treino` | Lembrete para registrar atividade |
| Ultrapassado no ranking | `ultrapassado` | Motivação para recuperar posição |
| Meta atingida | `meta_atingida` | Parabenização por conquista |
| Pouca água | `pouca_agua` | Lembrete de hidratação |

### 📚 Notificações de Conteúdo

| Conteúdo | Trigger Type | Descrição |
|----------|--------------|-----------|
| Novo PDF | `hipertrofia`, `emagrecimento` | Guias especializados |
| Novo vídeo | `novo_treino` | Vídeos de exercícios |
| Nova receita | `nova_receita` | Receitas nutritivas |
| Novo cupom | `novo_cupom` | Benefícios exclusivos |

## ⚙️ Edge Function: `send_push_notifications`

### Localização
```
supabase/functions/send_push_notifications/index.ts
```

### Funcionalidades
1. **Detecção de horário**: Determina o `trigger_type` baseado na hora atual
2. **Busca de templates**: Seleciona mensagens apropriadas do banco
3. **Busca de usuários**: Encontra perfis com `fcm_token` válido
4. **Envio FCM**: Dispara notificações via Firebase
5. **Registro**: Salva histórico na tabela `notifications`

### Variáveis de Ambiente Necessárias

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `SUPABASE_URL` | URL do projeto Supabase | `https://xxx.supabase.co` |
| `SUPABASE_SERVICE_ROLE_KEY` | Chave de serviço | `eyJ...` |
| `FCM_SERVER_KEY` | Chave do servidor Firebase | `AAAA...` |

## ⏰ Agendamento Automático

### Schedulers Configurados

```bash
# Notificações da manhã (8h)
supabase functions schedule create notificacoes_manha \
  --function send_push_notifications \
  --cron "0 8 * * *"

# Notificações da tarde (15h)  
supabase functions schedule create notificacoes_tarde \
  --function send_push_notifications \
  --cron "0 15 * * *"

# Notificações da noite (20h)
supabase functions schedule create notificacoes_noite \
  --function send_push_notifications \
  --cron "0 20 * * *"
```

### Formato Cron

| Campo | Valores | Descrição |
|-------|---------|-----------|
| Minuto | 0-59 | Minuto da hora |
| Hora | 0-23 | Hora do dia |
| Dia | 1-31 | Dia do mês |
| Mês | 1-12 | Mês do ano |
| Dia da semana | 0-7 | Domingo = 0 ou 7 |

## 🚀 Configuração e Deploy

### 1. Preparar o Banco de Dados

Execute o script SQL para criar as tabelas e inserir os templates:

```bash
# No Supabase SQL Editor, execute:
sql/setup_notifications_system.sql
```

### 2. Configurar Variáveis de Ambiente

No painel do Supabase, vá em **Settings > Edge Functions** e adicione:

```
SUPABASE_URL=https://zsbbgchsjiuicwvtrldn.supabase.co
SUPABASE_SERVICE_ROLE_KEY=sua_service_role_key
FCM_SERVER_KEY=sua_fcm_server_key
```

### 3. Deploy da Função

```bash
# Deploy da função
supabase functions deploy send_push_notifications --project-ref zsbbgchsjiuicwvtrldn

# Configurar schedulers
./scripts/setup_notification_schedulers.sh
```

### 4. Conectar ao GitHub

1. Acesse o **Supabase Studio**
2. Vá em **Settings > Integrations**
3. Clique em **Connect to GitHub**
4. Selecione o repositório `rayclubfunctions`
5. Ative o **Scheduler** no menu lateral

## 📱 Integração no Flutter

### 1. Configurar FCM Token

```dart
// Obter e salvar FCM token
final fcmToken = await FirebaseMessaging.instance.getToken();
await supabase.from('profiles').update({
  'fcm_token': fcmToken
}).eq('id', user.id);
```

### 2. Escutar Notificações Realtime

```dart
// Escutar notificações em tempo real
supabase
  .from('notifications')
  .stream(primaryKey: ['id'])
  .eq('user_id', user.id)
  .listen((data) {
    // Processar notificação recebida
  });
```

### 3. Configurar Handlers FCM

```dart
// Handler para notificações em foreground
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Mostrar notificação local
});

// Handler para notificações em background
FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
```

## 🧪 Testes e Monitoramento

### Testar Função Manualmente

```bash
# Invocar função diretamente
supabase functions invoke send_push_notifications \
  --project-ref zsbbgchsjiuicwvtrldn
```

### Verificar Schedulers Ativos

```bash
# Listar schedulers configurados
supabase functions schedule list --project-ref zsbbgchsjiuicwvtrldn
```

### Monitorar Logs

```bash
# Ver logs da função
supabase functions logs send_push_notifications \
  --project-ref zsbbgchsjiuicwvtrldn
```

## 🔧 Manutenção

### Adicionar Novos Templates

```sql
INSERT INTO notification_templates (category, trigger_type, title, body)
VALUES ('nova_categoria', 'novo_trigger', 'Título', 'Mensagem');
```

### Atualizar Horários dos Schedulers

```bash
# Remover scheduler existente
supabase functions schedule delete notificacoes_manha \
  --project-ref zsbbgchsjiuicwvtrldn

# Criar novo com horário diferente
supabase functions schedule create notificacoes_manha \
  --function send_push_notifications \
  --cron "0 9 * * *" \
  --project-ref zsbbgchsjiuicwvtrldn
```

### Pausar Notificações

```sql
-- Pausar temporariamente removendo FCM tokens
UPDATE profiles SET fcm_token = NULL WHERE id = 'user_id';

-- Ou criar flag de controle
ALTER TABLE profiles ADD COLUMN notifications_enabled BOOLEAN DEFAULT true;
```

## 📊 Métricas e Analytics

### Queries Úteis

```sql
-- Usuários com FCM token ativo
SELECT COUNT(*) FROM profiles WHERE fcm_token IS NOT NULL;

-- Templates por categoria
SELECT category, COUNT(*) FROM notification_templates GROUP BY category;

-- Notificações enviadas hoje
SELECT COUNT(*) FROM notifications WHERE DATE(created_at) = CURRENT_DATE;

-- Usuários mais ativos (mais notificações recebidas)
SELECT user_id, COUNT(*) as total_notifications 
FROM notifications 
GROUP BY user_id 
ORDER BY total_notifications DESC 
LIMIT 10;
```

## 🚨 Troubleshooting

### Problemas Comuns

1. **Função não executa**: Verificar se as variáveis de ambiente estão configuradas
2. **FCM falha**: Validar se a `FCM_SERVER_KEY` está correta
3. **Scheduler não ativa**: Confirmar se o projeto está conectado ao GitHub
4. **Templates não encontrados**: Verificar se os dados foram inseridos corretamente

### Logs de Debug

A função registra logs detalhados que podem ser acessados via:

```bash
supabase functions logs send_push_notifications --project-ref zsbbgchsjiuicwvtrldn
```

## 🔮 Próximos Passos

1. **Personalização avançada**: Templates baseados no perfil do usuário
2. **A/B Testing**: Testar diferentes mensagens para otimizar engajamento
3. **Segmentação**: Notificações específicas por grupos de usuários
4. **Analytics**: Dashboard de métricas de notificações
5. **Machine Learning**: Horários otimizados por usuário baseado em atividade

---

**Desenvolvido para Ray Club** 🏋️‍♀️  
*Sistema de notificações inteligentes para maximizar o engajamento dos usuários*
