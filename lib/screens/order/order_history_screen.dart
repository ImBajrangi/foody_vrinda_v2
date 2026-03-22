import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/industrial_widgets.dart';
import '../../config/lottie_assets.dart';
import '../tracking/tracking_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.userData?.uid ?? 'mock_user_123';
    final orderService = OrderService();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'ORDER_LOGS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppTheme.borderDark, height: 1),
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getUserOrders(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderLogTile(order: order);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieAssets.build(LottieAssets.emptySearch, width: 220),
          const SizedBox(height: 24),
          const MonoLabel('NO_ACTIVE_LOGS_FOUND'),
          const SizedBox(height: 8),
          Text(
            'Your order history is currently empty.',
            style: GoogleFonts.jetBrainsMono(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderLogTile extends StatelessWidget {
  final OrderModel order;
  const _OrderLogTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return HardShadowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${order.orderNumber}',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  MonoLabel(
                    order.formattedDate,
                    fontSize: 9,
                  ),
                ],
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppTheme.borderDark, height: 1),
          ),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 12, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.name}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MonoLabel('TOTAL_PAYABLE', fontSize: 8),
                  Text(
                    '₹${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              if (order.status != OrderStatus.completed && order.status != OrderStatus.cancelled)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackingScreen(orderId: order.id),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'TRACK_ACTIVE',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case OrderStatus.completed:
        color = AppTheme.success;
        break;
      case OrderStatus.cancelled:
        color = AppTheme.error;
        break;
      case OrderStatus.newOrder:
        color = AppTheme.warning;
        break;
      default:
        color = AppTheme.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
