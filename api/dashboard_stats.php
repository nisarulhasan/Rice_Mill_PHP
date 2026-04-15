<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
checkPermission('dashboard','view');
json_response(['success'=>true,'data'=>[
  'purchase'=>(float)(fetch_one('SELECT COALESCE(SUM(total_amount),0) t FROM purchase_bills')['t']??0),
  'sales'=>(float)(fetch_one('SELECT COALESCE(SUM(total_amount),0) t FROM sales_invoices')['t']??0),
  'stock'=>(int)count_rows('products','deleted_at IS NULL'),
  'machines'=>(int)count_rows('machines',"status='running' AND deleted_at IS NULL")
]]);
