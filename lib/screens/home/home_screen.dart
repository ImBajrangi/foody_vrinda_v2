import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../restaurant/restaurant_screen.dart';
import '../favorites/favorites_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

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
      onTap: () => setState(() => _currentNavIndex = index),
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

  final _categories = [
    {'emoji': '🍕', 'label': 'PIZZA'},
    {'emoji': '🍔', 'label': 'BURGER'},
    {'emoji': '🍜', 'label': 'RAMEN'},
    {'emoji': '🍣', 'label': 'SUSHI'},
    {'emoji': '☕', 'label': 'COFFEE'},
    {'emoji': '🌮', 'label': 'TACOS'},
    {'emoji': '🍛', 'label': 'CURRY'},
  ];

  final _heroCards = [
    {
      'title': 'THE OMNIVORE\nSTACK',
      'badge': 'FEATURED DROP',
      'badgeColor': const Color(0xFFFF3B30),
      'status': '● OPEN NOW',
      'meta': 'LIMITED QTY',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD4_-hFyORwJDad98D9C7-MpI6ez7dMm2XJ0jChJCJ7vmERQW8ZbzbVMO-VNpX_brGVVTZ_2Nmcp6v9q1GTVPrTwTMDkkRwTOxatbE6VYy4dcwfltFrOM1p_Hs7RU3tPL1squN0zkaD3KEk328dRQoS6MS5_a9ivCkf3EZajScXpP9RLhEZegi8NpOb9vHOYofiQZuASE23rA4DvcqVgwVPFPlciWn7feL1CYz1eIfqyHtfXAEgxXtPj3vxnO7I9gpSx9saxNO-l0h1',
    },
    {
      'title': 'TOKYO\nDRIFT',
      'badge': 'LATE NIGHT',
      'badgeColor': const Color(0xFFFF9500),
      'status': '● FAST DELIVERY',
      'meta': '24/7',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDMv2egTH49gc_zCIUG0hw1-lBb4Bo2RKLrIUH-VqJoEko9uAecY9gMoekmqnvWDbPUBd62DTma8XL9SmehReF8LDeOAuO7wNtXzR7EnhnIp5Rz27qg2Mv8pFpsXslKejHFBMqbKrC-4s_88yC1gfjXzKKToNrkG7NO0kJJ-zDHSRx1R_iu3fQnUim80h93lUwsqnzfzDYSmXL1ePWgjyuqdKeou1aTnG7qOBFs3-rBC7_B_mQxqBg2cpWwPlKzr4vfhpgdn7YinHwV',
    },
  ];

  final _restaurants = [
    {
      'name': 'NEON RAMEN BAR',
      'tags': ['JAPANESE', 'NOODLES', '\$\$'],
      'time': '15m',
      'distance': '0.8km',
      'match': 98,
      'badge': '🔥 HOT',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBncsX5meUqkGVBQRz-4e9PNBoiTQZI9qlxYNDgAphLrENSxPFAhJJIvHfJzQfNoNOwGf0gKpLnw3xF4lQSfmxZmxMVY1_Du7GZuH6Iug00SbPyoAiE5wC35ufsP_0HVjOQarTjcFVPbqGKanHRYt3I_OMsKwdQepsmfpskVFIxvh_yxQT98bcMkZycl7x7vOSm8PbKHppAiOE_THuQSL8JTiPexiatMcChk63X-n-KvTyhH5C-midNxVIxrhaaoRaRkYjvXx6CodTu',
    },
    {
      'name': 'CYBER TACOS',
      'tags': ['MEXICAN', 'SPICY', '\$'],
      'time': '22m',
      'distance': '1.2km',
      'match': 85,
      'badge': null,
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCoIjjsAY-PUGZxSVwJAnxHVKtPBCcbjAQPnk9GO95R6bI_fwJkZ2giVcUCpsKeqiF_K_ouOjH2pQXLOqzWf19-iUZO9EBSHNDAW7mF6s1rNFLfW9ZEHF1xfk18idSJLonby5CT3vUfiSASFeevTIMLLcb72B6tvEMbNwAQ3UoWrgrrHM32fS5QoRklgYtWF2Jp7Rpv-5_1d4Z0bON_6wuwd3cN42RJjBA1y58CPDTN0fLOBQl5HaGMa74QEKIzzsRMzg1nD5iSD45b',
    },
    {
      'name': 'GLITCH BURGER',
      'tags': ['AMERICAN', 'COMFORT', '\$\$\$'],
      'time': '30m',
      'distance': '2.4km',
      'match': 92,
      'badge': null,
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuATkSlRx_-Sp_sI8b_gIFvSwAwjSHpaNry4dhvporAsiQNW610GNbiIvJcTQEhjIL1TlbrdFjob-OAE-8ILx8vUhNpK5OjRyqyKpB6vP0Cds5dfoZyMBMs5CQEgB8WrY8oN17gAaLwfzgR1c92v6Ge69xiIfmGm708LxoLQF5OlfOqgk8zm5GtCqpB94OyQ1dUeQPm_ku6rJVdjV18srD5hVYt8Yax-1emyo2HCsSU5GOXncUYuhA9FgkEfQDVjJqfJ1uCeBGH3RcX_',
    },
    {
      'name': 'DATA SLICE',
      'tags': ['PIZZA', 'ITALIAN', '\$\$'],
      'time': '18m',
      'distance': '1.1km',
      'match': 88,
      'badge': '★ 4.9',
      'image':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCClMzetgrTz119uXlZuO0FOPEGcUz90QdXz0skupvzpk8o8Q0oM-42jrp_JCKSD-hcuDLEMqLGvi5gjn5m3o6G_ZsLUqrGfNkBb4mT6P3Q9igCwS9DaO6n6e6-Yz9kjaJCS7WnH5UMsBqHXgE7piSNdiH9TrokoaodbbHu0qGFJaxtWUD2ILSwQiCsURrRQtV1mJBR3SXO9IJBnmlag9K5Oq2BcH9xmSiWAO4zOhQEtgxzYCwIaYGc3wCjnhbuLK0rXNcj9yAI450L',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
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
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (context, i) => CategoryChip(
            icon: _categories[i]['emoji']!,
            label: _categories[i]['label']!,
            onTap: () {},
          ),
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
            '⚡ 50% OFF BURGERS • FREE DELIVERY • SUSHI BOGO • RUSH HOUR MODE ACTIVE ⚡ ',
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
                    imageUrl: restaurant['image'] as String,
                    fit: BoxFit.cover,
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
