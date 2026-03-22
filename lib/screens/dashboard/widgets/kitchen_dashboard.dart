import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../widgets/industrial_widgets.dart';
import '../../../services/order_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/order_model.dart';

class KitchenDashboard extends StatefulWidget {
  const KitchenDashboard({super.key});

  @override
  State<KitchenDashboard> createState() => _KitchenDashboardState();
}

class _KitchenDashboardState extends State<KitchenDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final shopId = authProvider.userData?.shopId;
    final orderService = Provider.of<OrderService>(context);

    if (shopId == null) {
      return const Center(child: MonoLabel('ERROR // NO_SHOP_ASSIGNED'));
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KITCHEN_TERMINAL_V2.0',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Row(
                  children: [
                    _LiveIndicator(),
                    const SizedBox(width: 6),
                    MonoLabel('SESSION_ACTIVE // SYNC_OK', fontSize: 8),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: orderService.getKitchenOrders(shopId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 64, color: AppTheme.borderDark.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const MonoLabel('QUE_EMPTY // KITCHEN_STANDBY', fontSize: 12),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            itemCount: orders.length,
            itemBuilder: (context, index) => _KitchenOrderCard(
              order: orders[index],
              orderService: orderService,
            ),
          );
        },
      ),
    );
  }
}

class _LiveIndicator extends StatefulWidget {
  @override
  _LiveIndicatorState createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppTheme.success,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _KitchenOrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderService orderService;

  const _KitchenOrderCard({required this.order, required this.orderService});

  @override
  Widget build(BuildContext context) {
    final isNew = order.status == OrderStatus.newOrder;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(
          color: isNew ? AppTheme.primary : AppTheme.borderDark,
          width: isNew ? 2 : 1,
        ),
        boxShadow: [
          if (isNew)
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isNew ? AppTheme.primary.withOpacity(0.05) : Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORD_${order.orderNumber.substring(order.orderNumber.length - 4).toUpperCase()}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isNew ? AppTheme.primary : Colors.white,
                      ),
                    ),
                    MonoLabel('ELAPSED // ${order.timeAgo}', fontSize: 9, color: AppTheme.textSecondary),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isNew ? AppTheme.primary : AppTheme.background,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    order.status.value.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: isNew ? Colors.black : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.borderDark, height: 1),
          
          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primary),
                        ),
                        child: Text(
                          '${item.quantity}X',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.name.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _IndustrialButton(
                    label: 'REJECT',
                    color: AppTheme.error,
                    isOutline: true,
                    onTap: () => _showRejectDialog(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _IndustrialButton(
                    label: isNew ? 'START_COOKING' : 'MARK_READY',
                    color: isNew ? AppTheme.primary : AppTheme.success,
                    onTap: () {
                      final nextStatus = isNew ? OrderStatus.preparing : OrderStatus.readyForPickup;
                      orderService.updateOrderStatus(order.id, nextStatus);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final reasons = ['OUT_OF_STOCK', 'SHOP_CLOSING', 'TOO_BUSY', 'OTHER'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MonoLabel('REJECT_ORDER // SELECT_REASON'),
            const SizedBox(height: 16),
            ...reasons.map((reason) => ListTile(
              title: Text(reason, style: GoogleFonts.jetBrainsMono(color: Colors.white, fontSize: 13)),
              onTap: () {
                orderService.updateOrderStatus(order.id, OrderStatus.cancelled, reason: reason);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}

class _IndustrialButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isOutline;

  const _IndustrialButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.isOutline = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : color,
          border: Border.all(color: color, width: 2),
          gradient: isOutline ? null : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: isOutline ? color : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
