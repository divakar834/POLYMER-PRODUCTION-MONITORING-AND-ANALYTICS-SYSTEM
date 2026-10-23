-- =====================================================
-- Polymer Production Monitoring & Analytics System
-- PostgreSQL Database Schema
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- ROLES
-- =====================================================
CREATE TABLE IF NOT EXISTS roles (
  id          SERIAL PRIMARY KEY,
  name        VARCHAR(50) UNIQUE NOT NULL,
  description TEXT,
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO roles (name, description) VALUES
  ('admin',              'Full system access'),
  ('production_manager', 'Manage production batches and monitor'),
  ('quality_manager',    'Manage quality tests and approvals'),
  ('inventory_manager',  'Manage raw materials and consumption')
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- USERS
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email        VARCHAR(255) UNIQUE NOT NULL,
  password     VARCHAR(255) NOT NULL,
  first_name   VARCHAR(100) NOT NULL,
  last_name    VARCHAR(100) NOT NULL,
  role_id      INTEGER NOT NULL REFERENCES roles(id),
  is_active    BOOLEAN DEFAULT TRUE,
  last_login   TIMESTAMP WITH TIME ZONE,
  created_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_role_id ON users(role_id);

-- =====================================================
-- PRODUCTS
-- =====================================================
CREATE TABLE IF NOT EXISTS products (
  id           SERIAL PRIMARY KEY,
  name         VARCHAR(200) NOT NULL,
  code         VARCHAR(50) UNIQUE NOT NULL,
  product_type VARCHAR(100) NOT NULL,
  description  TEXT,
  unit         VARCHAR(20) NOT NULL DEFAULT 'kg',
  is_active    BOOLEAN DEFAULT TRUE,
  created_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_code ON products(code);

-- =====================================================
-- MACHINES
-- =====================================================
CREATE TABLE IF NOT EXISTS machines (
  id                   SERIAL PRIMARY KEY,
  machine_name         VARCHAR(200) NOT NULL,
  machine_code         VARCHAR(50) UNIQUE NOT NULL,
  machine_type         VARCHAR(100) NOT NULL,
  production_line      VARCHAR(100),
  status               VARCHAR(20) NOT NULL DEFAULT 'idle'
                         CHECK (status IN ('running','idle','maintenance','offline')),
  operating_hours      NUMERIC(10,2) DEFAULT 0,
  downtime_hours       NUMERIC(10,2) DEFAULT 0,
  last_maintenance_date DATE,
  next_maintenance_date DATE,
  notes                TEXT,
  created_at           TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at           TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_machines_code   ON machines(machine_code);
CREATE INDEX IF NOT EXISTS idx_machines_status ON machines(status);

-- =====================================================
-- RAW MATERIALS
-- =====================================================
CREATE TABLE IF NOT EXISTS raw_materials (
  id                  SERIAL PRIMARY KEY,
  material_name       VARCHAR(200) NOT NULL,
  material_code       VARCHAR(50) UNIQUE NOT NULL,
  material_type       VARCHAR(100) NOT NULL,
  supplier            VARCHAR(200),
  unit                VARCHAR(20) NOT NULL DEFAULT 'kg',
  current_stock       NUMERIC(12,3) NOT NULL DEFAULT 0,
  minimum_stock_level NUMERIC(12,3) NOT NULL DEFAULT 0,
  maximum_stock_level NUMERIC(12,3) NOT NULL DEFAULT 0,
  cost_per_unit       NUMERIC(12,4) DEFAULT 0,
  status              VARCHAR(20) NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active','inactive','discontinued')),
  notes               TEXT,
  created_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at          TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_raw_materials_code   ON raw_materials(material_code);
CREATE INDEX IF NOT EXISTS idx_raw_materials_status ON raw_materials(status);

-- =====================================================
-- STOCK HISTORY
-- =====================================================
CREATE TABLE IF NOT EXISTS stock_history (
  id            SERIAL PRIMARY KEY,
  material_id   INTEGER NOT NULL REFERENCES raw_materials(id) ON DELETE CASCADE,
  change_type   VARCHAR(20) NOT NULL CHECK (change_type IN ('increase','decrease','adjustment','consumption')),
  quantity      NUMERIC(12,3) NOT NULL,
  stock_before  NUMERIC(12,3) NOT NULL,
  stock_after   NUMERIC(12,3) NOT NULL,
  reference_id  VARCHAR(100),
  notes         TEXT,
  performed_by  UUID REFERENCES users(id),
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_stock_history_material ON stock_history(material_id);
CREATE INDEX IF NOT EXISTS idx_stock_history_date     ON stock_history(created_at);

-- =====================================================
-- PRODUCTION BATCHES
-- =====================================================
CREATE TABLE IF NOT EXISTS production_batches (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  batch_number     VARCHAR(50) UNIQUE NOT NULL,
  product_id       INTEGER NOT NULL REFERENCES products(id),
  machine_id       INTEGER REFERENCES machines(id),
  operator_id      UUID REFERENCES users(id),
  production_date  DATE NOT NULL DEFAULT CURRENT_DATE,
  planned_quantity NUMERIC(12,3) NOT NULL,
  produced_quantity NUMERIC(12,3) DEFAULT 0,
  rejected_quantity NUMERIC(12,3) DEFAULT 0,
  unit             VARCHAR(20) NOT NULL DEFAULT 'kg',
  start_time       TIMESTAMP WITH TIME ZONE,
  end_time         TIMESTAMP WITH TIME ZONE,
  status           VARCHAR(20) NOT NULL DEFAULT 'planned'
                     CHECK (status IN ('planned','in_progress','completed','rejected','on_hold')),
  quality_status   VARCHAR(20) DEFAULT 'pending'
                     CHECK (quality_status IN ('pending','approved','rejected')),
  efficiency       NUMERIC(6,2) DEFAULT 0,
  rejection_rate   NUMERIC(6,2) DEFAULT 0,
  remarks          TEXT,
  created_by       UUID REFERENCES users(id),
  created_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_batches_number      ON production_batches(batch_number);
CREATE INDEX IF NOT EXISTS idx_batches_product     ON production_batches(product_id);
CREATE INDEX IF NOT EXISTS idx_batches_machine     ON production_batches(machine_id);
CREATE INDEX IF NOT EXISTS idx_batches_status      ON production_batches(status);
CREATE INDEX IF NOT EXISTS idx_batches_date        ON production_batches(production_date);
CREATE INDEX IF NOT EXISTS idx_batches_quality     ON production_batches(quality_status);

-- =====================================================
-- BATCH STATUS HISTORY
-- =====================================================
CREATE TABLE IF NOT EXISTS batch_status_history (
  id          SERIAL PRIMARY KEY,
  batch_id    UUID NOT NULL REFERENCES production_batches(id) ON DELETE CASCADE,
  old_status  VARCHAR(20),
  new_status  VARCHAR(20) NOT NULL,
  changed_by  UUID REFERENCES users(id),
  notes       TEXT,
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_batch_status_batch ON batch_status_history(batch_id);

-- =====================================================
-- MATERIAL CONSUMPTION
-- =====================================================
CREATE TABLE IF NOT EXISTS material_consumption (
  id           SERIAL PRIMARY KEY,
  batch_id     UUID NOT NULL REFERENCES production_batches(id) ON DELETE CASCADE,
  material_id  INTEGER NOT NULL REFERENCES raw_materials(id),
  quantity_used NUMERIC(12,3) NOT NULL,
  unit         VARCHAR(20) NOT NULL DEFAULT 'kg',
  consumption_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  operator_id  UUID REFERENCES users(id),
  notes        TEXT,
  created_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_consumption_batch    ON material_consumption(batch_id);
CREATE INDEX IF NOT EXISTS idx_consumption_material ON material_consumption(material_id);
CREATE INDEX IF NOT EXISTS idx_consumption_date     ON material_consumption(consumption_date);

-- =====================================================
-- QUALITY PARAMETERS
-- =====================================================
CREATE TABLE IF NOT EXISTS quality_parameters (
  id            SERIAL PRIMARY KEY,
  parameter_name VARCHAR(100) NOT NULL,
  parameter_code VARCHAR(50) UNIQUE NOT NULL,
  unit          VARCHAR(30),
  is_critical   BOOLEAN DEFAULT FALSE,
  description   TEXT,
  is_active     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- QUALITY TESTS
-- =====================================================
CREATE TABLE IF NOT EXISTS quality_tests (
  id             SERIAL PRIMARY KEY,
  batch_id       UUID NOT NULL REFERENCES production_batches(id) ON DELETE CASCADE,
  parameter_id   INTEGER NOT NULL REFERENCES quality_parameters(id),
  tester_id      UUID REFERENCES users(id),
  test_date      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expected_value NUMERIC(12,4),
  actual_value   NUMERIC(12,4) NOT NULL,
  min_limit      NUMERIC(12,4),
  max_limit      NUMERIC(12,4),
  result         VARCHAR(10) NOT NULL CHECK (result IN ('pass','fail')),
  remarks        TEXT,
  created_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_quality_tests_batch     ON quality_tests(batch_id);
CREATE INDEX IF NOT EXISTS idx_quality_tests_parameter ON quality_tests(parameter_id);
CREATE INDEX IF NOT EXISTS idx_quality_tests_result    ON quality_tests(result);
CREATE INDEX IF NOT EXISTS idx_quality_tests_date      ON quality_tests(test_date);

-- =====================================================
-- MACHINE DOWNTIME
-- =====================================================
CREATE TABLE IF NOT EXISTS machine_downtime (
  id              SERIAL PRIMARY KEY,
  machine_id      INTEGER NOT NULL REFERENCES machines(id) ON DELETE CASCADE,
  batch_id        UUID REFERENCES production_batches(id),
  start_time      TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time        TIMESTAMP WITH TIME ZONE,
  duration_hours  NUMERIC(8,2),
  reason          VARCHAR(500) NOT NULL,
  category        VARCHAR(50) CHECK (category IN ('mechanical','electrical','scheduled','unplanned','other')),
  reported_by     UUID REFERENCES users(id),
  notes           TEXT,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_downtime_machine ON machine_downtime(machine_id);
CREATE INDEX IF NOT EXISTS idx_downtime_date    ON machine_downtime(start_time);

-- =====================================================
-- MAINTENANCE RECORDS
-- =====================================================
CREATE TABLE IF NOT EXISTS maintenance_records (
  id               SERIAL PRIMARY KEY,
  machine_id       INTEGER NOT NULL REFERENCES machines(id) ON DELETE CASCADE,
  maintenance_type VARCHAR(50) NOT NULL CHECK (maintenance_type IN ('preventive','corrective','emergency','routine')),
  maintenance_date DATE NOT NULL,
  performed_by     VARCHAR(200) NOT NULL,
  cost             NUMERIC(12,2) DEFAULT 0,
  description      TEXT,
  parts_replaced   TEXT,
  next_maintenance DATE,
  status           VARCHAR(20) DEFAULT 'completed' CHECK (status IN ('scheduled','in_progress','completed','cancelled')),
  created_by       UUID REFERENCES users(id),
  created_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_maintenance_machine ON maintenance_records(machine_id);
CREATE INDEX IF NOT EXISTS idx_maintenance_date    ON maintenance_records(maintenance_date);

-- =====================================================
-- ALERTS
-- =====================================================
CREATE TABLE IF NOT EXISTS alerts (
  id               SERIAL PRIMARY KEY,
  alert_type       VARCHAR(50) NOT NULL CHECK (alert_type IN ('inventory','quality','production','machine')),
  severity         VARCHAR(20) NOT NULL CHECK (severity IN ('low','medium','high','critical')),
  title            VARCHAR(200) NOT NULL,
  message          TEXT NOT NULL,
  batch_id         UUID REFERENCES production_batches(id),
  machine_id       INTEGER REFERENCES machines(id),
  material_id      INTEGER REFERENCES raw_materials(id),
  status           VARCHAR(20) NOT NULL DEFAULT 'active'
                     CHECK (status IN ('active','acknowledged','resolved')),
  acknowledged_by  UUID REFERENCES users(id),
  acknowledged_at  TIMESTAMP WITH TIME ZONE,
  resolved_at      TIMESTAMP WITH TIME ZONE,
  created_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alerts_type     ON alerts(alert_type);
CREATE INDEX IF NOT EXISTS idx_alerts_status   ON alerts(status);
CREATE INDEX IF NOT EXISTS idx_alerts_severity ON alerts(severity);
CREATE INDEX IF NOT EXISTS idx_alerts_date     ON alerts(created_at);

-- =====================================================
-- TRIGGERS — auto-update updated_at
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_machines_updated_at
  BEFORE UPDATE ON machines
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_raw_materials_updated_at
  BEFORE UPDATE ON raw_materials
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_batches_updated_at
  BEFORE UPDATE ON production_batches
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_quality_tests_updated_at
  BEFORE UPDATE ON quality_tests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- AUTO-COMPUTE efficiency & rejection_rate on batch update
-- =====================================================
CREATE OR REPLACE FUNCTION compute_batch_metrics()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.planned_quantity > 0 THEN
    NEW.efficiency := ROUND((NEW.produced_quantity / NEW.planned_quantity) * 100, 2);
  ELSE
    NEW.efficiency := 0;
  END IF;

  IF NEW.produced_quantity > 0 THEN
    NEW.rejection_rate := ROUND((NEW.rejected_quantity / NEW.produced_quantity) * 100, 2);
  ELSE
    NEW.rejection_rate := 0;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_batch_metrics
  BEFORE INSERT OR UPDATE ON production_batches
  FOR EACH ROW EXECUTE FUNCTION compute_batch_metrics();
