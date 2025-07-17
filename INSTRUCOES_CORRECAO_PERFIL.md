# Instruções para Correção dos Problemas de Perfil

## Resumo dos Problemas
A funcionalidade de adicionar foto de perfil e salvar informações do perfil não está funcionando. Os problemas identificados são:

1. **Upload de Foto**: Erro ao fazer upload da foto de perfil
2. **Salvamento de Dados**: Erro ao salvar informações do perfil (telefone, gênero, data de nascimento, Instagram)

## Passos para Correção

### 1. Aplicar Correções no Banco de Dados

Execute o script `fix_profile_complete.sql` no **Supabase SQL Editor**:

1. Acesse o painel do Supabase
2. Vá para **SQL Editor**
3. Cole o conteúdo do arquivo `fix_profile_complete.sql`
4. Execute o script
5. Verifique se não há erros na execução

O script irá:
- ✅ Criar bucket `profile-images` se não existir
- ✅ Configurar políticas RLS para storage
- ✅ Corrigir políticas RLS da tabela `profiles`
- ✅ Adicionar campos ausentes na tabela
- ✅ Criar função RPC `update_user_photo_url`
- ✅ Configurar triggers para `updated_at`

### 2. Verificar Configurações

Após executar o script, verifique:

#### Bucket de Storage
```sql
SELECT id, name, public FROM storage.buckets WHERE id = 'profile-images';
```
Deve retornar: `profile-images | profile-images | true`

#### Políticas de Storage
```sql
SELECT policyname, cmd FROM storage.policies WHERE bucket_id = 'profile-images';
```
Deve retornar pelo menos 4 políticas (INSERT, SELECT, UPDATE, DELETE)

#### Políticas da Tabela Profiles
```sql
SELECT policyname, cmd FROM pg_policies 
WHERE tablename = 'profiles' AND schemaname = 'public';
```
Deve retornar 4 políticas básicas (SELECT, INSERT, UPDATE, DELETE)

#### Função RPC
```sql
SELECT proname FROM pg_proc WHERE proname = 'update_user_photo_url';
```
Deve retornar: `update_user_photo_url`

### 3. Teste as Funcionalidades

#### Teste de Upload de Foto
1. Execute o app
2. Vá para **Perfil** → **Editar Perfil**
3. Toque no ícone da câmera
4. Selecione uma imagem da galeria ou tire uma foto
5. Verifique se a foto é atualizada
6. Verifique os logs no console:
   ```
   🔍 Iniciando seleção de imagem...
   ✅ Imagem selecionada: /path/to/image
   📋 Tamanho do arquivo: X.XX MB
   🔄 Fazendo upload da foto...
   ✅ Upload realizado com sucesso
   ✅ URL pública gerada: https://...
   🔄 Atualizando perfil via RPC...
   ✅ Perfil atualizado via RPC com sucesso
   ```

#### Teste de Salvamento de Perfil
1. Execute o app
2. Vá para **Perfil** → **Editar Perfil**
3. Preencha os campos:
   - Telefone: `(11) 99999-9999`
   - Gênero: Selecione uma opção
   - Data de nascimento: Selecione uma data
   - Instagram: `@seuuser`
4. Toque em **Salvar Alterações**
5. Verifique se aparece a mensagem de sucesso
6. Verifique os logs no console:
   ```
   🔍 Iniciando salvamento do perfil...
   📋 Dados a serem salvos:
   ✅ Validações aprovadas, enviando para repositório...
   ✅ Perfil atualizado com sucesso
   ✅ Perfil salvo com sucesso
   ```

### 4. Troubleshooting

#### Erro: "Bucket não encontrado"
**Solução**: Re-execute a seção 1 do script SQL que cria o bucket

#### Erro: "Permissão negada"
**Solução**: Re-execute a seção 3 do script SQL que corrige as políticas RLS

#### Erro: "Função não encontrada"
**Solução**: Re-execute a seção 4 do script SQL que cria a função RPC

#### Erro: "Campo não existe"
**Solução**: Re-execute a seção 2 do script SQL que adiciona campos ausentes

#### Upload funciona mas não salva no perfil
**Diagnóstico**:
1. Verifique se a função RPC existe e tem permissões
2. Verifique os logs para ver se há erro no RPC
3. Teste a função RPC manualmente:
```sql
SELECT public.update_user_photo_url(
    'SEU_USER_ID'::uuid, 
    'https://test.com/test.jpg'
);
```

#### Salvamento de dados não funciona
**Diagnóstico**:
1. Verifique se todos os campos existem na tabela
2. Verifique as políticas RLS da tabela profiles
3. Teste uma atualização manual:
```sql
UPDATE public.profiles 
SET phone = '11999999999', updated_at = now() 
WHERE id = 'SEU_USER_ID'::uuid;
```

### 5. Logs de Debug

Durante os testes, monitore os logs do Flutter para identificar problemas:

```bash
flutter logs
```

Procure por:
- ❌ Erros em vermelho
- ⚠️ Avisos em amarelo
- ✅ Sucessos em verde
- 🔍 Informações de debug

### 6. Verificação Final

Após aplicar todas as correções:

1. ✅ Upload de foto funciona
2. ✅ Foto aparece na tela de perfil
3. ✅ Dados do perfil são salvos
4. ✅ Campos são validados corretamente
5. ✅ Mensagens de erro são claras
6. ✅ Não há erros nos logs

## Melhorias Implementadas

### Código Dart
- ✅ Melhor tratamento de erros
- ✅ Validação de dados antes do envio
- ✅ Logs detalhados para debug
- ✅ Feedback claro para o usuário
- ✅ Verificação de tamanho de arquivo
- ✅ Fallback entre RPC e método tradicional

### Banco de Dados
- ✅ Políticas RLS simplificadas e não conflitantes
- ✅ Bucket de storage com permissões corretas
- ✅ Função RPC robusta para upload de foto
- ✅ Triggers automáticos para updated_at
- ✅ Campos necessários na tabela profiles

## Notas Importantes

1. **Backup**: Sempre faça backup do banco antes de executar scripts
2. **Teste**: Teste em ambiente de desenvolvimento primeiro
3. **Logs**: Mantenha os logs ativos durante os testes
4. **Validação**: Valide cada etapa antes de prosseguir
5. **Rollback**: Tenha um plano de rollback se algo der errado 