import { createClient } from '@supabase/supabase-js'

const SUPABASE_URL = 'https://agrytrijoibwasaezedc.supabase.co'
const SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFncnl0cmlqb2lid2FzYWV6ZWRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk4MTkxMTAsImV4cCI6MjA5NTM5NTExMH0.-3Uft_OR_gPAyJnKCP3QKxJ42lq2_dUvxOqUchxT3F0'

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY)

async function testUpdate() {
  const { data, error } = await supabase
    .from('usuarios')
    .update({ nombre_real: 'Prueba JS' })
    .eq('id', '5e1732e7-03bb-403d-82d8-21d1297dbdb2')
  console.log(error)
}

testUpdate()
