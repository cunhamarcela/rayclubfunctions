# Teste de Navegação - Vídeos de Treino

## 🧪 Como Testar a Navegação Completa

### 1. **Preparação do Banco de Dados**

Primeiro, execute os scripts SQL no Supabase:

```sql
-- 1. Criar as tabelas
-- Execute: sql/migrations/create_workout_videos_tables.sql

-- 2. Inserir os dados dos vídeos
-- Execute: sql/migrations/insert_partner_workout_videos.sql
```

### 2. **Fluxo de Navegação para Testar**

#### **Caminho 1: Da Tela de Treinos**
1. Abra o app e faça login
2. Navegue para a aba "Treinos" (segunda aba na bottom navigation)
3. Você verá as categorias de treino em cards
4. Procure pelas novas categorias dos parceiros:
   - **Musculação** (ícone de halteres)
   - **Pilates** (ícone de spa)
   - **Funcional** (ícone de artes marciais)
   - **Corrida** (ícone de corrida)
   - **Fisioterapia** (ícone de cura)
5. Clique em uma categoria (ex: Musculação)
6. Você será direcionado para a lista de vídeos dessa categoria

#### **Caminho 2: Na Tela de Vídeos**
1. Na tela de vídeos, você verá:
   - Filtros no topo (Todos, Recomendados, Iniciante, Intermediário, Avançado)
   - Vídeos organizados por nível de dificuldade
   - Cards com thumbnail, título, instrutor e duração
2. Clique em qualquer vídeo
3. Você será direcionado para o player de vídeo

#### **Caminho 3: No Player de Vídeo**
1. O player deve mostrar:
   - Informações do vídeo no topo
   - Player do YouTube no centro
   - Botões de ação na parte inferior (Favoritar e Concluir)
2. Teste os controles do player:
   - Play/Pause
   - Avançar/Retroceder 10s
   - Tela cheia
3. Teste o botão voltar para retornar à lista

### 3. **Pontos de Verificação**

✅ **Tela de Categorias**
- [ ] As novas categorias aparecem com ícones e cores corretas
- [ ] O contador mostra "X vídeos" ao invés de "X exercícios" para categorias de parceiros
- [ ] Clicar em uma categoria navega corretamente

✅ **Tela de Vídeos**
- [ ] Os vídeos são carregados da categoria correta
- [ ] Os filtros funcionam corretamente
- [ ] As seções por dificuldade são exibidas
- [ ] Os cards mostram todas as informações (thumbnail, título, duração, etc.)
- [ ] Badges de "Novo" e "Popular" aparecem quando aplicável

✅ **Player de Vídeo**
- [ ] O vídeo carrega e reproduz corretamente
- [ ] As informações do vídeo são exibidas
- [ ] Os controles do player funcionam
- [ ] O botão voltar retorna à lista
- [ ] Os botões de ação mostram feedback (snackbar)

### 4. **URLs de Teste**

Se precisar testar diretamente via URL:
- Lista de vídeos: `/workouts/videos/bodybuilding`
- Player de vídeo: `/workouts/video/{video_id}`

### 5. **Possíveis Problemas e Soluções**

**Problema**: Categorias não aparecem
- **Solução**: Verificar se as categorias foram adicionadas no banco de dados

**Problema**: Vídeos não carregam
- **Solução**: Verificar se os scripts SQL foram executados corretamente

**Problema**: Player não funciona
- **Solução**: Verificar conexão com internet e URLs do YouTube

**Problema**: Navegação não funciona
- **Solução**: Executar `flutter pub run build_runner build` novamente

### 6. **Dados de Teste**

Os vídeos inseridos usam a URL de exemplo: `https://www.youtube.com/watch?v=Ej0Tz0Ym5Ow`

Para testar com vídeos reais, atualize as URLs no banco de dados:
```sql
UPDATE workout_videos 
SET youtube_url = 'URL_REAL_DO_YOUTUBE' 
WHERE id = 'ID_DO_VIDEO';
```

### 7. **Verificação de Analytics**

Para verificar se as visualizações estão sendo registradas:
```sql
SELECT * FROM workout_video_views 
WHERE user_id = 'SEU_USER_ID' 
ORDER BY viewed_at DESC;
```

## 📱 Screenshots Esperados

1. **Tela de Categorias**: Grid com as novas categorias destacadas
2. **Tela de Vídeos**: Lista organizada por dificuldade com filtros
3. **Player de Vídeo**: Player YouTube integrado com controles nativos

## 🚀 Próximos Passos Após Teste

1. Substituir URLs de exemplo por vídeos reais dos parceiros
2. Implementar funcionalidade de favoritar
3. Implementar registro de treino concluído
4. Adicionar analytics detalhado
5. Implementar busca de vídeos 