import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../../providers/cart_provider.dart';
import '../payment/payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    final subtotal = cart.subtotal;
    final deliveryFee = cart.deliveryFee;
    final tax = cart.tax;
    final total = cart.total;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CART',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if (Navigator.canPop(context))
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.borderDark),
                        ),
                        child: const MonoLabel(
                          'CANCEL',
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Empty State
            if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, size: 64, color: AppTheme.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        'YOUR CART IS EMPTY',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
            // Scrollable
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Items Card
                  HardShadowCard(
                    child: Column(
                      children: items.map((cartItem) {
                        final item = cartItem.menuItem;
                        final isLast = items.indexOf(cartItem) == items.length - 1;
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : const Border(
                                    bottom: BorderSide(
                                      color: AppTheme.borderDark,
                                    ),
                                  ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.borderDark),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: CachedNetworkImage(
                                  imageUrl: item.imageUrl ?? '',
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Container(color: AppTheme.surface),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name.toUpperCase(),
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '₹${item.price.toStringAsFixed(0)} x ${cartItem.quantity}',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  _qtyBtn(Icons.remove, () => cart.updateQuantity(item.id, cartItem.quantity - 1)),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${cartItem.quantity}',
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _qtyBtn(Icons.add, () => cart.addToCart(item)),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Receipt
                  HardShadowCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _receiptRow('SUBTOTAL', '₹${subtotal.toStringAsFixed(0)}'),
                        const SizedBox(height: 8),
                        _receiptRow('DELIVERY FEE', '₹${deliveryFee.toStringAsFixed(0)}'),
                        const SizedBox(height: 8),
                        _receiptRow('TAX & FEES', '₹${tax.toStringAsFixed(0)}'),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '₹${total.toStringAsFixed(0)}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment Info (Static for now)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.borderDark),
                              ),
                              child: const Icon(Icons.credit_card, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'VISA •••• 4242',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const MonoLabel('Main Wallet'),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          'CHANGE',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            // Checkout Button
            if (items.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: PrimaryButton(
                  label: 'PROCEED TO CHECKOUT',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PaymentScreen(amount: cart.total)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _receiptRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          color: AppTheme.textSecondary,
        ),
      ),
      Text(
        value,
        style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white),
      ),
    ],
  );

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
