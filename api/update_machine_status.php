<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
checkPermission('machinery','edit');
validateCSRF();
$id=require_int($_POST['machine_id']??0); $status=sanitize_text($_POST['status']??'stopped'); $reason=sanitize_text($_POST['reason']??'');
execute_query('UPDATE machines SET status=?,updated_at=NOW() WHERE id=?',[$status,$id]);
execute_query('INSERT INTO machine_status_logs(machine_id,status,reason,start_time,updated_by) VALUES(?,?,?,?,?)',[$id,$status,$reason,now(),current_user_id()]);
audit_log('machinery','status_update',$id,[],['status'=>$status,'reason'=>$reason]);
json_response(['success'=>true]);
