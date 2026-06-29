import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // Manejo de peticiones pre-flight (CORS)
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { dni } = await req.json();

    if (!dni || dni.length !== 8) {
      return new Response(JSON.stringify({ error: 'DNI inválido' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      });
    }

    // Primer filtro: API pública y gratuita (v1)
    let response = await fetch(`https://api.apis.net.pe/v1/dni?numero=${dni}`);
    let data = null;

    if (response.ok) {
      data = await response.json();
    } 
    
    // Si la v1 falla o no encuentra el DNI, intentamos el segundo filtro (v2) si hay token
    if (!response.ok || !data || data.error) {
      const token = Deno.env.get('DECOLECTA_TOKEN');
      
      if (token) {
        response = await fetch(`https://api.decolecta.com/v1/reniec/dni?numero=${dni}`, {
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        
        if (response.ok) {
          const decolectaData = await response.json();
          // Mapeamos la respuesta de Decolecta al formato esperado (apis.net.pe)
          data = {
            nombre: decolectaData.full_name,
            nombres: decolectaData.first_name,
            apellidoPaterno: decolectaData.first_last_name,
            apellidoMaterno: decolectaData.second_last_name
          };
        } else {
          throw new Error(`Ambas APIs fallaron. Estado Decolecta: ${response.status}`);
        }
      } else {
        throw new Error(`Error en API v1 (${response.status}) y no hay Token configurado para Decolecta.`);
      }
    }

    return new Response(JSON.stringify(data), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
