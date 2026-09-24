import '../core/constants/app_constants.dart';
import '../models/menu_item_model.dart';
import '../services/firestore_service.dart';

/// Abstracts all menu data access. ViewModels depend on this interface,
/// never directly on Firestore (Clean Architecture boundary).
class MenuRepository {
  final FirestoreService _service;
  MenuRepository(this._service);

  Stream<List<MenuItemModel>> streamMenu() {
    return _service
        .streamCollection(
      AppConstants.menuCollection,
      query: (q) => q.orderBy('name'),
    )
        .map((snap) => snap.docs
        .map((d) => MenuItemModel.fromMap(d.data(), d.id))
        .toList());
  }

  Stream<List<MenuItemModel>> streamMenuByCategory(String categoryId) {
    return _service
        .streamCollection(
      AppConstants.menuCollection,
      query: (q) => q.where('category', isEqualTo: categoryId),
    )
        .map((snap) => snap.docs
        .map((d) => MenuItemModel.fromMap(d.data(), d.id))
        .toList());
  }

  Future<void> addMenuItem(MenuItemModel item) {
    return _service.add(AppConstants.menuCollection, item.toMap());
  }

  Future<void> updateMenuItem(MenuItemModel item) {
    return _service.update(
      AppConstants.menuCollection,
      item.menuId,
      item.toMap(),
    );
  }

  Future<void> setAvailability(String menuId, bool available) {
    return _service.update(
      AppConstants.menuCollection,
      menuId,
      {'available': available},
    );
  }

  Future<void> deleteMenuItem(String menuId) {
    return _service.delete(AppConstants.menuCollection, menuId);
  }
}
