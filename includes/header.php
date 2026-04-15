<?php require_once __DIR__ . '/functions.php'; ?>
<!doctype html>
<html lang="en" class="h-full">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e(APP_NAME) ?></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
    <link rel="stylesheet" href="/assets/css/custom.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body class="h-full bg-gradient-to-br from-gray-50 to-gray-100 text-gray-800">
<div class="min-h-screen flex">
<?php include __DIR__ . '/sidebar.php'; ?>
<div class="flex-1 lg:ml-72">
<header class="sticky top-0 z-20 bg-white/70 backdrop-blur-md border-b border-white/30">
  <div class="px-4 py-3 flex items-center justify-between gap-3">
    <div class="relative w-full max-w-xl">
      <i class="fa fa-search absolute left-3 top-3 text-gray-400"></i>
      <input id="global-search" class="w-full rounded-xl pl-10 pr-4 py-2 bg-white/80 border border-gray-200 focus:ring-2 focus:ring-emerald-500" placeholder="Search anything... (Ctrl+K)">
    </div>
    <div class="flex items-center gap-4">
      <button id="dark-toggle" class="p-2 rounded-lg bg-gray-900 text-white"><i class="fa fa-moon"></i></button>
      <div class="text-right">
        <div class="font-semibold"><?= e(current_user_name()) ?></div>
        <div class="text-xs text-gray-500"><?= e(ucfirst(current_role())) ?></div>
      </div>
      <a href="/logout.php" class="px-3 py-2 rounded-lg bg-gradient-to-r from-rose-600 to-rose-700 text-white hover:scale-105 transition">Logout</a>
    </div>
  </div>
</header>
<main class="p-4 lg:p-8">
<?php if ($m = get_flash('success')): ?><div class="mb-4 rounded-xl bg-emerald-100 text-emerald-700 px-4 py-3"><?= e($m) ?></div><?php endif; ?>
<?php if ($m = get_flash('error')): ?><div class="mb-4 rounded-xl bg-rose-100 text-rose-700 px-4 py-3"><?= e($m) ?></div><?php endif; ?>
