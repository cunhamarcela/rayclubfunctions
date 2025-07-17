marcelacunha@MacBook-Pro-de-Marcela ray_club_app % flutter run
Connected devices:
iPhone 16 (mobile)              • 3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5 • ios          •
com.apple.CoreSimulator.SimRuntime.iOS-18-3 (simulator)
Iphone 15 (mobile)              • BF7B60D9-B0B3-4705-9A0A-77CFB1CBFC02 • ios          •
com.apple.CoreSimulator.SimRuntime.iOS-18-3 (simulator)
macOS (desktop)                 • macos                                • darwin-arm64 • macOS
15.3.1 24D70 darwin-arm64
Mac Designed for iPad (desktop) • mac-designed-for-ipad                • darwin       • macOS
15.3.1 24D70 darwin-arm64

No wireless devices were found.

[1]: iPhone 16 (3F65C00E-0CCB-4B8A-ADC4-3C3008F485A5)
[2]: Iphone 15 (BF7B60D9-B0B3-4705-9A0A-77CFB1CBFC02)
[3]: macOS (macos)
[4]: Mac Designed for iPad (mac-designed-for-ipad)
Please choose one (or "q" to quit): 1
Launching lib/main.dart on iPhone 16 in debug mode...
Running Xcode build...                                                  
 └─Compiling, linking and signing...                         3,7s
Xcode build done.                                           22,1s
flutter: 🟢 MAIN ATUAL EXECUTADA
flutter: ✅ AppConfig inicializado (Ambiente: Environment.development)
Syncing files to device iPhone 16...                                56ms
flutter: supabase.supabase_flutter: INFO: ***** Supabase init completed *****
flutter: ✅ Supabase inicializado
flutter: 🔍 Verificando tabelas do Supabase

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on iPhone 16 is available at: http://127.0.0.1:63382/IPEb_4wGau8=/
The Flutter DevTools debugger and profiler on iPhone 16 is available at:
http://127.0.0.1:9100?uri=http://127.0.0.1:63382/IPEb_4wGau8=/
flutter: ✅ Tabela workouts verificada
flutter: ✅ Tabela banners verificada
flutter: ✅ Tabela user_progress verificada
flutter: 🔍 Current has_seen_intro value: true
flutter: ⚠️ FORCED RESET: has_seen_intro flag set to false for testing
flutter: ✅ SharedPreferences inicializado
flutter: Inicializando dependências...
flutter: 🔍 Já viu a introdução? false
flutter: ✅ Configurando primeira execução - tela de intro será exibida
flutter: 🔍 DeepLinkService: Inicializando serviço de deep links
flutter: 🔍 DeepLinkService: Nenhum link inicial detectado
flutter: ✅ DeepLinkService: Listener de links configurado com sucesso
flutter: ✅ Dependências inicializadas com sucesso
flutter: ✅ Dependências inicializadas
flutter: \^[[38;5;12m┌───────────────────────────────────────────────────────────────────────────────<…>
flutter: \^[[38;5;12m│ 15:04:37.437 (+0:00:00.000929)<…>
flutter: \^[[38;5;12m├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄<…>
flutter: \^[[38;5;12m│ 💡 {<…>
flutter: \^[[38;5;12m│ 💡   "tag": "RemoteLoggingService",<…>
flutter: \^[[38;5;12m│ 💡   "message": "Serviço de log remoto desabilitado por configuração",<…>
flutter: \^[[38;5;12m│ 💡   "data": null<…>
flutter: \^[[38;5;12m│ 💡 }<…>
flutter: \^[[38;5;12m└───────────────────────────────────────────────────────────────────────────────<…>
flutter: 🚀 App inicializado e rodando
flutter: 🔍 Building MyApp
flutter: 🔍 Configurando router - rota inicial: /intro
flutter: LayeredAuthGuard - Navegando para: /
flutter: LayeredAuthGuard - Usuário ainda não viu intro, redirecionando para tela de introdução
flutter: >>> IntroScreen carregada
flutter: 🔍 ----- INFORMAÇÕES DE DEEP LINKING -----
flutter: 🔍 DeepLinkService inicializado: true
flutter: 🔍 Formato esperado de URL: rayclub://login-callback/
flutter: 🔍 Configuração necessária:
flutter: 🔍   - Android: <data android:scheme="rayclub" android:host="login-callback" />
flutter: 🔍   - iOS: CFBundleURLSchemes array com <string>rayclub</string>
flutter: 🔍   - iOS: FlutterDeepLinkingEnabled key com <true/>
flutter: 🔍   - Supabase: Redirect URL deve incluir rayclub://login-callback/
flutter: 🔍   - GCP: https://[ID DO PROJETO].supabase.co/auth/v1/callback
flutter: 🔍 DeepLinkService: Verificando link rayclub://login-callback/
flutter: 🔍 DeepLinkService: Esquema: rayclub (esperado: rayclub) - Match: true
flutter: 🔍 DeepLinkService: Host: login-callback (esperado: login-callback) - Match: true
flutter: 🔍 DeepLinkService: É link de autenticação: true
flutter: 🔍 Teste URI 1: rayclub://login-callback/ => isAuthLink: true
flutter: 🔍 DeepLinkService: Verificando link rayclub://login-callback/?token=1234
flutter: 🔍 DeepLinkService: Esquema: rayclub (esperado: rayclub) - Match: true
flutter: 🔍 DeepLinkService: Host: login-callback (esperado: login-callback) - Match: true
flutter: 🔍 DeepLinkService: É link de autenticação: true
flutter: 🔍 Teste URI 2: rayclub://login-callback/?token=1234 => isAuthLink: true
flutter: 🔍 DeepLinkService: Verificando link https://rayclub.vercel.app/auth/callback
flutter: 🔍 DeepLinkService: Esquema: https (esperado: rayclub) - Match: false
flutter: 🔍 DeepLinkService: Host: rayclub.vercel.app (esperado: login-callback) - Match: false
flutter: 🔍 DeepLinkService: É link de autenticação: false
flutter: 🔍 Teste URI 3: https://rayclub.vercel.app/auth/callback => isAuthLink: false
flutter: 🔍 ----- FIM DAS INFORMAÇÕES DE DEEP LINKING -----
flutter: 📱 IntroScreen: Botão Visualizar conteúdo clicado
flutter: 💡 IntroScreen: Marcando que o usuário já viu a introdução
flutter: ✅ IntroScreen: Marcado que o usuário já viu a introdução
flutter: LayeredAuthGuard - Navegando para: /
flutter: 🔄 AuthViewModel: Token próximo de expirar, renovando sessão
flutter: supabase.auth: INFO: Refresh session
flutter: 🔄 AuthViewModel: Iniciado verificador periódico de autenticação a cada 30 minutos
flutter: LayeredAuthGuard - Realizando verificação completa de autenticação
flutter: 🔄 AuthViewModel: Token próximo de expirar, renovando sessão
flutter: supabase.auth: INFO: Refresh session
flutter: ✅ AuthViewModel: Sessão renovada com sucesso, expira em: 1744571079
flutter: ✅ AuthViewModel: Sessão renovada com sucesso, expira em: 1744571079
flutter: LayeredAuthGuard - Usuário autenticado, permitindo acesso
flutter: 🔍 HomeViewModel: Iniciando carregamento de dados
flutter: 🔍 HomeViewModel: Chamando repository.getHomeData()
flutter: 🔍 SupabaseHomeRepository: Iniciando busca de dados
flutter: 🔍 Cache não encontrado, buscando dados remotos
flutter: 🔍 Verificando conexão com Supabase...
flutter: ✅ Sessão Supabase: Ativa
flutter: 🔍 Iniciando requisições paralelas
flutter: 🔍 Cache de banners não encontrado
flutter: 🔍 Buscando banners do Supabase...
flutter: ⚠️ Nenhum banner encontrado no Supabase, usando dados padrão
flutter: ❌ Erro detalhado ao carregar dados da Home: AppException: Erro ao buscar progresso: JSON object requested, multiple (or no) rows returned
flutter: ❌ Stack trace: #0      SupabaseHomeRepository.getUserProgress (package:ray_club_app/features/home/repositories/home_repository.dart:371:9)
<asynchronous suspension>
#1      Future.wait.<anonymous closure> (dart:async/future.dart:528:21)
<asynchronous suspension>
#2      Future.timeout.<anonymous closure> (dart:async/future_impl.dart:1043:7)
<asynchronous suspension>
#3      SupabaseHomeRepository.getHomeData (package:ray_club_app/features/home/repositories/home_repository.dart:238:23)
<asynchronous suspension>
#4      HomeViewModel.loadHomeData (package:ray_club_app/features/home/viewmodels/home_view_model.dart:54:24)
<asynchronous suspension>
flutter: 🔍 Tentando usar cache como fallback após erro
flutter: ⚠️ Nenhum cache disponível como fallback
flutter: ❌ HomeViewModel - Erro específico da aplicação: Erro ao carregar dados da Home
flutter: ❌ Erro original: AppException: Erro ao buscar progresso: JSON object requested, multiple (or no) rows returned
flutter: ❌ Stack trace: #0      SupabaseHomeRepository.getUserProgress (package:ray_club_app/features/home/repositories/home_repository.dart:371:9)
<asynchronous suspension>
#1      Future.wait.<anonymous closure> (dart:async/future.dart:528:21)
<asynchronous suspension>
#2      Future.timeout.<anonymous closure> (dart:async/future_impl.dart:1043:7)
<asynchronous suspension>
#3      SupabaseHomeRepository.getHomeData (package:ray_club_app/features/home/repositories/home_repository.dart:238:23)
<asynchronous suspension>
#4      HomeViewModel.loadHomeData (package:ray_club_app/features/home/viewmodels/home_view_model.dart:54:24)
<asynchronous suspension>
flutter: 🔄 Tentando carregar dados parciais após erro
flutter: 🔍 Cache de banners não encontrado
flutter: 🔍 Buscando banners do Supabase...
flutter: ⚠️ Nenhum banner encontrado no Supabase, usando dados padrão
flutter: ✅ Banners carregados em modo parcial: 3
flutter: ✅ Categorias carregadas em modo parcial: 4
flutter: ⚠️ Não foi possível carregar treinos populares: AppException: Erro ao carregar treinos populares
flutter: ✅ HomeViewModel: Carregamento parcial concluído
flutter: 🔍 Registro de treino criado: WorkoutRecord(id: ae387d84-d99d-4f00-9f4a-920e7bbdd490, userId: , workoutId: null, workoutName: muscula'çao, workoutType: Funcional, date: 2025-04-13 15:04:54.308615, durationMinutes: 30, isCompleted: true, notes: Intensidade: 1/5, createdAt: 2025-04-13 15:04:54.308615)
flutter: 📤 Convertendo para o banco: {user_id: 01d4a292-1873-4af6-948b-a55eed56d6b9, workout_id: null, workout_name: muscula'çao, workout_type: Funcional, date: 2025-04-13T15:04:54.308615, duration_minutes: 30, is_completed: true, notes: Intensidade: 1/5, created_at: 2025-04-13T15:04:54.308615}
flutter: 🔍 Enviando para Supabase: {user_id: 01d4a292-1873-4af6-948b-a55eed56d6b9, workout_id: null, workout_name: muscula'çao, workout_type: Funcional, date: 2025-04-13T15:04:54.308615, duration_minutes: 30, is_completed: true, notes: Intensidade: 1/5, created_at: 2025-04-13T15:04:54.308615}
flutter: ✅ Resposta do Supabase: {id: 9fd7dfa6-4a37-4de8-9683-c8d96e473d49, user_id: 01d4a292-1873-4af6-948b-a55eed56d6b9, workout_id: null, workout_name: muscula'çao, workout_type: Funcional, date: 2025-04-13T15:04:54.308615+00:00, duration_minutes: 30, is_completed: true, notes: Intensidade: 1/5, created_at: 2025-04-13T18:04:54.56081+00:00}
flutter: 📥 Convertendo do banco: {id: 9fd7dfa6-4a37-4de8-9683-c8d96e473d49, user_id: 01d4a292-1873-4af6-948b-a55eed56d6b9, workout_id: null, workout_name: muscula'çao, workout_type: Funcional, date: 2025-04-13T15:04:54.308615+00:00, duration_minutes: 30, is_completed: true, notes: Intensidade: 1/5, created_at: 2025-04-13T18:04:54.56081+00:00}
flutter: ✅ Registro de treino salvo com sucesso: WorkoutRecord(id: 9fd7dfa6-4a37-4de8-9683-c8d96e473d49, userId: 01d4a292-1873-4af6-948b-a55eed56d6b9, workoutId: null, workoutName: muscula'çao, workoutType: Funcional, date: 2025-04-13 15:04:54.308615Z, durationMinutes: 30, isCompleted: true, notes: Intensidade: 1/5, createdAt: 2025-04-13 18:04:54.560810Z)
flutter: 🏋️ Processando treino concluído: muscula'çao
flutter: 🎯 Usuário participa de 1 desafios ativos
flutter: Error checking check-in: PostgrestException(message: operator does not exist: timestamp with time zone ~~* unknown, code: 42883, details: Not Found, hint: No operator matches the given name and argument types. You might need to add explicit type casts.)
flutter: ❌ Erro ao registrar check-in: PostgrestException(message: column reference "check_ins_count" is ambiguous, code: 42702, details: Bad Request, hint: null)
flutter: ❌ Erro ao processar treino para desafios: AppException: Erro ao registrar check-in
flutter: ❌ Erro ao processar desafios: AppException [challenge_processing_error]: Erro ao processar treino para desafios
flutter: LayeredAuthGuard - Navegando para: /challenges
flutter: LayeredAuthGuard - Usando estado em cache (última verificação há 0 minutos)
flutter: LayeredAuthGuard - Usuário autenticado, permitindo acesso
flutter: 🔍 ChallengeViewModel - loadOfficialChallenge iniciado
flutter: 🔍 Buscando desafio oficial...
flutter: 🧪 Estado na build: isLoading=true, officialChallenge=null, errorMessage=null
flutter: 🔍 ChallengeViewModel - loadOfficialChallenge iniciado
flutter: 🔍 Buscando desafio oficial...
flutter: 🔍 Buscando desafio oficial...
flutter: 🧪 Estado na build: isLoading=true, officialChallenge=null, errorMessage=null
flutter: 🔍 Resposta da busca: [{id: 1c26ef02-e87d-4fd6-855b-8f968cdad06b, title: TESTE - Desafio Oficial Ray Club, description: Desafio de teste disponível para todos. Complete diariamente para ganhar pontos., image_url: null, start_date: 2025-04-09T00:00:00+00:00, end_date: 2025-05-10T00:00:00+00:00, type: daily, points: 1000, requirements: {count: 0, workouts: [], specific_exercises: []}, participants: 1, active: true, creator_id: 01d4a292-1873-4af6-948b-a55eed56d6b9, is_official: true, created_at: 2025-04-10T21:09:43.019452+00:00, updated_at: 2025-04-10T21:09:43.019452+00:00, invited_users: []}]
flutter: ✅ Desafio oficial encontrado: TESTE - Desafio Oficial Ray Club
flutter: 🔍 ChallengeViewModel - Desafio oficial recebido: TESTE - Desafio Oficial Ray Club, id: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 Buscando progresso para desafio: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 Resposta da busca: [{id: 1c26ef02-e87d-4fd6-855b-8f968cdad06b, title: TESTE - Desafio Oficial Ray Club, description: Desafio de teste disponível para todos. Complete diariamente para ganhar pontos., image_url: null, start_date: 2025-04-09T00:00:00+00:00, end_date: 2025-05-10T00:00:00+00:00, type: daily, points: 1000, requirements: {count: 0, workouts: [], specific_exercises: []}, participants: 1, active: true, creator_id: 01d4a292-1873-4af6-948b-a55eed56d6b9, is_official: true, created_at: 2025-04-10T21:09:43.019452+00:00, updated_at: 2025-04-10T21:09:43.019452+00:00, invited_users: []}]
flutter: ✅ Desafio oficial encontrado: TESTE - Desafio Oficial Ray Club
flutter: 🔍 ChallengeViewModel - Desafio oficial recebido: TESTE - Desafio Oficial Ray Club, id: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 Buscando progresso para desafio: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 Resposta da busca: [{id: 1c26ef02-e87d-4fd6-855b-8f968cdad06b, title: TESTE - Desafio Oficial Ray Club, description: Desafio de teste disponível para todos. Complete diariamente para ganhar pontos., image_url: null, start_date: 2025-04-09T00:00:00+00:00, end_date: 2025-05-10T00:00:00+00:00, type: daily, points: 1000, requirements: {count: 0, workouts: [], specific_exercises: []}, participants: 1, active: true, creator_id: 01d4a292-1873-4af6-948b-a55eed56d6b9, is_official: true, created_at: 2025-04-10T21:09:43.019452+00:00, updated_at: 2025-04-10T21:09:43.019452+00:00, invited_users: []}]
flutter: ✅ Desafio oficial encontrado: TESTE - Desafio Oficial Ray Club
flutter: ⚠️ Erro ao converter item de progresso: type 'Null' is not a subtype of type 'String' in type cast
flutter: ✅ 0 registros de progresso encontrados
flutter: 🔍 ChallengeViewModel - Ranking carregado, 0 participantes
flutter: ⚠️ Erro ao converter item de progresso: type 'Null' is not a subtype of type 'String' in type cast
flutter: ✅ 0 registros de progresso encontrados
flutter: 🔍 ChallengeViewModel - Ranking carregado, 0 participantes
flutter: 🔍 ChallengeViewModel - Progresso do usuário: encontrado
flutter: 🔍 ChallengeViewModel - Estado atualizado com desafio oficial
flutter: 🔍 ChallengeViewModel - watchChallengeRanking iniciado para desafio: 1c26ef02-e87d-4fd6-855b-8f968cdad06b, filtro: null
flutter: 🔄 ChallengeRealtimeService - Iniciando observação: challenge_1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 ChallengeViewModel - Stream configurado com o serviço realtime
flutter: 🔍 Iniciando observação do ranking do desafio: 1c26ef02-e87d-4fd6-855b-8f968cdad06b (limit: 50, offset: 0)
flutter: 🧪 Estado na build: isLoading=true, officialChallenge=TESTE - Desafio Oficial Ray Club, errorMessage=null
flutter: 🔍 ChallengeViewModel - Progresso do usuário: encontrado
flutter: 🔍 ChallengeViewModel - Estado atualizado com desafio oficial
flutter: 🔍 ChallengeViewModel - watchChallengeRanking iniciado para desafio: 1c26ef02-e87d-4fd6-855b-8f968cdad06b, filtro: null
flutter: 🔍 ChallengeViewModel - Cancelando subscription anterior
flutter: 🛑 ChallengeRealtimeService - Stream fechado: challenge_1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🛑 ChallengeRealtimeService - Cancelando subscription anterior: challenge_1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔄 ChallengeRealtimeService - Iniciando observação: challenge_1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 ChallengeViewModel - Stream configurado com o serviço realtime
flutter: 🔍 Iniciando observação do ranking do desafio: 1c26ef02-e87d-4fd6-855b-8f968cdad06b (limit: 50, offset: 0)
flutter: 🧪 Estado na build: isLoading=true, officialChallenge=TESTE - Desafio Oficial Ray Club, errorMessage=null
flutter: 🔄 Enviando atualização do ranking: 1 participantes
flutter: 🔄 Enviando atualização do ranking: 1 participantes
flutter: 🔍 ChallengeViewModel - Stream atualizou com 1 participantes
flutter: 🧪 Estado na build: isLoading=false, officialChallenge=TESTE - Desafio Oficial Ray Club, errorMessage=null
flutter: ⏱️ Navegando para detalhes do desafio: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: LayeredAuthGuard - Navegando para: /challenges/:challengeId
flutter: LayeredAuthGuard - Usando estado em cache (última verificação há 0 minutos)
flutter: LayeredAuthGuard - Usuário autenticado, permitindo acesso
flutter: 🔍 ChallengeDetailScreen - build chamado
flutter: 🔍 ChallengeDetailScreen - challengeId: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 ChallengeDetailScreen - challenge carregado: TESTE - Desafio Oficial Ray Club
flutter: 🔍 ChallengeDetailScreen - isLoading: false
flutter: 🔍 ChallengeDetailScreen - progresso: 1 participantes
flutter: 🔍 ChallengeDetailScreen - filtro: null
flutter: 🔍 ChallengeDetailScreen - userId: null
flutter: 🔍 ChallengeLeaderboard - build com 1 participantes
flutter: 🔍 ChallengeLeaderboard - challengeId: 1c26ef02-e87d-4fd6-855b-8f968cdad06b, groupId: null
flutter: 🔍 ChallengeLeaderboard - userId para destacar: null
flutter: 🔍 ChallengeLeaderboard - exibindo 1 de 1 entradas
flutter: 🔍 ChallengeDetailScreen - postFrameCallback para id: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🧪 Estado na build: isLoading=true, officialChallenge=TESTE - Desafio Oficial Ray Club, errorMessage=null
flutter: 🔍 ChallengeDetailScreen - build chamado
flutter: 🔍 ChallengeDetailScreen - challengeId: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 ChallengeDetailScreen - challenge carregado: null
flutter: 🔍 ChallengeDetailScreen - isLoading: true
flutter: 🔍 ChallengeDetailScreen - progresso: 0 participantes
flutter: 🔍 ChallengeDetailScreen - filtro: null
flutter: 🔍 ChallengeDetailScreen - userId: 01d4a292-1873-4af6-948b-a55eed56d6b9
flutter: 🔍 ChallengeDetailScreen - exibindo loading...
flutter: 🔍 ChallengeDetailScreen - build chamado
flutter: 🔍 ChallengeDetailScreen - challengeId: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 ChallengeDetailScreen - challenge carregado: null
flutter: 🔍 ChallengeDetailScreen - isLoading: true
flutter: 🔍 ChallengeDetailScreen - progresso: 0 participantes
flutter: 🔍 ChallengeDetailScreen - filtro: null
flutter: 🔍 ChallengeDetailScreen - userId: 01d4a292-1873-4af6-948b-a55eed56d6b9
flutter: 🔍 ChallengeDetailScreen - exibindo loading...
flutter: 🔍 Buscando progresso para desafio: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: ⚠️ Erro ao converter item de progresso: type 'Null' is not a subtype of type 'String' in type cast
flutter: ✅ 0 registros de progresso encontrados
flutter: ✅ Details loaded for challenge: TESTE - Desafio Oficial Ray Club
flutter: 🔍 ChallengeViewModel - watchChallengeRanking iniciado para desafio: 1c26ef02-e87d-4fd6-855b-8f968cdad06b, filtro: null
flutter: 🔍 ChallengeViewModel - Cancelando subscription anterior
flutter: 🛑 ChallengeRealtimeService - Stream fechado: challenge_1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🛑 ChallengeRealtimeService - Cancelando subscription anterior: challenge_1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔄 ChallengeRealtimeService - Iniciando observação: challenge_1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 ChallengeViewModel - Stream configurado com o serviço realtime
flutter: 🔍 Iniciando observação do ranking do desafio: 1c26ef02-e87d-4fd6-855b-8f968cdad06b (limit: 50, offset: 0)
flutter: 🧪 Estado na build: isLoading=true, officialChallenge=TESTE - Desafio Oficial Ray Club, errorMessage=null
flutter: 🔍 ChallengeDetailScreen - build chamado
flutter: 🔍 ChallengeDetailScreen - challengeId: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 ChallengeDetailScreen - challenge carregado: TESTE - Desafio Oficial Ray Club
flutter: 🔍 ChallengeDetailScreen - isLoading: true
flutter: 🔍 ChallengeDetailScreen - progresso: 0 participantes
flutter: 🔍 ChallengeDetailScreen - filtro: null
flutter: 🔍 ChallengeDetailScreen - userId: 01d4a292-1873-4af6-948b-a55eed56d6b9
flutter: Erro ao carregar grupos: PostgrestException(message: infinite recursion detected in policy for relation "challenge_group_members", code: 42P17, details: Internal Server Error, hint: null)
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
[ERROR:flutter/impeller/entity/contents/text_contents.cc(161)] Break on 'ImpellerValidationBreak' to inspect point of failure: Could not find glyph position in the atlas.
flutter: 🔄 Enviando atualização do ranking: 1 participantes
flutter: 🔍 ChallengeViewModel - Stream atualizou com 1 participantes
flutter: 🧪 Estado na build: isLoading=false, officialChallenge=TESTE - Desafio Oficial Ray Club, errorMessage=null
flutter: 🔍 ChallengeDetailScreen - build chamado
flutter: 🔍 ChallengeDetailScreen - challengeId: 1c26ef02-e87d-4fd6-855b-8f968cdad06b
flutter: 🔍 ChallengeDetailScreen - challenge carregado: TESTE - Desafio Oficial Ray Club
flutter: 🔍 ChallengeDetailScreen - isLoading: false
flutter: 🔍 ChallengeDetailScreen - progresso: 1 participantes
flutter: 🔍 ChallengeDetailScreen - filtro: null
flutter: 🔍 ChallengeDetailScreen - userId: 01d4a292-1873-4af6-948b-a55eed56d6b9
flutter: 🔍 ChallengeLeaderboard - build com 1 participantes
flutter: 🔍 ChallengeLeaderboard - challengeId: 1c26ef02-e87d-4fd6-855b-8f968cdad06b, groupId: null
flutter: 🔍 ChallengeLeaderboard - userId para destacar: 01d4a292-1873-4af6-948b-a55eed56d6b9
flutter: 🔍 ChallengeLeaderboard - exibindo 1 de 1 entradas
flutter: 🔍 ChallengeLeaderboard - usuário atual encontrado na posição 1
flutter: LayeredAuthGuard - Navegando para: /
flutter: LayeredAuthGuard - Usando estado em cache (última verificação há 0 minutos)
flutter: LayeredAuthGuard - Usuário autenticado, permitindo acesso
flutter: LayeredAuthGuard - Navegando para: /workouts
flutter: LayeredAuthGuard - Usando estado em cache (última verificação há 0 minutos)
flutter: LayeredAuthGuard - Usuário autenticado, permitindo acesso
flutter: LayeredAuthGuard - Navegando para: /workouts/history
flutter: LayeredAuthGuard - Usando estado em cache (última verificação há 0 minutos)
flutter: LayeredAuthGuard - Usuário autenticado, permitindo acesso
flutter: 📥 Convertendo do banco: {id: e7225982-3be1-450a-8a37-e0d82a796826, user_id: 01d4a292-1873-4af6-948b-a55eed56d6b9, workout_id: null, workout_name: Teste Manual, workout_type: Funcional, date: 2025-04-13T17:49:56.180656+00:00, duration_minutes: 30, is_completed: true, notes: Teste direto do SQL, created_at: 2025-04-13T17:49:56.180656+00:00}
flutter: 📥 Convertendo do banco: {id: 9fd7dfa6-4a37-4de8-9683-c8d96e473d49, user_id: 01d4a292-1873-4af6-948b-a55eed56d6b9, workout_id: null, workout_name: muscula'çao, workout_type: Funcional, date: 2025-04-13T15:04:54.308615+00:00, duration_minutes: 30, is_completed: true, notes: Intensidade: 1/5, created_at: 2025-04-13T18:04:54.56081+00:00}
flutter: LayeredAuthGuard - Navegando para: /
flutter: LayeredAuthGuard - Usando estado em cache (última verificação há 0 minutos)
flutter: LayeredAuthGuard - Usuário autenticado, permitindo acesso
flutter: LayeredAuthGuard - Navegando para: /progress/day/:day
flutter: LayeredAuthGuard - Usando estado em cache (última verificação há 0 minutos)
flutter: LayeredAuthGuard - Usuário autenticado, permitindo acesso

══╡ EXCEPTION CAUGHT BY IMAGE RESOURCE SERVICE
╞════════════════════════════════════════════════════
The following NetworkImageLoadException was thrown resolving an image codec:
HTTP request failed, statusCode: 404,
https://images.pexels.com/photos/4804076/pexels-photo-4804076.jpeg?auto=compress&cs=tinysrgb&w=800

When the exception was thrown, this was the stack:
#0      NetworkImage._loadAsync (package:flutter/src/painting/_network_image_io.dart:132:9)
<asynchronous suspension>
#1      MultiFrameImageStreamCompleter._handleCodecReady
(package:flutter/src/painting/image_stream.dart:1048:3)
<asynchronous suspension>

Image provider:
  NetworkImage("https://images.pexels.com/photos/4804076/pexels-photo-4804076.jpeg?auto=compress&c
  s=tinysrgb&w=800",
  scale: 1.0)
Image key:
  NetworkImage("https://images.pexels.com/photos/4804076/pexels-photo-4804076.jpeg?auto=compress&c
  s=tinysrgb&w=800",
  scale: 1.0)
══════════════════════════════════════════════════════════════════════════════════════════════════
══

Another exception was thrown: HTTP request failed, statusCode: 404,
https://images.pexels.com/photos/8957028/pexels-photo-8957028.jpeg?auto=compress&cs=tinysrgb&w=800
flutter: LayeredAuthGuard - Navegando para: /workouts/:id
flutter: LayeredAuthGuard - Usando estado em cache (última verificação há 0 minutos)
flutter: LayeredAuthGuard - Usuário autenticado, permitindo acesso# Refatoração da Funcionalidade de Desafios (Challenges)

Este documento descreve as principais mudanças realizadas na refatoração da funcionalidade de Desafios do aplicativo Ray Club, com foco em usabilidade, ranking em tempo real, grupos personalizados e integração com o registro de treinos.

## 🎯 Objetivos da Refatoração

- Posicionar o **ranking** como núcleo motivacional.
- Simplificar o fluxo de participação e visualização do desafio principal.
- Implementar **grupos personalizados** para filtragem de ranking entre amigos.
- Garantir a **atualização em tempo real** do ranking após a conclusão de treinos.
- Melhorar a **robustez e clareza** do código (Modelos, Serviços, ViewModels).
- Assegurar a **consistência** na lógica de pontuação e bônus.

## ✨ Principais Mudanças Implementadas

### 1. Modelos (`models/`)

- **`Challenge.dart`**:
    - Simplificada a desserialização (`fromJson`) para listas (`requirements`, `participants`, `invitedUsers`), assumindo que o backend (Supabase) retorna tipos corretos. Removida lógica complexa de parsing de strings JSON.
    - O campo `points` agora é a fonte primária para pontos de check-in diário, removendo a dependência de chaves específicas dentro de `requirements`.
    - Removido o alias `reward`.
    - Adicionadas/melhoradas docstrings.
- **`ChallengeState`** (dentro de `Challenge.dart`):
    - Adicionado `selectedGroupIdForFilter` para gerenciar o estado do filtro de grupo no ranking.
    - Refatorado `copyWith`, construtores (`.loading`, `.success`, `.error`) e anotações (`@immutable`, `const`) para melhor manutenibilidade e performance.
    - Movida a definição do enum `InviteStatus` para este arquivo para centralização (ou verificada sua existência).

### 2. Serviços (`services/`)

- **`WorkoutChallengeService.dart`**:
    - **Lógica de Pontos Simplificada**:
        - Check-in diário no desafio oficial agora usa `challenge.points` diretamente.
        - Bônus de streak (semanal) agora usa uma constante (`_kWeeklyStreakBonusPoints`) em vez de buscar em `challenge.requirements`. A frequência do bônus também é definida por constante (`_kStreakBonusFrequency`).
        - Check-in em desafios privados usa uma constante (`_kDefaultPrivateChallengePoints`) para simplicidade (poderia ser adaptado para usar `challenge.points` se necessário).
    - **Retorno de Pontos**: O método `processWorkoutCompletion` agora retorna um `Future<int>` com o total de pontos ganhos, permitindo feedback ao usuário.
    - **Otimização**: Reduzido fetching redundante de detalhes do usuário/desafio.
    - **Error Handling**: Melhorado logging de erros e re-lançamento de exceção (`ChallengeProcessingException`) para o ViewModel tratar.

### 3. ViewModels (`viewmodels/`)

- **`UserWorkoutViewModel.dart`**:
    - `completeWorkout`: Captura os pontos retornados por `WorkoutChallengeService.processWorkoutCompletion` e os inclui na mensagem de sucesso para feedback ao usuário (ex: "Você ganhou X pontos!").
- **`ChallengeViewModel.dart`**:
    - **Removida Duplicação**: Removido o método `registerWorkoutCheckIn`, centralizando essa lógica no `WorkoutChallengeService`.
    - **Filtro de Grupo**: Adicionado estado `selectedGroupIdForFilter` e método `filterRankingByGroup(String? groupId)` para carregar e exibir o ranking filtrado.
    - **Carregamento Distinto**: Refatorados `loadOfficialChallenge` e `loadChallengeDetails` para carregar o desafio oficial/específico e seu ranking (geral ou filtrado), atualizando o estado (`officialChallenge`, `selectedChallenge`, `progressList`, `userProgress`, `selectedGroupIdForFilter`).
    - **Ranking Real-time**: O método `watchChallengeRanking` agora aceita `filterByGroupId` e se inscreve no stream correto (`watchGroupRanking` ou `watchChallengeParticipants`) para atualizações em tempo real, cancelando a subscrição anterior ao mudar o filtro.
- **`ChallengeGroupViewModel.dart`**:
    - Adicionados métodos (via dialogs em `challenge_group_detail_screen.dart`) para `updateGroup` e `deleteGroup`, permitindo edição e exclusão de grupos pelo criador.

### 4. Telas (`screens/`)

- **`challenge_detail_screen.dart`**:
    - **Layout Refatorado**: A ordem do conteúdo foi alterada para priorizar o Ranking:
        1. Cartão de Progresso do Usuário (se logado)
        2. Seção de Ranking (com filtro e leaderboard)
        3. Descrição
        4. Período
        5. Regras
    - **Filtro de Grupo**: Adicionado um `DropdownButton` acima do ranking, permitindo ao usuário selecionar um de seus grupos (`userGroupsProvider`) para filtrar a lista (`ChallengeViewModel.filterRankingByGroup`).
    - **Ranking Completo**: Adicionado botão "Ver Ranking Completo" que navega para `ChallengeRankingScreen`.
    - **Leaderboard**: O widget `ChallengeLeaderboard` agora recebe a lista de ranking (`rankingList`) e o `groupId` (opcional) diretamente do `ChallengeViewModel` via `challengeState`.
- **`challenge_groups_screen.dart`**:
    - Confirmado/adicionado `FloatingActionButton` para chamar `_createGroup` (via dialog).
- **`challenge_group_detail_screen.dart`**:
    - Adicionado `PopupMenuButton` na `AppBar` com opções "Editar Grupo" e "Excluir Grupo", visíveis apenas para o criador (`isCreator`), que chamam `_showEditGroupDialog` e `_showDeleteGroupDialog` respectivamente.

### 5. Widgets (`widgets/`)

- **`ChallengeLeaderboard.dart`**:
    - Refatorado para ser mais reutilizável.
    - Removeu a busca direta de dados (providers).
    - Recebe `rankingList`, `challengeId`, `groupId` (opcional), `userId` e `maxEntriesToShow` como parâmetros.
    - Exibe a lista de ranking fornecida, aplicando destaque para o `userId` atual.

## 🚀 Próximos Passos / Considerações

- **Testes**: Adicionar/atualizar testes unitários para ViewModels/Serviços e testes de widget para as telas modificadas.
- **Repositório**: Implementar `ChallengeRepository.watchGroupRanking(String groupId)` se ainda não existir, para suportar o ranking filtrado em tempo real.
- **UI/UX**:
    - Refinar a UI do filtro de grupo.
    - Considerar extrair o "Challenge Summary Card" para um widget dedicado em `challenge_detail_screen.dart`.
    - Melhorar o feedback visual durante o carregamento de rankings filtrados.
- **Error Handling**: Expandir o tratamento de erros, especialmente para falhas em atualizações de desafio em background.
- **Docstrings**: Revisar e adicionar docstrings (`///`) em todos os métodos e classes públicas modificadas/adicionadas. 