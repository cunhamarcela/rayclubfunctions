# Atualização do Widget de Desafio no Dashboard

## Resumo das Alterações

O widget `ChallengeProgressWidget` foi modificado para exibir informações do desafio em si ao invés do progresso individual do usuário.

## Mudanças Implementadas

### Antes
- Exibia: Check-ins do usuário e pontos totais do usuário
- Dados vinham diretamente do `challengeProgressProvider`

### Depois
- Exibe: Total de participantes do desafio e pontos totais do desafio
- Busca dados do desafio ativo através do `userChallengesProvider`
- Usa o `challengeRankingProvider` para obter o número de participantes

## Detalhes Técnicos

### Arquivos Modificados
1. `lib/features/dashboard/widgets/challenge_progress_widget.dart`
   - Alterada lógica para buscar dados do desafio ao invés do progresso do usuário
   - Adicionado novo método `_buildChallengeInfo` para buscar informações do desafio
   - Modificados ícones e labels para refletir as novas informações

### Novos Dados Exibidos
- **Participantes**: Total de pessoas participando do desafio (obtido através do ranking)
- **Pontos**: Pontos totais disponíveis no desafio (propriedade `points` do modelo Challenge)

### Fluxo de Dados
1. Widget observa o `dashboardDataProvider` para verificar se há desafio ativo
2. Se houver, busca os desafios do usuário através do `userChallengesProvider`
3. Seleciona o primeiro desafio ativo
4. Usa o `challengeRankingProvider` para obter a lista de participantes
5. Exibe o total de participantes e os pontos do desafio

## Testes

Foi criado um arquivo de teste em `test/features/dashboard/widgets/challenge_progress_widget_test.dart` com os seguintes cenários:
- Widget vazio quando não há dados de desafio
- Exibição correta das informações quando há desafio ativo
- Tratamento de estados de loading
- Tratamento de estados de erro

## Considerações

- O widget agora depende de múltiplos providers, o que pode impactar a performance
- O número de participantes é obtido através do tamanho da lista do ranking, que pode não ser a forma mais eficiente
- Para melhor performance, considere criar um provider específico que retorne apenas o count de participantes 