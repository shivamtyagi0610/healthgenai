import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/constants/app_colors.dart';
import '../providers/cart_provider.dart';
import '../../data/models/cart_item.dart';
import 'package:healthgenai/features/orders/presentation/providers/order_provider.dart';
import 'package:healthgenai/features/orders/data/models/order_model.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(
            'My Cart',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: cartItems.isEmpty 
        ? _buildEmptyState(context)
        : _buildPopulatedState(context, ref, cartItems),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.textTertiary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            height: 52,
            child: OutlinedButton(
              onPressed: () => context.go('/home/medicines'),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.divider, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Text(
                'Browse medicines',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPopulatedState(BuildContext context, WidgetRef ref, List<CartItem> cartItems) {
    // Calculate Total Price
    double total = 0;
    for (var item in cartItems) {
      final priceValue = double.tryParse(item.price.replaceAll('₹', '').replaceAll(',', '')) ?? 0;
      total += priceValue * item.quantity;
    }

    return Column(
      children: [
        // List of Items
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            itemCount: cartItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider, width: 0.8),
                ),
                child: Row(
                  children: [
                    // Product Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CachedNetworkImage(
                        imageUrl: item.image,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Name & Price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.price,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Quantity Controls
                          Row(
                            children: [
                              _QtyButton(
                                icon: Icons.remove,
                                onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.id, -1),
                                color: const Color(0xFFEDF8AF),
                                iconColor: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${item.quantity}',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 16),
                              _QtyButton(
                                icon: Icons.add,
                                onPressed: () => ref.read(cartProvider.notifier).updateQuantity(item.id, 1),
                                color: AppColors.primary,
                                iconColor: Colors.white,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Delete Button
                    IconButton(
                      onPressed: () => ref.read(cartProvider.notifier).removeItem(item.id),
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.redAccent,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom Checkout Bar
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.divider, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '₹${total.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () {
                      if (cartItems.isEmpty) return;

                      // 1. Generate mocking Order ID
                      final orderId = '#${math.Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
                      
                      // 2. Format Date
                      final date = DateFormat('dd/MM/yyyy').format(DateTime.now());

                      // 3. Create Order
                      final newOrder = OrderModel(
                        id: orderId,
                        items: List.from(cartItems),
                        totalPrice: '₹${total.toStringAsFixed(2)}',
                        date: date,
                        status: OrderStatus.pending,
                      );

                      // 4. Add to History
                      ref.read(orderProvider.notifier).addOrder(newOrder);

                      // 5. Clear Cart
                      ref.read(cartProvider.notifier).clear();

                      // 6. Navigate to Orders Tab
                      context.go('/orders');

                      // 7. Show Success confirmation
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Order $orderId placed successfully!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'Checkout',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final Color iconColor;

  const _QtyButton({
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isAdd = icon == Icons.add;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isAdd ? AppColors.primary : const Color(0xFFEDF8F2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon, 
          color: isAdd ? Colors.white : AppColors.textSecondary, 
          size: 18
        ),
      ),
    );
  }
}
