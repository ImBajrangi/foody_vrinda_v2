import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../tracking/tracking_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'name': 'Spicy Miso Ramen',
        'qty': 2,
        'price': 28.00,
        'mods': 'Ex. Spicy • No Corn • Extra Egg',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuB-xCmhheF_L3jXa53y5tZgQ56m8UbB9JXgSs04FfKVdFq6J9f7yuL9pqFK0o6wOephtupVGd1mSWH0S3W2fPOb03KVE5PYCU-F0Nvv8gTNm9OyNTNQysPlS2N9PPukr-doYd6w6QtC5SE1WQ486bRF5PghNiFG5GyzkTpBHF6utK2xIYMNCBFyiMS0z6lqCa-CY83wKW6_RqmF8I_utOztlUX3p3Q57ExHSPOC2S0u_rry99NeEaXPIhOV7uHBlweLicGp6tbQf8H8',
      },
      {
        'name': 'Gyoza (5pc)',
        'qty': 1,
        'price': 6.50,
        'mods': 'Pan-fried • Soy Vinegar',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuD6DXbl40JslWPJ2ol7tihK7vdrneWxxcOGU-5Ki_BW2cgBCBRlHYVQ7xg14siVR3L4p3ELjArBNKim7Nc6dFn3mCw0KMuShxo0y23S1sT9lJJxx-OI6y1EVHI999N_FUpm098QitVP_XL4ukOpzu1zH1tPa_SkEZ4UQ2D5mXD9n_b9KkS2FfXGROC-gPkFHoXPbEQ-v1Jsbr7io8ulV-o6XjsN3uE95JXZ_d1j_HVwoRa7o1umtb9rEXs7lJmI3AswphkK1Wr6K5k1',
      },
      {
        'name': 'Asahi Super Dry',
        'qty': 1,
        'price': 5.00,
        'mods': 'Chilled',
        'image':
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBtw3RMEfBZuP7JJ_rmi840xJgx0zBVWnFbVdXM71Q1tOZw7rWJLxsDyYeI5bBrC9EAOejL8OnYEHo08CZjR92lTUDvz-XqNVMI3B2H63ElkDG6dLHVros89j3yrkIuLpK5havFZFNkpEsv-EUBwlCL8ZD-imCH2VjV08YCKHNue1ZczUGTl5ZfTFncUF9g4SDYdMbfcB2lb_T6ouV0KpSFsVf6us9_79A45m3l33moIyV7LNlbHQvFBgZRSkCEVWbZtpEQinAZ8rh8',
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
                        _receiptRow('SUBTOTAL', '\$39.50'),
                        const SizedBox(height: 8),
                        _receiptRow('TAX (8%)', '\$3.16'),
                        const SizedBox(height: 8),
                        _receiptRow('DELIVERY FEE', '\$2.99'),
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
                              '\$45.65',
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TrackingScreen(),
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
