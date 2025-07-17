# Sistema de Desafios do Ray Club

## Visão Geral

O sistema de desafios do Ray Club foi redesenhado para focar exclusivamente no desafio oficial "Ray 21", um programa de 21 dias que incentiva os usuários a manterem a consistência em suas atividades físicas. O redesenho simplifica a experiência do usuário, permitindo maior engajamento através de grupos e funcionalidades de ranking.

## Desafio Ray 21

O "Ray 21" é o desafio oficial da plataforma, projetado para estimular a constância na prática de exercícios por 21 dias consecutivos. Características principais:

- Duração fixa de 21 dias
- Pontos são concedidos para cada dia em que o usuário realiza check-in após treino
- Ranking geral de todos os participantes
- Possibilidade de criação de grupos para competições entre amigos

## Grupos de Desafio

A nova funcionalidade de grupos permite que os usuários criem círculos sociais dentro do desafio principal:

### Funcionalidades de Grupos

1. **Criação de Grupos**
   - Qualquer usuário pode criar um grupo
   - Cada grupo está vinculado ao desafio oficial Ray 21
   - O criador se torna automaticamente administrador do grupo

2. **Convites**
   - Administradores podem convidar outros usuários
   - Usuários recebem notificações de convites
   - Interface dedicada para gerenciar convites pendentes

3. **Ranking por Grupo**
   - Cada grupo possui seu próprio ranking
   - Visualização em tempo real do progresso de todos os membros
   - Filtros para diferentes períodos (últimos 7 dias, total, etc.)

4. **Gestão de Membros**
   - Administradores podem remover membros
   - Membros podem sair voluntariamente
   - Limite máximo de 50 participantes por grupo

## Fluxo de Navegação

O sistema de navegação foi simplificado:

- A tela principal exibe apenas o desafio oficial Ray 21
- O botão de "Grupos" permite acesso à lista de grupos do usuário
- A aba "Convites" mostra convites pendentes para grupos
- O ranking geral está acessível a partir da tela principal do desafio

## Banco de Dados

O sistema utiliza duas tabelas principais no Supabase:

1. **challenge_groups**: Armazena informações dos grupos
   - Campos: id, challenge_id, creator_id, name, description, member_ids, etc.

2. **challenge_group_invites**: Gerencia convites de grupo
   - Campos: id, group_id, inviter_id, invitee_id, status, etc.

Funções SQL especializadas:
- `get_group_ranking`: Retorna o ranking dos membros de um grupo específico

## Implementação Técnica

A implementação segue o padrão MVVM com Riverpod:

- **Models**: `ChallengeGroup` e `ChallengeGroupInvite`
- **ViewModels**: `ChallengeViewModel` e `ChallengeGroupViewModel`
- **Repositories**: Métodos específicos no `ChallengeRepository`
- **Screens**: Telas dedicadas para grupos, convites e rankings

## Considerações de UX

- Interface simplificada com foco no desafio principal
- Navegação intuitiva entre grupos e desafio principal
- Feedback visual para ações como criação de grupo e resposta a convites
- Cores e ícones consistentes com o resto da aplicação 