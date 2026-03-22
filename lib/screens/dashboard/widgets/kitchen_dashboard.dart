import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../config/app_theme.dart';
import '../../../widgets/industrial_widgets.dart';
import '../../../services/order_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/order_model.dart';

class KitchenDashboard extends StatelessWidget {
  const KitchenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final shopId = authProvider.userData?.shopId ?? 'mock_shop_123';
    final orderService = Provider.of<OrderService>(context);

    return StreamBuilder<List<OrderModel>>(
      stream: orderService.getShopOrders(shopId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final orders = snapshot.data!.where((o) => o.status != OrderStatus.completed && o.status != OrderStatus.cancelled).toList();

        if (orders.isEmpty) {
          return const Center(child: MonoLabel('NO_ACTIVE_ORDERS // QUE_BUFFER_EMPTY'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return _KitchenOrderCard(order: order, orderService: orderService);
          },
        );
      },
    );
  }
}

class _KitchenOrderCard extends StatelessWidget {
  final OrderModel order;
  final OrderService orderService;

  const _KitchenOrderCard({required this.order, required this.orderService});

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
              Text(
                'ORD_${order.orderNumber}',
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: AppTheme.primary,
                ),
              ),
              MonoLabel(order.formattedDate, fontSize: 10),
            ],
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${item.quantity}x ${item.name.toUpperCase()}',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, color: Colors.white),
            ),
          )),
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionButton(
                label: 'PREPARING',
                isActive: order.status == OrderStatus.preparing,
                onTap: () => orderService.updateOrderStatus(order.id, OrderStatus.preparing),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'READY',
                isActive: order.status == OrderStatus.readyForPickup,
                onTap: () => orderService.updateOrderStatus(order.id, OrderStatus.readyForPickup),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.surface,
            border: Border.all(color: AppTheme.primary),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isActive ? Colors.black : AppTheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
