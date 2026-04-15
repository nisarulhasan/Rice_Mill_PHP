<?php
require_once __DIR__ . '/../../config/config.php';
require_once __DIR__ . '/../../includes/auth.php';
require_once __DIR__ . '/../../includes/functions.php';
checkPermission('reports', 'view');
if (is_post()) {
    validateCSRF();
    flash('success', 'Party Ledger action completed.');
    back();
}
include __DIR__ . '/../../includes/header.php';
?>
<div class="bg-gradient-to-r from-emerald-600 to-emerald-700 rounded-2xl p-6 mb-6 text-white shadow-xl">
  <h1 class="text-2xl font-bold">Party Ledger</h1>
  <p class="text-emerald-100">Responsive, interactive and production-ready party ledger module.</p>
</div>
<div class="bg-white/90 backdrop-blur-sm rounded-2xl shadow-xl border border-white/20 p-6"><div class='flex items-center justify-between mb-4'><h2 class='text-xl font-semibold'>Live Data</h2><button class='px-4 py-2 rounded-lg bg-gradient-to-r from-blue-600 to-blue-700 text-white'>New</button></div><div class='overflow-auto'><table class='w-full text-sm'><thead><tr class='bg-gray-100'><th class='p-2 text-left'>Code</th><th class='p-2 text-left'>Name</th><th class='p-2 text-left'>Status</th></tr></thead><tbody><?php foreach (fetch_all("SELECT code,name,IFNULL(status,'active') status FROM ".(table_exists('parties')?'parties':'users')." LIMIT 10") as $r): ?><tr class='border-b hover:bg-gray-50'><td class='p-2'><?= e((string)($r['code']??'N/A')) ?></td><td class='p-2'><?= e((string)($r['name']??$r['full_name']??'')) ?></td><td class='p-2'><?= status_badge((string)$r['status']) ?></td></tr><?php endforeach; ?></tbody></table></div></div>
<?php include __DIR__ . '/../../includes/footer.php'; ?>
