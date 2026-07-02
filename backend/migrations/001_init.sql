-- MOBO initial schema + RLS migration
-- Requires pgcrypto for gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Tenants and users
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_name TEXT NOT NULL,
  business_type TEXT NOT NULL CHECK (business_type IN ('retail','service','trading')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone_number TEXT NOT NULL UNIQUE,
  display_name TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tenant_members (
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  user_id UUID NOT NULL REFERENCES users(id),
  role TEXT NOT NULL CHECK (role IN ('owner','staff','accountant')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (tenant_id, user_id)
);

-- Business module tables
CREATE TABLE items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  name TEXT NOT NULL,
  price NUMERIC(12,2) NOT NULL,
  stock_qty NUMERIC(12,2) NOT NULL DEFAULT 0,
  low_stock_threshold NUMERIC(12,2),
  barcode TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  client_id UUID,
  sync_version INT NOT NULL DEFAULT 1
);

CREATE TABLE customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  name TEXT NOT NULL,
  phone_number TEXT,
  current_balance NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  client_id UUID,
  sync_version INT NOT NULL DEFAULT 1
);

CREATE TABLE sales (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  customer_id UUID REFERENCES customers(id),
  payment_type TEXT NOT NULL CHECK (payment_type IN ('cash','upi','credit')),
  total_amount NUMERIC(12,2) NOT NULL,
  amount_paid NUMERIC(12,2) NOT NULL DEFAULT 0,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  client_id UUID,
  sync_version INT NOT NULL DEFAULT 1
);

CREATE TABLE sale_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sale_id UUID NOT NULL REFERENCES sales(id),
  item_id UUID REFERENCES items(id),
  item_name_snapshot TEXT NOT NULL,
  quantity NUMERIC(12,2) NOT NULL,
  unit_price NUMERIC(12,2) NOT NULL
);

CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  customer_id UUID NOT NULL REFERENCES customers(id),
  status TEXT NOT NULL CHECK (status IN ('paid','partial','unpaid')),
  total_amount NUMERIC(12,2) NOT NULL,
  amount_paid NUMERIC(12,2) NOT NULL DEFAULT 0,
  pdf_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  client_id UUID,
  sync_version INT NOT NULL DEFAULT 1
);

CREATE TABLE invoice_line_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id UUID NOT NULL REFERENCES invoices(id),
  description TEXT NOT NULL,
  amount NUMERIC(12,2) NOT NULL
);

CREATE TABLE expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  amount NUMERIC(12,2) NOT NULL,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  client_id UUID,
  sync_version INT NOT NULL DEFAULT 1
);

-- Ledger entries (single source of truth for balances)
CREATE TABLE ledger_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  customer_id UUID NOT NULL REFERENCES customers(id),
  entry_type TEXT NOT NULL CHECK (entry_type IN ('credit_sale','payment_received','invoice_partial','adjustment')),
  amount NUMERIC(12,2) NOT NULL,
  source_table TEXT,
  source_id UUID,
  created_by UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  client_id UUID,
  sync_version INT NOT NULL DEFAULT 1
);

CREATE TABLE reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  customer_id UUID NOT NULL REFERENCES customers(id),
  channel TEXT NOT NULL CHECK (channel IN ('whatsapp','sms')),
  status TEXT NOT NULL CHECK (status IN ('pending','sent','failed')) DEFAULT 'pending',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  sent_at TIMESTAMPTZ
);

-- AI tables
CREATE TABLE ai_conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES tenants(id),
  user_id UUID NOT NULL REFERENCES users(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE ai_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES ai_conversations(id),
  role TEXT NOT NULL CHECK (role IN ('user','assistant')),
  content TEXT NOT NULL,
  proposed_action JSONB,
  action_confirmed BOOLEAN,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX idx_customers_tenant_balance ON customers (tenant_id, current_balance DESC) WHERE deleted_at IS NULL;
CREATE INDEX idx_sales_tenant_created ON sales (tenant_id, created_at DESC);
CREATE INDEX idx_ledger_customer ON ledger_entries (customer_id, created_at DESC);
CREATE INDEX idx_items_tenant_lowstock ON items (tenant_id) WHERE stock_qty <= low_stock_threshold;

-- RLS setup: enable RLS on tenant-scoped tables
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE sale_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_line_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE ledger_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_messages ENABLE ROW LEVEL SECURITY;

-- RLS policy: allow rows where tenant_id matches session var
DO $$
BEGIN
  -- generic function to create policy per table
  PERFORM 1;
END$$;

-- Create policy for a given table name function
CREATE OR REPLACE FUNCTION create_tenant_rls_policy(tbl regclass) RETURNS void AS $$
BEGIN
  EXECUTE format('CREATE POLICY tenant_isolation ON %s USING (tenant_id = current_setting(''app.current_tenant_id'')::uuid);', tbl::text);
END;
$$ LANGUAGE plpgsql;

-- Apply policies
SELECT create_tenant_rls_policy('items'::regclass);
SELECT create_tenant_rls_policy('customers'::regclass);
SELECT create_tenant_rls_policy('sales'::regclass);
SELECT create_tenant_rls_policy('sale_items'::regclass);
SELECT create_tenant_rls_policy('invoices'::regclass);
SELECT create_tenant_rls_policy('invoice_line_items'::regclass);
SELECT create_tenant_rls_policy('expenses'::regclass);
SELECT create_tenant_rls_policy('ledger_entries'::regclass);
SELECT create_tenant_rls_policy('reminders'::regclass);
SELECT create_tenant_rls_policy('ai_conversations'::regclass);
SELECT create_tenant_rls_policy('ai_messages'::regclass);

-- Trigger to update customers.current_balance after insert on ledger_entries
CREATE OR REPLACE FUNCTION update_customer_balance() RETURNS TRIGGER AS $$
BEGIN
  UPDATE customers
  SET current_balance = current_balance + NEW.amount
  WHERE id = NEW.customer_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ledger_balance
AFTER INSERT ON ledger_entries
FOR EACH ROW EXECUTE FUNCTION update_customer_balance();
