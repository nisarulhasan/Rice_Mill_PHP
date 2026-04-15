<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';

if (!empty($_SESSION['user'])) redirect('/dashboard.php');
$error = '';
if (is_post()) {
    validateCSRF();
    $username = sanitize_text($_POST['username'] ?? '');
    $password = (string)($_POST['password'] ?? '');
    if (attemptLogin($username, $password)) {
        redirect('/dashboard.php');
    }
    $error = is_locked_out() ? 'Too many failed attempts. Try again after 5 minutes.' : 'Invalid credentials.';
}
?>
<!doctype html><html><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<script src="https://cdn.tailwindcss.com"></script><link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
</head><body class="min-h-screen bg-[url('https://images.unsplash.com/photo-1594041680534-e8c8cdebd659?auto=format&fit=crop&w=1600&q=80')] bg-cover bg-center">
<div class="min-h-screen bg-black/40 flex items-center justify-center p-4">
<form method="post" class="w-full max-w-md backdrop-blur-md bg-white/85 rounded-3xl shadow-2xl p-8">
<h1 class="text-3xl font-bold text-center bg-gradient-to-r from-emerald-600 to-blue-700 bg-clip-text text-transparent mb-2">Rice Mill ERP</h1>
<p class="text-center text-gray-500 mb-6">Sign in to continue</p>
<?= csrf_input() ?>
<?php if ($error): ?><div class="mb-4 bg-rose-100 text-rose-700 rounded-xl p-3"><?= e($error) ?></div><?php endif; ?>
<div class="relative mb-5"><input name="username" required class="peer w-full rounded-xl border px-4 py-3 placeholder-transparent" placeholder="Username"><label class="absolute left-3 -top-2 text-xs bg-white px-1">Username</label></div>
<div class="relative mb-5"><input id="password" type="password" name="password" required class="peer w-full rounded-xl border px-4 py-3 placeholder-transparent" placeholder="Password"><label class="absolute left-3 -top-2 text-xs bg-white px-1">Password</label><button type="button" onclick="password.type=password.type==='password'?'text':'password'" class="absolute right-3 top-3"><i class="fa fa-eye"></i></button></div>
<label class="flex items-center gap-2 mb-6"><input type="checkbox" name="remember">Remember me</label>
<button class="w-full py-3 rounded-xl bg-gradient-to-r from-emerald-600 to-emerald-700 text-white font-semibold hover:scale-[1.02] transition">Login</button>
</form></div></body></html>
