import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../repositories/category_repository.dart';
import '../repositories/menu_repository.dart';

/// Backs the "Manage Menu" & "Manage Categories" admin screens: full CRUD
/// over menu items, categories, prices, availability & offers.
class AdminMenuViewModel extends ChangeNotifier {
  final MenuRepository _menuRepository;
  final CategoryRepository _categoryRepository;

  AdminMenuViewModel(this._menuRepository, this._categoryRepository) {
    _menuSub = _menuRepository.streamMenu().listen((items) {
      menuItems = items;
      notifyListeners();
    });
    _categorySub = _categoryRepository.streamCategories().listen((cats) {
      categories = cats;
      notifyListeners();
    });
  }

  List<MenuItemModel> menuItems = [];
  List<CategoryModel> categories = [];
  StreamSubscription? _menuSub;
  StreamSubscription? _categorySub;

  Future<void> saveMenuItem(MenuItemModel item, {required bool isNew}) {
    return isNew
        ? _menuRepository.addMenuItem(item)
        : _menuRepository.updateMenuItem(item);
  }

  Future<void> toggleAvailability(MenuItemModel item) {
    return _menuRepository.setAvailability(item.menuId, !item.available);
  }

  Future<void> deleteMenuItem(String menuId) =>
      _menuRepository.deleteMenuItem(menuId);

  Future<void> saveCategory(CategoryModel category, {required bool isNew}) {
    return isNew
        ? _categoryRepository.addCategory(category)
        : _categoryRepository.updateCategory(category);
  }

  Future<void> deleteCategory(String categoryId) =>
      _categoryRepository.deleteCategory(categoryId);

  @override
  void dispose() {
    _menuSub?.cancel();
    _categorySub?.cancel();
    super.dispose();
  }
}
