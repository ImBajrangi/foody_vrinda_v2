import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../../config/lottie_assets.dart';
import '../restaurant/restaurant_screen.dart';
import '../favorites/favorites_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const FavoritesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(index: _currentNavIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181111).withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home, 'FEED', 0),
              _navItem(Icons.favorite_border, 'LIKES', 1),
              _navItem(Icons.shopping_bag_outlined, 'CART', 2),
              _navItem(Icons.person_outline, 'USER', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _currentNavIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? AppTheme.primary : AppTheme.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  final _scrollController = ScrollController();

  List<Map<String, String>> get _categories => [
    {'lottie': LottieAssets.cooking, 'label': 'THALI'},
    {'lottie': LottieAssets.pizzaSlices, 'label': 'ROTI/NAAN'},
    {'lottie': LottieAssets.potato, 'label': 'SWEETS'},
    {'lottie': LottieAssets.growingTomatoes, 'label': 'PANEER'},
    {'lottie': LottieAssets.walkingBroccoli, 'label': 'STARTERS'},
    {'lottie': LottieAssets.foodDelivery, 'label': 'STREET'},
    {'lottie': LottieAssets.dotsLoading, 'label': 'DRINKS'},
  ];

  List<Map<String, dynamic>> get _heroCards => [
    {
      'title': 'VRINDAVAN\nSATTVIK THALI',
      'badge': 'POOJA SPECIAL',
      'badgeColor': const Color(0xFFFF9500),
      'status': '● PURE VEG',
      'meta': 'TRADITIONAL',
      'image':
          'https://images.unsplash.com/photo-1742281257687-092746ad6021?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    },
    {
      'title': 'KESHAV\nSWEETS',
      'badge': 'FESTIVAL READY',
      'badgeColor': const Color(0xFF30D158),
      'status': '● DESI GHEE',
      'meta': 'SINCE 1985',
      'image':
          'https://images.unsplash.com/photo-1666190092159-3171cf0fbb12?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    },
  ];

  List<Map<String, dynamic>> get _restaurants => [
    {
      'name': 'RADHE RADHE DHABA',
      'tags': ['PURE VEG', 'NORTH INDIAN', 'THALI'],
      'time': '20m',
      'distance': '1.5km',
      'match': 99,
      'badge': '🥦 BEST',
      'image':
          'https://images.unsplash.com/photo-1742281257687-092746ad6021?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    },
    {
      'name': 'GOKUL CHAAT CENTER',
      'tags': ['STREET FOOD', 'SPICY', 'PURE VEG'],
      'time': '12m',
      'distance': '0.5km',
      'match': 94,
      'badge': '🔥 TRENDING',
      'image':
          'https://images.unsplash.com/photo-1666001120694-3ebe8fd207be?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    },
    {
      'name': 'SOUTH INDIAN EXPRESS',
      'tags': ['IDLI', 'DOSA', 'VEGAN FRIENDLY'],
      'time': '18m',
      'distance': '2.2km',
      'match': 88,
      'badge': null,
      'image':
          'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?fm=jpg&q=60&w=3000&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      key: UniqueKey(),
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            children: [
              _buildCategories(),
              _buildHeroCarousel(),
              _buildMarqueeTicker(),
              _buildRestaurantFeed(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.95),
        border: const Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              ),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 12),
                      child: Icon(
                        Icons.terminal,
                        color: AppTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'SEARCH COMMAND...',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: const Icon(Icons.tune, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, i) {
            final cat = _categories[i];
            return Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.borderDark, width: 1.5),
                  ),
                  child: LottieAssets.build(cat['lottie']!, width: 44, height: 44),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['label']!,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: SizedBox(
        height: 200,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _heroCards.length,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, i) {
            final card = _heroCards[i];
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RestaurantScreen()),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.82,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: card['image'] as String,
                      fit: BoxFit.cover,
                      color: Colors.white.withValues(alpha: 0.8),
                      colorBlendMode: BlendMode.modulate,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.9),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Transform(
                            transform: Matrix4.skewX(-0.15),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              color: card['badgeColor'] as Color,
                              child: Text(
                                card['badge'] as String,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card['title'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 0.95,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                card['status'] as String,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: AppTheme.success,
                                ),
                              ),
                              Text(
                                '  //  ',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                card['meta'] as String,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color: Colors.grey[400],
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
          },
        ),
      ),
    );
  }

  Widget _buildMarqueeTicker() {
    return Container(
      height: 32,
      color: AppTheme.primary,
      child: ClipRect(
        child: _MarqueeWidget(
          child: Text(
            '⚡ 50% OFF THALIS • FREE DELIVERY • SWEETS BOGO • PURE VEG MODE ACTIVE ⚡ ',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRestaurantFeed() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Incoming Feeds',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: const MonoLabel('SORT: MATCH_SCORE_DESC'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._restaurants.map((res) => _buildRestaurantCard(res)),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Map<String, dynamic> restaurant) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RestaurantScreen()),
      ),
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.borderDark),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: restaurant['image']!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  if (restaurant['badge'] != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.8),
                          border: Border.all(color: AppTheme.borderDark),
                        ),
                        child: Text(
                          restaurant['badge'] as String,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color:
                                restaurant['badge'].toString().contains('HOT')
                                ? Colors.white
                                : AppTheme.secondary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(width: 1, color: AppTheme.borderDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant['name'] as String,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: (restaurant['tags'] as List<String>)
                              .map((tag) => IndustrialTag(tag))
                              .toList(),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            MonoLabel(restaurant['time'] as String),
                          ],
                        ),
                        MatchScoreBadge(score: restaurant['match'] as int),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarqueeWidget extends StatefulWidget {
  final Widget child;
  const _MarqueeWidget({required this.child});

  @override
  State<_MarqueeWidget> createState() => _MarqueeWidgetState();
}

class _MarqueeWidgetState extends State<_MarqueeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: FractionalTranslation(
            translation: Offset(-_controller.value, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [widget.child, widget.child],
            ),
          ),
        );
      },
    );
  }
}
