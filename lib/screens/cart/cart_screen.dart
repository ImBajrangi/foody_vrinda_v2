import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../payment/payment_screen.dart';
import '../tracking/tracking_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'name': 'Paneer Tikka Platter',
        'qty': 1,
        'price': 12.00,
        'mods': 'Well-done • Mint Chutney',
        'image': 'https://images.unsplash.com/photo-1666001120694-3ebe8fd207be?fm=jpg&q=60&w=3000&auto=format&fit=crop',
      },
      {
        'name': 'Dal Makhani',
        'qty': 2,
        'price': 21.00,
        'mods': 'Extra Creamy • Less Spicy',
        'image': 'https://images.unsplash.com/photo-1742281257687-092746ad6021?fm=jpg&q=60&w=3000&auto=format&fit=crop',
      },
      {
        'name': 'Butter Naan',
        'qty': 3,
        'price': 10.50,
        'mods': 'Garlic Topping',
        'image': 'https://images.unsplash.com/photo-1742281257687-092746ad6021?fm=jpg&q=60&w=3000&auto=format&fit=crop',
      },
    ];

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
            // Scrollable
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Items Card
                  HardShadowCard(
                    child: Column(
                      children: items.map((item) {
                        final isLast = items.indexOf(item) == items.length - 1;
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
                              SizedBox(
                                width: 64,
                                height: 64,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: AppTheme.borderDark,
                                        ),
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: CachedNetworkImage(
                                        imageUrl: item['image'] as String,
                                        fit: BoxFit.cover,
                                        width: 64,
                                        height: 64,
                                      ),
                                    ),
                                    Positioned(
                                      top: -4,
                                      right: -4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: (item['qty'] as int) > 1
                                              ? AppTheme.primary
                                              : AppTheme.surface,
                                          border: Border.all(
                                            color: AppTheme.borderDark,
                                          ),
                                        ),
                                        child: Text(
                                          '${item['qty']}x',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            (item['name'] as String)
                                                .toUpperCase(),
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '\$${(item['price'] as double).toStringAsFixed(2)}',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 13,
                                            color: (item['qty'] as int) > 1
                                                ? AppTheme.primary
                                                : Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['mods'] as String,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
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
                        _receiptRow('SUBTOTAL', '\$43.50'),
                        const SizedBox(height: 8),
                        _receiptRow('TAX (5%)', '\$2.17'),
                        const SizedBox(height: 8),
                        _receiptRow('DELIVERY FEE', '\$0.00'),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          height: 2,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppTheme.borderDark,
                                style: BorderStyle.solid,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              '\$45.67',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Payment
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
                              child: const Icon(
                                Icons.credit_card,
                                color: Colors.white,
                                size: 16,
                              ),
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
                  const SizedBox(height: 16),
                  // Promo
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppTheme.borderDark),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ENTER_PROMO_CODE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.borderDark),
                          boxShadow: const [AppTheme.hardShadow],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'ADD MORE',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Slide to Pay
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: BoxDecoration(
                color: AppTheme.surface.withValues(alpha: 0.9),
                border: const Border(
                  top: BorderSide(color: AppTheme.borderDark),
                ),
              ),
              child: Column(
                children: [
                  SlideToPayButton(
                    amount: 45.65,
                    onSlideComplete: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(amount: 45.67),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const MonoLabel('SECURED BY TURBO_PAY™ // 256-BIT'),
                ],
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
}
