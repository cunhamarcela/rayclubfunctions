import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  try {
    const { name, title, body, token } = await req.json()
    
    console.log("🔔 Enviando notificação para:", name)
    console.log("📱 Token FCM:", token?.substring(0, 20) + "...")
    console.log("📝 Título:", title)
    console.log("📄 Mensagem:", body)
    
    // Aqui você pode integrar com Firebase FCM ou outro serviço
    // Por enquanto, apenas simula o envio
    
    const response = {
      success: true,
      message: `Notificação enviada com sucesso para ${name}`,
      timestamp: new Date().toISOString(),
      data: {
        title,
        body,
        recipient: name
      }
    }
    
    return new Response(JSON.stringify(response), {
      status: 200,
      headers: {
        "Content-Type": "application/json",
      },
    })
    
  } catch (error) {
    console.error("❌ Erro ao enviar notificação:", error)
    
    return new Response(JSON.stringify({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    }), {
      status: 500,
      headers: {
        "Content-Type": "application/json",
      },
    })
  }
})
