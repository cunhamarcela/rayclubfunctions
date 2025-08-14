import { serve } from 'https://deno.land/std/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface NotificationTemplate {
  id: string
  category: string
  trigger_type: string
  title?: string
  body: string
}

interface UserProfile {
  id: string
  fcm_token: string
  name?: string
  email?: string
  created_at?: string
  last_login_at?: string
  streak?: number
  completed_workouts?: number
  points?: number
}

interface UserGoal {
  user_id: string
  daily_workout_goal?: number
  weekly_workout_goal?: number
  current_week_workouts?: number
  current_day_workouts?: number
}

interface ChallengeParticipant {
  user_id: string
  challenge_id: string
  points: number
  rank?: number
  challenge_name?: string
}

serve(async (req) => {
  try {
    // Inicializar cliente Supabase
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    )

    // Obter parâmetros da requisição
    const { trigger_type: forcedTrigger, test_mode } = await req.json().catch(() => ({}))
    
    // Determinar tipos de trigger baseados no horário e contexto
    const now = new Date()
    const hour = now.getHours()
    const dayOfWeek = now.getDay() // 0 = domingo, 1 = segunda
    const dayOfMonth = now.getDate()
    
    let triggerTypes: string[] = []
    
    if (forcedTrigger) {
      triggerTypes = [forcedTrigger]
    } else {
      // Triggers baseados em horário
      if (hour >= 6 && hour < 10) {
        triggerTypes.push('manha')
      } else if (hour >= 12 && hour < 16) {
        triggerTypes.push('tarde')
      } else if (hour >= 18 && hour < 21) {
        triggerTypes.push('noite')
      }
      
      // Triggers especiais baseados em dias
      if (dayOfWeek === 1) { // Segunda-feira
        triggerTypes.push('inicio_semana')
      }
      
      if (dayOfWeek === 4 && hour === 18) { // Quinta à noite
        triggerTypes.push('meta_semanal_risco')
      }
      
      // Triggers sazonais
      const month = now.getMonth() + 1
      if (month >= 6 && month <= 8) { // Inverno
        triggerTypes.push('ebook_sazonal_inverno')
      } else if (month >= 12 || month <= 2) { // Verão
        triggerTypes.push('ebook_sazonal_verao')
      }
    }

    console.log(`Processando triggers: ${triggerTypes.join(', ')} às ${hour}h`)

    if (triggerTypes.length === 0) {
      return new Response(
        JSON.stringify({ message: 'Nenhum trigger ativo para este horário' }), 
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Buscar templates para os triggers ativos
    const { data: templates, error: templatesError } = await supabase
      .from('notification_templates')
      .select('*')
      .in('trigger_type', triggerTypes)

    if (templatesError) {
      console.error('Erro ao buscar templates:', templatesError)
      return new Response(
        JSON.stringify({ error: 'Erro ao buscar templates' }), 
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    if (!templates || templates.length === 0) {
      return new Response(
        JSON.stringify({ message: `Nenhum template encontrado para triggers: ${triggerTypes.join(', ')}` }), 
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Buscar usuários com FCM token
    const { data: users, error: usersError } = await supabase
      .from('profiles')
      .select('id, fcm_token, name, email, created_at, last_login_at, streak, completed_workouts, points')
      .not('fcm_token', 'is', null)
      .neq('fcm_token', '')

    if (usersError) {
      console.error('Erro ao buscar usuários:', usersError)
      return new Response(
        JSON.stringify({ error: 'Erro ao buscar usuários' }), 
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    if (!users || users.length === 0) {
      return new Response(
        JSON.stringify({ message: 'Nenhum usuário com FCM token encontrado' }), 
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    console.log(`Processando ${templates.length} templates para ${users.length} usuários`)

    // Função para personalizar mensagens
    const personalizeMessage = async (template: NotificationTemplate, user: UserProfile): Promise<{ title: string, body: string }> => {
      let personalizedTitle = template.title || "Ray Club"
      let personalizedBody = template.body

      // Substituições básicas
      if (user.name) {
        personalizedBody = personalizedBody.replace('[nome]', user.name)
        personalizedTitle = personalizedTitle.replace('[nome]', user.name)
      }

      // Substituições específicas por tipo de trigger
      switch (template.trigger_type) {
        case 'meta_semanal_risco':
          // Buscar dados de meta semanal do usuário
          const { data: weeklyProgress } = await supabase
            .from('user_workouts')
            .select('id')
            .eq('user_id', user.id)
            .gte('created_at', getStartOfWeek())
          
          const workoutsThisWeek = weeklyProgress?.length || 0
          const weeklyGoal = 5 // Padrão, pode vir do perfil do usuário
          const remaining = Math.max(0, weeklyGoal - workoutsThisWeek)
          
          personalizedBody = personalizedBody.replace('[x]', remaining.toString())
          break

        case 'meta_diaria_risco':
          // Buscar treinos do dia
          const { data: dailyProgress } = await supabase
            .from('user_workouts')
            .select('id')
            .eq('user_id', user.id)
            .gte('created_at', getStartOfDay())
          
          const workoutsToday = dailyProgress?.length || 0
          const dailyGoal = 1 // Padrão
          const dailyRemaining = Math.max(0, dailyGoal - workoutsToday)
          
          personalizedBody = personalizedBody.replace('[x]', dailyRemaining.toString())
          break

        case 'sequencia_alta':
          personalizedBody = personalizedBody.replace('[x]', (user.streak || 0).toString())
          break

        case 'treino_longo':
          // Esta seria chamada com dados específicos do treino
          personalizedBody = personalizedBody.replace('[x]', '45') // Exemplo
          break

        case 'manha':
        case 'tarde':
        case 'noite':
          // Buscar receita aleatória para o horário
          const { data: recipes } = await supabase
            .from('recipes')
            .select('title')
            .limit(1)
            .order('created_at', { ascending: false })
          
          if (recipes && recipes.length > 0) {
            personalizedBody = personalizedBody.replace('[nome_receita]', recipes[0].title)
          }
          break
      }

      return { title: personalizedTitle, body: personalizedBody }
    }

    // Função para verificar se deve enviar notificação para usuário específico
    const shouldSendToUser = async (template: NotificationTemplate, user: UserProfile): Promise<boolean> => {
      const now = new Date()
      const userCreatedAt = new Date(user.created_at || now)
      const daysSinceJoined = Math.floor((now.getTime() - userCreatedAt.getTime()) / (1000 * 60 * 60 * 24))

      // Não enviar para usuários muito novos (menos de 1 dia)
      if (daysSinceJoined < 1) return false

      // Lógica específica por tipo de trigger
      switch (template.trigger_type) {
        case 'primeiro_treino':
          // Só para usuários sem treinos
          const { data: workouts } = await supabase
            .from('user_workouts')
            .select('id')
            .eq('user_id', user.id)
            .limit(1)
          return !workouts || workouts.length === 0

        case 'sem_treino_1dia':
          // Usuários que não treinaram ontem
          const { data: yesterdayWorkouts } = await supabase
            .from('user_workouts')
            .select('id')
            .eq('user_id', user.id)
            .gte('created_at', getYesterday())
            .lt('created_at', getStartOfDay())
          return !yesterdayWorkouts || yesterdayWorkouts.length === 0

        case 'sem_treino_2dias':
          // Usuários que não treinaram nos últimos 2 dias
          const { data: twoDaysWorkouts } = await supabase
            .from('user_workouts')
            .select('id')
            .eq('user_id', user.id)
            .gte('created_at', getTwoDaysAgo())
          return !twoDaysWorkouts || twoDaysWorkouts.length === 0

        case 'ultrapassado':
          // Verificar se usuário foi ultrapassado em desafio ativo
          // Esta lógica seria mais complexa, verificando ranking anterior vs atual
          return Math.random() < 0.1 // 10% de chance para teste

        default:
          return true
      }
    }

    // Enviar notificações
    let successCount = 0
    let errorCount = 0
    let skippedCount = 0

    for (const user of users as UserProfile[]) {
      for (const template of templates as NotificationTemplate[]) {
        try {
          // Verificar se deve enviar para este usuário
          if (!(await shouldSendToUser(template, user))) {
            skippedCount++
            continue
          }

          // Personalizar mensagem
          const { title, body } = await personalizeMessage(template, user)

          const fcmPayload = {
            to: user.fcm_token,
            notification: {
              title,
              body,
              icon: "ic_notification",
              sound: "default"
            },
            data: {
              category: template.category,
              trigger_type: template.trigger_type,
              template_id: template.id,
              click_action: "FLUTTER_NOTIFICATION_CLICK"
            }
          }

          // Enviar via FCM
          const fcmResponse = await fetch('https://fcm.googleapis.com/fcm/send', {
            method: 'POST',
            headers: {
              'Authorization': `key=${Deno.env.get("FCM_SERVER_KEY")}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify(fcmPayload)
          })

          if (fcmResponse.ok) {
            successCount++
            console.log(`✅ Notificação enviada: ${template.trigger_type} para ${user.id}`)
          } else {
            errorCount++
            const errorText = await fcmResponse.text()
            console.error(`❌ Erro FCM para ${user.id}:`, errorText)
          }

          // Registrar notificação no banco
          await supabase
            .from('notifications')
            .insert({
              user_id: user.id,
              title,
              message: body,
              type: template.category,
              data: {
                trigger_type: template.trigger_type,
                template_id: template.id,
                sent_via: 'fcm'
              }
            })

        } catch (error) {
          errorCount++
          console.error(`❌ Erro ao processar ${template.trigger_type} para ${user.id}:`, error)
        }
      }
    }

    const result = {
      message: 'Processo de envio concluído',
      trigger_types: triggerTypes,
      templates_found: templates.length,
      users_found: users.length,
      notifications_sent: successCount,
      notifications_skipped: skippedCount,
      errors: errorCount,
      timestamp: new Date().toISOString()
    }

    console.log('📊 Resultado final:', result)

    return new Response(
      JSON.stringify(result), 
      { 
        status: 200, 
        headers: { 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('💥 Erro geral na função:', error)
    return new Response(
      JSON.stringify({ 
        error: 'Erro interno da função',
        details: error.message 
      }), 
      { 
        status: 500, 
        headers: { 'Content-Type': 'application/json' } 
      }
    )
  }
})

// Funções auxiliares para datas
function getStartOfDay(): string {
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  return today.toISOString()
}

function getYesterday(): string {
  const yesterday = new Date()
  yesterday.setDate(yesterday.getDate() - 1)
  yesterday.setHours(0, 0, 0, 0)
  return yesterday.toISOString()
}

function getTwoDaysAgo(): string {
  const twoDaysAgo = new Date()
  twoDaysAgo.setDate(twoDaysAgo.getDate() - 2)
  twoDaysAgo.setHours(0, 0, 0, 0)
  return twoDaysAgo.toISOString()
}

function getStartOfWeek(): string {
  const today = new Date()
  const dayOfWeek = today.getDay()
  const startOfWeek = new Date(today)
  startOfWeek.setDate(today.getDate() - dayOfWeek + (dayOfWeek === 0 ? -6 : 1)) // Segunda-feira
  startOfWeek.setHours(0, 0, 0, 0)
  return startOfWeek.toISOString()
}