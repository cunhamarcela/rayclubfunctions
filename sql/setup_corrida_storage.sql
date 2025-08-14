-- ===================================================
-- SCRIPT: Configurar Storage para Planilhas de Corrida
-- DATA: 2025-01-21
-- OBJETIVO: Configurar permissões e políticas para PDFs de corrida
-- ===================================================

-- Verificar se o bucket 'materials' existe, se não, criar
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM storage.buckets WHERE id = 'materials'
    ) THEN
        INSERT INTO storage.buckets (id, name, public) 
        VALUES ('materials', 'materials', false);
        
        RAISE NOTICE 'Bucket materials criado com sucesso!';
    ELSE
        RAISE NOTICE 'Bucket materials já existe.';
    END IF;
END $$;

-- Criar política de leitura para materiais de treino (se não existir)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND schemaname = 'storage'
        AND policyname = 'Allow authenticated users to read workout materials'
    ) THEN
        CREATE POLICY "Allow authenticated users to read workout materials" 
        ON storage.objects FOR SELECT 
        USING (
            bucket_id = 'materials' 
            AND auth.role() = 'authenticated'
            AND (
                name LIKE 'corrida/%' 
                OR name LIKE 'musculacao/%'
                OR name LIKE 'nutrition/%'
            )
        );
        
        RAISE NOTICE 'Política de leitura para materiais criada!';
    ELSE
        RAISE NOTICE 'Política de leitura para materiais já existe.';
    END IF;
END $$;

-- Listar arquivos existentes no bucket materials (para verificação)
SELECT 
    name,
    bucket_id,
    created_at,
    updated_at
FROM storage.objects 
WHERE bucket_id = 'materials'
ORDER BY created_at DESC;

-- Verificar políticas ativas no storage
SELECT 
    policyname,
    tablename,
    schemaname,
    permissive,
    roles,
    cmd,
    qual
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects';

-- Verificar se os arquivos de corrida estão no storage
SELECT 
    name,
    bucket_id,
    owner,
    created_at
FROM storage.objects 
WHERE bucket_id = 'materials' 
  AND name LIKE 'corrida/%';

RAISE NOTICE 'Configuração do storage para corrida concluída!';
RAISE NOTICE 'Certifique-se de que os arquivos 5km.pdf e 10km.pdf estão uploadeados na pasta corrida/ do bucket materials.'; 