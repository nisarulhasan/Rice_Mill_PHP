<?php
declare(strict_types=1);

require_once __DIR__ . '/constants.php';

error_reporting(E_ALL);
ini_set('display_errors', '1');

if (session_status() === PHP_SESSION_NONE) {
    ini_set('session.use_strict_mode', '1');
    ini_set('session.cookie_httponly', '1');
    ini_set('session.cookie_samesite', 'Lax');
    session_name('RICE_ERP_SESSION');
    session_start();
}

date_default_timezone_set(DEFAULT_TIMEZONE);

header('X-Frame-Options: SAMEORIGIN');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: strict-origin-when-cross-origin');

if (empty($_SESSION['csrf_token'])) {
    $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
}

define('BASE_PATH', dirname(__DIR__));
define('BASE_URL', '/');
