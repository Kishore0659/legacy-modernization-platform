import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/loading_indicator.dart';
import '../../core/widgets/menu_item_card.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/menu_repository.dart';
import '../../services/firestore_service.dart';
import '../../viewmodels/cart_viewmodel.dart';
import '../../viewmodels/customer_menu_viewmodel.dart';
import 'cart_screen.dart';
import 'food_details_screen.dart';

/// Customer landing screen after scanning a table QR code.
/// Shows restaurant info, category filters, search, and the menu grid.
class CustomerHomeScreen extends StatelessWidget {
  final String tableId;
  const CustomerHomeScreen({super.key, required this.tableId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerMenuViewModel(
        MenuRepository(FirestoreService()),
        CategoryRepository(FirestoreService()),
      ),
      child: _CustomerHomeBody(tableId: tableId),
    );
  }
}

class _CustomerHomeBody extends StatefulWidget {
  final String tableId;
  const _CustomerHomeBody({required this.tableId});

  @override
  State<_CustomerHomeBody> createState() => _CustomerHomeBodyState();
}

class _CustomerHomeBodyState extends State<_CustomerHomeBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartViewModel>().setTable(widget.tableId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuVm = context.watch<CustomerMenuViewModel>();
    final cartVm = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(AppConstants.restaurantName),
            Text('Table ${widget.tableId}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.outline)),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('${cartVm.totalItemCount}'),
              isLabelVisible: cartVm.totalItemCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Firestore streams are already real-time; this simply gives
          // users the familiar pull-to-refresh affordance.
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: menuVm.isLoading
            ? const LoadingIndicator(label: 'Loading menu...')
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildSearchAndFilters(context, menuVm)),
                  SliverToBoxAdapter(child: _buildCategories(menuVm)),
                  _buildMenuGrid(context, menuVm, cartVm),
                ],
              ),
      ),
      bottomNavigationBar: cartVm.totalItemCount > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  child: Text(
                      'View Cart • ${cartVm.totalItemCount} items'),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSearchAndFilters(
      BuildContext context, CustomerMenuViewModel menuVm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: menuVm.search,
              decoration: InputDecoration(
                hintText: 'Search for food...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            icon: Icon(menuVm.vegOnly ? Icons.eco : Icons.eco_outlined),
            tooltip: 'Veg only',
            onPressed: menuVm.toggleVegOnly,
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(CustomerMenuViewModel menuVm) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          CategoryChipWidget(
            label: 'All',
            selected: menuVm.selectedCategoryId == null,
            onTap: () => menuVm.selectCategory(null),
          ),
          ...menuVm.categories.map(
            (cat) => CategoryChipWidget(
              label: cat.name,
              selected: menuVm.selectedCategoryId == cat.categoryId,
              onTap: () => menuVm.selectCategory(cat.categoryId),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(
    BuildContext context,
    CustomerMenuViewModel menuVm,
    CartViewModel cartVm,
  ) {
    final items = menuVm.filteredItems;
    if (items.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.search_off,
          title: 'No dishes found',
          subtitle: 'Try a different search term or category',
        ),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return MenuItemCard(
              item: item,
              quantityInCart: cartVm.quantityOf(item.menuId),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FoodDetailsScreen(item: item)),
              ),
              onAdd: () => cartVm.addItem(item),
              onIncrease: () => cartVm.increaseQuantity(item.menuId),
              onDecrease: () => cartVm.decreaseQuantity(item.menuId),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
