/// Food category, e.g. Starters, Main Course, Beverages, Desserts.
class CategoryModel {
  final String categoryId;
  final String name;
  final String icon; // material icon name or asset path
  final int sortOrder;
  final bool active;

  const CategoryModel({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.sortOrder,
    required this.active,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      categoryId: id,
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'restaurant',
      sortOrder: map['sortOrder'] ?? 0,
      active: map['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'sortOrder': sortOrder,
      'active': active,
    };
  }
}
