<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
checkPermission('warehouse','view');
$rows=fetch_all('SELECT id,name,capacity_mt FROM warehouses WHERE deleted_at IS NULL');
foreach($rows as &$r){$util=warehouse_utilization((int)$r['id']);$r['used']=$util['used'];$r['pct']=$util['pct'];}
json_response(['success'=>true,'data'=>$rows]);
