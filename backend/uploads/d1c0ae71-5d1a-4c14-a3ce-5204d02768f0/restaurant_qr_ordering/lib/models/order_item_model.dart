/// A line item inside an order (denormalized copy of a menu item at order time).
class OrderItemModel {
  final String orderItemId;
  final String menuId;
  final String name;      // snapshot of menu item name at order time
  final String image;     // snapshot of image
  final int quantity;
  final double price;     // unit price at order time

  const OrderItemModel({
    required this.orderItemId,
    required this.menuId,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
  });

  double get subtotal => price * quantity;

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      orderItemId: map['orderItemId'] ?? '',
      menuId: map['menuId'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      quantity: map['quantity'] ?? 1,
      price: (map['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderItemId': orderItemId,
      'menuId': menuId,
      'name': name,
      'image': image,
      'quantity': quantity,
      'price': price,
    };
  }
}
