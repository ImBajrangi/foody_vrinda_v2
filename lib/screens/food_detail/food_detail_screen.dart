import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';

class FoodDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAddToCart;
  const FoodDetailScreen({
    super.key,
    required this.item,
    required this.onAddToCart,
  });
  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  int _quantity = 1;
  int _baseSelection = 0;
  double _spiceLevel = 2;
  final List<bool> _addOns = [false, true, false, false];
  final _addOnItems = [
    {'name': 'Extra Beef', 'price': 3.00},
    {'name': 'Fried Egg', 'price': 1.50},
    {'name': 'Bok Choy', 'price': 1.00},
    {'name': 'Chili Oil Jar', 'price': 5.00},
  ];
  final _bases = [
    {'name': 'Egg Noodles', 'price': 'INCLUDED'},
    {'name': 'Rice Noodles', 'price': '+\$1.00'},
    {'name': 'Udon Noodles', 'price': '+\$1.50'},
  ];

  double get _totalPrice {
    double base = (widget.item['price'] as double) * _quantity;
    for (int i = 0; i < _addOns.length; i++) {
      if (_addOns[i]) base += (_addOnItems[i]['price'] as double) * _quantity;
    }
    if (_baseSelection == 1) base += 1.0 * _quantity;
    if (_baseSelection == 2) base += 1.5 * _quantity;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: const Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 48,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.borderDark,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Hero Image
                if (widget.item['image'] != null)
                  SizedBox(
                    height: 240,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: widget.item['image'] as String,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppTheme.background,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.success,
                                  border: Border.all(color: Colors.black),
                                  boxShadow: const [AppTheme.hardShadow],
                                ),
                                child: Text(
                                  '98% Match',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primary,
                                  border: Border.all(color: Colors.black),
                                  boxShadow: const [AppTheme.hardShadow],
                                ),
                                child: Text(
                                  'Spicy',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.item['name'] as String,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${(widget.item['price'] as double).toStringAsFixed(2)}',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const MonoLabel('BASE PRICE'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.item['desc'] as String,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: Colors.grey[400],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _metaChip(Icons.timer, '15 MIN'),
                          const SizedBox(width: 16),
                          _metaChip(Icons.local_fire_department, 'HIGH HEAT'),
                          const SizedBox(width: 16),
                          _metaChip(Icons.group, 'SERVES 1'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppTheme.borderDark),
                // Choose Base
                _sectionHeader('Choose Base', 'REQUIRED', AppTheme.primary),
                ...List.generate(_bases.length, (i) => _radioOption(i)),
                const SizedBox(height: 16),
                // Spice Level
                _sectionHeader('Heat Level', 'ADJUST TO TASTE', null),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.borderDark),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('🌶️', style: TextStyle(fontSize: 20)),
                          Text('😅', style: TextStyle(fontSize: 20)),
                          Text('🔥', style: TextStyle(fontSize: 20)),
                          Text('☠️', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.primary,
                          inactiveTrackColor: AppTheme.borderDark,
                          thumbColor: AppTheme.primary,
                          overlayColor: AppTheme.primary.withValues(alpha: 0.2),
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 12,
                          ),
                        ),
                        child: Slider(
                          min: 1,
                          max: 4,
                          divisions: 3,
                          value: _spiceLevel,
                          onChanged: (v) => setState(() => _spiceLevel = v),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          'Mild',
                          'Medium',
                          'Hot',
                          'Nuclear',
                        ].map((s) => MonoLabel(s)).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Add-ons
                _sectionHeader('Add-ons', 'OPTIONAL', null),
                ...List.generate(_addOnItems.length, (i) => _checkboxOption(i)),
                const SizedBox(height: 100),
              ],
            ),
          ),
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _metaChip(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 14, color: Colors.grey[600]),
      const SizedBox(width: 4),
      MonoLabel(text),
    ],
  );

  Widget _sectionHeader(String title, String badge, Color? badgeColor) =>
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[300],
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                color: (badgeColor ?? Colors.transparent).withValues(
                  alpha: 0.1,
                ),
                child: MonoLabel(badge, color: badgeColor),
              ),
            ],
          ),
        ),
      );

  Widget _radioOption(int i) {
    final active = _baseSelection == i;
    return GestureDetector(
      onTap: () => setState(() => _baseSelection = i),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? AppTheme.surface : AppTheme.background,
          border: Border.all(
            color: active ? AppTheme.primary : AppTheme.borderDark,
          ),
          boxShadow: active
              ? [const BoxShadow(offset: Offset(2, 2), color: AppTheme.primary)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: active ? AppTheme.primary : Colors.transparent,
                    border: Border.all(
                      color: active ? AppTheme.primary : Colors.grey[600]!,
                    ),
                  ),
                  child: active
                      ? const Icon(Icons.circle, size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  _bases[i]['name'] as String,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w500,
                    color: active ? Colors.white : Colors.grey[300],
                  ),
                ),
              ],
            ),
            MonoLabel(_bases[i]['price'] as String, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _checkboxOption(int i) {
    final checked = _addOns[i];
    return GestureDetector(
      onTap: () => setState(() => _addOns[i] = !_addOns[i]),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: checked ? AppTheme.surface : AppTheme.background,
          border: Border.all(
            color: checked ? AppTheme.primary : AppTheme.borderDark,
          ),
          boxShadow: checked
              ? [const BoxShadow(offset: Offset(2, 2), color: AppTheme.primary)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: checked ? AppTheme.primary : Colors.transparent,
                    border: Border.all(
                      color: checked ? AppTheme.primary : Colors.grey[600]!,
                    ),
                  ),
                  child: checked
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  _addOnItems[i]['name'] as String,
                  style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w500,
                    color: checked ? Colors.white : Colors.grey[300],
                  ),
                ),
              ],
            ),
            MonoLabel(
              '+\$${(_addOnItems[i]['price'] as double).toStringAsFixed(2)}',
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Quantity
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.borderDark),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        color: Colors.white,
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: const BoxDecoration(
                          border: Border.symmetric(
                            vertical: BorderSide(color: AppTheme.borderDark),
                          ),
                        ),
                        child: Text(
                          '$_quantity',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        color: Colors.white,
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Add to Order',
              trailing: Row(
                children: [
                  Text(
                    '\$${_totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              onPressed: () {
                widget.onAddToCart();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
