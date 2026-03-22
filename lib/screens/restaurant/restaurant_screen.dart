import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../food_detail/food_detail_screen.dart';
import '../cart/cart_screen.dart';

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key});
  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  int _selectedTab = 0;
  int _cartCount = 0;
  double _cartTotal = 0;
  final _tabs = ['Signature', 'Thalis', 'Starters', 'Sides', 'Sweets'];

  List<Map<String, dynamic>> get _menuItems => [
    {
      'name': 'Paneer Tikka Platter',
      'desc': 'Clay-oven roasted cottage cheese, mint chutney, masala onions.',
      'price': 12.00,
      'tags': ['SPICY', 'GF'],
      'image': 'https://images.unsplash.com/photo-1666001120694-3ebe8fd207be?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    },
    {
      'name': 'Dal Makhani High-Sync',
      'desc': 'Slow-cooked black lentils, creamy texture, served with butter.',
      'price': 10.50,
      'tags': ['POPULAR'],
      'image': 'https://images.unsplash.com/photo-1742281257687-092746ad6021?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    },
    {
      'name': 'Binary Butter Naan',
      'desc': 'Traditional leavened bread with premium butter glaze.',
      'price': 3.50,
      'tags': <String>[],
      'image': null,
    },
    {
      'name': 'Cyber Chole Bhature',
      'desc': 'Spicy chickpea curry with fluffy deep-fried bread.',
      'price': 9.00,
      'tags': ['SIGNATURE'],
      'image': 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    },
    {
      'name': 'Gulab Jamun Matrix',
      'desc': 'Soft khoya balls in rose-scented sugar syrup.',
      'price': 5.00,
      'tags': <String>[],
      'image': 'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    },
  ];

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      _cartCount++;
      _cartTotal += (item['price'] as double);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(), // Force rebuild
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildHero(),
              SliverToBoxAdapter(child: _buildMatchScore()),
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(child: _buildTabs()),
              ),
              SliverToBoxAdapter(child: _buildMenuList()),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
          if (_cartCount > 0) _buildCartBar(),
        ],
      ),
    );
  }

  SliverAppBar _buildHero() {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppTheme.background,
      leading: _fab(Icons.arrow_back, () => Navigator.pop(context)),
      actions: [
        _fab(Icons.search, () {}),
        const SizedBox(width: 8),
        _fab(Icons.more_horiz, () {}),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1742281257687-092746ad6021?fm=jpg&q=60&w=3000&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.background.withValues(alpha: 0.6),
                    AppTheme.background,
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        color: AppTheme.primary,
                        child: Text(
                          'Promoted',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const IndustrialTag('30-45 min'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'VRINDAVAN SATTVIK LAB',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Japanese • 0.4mi • ',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        'Open until 3am',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fab(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );

  Widget _buildMatchScore() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: 0.94,
                    strokeWidth: 4,
                    backgroundColor: AppTheme.borderDark,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.success),
                  ),
                ),
                Text(
                  '94%',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.success,
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
                Text(
                  'Excellent Match',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'High compatibility based on your order history.',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.95),
        border: const Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 24),
        itemBuilder: (context, i) {
          final active = i == _selectedTab;
          return GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: active ? AppTheme.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                _tabs[i].toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppTheme.primary : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SATTVIK SELECTIONS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const MonoLabel('PURE VEG'),
            ],
          ),
          ..._menuItems.map((item) => _menuItem(item)),
        ],
      ),
    );
  }

  Widget _menuItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            FoodDetailScreen(item: item, onAddToCart: () => _addToCart(item)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  if ((item['tags'] as List).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Wrap(
                        spacing: 6,
                        children: (item['tags'] as List<String>)
                            .map(
                              (t) => IndustrialTag(
                                t,
                                textColor: t == 'SPICY'
                                    ? AppTheme.primary
                                    : t == 'POPULAR'
                                    ? Colors.amber
                                    : null,
                                backgroundColor: t == 'SPICY'
                                    ? AppTheme.primary.withValues(alpha: 0.1)
                                    : t == 'POPULAR'
                                    ? Colors.amber.withValues(alpha: 0.1)
                                    : null,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    item['desc'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${(item['price'] as double).toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: item['image'] as String? ?? '',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.restaurant,
                          color: AppTheme.borderDark,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -8,
                    right: -8,
                    child: GestureDetector(
                      onTap: () => _addToCart(item),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black),
                          boxShadow: const [AppTheme.hardShadow],
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartBar() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.borderDark),
            boxShadow: const [
              BoxShadow(offset: Offset(4, 4), color: AppTheme.primary),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$_cartCount',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${_cartTotal.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'VIEW CART',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabBarDelegate({required this.child});
  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;
  @override
  Widget build(BuildContext c, double s, bool o) => child;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate o) => true;
}
