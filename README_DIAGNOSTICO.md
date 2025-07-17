# Diagnóstico de Problemas no Dashboard e Ranking

Este conjunto de ferramentas de diagnóstico irá ajudar a encontrar e corrigir problemas relacionados à atualização do dashboard e do ranking após o registro de treinos no Ray Club App.

## Conteúdo

1. `funcoes_utilitarias_diagnostico.sql` - Funções SQL para o Supabase
2. `diagnostico_supabase.dart` - Aplicativo Flutter para coletar informações do Supabase
3. `diagnostico_ranking_dashboard.sql` - Consultas SQL para diagnóstico manual (opcional)
4. `diagnostico_flutter.dart` - Ferramenta de diagnóstico para o código Flutter (opcional)
5. `verificar_providers_viewmodels.dart` - Ferramenta para verificar Providers e ViewModels (opcional)

## Instruções

### Passo 1: Configurar funções utilitárias no Supabase

1. Acesse o painel do Supabase para seu projeto
2. Vá para a seção "SQL Editor"
3. Crie uma nova consulta e copie todo o conteúdo do arquivo `funcoes_utilitarias_diagnostico.sql`
4. Execute a consulta para criar todas as funções utilitárias

### Passo 2: Executar o diagnóstico automático

1. Adicione o arquivo `diagnostico_supabase.dart` ao seu projeto Flutter
2. Execute o aplicativo de diagnóstico com suas credenciais do Supabase:

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=sua_url --dart-define=SUPABASE_ANON_KEY=sua_chave diagnostico_supabase.dart
```

3. No aplicativo, clique em "Iniciar Diagnóstico" e aguarde a execução
4. Após a conclusão, o relatório será exibido na tela e também salvo como arquivo de texto

### Passo 3: Analisar os resultados

O relatório gerado contém informações sobre:

- Estruturas das tabelas relacionadas aos treinos, desafios e dashboard
- Definições das funções RPC importantes
- Triggers existentes nas tabelas
- Registros recentes de treinos, check-ins e progresso
- Logs de erros (se existirem)

### Passo 4 (Opcional): Diagnóstico manual

Se preferir, você pode executar consultas SQL manuais no Supabase usando o arquivo `diagnostico_ranking_dashboard.sql`. Este arquivo contém consultas detalhadas para verificar cada aspecto do sistema.

## Problemas comuns e soluções

### 1. Falha na atualização de rankings

**Possíveis causas:**
- A função `record_challenge_check_in_v2` não está chamando `process_workout_for_ranking`
- A função `process_workout_for_ranking` está retornando FALSE sem sucesso
- Falta de atualização dos providers no Flutter após registrar um treino

**Soluções:**
- Verificar e corrigir a função `record_challenge_check_in_v2` no Supabase
- Adicionar chamadas para `ref.refresh()` no ViewModel de treinos

### 2. Falha na atualização do dashboard

**Possíveis causas:**
- A função `process_workout_for_dashboard` não está sendo chamada
- A função `process_workout_for_dashboard` está retornando FALSE sem sucesso
- Falta de atualização dos providers no Flutter após registrar um treino

**Soluções:**
- Verificar e corrigir a função `record_challenge_check_in_v2` para garantir que chama `process_workout_for_dashboard`
- Modificar os providers do dashboard para usar `autoDispose()` e garantir atualização
- Implementar um sistema de eventos para notificar ViewModels sobre novos treinos

### 3. Problemas com Providers e ViewModels

Se as tabelas e funções do Supabase estiverem corretas, o problema pode estar na forma como os Providers e ViewModels estão gerenciando o estado no Flutter.

Utilize o arquivo `verificar_providers_viewmodels.dart` para diagnosticar problemas específicos com a gestão de estado:

```bash
flutter run -d chrome diagnostico_flutter.dart
```

## Contato e Suporte

Se precisar de ajuda para interpretar os resultados ou implementar correções, entre em contato com a equipe de desenvolvimento. 