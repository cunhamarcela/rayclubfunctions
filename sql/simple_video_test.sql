-- Teste simples para verificar o que o usuário expert deveria ver

-- 1. CONTAR vídeos total
SELECT 'VÍDEOS TOTAL NO BANCO:' as tipo, COUNT(*) as total
FROM workout_videos;

-- 2. CONTAR por tipo
SELECT 
    'Expert-only (parceiros):' as tipo,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = true;

SELECT 
    'Públicos:' as tipo,
    COUNT(*) as total
FROM workout_videos 
WHERE requires_expert_access = false OR requires_expert_access IS NULL;

-- 3. VERIFICAR se há vídeos públicos (que TODOS deveriam ver)
SELECT 
    title,
    instructor_name,
    requires_expert_access
FROM workout_videos 
WHERE requires_expert_access = false OR requires_expert_access IS NULL
ORDER BY instructor_name, title
LIMIT 10;

-- 4. VERIFICAR estrutura da tabela (campos que o Flutter pode estar usando)
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'workout_videos' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 5. INSTRUÇÕES PARA FLUTTER
SELECT 'TESTE NO FLUTTER:' as instrucoes;
SELECT 'Cole este código no seu Flutter e me mostre o resultado:' as passo1;

SELECT '
// TESTE 1: Contar todos os vídeos (deveria ser filtrado pela RLS)
final allVideos = await supabase.from("workout_videos").select().count();
print("Total vídeos visíveis: \${allVideos.count}");

// TESTE 2: Verificar se usuário está autenticado  
final user = supabase.auth.currentUser;
print("Usuário logado: \${user?.id}");
print("Email: \${user?.email}");

// TESTE 3: Verificar nível do usuário
final userLevel = await supabase
  .from("user_progress_level")
  .select("current_level, level_expires_at")
  .eq("user_id", user!.id)
  .single();
print("Nível do usuário: \${userLevel}");

// TESTE 4: Listar primeiros 5 vídeos visíveis
final videos = await supabase
  .from("workout_videos")
  .select("title, instructor_name, requires_expert_access")
  .limit(5);
print("Primeiros 5 vídeos:");
for (var video in videos) {
  print("- \${video['title']} (\${video['instructor_name']}) - Expert: \${video['requires_expert_access']}");
}
' as codigo_teste; 