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
}

serve(async (req) => {
  try {
    // Inicializar cliente Supabase
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    )

    // Determinar o tipo de trigger baseado no horário atual
    const now = new Date()
    const hour = now.getHours()
    let trigger_type = 'manha'
    
    if (hour >= 12 && hour < 17) {
      trigger_type = 'tarde'
    } else if (hour >= 17 && hour < 22) {
      trigger_type = 'noite'
    }

    console.log(`Enviando notificações para trigger_type: ${trigger_type} às ${hour}h`)

    // Buscar templates de notificação para o horário atual
    const { data: templates, error: templatesError } = await supabase
      .from('notification_templates')
      .select('*')
      .eq('trigger_type', trigger_type)

    if (templatesError) {
      console.error('Erro ao buscar templates:', templatesError)
      return new Response(
        JSON.stringify({ error: 'Erro ao buscar templates' }), 
        { status: 500, headers: { 'Content-Type': 'application/json' } }
      )
    }

    if (!templates || templates.length === 0) {
      console.log(`Nenhum template encontrado para trigger_type: ${trigger_type}`)
      return new Response(
        JSON.stringify({ message: `Nenhum template encontrado para ${trigger_type}` }), 
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    // Buscar usuários com FCM token válido
    const { data: users, error: usersError } = await supabase
      .from('profiles')
      .select('id, fcm_token, name')
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
      console.log('Nenhum usuário com FCM token encontrado')
      return new Response(
        JSON.stringify({ message: 'Nenhum usuário com FCM token encontrado' }), 
        { status: 200, headers: { 'Content-Type': 'application/json' } }
      )
    }

    console.log(`Enviando notificações para ${users.length} usuários`)

    // Enviar notificações
    let successCount = 0
    let errorCount = 0

    for (const user of users as UserProfile[]) {
      for (const template of templates as NotificationTemplate[]) {
        try {
          // Personalizar mensagem se necessário
          let personalizedBody = template.body
          if (user.name) {
            personalizedBody = personalizedBody.replace('[nome]', user.name)
          }

          const fcmPayload = {
            to: user.fcm_token,
            notification: {
              title: template.title || "Ray Club",
              body: personalizedBody,
              icon: "ic_notification",
              sound: "default"
            },
            data: {
              category: template.category,
              trigger_type: template.trigger_type,
              click_action: "FLUTTER_NOTIFICATION_CLICK"
            }
          }

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
            console.log(`Notificação enviada com sucesso para usuário ${user.id}`)
          } else {
            errorCount++
            const errorText = await fcmResponse.text()
            console.error(`Erro ao enviar notificação para usuário ${user.id}:`, errorText)
          }

          // Registrar notificação no banco (opcional)
          await supabase
            .from('notifications')
            .insert({
              user_id: user.id,
              title: template.title || "Ray Club",
              message: personalizedBody,
              type: template.category,
              data: {
                trigger_type: template.trigger_type,
                sent_via: 'fcm'
              }
            })

        } catch (error) {
          errorCount++
          console.error(`Erro ao processar notificação para usuário ${user.id}:`, error)
        }
      }
    }

    const result = {
      message: 'Processo de envio de notificações concluído',
      trigger_type,
      templates_found: templates.length,
      users_found: users.length,
      notifications_sent: successCount,
      errors: errorCount,
      timestamp: new Date().toISOString()
    }

    console.log('Resultado final:', result)

    return new Response(
      JSON.stringify(result), 
      { 
        status: 200, 
        headers: { 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('Erro geral na função:', error)
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
