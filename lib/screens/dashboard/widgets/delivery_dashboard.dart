import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_theme.dart';
import '../../../widgets/industrial_widgets.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/order_service.dart';
import '../../../models/order_model.dart';
import '../../../models/user_model.dart';

class DeliveryDashboard extends StatefulWidget {
  const DeliveryDashboard({super.key});

  @override
  State<DeliveryDashboard> createState() => _DeliveryDashboardState();
}

class _DeliveryDashboardState extends State<DeliveryDashboard> {
  final OrderService _orderService = OrderService();
  bool _isTogglingStatus = false;

  Future<void> _updateStatus(String orderId, OrderStatus status) async {
    try {
      await _orderService.updateOrderStatus(orderId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.surface,
            content: MonoLabel('SIGNAL_OK // STATUS: ${status.value.toUpperCase()}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: MonoLabel('SIGNAL_DROP // ERROR: $e'),
          ),
        );
      }
    }
  }

  Future<void> _collectCash(OrderModel order) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      await _orderService.collectCash(
        order.id,
        auth.userData!.uid,
        auth.userData!.displayName ?? 'RIDER',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppTheme.success,
            content: MonoLabel('CASH_SECURED // AUDIT_SUCCESS'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: MonoLabel('AUDIT_FAIL // ERROR: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    
    String? shopId = userData?.shopId;
    List<String>? shopIds = userData?.shopIds;

    return Column(
      children: [
        _buildAvailabilityHeader(authProvider),
        _buildRiderStats(shopId),
        const Divider(color: AppTheme.borderDark, height: 1),
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: (shopIds != null && shopIds.isNotEmpty)
                ? _orderService.getDeliveryOrdersMultiShop(shopIds)
                : _orderService.getDeliveryOrders(shopId),
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
                      Icon(Icons.electric_moped, size: 64, color: AppTheme.borderDark.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const MonoLabel('GRID_CLEAR // RIDER_STANDBY', fontSize: 12),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: orders.length,
                itemBuilder: (context, index) => _DeliveryOrderCard(
                  order: orders[index],
                  onStatusUpdate: _updateStatus,
                  onCollectCash: _collectCash,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityHeader(AuthProvider auth) {
    final isOnline = auth.userData?.isOnline ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _LiveIndicator(isOnline: isOnline),
              const SizedBox(width: 12),
              MonoLabel(isOnline ? 'RIDER_ACTIVE // GRID_CONNECTED' : 'RIDER_SLEEP // GRID_OFFLINE'),
            ],
          ),
          Switch(
            value: isOnline,
            onChanged: (val) async {
              setState(() => _isTogglingStatus = true);
              await auth.updateUserData({'isOnline': val});
              if (mounted) setState(() => _isTogglingStatus = false);
            },
            activeColor: AppTheme.success,
            activeTrackColor: AppTheme.success.withOpacity(0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildRiderStats(String? shopId) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _orderService.getDeliveryStats(shopId),
      builder: (context, snapshot) {
        final stats = snapshot.data;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _StatItem(label: 'DELIVERIES_TODAY', value: '${stats?['todayDeliveries'] ?? 0}', color: AppTheme.primary),
              const SizedBox(width: 12),
              _StatItem(label: 'CASH_COLLECTED', value: '₹${(stats?['todayCollections'] ?? 0).toStringAsFixed(0)}', color: AppTheme.success),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MonoLabel(label, fontSize: 8),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveIndicator extends StatefulWidget {
  final bool isOnline;
  const _LiveIndicator({required this.isOnline});

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
      opacity: widget.isOnline ? _controller : const AlwaysStoppedAnimation(0.3),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.isOnline ? AppTheme.success : AppTheme.error,
          shape: BoxShape.circle,
          boxShadow: [
            if (widget.isOnline)
              BoxShadow(
                color: AppTheme.success.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryOrderCard extends StatelessWidget {
  final OrderModel order;
  final Function(String, OrderStatus) onStatusUpdate;
  final Function(OrderModel) onCollectCash;

  const _DeliveryOrderCard({
    required this.order,
    required this.onStatusUpdate,
    required this.onCollectCash,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = order.status == OrderStatus.readyForPickup;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.borderDark),
        boxShadow: [
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
            color: AppTheme.background.withOpacity(0.5),
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
                        color: Colors.white,
                      ),
                    ),
                    MonoLabel(order.status.value.toUpperCase(), fontSize: 9, color: AppTheme.primary),
                  ],
                ),
                if (order.paymentMethod == PaymentMethod.cash)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.warning),
                    ),
                    child: const MonoLabel('COD_PENDING', color: AppTheme.warning, fontSize: 8),
                  ),
              ],
            ),
          ),
          const Divider(color: AppTheme.borderDark, height: 1),
          
          // Customer Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _DetailRow(Icons.person, order.customerName.toUpperCase()),
                const SizedBox(height: 12),
                _DetailRow(Icons.pin_drop, order.deliveryAddress.toUpperCase()),
                const SizedBox(height: 12),
                _DetailRow(Icons.payments, '₹${order.totalAmount.toStringAsFixed(0)}'),
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _IconButton(
                  icon: Icons.map,
                  onTap: () => _launchMap(order.deliveryAddress),
                ),
                const SizedBox(width: 8),
                _IconButton(
                  icon: Icons.call,
                  onTap: () => _launchPhone(order.customerPhone),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _IndustrialButton(
                    label: isReady ? 'PICK_UP_ORDER' : 'COMPLETE_DROP',
                    color: isReady ? AppTheme.primary : AppTheme.success,
                    onTap: () {
                      if (isReady) {
                        onStatusUpdate(order.id, OrderStatus.outForDelivery);
                      } else {
                        if (order.paymentMethod == PaymentMethod.cash) {
                          onCollectCash(order);
                        } else {
                          onStatusUpdate(order.id, OrderStatus.completed);
                        }
                      }
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

  Future<void> _launchMap(String address) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }

  Future<void> _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _DetailRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.background,
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
    );
  }
}

class _IndustrialButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _IndustrialButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: color, width: 2),
          gradient: LinearGradient(
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
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
