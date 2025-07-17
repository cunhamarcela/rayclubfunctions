# Implementação do Sistema de Edição/Exclusão de Treinos

Este documento descreve a implementação do sistema de edição e exclusão de treinos integrado com Supabase, garantindo que as alterações reflitam corretamente no ranking dos desafios.

## Visão Geral

A funcionalidade permite aos usuários:
- Editar seus próprios treinos (nome, tipo, duração)
- Excluir treinos existentes
- Atualização automática do ranking e da pontuação nos desafios

## Componentes da Solução

### Backend (Supabase)

1. **Função `recalculate_challenge_progress`**
   - Recalcula pontos, check-ins e datas com base nos registros de treino
   - Atualiza a tabela `challenge_progress` automaticamente

2. **Trigger `trg_update_progress_after_workout_edit`**
   - Acionado após `UPDATE` ou `DELETE` na tabela `workout_records`
   - Executa a função `recalculate_challenge_progress` automaticamente

3. **Função RPC pública**
   - Permite recalcular o progresso manualmente através de chamadas RPC do app

### Frontend (Flutter)

1. **Modal de Edição/Exclusão**
   - Implementado em `lib/features/workout/widgets/workout_edit_modal.dart`
   - UI para editar ou excluir treinos com confirmação

2. **Integração com Telas Existentes**
   - Na tela de ranking de desafios, o usuário pode clicar em seu próprio nome e acessar opções
   - Na tela de histórico de treinos, o usuário tem acesso direto ao botão de edição

## Fluxo de Dados

1. O usuário edita ou exclui um treino na interface
2. O app chama o repositório para atualizar/excluir o registro no Supabase
3. O trigger no Supabase é acionado automaticamente
4. A função recalcula os pontos e atualiza a tabela de progresso
5. O ranking é atualizado quando a tela é recarregada

## Como Implementar no Supabase

Siga estes passos para implementar as funções necessárias no Supabase:

1. **Acesse o Console Supabase** 
   - Entre no projeto na dashboard do Supabase

2. **Abra o SQL Editor**
   - Vá para "Database" > "SQL Editor"

3. **Execute o Script SQL**
   - Cole o conteúdo do arquivo `/sql/workout_ranking_updates.sql` 
   - Execute o script completo

4. **Verifique as Funções e Triggers**
   - Confirme se as funções foram criadas em "Database" > "Functions"
   - Verifique se o trigger aparece em "Database" > "Tables" > "workout_records" > "Triggers"

## Testando a Funcionalidade

1. **Teste Manual de Edição**
   - Acesse o app como um usuário que tenha treinos em um desafio
   - Edite um treino e verifique se o ranking foi atualizado

2. **Teste Manual de Exclusão**
   - Exclua um treino e verifique se os pontos foram recalculados
   - Confirme se a posição no ranking foi ajustada

3. **Teste via Supabase**
   - Execute a função RPC diretamente via SQL:
   ```sql
   select recalculate_challenge_progress('user_id_here', 'challenge_id_here');
   ```

## Limitações Atuais e Melhorias Futuras

- A data do treino não pode ser editada na implementação atual
- Considerar adicionar auditoria de edições/exclusões para segurança
- Implementar um cache para evitar recálculos desnecessários em operações em massa 