# 🚀 CÓDIGO COMPLETO PARA COLAR NO DASHBOARD SUPABASE

## ✅ COPIE E COLE ESTE CÓDIGO NA INTERFACE:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import Stripe from 'https://esm.sh/stripe@11.1.0?target=deno'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, stripe-signature',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Verificar se é uma requisição POST
    if (req.method !== 'POST') {
      return new Response(
        JSON.stringify({ error: 'Method not allowed' }),
        { 
          status: 405, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Obter variáveis de ambiente
    const stripeSecretKey = Deno.env.get('STRIPE_SECRET_KEY')
    const stripeWebhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')
    const supabaseUrl = Deno.env.get('SUPABASE_URL')
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')

    if (!stripeSecretKey || !stripeWebhookSecret || !supabaseUrl || !supabaseServiceKey) {
      console.error('Missing required environment variables')
      return new Response(
        JSON.stringify({ error: 'Server configuration error' }),
        { 
          status: 500, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Inicializar Stripe
    const stripe = new Stripe(stripeSecretKey, {
      apiVersion: '2022-11-15',
    })

    // Inicializar Supabase client
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Obter o body da requisição e a assinatura
    const body = await req.text()
    const signature = req.headers.get('stripe-signature')

    if (!signature) {
      console.error('Missing stripe-signature header')
      return new Response(
        JSON.stringify({ error: 'Missing signature' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    // Verificar a assinatura do webhook
    let event: Stripe.Event
    try {
      event = stripe.webhooks.constructEvent(body, signature, stripeWebhookSecret)
    } catch (err) {
      console.error('Webhook signature verification failed:', err.message)
      return new Response(
        JSON.stringify({ error: 'Invalid signature' }),
        { 
          status: 400, 
          headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
        }
      )
    }

    console.log('✅ Webhook verificado com sucesso:', event.type)

    // Processar eventos relevantes
    switch (event.type) {
      case 'customer.subscription.created':
      case 'customer.subscription.updated':
      case 'invoice.payment_succeeded':
        await handleSubscriptionEvent(event, stripe, supabase)
        break
      
      case 'customer.subscription.deleted':
      case 'invoice.payment_failed':
        await handleSubscriptionCancelEvent(event, stripe, supabase)
        break
      
      default:
        console.log(`🔄 Evento não processado: ${event.type}`)
    }

    return new Response(
      JSON.stringify({ received: true, event_type: event.type }),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )

  } catch (error) {
    console.error('❌ Erro no webhook:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  }
})

async function handleSubscriptionEvent(
  event: Stripe.Event, 
  stripe: Stripe, 
  supabase: any
) {
  try {
    console.log(`🎯 Processando evento de assinatura: ${event.type}`)
    
    let customerId: string
    let subscriptionId: string
    let currentPeriodEnd: number

    // Extrair dados baseado no tipo de evento
    if (event.type === 'invoice.payment_succeeded') {
      const invoice = event.data.object as Stripe.Invoice
      customerId = invoice.customer as string
      subscriptionId = invoice.subscription as string
      
      // Buscar dados da subscription
      const subscription = await stripe.subscriptions.retrieve(subscriptionId)
      currentPeriodEnd = subscription.current_period_end
    } else {
      const subscription = event.data.object as Stripe.Subscription
      customerId = subscription.customer as string
      subscriptionId = subscription.id
      currentPeriodEnd = subscription.current_period_end
    }

    // Buscar informações do cliente
    const customer = await stripe.customers.retrieve(customerId) as Stripe.Customer
    
    if (!customer.email) {
      console.error('❌ Customer sem email:', customerId)
      return
    }

    console.log(`📧 Processando para: ${customer.email}`)

    // Calcular data de expiração (30 dias a partir do fim do período atual)
    const expiresAt = new Date(currentPeriodEnd * 1000)
    expiresAt.setDate(expiresAt.getDate() + 30) // Adicionar 30 dias de margem

    // Chamar função SQL para atualizar usuário (NOVA FUNÇÃO)
    const { data, error } = await supabase.rpc('stripe_update_user_level', {
      p_email: customer.email,
      p_level: 'expert',
      p_expires_at: expiresAt.toISOString(),
      p_stripe_customer_id: customerId,
      p_stripe_subscription_id: subscriptionId,
      p_stripe_event_id: event.id
    })

    if (error) {
      console.error('❌ Erro ao atualizar usuário:', error)
      throw error
    }

    console.log('✅ Usuário atualizado com sucesso:', data)

    // Log adicional para monitoramento
    console.log(`
      📊 Resumo da atualização:
      - Email: ${customer.email}
      - Nível: expert
      - Expira em: ${expiresAt.toISOString()}
      - Customer ID: ${customerId}
      - Subscription ID: ${subscriptionId}
      - Event ID: ${event.id}
    `)

  } catch (error) {
    console.error('❌ Erro ao processar evento de assinatura:', error)
    throw error
  }
}

async function handleSubscriptionCancelEvent(
  event: Stripe.Event, 
  stripe: Stripe, 
  supabase: any
) {
  try {
    console.log(`🚫 Processando cancelamento: ${event.type}`)
    
    let customerId: string

    if (event.type === 'invoice.payment_failed') {
      const invoice = event.data.object as Stripe.Invoice
      customerId = invoice.customer as string
    } else {
      const subscription = event.data.object as Stripe.Subscription
      customerId = subscription.customer as string
    }

    // Buscar informações do cliente
    const customer = await stripe.customers.retrieve(customerId) as Stripe.Customer
    
    if (!customer.email) {
      console.error('❌ Customer sem email para cancelamento:', customerId)
      return
    }

    console.log(`📧 Cancelando acesso para: ${customer.email}`)

    // Atualizar usuário para nível básico (imediatamente) - NOVA FUNÇÃO
    const { data, error } = await supabase.rpc('stripe_update_user_level', {
      p_email: customer.email,
      p_level: 'basic',
      p_expires_at: null, // Remove data de expiração
      p_stripe_customer_id: customerId,
      p_stripe_subscription_id: null,
      p_stripe_event_id: event.id
    })

    if (error) {
      console.error('❌ Erro ao cancelar acesso do usuário:', error)
      throw error
    }

    console.log('✅ Acesso cancelado com sucesso:', data)

  } catch (error) {
    console.error('❌ Erro ao processar cancelamento:', error)
    throw error
  }
}
```

## 🔧 CONFIGURAÇÕES IMPORTANTES:

### ✅ Nome da função: `stripe-webhook`
### ✅ Runtime: Deno (já selecionado automaticamente)
### ✅ HTTP triggers: Enabled
### ✅ CORS: Enabled

---

## 📋 DEPOIS DE CRIAR A FUNÇÃO:

1. ✅ **Salvar** a função
2. ⚙️ **Configurar variáveis de ambiente** (próximo passo)
3. 🧪 **Testar** a função
4. 🔗 **Configurar webhook no Stripe** 