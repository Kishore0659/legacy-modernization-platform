import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../models/menu_item_model.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/menu_repository.dart';
import '../../services/firestore_service.dart';
import '../../viewmodels/admin_menu_viewmodel.dart';

/// Admin CRUD screen for menu items: name, description, price, image,
/// category, availability & offers.
class ManageMenuScreen extends StatelessWidget {
  const ManageMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminMenuViewModel(
        MenuRepository(FirestoreService()),
        CategoryRepository(FirestoreService()),
      ),
      child: const _ManageMenuBody(),
    );
  }
}

class _ManageMenuBody extends StatelessWidget {
  const _ManageMenuBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminMenuViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Menu')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(context, vm, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      body: vm.menuItems.isEmpty
          ? const Center(child: Text('No menu items yet. Tap + to add one.'))
          : ListView.builder(
              itemCount: vm.menuItems.length,
              itemBuilder: (context, i) {
                final item = vm.menuItems[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                          item.image.isNotEmpty ? NetworkImage(item.image) : null,
                      child: item.image.isEmpty ? const Icon(Icons.fastfood) : null,
                    ),
                    title: Text(item.name),
                    subtitle: Text(CurrencyFormatter.format(item.finalPrice)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: item.available,
                          onChanged: (_) => vm.toggleAvailability(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showEditDialog(context, vm, item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () async {
                            final confirmed = await ConfirmationDialog.show(
                              context,
                              title: 'Delete item',
                              message: 'Delete "${item.name}" permanently?',
                              confirmLabel: 'Delete',
                              isDestructive: true,
                            );
                            if (confirmed) vm.deleteMenuItem(item.menuId);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showEditDialog(
      BuildContext context, AdminMenuViewModel vm, MenuItemModel? existing) {
    showDialog(
      context: context,
      builder: (_) => _MenuItemFormDialog(vm: vm, existing: existing),
    );
  }
}

class _MenuItemFormDialog extends StatefulWidget {
  final AdminMenuViewModel vm;
  final MenuItemModel? existing;
  const _MenuItemFormDialog({required this.vm, this.existing});

  @override
  State<_MenuItemFormDialog> createState() => _MenuItemFormDialogState();
}

class _MenuItemFormDialogState extends State<_MenuItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _price;
  late final TextEditingController _image;
  String? _categoryId;
  bool _isVeg = true;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _desc = TextEditingController(text: e?.description ?? '');
    _price = TextEditingController(text: e?.price.toString() ?? '');
    _image = TextEditingController(text: e?.image ?? '');
    _categoryId = e?.categoryId;
    _isVeg = e?.isVeg ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.vm.categories;
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Menu Item' : 'Edit Menu Item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => Validators.required(v, label: 'Name'),
              ),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) => Validators.positiveNumber(v, label: 'Price'),
              ),
              TextFormField(
                controller: _image,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              DropdownButtonFormField<String>(
                value: _categoryId,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) =>
                        DropdownMenuItem(value: c.categoryId, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
                validator: (v) => v == null ? 'Select a category' : null,
              ),
              SwitchListTile(
                title: const Text('Vegetarian'),
                value: _isVeg,
                onChanged: (v) => setState(() => _isVeg = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final item = MenuItemModel(
              menuId: widget.existing?.menuId ?? '',
              name: _name.text.trim(),
              description: _desc.text.trim(),
              price: double.parse(_price.text),
              image: _image.text.trim(),
              categoryId: _categoryId!,
              available: widget.existing?.available ?? true,
              isVeg: _isVeg,
            );
            widget.vm.saveMenuItem(item, isNew: widget.existing == null);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
