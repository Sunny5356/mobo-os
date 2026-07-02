const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

app.post('/v1/auth/otp/request', (req, res) => {
  res.json({ sent: true });
});

app.post('/v1/auth/otp/verify', (req, res) => {
  res.json({ access_token: 'mock-token', refresh_token: 'mock-refresh', is_new_user: true });
});

app.get('/v1/insights/summary', (req, res) => {
  res.json({ today_sales: 1200.0, total_receivables: 4500.0, low_stock_count: 2 });
});

app.post('/v1/ai/conversations', (req, res) => {
  res.status(201).json({ conversation_id: 'conv-1' });
});

app.post('/v1/ai/conversations/:id/messages', (req, res) => {
  // mock assistant response with proposed action
  const message = {
    id: 'msg-' + Date.now(),
    role: 'assistant',
    content: 'I can remind Ramesh.',
    proposed_action: { type: 'send_reminder', customer_id: 'cust-123', channel: 'whatsapp', customer_name: 'Ramesh' },
  };
  res.json(message);
});

app.post('/v1/ai/actions/:messageId/confirm', (req, res) => {
  res.json({ status: 'executed' });
});

app.post('/v1/sync/push', (req, res) => {
  const changes = req.body.changes || [];
  const results = changes.map(c => ({ client_id: c.client_id || c.clientId, server_id: 'srv-' + Date.now(), status: 'applied' }));
  res.json({ results });
});

app.get('/v1/customers', (req, res) => {
  res.json([{ id: 'cust-123', name: 'Ramesh', phone_number: '99999', current_balance: 500 }]);
});

app.post('/v1/customers', (req, res) => {
  res.status(201).json({ id: 'cust-' + Date.now(), name: req.body.name });
});

app.post('/v1/customers/:id/payments', (req, res) => {
  res.json({ status: 'recorded' });
});

const port = process.env.PORT || 3000;
app.listen(port, () => console.log('Mock backend listening on', port));
