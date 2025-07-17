**Plano de Integração Flutter + Supabase para o Fluxo do Dashboard Ray Club**

---

### 1. **REGISTRO DE TREINO (Botão de Registro de Treino)**

#### Flutter:

* Tela de registro com campos: nome, tipo, duração, intensidade, imagem.
* Ao salvar, disparar função `registerWorkout()` que envia os dados para a tabela `workout_records` via Supabase.

#### Supabase:

* Tabela: `workout_records`
* Trigger: `update_user_progress_after_workout` (já criada)
* Função: atualiza `user_progress` (tempo, pontos, streaks, tipo de treino, etc).
* Alimenta também: `user_progress`, `challenge_progress` e `calendar`.

---

### 2. **HISTÓRICO DE TREINO / CALENDÁRIO DE TREINOS**

#### Flutter:

* Tela "Histórico de Treinos": puxa dados de `workout_records` para exibir por dia (nome, hora, duração).
* Tela "Calendário do Dashboard": reúproveita dados do histórico apenas com marcação dos dias com treino.

#### Supabase:

* Consulta à tabela `workout_records` (SELECT por data e user\_id)
* Não necessita de nova estrutura, mas pode usar `user_progress.monthly_workouts` como cache para otimizar.

---

### 3. **RANKING DO DESAFIO**

#### Flutter:

* Tela do desafio (ranking): mostra nome, pontos e posição do usuário.
* Puxa de `challenge_progress` filtrando pelo `challenge_id` atual.

#### Supabase:

* Tabela: `challenge_progress`
* Relaciona user\_id + challenge\_id + pontos.
* Pontuação alimentada via função específica (ex: `update_challenge_progress_after_workout()` ou manual via check-in).

---

### 4. **PROGRESSO DE TEMPO (Dashboard)**

#### Flutter:

* Mostra progresso de tempo total, streak atual, total de treinos, etc.
* Consulta direta à tabela `user_progress`.

#### Supabase:

* Tabela: `user_progress`
* Campos relevantes: `total_duration`, `current_streak`, `total_workouts`, `days_trained_this_month`, etc.
* Atualizados via trigger de `workout_records`.

---

### 5. **ESTATÍSTICAS (Tela de Perfil)**

#### Flutter:

* Puxa as mesmas informações de `user_progress`, mas mostra em outro layout.

#### Supabase:

* Reutiliza tabela `user_progress`.

---

### 6. **METAS (Perfil do Usuário → Dashboard)**

#### Flutter:

* Cadastro de metas: tela de perfil.
* Exibição no dashboard.
* Botões de progresso: + / -

#### Supabase:

* Tabela: `user_goals` (se não existe, criar com user\_id, tipo, meta, progresso, unidade, etc).
* Policies RLS para permitir só visualização/edição pelo próprio usuário.

---

### 7. **BENEFÍCIOS RESGATADOS (Tela de Benefícios → Dashboard)**

#### Flutter:

* Ao resgatar um benefício, salvar em tabela de resgates.
* No dashboard, exibir benefícios resgatados recentes.

#### Supabase:

* Tabela: `benefit_redemption_codes`
* Relaciona user\_id com benefit\_id e status.
* RLS ativado e funcionando.

---

### 8. **CONSUMO DE ÁGUA (Direto no Dashboard)**

#### Flutter:

* Botões "Adicionar" e "Remover" copos d'água.
* Atualiza visual e porcentagem em tempo real.

#### Supabase:

* Tabela: `water_intake`
* Cada registro pode conter data, user\_id e quantidade.
* Agregar por dia para mostrar total.

---

### 9. **DESAFIOS PARTICIPADOS (Histórico e progresso no Dashboard)**

#### Flutter:

* Dashboard mostra desafios ativos/concluídos e progresso.
* Exibe ranking, porcentagem de conclusão, dias ativos etc.

#### Supabase:

* Tabelas:

  * `challenge_participants`
  * `challenge_progress`
  * `challenge_check_ins`
* Consulta combinada por user\_id para recuperar o histórico completo.

---

### Etapas Finais para Integração Completa:

1. **No Supabase:**

   * Garantir todas as tabelas citadas com RLS (já configuradas na maioria).
   * Verificar se todas estão com colunas necessárias (ex: `created_at`, `user_id`, etc).
   * Criar views otimizadas se necessário para consultas mais rápidas (ex: `dashboard_view`).

2. **No Flutter:**

   * Criar repositórios para cada funcionalidade: treino, metas, água, desafio, benefício.
   * Gerenciar estado com Riverpod para todas as páginas relacionadas ao dashboard.
   * Usar `supabase.from("...").select()`, `.insert()`, `.update()` conforme o módulo.
   * Criar métodos assíncronos centralizados no repositório de cada feature para abstrair lógica.

3. **Testes:**

   * Registrar treino: deve atualizar dashboard, ranking e calendário.
   * Adicionar meta: aparecer no dashboard.
   * Resgatar benefício: aparecer no dashboard.
   * Check-in desafio: atualizar ranking/desempenho.
   * Adicionar copo d'água: atualizar componente no dashboard.


