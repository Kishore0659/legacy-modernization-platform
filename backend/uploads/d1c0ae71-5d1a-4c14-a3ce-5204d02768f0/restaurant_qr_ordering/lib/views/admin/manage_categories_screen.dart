import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../models/category_model.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/menu_repository.dart';
import '../../services/firestore_service.dart';
import '../../viewmodels/admin_menu_viewmodel.dart';

/// Admin CRUD screen for food categories.
class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminMenuViewModel(
        MenuRepository(FirestoreService()),
        CategoryRepository(FirestoreService()),
      ),
      child: const _ManageCategoriesBody(),
    );
  }
}

class _ManageCategoriesBody extends StatelessWidget {
  const _ManageCategoriesBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminMenuViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(context, vm, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
      body: ListView.builder(
        itemCount: vm.categories.length,
        itemBuilder: (context, i) {
          final cat = vm.categories[i];
          return ListTile(
            leading: const Icon(Icons.category_outlined),
            title: Text(cat.name),
            subtitle: Text(cat.active ? 'Active' : 'Hidden'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showForm(context, vm, cat),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    final confirmed = await ConfirmationDialog.show(
                      context,
                      title: 'Delete category',
                      message: 'Delete "${cat.name}"?',
                      isDestructive: true,
                    );
                    if (confirmed) vm.deleteCategory(cat.categoryId);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, AdminMenuViewModel vm, CategoryModel? existing) {
    final controller = TextEditingController(text: existing?.name ?? '');
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? 'Add Category' : 'Edit Category'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Category Name'),
            validator: (v) => Validators.required(v, label: 'Name'),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final category = CategoryModel(
                categoryId: existing?.categoryId ?? '',
                name: controller.text.trim(),
                icon: existing?.icon ?? 'restaurant',
                sortOrder: existing?.sortOrder ?? vm.categories.length,
                active: existing?.active ?? true,
              );
              vm.saveCategory(category, isNew: existing == null);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
