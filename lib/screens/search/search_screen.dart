import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../services/search_service.dart';
import '../../models/shop_model.dart';
import '../../config/lottie_assets.dart';
import '../../widgets/animations.dart';
import '../../widgets/industrial_widgets.dart';
import '../restaurant/restaurant_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<SearchResult> _results = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isLoading = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    final response = await _searchService.enhancedSearch(query);

    if (mounted) {
      setState(() {
        _results = response.results;
        _isLoading = false;
      });
    }
  }

  void _navigateToResult(SearchResult result) async {
    if (result.type == 'shop' && result.shop != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RestaurantScreen(restaurant: result.shop!.toRestaurantMap())),
      );
    } else if (result.type == 'menuItem' && result.shopId != null) {
      final shop = await _searchService.getShopById(result.shopId!);
      if (shop != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RestaurantScreen(restaurant: shop.toRestaurantMap())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchField(),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppTheme.borderDark, height: 1),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        style: GoogleFonts.jetBrainsMono(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'SEARCH SATTVIK...',
          hintStyle: GoogleFonts.jetBrainsMono(
            color: AppTheme.textSecondary,
            fontSize: 12,
            letterSpacing: 2,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textSecondary, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieAssets.build(LottieAssets.cooking, width: 120),
            const SizedBox(height: 16),
            const MonoLabel('SEARCHING VAANI...', fontSize: 12),
          ],
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return _buildEmptyState();
    }

    if (_results.isEmpty) {
      return _buildNoResults();
    }

    return _buildResults();
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MonoLabel('POPULAR CATEGORIES', color: AppTheme.primary),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _categoryChip('THALI', LottieAssets.cooking),
              _categoryChip('SWEETS', LottieAssets.celebration),
              _categoryChip('SNACKS', LottieAssets.foodLoading),
              _categoryChip('FAST FOOD', LottieAssets.delivery),
            ],
          ),
          const SizedBox(height: 48),
          Center(
            child: Opacity(
              opacity: 0.1,
              child: LottieAssets.build(LottieAssets.loading, width: 200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, String lottie) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _performSearch(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: RepaintBoundary(
                child: LottieAssets.build(lottie),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieAssets.build(LottieAssets.noData, width: 200),
          const SizedBox(height: 16),
          const MonoLabel('NO SATTVIK DATA FOUND', color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildResultTile(result);
      },
    );
  }

  Widget _buildResultTile(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.borderDark),
        boxShadow: const [
          BoxShadow(offset: Offset(4, 4), color: Color(0x33000000)),
        ],
      ),
      child: ListTile(
        onTap: () => _navigateToResult(result),
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 60,
            height: 60,
            color: AppTheme.background,
            child: result.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: result.imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Icon(Icons.image, color: AppTheme.borderDark),
                    errorWidget: (context, url, error) => const Icon(Icons.image, color: AppTheme.borderDark),
                  )
                : const Icon(Icons.image, color: AppTheme.borderDark),
          ),
        ),
        title: Text(
          result.title.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              result.subtitle ?? '',
              style: GoogleFonts.jetBrainsMono(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: result.type == 'shop' ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                result.type == 'shop' ? 'ESTABLISHMENT' : 'DISH',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: result.type == 'shop' ? AppTheme.primary : AppTheme.success,
                ),
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.primary, size: 14),
      ),
    );
  }
}

extension on ShopModel {
  Map<String, dynamic> toRestaurantMap() {
    return {
      'name': name,
      'tags': ['PURE VEG', 'SATTVIK', 'Vrindavan Exclusive'],
      'time': '20-30m',
      'distance': '1.2km',
      'match': 98,
      'badge': isOpen ? 'OPEN NOW' : 'CLOSED',
      'image': imageUrl ?? 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4',
    };
  }
}
