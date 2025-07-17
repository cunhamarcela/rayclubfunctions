# 🔒 Sistema de Controle de Acesso aos Vídeos

## 📋 Resumo

Este sistema permite controlar o acesso aos vídeos de treino usando duas abordagens:
1. **Restrição por Nível Expert** - Vídeos específicos apenas para usuários expert
2. **Bloqueio Temporário Geral** - Bloquear todos os vídeos temporariamente

## 🚀 Como Usar

### 🎯 **MÉTODO 1: Restrição por Nível Expert (RECOMENDADO)**

#### **Restringir Vídeos Específicos para Expert:**
```sql
-- Execute o arquivo no SQL Editor do Supabase
\i restrict_videos_to_expert.sql
```

#### **Remover Restrições Expert:**
```sql
-- Voltar vídeos para acesso básico
\i remove_expert_restriction.sql
```

#### **Verificar Status dos Vídeos:**
```sql
-- Ver quais vídeos estão ativos/bloqueados
\i check_video_status.sql
```

---

### 🛑 **MÉTODO 2: Bloqueio Temporário Geral**

#### **Bloquear Todos os Vídeos:**
```sql
\i block_videos_simple.sql
```

#### **Desbloquear Todos os Vídeos:**
```sql
\i unblock_videos_simple.sql
```

## 📊 O Que Acontece

### 🎯 **MÉTODO 1: Restrição Expert**
- ✅ **Usuários Expert**: Veem TODOS os vídeos (básicos + expert)
- ⚠️ **Usuários Basic**: Veem apenas vídeos básicos (sem restrição expert)
- 🔒 **Vídeos Restritos**: Aparecem com ícone de bloqueio para usuários basic
- 💡 **Ideal para**: Controle granular de conteúdo premium

### 🛑 **MÉTODO 2: Bloqueio Geral**
- ❌ **TODOS os usuários** (basic e expert) perdem acesso aos vídeos
- 🔒 **Todos os vídeos**: Ficam sem URL, tornando-se inacessíveis
- ✅ **Outras funções** do app continuam normais
- 💡 **Ideal para**: Manutenção temporária ou emergências

## 🔄 Comandos Rápidos

| Ação | Comando |
|------|---------|
| **🎯 Restringir para Expert** | `\i restrict_videos_to_expert.sql` |
| **🎯 Remover Restrição Expert** | `\i remove_expert_restriction.sql` |
| **📊 Ver Status dos Vídeos** | `\i check_video_status.sql` |
| **🛑 Bloquear Todos** | `\i block_videos_simple.sql` |
| **✅ Desbloquear Todos** | `\i unblock_videos_simple.sql` |

## 🛡️ Segurança

- ✅ **Não modifica dados existentes**
- ✅ **Não afeta usuários ou permissões**
- ✅ **Facilmente reversível**
- ✅ **Mantém log de ativações**
- ✅ **Sem risco de perda de dados**

## 🔧 Troubleshooting

### Problema: Proteção não está funcionando
```sql
-- Verificar se a função foi criada
SELECT proname FROM pg_proc WHERE proname = 'can_user_access_video_link';

-- Recriar se necessário
\i temporary_video_protection.sql
```

### Problema: Não consegue desbloquear
```sql
-- Forçar desbloqueio
UPDATE global_video_protection SET is_enabled = FALSE WHERE id = 1;
```

### Problema: Remover sistema completamente
```sql
-- Limpar tudo
DROP TABLE IF EXISTS global_video_protection CASCADE;
DROP FUNCTION IF EXISTS enable_video_protection(TEXT);
DROP FUNCTION IF EXISTS disable_video_protection();
DROP FUNCTION IF EXISTS check_video_protection_status();
DROP FUNCTION IF EXISTS can_user_access_video_link(UUID, UUID);
```

## 💡 Casos de Uso

- **Manutenção de conteúdo**: Bloquear durante uploads de novos vídeos
- **Atualizações do app**: Proteger durante releases
- **Testes**: Validar comportamento de bloqueio
- **Emergência**: Bloquear rapidamente se necessário

## ⚠️ Importante

- O bloqueio é **instantâneo** e **global**
- Afeta **todos os usuários** igualmente
- Use apenas quando necessário
- Sempre teste em ambiente de desenvolvimento primeiro
- Comunique aos usuários sobre manutenções programadas 