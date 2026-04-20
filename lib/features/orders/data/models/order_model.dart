import 'package:healthgenai/features/cart/data/models/cart_item.dart';

enum OrderStatus { pending, completed, cancelled }

class OrderModel {
  final String id;
  final List<CartItem> items;
  final String totalPrice;
  final String date;
  final OrderStatus status;

  OrderModel({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.date,
    required this.status,
  });

  OrderModel copyWith({
    String? id,
    List<CartItem>? items,
    String? totalPrice,
    String? date,
    OrderStatus? status,
  }) {
    return OrderModel(
      id: id ?? this.id,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }
}
