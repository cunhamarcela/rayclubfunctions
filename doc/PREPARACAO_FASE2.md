# Preparação para Fase 2 - Ray Club App

Antes de iniciarmos a Fase 2 do desenvolvimento do Ray Club App, precisamos documentar e entender completamente a estrutura de banco de dados existente no Supabase. Este documento descreve os passos necessários para extrair e documentar o esquema do banco de dados.

## 1. Extração do Esquema do Supabase

Criamos ferramentas específicas para extrair e documentar o esquema do banco de dados Supabase. Siga estes passos:

### 1.1 Extraia as informações do esquema usando o SQL Editor do Supabase

1. Acesse o painel do Supabase do projeto Ray Club App
2. Navegue até **SQL Editor**
3. Crie uma nova consulta e cole o conteúdo do arquivo `scripts/extract_supabase_schema.sql`
4. Execute o script clicando em **Run**
5. Para cada tabela de resultados:
   - Clique no botão **Download** para baixar os resultados em formato CSV
   - Salve os arquivos CSV em uma pasta dedicada (ex: `supabase_schema_csvs`)

### 1.2 Gere a documentação do esquema automaticamente

Depois de baixar os arquivos CSV, use o script Dart que criamos para gerar automaticamente a documentação em formato Markdown:

```bash
# Instale a dependência path se ainda não estiver instalada
flutter pub add path

# Execute o script de geração de documentação
dart scripts/create_doc_from_schema.dart supabase_schema_csvs doc/SUPABASE_SCHEMA.md
```

Este script processará todos os CSVs na pasta especificada e gerará um documento Markdown estruturado com todas as informações do esquema.

## 2. Análise do Esquema

Após gerar a documentação, faça uma análise cuidadosa para:

1. **Verificar completude**: Todas as tabelas necessárias para a Fase 2 existem?
2. **Identificar inconsistências**: Existem problemas de design ou estrutura?
3. **Verificar relações**: As relações entre tabelas estão corretamente definidas?
4. **Confirmar tipos de dados**: Os tipos de dados são apropriados para cada coluna?
5. **Revisar segurança**: As políticas RLS estão configuradas adequadamente?

### 2.1 Lista de Verificação para Análise

Use esta lista para revisar o esquema gerado:

- [ ] Todas as tabelas listadas em "Estruturas Esperadas" do arquivo `doc/SUPABASE_SCHEMA_GUIDE.md` existem?
- [ ] Todas as relações necessárias estão implementadas com chaves estrangeiras?
- [ ] Todas as tabelas têm chaves primárias adequadas?
- [ ] As tabelas usam UUID para IDs quando apropriado?
- [ ] Existem índices para colunas frequentemente pesquisadas?
- [ ] As políticas RLS estão configuradas para proteger dados sensíveis?
- [ ] Existem triggers para manter a integridade dos dados (timestamps, contagem de participantes, etc.)?
- [ ] Os buckets de storage necessários estão configurados?

## 3. Criação de Scripts SQL para Fase 2

Com base na análise, crie scripts SQL para:

1. **Criar tabelas ausentes**: Se alguma tabela necessária para a Fase 2 estiver faltando
2. **Alterar tabelas existentes**: Se alguma tabela precisar de modificações
3. **Adicionar ou modificar triggers**: Para implementar lógica de negócios no banco de dados
4. **Configurar políticas de segurança**: Para proteger dados sensíveis
5. **Criar índices**: Para otimizar consultas frequentes

Salve os scripts em arquivos separados na pasta `scripts/supabase`:

- `scripts/supabase/create_missing_tables.sql`
- `scripts/supabase/alter_existing_tables.sql`
- `scripts/supabase/create_triggers.sql`
- `scripts/supabase/setup_policies.sql`
- `scripts/supabase/create_indexes.sql`

## 4. Validação dos Scripts

Antes de aplicar os scripts no ambiente de produção:

1. **Teste em ambiente de desenvolvimento**: Aplique os scripts em um banco Supabase de desenvolvimento
2. **Verifique a migração de dados**: Certifique-se de que os dados existentes serão preservados
3. **Teste as consultas**: Verifique se as consultas esperadas funcionam corretamente
4. **Valide a segurança**: Teste diferentes perfis de usuário para garantir que as políticas RLS funcionem

## 5. Documentação para Desenvolvedores

Atualize a documentação para desenvolvedores, incluindo:

1. **Diagrama ER**: Crie ou atualize um diagrama de Entidade-Relacionamento
2. **Guia de Consultas**: Documente consultas comuns que serão usadas na aplicação
3. **Guia de Acesso**: Documente as permissões e políticas de acesso aos dados

## 6. Checklist Final Antes da Fase 2

- [ ] Esquema do banco de dados documentado
- [ ] Scripts SQL para correções/adições criados e testados
- [ ] Documentação para desenvolvedores atualizada
- [ ] Ambientes de desenvolvimento e testes configurados
- [ ] Equipe de desenvolvimento informada sobre a estrutura do banco de dados

---

Ao completar estes passos, teremos uma compreensão completa do esquema atual do banco de dados e um plano claro para qualquer modificação necessária antes de iniciar a implementação da Fase 2.

## Próximos Passos

Após a documentação e análise do esquema, seguiremos para a implementação da Fase 2, que inclui:

1. **Sistema de Perfil Completo**: Implementação de funcionalidades de perfil de usuário
2. **Dashboard e Progresso Funcional**: Sistema para rastreamento de água, gráficos e métricas
3. **Sistema de Desafios Real**: Implementação do sistema de check-in e ranking 