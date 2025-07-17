-- 🔧 CORREÇÃO DE REPLICA IDENTITY PARA TESTES
-- 📋 Resolve erro de DELETE no Supabase

-- ======================================
-- 🛠️ CONFIGURAR REPLICA IDENTITY
-- ======================================

-- Configurar replica identity para workout_records
ALTER TABLE workout_records REPLICA IDENTITY FULL;

-- Configurar replica identity para challenge_check_ins  
ALTER TABLE challenge_check_ins REPLICA IDENTITY FULL;

-- Configurar replica identity para challenge_progress
ALTER TABLE challenge_progress REPLICA IDENTITY FULL;

-- Configurar replica identity para challenge_participants
ALTER TABLE challenge_participants REPLICA IDENTITY FULL;

-- ======================================
-- ✅ VERIFICAR CONFIGURAÇÕES
-- ======================================

DO $$
BEGIN
    RAISE NOTICE '✅ REPLICA IDENTITY configurado para todas as tabelas';
    RAISE NOTICE '🎯 Agora você pode executar os scripts de teste!';
    RAISE NOTICE '';
    RAISE NOTICE '📋 PRÓXIMOS PASSOS:';
    RAISE NOTICE '1. Execute este script primeiro';
    RAISE NOTICE '2. Execute: test_complete_ranking_system_FINAL.sql';
    RAISE NOTICE '3. Execute: quick_ranking_health_check.sql';
    RAISE NOTICE '';
    RAISE NOTICE '🚀 Scripts de teste prontos para execução!';
END $$; 