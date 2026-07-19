import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/api_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/logout_dialog.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final productState = ref.watch(productProvider);
    final theme = Theme.of(context);
    final user = authState.user;

    // Calculate Dashboard Statistics
    final productsList = productState.products;
    final totalProducts = productsList.length;
    final lowStockItems = productsList.where((p) => p.quantity <= 5).toList();
    final totalInventoryValue = productsList.fold<double>(
      0.0,
      (sum, p) => sum + (p.price * p.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(productProvider.notifier).fetchProducts(),
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: theme.colorScheme.primary),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: user != null && user.profileImage.isNotEmpty
                    ? NetworkImage('${ApiConstants.uploadsUrl}${user.profileImage}')
                    : null,
                child: user == null || user.profileImage.isEmpty
                    ? Icon(Icons.person, size: 40, color: theme.colorScheme.primary)
                    : null,
              ),
              accountName: Text(
                user?.name ?? 'User Name',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(user?.email ?? 'user@email.com'),
            ),
            // Navigation Links
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              selected: true,
              selectedColor: theme.colorScheme.primary,
              onTap: () => context.pop(),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Products List'),
              onTap: () {
                context.pop();
                context.push('/products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add Product'),
              onTap: () {
                context.pop();
                context.push('/products/add');
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('My Profile'),
              onTap: () {
                context.pop();
                context.push('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                context.pop();
                context.push('/settings');
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text('Log Out', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                context.pop();
                showDialog(
                  context: context,
                  builder: (context) => const LogoutDialog(),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productProvider.notifier).fetchProducts(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                'Hello, ${user?.name ?? "Guest"}!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Here is the status of your inventory today',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),

              // Statistics Grid
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                children: [
                  _buildStatCard(
                    context,
                    title: 'Total Items',
                    value: '$totalProducts',
                    icon: Icons.inventory_2,
                    color: Colors.blue.shade700,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Low Stock',
                    value: '${lowStockItems.length}',
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange.shade800,
                    subtitle: '5 units or less',
                  ),
                  _buildStatCard(
                    context,
                    title: 'Total Valuation',
                    value: '\$${totalInventoryValue.toStringAsFixed(2)}',
                    icon: Icons.attach_money,
                    color: theme.colorScheme.primary,
                  ),
                  _buildStatCard(
                    context,
                    title: 'CategoriesCount',
                    value: '${productsList.map((e) => e.category).toSet().length}',
                    icon: Icons.category_outlined,
                    color: Colors.purple.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Search Bar shortcut redirect
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.search, color: Colors.grey),
                  title: const Text('Search inventory...', style: TextStyle(color: Colors.grey)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () => context.push('/products'),
                ),
              ),
              const SizedBox(height: 28),

              // Low Stock Header section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Low Stock Warnings',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (lowStockItems.isNotEmpty)
                    TextButton(
                      onPressed: () => context.push('/products'),
                      child: const Text('View All'),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Low stock inventory items list
              if (lowStockItems.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline, size: 40, color: Colors.teal.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'All stock levels are healthy!',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: lowStockItems.length > 3 ? 3 : lowStockItems.length,
                  itemBuilder: (context, index) {
                    final product = lowStockItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          child: product.image.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    '${ApiConstants.uploadsUrl}${product.image}',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.image_not_supported),
                                  ),
                                )
                              : const Icon(Icons.image),
                        ),
                        title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Qty: ${product.quantity} in stock'),
                        trailing: Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        onTap: () => context.push('/products/${product.id}'),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 28),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
