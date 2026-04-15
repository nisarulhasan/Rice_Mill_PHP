<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
checkPermission('purchase','edit');
$base=require_float($_POST['base_rate'] ?? 0);
$mo=require_float($_POST['moisture'] ?? 0);$br=require_float($_POST['broken'] ?? 0);$da=require_float($_POST['damage'] ?? 0);$fm=require_float($_POST['foreign_matter'] ?? 0);
$tot=0; foreach(['moisture'=>$mo,'broken'=>$br,'damage'=>$da,'foreign_matter'=>$fm] as $p=>$v){$r=fetch_one('SELECT deduction_pct FROM quality_rules WHERE parameter_name=? AND ? BETWEEN threshold_from AND threshold_to AND is_active=1 LIMIT 1',[$p,$v]); $tot += (float)($r['deduction_pct'] ?? 0);} 
$final=round($base-(($base*$tot)/100),2);
json_response(['success'=>true,'total_deduction_pct'=>$tot,'final_rate'=>$final]);
