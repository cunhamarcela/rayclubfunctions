# Correção do Erro de Atualização da Foto de Perfil

## Problema
Ao tentar atualizar a foto de perfil, o aplicativo retorna o erro:
```
Erro ao atualizar foto: AppException [428C9]: column "photo_url" can only be updated to DEFAULT
```

## Causa
Este erro ocorre devido a uma política RLS (Row Level Security) restritiva no Supabase que está impedindo a atualização da coluna `photo_url` na tabela `profiles`.

## Solução

### 1. Execute o Script de Diagnóstico
Primeiro, execute o arquivo `check_photo_url_policies.sql` no editor SQL do Supabase para verificar as políticas atuais:

```sql
-- Este arquivo já foi criado e contém queries para verificar:
-- - Políticas RLS existentes
-- - Constraints na tabela
-- - Definição das colunas
-- - Triggers relacionados
```

### 2. Execute o Script de Correção
Execute o arquivo `fix_photo_url_update_policy.sql` no editor SQL do Supabase:

```bash
# No painel do Supabase:
# 1. Vá para SQL Editor
# 2. Crie uma nova query
# 3. Cole o conteúdo do arquivo fix_photo_url_update_policy.sql
# 4. Execute a query
```

### 3. Verificação Adicional no Código Flutter

Se o problema persistir após executar o script SQL, verifique se o repositório está usando a coluna correta:

```dart
// Em lib/features/profile/repositories/supabase_profile_repository.dart
// Linha ~350, verifique se está atualizando ambas as colunas:

await _client
    .from(_profilesTable)
    .update({
      'photo_url': imageUrl,
      'profile_image_url': imageUrl, // Por compatibilidade
      'updated_at': DateTime.now().toIso8601String(),
    })
    .eq('id', userId);
```

### 4. Teste Alternativo

Se ainda houver problemas, você pode testar usando a função criada no script:

```dart
// Teste temporário para verificar se a função funciona
await _client.rpc('test_update_photo_url', params: {
  'user_id': userId,
  'new_photo_url': imageUrl,
});
```

### 5. Verificação no Painel do Supabase

1. Vá para **Authentication > Policies**
2. Procure pela tabela `profiles`
3. Verifique se existe alguma política com restrições específicas para `photo_url`
4. Se existir, edite ou remova a restrição

### 6. Debug Adicional

Se o erro persistir, adicione logs de debug no código Flutter:

```dart
// Em supabase_profile_repository.dart, antes do update:
debugPrint('🔍 Tentando atualizar photo_url para userId: $userId');
debugPrint('🔍 Nova URL: $imageUrl');

try {
  // ... código de update ...
} catch (e) {
  debugPrint('❌ Erro detalhado: $e');
  if (e is PostgrestException) {
    debugPrint('❌ Código: ${e.code}');
    debugPrint('❌ Mensagem: ${e.message}');
    debugPrint('❌ Detalhes: ${e.details}');
  }
  rethrow;
}
```

## Solução Temporária

Se precisar de uma solução imediata enquanto investiga o problema:

1. **Desabilite temporariamente RLS** (apenas para teste):
   ```sql
   ALTER TABLE public.profiles DISABLE ROW LEVEL SECURITY;
   -- Teste o upload
   -- Depois reabilite:
   ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
   ```

2. **Use uma função stored procedure** que já foi criada no script:
   ```sql
   -- Esta função já foi criada no script fix_photo_url_update_policy.sql
   -- Ela usa SECURITY DEFINER para contornar RLS
   ```

## Próximos Passos

1. Execute os scripts SQL fornecidos
2. Teste o upload de foto novamente
3. Se o problema persistir, verifique os logs de debug
4. Considere revisar todas as políticas RLS da tabela profiles

## Observações Importantes

- O erro 428C9 parece ser um código customizado da aplicação, não um erro padrão do PostgreSQL
- A restrição "can only be updated to DEFAULT" sugere uma política WITH CHECK muito restritiva
- Certifique-se de que o usuário está autenticado corretamente antes de tentar atualizar a foto 