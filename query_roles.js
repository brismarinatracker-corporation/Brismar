const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();
const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
async function run() {
  const { data, error } = await supabase.from('usuarios').select('rol').limit(10);
  console.log(data);
  if (error) console.error(error);
}
run();
