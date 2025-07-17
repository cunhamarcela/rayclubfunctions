# Correção dos Problemas de Perfil

## Problemas Identificados

### 1. Upload de Foto de Perfil
**Problema**: A função de upload de foto não está funcionando corretamente.

**Possíveis Causas**:
- Bucket `profile-images` pode não existir no Supabase Storage
- Políticas RLS podem estar bloqueando o upload
- Função RPC `update_user_photo_url` pode não estar aplicada

### 2. Salvamento de Informações do Perfil
**Problema**: As atualizações do perfil não estão sendo salvas.

**Possíveis Causas**:
- Políticas RLS conflitantes na tabela `profiles`
- Campos ausentes na tabela
- Problema na validação de dados

## Soluções Implementadas

### 1. Verificar e Criar Bucket de Storage

```sql
-- Criar bucket se não existir
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO NOTHING;

-- Política para permitir upload de imagens
CREATE POLICY "Users can upload profile images" ON storage.objects
FOR INSERT WITH CHECK (
    bucket_id = 'profile-images' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Política para visualizar imagens (público)
CREATE POLICY "Profile images are publicly accessible" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-images');

-- Política para atualizar imagens próprias
CREATE POLICY "Users can update their profile images" ON storage.objects
FOR UPDATE USING (
    bucket_id = 'profile-images' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Política para deletar imagens próprias
CREATE POLICY "Users can delete their profile images" ON storage.objects
FOR DELETE USING (
    bucket_id = 'profile-images' 
    AND auth.uid()::text = (storage.foldername(name))[1]
);
```

### 2. Corrigir Políticas RLS da Tabela Profiles

```sql
-- Remover políticas conflitantes
DROP POLICY IF EXISTS "Allow individuals update access to own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can update profiles" ON public.profiles;
DROP POLICY IF EXISTS "Allow admin full access" ON public.profiles;

-- Política simples para atualização de perfil próprio
CREATE POLICY "profiles_update_own" ON public.profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- Política para leitura de qualquer perfil
CREATE POLICY "profiles_select_any" ON public.profiles
FOR SELECT
TO authenticated
USING (true);
```

### 3. Garantir que a Função RPC Existe

```sql
-- Função para atualizar foto de perfil
CREATE OR REPLACE FUNCTION public.update_user_photo_url(
    p_user_id uuid, 
    p_photo_url text
)
RETURNS jsonb AS $$
DECLARE
    v_result jsonb;
BEGIN
    -- Verificar se o usuário está atualizando seu próprio perfil
    IF auth.uid() != p_user_id THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Você não tem permissão para atualizar este perfil'
        );
    END IF;
    
    -- Atualizar foto de perfil
    UPDATE public.profiles
    SET 
        photo_url = p_photo_url,
        updated_at = now()
    WHERE id = p_user_id;
    
    IF FOUND THEN
        v_result := jsonb_build_object(
            'success', true,
            'message', 'Foto de perfil atualizada com sucesso',
            'photo_url', p_photo_url
        );
    ELSE
        v_result := jsonb_build_object(
            'success', false,
            'message', 'Perfil não encontrado'
        );
    END IF;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Dar permissão para usuários autenticados
GRANT EXECUTE ON FUNCTION public.update_user_photo_url(uuid, text) TO authenticated;
```

### 4. Verificar Campos da Tabela Profiles

```sql
-- Verificar se todos os campos necessários existem
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS gender TEXT,
ADD COLUMN IF NOT EXISTS birth_date DATE,
ADD COLUMN IF NOT EXISTS instagram TEXT,
ADD COLUMN IF NOT EXISTS daily_water_goal INTEGER DEFAULT 8,
ADD COLUMN IF NOT EXISTS daily_workout_goal INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS weekly_workout_goal INTEGER DEFAULT 5,
ADD COLUMN IF NOT EXISTS weight_goal DECIMAL,
ADD COLUMN IF NOT EXISTS height DECIMAL,
ADD COLUMN IF NOT EXISTS current_weight DECIMAL,
ADD COLUMN IF NOT EXISTS preferred_workout_types TEXT[],
ADD COLUMN IF NOT EXISTS photo_url TEXT;
```

## Correções no Código Dart

### 1. Melhorar Tratamento de Erros no Repository

```dart
@override
Future<String> updateProfilePhoto(String userId, String filePath) async {
  try {
    final authUserId = _client.auth.currentUser?.id;
    if (authUserId == null) {
      throw AppAuthException(message: 'Usuário não autenticado');
    }
    
    if (authUserId != userId) {
      throw AppAuthException(message: 'Não é possível atualizar foto de outro usuário');
    }
    
    // Verificar se o arquivo existe
    final file = File(filePath);
    if (!await file.exists()) {
      throw AppException(message: 'Arquivo de imagem não encontrado');
    }
    
    // Nome único para o arquivo
    final fileExt = path.extension(filePath);
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}$fileExt';
    
    debugPrint('🔄 Fazendo upload de foto: $fileName');
    
    // Upload da imagem
    await _client.storage
        .from('profile-images')
        .upload(fileName, file);
        
    // Obter URL pública
    final imageUrl = _client.storage
        .from('profile-images')
        .getPublicUrl(fileName);
    
    debugPrint('✅ Upload concluído. URL: $imageUrl');
    
    // Atualizar perfil usando RPC
    final result = await _client.rpc('update_user_photo_url', params: {
      'p_user_id': userId,
      'p_photo_url': imageUrl,
    });
    
    if (result['success'] != true) {
      throw AppException(message: result['message'] ?? 'Erro ao atualizar foto');
    }
    
    return imageUrl;
  } catch (e, stackTrace) {
    debugPrint('❌ Erro ao atualizar foto: $e');
    throw _handleError(e, stackTrace, 'Erro ao atualizar foto de perfil');
  }
}
```

### 2. Melhorar Validação no ViewModel

```dart
Future<void> updateProfile({
  String? name,
  String? bio,
  List<String>? goals,
  String? phone,
  String? gender,
  DateTime? birthDate,
  String? instagram,
}) async {
  final currentState = state;
  if (currentState is! BaseStateData<Profile>) {
    state = const BaseState.error(message: 'Perfil não disponível para atualização');
    return;
  }
  
  final currentProfile = currentState.data;
  
  try {
    state = const BaseState.loading();
    
    // Validar dados antes de enviar
    if (phone != null && phone.isNotEmpty && !_isValidPhone(phone)) {
      throw AppException(message: 'Número de telefone inválido');
    }
    
    final updatedProfile = await _repository.updateProfile(
      currentProfile.copyWith(
        name: name ?? currentProfile.name,
        bio: bio ?? currentProfile.bio,
        goals: goals ?? currentProfile.goals,
        phone: phone ?? currentProfile.phone,
        gender: gender ?? currentProfile.gender,
        birthDate: birthDate ?? currentProfile.birthDate,
        instagram: instagram ?? currentProfile.instagram,
      ),
    );
    
    state = BaseState.data(data: updatedProfile);
  } catch (e, stackTrace) {
    state = handleError(e, stackTrace: stackTrace);
    logError('Erro ao atualizar perfil', error: e, stackTrace: stackTrace);
    rethrow; // Permitir que a UI trate o erro
  }
}

bool _isValidPhone(String phone) {
  final numericPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
  return numericPhone.length >= 10 && numericPhone.length <= 11;
}
```

### 3. Melhorar Feedback na UI

```dart
Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }
  
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });
  
  try {
    await ref.read(profileViewModelProvider.notifier).updateProfile(
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      gender: _gender,
      birthDate: _birthDate,
      instagram: _instagramController.text.trim().isNotEmpty ? _instagramController.text.trim() : null,
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      context.router.maybePop();
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Erro ao atualizar perfil: ${e.toString()}';
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
```

## Próximos Passos

1. **Aplicar o script SQL** para criar bucket e corrigir políticas
2. **Atualizar o código Dart** com as melhorias propostas
3. **Testar o upload de foto** com um usuário autenticado
4. **Testar o salvamento de perfil** com dados válidos
5. **Verificar logs** para identificar problemas específicos

## Debug Adicional

Para identificar problemas específicos, adicionar logs detalhados:

```dart
debugPrint('🔍 Dados do perfil sendo salvos:');
debugPrint('   - Nome: $name');
debugPrint('   - Telefone: $phone');
debugPrint('   - Gênero: $gender');
debugPrint('   - Data nascimento: $birthDate');
debugPrint('   - Instagram: $instagram');
``` 