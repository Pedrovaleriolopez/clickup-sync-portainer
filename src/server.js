const express = require('express');
const { createClient } = require('@supabase/supabase-js');
require('dotenv').config();

const app = express();
app.use(express.json());

// Initialize Supabase
const supabase = createClient(
  process.env.SUPABASE_URL || '',
  process.env.SUPABASE_ANON_KEY || ''
);

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    supabase: !!process.env.SUPABASE_URL
  });
});

// Home page
app.get('/', (req, res) => {
  res.send(`
    <h1>ClickUp Sync v1.0</h1>
    <p>Status: Running</p>
    <p>Endpoints:</p>
    <ul>
      <li>GET /health - Health check</li>
      <li>POST /webhook - ClickUp webhook receiver</li>
      <li>GET /logs - View recent webhook events</li>
    </ul>
  `);
});

// Webhook receiver
app.post('/webhook', async (req, res) => {
  const event = req.headers['x-clickup-event'];
  const body = req.body;
  
  console.log(`Webhook received: ${event}`, body);
  
  // Save to Supabase if configured
  if (process.env.SUPABASE_URL) {
    try {
      const { data, error } = await supabase
        .from('webhook_events')
        .insert({
          event_type: event,
          payload: body,
          processed: false
        });
      
      if (error) {
        console.error('Supabase error:', error);
      } else {
        console.log('Event saved to Supabase');
      }
    } catch (err) {
      console.error('Error saving to Supabase:', err);
    }
  }
  
  res.json({ received: true });
});

// View logs
app.get('/logs', async (req, res) => {
  if (!process.env.SUPABASE_URL) {
    return res.json({ message: 'Supabase not configured' });
  }
  
  try {
    const { data, error } = await supabase
      .from('webhook_events')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(20);
    
    if (error) {
      return res.status(500).json({ error: error.message });
    }
    
    res.json(data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});