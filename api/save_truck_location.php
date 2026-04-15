<?php
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../includes/auth.php';
require_once __DIR__ . '/../includes/functions.php';
checkPermission('logistics','edit');
$allocation=require_int($_POST['allocation_id']??0);
$lat=require_float($_POST['latitude']??0);$lng=require_float($_POST['longitude']??0);$note=sanitize_text($_POST['status_note']??'Location updated');
execute_query('INSERT INTO truck_tracking(allocation_id,latitude,longitude,status_note,event_time) VALUES(?,?,?,?,NOW())',[$allocation,$lat,$lng,$note]);
json_response(['success'=>true]);
