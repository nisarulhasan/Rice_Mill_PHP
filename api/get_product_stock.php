<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
checkPermission('inventory','view');
$productId=require_int($_GET['product_id'] ?? 0);
$data=fetch_all("SELECT w.id,w.name,COALESCE(SUM(CASE WHEN sm.movement_type='in' THEN sm.qty ELSE -sm.qty END),0) stock FROM warehouses w LEFT JOIN stock_movements sm ON sm.warehouse_id=w.id AND sm.product_id=? WHERE w.deleted_at IS NULL GROUP BY w.id",[$productId]);
json_response(['success'=>true,'data'=>$data]);
