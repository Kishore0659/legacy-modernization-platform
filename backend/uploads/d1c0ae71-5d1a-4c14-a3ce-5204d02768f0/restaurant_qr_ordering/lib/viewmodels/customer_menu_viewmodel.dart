import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../repositories/category_repository.dart';
import '../repositories/menu_repository.dart';

/// Drives the customer home / menu browsing screen: categories, search,
/// filters, and the full menu list, all backed by real-time Firestore
/// streams.
class CustomerMenuViewModel extends ChangeNotifier {
  final MenuRepository _menuRepository;
  final CategoryRepository _categoryRepository;

  CustomerMenuViewModel(this._menuRepository, this._categoryRepository) {
    _listenMenu();
    _listenCategories();
  }

  List<MenuItemModel> _allItems = [];
  List<CategoryModel> categories = [];
  String? selectedCategoryId; // null = all
  String searchQuery = '';
  bool vegOnly = false;
  bool isLoading = true;

  StreamSubscription? _menuSub;
  StreamSubscription? _categorySub;

  void _listenMenu() {
    _menuSub = _menuRepository.streamMenu().listen((items) {
      _allItems = items;
      isLoading = false;
      notifyListeners();
    });
  }

  void _listenCategories() {
    _categorySub = _categoryRepository.streamCategories().listen((cats) {
      categories = cats.where((c) => c.active).toList();
      notifyListeners();
    });
  }

  List<MenuItemModel> get filteredItems {
    return _allItems.where((item) {
      final matchesCategory =
          selectedCategoryId == null || item.categoryId == selectedCategoryId;
      final matchesSearch = searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesVeg = !vegOnly || item.isVeg;
      return matchesCategory && matchesSearch && matchesVeg && item.available;
    }).toList();
  }

  void selectCategory(String? categoryId) {
    selectedCategoryId = categoryId;
    notifyListeners();
  }

  void search(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void toggleVegOnly() {
    vegOnly = !vegOnly;
    notifyListeners();
  }

  @override
  void dispose() {
    _menuSub?.cancel();
    _categorySub?.cancel();
    super.dispose();
  }
}
