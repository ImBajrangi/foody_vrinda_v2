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

    return StreamBuilder<List<OrderModel>>(
      stream: orderService.getKitchenOrders(shopId), // Only new/preparing
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant, size: 48, color: AppTheme.borderDark),
                SizedBox(height: 16),
                MonoLabel('QUE_EMPTY // KITCHEN_STANDBY'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,
          itemBuilder: (context, index) => _KitchenOrderCard(
            order: orders[index],
            orderService: orderService,
          ),
        );
      },
    );
  }
}

class _KitchenOrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderService orderService;

  const _KitchenOrderCard({required this.order, required this.orderService});

  void _showRejectDialog(BuildContext context) {
    final reasons = [
      'ITEM_OUT_OF_STOCK',
      'SHOP_CLOSING',
      'TOO_MANY_ORDERS',
      'KITCHEN_MALFUNCTION',
      'OTHER_FORCE_MAJEURE',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = order.status == OrderStatus.newOrder;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: HardShadowCard(
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
                      'ORD_${order.orderNumber.toUpperCase()}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isNew ? AppTheme.primary : Colors.white,
                      ),
                    ),
                    MonoLabel('ELAPSED // ${order.timeAgo}'),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isNew ? AppTheme.primary.withOpacity(0.1) : AppTheme.surface,
                    border: Border.all(color: isNew ? AppTheme.primary : AppTheme.borderDark),
                  ),
                  child: MonoLabel(
                    order.status.value.toUpperCase(),
                    color: isNew ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.borderDark, height: 1),
            const SizedBox(height: 16),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.borderDark,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          '${item.quantity}X',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
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
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showRejectDialog(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const MonoLabel('REJECT', color: AppTheme.error),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: isNew ? 'START_COOKING' : 'MARK_READY',
                    onPressed: () {
                      final nextStatus = isNew ? OrderStatus.preparing : OrderStatus.readyForPickup;
                      orderService.updateOrderStatus(order.id, nextStatus);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
