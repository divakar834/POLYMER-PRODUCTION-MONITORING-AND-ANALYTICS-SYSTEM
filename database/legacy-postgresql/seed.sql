-- =====================================================
-- Polymer Production Monitoring & Analytics System
-- Seed Data — Realistic Sample Data
-- =====================================================

-- =====================================================
-- USERS (passwords are bcrypt hashes of stated values)
-- The accounts have separate hashes for these development passwords:
-- admin@polymer.com     → Admin@123
-- prod@polymer.com      → Prod@123
-- quality@polymer.com   → Quality@123
-- inventory@polymer.com → Inventory@123
-- =====================================================
INSERT INTO users (id, email, password, first_name, last_name, role_id) VALUES
(
  '11111111-1111-1111-1111-111111111111',
  'admin@polymer.com',
  '$2b$10$hiTON5hahbt9YtZcdQ51Uuuw8s1k5PAuQisookolQPqZy20MyooFe', -- Admin@123
  'System', 'Administrator', 1
),
(
  '22222222-2222-2222-2222-222222222222',
  'prod@polymer.com',
  '$2b$10$NOa/xRbzBl6rgK/mYwafOOy2jxC7JDrLQDwl4N3lDG/j0h.f1diRa', -- Prod@123
  'Rajesh', 'Sharma', 2
),
(
  '33333333-3333-3333-3333-333333333333',
  'quality@polymer.com',
  '$2b$10$4gi1fzKuzGN2V0dGBGad.e3i2UOuU6DjK7Hy7SGd6KsjFcDYZ508i', -- Quality@123
  'Priya', 'Verma', 3
),
(
  '44444444-4444-4444-4444-444444444444',
  'inventory@polymer.com',
  '$2b$10$2.MmClf5JfRCLaKBoPX22Ou61LpUW2N4cbvi6cbjqehj8UWGuHdlG', -- Inventory@123
  'Amit', 'Kumar', 4
),
(
  '55555555-5555-5555-5555-555555555555',
  'operator1@polymer.com',
  '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  'Suresh', 'Patel', 2
)
ON CONFLICT (email) DO NOTHING;

-- =====================================================
-- PRODUCTS
-- =====================================================
INSERT INTO products (name, code, product_type, description, unit) VALUES
('HDPE Grade A', 'HDPE-A-01', 'High Density Polyethylene', 'High-grade HDPE for industrial pipes', 'kg'),
('LDPE Film Grade', 'LDPE-F-02', 'Low Density Polyethylene', 'LDPE for packaging films', 'kg'),
('PP Homopolymer', 'PP-H-03', 'Polypropylene', 'General purpose PP homopolymer', 'kg'),
('PP Copolymer', 'PP-C-04', 'Polypropylene', 'Impact-resistant PP copolymer', 'kg'),
('PVC Rigid', 'PVC-R-05', 'Polyvinyl Chloride', 'Rigid PVC for construction', 'kg'),
('PVC Flexible', 'PVC-F-06', 'Polyvinyl Chloride', 'Flexible PVC for cables', 'kg'),
('ABS Standard', 'ABS-S-07', 'Acrylonitrile Butadiene Styrene', 'Standard ABS for injection moulding', 'kg'),
('Nylon 6', 'NYL-6-08', 'Polyamide', 'Nylon 6 engineering grade', 'kg')
ON CONFLICT (code) DO NOTHING;

-- =====================================================
-- MACHINES
-- =====================================================
INSERT INTO machines (machine_name, machine_code, machine_type, production_line, status, operating_hours, downtime_hours, last_maintenance_date, next_maintenance_date) VALUES
('Extruder Line 1',   'EXT-L1-01', 'Extruder',          'Line A', 'running',     2450.5, 48.5,  '2026-08-15', '2026-10-15'),
('Extruder Line 2',   'EXT-L2-02', 'Extruder',          'Line A', 'idle',        1820.0, 32.0,  '2026-07-20', '2026-09-20'),
('Injection Moulder 1','INJ-M1-03','Injection Moulding', 'Line B', 'running',     3100.0, 65.0,  '2026-08-01', '2026-11-01'),
('Injection Moulder 2','INJ-M2-04','Injection Moulding', 'Line B', 'maintenance', 2750.0, 120.0, '2026-09-25', '2026-12-25'),
('Blow Moulding 1',   'BLW-M1-05', 'Blow Moulding',     'Line C', 'running',     1650.0, 22.0,  '2026-09-01', '2026-12-01'),
('Granulator 1',      'GRN-01-06', 'Granulator',        'Line D', 'idle',        980.0,  12.0,  '2026-06-15', '2026-09-15'),
('Mixer Unit 1',      'MIX-01-07', 'Mixer',             'Line A', 'running',     2100.0, 35.0,  '2026-07-10', '2026-10-10'),
('Film Line 1',       'FLM-L1-08', 'Film Extrusion',    'Line E', 'offline',     560.0,  180.0, '2026-05-01', '2026-07-01')
ON CONFLICT (machine_code) DO NOTHING;

-- =====================================================
-- RAW MATERIALS
-- =====================================================
INSERT INTO raw_materials (material_name, material_code, material_type, supplier, unit, current_stock, minimum_stock_level, maximum_stock_level, cost_per_unit) VALUES
('HDPE Base Resin',       'RM-HDPE-001', 'Polymer Resin',  'SABIC India Ltd',          'kg', 12500, 2000, 20000, 85.50),
('LDPE Base Resin',       'RM-LDPE-002', 'Polymer Resin',  'Reliance Industries Ltd',  'kg', 8200,  1500, 15000, 78.25),
('PP Base Resin',         'RM-PP-003',   'Polymer Resin',  'Haldia Petrochemicals',    'kg', 15000, 2500, 25000, 72.00),
('PVC Base Resin',        'RM-PVC-004',  'Polymer Resin',  'Finolex Industries',       'kg', 920,   1000, 18000, 65.75),
('ABS Base Resin',        'RM-ABS-005',  'Polymer Resin',  'LG Chem India',            'kg', 3400,  500,  8000,  195.00),
('Heat Stabilizer CaZn',  'RM-HS-006',   'Stabilizer',     'Baerlocher India',         'kg', 750,   200,  2000,  425.00),
('UV Stabilizer 770',     'RM-UV-007',   'Stabilizer',     'Clariant Chemicals',       'kg', 180,   100,  500,   1250.00),
('White Masterbatch',     'RM-WMB-008',  'Colorant',       'Cabot India Ltd',          'kg', 2100,  300,  4000,  220.00),
('Black Masterbatch',     'RM-BMB-009',  'Colorant',       'Cabot India Ltd',          'kg', 1800,  300,  4000,  195.00),
('TiO2 Pigment',          'RM-TIO2-010', 'Colorant',       'Huntsman Corporation',     'kg', 450,   150,  1500,  380.00),
('DOP Plasticizer',       'RM-DOP-011',  'Plasticizer',    'Aekyung Petrochemical',    'kg', 3200,  500,  6000,  95.00),
('DINP Plasticizer',      'RM-DINP-012', 'Plasticizer',    'Aekyung Petrochemical',    'kg', 2800,  500,  6000,  105.00),
('CaCO3 Filler',          'RM-CAC-013',  'Filler',         'Omya India Pvt Ltd',       'kg', 18000, 3000, 30000, 18.50),
('Talc Powder',           'RM-TALC-014', 'Filler',         'Imerys India',             'kg', 5500,  1000, 10000, 28.00),
('Antioxidant Irganox',   'RM-AOX-015',  'Additive',       'BASF India',               'kg', 85,    50,   500,   2800.00),
('Processing Aid PTFE',   'RM-PTFE-016', 'Additive',       'Dyneon India',             'kg', 120,   50,   300,   3500.00),
('Flame Retardant Mg(OH)2','RM-FR-017',  'Additive',       'ICL Group India',          'kg', 1600,  400,  3000,  245.00),
('Slip Agent Erucamide',  'RM-SA-018',   'Additive',       'Croda India',              'kg', 220,   100,  600,   680.00),
('Blowing Agent Azodicarbonamide','RM-BA-019','Additive',  'Akzo Nobel India',         'kg', 55,    30,   200,   850.00),
('Nylon 6 Resin',         'RM-NYL6-020', 'Polymer Resin',  'BASF India',               'kg', 1200,  300,  4000,  320.00)
ON CONFLICT (material_code) DO NOTHING;

-- =====================================================
-- QUALITY PARAMETERS
-- =====================================================
INSERT INTO quality_parameters (parameter_name, parameter_code, unit, is_critical) VALUES
('Melt Flow Index',      'MFI',   'g/10min', TRUE),
('Density',              'DEN',   'g/cm³',   TRUE),
('Tensile Strength',     'TS',    'MPa',     TRUE),
('Elongation at Break',  'EAB',   '%',       FALSE),
('Moisture Content',     'MC',    '%',       TRUE),
('Shore Hardness',       'SH',    'Shore D', FALSE),
('Color L Value',        'CLV',   '',        FALSE),
('Vicat Softening Temp', 'VST',   '°C',      FALSE),
('Impact Strength',      'IS',    'kJ/m²',   FALSE),
('Ash Content',          'ASH',   '%',       FALSE)
ON CONFLICT (parameter_code) DO NOTHING;

-- =====================================================
-- PRODUCTION BATCHES (last 30 days)
-- =====================================================
INSERT INTO production_batches (id, batch_number, product_id, machine_id, operator_id, production_date, planned_quantity, produced_quantity, rejected_quantity, unit, start_time, end_time, status, quality_status, remarks, created_by) VALUES
('aaaa0001-0001-0001-0001-000000000001','BATCH-2026-0901',1,1,'22222222-2222-2222-2222-222222222222','2026-09-01',5000,4950,75,'kg','2026-09-01 07:00:00+05:30','2026-09-01 19:00:00+05:30','completed','approved','Good run','11111111-1111-1111-1111-111111111111'),
('aaaa0002-0002-0002-0002-000000000002','BATCH-2026-0902',2,8,'55555555-5555-5555-5555-555555555555','2026-09-02',3000,2850,140,'kg','2026-09-02 06:00:00+05:30','2026-09-02 18:00:00+05:30','completed','rejected','Film thickness out of spec','11111111-1111-1111-1111-111111111111'),
('aaaa0003-0003-0003-0003-000000000003','BATCH-2026-0903',3,3,'22222222-2222-2222-2222-222222222222','2026-09-03',4500,4480,22,'kg','2026-09-03 07:00:00+05:30','2026-09-03 19:00:00+05:30','completed','approved','','11111111-1111-1111-1111-111111111111'),
('aaaa0004-0004-0004-0004-000000000004','BATCH-2026-0905',4,3,'55555555-5555-5555-5555-555555555555','2026-09-05',4000,3980,38,'kg','2026-09-05 07:00:00+05:30','2026-09-05 19:00:00+05:30','completed','approved','','11111111-1111-1111-1111-111111111111'),
('aaaa0005-0005-0005-0005-000000000005','BATCH-2026-0907',5,1,'22222222-2222-2222-2222-222222222222','2026-09-07',6000,5820,180,'kg','2026-09-07 06:00:00+05:30','2026-09-07 20:00:00+05:30','completed','approved','Minor colour variation','11111111-1111-1111-1111-111111111111'),
('aaaa0006-0006-0006-0006-000000000006','BATCH-2026-0908',6,1,'55555555-5555-5555-5555-555555555555','2026-09-08',5500,5450,55,'kg','2026-09-08 07:00:00+05:30','2026-09-08 19:00:00+05:30','completed','approved','','11111111-1111-1111-1111-111111111111'),
('aaaa0007-0007-0007-0007-000000000007','BATCH-2026-0910',7,3,'22222222-2222-2222-2222-222222222222','2026-09-10',2500,2480,20,'kg','2026-09-10 08:00:00+05:30','2026-09-10 18:00:00+05:30','completed','approved','','11111111-1111-1111-1111-111111111111'),
('aaaa0008-0008-0008-0008-000000000008','BATCH-2026-0912',1,1,'55555555-5555-5555-5555-555555555555','2026-09-12',5000,4900,200,'kg','2026-09-12 06:00:00+05:30','2026-09-12 18:00:00+05:30','completed','rejected','High moisture content','11111111-1111-1111-1111-111111111111'),
('aaaa0009-0009-0009-0009-000000000009','BATCH-2026-0914',3,3,'22222222-2222-2222-2222-222222222222','2026-09-14',4500,4465,35,'kg','2026-09-14 07:00:00+05:30','2026-09-14 19:00:00+05:30','completed','approved','','11111111-1111-1111-1111-111111111111'),
('aaaa0010-0010-0010-0010-000000000010','BATCH-2026-0916',8,3,'55555555-5555-5555-5555-555555555555','2026-09-16',2000,1980,18,'kg','2026-09-16 08:00:00+05:30','2026-09-16 18:00:00+05:30','completed','approved','Nylon 6 batch OK','11111111-1111-1111-1111-111111111111'),
('aaaa0011-0011-0011-0011-000000000011','BATCH-2026-0918',4,3,'22222222-2222-2222-2222-222222222222','2026-09-18',4000,3950,45,'kg','2026-09-18 07:00:00+05:30','2026-09-18 19:00:00+05:30','completed','approved','','11111111-1111-1111-1111-111111111111'),
('aaaa0012-0012-0012-0012-000000000012','BATCH-2026-0920',2,8,'55555555-5555-5555-5555-555555555555','2026-09-20',3000,2780,220,'kg','2026-09-20 06:00:00+05:30','2026-09-20 18:00:00+05:30','completed','rejected','Thickness non-uniform','11111111-1111-1111-1111-111111111111'),
('aaaa0013-0013-0013-0013-000000000013','BATCH-2026-0922',5,1,'22222222-2222-2222-2222-222222222222','2026-09-22',6000,5950,60,'kg','2026-09-22 06:00:00+05:30','2026-09-22 20:00:00+05:30','completed','approved','','11111111-1111-1111-1111-111111111111'),
('aaaa0014-0014-0014-0014-000000000014','BATCH-2026-0924',7,3,'55555555-5555-5555-5555-555555555555','2026-09-24',2500,2450,25,'kg','2026-09-24 08:00:00+05:30','2026-09-24 18:00:00+05:30','completed','approved','','11111111-1111-1111-1111-111111111111'),
('aaaa0015-0015-0015-0015-000000000015','BATCH-2026-0926',3,1,'22222222-2222-2222-2222-222222222222','2026-09-26',4500,4200,150,'kg','2026-09-26 07:00:00+05:30','2026-09-26 17:00:00+05:30','on_hold','pending','Power fluctuation halt','11111111-1111-1111-1111-111111111111'),
('aaaa0016-0016-0016-0016-000000000016','BATCH-2026-0927',1,1,'22222222-2222-2222-2222-222222222222','2026-09-27',5000,3200,0,'kg','2026-09-27 07:00:00+05:30',NULL,'in_progress','pending','Currently running','11111111-1111-1111-1111-111111111111'),
('aaaa0017-0017-0017-0017-000000000017','BATCH-2026-0928',4,3,'55555555-5555-5555-5555-555555555555','2026-09-28',4000,0,0,'kg',NULL,NULL,'planned','pending','Scheduled for today','11111111-1111-1111-1111-111111111111'),
('aaaa0018-0018-0018-0018-000000000018','BATCH-2026-0928B',6,5,'22222222-2222-2222-2222-222222222222','2026-09-28',5500,0,0,'kg',NULL,NULL,'planned','pending','Evening shift','11111111-1111-1111-1111-111111111111')
ON CONFLICT (batch_number) DO NOTHING;

-- =====================================================
-- MATERIAL CONSUMPTION
-- =====================================================
INSERT INTO material_consumption (batch_id, material_id, quantity_used, unit, operator_id) VALUES
-- Batch 1 (HDPE-A)
('aaaa0001-0001-0001-0001-000000000001', 1, 4800, 'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0001-0001-0001-0001-000000000001', 6, 48,   'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0001-0001-0001-0001-000000000001', 8, 120,  'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0001-0001-0001-0001-000000000001', 15,5,    'kg', '44444444-4444-4444-4444-444444444444'),
-- Batch 2 (LDPE Film)
('aaaa0002-0002-0002-0002-000000000002', 2, 2700, 'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0002-0002-0002-0002-000000000002', 7, 12,   'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0002-0002-0002-0002-000000000002', 18,8,    'kg', '44444444-4444-4444-4444-444444444444'),
-- Batch 3 (PP Homo)
('aaaa0003-0003-0003-0003-000000000003', 3, 4200, 'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0003-0003-0003-0003-000000000003', 6, 42,   'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0003-0003-0003-0003-000000000003', 14,280,  'kg', '44444444-4444-4444-4444-444444444444'),
-- Batch 4 (PP Copoly)
('aaaa0004-0004-0004-0004-000000000004', 3, 3700, 'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0004-0004-0004-0004-000000000004', 9, 80,   'kg', '44444444-4444-4444-4444-444444444444'),
-- Batch 5 (PVC Rigid)
('aaaa0005-0005-0005-0005-000000000005', 4, 5400, 'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0005-0005-0005-0005-000000000005', 6, 120,  'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0005-0005-0005-0005-000000000005',13, 600,  'kg', '44444444-4444-4444-4444-444444444444'),
-- Batch 6 (PVC Flex)
('aaaa0006-0006-0006-0006-000000000006', 4, 3800, 'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0006-0006-0006-0006-000000000006',11,1200,  'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0006-0006-0006-0006-000000000006', 6, 60,   'kg', '44444444-4444-4444-4444-444444444444'),
-- Batch 7 (ABS)
('aaaa0007-0007-0007-0007-000000000007', 5, 2350, 'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0007-0007-0007-0007-000000000007', 9, 50,   'kg', '44444444-4444-4444-4444-444444444444'),
-- Batch 8 (HDPE repeat)
('aaaa0008-0008-0008-0008-000000000008', 1, 4700, 'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0008-0008-0008-0008-000000000008', 6, 47,   'kg', '44444444-4444-4444-4444-444444444444'),
('aaaa0008-0008-0008-0008-000000000008', 8, 118,  'kg', '44444444-4444-4444-4444-444444444444')
ON CONFLICT DO NOTHING;

-- =====================================================
-- QUALITY TESTS
-- =====================================================
INSERT INTO quality_tests (batch_id, parameter_id, tester_id, test_date, expected_value, actual_value, min_limit, max_limit, result, remarks) VALUES
-- Batch 1 (HDPE - approved)
('aaaa0001-0001-0001-0001-000000000001',1,'33333333-3333-3333-3333-333333333333','2026-09-01 20:00:00+05:30', 0.35, 0.34, 0.25, 0.45, 'pass', NULL),
('aaaa0001-0001-0001-0001-000000000001',2,'33333333-3333-3333-3333-333333333333','2026-09-01 20:00:00+05:30', 0.954,0.953,0.950,0.958,'pass', NULL),
('aaaa0001-0001-0001-0001-000000000001',3,'33333333-3333-3333-3333-333333333333','2026-09-01 20:00:00+05:30', 26.0, 26.5, 24.0, 30.0, 'pass', NULL),
('aaaa0001-0001-0001-0001-000000000001',5,'33333333-3333-3333-3333-333333333333','2026-09-01 20:00:00+05:30', 0.10, 0.08, 0.00, 0.15, 'pass', NULL),
-- Batch 2 (LDPE Film - rejected)
('aaaa0002-0002-0002-0002-000000000002',1,'33333333-3333-3333-3333-333333333333','2026-09-02 20:00:00+05:30', 2.0,  2.8,  1.5,  2.5,  'fail', 'MFI too high'),
('aaaa0002-0002-0002-0002-000000000002',5,'33333333-3333-3333-3333-333333333333','2026-09-02 20:00:00+05:30', 0.10, 0.22, 0.00, 0.15, 'fail', 'Moisture high'),
-- Batch 3 (PP Homo - approved)
('aaaa0003-0003-0003-0003-000000000003',1,'33333333-3333-3333-3333-333333333333','2026-09-03 20:00:00+05:30', 3.5,  3.6,  3.0,  4.0,  'pass', NULL),
('aaaa0003-0003-0003-0003-000000000003',2,'33333333-3333-3333-3333-333333333333','2026-09-03 20:00:00+05:30', 0.902,0.901,0.895,0.910,'pass', NULL),
('aaaa0003-0003-0003-0003-000000000003',3,'33333333-3333-3333-3333-333333333333','2026-09-03 20:00:00+05:30', 32.0, 33.5, 28.0, 38.0, 'pass', NULL),
('aaaa0003-0003-0003-0003-000000000003',5,'33333333-3333-3333-3333-333333333333','2026-09-03 20:00:00+05:30', 0.10, 0.09, 0.00, 0.15, 'pass', NULL),
-- Batch 4 (PP Copoly - approved)
('aaaa0004-0004-0004-0004-000000000004',1,'33333333-3333-3333-3333-333333333333','2026-09-05 20:00:00+05:30', 6.0,  5.8,  5.0,  7.0,  'pass', NULL),
('aaaa0004-0004-0004-0004-000000000004',9,'33333333-3333-3333-3333-333333333333','2026-09-05 20:00:00+05:30', 45.0, 47.0, 35.0, 55.0, 'pass', NULL),
-- Batch 5 (PVC Rigid - approved)
('aaaa0005-0005-0005-0005-000000000005',8,'33333333-3333-3333-3333-333333333333','2026-09-07 21:00:00+05:30', 78.0, 79.5, 75.0, 85.0, 'pass', NULL),
('aaaa0005-0005-0005-0005-000000000005',6,'33333333-3333-3333-3333-333333333333','2026-09-07 21:00:00+05:30', 80.0, 81.0, 78.0, 84.0, 'pass', NULL),
-- Batch 7 (ABS - approved)
('aaaa0007-0007-0007-0007-000000000007',1,'33333333-3333-3333-3333-333333333333','2026-09-10 19:00:00+05:30', 8.0,  7.8,  6.0,  10.0, 'pass', NULL),
('aaaa0007-0007-0007-0007-000000000007',3,'33333333-3333-3333-3333-333333333333','2026-09-10 19:00:00+05:30', 42.0, 43.5, 38.0, 48.0, 'pass', NULL),
('aaaa0007-0007-0007-0007-000000000007',9,'33333333-3333-3333-3333-333333333333','2026-09-10 19:00:00+05:30', 22.0, 20.5, 18.0, 28.0, 'pass', NULL),
-- Batch 8 (HDPE - rejected quality)
('aaaa0008-0008-0008-0008-000000000008',5,'33333333-3333-3333-3333-333333333333','2026-09-12 20:00:00+05:30', 0.10, 0.28, 0.00, 0.15, 'fail', 'Moisture well above limit'),
('aaaa0008-0008-0008-0008-000000000008',1,'33333333-3333-3333-3333-333333333333','2026-09-12 20:00:00+05:30', 0.35, 0.36, 0.25, 0.45, 'pass', NULL),
-- Batch 12 (LDPE - rejected)
('aaaa0012-0012-0012-0012-000000000012',1,'33333333-3333-3333-3333-333333333333','2026-09-20 20:00:00+05:30', 2.0,  3.1,  1.5,  2.5,  'fail', 'MFI high again')
ON CONFLICT DO NOTHING;

-- =====================================================
-- MACHINE DOWNTIME
-- =====================================================
INSERT INTO machine_downtime (machine_id, batch_id, start_time, end_time, duration_hours, reason, category, reported_by) VALUES
(1, 'aaaa0005-0005-0005-0005-000000000005','2026-09-07 13:00:00+05:30','2026-09-07 14:30:00+05:30',1.5, 'Screw wear — planned stop for lubrication', 'mechanical', '22222222-2222-2222-2222-222222222222'),
(3, 'aaaa0008-0008-0008-0008-000000000008','2026-09-12 15:00:00+05:30','2026-09-12 17:30:00+05:30',2.5, 'Heating element replacement',              'electrical',  '22222222-2222-2222-2222-222222222222'),
(4, NULL,'2026-09-25 08:00:00+05:30',NULL,NULL,'Hydraulic pump failure — awaiting parts','mechanical','22222222-2222-2222-2222-222222222222'),
(8, NULL,'2026-08-15 07:00:00+05:30','2026-09-25 18:00:00+05:30',982.0,'Major die head damage',               'mechanical',  '22222222-2222-2222-2222-222222222222'),
(1, 'aaaa0015-0015-0015-0015-000000000015','2026-09-26 12:00:00+05:30','2026-09-26 14:00:00+05:30',2.0, 'Power fluctuation caused shutdown',       'unplanned',   '22222222-2222-2222-2222-222222222222')
ON CONFLICT DO NOTHING;

-- =====================================================
-- MAINTENANCE RECORDS
-- =====================================================
INSERT INTO maintenance_records (machine_id, maintenance_type, maintenance_date, performed_by, cost, description, next_maintenance, status, created_by) VALUES
(1, 'preventive', '2026-08-15', 'ABC Engineering Services', 12500, 'Full screw and barrel inspection, lubrication, die cleaning', '2026-10-15', 'completed', '11111111-1111-1111-1111-111111111111'),
(2, 'preventive', '2026-07-20', 'ABC Engineering Services', 10000, 'Barrel temperature calibration and heater check', '2026-09-20', 'completed', '11111111-1111-1111-1111-111111111111'),
(3, 'corrective',  '2026-08-01', 'Krauss-Maffei Service',   35000, 'Heating element replacement (zone 3 and 4)', '2026-11-01', 'completed', '11111111-1111-1111-1111-111111111111'),
(4, 'emergency',   '2026-09-25', 'Engel Service Team',      85000, 'Hydraulic pump replacement (ongoing)', NULL, 'in_progress', '11111111-1111-1111-1111-111111111111'),
(5, 'preventive', '2026-09-01', 'XYZ Maintenance Co',       8500,  'Die head cleaning and mould inspection', '2026-12-01', 'completed', '11111111-1111-1111-1111-111111111111'),
(8, 'corrective',  '2026-08-15', 'Film Tech Services',      120000,'Complete die head replacement and film line overhaul', NULL, 'in_progress', '11111111-1111-1111-1111-111111111111')
ON CONFLICT DO NOTHING;

-- =====================================================
-- ALERTS (pre-populated)
-- =====================================================
INSERT INTO alerts (alert_type, severity, title, message, batch_id, machine_id, material_id, status) VALUES
('inventory', 'critical', 'Critical: PVC Resin Below Minimum Stock',
 'PVC Base Resin (RM-PVC-004) current stock 920 kg is below minimum level of 1000 kg. Immediate replenishment required.',
 NULL, NULL, 4, 'active'),

('inventory', 'high', 'Low Stock: Antioxidant Irganox',
 'Antioxidant Irganox (RM-AOX-015) current stock 85 kg is near minimum level of 50 kg. Please reorder soon.',
 NULL, NULL, 15, 'active'),

('inventory', 'medium', 'Low Stock: UV Stabilizer 770',
 'UV Stabilizer 770 (RM-UV-007) current stock 180 kg is approaching minimum level of 100 kg.',
 NULL, NULL, 7, 'acknowledged'),

('inventory', 'high', 'Low Stock: Blowing Agent',
 'Blowing Agent Azodicarbonamide (RM-BA-019) current stock 55 kg is near minimum level of 30 kg.',
 NULL, NULL, 19, 'active'),

('quality', 'critical', 'Quality FAIL: LDPE Film Batch BATCH-2026-0902',
 'Batch BATCH-2026-0902 failed MFI and Moisture quality tests. Batch marked as Quality Rejected. Review required.',
 'aaaa0002-0002-0002-0002-000000000002', NULL, NULL, 'acknowledged'),

('quality', 'high', 'Quality FAIL: HDPE Batch BATCH-2026-0912',
 'Batch BATCH-2026-0912 failed Moisture Content test (Actual: 0.28%, Limit: 0.15%). Batch rejected.',
 'aaaa0008-0008-0008-0008-000000000008', NULL, NULL, 'resolved'),

('machine', 'critical', 'Machine Offline: Film Line 1 (FLM-L1-08)',
 'Film Line 1 has been offline since 2026-08-15 due to die head damage. Total downtime: 982 hours. Urgent attention required.',
 NULL, 8, NULL, 'active'),

('machine', 'high', 'Machine Under Maintenance: Injection Moulder 2',
 'Injection Moulder 2 is under emergency maintenance due to hydraulic pump failure. No ETA for restoration.',
 NULL, 4, NULL, 'active'),

('production', 'medium', 'Production On Hold: Batch BATCH-2026-0926',
 'Batch BATCH-2026-0926 (PP Homopolymer) has been placed on hold due to power fluctuation. Efficiency impacted.',
 'aaaa0015-0015-0015-0015-000000000015', 1, NULL, 'active'),

('quality', 'high', 'Quality FAIL: LDPE Film Batch BATCH-2026-0920',
 'Batch BATCH-2026-0920 failed MFI quality test (Actual: 3.1 g/10min, Max: 2.5). Third LDPE issue this month.',
 'aaaa0012-0012-0012-0012-000000000012', NULL, NULL, 'active')
ON CONFLICT DO NOTHING;
