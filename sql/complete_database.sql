
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS rice_mill_erp CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rice_mill_erp;

CREATE TABLE roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  permissions JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  role_id INT NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(120) UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  status ENUM('active','inactive','locked') DEFAULT 'active',
  failed_attempts INT DEFAULT 0,
  locked_until DATETIME NULL,
  last_login_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id) ON UPDATE CASCADE,
  INDEX idx_users_status(status),
  INDEX idx_users_deleted(deleted_at)
);
CREATE TABLE sessions (
  id VARCHAR(128) PRIMARY KEY,
  user_id INT NULL,
  ip_address VARCHAR(45),
  user_agent TEXT,
  payload LONGTEXT NOT NULL,
  last_activity INT NOT NULL,
  CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_sessions_last_activity(last_activity)
);
CREATE TABLE companies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(180) NOT NULL,
  gst_no VARCHAR(25),
  pan_no VARCHAR(20),
  address TEXT,
  phone VARCHAR(30),
  email VARCHAR(120),
  logo VARCHAR(255),
  fiscal_year_start DATE,
  fiscal_year_end DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
CREATE TABLE parties (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(30) UNIQUE,
  type ENUM('vendor','customer','broker','transporter','other') NOT NULL,
  name VARCHAR(150) NOT NULL,
  mobile VARCHAR(20),
  email VARCHAR(120),
  gst_no VARCHAR(25),
  pan_no VARCHAR(20),
  address TEXT,
  city VARCHAR(80),
  state VARCHAR(80),
  pincode VARCHAR(10),
  opening_balance DECIMAL(14,2) DEFAULT 0,
  credit_days INT DEFAULT 0,
  credit_limit DECIMAL(14,2) DEFAULT 0,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  INDEX idx_parties_name(name),
  INDEX idx_parties_type(type),
  INDEX idx_parties_deleted(deleted_at)
);
CREATE TABLE uoms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) UNIQUE,
  name VARCHAR(50) NOT NULL,
  decimal_places INT DEFAULT 2,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL
);
CREATE TABLE bag_types (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(60) NOT NULL,
  weight_kg DECIMAL(8,3) NOT NULL,
  deposit_amount DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL
);
CREATE TABLE warehouses (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(30) UNIQUE,
  name VARCHAR(120) NOT NULL,
  location VARCHAR(255),
  capacity_mt DECIMAL(12,2) NOT NULL,
  manager_name VARCHAR(120),
  phone VARCHAR(20),
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  INDEX idx_warehouses_name(name),
  INDEX idx_warehouses_deleted(deleted_at)
);
CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(30) UNIQUE,
  name VARCHAR(150) NOT NULL,
  category VARCHAR(80) NOT NULL,
  uom_id INT NOT NULL,
  hsn_code VARCHAR(20),
  gst_rate DECIMAL(5,2) DEFAULT 5.00,
  reorder_level DECIMAL(14,3) DEFAULT 0,
  image_path VARCHAR(255),
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_products_uom FOREIGN KEY (uom_id) REFERENCES uoms(id) ON UPDATE CASCADE,
  INDEX idx_products_name(name),
  INDEX idx_products_cat(category),
  INDEX idx_products_deleted(deleted_at)
);
CREATE TABLE machines (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(30) UNIQUE,
  name VARCHAR(120) NOT NULL,
  section VARCHAR(80),
  status ENUM('running','stopped','maintenance','breakdown') DEFAULT 'stopped',
  installed_on DATE,
  capacity_tph DECIMAL(8,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  INDEX idx_machines_status(status),
  INDEX idx_machines_deleted(deleted_at)
);
CREATE TABLE stock_batches (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  warehouse_id INT NOT NULL,
  batch_no VARCHAR(40),
  mfg_date DATE NULL,
  exp_date DATE NULL,
  qty DECIMAL(14,3) NOT NULL,
  rate DECIMAL(14,2) NOT NULL,
  source_type VARCHAR(30),
  source_id BIGINT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sb_product FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  CONSTRAINT fk_sb_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON UPDATE CASCADE,
  INDEX idx_sb_prod_wh(product_id,warehouse_id)
);
CREATE TABLE stock_movements (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  movement_date DATETIME NOT NULL,
  product_id INT NOT NULL,
  warehouse_id INT NOT NULL,
  movement_type ENUM('in','out','transfer','adjustment','production') NOT NULL,
  qty DECIMAL(14,3) NOT NULL,
  rate DECIMAL(14,2) DEFAULT 0,
  reference_type VARCHAR(40),
  reference_id BIGINT,
  narration VARCHAR(255),
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sm_product FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  CONSTRAINT fk_sm_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON UPDATE CASCADE,
  CONSTRAINT fk_sm_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_sm_date(movement_date), INDEX idx_sm_ref(reference_type,reference_id)
);
CREATE TABLE purchase_bargains (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  bargain_no VARCHAR(30) UNIQUE,
  bargain_date DATE NOT NULL,
  party_id INT NOT NULL,
  broker_id INT NULL,
  product_id INT NOT NULL,
  qty DECIMAL(14,3) NOT NULL,
  rate DECIMAL(14,2) NOT NULL,
  status ENUM('open','closed','cancelled') DEFAULT 'open',
  remarks VARCHAR(255),
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_pb_party FOREIGN KEY (party_id) REFERENCES parties(id) ON UPDATE CASCADE,
  CONSTRAINT fk_pb_broker FOREIGN KEY (broker_id) REFERENCES parties(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_pb_product FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  CONSTRAINT fk_pb_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_pb_date(bargain_date), INDEX idx_pb_status(status)
);
CREATE TABLE purchase_quality_checks (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  bargain_id BIGINT NOT NULL,
  moisture DECIMAL(5,2) DEFAULT 0,
  broken DECIMAL(5,2) DEFAULT 0,
  damage DECIMAL(5,2) DEFAULT 0,
  foreign_matter DECIMAL(5,2) DEFAULT 0,
  total_deduction_pct DECIMAL(6,3) DEFAULT 0,
  final_rate DECIMAL(14,2) DEFAULT 0,
  checked_by INT,
  checked_at DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pqc_bargain FOREIGN KEY (bargain_id) REFERENCES purchase_bargains(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pqc_user FOREIGN KEY (checked_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE purchase_bills (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  bill_no VARCHAR(40) UNIQUE,
  bill_date DATE NOT NULL,
  party_id INT NOT NULL,
  bargain_id BIGINT NULL,
  subtotal DECIMAL(14,2) NOT NULL,
  gst_amount DECIMAL(14,2) DEFAULT 0,
  freight DECIMAL(14,2) DEFAULT 0,
  other_charges DECIMAL(14,2) DEFAULT 0,
  total_amount DECIMAL(14,2) NOT NULL,
  due_date DATE,
  status ENUM('draft','posted','paid','cancelled') DEFAULT 'draft',
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_pbill_party FOREIGN KEY (party_id) REFERENCES parties(id) ON UPDATE CASCADE,
  CONSTRAINT fk_pbill_bargain FOREIGN KEY (bargain_id) REFERENCES purchase_bargains(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_pbill_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_pbill_date(bill_date), INDEX idx_pbill_status(status)
);
CREATE TABLE purchase_bill_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  bill_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  warehouse_id INT NOT NULL,
  qty DECIMAL(14,3) NOT NULL,
  rate DECIMAL(14,2) NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  bag_type_id INT NULL,
  bags INT DEFAULT 0,
  CONSTRAINT fk_pbi_bill FOREIGN KEY (bill_id) REFERENCES purchase_bills(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pbi_product FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  CONSTRAINT fk_pbi_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON UPDATE CASCADE,
  CONSTRAINT fk_pbi_bag FOREIGN KEY (bag_type_id) REFERENCES bag_types(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE sales_bargains (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  bargain_no VARCHAR(30) UNIQUE,
  bargain_date DATE NOT NULL,
  party_id INT NOT NULL,
  broker_id INT NULL,
  product_id INT NOT NULL,
  qty DECIMAL(14,3) NOT NULL,
  rate DECIMAL(14,2) NOT NULL,
  status ENUM('open','closed','cancelled') DEFAULT 'open',
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_sbarg_party FOREIGN KEY (party_id) REFERENCES parties(id) ON UPDATE CASCADE,
  CONSTRAINT fk_sbarg_broker FOREIGN KEY (broker_id) REFERENCES parties(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_sbarg_product FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  CONSTRAINT fk_sbarg_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE sales_invoices (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  invoice_no VARCHAR(40) UNIQUE,
  invoice_date DATE NOT NULL,
  party_id INT NOT NULL,
  bargain_id BIGINT NULL,
  subtotal DECIMAL(14,2) NOT NULL,
  gst_amount DECIMAL(14,2) DEFAULT 0,
  freight DECIMAL(14,2) DEFAULT 0,
  total_amount DECIMAL(14,2) NOT NULL,
  due_date DATE,
  status ENUM('draft','posted','paid','partial','cancelled') DEFAULT 'draft',
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_sinv_party FOREIGN KEY (party_id) REFERENCES parties(id) ON UPDATE CASCADE,
  CONSTRAINT fk_sinv_bargain FOREIGN KEY (bargain_id) REFERENCES sales_bargains(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_sinv_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_sinv_date(invoice_date)
);
CREATE TABLE sales_invoice_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  invoice_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  warehouse_id INT NOT NULL,
  qty DECIMAL(14,3) NOT NULL,
  rate DECIMAL(14,2) NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  bag_type_id INT NULL,
  bags INT DEFAULT 0,
  CONSTRAINT fk_sii_invoice FOREIGN KEY (invoice_id) REFERENCES sales_invoices(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_sii_product FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE,
  CONSTRAINT fk_sii_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON UPDATE CASCADE,
  CONSTRAINT fk_sii_bag FOREIGN KEY (bag_type_id) REFERENCES bag_types(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE trucks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  truck_no VARCHAR(30) UNIQUE,
  owner_party_id INT,
  driver_name VARCHAR(120),
  driver_mobile VARCHAR(20),
  license_expiry DATE,
  insurance_expiry DATE,
  permit_expiry DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_truck_owner FOREIGN KEY (owner_party_id) REFERENCES parties(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE logistics_allocations (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  invoice_id BIGINT,
  truck_id INT,
  transporter_id INT,
  freight_rate DECIMAL(12,2),
  freight_amount DECIMAL(14,2),
  status ENUM('assigned','in_transit','delivered','cancelled') DEFAULT 'assigned',
  allocated_at DATETIME,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_la_invoice FOREIGN KEY (invoice_id) REFERENCES sales_invoices(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_la_truck FOREIGN KEY (truck_id) REFERENCES trucks(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_la_transporter FOREIGN KEY (transporter_id) REFERENCES parties(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_la_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE truck_tracking (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  allocation_id BIGINT NOT NULL,
  latitude DECIMAL(10,7),
  longitude DECIMAL(10,7),
  status_note VARCHAR(150),
  event_time DATETIME,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tt_alloc FOREIGN KEY (allocation_id) REFERENCES logistics_allocations(id) ON DELETE CASCADE ON UPDATE CASCADE,
  INDEX idx_tt_event(event_time)
);
CREATE TABLE production_entries (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  batch_no VARCHAR(40) UNIQUE,
  entry_date DATE NOT NULL,
  input_product_id INT NOT NULL,
  input_qty DECIMAL(14,3) NOT NULL,
  output_product_id INT NOT NULL,
  output_qty DECIMAL(14,3) NOT NULL,
  wastage_qty DECIMAL(14,3) DEFAULT 0,
  machine_id INT NULL,
  shift ENUM('A','B','C') DEFAULT 'A',
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_pe_iprod FOREIGN KEY (input_product_id) REFERENCES products(id) ON UPDATE CASCADE,
  CONSTRAINT fk_pe_oprod FOREIGN KEY (output_product_id) REFERENCES products(id) ON UPDATE CASCADE,
  CONSTRAINT fk_pe_machine FOREIGN KEY (machine_id) REFERENCES machines(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_pe_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE machine_status_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  machine_id INT NOT NULL,
  status ENUM('running','stopped','maintenance','breakdown') NOT NULL,
  reason VARCHAR(200),
  start_time DATETIME,
  end_time DATETIME NULL,
  updated_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_msl_machine FOREIGN KEY (machine_id) REFERENCES machines(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_msl_user FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE quality_rules (
  id INT AUTO_INCREMENT PRIMARY KEY,
  parameter_name VARCHAR(80) NOT NULL,
  threshold_from DECIMAL(8,2) NOT NULL,
  threshold_to DECIMAL(8,2) NOT NULL,
  deduction_pct DECIMAL(6,3) NOT NULL,
  is_active TINYINT(1) DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE chart_of_accounts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  account_code VARCHAR(20) UNIQUE,
  account_name VARCHAR(150) NOT NULL,
  account_type ENUM('asset','liability','equity','income','expense') NOT NULL,
  parent_id INT NULL,
  is_group TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_coa_parent FOREIGN KEY (parent_id) REFERENCES chart_of_accounts(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_coa_type(account_type)
);
CREATE TABLE vouchers (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  voucher_no VARCHAR(40) UNIQUE,
  voucher_date DATE NOT NULL,
  voucher_type ENUM('payment','receipt','journal','contra') NOT NULL,
  narration VARCHAR(255),
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_voucher_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE voucher_lines (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  voucher_id BIGINT NOT NULL,
  account_id INT NOT NULL,
  dr_amount DECIMAL(14,2) DEFAULT 0,
  cr_amount DECIMAL(14,2) DEFAULT 0,
  party_id INT NULL,
  reference_no VARCHAR(60),
  CONSTRAINT fk_vl_voucher FOREIGN KEY (voucher_id) REFERENCES vouchers(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_vl_account FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id) ON UPDATE CASCADE,
  CONSTRAINT fk_vl_party FOREIGN KEY (party_id) REFERENCES parties(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE bank_reconciliation (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  account_id INT NOT NULL,
  txn_date DATE NOT NULL,
  description VARCHAR(255),
  amount DECIMAL(14,2) NOT NULL,
  txn_type ENUM('debit','credit') NOT NULL,
  source ENUM('book','bank') NOT NULL,
  matched_with BIGINT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_br_account FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id) ON UPDATE CASCADE
);
CREATE TABLE activity_logs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NULL,
  module_name VARCHAR(80),
  action_name VARCHAR(80),
  record_id VARCHAR(80),
  old_values JSON,
  new_values JSON,
  ip_address VARCHAR(45),
  user_agent VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_al_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
  INDEX idx_al_module(module_name), INDEX idx_al_created(created_at)
);
CREATE TABLE notifications (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  title VARCHAR(120),
  message VARCHAR(255),
  is_read TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE TABLE file_uploads (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  module_name VARCHAR(50),
  record_id BIGINT,
  file_name VARCHAR(255),
  file_path VARCHAR(255),
  mime_type VARCHAR(120),
  file_size INT,
  uploaded_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_fu_user FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE stock_adjustments (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  adjustment_no VARCHAR(40) UNIQUE,
  adjustment_date DATE,
  warehouse_id INT,
  reason VARCHAR(200),
  status ENUM('draft','pending','approved','rejected') DEFAULT 'draft',
  approved_by INT NULL,
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sa_wh FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_sa_approved FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_sa_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE stock_adjustment_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  adjustment_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  system_qty DECIMAL(14,3) NOT NULL,
  physical_qty DECIMAL(14,3) NOT NULL,
  variance_qty DECIMAL(14,3) NOT NULL,
  CONSTRAINT fk_sai_adjust FOREIGN KEY (adjustment_id) REFERENCES stock_adjustments(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_sai_product FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE
);
CREATE TABLE physical_counts (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  count_no VARCHAR(40) UNIQUE,
  warehouse_id INT NOT NULL,
  count_date DATE NOT NULL,
  status ENUM('open','submitted','approved') DEFAULT 'open',
  created_by INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pc_wh FOREIGN KEY (warehouse_id) REFERENCES warehouses(id) ON UPDATE CASCADE,
  CONSTRAINT fk_pc_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE physical_count_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  physical_count_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  counted_qty DECIMAL(14,3) NOT NULL,
  CONSTRAINT fk_pci_pc FOREIGN KEY (physical_count_id) REFERENCES physical_counts(id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pci_product FOREIGN KEY (product_id) REFERENCES products(id) ON UPDATE CASCADE
);
CREATE TABLE bag_transactions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  txn_date DATE NOT NULL,
  party_id INT,
  bag_type_id INT,
  txn_type ENUM('issue','return','purchase','scrap') NOT NULL,
  qty INT NOT NULL,
  rate DECIMAL(10,2) DEFAULT 0,
  reference_type VARCHAR(40),
  reference_id BIGINT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_bt_party FOREIGN KEY (party_id) REFERENCES parties(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_bt_bag FOREIGN KEY (bag_type_id) REFERENCES bag_types(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE gate_passes (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  pass_no VARCHAR(40) UNIQUE,
  pass_date DATE NOT NULL,
  purchase_bill_id BIGINT,
  sales_invoice_id BIGINT,
  truck_no VARCHAR(30),
  qr_payload VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_gp_pb FOREIGN KEY (purchase_bill_id) REFERENCES purchase_bills(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_gp_si FOREIGN KEY (sales_invoice_id) REFERENCES sales_invoices(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE sales_returns (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  return_no VARCHAR(40) UNIQUE,
  return_date DATE,
  invoice_id BIGINT,
  party_id INT,
  amount DECIMAL(14,2),
  reason VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sr_invoice FOREIGN KEY (invoice_id) REFERENCES sales_invoices(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_sr_party FOREIGN KEY (party_id) REFERENCES parties(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE purchase_returns (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  return_no VARCHAR(40) UNIQUE,
  return_date DATE,
  bill_id BIGINT,
  party_id INT,
  amount DECIMAL(14,2),
  reason VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pr_bill FOREIGN KEY (bill_id) REFERENCES purchase_bills(id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_pr_party FOREIGN KEY (party_id) REFERENCES parties(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE reminders (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  party_id INT,
  due_type ENUM('payable','receivable') NOT NULL,
  due_date DATE,
  amount DECIMAL(14,2),
  status ENUM('pending','sent','resolved') DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rem_party FOREIGN KEY (party_id) REFERENCES parties(id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE TABLE app_settings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  setting_key VARCHAR(100) UNIQUE,
  setting_value TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO roles(name, permissions) VALUES
('admin', JSON_OBJECT('all', true)),('manager', JSON_OBJECT('dashboard', true, 'masters', true, 'purchase', true, 'sales', true)),('operator', JSON_OBJECT('dashboard', true, 'inventory', true));
INSERT INTO users(role_id, full_name, username, email, password_hash) VALUES
(1,'System Admin','admin','admin@ricemill.local','$2y$12$knCCeZeXhzu4e99vuuNryeEdKPOuVdJYH3h/QN2jEpFX8VDf1Mf/S');
INSERT INTO companies(name, gst_no, pan_no, address, phone, email, fiscal_year_start, fiscal_year_end) VALUES
('Green Grain Rice Mill Pvt Ltd','27ABCDE1234F1Z5','ABCDE1234F','Industrial Area, Nashik','+91-9876543210','info@greengrain.test','2026-04-01','2027-03-31');

INSERT INTO uoms(code,name,decimal_places) VALUES ('KG','Kilogram',3),('QTL','Quintal',3),('BAG','Bag',0),('MT','Metric Ton',3),('LTR','Liter',3);
INSERT INTO bag_types(name,weight_kg,deposit_amount) VALUES
('PP 25KG',25,12),('PP 50KG',50,20),('Jute 50KG',50,35),('HDPE 25KG',25,15),('Non-Woven 10KG',10,8);
INSERT INTO warehouses(code,name,location,capacity_mt,manager_name,phone) VALUES
('WH-01','Main Godown','Plant Campus Block A',1200,'Ravi Patil','9876000001'),
('WH-02','Raw Paddy Yard','Plant Campus Block B',1800,'Amit Kale','9876000002'),
('WH-03','Finished Goods','MIDC Zone 2',900,'Sameer Joshi','9876000003'),
('WH-04','Packing Storage','MIDC Zone 3',600,'Neha Kulkarni','9876000004'),
('WH-05','Transit Warehouse','Highway Hub',750,'Pratik Shah','9876000005');

INSERT INTO parties(code,type,name,mobile,email,gst_no,city,state,pincode,opening_balance,credit_days,credit_limit) VALUES
('PTY-001','vendor','Shree Agro Traders','9800000001','p1@example.com','27GSTAA1001A1Z1','Nashik','MH','422001',25000,15,500000),
('PTY-002','vendor','Farm Fresh Procurement','9800000002','p2@example.com','27GSTAA1002A1Z1','Pune','MH','411001',19000,12,300000),
('PTY-003','vendor','Golden Paddy Suppliers','9800000003','p3@example.com','27GSTAA1003A1Z1','Kolhapur','MH','416001',0,10,250000),
('PTY-004','vendor','Rural Grain Mart','9800000004','p4@example.com','27GSTAA1004A1Z1','Satara','MH','415001',0,10,200000),
('PTY-005','vendor','Narmada Agro','9800000005','p5@example.com','27GSTAA1005A1Z1','Indore','MP','452001',5000,20,350000),
('PTY-006','customer','City Retail Foods','9800000006','p6@example.com','27GSTAA1006A1Z1','Mumbai','MH','400001',-12000,30,450000),
('PTY-007','customer','Prime Wholesale Hub','9800000007','p7@example.com','27GSTAA1007A1Z1','Thane','MH','400601',-8000,25,600000),
('PTY-008','customer','Taste Basket Stores','9800000008','p8@example.com','27GSTAA1008A1Z1','Nagpur','MH','440001',-5000,20,300000),
('PTY-009','customer','Daily Needs Supermart','9800000009','p9@example.com','27GSTAA1009A1Z1','Aurangabad','MH','431001',0,18,250000),
('PTY-010','customer','Shivaji Grocers','9800000010','p10@example.com','27GSTAA1010A1Z1','Nashik','MH','422001',0,12,200000),
('PTY-011','broker','Mandi Link Brokers','9800000011','p11@example.com','27GSTAA1011A1Z1','Nashik','MH','422001',0,0,0),
('PTY-012','broker','TradeBridge Associates','9800000012','p12@example.com','27GSTAA1012A1Z1','Pune','MH','411001',0,0,0),
('PTY-013','transporter','Swift Trans Logistics','9800000013','p13@example.com','27GSTAA1013A1Z1','Nashik','MH','422001',0,0,0),
('PTY-014','transporter','Highway Cargo Movers','9800000014','p14@example.com','27GSTAA1014A1Z1','Dhule','MH','424001',0,0,0),
('PTY-015','vendor','Sahyadri Farmers Group','9800000015','p15@example.com','27GSTAA1015A1Z1','Pune','MH','411001',0,10,100000),
('PTY-016','vendor','Krishna Dhan Traders','9800000016','p16@example.com','27GSTAA1016A1Z1','Sangli','MH','416416',0,20,150000),
('PTY-017','customer','Family Basket','9800000017','p17@example.com','27GSTAA1017A1Z1','Pune','MH','411001',0,15,180000),
('PTY-018','customer','Metro Foodline','9800000018','p18@example.com','27GSTAA1018A1Z1','Mumbai','MH','400002',0,25,500000),
('PTY-019','vendor','Vidarbha Paddy Supply','9800000019','p19@example.com','27GSTAA1019A1Z1','Amravati','MH','444601',0,14,220000),
('PTY-020','other','Quality Labs India','9800000020','p20@example.com','27GSTAA1020A1Z1','Nashik','MH','422001',0,0,0);

INSERT INTO products(code,name,category,uom_id,hsn_code,gst_rate,reorder_level) VALUES
('PRD-001','Raw Paddy Premium','Raw',1,'100610',5,12000),('PRD-002','Raw Paddy Standard','Raw',1,'100610',5,9000),('PRD-003','Boiled Rice','Finished',1,'100630',5,6000),('PRD-004','Steam Rice','Finished',1,'100630',5,6000),('PRD-005','Broken Rice','Byproduct',1,'100640',5,1000),('PRD-006','Rice Bran','Byproduct',1,'230240',5,800),('PRD-007','Rice Husk','Byproduct',1,'140490',5,800),('PRD-008','Parboiled Rice','Finished',1,'100630',5,4500),('PRD-009','Sona Masoori','Finished',1,'100630',5,3500),('PRD-010','Basmati Rice','Finished',1,'100630',5,2000),('PRD-011','Silky Rice','Finished',1,'100630',5,1500),('PRD-012','Packaging Twine','Consumable',3,'560790',18,200),('PRD-013','PP Bag 25KG','Packaging',3,'392329',18,1000),('PRD-014','PP Bag 50KG','Packaging',3,'392329',18,1200),('PRD-015','Diesel','Fuel',5,'271019',18,5000);

INSERT INTO machines(code,name,section,status,installed_on,capacity_tph) VALUES
('MC-001','Cleaner 1','Cleaning','running','2023-01-15',5.5),('MC-002','Dehusker 1','Milling','running','2023-02-20',4.2),('MC-003','Polisher 1','Polishing','stopped','2023-03-10',3.8),('MC-004','Grader 1','Grading','maintenance','2023-03-15',3.5),('MC-005','Color Sorter','Sorting','running','2023-04-12',2.2);

INSERT INTO quality_rules(parameter_name,threshold_from,threshold_to,deduction_pct) VALUES
('moisture',0,12,0),('moisture',12.01,14,0.5),('moisture',14.01,16,1.0),('broken',0,2,0),('broken',2.01,5,0.5),('broken',5.01,8,1.2),('damage',0,1,0),('damage',1.01,3,0.5),('foreign_matter',0,0.5,0),('foreign_matter',0.51,2,0.75);

INSERT INTO chart_of_accounts(account_code,account_name,account_type,parent_id,is_group) VALUES
('1000','Assets','asset',NULL,1),('1100','Current Assets','asset',1,1),('1110','Cash in Hand','asset',2,0),('1120','Bank Account - SBI','asset',2,0),('1130','Accounts Receivable','asset',2,0),('1140','Inventory - Raw Paddy','asset',2,0),('1150','Inventory - Finished Rice','asset',2,0),('1160','Inventory - Packaging','asset',2,0),('1170','Input GST','asset',2,0),('1180','Advance to Suppliers','asset',2,0),('1190','Security Deposits','asset',2,0),
('1200','Fixed Assets','asset',1,1),('1210','Plant & Machinery','asset',12,0),('1220','Vehicles','asset',12,0),('1230','Furniture','asset',12,0),('1240','Computers','asset',12,0),('1250','Accumulated Depreciation','asset',12,0),
('2000','Liabilities','liability',NULL,1),('2100','Current Liabilities','liability',18,1),('2110','Accounts Payable','liability',19,0),('2120','Output GST','liability',19,0),('2130','Expenses Payable','liability',19,0),('2140','Duties & Taxes','liability',19,0),('2150','Short-term Loan','liability',19,0),
('2200','Long-term Liabilities','liability',18,1),('2210','Term Loan','liability',25,0),
('3000','Equity','equity',NULL,1),('3100','Capital Account','equity',28,0),('3200','Retained Earnings','equity',28,0),
('4000','Income','income',NULL,1),('4100','Sales - Rice','income',31,0),('4110','Sales - Bran','income',31,0),('4120','Sales - Husk','income',31,0),('4130','Freight Income','income',31,0),('4140','Other Income','income',31,0),
('5000','Expenses','expense',NULL,1),('5100','Purchase - Paddy','expense',37,0),('5110','Packing Material','expense',37,0),('5120','Power & Fuel','expense',37,0),('5130','Wages & Salary','expense',37,0),('5140','Repairs & Maintenance','expense',37,0),('5150','Freight Outward','expense',37,0),('5160','Brokerage','expense',37,0),('5170','Admin Expenses','expense',37,0),('5180','Bad Debts','expense',37,0),('5190','Depreciation','expense',37,0),('5200','Bank Charges','expense',37,0),('5210','Insurance','expense',37,0),('5220','Telephone & Internet','expense',37,0),('5230','Rent','expense',37,0),('5240','Miscellaneous','expense',37,0);

INSERT INTO purchase_bargains(bargain_no,bargain_date,party_id,broker_id,product_id,qty,rate,status,created_by) VALUES
('PB-0001','2026-04-01',1,11,1,1200,24.20,'closed',1),('PB-0002','2026-04-02',2,12,2,900,23.80,'open',1),('PB-0003','2026-04-03',3,11,1,1500,24.10,'closed',1),('PB-0004','2026-04-04',4,12,2,600,23.50,'open',1),('PB-0005','2026-04-05',5,11,1,800,24.00,'closed',1),('PB-0006','2026-04-06',15,12,2,700,23.60,'open',1),('PB-0007','2026-04-07',16,11,1,1100,24.30,'open',1),('PB-0008','2026-04-08',19,12,2,950,23.70,'closed',1),('PB-0009','2026-04-09',1,11,1,500,24.00,'open',1),('PB-0010','2026-04-10',2,12,2,650,23.90,'closed',1);
INSERT INTO purchase_bills(bill_no,bill_date,party_id,bargain_id,subtotal,gst_amount,freight,total_amount,due_date,status,created_by) VALUES
('PUR-0001','2026-04-01',1,1,29040,1452,1200,31692,'2026-04-16','posted',1),('PUR-0002','2026-04-03',3,3,36150,1807.5,900,38857.5,'2026-04-18','posted',1),('PUR-0003','2026-04-05',5,5,19200,960,600,20760,'2026-04-20','posted',1),('PUR-0004','2026-04-08',19,8,22515,1125.75,700,24340.75,'2026-04-23','posted',1),('PUR-0005','2026-04-10',2,10,15535,776.75,550,16861.75,'2026-04-25','posted',1),('PUR-0006','2026-04-11',15,6,16520,826,500,17846,'2026-04-26','draft',1),('PUR-0007','2026-04-12',16,7,26730,1336.5,800,28866.5,'2026-04-27','draft',1),('PUR-0008','2026-04-13',1,9,12000,600,450,13050,'2026-04-28','posted',1),('PUR-0009','2026-04-14',4,4,14100,705,500,15305,'2026-04-29','draft',1),('PUR-0010','2026-04-15',2,2,21420,1071,650,23141,'2026-04-30','posted',1);
INSERT INTO purchase_bill_items(bill_id,product_id,warehouse_id,qty,rate,amount) VALUES
(1,1,2,1200,24.2,29040),(2,1,2,1500,24.1,36150),(3,1,2,800,24,19200),(4,2,2,950,23.7,22515),(5,2,2,650,23.9,15535),(6,2,2,700,23.6,16520),(7,1,2,1100,24.3,26730),(8,1,2,500,24,12000),(9,2,2,600,23.5,14100),(10,2,2,900,23.8,21420);

INSERT INTO sales_bargains(bargain_no,bargain_date,party_id,broker_id,product_id,qty,rate,status,created_by) VALUES
('SB-0001','2026-04-02',6,11,3,400,39.0,'open',1),('SB-0002','2026-04-03',7,12,4,350,40.0,'closed',1),('SB-0003','2026-04-04',8,11,8,280,42.0,'open',1),('SB-0004','2026-04-05',9,12,9,300,45.0,'open',1),('SB-0005','2026-04-06',10,11,10,200,70.0,'closed',1),('SB-0006','2026-04-07',17,12,3,150,38.0,'open',1),('SB-0007','2026-04-08',18,11,4,220,40.5,'open',1),('SB-0008','2026-04-09',6,12,11,120,48.0,'closed',1),('SB-0009','2026-04-10',7,11,3,260,39.5,'open',1),('SB-0010','2026-04-11',8,12,9,190,44.0,'open',1);
INSERT INTO sales_invoices(invoice_no,invoice_date,party_id,bargain_id,subtotal,gst_amount,freight,total_amount,due_date,status,created_by) VALUES
('INV-0001','2026-04-03',7,2,14000,700,500,15200,'2026-05-03','posted',1),('INV-0002','2026-04-06',10,5,14000,700,300,15000,'2026-04-26','paid',1),('INV-0003','2026-04-09',6,8,5760,288,200,6248,'2026-04-29','posted',1),('INV-0004','2026-04-11',7,9,10270,513.5,350,11133.5,'2026-05-01','partial',1),('INV-0005','2026-04-12',8,10,8360,418,250,9028,'2026-05-02','posted',1),('INV-0006','2026-04-13',9,4,13500,675,400,14575,'2026-05-03','draft',1),('INV-0007','2026-04-14',17,6,5700,285,150,6135,'2026-05-04','posted',1),('INV-0008','2026-04-15',18,7,8910,445.5,200,9555.5,'2026-05-05','posted',1),('INV-0009','2026-04-15',6,1,15600,780,350,16730,'2026-05-05','draft',1),('INV-0010','2026-04-15',8,3,11760,588,280,12628,'2026-05-05','posted',1);
INSERT INTO sales_invoice_items(invoice_id,product_id,warehouse_id,qty,rate,amount) VALUES
(1,4,3,350,40,14000),(2,10,3,200,70,14000),(3,11,3,120,48,5760),(4,3,3,260,39.5,10270),(5,9,3,190,44,8360),(6,9,3,300,45,13500),(7,3,3,150,38,5700),(8,4,3,220,40.5,8910),(9,3,3,400,39,15600),(10,8,3,280,42,11760);

INSERT INTO production_entries(batch_no,entry_date,input_product_id,input_qty,output_product_id,output_qty,wastage_qty,machine_id,shift,created_by) VALUES
('PRD-BAT-0001','2026-04-05',1,500,3,335,25,2,'A',1),('PRD-BAT-0002','2026-04-06',2,450,4,300,30,2,'B',1),('PRD-BAT-0003','2026-04-08',1,380,8,250,20,3,'A',1),('PRD-BAT-0004','2026-04-11',1,420,9,275,22,3,'C',1),('PRD-BAT-0005','2026-04-13',2,390,11,245,18,5,'B',1);

INSERT INTO stock_movements(movement_date,product_id,warehouse_id,movement_type,qty,rate,reference_type,reference_id,created_by)
SELECT CONCAT(bill_date,' 10:00:00'), product_id, warehouse_id, 'in', qty, rate, 'purchase_bill', bill_id, 1 FROM purchase_bill_items;
INSERT INTO stock_movements(movement_date,product_id,warehouse_id,movement_type,qty,rate,reference_type,reference_id,created_by)
SELECT CONCAT(invoice_date,' 14:00:00'), product_id, warehouse_id, 'out', qty, rate, 'sales_invoice', invoice_id, 1 FROM sales_invoice_items;

INSERT INTO trucks(truck_no,owner_party_id,driver_name,driver_mobile,license_expiry,insurance_expiry,permit_expiry) VALUES
('MH15AB1234',13,'Ramesh Pawar','9000000001','2027-03-10','2026-12-31','2026-11-30'),
('MH12CD5678',14,'Suresh Jadhav','9000000002','2026-10-20','2026-09-30','2026-08-15'),
('MH14EF9012',13,'Ganesh Shinde','9000000003','2027-01-10','2026-11-11','2026-10-21'),
('MH20GH3456',14,'Mohan Borse','9000000004','2026-08-08','2026-12-01','2026-07-22'),
('MH16IJ7890',13,'Nitin Kadam','9000000005','2027-02-02','2027-01-20','2026-12-31');

INSERT INTO logistics_allocations(invoice_id,truck_id,transporter_id,freight_rate,freight_amount,status,allocated_at,created_by) VALUES
(1,1,13,1200,1200,'delivered','2026-04-03 09:00:00',1),(2,2,14,1300,1300,'delivered','2026-04-06 10:00:00',1),(3,3,13,900,900,'in_transit','2026-04-09 11:30:00',1),(4,4,14,950,950,'assigned','2026-04-11 12:15:00',1),(5,5,13,980,980,'assigned','2026-04-12 12:45:00',1);

INSERT INTO app_settings(setting_key,setting_value) VALUES
('theme','light'),('items_per_page','25'),('currency_symbol','₹'),('default_timezone','Asia/Kolkata');

COMMIT;
