<?php
require_once __DIR__ . '/config/config.php';
require_once __DIR__ . '/includes/auth.php';
require_once __DIR__ . '/includes/functions.php';
checkPermission('dashboard', 'view');
$stats = [
  'purchase' => (float)(fetch_one('SELECT COALESCE(SUM(total_amount),0) t FROM purchase_bills WHERE deleted_at IS NULL')['t'] ?? 0),
  'sales' => (float)(fetch_one('SELECT COALESCE(SUM(total_amount),0) t FROM sales_invoices WHERE deleted_at IS NULL')['t'] ?? 0),
  'stock_products' => count_rows('products','deleted_at IS NULL'),
  'parties' => count_rows('parties','deleted_at IS NULL'),
  'open_bargains' => count_rows('purchase_bargains',"status='open' AND deleted_at IS NULL"),
  'pending_invoices' => count_rows('sales_invoices',"status IN ('draft','partial') AND deleted_at IS NULL"),
  'running_machines' => count_rows('machines',"status='running' AND deleted_at IS NULL"),
  'alerts' => count_rows('products',"reorder_level > 0")
];
$recent = fetch_all('SELECT invoice_no, invoice_date, total_amount, status FROM sales_invoices ORDER BY id DESC LIMIT 8');
$lowStock = fetch_all("SELECT p.name, p.reorder_level, COALESCE(SUM(CASE WHEN sm.movement_type='in' THEN sm.qty ELSE -sm.qty END),0) stock FROM products p LEFT JOIN stock_movements sm ON sm.product_id=p.id WHERE p.deleted_at IS NULL GROUP BY p.id HAVING stock < p.reorder_level LIMIT 6");
include __DIR__ . '/includes/header.php';
?>
<div class="bg-gradient-to-r from-emerald-600 to-blue-700 rounded-2xl p-6 mb-8 text-white shadow-xl">
  <h1 class="text-3xl font-bold">Welcome, <?= e(current_user_name()) ?></h1>
  <p class="text-emerald-100">Today: <?= e(date('l, d M Y')) ?></p>
</div>
<div class="grid sm:grid-cols-2 xl:grid-cols-4 gap-5 mb-8">
<?php foreach ([['Total Purchase',money($stats['purchase']),'fa-cart-plus'],['Total Sales',money($stats['sales']),'fa-file-invoice'],['Products',(string)$stats['stock_products'],'fa-box'],['Parties',(string)$stats['parties'],'fa-users'],['Open Bargains',(string)$stats['open_bargains'],'fa-handshake'],['Pending Invoices',(string)$stats['pending_invoices'],'fa-clock'],['Running Machines',(string)$stats['running_machines'],'fa-cogs'],['Low Stock Alerts',(string)$stats['alerts'],'fa-triangle-exclamation']] as $card): ?>
<div class="group rounded-2xl bg-white/90 p-5 shadow-xl hover:shadow-2xl hover:scale-[1.02] transition-all">
  <div class="flex justify-between"><div><p class="text-gray-500 text-sm"><?= e($card[0]) ?></p><h3 class="text-xl font-bold mt-2"><?= e($card[1]) ?></h3></div><div class="w-11 h-11 rounded-xl bg-gradient-to-r from-emerald-600 to-emerald-700 text-white flex items-center justify-center"><i class="fa <?= $card[2] ?>"></i></div></div>
</div>
<?php endforeach; ?>
</div>
<div class="grid lg:grid-cols-2 gap-6 mb-8">
  <div class="bg-white/90 rounded-2xl shadow-xl p-5"><canvas id="lineChart" height="120"></canvas></div>
  <div class="bg-white/90 rounded-2xl shadow-xl p-5"><canvas id="barChart" height="120"></canvas></div>
  <div class="bg-white/90 rounded-2xl shadow-xl p-5"><canvas id="doughnutChart" height="120"></canvas></div>
  <div class="bg-white/90 rounded-2xl shadow-xl p-5"><canvas id="polarChart" height="120"></canvas></div>
</div>
<div class="grid lg:grid-cols-3 gap-6">
<div class="lg:col-span-2 bg-white/90 rounded-2xl shadow-xl p-6"><h3 class="font-semibold mb-4">Recent Transactions</h3><table class="w-full text-sm"><thead><tr class="text-left text-gray-500"><th>No</th><th>Date</th><th>Amount</th><th>Status</th></tr></thead><tbody><?php foreach($recent as $r): ?><tr class="border-t"><td class="py-2"><?= e($r['invoice_no']) ?></td><td><?= e($r['invoice_date']) ?></td><td><?= money((float)$r['total_amount']) ?></td><td><?= status_badge($r['status']) ?></td></tr><?php endforeach; ?></tbody></table></div>
<div class="bg-white/90 rounded-2xl shadow-xl p-6"><h3 class="font-semibold mb-4">Low Stock Alerts</h3><?php foreach($lowStock as $l): $pct=$l['reorder_level']>0?min(100,($l['stock']/$l['reorder_level'])*100):0; ?><div class="mb-4"><div class="flex justify-between text-sm"><span><?= e($l['name']) ?></span><span><?= qty((float)$l['stock']) ?></span></div><div class="h-2 rounded bg-gray-200"><div class="h-2 rounded bg-gradient-to-r from-amber-500 to-rose-500" style="width:<?= $pct ?>%"></div></div></div><?php endforeach; ?></div>
</div>
<script src="/assets/js/dashboard_charts.js"></script>
<?php include __DIR__ . '/includes/footer.php'; ?>
