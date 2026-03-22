import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../widgets/industrial_widgets.dart';
import '../../../services/order_service.dart';
import '../../../services/shop_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/order_model.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final shopId = authProvider.userData?.shopId ?? 'mock_shop_123';
    final orderService = Provider.of<OrderService>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuickStats(orderService, shopId),
          const SizedBox(height: 24),
          const MonoLabel('SHOP_SYNC_CONTROL', color: AppTheme.primary),
          const SizedBox(height: 12),
          _buildShopControls(shopId),
          const SizedBox(height: 24),
          const MonoLabel('REALTIME_ORDER_STREAM', color: AppTheme.primary),
          const SizedBox(height: 12),
          _buildRecentOrders(orderService, shopId),
        ],
      ),
    );
  }

  Widget _buildQuickStats(OrderService orderService, String shopId) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'GROSS_SALES',
            value: '₹42,850',
            trend: '+12.5%',
            icon: Icons.account_balance_wallet,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            label: 'ACTIVE_QUE',
            value: '08',
            trend: 'STABLE',
            icon: Icons.timer,
          ),
        ),
      ],
    );
  }

  Widget _buildShopControls(String shopId) {
    return HardShadowCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VAANI_REST_LAB', // Mock shop name
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const MonoLabel('STATUS: ACTIVE // BUFF_READY'),
            ],
          ),
          Switch(
            value: true,
            onChanged: (v) {},
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(OrderService orderService, String shopId) {
    return StreamBuilder<List<OrderModel>>(
      stream: orderService.getShopOrders(shopId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final orders = snapshot.data!;
        
        return Column(
          children: orders.take(5).map((order) => _OrderMiniTile(order: order)).toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, trend;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.trend, required this.icon});

  @override
  Widget build(BuildContext context) {
    return HardShadowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MonoLabel(label, fontSize: 8),
              Text(
                trend,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: trend.startsWith('+') ? AppTheme.success : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderMiniTile extends StatelessWidget {
  final OrderModel order;
  const _OrderMiniTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ORD_${order.orderNumber}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              MonoLabel('₹${order.totalAmount.toStringAsFixed(0)}', fontSize: 9),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primary),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              order.status.name.toUpperCase(),
              style: GoogleFonts.jetBrainsMono(fontSize: 8, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
