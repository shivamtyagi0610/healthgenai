import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:healthgenai/features/orders/data/models/order_model.dart';

final orderProvider = NotifierProvider<OrderNotifier, List<OrderModel>>(OrderNotifier.new);

class OrderNotifier extends Notifier<List<OrderModel>> {
  @override
  List<OrderModel> build() => [];

  void addOrder(OrderModel order) {
    state = [order, ...state]; // Newest orders first
  }
}
