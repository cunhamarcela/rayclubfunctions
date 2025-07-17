# 🔧 Instruções para Correção do Sistema Basic/Expert

## ⚠️ Problema Identificado

O sistema atual está usando `'basic'` e `'premium'`, mas precisa usar `'basic'` e `'expert'` para ser compatível com o Stripe e a função SQL que você mostrou.

## ✅ Passos para Correção

### 1. **Execute o Script SQL de Correção no Supabase**

Execute o arquivo `fix_user_access_system_expert.sql` no SQL Editor do Supabase:

```bash
# Este script irá:
# - Fazer backup dos dados atuais
# - Migrar usuários 'premium' para 'expert'
# - Atualizar as features para o padrão correto
# - Recriar as funções com a nomenclatura correta
# - Criar a tabela pending_user_levels
# - Configurar o trigger para aplicar níveis pendentes
```

### 2. **Verifique se as Mudanças Foram Aplicadas**

Execute estas queries para verificar:

```sql
-- Verificar níveis atuais
SELECT current_level, COUNT(*) 
FROM user_progress_level 
GROUP BY current_level;

-- Verificar features por nível
SELECT DISTINCT current_level, unlocked_features 
FROM user_progress_level;

-- Testar a função
SELECT check_user_access_level('seu-user-id-aqui');
```

### 3. **Atualize o Código Flutter**

O modelo `UserAccessStatus` já foi atualizado. Agora verifique se os bloqueios estão usando as features corretas:

#### Features para Basic:
- `basic_workouts` - Treinos básicos
- `profile` - Perfil
- `basic_challenges` - Desafios
- `workout_recording` - Registro de treinos

#### Features para Expert:
Todas as features basic + :
- `enhanced_dashboard` - Dashboard normal (bloqueado)
- `nutrition_guide` - Nutrição
- `workout_library` - Vídeos dos parceiros
- `advanced_tracking` - Tracking avançado
- `detailed_reports` - Benefícios

### 4. **Mapeamento de Bloqueios no App**

Verifique se os bloqueios estão corretos:

| Tela/Feature | Feature Key | Status |
|--------------|-------------|---------|
| Dashboard Normal | `enhanced_dashboard` | ✅ Bloqueado |
| Dashboard Enhanced | Nenhum | ✅ Liberado |
| Nutrição | `nutrition_guide` | ✅ Bloqueado |
| Vídeos Parceiros | `workout_library` | ✅ Bloqueado |
| Benefícios | `detailed_reports` | ✅ Bloqueado |
| Desafios | `basic_challenges` | ✅ Liberado |
| Perfil | `profile` | ✅ Liberado |
| Registro Treinos | `workout_recording` | ✅ Liberado |

### 5. **Teste com Usuários Reais**

#### Criar usuário de teste Basic:
```sql
UPDATE user_progress_level 
SET current_level = 'basic',
    unlocked_features = ARRAY['basic_workouts', 'profile', 'basic_challenges', 'workout_recording'],
    level_expires_at = NULL
WHERE user_id = 'id-do-usuario-teste';
```

#### Criar usuário de teste Expert:
```sql
UPDATE user_progress_level 
SET current_level = 'expert',
    unlocked_features = ARRAY[
      'basic_workouts', 'profile', 'basic_challenges', 'workout_recording',
      'enhanced_dashboard', 'nutrition_guide', 'workout_library', 
      'advanced_tracking', 'detailed_reports'
    ],
    level_expires_at = NOW() + INTERVAL '30 days'
WHERE user_id = 'id-do-usuario-teste';
```

### 6. **Webhook do Stripe**

Certifique-se de que o webhook está chamando a função correta:

```javascript
// No webhook do Stripe
const { data, error } = await supabase.rpc('update_user_level_by_email', {
  email_param: customerEmail,
  new_level: 'expert', // Não 'premium'!
  expires_at: new Date(subscription.current_period_end * 1000).toISOString(),
  stripe_customer_id: customerId,
  stripe_subscription_id: subscriptionId
});
```

### 7. **Monitoramento**

Adicione logs para debug:

```dart
// No Flutter
debugPrint('User Access Level: ${userAccessStatus.accessLevel}');
debugPrint('Is Expert: ${userAccessStatus.isExpert}');
debugPrint('Features: ${userAccessStatus.availableFeatures}');
```

## 🎯 Checklist Final

- [ ] Script SQL executado no Supabase
- [ ] Usuários 'premium' migrados para 'expert'
- [ ] Features atualizadas corretamente
- [ ] Tabela `pending_user_levels` criada
- [ ] Trigger configurado
- [ ] Código Flutter atualizado
- [ ] Webhook do Stripe usando 'expert'
- [ ] Testes com usuários basic e expert

## 🚨 Importante

Após executar o script SQL, **todos os usuários que eram 'premium' serão automaticamente migrados para 'expert'** com as features corretas.

Se houver algum erro, você pode reverter usando o backup:

```sql
-- Reverter para o backup se necessário
DROP TABLE user_progress_level;
ALTER TABLE user_progress_level_backup RENAME TO user_progress_level;
``` 