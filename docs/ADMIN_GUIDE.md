# Guia de Administração - Ray Club App

Este guia explica como configurar e gerenciar administradores no Ray Club App.

## Definindo Administradores

No Ray Club App, administradores são usuários com privilégios especiais que podem gerenciar benefícios, incluindo a capacidade de modificar datas de expiração de cupons e visualizar todos os benefícios resgatados por todos os usuários.

### 1. Pré-requisitos

- Acesso ao console do Supabase
- As migrações SQL do arquivo `docs/supabase/admin_setup.sql` já devem ter sido aplicadas

### 2. Definir o Primeiro Administrador

Para definir o primeiro administrador, siga estes passos:

1. Acesse o console do Supabase
2. Vá para a seção "SQL Editor"
3. Execute o seguinte comando SQL, substituindo "EMAIL_DO_ADMIN" pelo email do usuário que será administrador:

```sql
UPDATE users 
SET is_admin = TRUE 
WHERE email = 'EMAIL_DO_ADMIN';
```

4. Verifique se a atualização foi bem-sucedida com:

```sql
SELECT id, email, is_admin FROM users WHERE is_admin = TRUE;
```

### 3. Definir Administradores Adicionais (através da Interface de Administração)

Uma vez que você tenha pelo menos um administrador, ele pode definir outros administradores através da interface administrativa do app:

1. Entre no app com a conta de administrador
2. Acesse a tela de Benefícios
3. Toque no ícone de administração no canto superior direito
4. Na tela de administração, acesse a guia "Usuários" (a ser implementada)
5. Localize o usuário que deseja promover e toque em "Tornar Admin"

### 4. Definir Administradores via SQL (console do Supabase)

Alternativamente, você pode definir administradores diretamente via SQL usando a função `set_user_as_admin`:

```sql
-- Para tornar um usuário administrador (substituir ID_DO_USUARIO pelo UUID do usuário)
SELECT set_user_as_admin('ID_DO_USUARIO', TRUE);

-- Para remover privilégios de administrador
SELECT set_user_as_admin('ID_DO_USUARIO', FALSE);
```

## Recursos de Administração

### Gerenciamento de Benefícios

Como administrador, você pode:

1. **Ver todos os benefícios disponíveis**
   - Incluindo aqueles ainda não disponíveis para os usuários

2. **Modificar datas de expiração de benefícios**
   - Definir novas datas de expiração
   - Remover datas de expiração (tornando benefícios permanentes)

3. **Ver todos os benefícios resgatados**
   - Ver resgates de todos os usuários
   - Filtrar por status (ativo, usado, expirado, cancelado)

4. **Estender validade de cupons resgatados**
   - Reativar cupons expirados
   - Modificar datas de expiração de cupons já resgatados pelos usuários

## Solução de Problemas

### Verificar Status de Administrador

Para verificar se um usuário é administrador:

```sql
SELECT id, email, is_admin FROM users WHERE email = 'EMAIL_DO_USUARIO';
```

### Restaurar Acesso de Administrador

Se todos os administradores perderem acesso, execute:

```sql
-- Conferir usuários atuais
SELECT id, email FROM users;

-- Definir um administrador de emergência (substitua pelo ID apropriado)
UPDATE users SET is_admin = TRUE WHERE id = 'ID_DO_USUARIO';
```

## Considerações de Segurança

- O status de administrador é protegido por Row Level Security (RLS) no Supabase
- Apenas administradores podem modificar o status de administrador de outros usuários
- Todas as operações administrativas são registradas nos logs do sistema
- Quando implementar uma solução de produção, considere adicionar autenticação de dois fatores (2FA) para administradores

## Verificações Regulares

Recomendamos realizar verificações periódicas dos privilégios administrativos:

```sql
-- Listar todos os administradores
SELECT id, email, created_at FROM users WHERE is_admin = TRUE;
``` 