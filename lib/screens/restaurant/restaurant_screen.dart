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
  final _tabs = ['Signature', 'Nigiri', 'Sashimi', 'Robata', 'Drinks'];

  final _menuItems = [
    {
      'name': 'Neon Salmon Roll',
      'desc': 'Torched salmon, spicy mayo, cucumber, micro-greens.',
      'price': 14.00,
      'tags': ['SPICY', 'GF'],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvLEAD-PSZezlwbAb0em_68GgVw8y3vFAC6U8U0NHD99lcG_kCP_HKR6aVF47WL4iQ7xedj_V-3ScCjoxMOa_Vgwf0OkTznD2f7ha6kxTl6X4mM21TwpTxrZlhQ78chmwcbrjl_uJCTLtA4u8KxYz39XZTMRnAjpkBXdDCp3wc1JGpDR5GFgEJOKtBIoQM03U4CU0-kG-bCVU51Gwb474CMDCP_neb-fORGBdMEe3nrCj3IAb-gyjdF2qC3GHJPbPEHnwSW-Zhk4Hs',
    },
    {
      'name': 'Data Crunch Tuna',
      'desc': 'Bluefin tuna, tempura flakes, truffle oil, avocado.',
      'price': 16.50,
      'tags': ['RAW'],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDAIle-hIGJ6uQAjfT2G2p_HmkV76QEJ6CdWE96G8CXJ_HAYOzo8cb04HsiF5AiIs3-eDyOnKeX_v88KavOJRH0IPzTa_PLG63KeQ7vkwf_oQl_WkmkzYvy7lBIzKqle2YCP4SELD6CvLqtJZ40uJhP_4uysR95uRUUrhQJRgVlZvR7aCJAC5x9JBnqaVak8wyL8Z21yY8gNCjxU8rqzKUE2DnnzmEZ6uvBsOjcWKiGvLQe6h-ptZlu2vZKjaqOQTNjQHMOAkHz6K5R',
    },
    {
      'name': 'Binary Edamame',
      'desc': 'Steamed soybeans, sea salt. Simple and efficient.',
      'price': 6.00,
      'tags': <String>[],
      'image': null,
    },
    {
      'name': 'Phantom Unagi Bowl',
      'desc': 'Grilled freshwater eel over rice, unagi sauce.',
      'price': 18.00,
      'tags': ['POPULAR'],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDdyflSpdKYeIyCuIEBUKMBkBNFX0qac9Xn6BlbXvBwVMUnM09hGcRNGsisWXE5oaZ1O4KguP8m0hMfNwSQVwcdc9GPAvLJQ2Z2LquAkZIjBofvmv9dy9KknQ8jLAcAj0_xtr_7lbadiAg_Clei-fsWPiseFD3HzxOYBoj2UqetNP2nFuu6sCHml0zn0hTr0QI9TYzSoaFsr-EqDRXsqlPvpNRfHphVOyEIzhYbylZ0HINtjEvHxUIuP1qFnv9YlS-MhwSQc7-6Q0S8',
    },
    {
      'name': 'Yakitori Skewers',
      'desc': 'Chicken thigh, scallion, tare sauce over charcoal.',
      'price': 8.00,
      'tags': <String>[],
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA1RnTWCpGatAdkh9dKC_JBM5F8JRiO2dxom3C_blmn0r10wFfv_m6-A86FpR4NRW0u4SPwLEbzABDwBvuBRQ2QOy_LZ2tTCLt6aw4KG-8j8HP5kavdHC2rRZv3twV7_9kY9r1ADHr4howxE8FBmYZDvEX_CSjVURSondqdMtJD4GO9cc0Z4c1rQ3zbpx6tKyFAn2dEgce1VFnLqA4DL2A8vw8a-9qBdJOkhBIWDGXEzeZt_cRZbv-nsNo-5uSQZARsdZuxl0C0e1nN',
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
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDhThSND04FxiD6b2JLcZzkUMiuxneLJs7xxcwcXPzqrLo7AFNPo44PDts-RWOmSxZ4I5N0S98oxWVuS-Dv2dC0TUZsgZMWsSEXy2Ui14k0dd70nLRV41bl2AvschPX4kd2zrmOSnUVr-aVCIfaffVAmtCGpREd3P91I2Gl21Zt2jT1ObdWPs8Ip6DHKKSWv4oCVky-gmJwMzANSkndZnQgqNqeOtEkdtOtUb1lY1RG6SWvpeL-XsWXgCIjZculFfsagqsv5Nw-hn0U',
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
                    'Cyber Sushi Lab',
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
      color: AppTheme.background.withValues(alpha: 0.95),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
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
                'SIGNATURE ROLLS',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              const MonoLabel('8 ITEMS'),
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
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.borderDark),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: item['image'] != null
                        ? CachedNetworkImage(
                            imageUrl: item['image'] as String,
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: AppTheme.surface,
                            child: const Center(
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
