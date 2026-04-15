<aside class="fixed inset-y-0 left-0 w-72 bg-gradient-to-b from-gray-900 to-gray-800 text-white shadow-2xl hidden lg:flex lg:flex-col">
  <div class="p-6 border-b border-white/10">
    <h1 class="text-xl font-bold bg-gradient-to-r from-emerald-400 to-blue-400 bg-clip-text text-transparent">Rice Mill ERP</h1>
  </div>
  <nav class="p-4 space-y-2 text-sm overflow-y-auto">
    <a class="block px-3 py-2 rounded-lg <?= active_nav('dashboard.php') ?>" href="/dashboard.php"><i class="fa fa-gauge mr-2"></i>Dashboard</a>
    <a class="block px-3 py-2 rounded-lg <?= active_nav('/modules/masters') ?>" href="/modules/masters/party/list.php"><i class="fa fa-layer-group mr-2"></i>Masters</a>
    <a class="block px-3 py-2 rounded-lg <?= active_nav('/modules/purchase') ?>" href="/modules/purchase/bargain_list.php"><i class="fa fa-cart-plus mr-2"></i>Purchase</a>
    <a class="block px-3 py-2 rounded-lg <?= active_nav('/modules/sales') ?>" href="/modules/sales/invoice_list.php"><i class="fa fa-file-invoice-dollar mr-2"></i>Sales</a>
    <a class="block px-3 py-2 rounded-lg <?= active_nav('/modules/inventory') ?>" href="/modules/inventory/stock_summary.php"><i class="fa fa-boxes-stacked mr-2"></i>Inventory</a>
    <a class="block px-3 py-2 rounded-lg <?= active_nav('/modules/reports') ?>" href="/modules/reports/mis_dashboard.php"><i class="fa fa-chart-line mr-2"></i>Reports</a>
    <a class="block px-3 py-2 rounded-lg <?= active_nav('/modules/settings') ?>" href="/modules/settings/company.php"><i class="fa fa-gear mr-2"></i>Settings</a>
  </nav>
</aside>
