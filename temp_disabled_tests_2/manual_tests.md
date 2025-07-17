# Testes Manuais para Correções no Ray Club App

Este documento contém testes manuais para verificar as correções implementadas nos bugs reportados.

## 1. Tela de Introdução após Login

**Objetivo:** Verificar se a tela de introdução (onboarding) não aparece mais para usuários que já a viram.

**Cenários de Teste:**

1. **Usuário faz login pela primeira vez:**
   - [ ] Após login bem-sucedido, o usuário deve ver a tela de introdução
   - [ ] Ao navegar para fora da tela de introdução, a flag `has_seen_intro` deve ser salva

2. **Usuário que já viu a introdução:**
   - [ ] Ao fazer login, o usuário deve ser redirecionado diretamente para a tela inicial
   - [ ] A tela de introdução não deve ser mostrada

3. **Usuário sem flag local, mas com flag no Supabase:**
   - [ ] Ao fazer login em um novo dispositivo, verificar se o app reconhece o status no Supabase
   - [ ] O usuário deve ser redirecionado diretamente para a tela inicial
   - [ ] A flag `has_seen_intro` local deve ser sincronizada

## 2. Registro de Água

**Objetivo:** Verificar se os dados de ingestão de água são corretamente persistidos no Supabase.

**Cenários de Teste:**

1. **Adicionar um copo de água:**
   - [ ] O contador na UI deve aumentar imediatamente
   - [ ] Verificar no banco de dados Supabase se o registro foi persistido corretamente
   - [ ] Fechar e reabrir o app para verificar se os dados são carregados corretamente

2. **Remover um copo de água:**
   - [ ] O contador na UI deve diminuir imediatamente
   - [ ] Verificar no banco de dados Supabase se o registro foi atualizado
   - [ ] Fechar e reabrir o app para verificar se os dados são carregados corretamente

3. **Testes em diferentes dias:**
   - [ ] Verificar se o app cria registros separados para diferentes dias
   - [ ] Verificar se o histórico de consumo de água é mantido corretamente

## 3. Ranking de Desafio

**Objetivo:** Verificar se os pontos no ranking do desafio são atribuídos corretamente conforme a nova lógica.

**Cenários de Teste:**

1. **Treino com duração menor que 45 minutos:**
   - [ ] Registrar um treino com duração de 30 minutos
   - [ ] Verificar se nenhum ponto é adicionado ao desafio

2. **Treino com duração maior ou igual a 45 minutos:**
   - [ ] Registrar um treino com duração de 45 minutos
   - [ ] Verificar se 1 ponto é adicionado ao desafio

3. **Múltiplos treinos no mesmo dia:**
   - [ ] Registrar um treino de 45 minutos
   - [ ] Registrar um segundo treino de 60 minutos no mesmo dia
   - [ ] Verificar se apenas 1 ponto total é concedido para o dia

4. **Treinos em dias consecutivos:**
   - [ ] Registrar treinos de 45+ minutos em dias consecutivos
   - [ ] Verificar se 1 ponto é adicionado para cada dia de treino

## 4. Tela de Perfil sem Foto

**Objetivo:** Verificar se o fallback para usuários sem foto de perfil funciona corretamente.

**Cenários de Teste:**

1. **Usuário sem foto de perfil:**
   - [ ] Verificar se a imagem placeholder é exibida
   - [ ] Verificar se a inicial do nome do usuário é exibida

2. **Usuário com URL de foto inválida:**
   - [ ] Definir uma URL inválida para a foto do usuário
   - [ ] Verificar se a imagem placeholder é exibida como fallback

3. **Usuário com foto válida:**
   - [ ] Verificar se a foto do usuário é exibida corretamente

## 5. Dados de Metas

**Objetivo:** Verificar se as metas do usuário são gerenciadas e armazenadas corretamente.

**Cenários de Teste:**

1. **Criar uma nova meta:**
   - [ ] Criar uma nova meta de treino
   - [ ] Verificar se a meta é exibida na lista de metas
   - [ ] Verificar se a meta é armazenada corretamente no Supabase

2. **Atualizar progresso de meta:**
   - [ ] Atualizar o progresso de uma meta existente
   - [ ] Verificar se o progresso é atualizado na UI
   - [ ] Verificar se o progresso é persistido no Supabase

3. **Excluir uma meta:**
   - [ ] Excluir uma meta existente
   - [ ] Verificar se a meta é removida da lista de metas
   - [ ] Verificar se a meta é removida do Supabase

## 6. Compatibilidade de Perfis

**Objetivo:** Verificar se o app funciona corretamente com diferentes tipos de perfil de usuário.

**Cenários de Teste:**

1. **Usuário sem foto:**
   - [ ] Verificar navegação por todas as telas principais
   - [ ] Verificar componentes que exibem o avatar do usuário

2. **Usuário com e sem metas:**
   - [ ] Verificar exibição da tela para usuário sem metas
   - [ ] Verificar exibição da tela para usuário com metas

3. **Usuário que treina todo dia vs intermitente:**
   - [ ] Verificar exibição de estatísticas para usuário com treinos diários
   - [ ] Verificar exibição de estatísticas para usuário com treinos intermitentes

4. **Usuário que fez ou não onboarding:**
   - [ ] Verificar fluxo para usuário que ainda não fez onboarding
   - [ ] Verificar fluxo para usuário que já fez onboarding 