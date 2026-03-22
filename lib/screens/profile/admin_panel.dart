import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../../services/auth_service.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../models/shop_model.dart';
import '../../services/shop_service.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  final ShopService _shopService = ShopService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          'ADMIN_CONSOLE',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w900),
          tabs: const [
            Tab(text: 'SHOPS'),
            Tab(text: 'STAFF'),
            Tab(text: 'GLOBAL'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShopManagement(),
          _buildStaffManagement(),
          _buildGlobalStats(),
        ],
      ),
    );
  }

  Widget _buildShopManagement() {
    return StreamBuilder<List<ShopModel>>(
      stream: _shopService.getShops(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        final shops = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            final shop = shops[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        color: shop.isOnline ? AppTheme.success : AppTheme.error,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop.name.toUpperCase(),
                                    style: GoogleFonts.spaceGrotesk(
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  MonoLabel('ID: ${shop.id.substring(0, 8)}'),
                                ],
                              ),
                              Column(
                                children: [
                                  Switch(
                                    value: shop.isOnline,
                                    onChanged: (val) => _shopService.updateShopStatus(shop.id, val),
                                    activeColor: AppTheme.success,
                                    activeTrackColor: AppTheme.success.withValues(alpha: 0.2),
                                  ),
                                  MonoLabel(
                                    shop.isOnline ? 'ONLINE' : 'OFFLINE', 
                                    fontSize: 8,
                                    color: shop.isOnline ? AppTheme.success : AppTheme.error,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStaffManagement() {
    return FutureBuilder<List<UserModel>>(
      future: _authService.getAllUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        final users = snapshot.data!.where((u) => u.role != UserRole.customer).toList();
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final initials = (user.displayName ?? 'U').substring(0, 1).toUpperCase();
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: GoogleFonts.spaceGrotesk(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    user.displayName?.toUpperCase() ?? 'UNKNOWN_STAFF',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          user.role.value.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: AppTheme.borderDark, size: 14),
                  onTap: () => _showUserRoleDialog(user),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserRoleDialog(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonoLabel('MODIFY_ROLE // ${user.displayName?.toUpperCase() ?? 'USER'}'),
            const SizedBox(height: 16),
            ...UserRole.values.map((role) => ListTile(
              title: Text(role.value.toUpperCase(), style: GoogleFonts.jetBrainsMono(color: Colors.white)),
              onTap: () {
                _authService.updateUserRole(uid: user.uid, role: role);
                Navigator.pop(context);
                setState(() {}); // Refresh list
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStats() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _statCard(
                'REVENUE',
                '₹1.42L',
                Icons.payments,
                [AppTheme.primary, const Color(0xFFFFD700)],
              ),
              const SizedBox(width: 16),
              _statCard(
                'ORDERS',
                '1,280',
                Icons.shopping_bag,
                [const Color(0xFF00F2FE), const Color(0xFF4FACFE)],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statCard(
                'SHOPS',
                '08',
                Icons.storefront,
                [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              ),
              const SizedBox(width: 16),
              _statCard(
                'RIDERS',
                '12',
                Icons.electric_moped,
                [const Color(0xFFF093FB), const Color(0xFFF5576C)],
              ),
            ],
          ),
          const SizedBox(height: 32),
          const MonoLabel('SYSTEM_HEALTH // ENGINE_STATUS'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.5),
              border: Border.all(color: AppTheme.borderDark),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                _healthRow('DATABASE_SYNC', 'OPTIMAL', AppTheme.primary),
                const SliverDivider(),
                _healthRow('API_LATENCY', '< 24MS', AppTheme.success),
                const SliverDivider(),
                _healthRow('CDN_EDGE_DEPLOY', 'GLOBAL_ACTIVE', AppTheme.success),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'FOODY_VRINDA_OS // V2.0.4RC',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: AppTheme.textSecondary.withValues(alpha: 0.3),
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _healthRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MonoLabel(label),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, List<Color> gradient) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.borderDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: Colors.black, size: 20),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            MonoLabel(label, fontSize: 8),
          ],
        ),
      ),
    );
  }
}

class SliverDivider extends StatelessWidget {
  const SliverDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.borderDark.withValues(alpha: 0),
            AppTheme.borderDark,
            AppTheme.borderDark.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
