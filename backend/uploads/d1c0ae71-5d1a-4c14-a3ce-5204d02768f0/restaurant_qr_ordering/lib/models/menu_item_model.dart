/// A single menu item offered by the restaurant.
class MenuItemModel {
  final String menuId;
  final String name;
  final String description;
  final double price;
  final String image; // URL (Firebase Storage or remote)
  final String categoryId;
  final bool available;
  final bool isVeg;
  final int prepTimeMinutes;
  final double rating;
  final bool hasOffer;
  final double offerPercent; // e.g. 10 = 10% off

  const MenuItemModel({
    required this.menuId,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.available,
    this.isVeg = true,
    this.prepTimeMinutes = 15,
    this.rating = 4.5,
    this.hasOffer = false,
    this.offerPercent = 0,
  });

  double get finalPrice =>
      hasOffer ? price - (price * offerPercent / 100) : price;

  factory MenuItemModel.fromMap(Map<String, dynamic> map, String id) {
    return MenuItemModel(
      menuId: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      image: map['image'] ?? '',
      categoryId: map['category'] ?? '',
      available: map['available'] ?? true,
      isVeg: map['isVeg'] ?? true,
      prepTimeMinutes: map['prepTimeMinutes'] ?? 15,
      rating: (map['rating'] ?? 4.5).toDouble(),
      hasOffer: map['hasOffer'] ?? false,
      offerPercent: (map['offerPercent'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': categoryId,
      'available': available,
      'isVeg': isVeg,
      'prepTimeMinutes': prepTimeMinutes,
      'rating': rating,
      'hasOffer': hasOffer,
      'offerPercent': offerPercent,
    };
  }

  MenuItemModel copyWith({bool? available}) {
    return MenuItemModel(
      menuId: menuId,
      name: name,
      description: description,
      price: price,
      image: image,
      categoryId: categoryId,
      available: available ?? this.available,
      isVeg: isVeg,
      prepTimeMinutes: prepTimeMinutes,
      rating: rating,
      hasOffer: hasOffer,
      offerPercent: offerPercent,
    );
  }
}
