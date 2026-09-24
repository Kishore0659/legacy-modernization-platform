import '../core/constants/app_constants.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';

class CategoryRepository {
  final FirestoreService _service;
  CategoryRepository(this._service);

  Stream<List<CategoryModel>> streamCategories() {
    return _service
        .streamCollection(
      AppConstants.categoriesCollection,
      query: (q) => q.orderBy('sortOrder'),
    )
        .map((snap) => snap.docs
        .map((d) => CategoryModel.fromMap(d.data(), d.id))
        .toList());
  }

  Future<void> addCategory(CategoryModel category) {
    return _service.add(AppConstants.categoriesCollection, category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) {
    return _service.update(
      AppConstants.categoriesCollection,
      category.categoryId,
      category.toMap(),
    );
  }

  Future<void> deleteCategory(String categoryId) {
    return _service.delete(AppConstants.categoriesCollection, categoryId);
  }
}
