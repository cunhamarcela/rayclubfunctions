Perfeito! Abaixo estão os prompts completos para o Cursor (ou Claude) com instruções detalhadas para implementar todas as etapas do checklist, mantendo o app Ray Club eficiente, sincronizado e consistente com o Supabase:

⸻

[PROMPT 1] – Criar e Validar o Modelo UserProgress com Freezed (Flutter)

Objetivo: Criar o modelo completo UserProgress com todos os campos do Supabase.

Você vai criar um model Dart usando Freezed e JsonSerializable para representar a tabela `user_progress`.

1. Use `@freezed` e `fromJson/toJson` com `@JsonKey` conforme necessário.
2. Os campos devem refletir exatamente a tabela Supabase atual, incluindo:
   - id (String)
   - userId (String)
   - totalWorkouts (int)
   - totalPoints (int)
   - currentStreak (int)
   - longestStreak (int)
   - bestStreak (int)
   - challengeProgress (int)
   - workoutsByType (Map<String, int>)
   - totalDuration (int)
   - completedChallenges (int)
   - daysTrainedThisMonth (int)
   - monthlyWorkouts (Map<String, int>)
   - weeklyWorkouts (Map<String, int>)
   - lastWorkout (DateTime?)
   - lastUpdated (DateTime?)
   - createdAt (DateTime?)

3. Salve o arquivo em:  
`lib/features/progress/models/user_progress.dart`



⸻

[PROMPT 2] – Criar UserProgressRepository com Supabase (Flutter)

Objetivo: Criar o repositório responsável por buscar, atualizar e sincronizar o progresso do usuário com o Supabase.

Crie um novo repositório Dart chamado `UserProgressRepository` com Supabase.

1. Local:  
`lib/features/progress/repositories/user_progress_repository.dart`

2. Funções necessárias:
   - `Future<UserProgress?> fetchUserProgress(String userId)`
   - `Future<void> updateFromWorkout(WorkoutRecord record)` → atualiza os campos usando lógica de streak, duração e tipo
   - `Future<void> updateFromChallengeProgress(ChallengeProgress cp)`
   - `Future<void> updateFromWaterIntake(WaterIntake intake)`
   - `Future<void> updateFromBenefitRedemption(...)`
   - `Future<void> updateFromUserGoal(...)`

3. Use `supabase.from(...).select().eq('user_id', userId)`  
   para buscar dados e atualize com `.update()` conforme necessário.



⸻

[PROMPT 3] – Refatorar ProgressViewModel para ser Centralizador de Dados

Objetivo: Atualizar o ProgressViewModel para reunir dados de várias fontes (treinos, desafios, metas, benefícios, água).

Refatore o `ProgressViewModel` localizado em:  
`lib/features/progress/view_models/progress_view_model.dart`

1. Adicione dependência dos seguintes repositórios:
   - UserProgressRepository
   - WorkoutRecordRepository
   - WaterIntakeRepository
   - ChallengeProgressRepository
   - UserGoalRepository

2. Crie método `loadFullProgress()` que:
   - Busca o progresso do Supabase
   - Atualiza o estado `ProgressState` com todos os blocos:
     - metas
     - água
     - desafios
     - treinos
     - estatísticas gerais

3. Exponha estado como `AsyncValue<ProgressState>`



⸻

[PROMPT 4] – Integrar Progresso Real à Tela Dashboard (Flutter)

Objetivo: Substituir dados mockados da Home por dados reais via ViewModel.

Atualize a `HomeScreen` (lib/features/home/screens/home_screen.dart):

1. Substitua o método `_buildProgressDashboard` para usar `ref.watch(progressViewModelProvider)`.
2. Mostre loading/error se necessário.
3. Construa os seguintes blocos de UI com dados reais:
   - Dias consecutivos (currentStreak)
   - Total de treinos
   - Total de duração
   - Consumo de água (últimos 7 dias)
   - Benefícios resgatados
   - Progresso de desafio (challengeProgress)
   - Metas criadas pelo usuário



⸻

[PROMPT 5] – Copiar Histórico de Treino para o Calendário (Tela Treinos)

Objetivo: Usar os dados já existentes de WorkoutRecord para preencher o calendário da Home.

Na HomeScreen ou ProgressViewModel:

1. Busque todos os registros de treino do mês atual.
2. Mapeie as datas em que há treino.
3. No widget do calendário, marque os dias com treinos usando destaque visual.
4. Se possível, diferencie o tipo de treino com cores ou ícones.



⸻

[PROMPT 6] – Garantir Sincronização com Trigger + Funções (Supabase)

Objetivo: Validar se a trigger update_user_progress_after_workout está funcionando e cobrindo os dados do dashboard.

Acesse o Supabase SQL Editor e:

1. Verifique se a função `update_user_progress_after_workout`:
   - Incrementa os campos corretamente
   - Calcula streak, workouts_by_type, etc.

2. Teste manualmente com INSERTs na tabela `workout_records`
3. Certifique-se que o trigger está ativo com:
   `SELECT * FROM pg_trigger WHERE tgname LIKE '%user_progress%'`

4. Verifique se todos os campos estão atualizando: `SELECT * FROM user_progress WHERE user_id = '<user_id>'`



⸻

[PROMPT 7] – Implementar Inserção Inicial via Trigger em auth.users (Supabase)

Objetivo: Garantir que todo novo usuário tenha seu registro na tabela user_progress.

No Supabase SQL Editor:

1. Confirme que existe a função:
```sql
CREATE OR REPLACE FUNCTION create_user_progress_for_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_progress (user_id) VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

	2.	E o trigger:

CREATE TRIGGER create_user_progress_for_new_user
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION create_user_progress_for_new_user();

	3.	Teste criando um novo usuário e validando que há linha em user_progress.

---

Esses prompts cobrem **toda a base técnica do seu fluxograma**. Posso agora gerar os prompts para as telas relacionadas (ex: Metas, Benefícios, Desafios) ou seguir com testes de integração e consistência. Deseja que eu continue por alguma tela específica agora?