# Correção: Permissões para Editar e Excluir Treinos

Este documento explica como corrigir o problema em que alguns usuários não conseguem editar ou excluir seus próprios treinos.

## Diagnóstico do Problema

O problema ocorre porque as funções `update_workout_and_refresh` e `delete_workout_and_refresh` que são chamadas pelo aplicativo:

1. Ou não existem no banco de dados Supabase
2. Ou não estão definidas com `SECURITY DEFINER`, necessário para contornar as restrições de RLS (Row Level Security)

Por isso você (como admin ou desenvolvedor) consegue editar/excluir treinos, mas usuários comuns recebem o erro:

```
Erro ao atualizar treino: AppException [unknown_error]: Erro ao atualizar treino
```

## Como Aplicar a Correção

Siga estas etapas:

1. Acesse o [Console Supabase](https://app.supabase.io)
2. Selecione o projeto do aplicativo Ray Club
3. Vá para a seção "SQL Editor"
4. Crie uma nova query
5. Cole o conteúdo do arquivo `fix_workout_permission.sql` fornecido
6. Execute a query

## O que a Correção Faz

O script:

1. Cria (ou recria) duas funções RPC:
   - `update_workout_and_refresh`: Permite que usuários atualizem seus próprios treinos
   - `delete_workout_and_refresh`: Permite que usuários excluam seus próprios treinos

2. Define essas funções com `SECURITY DEFINER`, para que possam contornar as restrições de RLS, mas:
   - Verifica explicitamente se o usuário é dono do registro antes de permitir a operação
   - Garante que nenhum usuário possa modificar treinos de outras pessoas

3. Concede permissão de execução para todos os usuários autenticados

4. Atualiza automaticamente o dashboard e progresso em desafios após cada operação

## Verificação

Após aplicar a correção, teste o aplicativo com um usuário comum para verificar se:

1. É possível editar treinos existentes
2. É possível excluir treinos existentes

Se os problemas persistirem, verifique os logs do Supabase para identificar possíveis erros adicionais. 