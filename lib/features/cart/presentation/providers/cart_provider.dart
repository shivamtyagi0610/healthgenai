import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_item.dart';

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() => [];

  void addItem(Map<String, String> medicine, int quantity) {
    final id = medicine['name']!; // Using name as ID for this phase
    
    final existingIndex = state.indexWhere((item) => item.id == id);

    if (existingIndex != -1) {
      // Item exists, update quantity
      final existingItem = state[existingIndex];
      final updatedList = [...state];
      updatedList[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      state = updatedList;
    } else {
      // New item, add to list
      state = [
        ...state,
        CartItem(
          id: id,
          name: id,
          price: medicine['price']!,
          image: medicine['image']!,
          quantity: quantity,
        ),
      ];
    }
  }

  void updateQuantity(String id, int delta) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final updatedList = [...state];
    final existingItem = updatedList[index];
    final newQuantity = existingItem.quantity + delta;

    if (newQuantity <= 0) {
      // Remove item if quantity becomes 0 or less
      updatedList.removeAt(index);
    } else {
      updatedList[index] = existingItem.copyWith(quantity: newQuantity);
    }
    state = updatedList;
  }

  void removeItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void clear() {
    state = [];
  }
}
