import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../../services/shop_service.dart';
import '../../services/auth_service.dart';
import '../../models/shop_model.dart';
import '../../models/user_model.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ShopService _shopService = ShopService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          indicatorWeight: 3,
          labelStyle: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w900, fontSize: 10),
          tabs: const [
            Tab(text: 'SHOPS'),
            Tab(text: 'STAFF'),
            Tab(text: 'GLOBAL_STATS'),
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final shops = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            final shop = shops[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: HardShadowCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        MonoLabel('ID // ${shop.id}'),
                      ],
                    ),
                  ),
                  Switch(
                    value: shop.isOnline,
                    onChanged: (val) => _shopService.updateShopStatus(shop.id, val),
                    activeColor: AppTheme.primary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppTheme.textSecondary, size: 20),
                    onPressed: () {
                      // Logic to edit shop would go here
                    },
                  ),
                ],
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
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data!.where((u) => u.role != UserRole.customer).toList();
        
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: HardShadowCard(
                padding: const EdgeInsets.all(12),
                child: ListTile(
                title: Text(
                  user.displayName?.toUpperCase() ?? 'UNKNOWN_USER',
                  style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w900, color: Colors.white),
                ),
                subtitle: MonoLabel('ROLE // ${user.role.value.toUpperCase()}'),
                trailing: const Icon(Icons.more_vert, color: AppTheme.primary),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _statCard('TOTAL_REVENUE', '₹1,42,000', Icons.analytics),
          const SizedBox(height: 16),
          _statCard('TOTAL_SHOPS', '08', Icons.store),
          const SizedBox(height: 16),
          _statCard('ACTIVE_RIDERS', '12', Icons.delivery_dining),
          const SizedBox(height: 24),
          const HardShadowCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                MonoLabel('SYSTEM_HEALTH // 100%'),
                SliverDivider(),
                MonoLabel('ALL_SERVICES_OPERATIONAL'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return HardShadowCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MonoLabel(label),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          Icon(icon, color: AppTheme.primary, size: 32),
        ],
      ),
    );
  }
}

class SliverDivider extends StatelessWidget {
  const SliverDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 1,
      color: AppTheme.borderDark,
    );
  }
}
