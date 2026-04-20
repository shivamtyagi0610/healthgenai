class CartItem {
  final String id;
  final String name;
  final String price;
  final String image;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
  });

  CartItem copyWith({
    String? id,
    String? name,
    String? price,
    String? image,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
    );
  }
}
