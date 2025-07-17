# 🔧 Correção Final do Problema de Foto de Perfil

## 📋 Problema Identificado

O erro `column "photo_url" can only be updated to DEFAULT` indica que a coluna `photo_url` na tabela `profiles` é uma **coluna gerada** (generated column) que não pode ser atualizada diretamente.

Análise dos logs:
- ✅ **Upload funcionou**: A imagem foi enviada com sucesso para o Supabase Storage
- ❌ **Atualização falhou**: O banco de dados rejeitou a atualização da coluna `photo_url`

## 🚀 Solução Implementada

### 1. Execute o Script SQL no Supabase

1. **Abra o Supabase Dashboard**: Acesse seu projeto no Supabase
2. **Vá para SQL Editor**: Menu lateral → SQL Editor
3. **Crie uma nova query**: Clique em "New query"
4. **Cole o conteúdo** do arquivo `fix_photo_url_generated_column.sql`
5. **Execute a query**: Clique em "Run"

### 2. O que o Script Faz

O script criará duas funções RPC especiais:

```sql
-- Função principal que tenta vários campos
safe_update_user_photo(user_id, photo_url)

-- Função alternativa para profile_image_url
update_user_photo_path(user_id, photo_path)
```

### 3. Código Flutter Atualizado

O repository foi modificado para:

1. **Primeiro**: Tentar a função `safe_update_user_photo`
2. **Fallback 1**: Tentar a função `update_user_photo_path`
3. **Fallback 2**: Tentar atualização direta no campo `profile_image_url`

## 🧪 Testando a Correção

### Depois de executar o script SQL:

1. **Reinicie o app** no simulador/dispositivo
2. **Navegue para editar perfil**
3. **Tente adicionar uma foto**
4. **Observe os logs** para ver qual método funcionou

### Logs Esperados (Sucesso):

```
🔍 Iniciando seleção de imagem...
✅ Imagem selecionada: /path/to/image.png
📋 Tamanho do arquivo: 0.07 MB
🔄 Fazendo upload da foto...
✅ Upload realizado com sucesso
✅ URL pública gerada: https://...
🔄 Atualizando perfil via nova função RPC...
✅ RPC bem-sucedido: Foto de perfil atualizada com sucesso
✅ Colunas atualizadas: ["profile_image_url"]
✅ Upload concluído com sucesso!
```

## 🔍 Diagnóstico Adicional

Se ainda houver problemas, execute esta query no SQL Editor para verificar a estrutura:

```sql
-- Verificar colunas geradas
SELECT 
    column_name,
    data_type,
    is_generated,
    generation_expression
FROM information_schema.columns
WHERE table_name = 'profiles' 
AND table_schema = 'public'
AND column_name IN ('photo_url', 'profile_image_url');

-- Verificar se as funções foram criadas
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN ('safe_update_user_photo', 'update_user_photo_path');
```

## 🚨 Se a Foto Ainda Não Aparecer

### Possíveis Causas:

1. **Cache**: O app pode estar usando cache da imagem anterior
2. **Campo errado**: A tela pode estar lendo de um campo diferente
3. **Política RLS**: Pode haver restrição de leitura

### Soluções:

```dart
// 1. Forçar reload do perfil após upload
await ref.read(profileViewModelProvider.notifier).fetchCurrentProfile();

// 2. Limpar cache da imagem
await PaintingBinding.instance.imageCache.clear();

// 3. Adicionar timestamp para evitar cache
final imageUrlWithTimestamp = '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}';
```

## 📱 Próximos Passos

1. ✅ Execute o script SQL
2. ✅ Teste o upload de foto
3. ✅ Verifique os logs no console
4. ✅ Confirme se a foto aparece na tela

## 🆘 Se Precisar de Ajuda

Envie os logs completos após tentar o upload, incluindo:
- Mensagens de debug com 🔍 🔄 ✅ ❌
- Qualquer erro que aparecer
- O resultado da query de diagnóstico

---

**Resumo**: O problema era uma coluna gerada que não pode ser atualizada diretamente. A solução usa funções RPC especiais que contornam essa limitação atualizando os campos corretos. 