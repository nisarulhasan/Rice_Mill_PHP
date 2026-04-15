<?php
declare(strict_types=1);
require_once __DIR__ . '/../config/config.php';
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/functions.php';

function requireLogin(): void
{
    if (empty($_SESSION['user'])) {
        flash('error', 'Please login to continue.');
        redirect('/login.php');
    }
}

function checkPermission(string $module, string $action = 'view'): void
{
    requireLogin();
    $role = current_role();
    if ($role === ROLE_ADMIN) return;
    $permissions = $_SESSION['user']['permissions'] ?? [];
    if (!($permissions[$module] ?? false) && !($permissions['all'] ?? false)) {
        http_response_code(403);
        exit('Access denied');
    }
}

function attemptLogin(string $username, string $password): bool
{
    if (is_locked_out()) {
        return false;
    }

    $stmt = db()->prepare('SELECT u.*, r.name role_name, r.permissions FROM users u JOIN roles r ON r.id=u.role_id WHERE u.username=:u AND u.deleted_at IS NULL LIMIT 1');
    $stmt->execute([':u' => $username]);
    $user = $stmt->fetch();

    if (!$user || !password_verify($password, $user['password_hash'])) {
        if (increment_login_attempt() >= 5) {
            set_lockout();
        }
        return false;
    }

    if (($user['status'] ?? '') !== STATUS_ACTIVE) {
        return false;
    }

    session_regenerate_id(true);
    reset_login_attempts();

    $_SESSION['user'] = [
        'id' => (int)$user['id'],
        'full_name' => $user['full_name'],
        'username' => $user['username'],
        'role' => $user['role_name'],
        'permissions' => json_decode((string)$user['permissions'], true) ?: [],
    ];

    db()->prepare('UPDATE users SET last_login_at=NOW(), failed_attempts=0 WHERE id=?')->execute([(int)$user['id']]);
    audit_log('auth', 'login', (int)$user['id']);
    return true;
}
