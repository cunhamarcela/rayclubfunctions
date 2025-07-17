-- ========================================
-- SISTEMA RLS AUTOMÁTICO - SEM MUDANÇAS NO FLUTTER
-- ========================================

-- 1. REMOVER POLÍTICAS ANTIGAS
DROP POLICY IF EXISTS "Apenas experts podem ver vídeos" ON workout_videos;
DROP POLICY IF EXISTS "Controle de acesso aos vídeos dos parceiros" ON workout_videos;
DROP POLICY IF EXISTS "Usuários não autenticados veem apenas vídeos públicos" ON workout_videos;
DROP POLICY IF EXISTS "Vídeos são públicos" ON workout_videos;

-- 2. HABILITAR RLS
ALTER TABLE workout_videos ENABLE ROW LEVEL SECURITY;

-- 3. CRIAR POLÍTICA QUE FUNCIONA AUTOMATICAMENTE
CREATE POLICY "Auto: Apenas experts veem vídeos" ON workout_videos
    FOR SELECT USING (
        -- Verificar se o usuário autenticado (auth.uid()) é expert na tabela user_progress_level
        EXISTS (
            SELECT 1 
            FROM user_progress_level upl
            WHERE upl.user_id = auth.uid()
              AND upl.current_level = 'expert'
              AND (upl.level_expires_at IS NULL OR upl.level_expires_at > NOW())
        )
    );

-- 4. FUNÇÃO DE TESTE PARA O SQL EDITOR (já que auth.uid() não funciona aqui)
CREATE OR REPLACE FUNCTION test_rls_for_user(test_user_id UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
    video_count INTEGER;
    user_level TEXT;
    expires_at TIMESTAMP;
BEGIN
    -- Buscar dados do usuário
    SELECT current_level, level_expires_at
    INTO user_level, expires_at
    FROM user_progress_level
    WHERE user_id = test_user_id;
    
    -- Simular a política RLS
    IF user_level = 'expert' AND (expires_at IS NULL OR expires_at > NOW()) THEN
        SELECT COUNT(*) INTO video_count FROM workout_videos;
    ELSE
        video_count := 0;
    END IF;
    
    result := json_build_object(
        'user_id', test_user_id,
        'user_level', COALESCE(user_level, 'not_found'),
        'level_expires_at', expires_at,
        'videos_visible', video_count,
        'is_expert', (user_level = 'expert' AND (expires_at IS NULL OR expires_at > NOW())),
        'policy_result', CASE 
            WHEN user_level = 'expert' AND (expires_at IS NULL OR expires_at > NOW()) THEN 'ALLOWED - Vê todos os vídeos'
            WHEN user_level = 'basic' THEN 'BLOCKED - Usuário basic não vê vídeos'
            WHEN user_level IS NULL THEN 'BLOCKED - Usuário não cadastrado'
            WHEN expires_at <= NOW() THEN 'BLOCKED - Acesso expert expirado'
            ELSE 'BLOCKED - Motivo desconhecido'
        END
    );
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. TESTAR COM USUÁRIOS REAIS
SELECT 
    '=== TESTE AUTOMÁTICO COM USUÁRIOS EXPERT ===' as info;

-- Testar com usuários expert
SELECT test_rls_for_user(user_id) as resultado
FROM user_progress_level 
WHERE current_level = 'expert' 
LIMIT 3;

SELECT 
    '=== TESTE AUTOMÁTICO COM USUÁRIOS BASIC ===' as info;

-- Testar com usuários basic
SELECT test_rls_for_user(user_id) as resultado
FROM user_progress_level 
WHERE current_level = 'basic' 
LIMIT 3;

-- 6. RESUMO DO SISTEMA
SELECT 
    '=== RESUMO DO SISTEMA RLS AUTOMÁTICO ===' as info;

SELECT 
    'Total de vídeos na tabela' as metrica,
    COUNT(*)::text as valor
FROM workout_videos
UNION ALL
SELECT 
    'Usuários expert',
    COUNT(*)::text
FROM user_progress_level 
WHERE current_level = 'expert'
UNION ALL
SELECT 
    'Usuários basic',
    COUNT(*)::text
FROM user_progress_level 
WHERE current_level = 'basic'
UNION ALL
SELECT 
    'Status RLS',
    CASE WHEN rowsecurity THEN 'HABILITADO' ELSE 'DESABILITADO' END
FROM pg_tables 
WHERE tablename = 'workout_videos';

-- 7. VERIFICAR POLÍTICA CRIADA
SELECT 
    '=== POLÍTICA RLS ATIVA ===' as info;

SELECT 
    policyname,
    cmd,
    qual
FROM pg_policies 
WHERE tablename = 'workout_videos';

-- 8. INSTRUÇÕES PARA O FLUTTER
SELECT 
    '=== INSTRUÇÕES PARA USO ===' as info;

/*
=== COMO USAR NO FLUTTER ===

NENHUMA MUDANÇA NECESSÁRIA NO CÓDIGO!

O código atual vai funcionar automaticamente:

```dart
// Este código vai funcionar automaticamente agora:
final videos = await supabase.from('workout_videos').select();

// Para usuários EXPERT: retorna todos os 40 vídeos
// Para usuários BASIC: retorna lista vazia []
// Para não logados: retorna lista vazia []
```

O Supabase vai aplicar a política RLS automaticamente baseado em:
- auth.uid() do usuário logado
- Nível do usuário na tabela user_progress_level
- Data de expiração (se aplicável)

=== COMPORTAMENTO ESPERADO ===

1. USUÁRIO EXPERT LOGADO:
   - supabase.from('workout_videos').select() → retorna todos os vídeos
   
2. USUÁRIO BASIC LOGADO:
   - supabase.from('workout_videos').select() → retorna []
   
3. USUÁRIO NÃO LOGADO:
   - supabase.from('workout_videos').select() → retorna []
   
4. USUÁRIO NÃO CADASTRADO NA TABELA:
   - supabase.from('workout_videos').select() → retorna []

=== VANTAGENS ===

✅ Zero mudanças no código Flutter
✅ Funciona automaticamente
✅ Segurança total no banco
✅ Transparente para o desenvolvedor
✅ Performance otimizada
*/

-- 9. USER_IDS PARA TESTE MANUAL NO FLUTTER
SELECT 
    '=== IDs PARA TESTE NO APP ===' as info;

SELECT 
    'EXPERT - Deve ver todos os vídeos:' as tipo,
    user_id
FROM user_progress_level 
WHERE current_level = 'expert' 
LIMIT 3;

SELECT 
    'BASIC - Deve ver 0 vídeos:' as tipo,
    user_id
FROM user_progress_level 
WHERE current_level = 'basic' 
LIMIT 3; 