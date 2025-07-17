# Teste Manual: Exibição de Desafios no Dashboard

Este arquivo contém instruções para testar manualmente se os desafios estão sendo exibidos corretamente no dashboard para todos os usuários.

## Problema: Desafio aparece para um usuário, mas não para outros

### Causa Raiz:
- Os desafios só eram exibidos para usuários que tinham registros em `challenge_participants` E `challenge_progress`
- A correção garante que ao entrar em um desafio, ambos os registros sejam criados corretamente

## Passos para Testar:

### 1. Verificar o banco de dados
1. Verifique se existem desafios ativos na tabela `challenges`:
   ```sql
   SELECT * FROM challenges WHERE end_date > NOW() AND active = true;
   ```

2. Para o usuário com problema, verifique se existe participação:
   ```sql
   SELECT * FROM challenge_participants WHERE user_id = 'ID_DO_USUARIO';
   ```

3. Para o usuário com problema, verifique se existe progresso:
   ```sql
   SELECT * FROM challenge_progress WHERE user_id = 'ID_DO_USUARIO';
   ```

### 2. Testes de Usuário

#### Para usuário que não vê desafios:
1. Faça login com o usuário que não consegue ver desafios
2. No Dashboard, verifique se o componente de desafio está visível
3. Se não estiver, verifique o console para logs de debug
4. Use a funcionalidade "Atualizar" (puxe para baixo ou clique no botão de atualizar)

#### Para adicionar um usuário a um desafio existente:
1. Identifique o ID do desafio ativo (da consulta 1 acima)
2. No aplicativo, navegue para a lista de desafios 
3. Entre no desafio desejado
4. Clique em "Participar"
5. Verifique se o desafio aparece no Dashboard

### 3. Solução de Problemas

Se o desafio ainda não aparecer após os passos acima:

1. Verifique se o desafio está ativo (data de término maior que hoje)
2. Limpe o cache do aplicativo e faça login novamente
3. Adicione o usuário manualmente às tabelas via SQL:

```sql
-- Adicionar à tabela challenge_participants
INSERT INTO challenge_participants (challenge_id, user_id, joined_at)
VALUES ('ID_DO_DESAFIO', 'ID_DO_USUARIO', NOW());

-- Adicionar à tabela challenge_progress
INSERT INTO challenge_progress (challenge_id, user_id, user_name, points, completion_percentage)
VALUES ('ID_DO_DESAFIO', 'ID_DO_USUARIO', 'Nome do Usuário', 0, 0);
```

## Resultados Esperados

Após as correções implementadas:
- Todos os usuários inscritos em desafios devem ver o componente de desafio no dashboard
- Ao entrar em um novo desafio, o usuário deve ver imediatamente o desafio no dashboard
- Logs de debug devem mostrar informações sobre o carregamento de desafios

## Notas

As alterações principais foram:
1. Melhorar o diagnóstico com logs detalhados
2. Garantir que desafios ativos sejam carregados corretamente
3. Corrigir o método `joinChallenge` para criar registros tanto em `challenge_participants` quanto em `challenge_progress`
4. Verificar registros de progresso existentes e criar se necessário 