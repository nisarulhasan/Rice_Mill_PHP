<?php
declare(strict_types=1);
require_once __DIR__ . '/../config/database.php';

function db(): PDO { return Database::connection(); }
function e(string $v): string { return htmlspecialchars($v, ENT_QUOTES, 'UTF-8'); }
function now(): string { return date('Y-m-d H:i:s'); }
function today(): string { return date('Y-m-d'); }
function current_user_id(): ?int { return $_SESSION['user']['id'] ?? null; }
function current_user_name(): string { return $_SESSION['user']['full_name'] ?? 'Guest'; }
function current_role(): string { return $_SESSION['user']['role'] ?? ROLE_OPERATOR; }
function is_post(): bool { return $_SERVER['REQUEST_METHOD'] === 'POST'; }
function csrf_token(): string { return $_SESSION['csrf_token'] ?? ''; }
function csrf_input(): string { return '<input type="hidden" name="csrf_token" value="'.e(csrf_token()).'">'; }
function validateCSRF(): void { if (!hash_equals(csrf_token(), $_POST['csrf_token'] ?? '')) { http_response_code(419); exit('Invalid CSRF token'); } }
function redirect(string $url): never { header('Location: ' . $url); exit; }
function flash(string $key, string $msg): void { $_SESSION['flash'][$key] = $msg; }
function get_flash(string $key): ?string { $v = $_SESSION['flash'][$key] ?? null; unset($_SESSION['flash'][$key]); return $v; }
function money(float $v): string { return CURRENCY_SYMBOL . ' ' . number_format($v, 2); }
function qty(float $v): string { return number_format($v, 3); }
function generate_code(string $prefix, string $table, string $column = 'id'): string { $stmt = db()->query("SELECT MAX($column) m FROM $table"); $n=(int)$stmt->fetch()['m']+1; return sprintf('%s-%04d', strtoupper($prefix), $n); }
function audit_log(string $module, string $action, string|int $recordId, array $old = [], array $new = []): void {
  $stmt = db()->prepare('INSERT INTO activity_logs(user_id,module_name,action_name,record_id,old_values,new_values,ip_address,user_agent) VALUES(:u,:m,:a,:r,:o,:n,:ip,:ua)');
  $stmt->execute([':u'=>current_user_id(),':m'=>$module,':a'=>$action,':r'=>(string)$recordId,':o'=>json_encode($old),':n'=>json_encode($new),':ip'=>$_SERVER['REMOTE_ADDR'] ?? 'cli',':ua'=>substr($_SERVER['HTTP_USER_AGENT'] ?? 'CLI',0,250)]);
}
function fetch_all(string $sql, array $params=[]): array { $s=db()->prepare($sql); $s->execute($params); return $s->fetchAll(); }
function fetch_one(string $sql, array $params=[]): ?array { $s=db()->prepare($sql); $s->execute($params); $r=$s->fetch(); return $r?:null; }
function execute_query(string $sql, array $params=[]): bool { $s=db()->prepare($sql); return $s->execute($params); }
function require_int(mixed $v, int $default=0): int { return filter_var($v,FILTER_VALIDATE_INT)!==false?(int)$v:$default; }
function require_float(mixed $v, float $default=0): float { return filter_var($v,FILTER_VALIDATE_FLOAT)!==false?(float)$v:$default; }
function sanitize_text(?string $v): string { return trim((string)$v); }
function random_string(int $len=16): string { return bin2hex(random_bytes(max(1,$len/2))); }
function app_setting(string $key, string $default=''): string { $r=fetch_one('SELECT setting_value FROM app_settings WHERE setting_key=?',[$key]); return $r['setting_value'] ?? $default; }
function set_setting(string $key, string $value): void { execute_query('INSERT INTO app_settings(setting_key,setting_value) VALUES(?,?) ON DUPLICATE KEY UPDATE setting_value=VALUES(setting_value)',[$key,$value]); }
function paginate(int $page=1,int $per=25): array { $page=max(1,$page); $per=max(1,$per); return [($page-1)*$per,$per]; }
function json_response(array $data, int $code=200): never { http_response_code($code); header('Content-Type: application/json'); echo json_encode($data); exit; }
function back(): never { redirect($_SERVER['HTTP_REFERER'] ?? '/dashboard.php'); }
function login_attempt_key(): string { return 'login_attempts_' . ($_SERVER['REMOTE_ADDR'] ?? 'cli'); }
function increment_login_attempt(): int { $k=login_attempt_key(); $_SESSION[$k]=($_SESSION[$k]??0)+1; return $_SESSION[$k]; }
function reset_login_attempts(): void { unset($_SESSION[login_attempt_key()]); }
function login_attempts(): int { return (int)($_SESSION[login_attempt_key()] ?? 0); }
function lockout_seconds(): int { return max(0, 300 - ((int)($_SESSION['lockout_ts'] ?? 0) - time()) ); }
function set_lockout(): void { $_SESSION['lockout_ts'] = time() + 300; }
function is_locked_out(): bool { return (int)($_SESSION['lockout_ts'] ?? 0) > time(); }
function table_exists(string $t): bool { try { db()->query("SELECT 1 FROM $t LIMIT 1"); return true; } catch (Throwable $e){ return false; } }
function count_rows(string $t, string $where='1=1'): int { return (int)db()->query("SELECT COUNT(*) c FROM $t WHERE $where")->fetch()['c']; }
function stock_by_product(int $productId): float { $r=fetch_one("SELECT COALESCE(SUM(CASE WHEN movement_type='in' THEN qty ELSE -qty END),0) q FROM stock_movements WHERE product_id=?",[$productId]); return (float)($r['q']??0); }
function stock_by_product_warehouse(int $productId, int $warehouseId): float { $r=fetch_one("SELECT COALESCE(SUM(CASE WHEN movement_type='in' THEN qty ELSE -qty END),0) q FROM stock_movements WHERE product_id=? AND warehouse_id=?",[$productId,$warehouseId]); return (float)($r['q']??0); }
function warehouse_utilization(int $warehouseId): array { $cap=(float)(fetch_one('SELECT capacity_mt FROM warehouses WHERE id=?',[$warehouseId])['capacity_mt']??0); $used=(float)(fetch_one("SELECT COALESCE(SUM(CASE WHEN movement_type='in' THEN qty ELSE -qty END),0) q FROM stock_movements WHERE warehouse_id=?",[$warehouseId])['q']??0); $pct=$cap>0?min(100,($used/$cap)*100):0; return ['capacity'=>$cap,'used'=>$used,'pct'=>$pct]; }
function date_fmt(?string $d): string { return $d?date('d M Y', strtotime($d)):''; }
function datetime_fmt(?string $d): string { return $d?date('d M Y h:i A', strtotime($d)):''; }
function active_nav(string $path): string { return str_contains($_SERVER['SCRIPT_NAME'] ?? '', $path) ? 'bg-emerald-600 text-white' : 'text-gray-300 hover:bg-gray-700'; }
function require_fields(array $fields, array $input): array { $err=[]; foreach($fields as $f){ if(trim((string)($input[$f]??''))==='') $err[$f]="$f is required"; } return $err; }
function status_badge(string $status): string { $map=['open'=>'amber','closed'=>'emerald','cancelled'=>'rose','draft'=>'slate','posted'=>'blue','paid'=>'emerald','partial'=>'amber','running'=>'emerald','stopped'=>'slate','maintenance'=>'amber','breakdown'=>'rose']; $c=$map[$status]??'slate'; return "<span class='px-2 py-1 rounded-full text-xs bg-{$c}-100 text-{$c}-700'>".e(ucfirst($status))."</span>"; }
function upload_file(array $file, string $dir='uploads'): ?string { if (($file['error']??UPLOAD_ERR_NO_FILE)!==UPLOAD_ERR_OK) return null; if (($file['size']??0)>3*1024*1024) return null; $allowed=['image/jpeg','image/png','application/pdf']; if(!in_array($file['type']??'', $allowed,true)) return null; $ext=pathinfo($file['name'],PATHINFO_EXTENSION); $name=random_string(20).'.'.$ext; $path=BASE_PATH.'/'.$dir; if(!is_dir($path)) mkdir($path,0777,true); $dest=$path.'/'.$name; if(!move_uploaded_file($file['tmp_name'],$dest)) return null; return $dir.'/'.$name; }
function outstanding_age_bucket(string $dueDate): string { $days=(new DateTime($dueDate))->diff(new DateTime())->days; return $days<=30?'0-30':($days<=60?'31-60':($days<=90?'61-90':'90+')); }
function to_slug(string $txt): string { return trim(strtolower(preg_replace('/[^a-z0-9]+/i','-',$txt)),'-'); }
function calc_gst(float $amt,float $rate): float { return round(($amt*$rate)/100,2); }
function number_input_value(mixed $v): string { return is_numeric($v)?(string)$v:'0'; }
function old(string $k, string $default=''): string { return $_POST[$k] ?? $default; }
function remember_old_post(): void { $_SESSION['old_post']=$_POST; }
function consume_old_post(): array { $a=$_SESSION['old_post'] ?? []; unset($_SESSION['old_post']); return $a; }
