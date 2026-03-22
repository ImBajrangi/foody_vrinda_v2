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
            content: MonoLabel('ORDER_UPDATED // ${status.value.toUpperCase()}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: MonoLabel('UPDATE_FAILED // $e'),
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
            content: MonoLabel('CASH_COLLECTED // TRANSACTION_LOGGED'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.error,
            content: MonoLabel('COLLECTION_FAILED // $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    
    // Get shop ID(s)
    String? shopId = userData?.shopId;
    List<String>? shopIds = userData?.shopIds;

    return Column(
      children: [
        _buildAvailabilityToggle(authProvider),
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
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delivery_dining, size: 48, color: AppTheme.borderDark),
                      SizedBox(height: 16),
                      MonoLabel('NO_ACTIVE_DELIVERIES // STANDBY'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: orders.length,
                itemBuilder: (context, index) => _buildOrderCard(orders[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityToggle(AuthProvider auth) {
    final isOnline = auth.userData?.isOnline ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? AppTheme.success : AppTheme.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (isOnline)
                      BoxShadow(
                        color: AppTheme.success.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MonoLabel(isOnline ? 'STATUS // ONLINE' : 'STATUS // OFFLINE'),
            ],
          ),
          Switch(
            value: isOnline,
            onChanged: (val) async {
              setState(() => _isTogglingStatus = true);
              // In v2, we should have a toggle method in AuthProvider/Service
              // For now, let's assume updateUserData works
              await auth.updateUserData({'isOnline': val});
              if (mounted) setState(() => _isTogglingStatus = false);
            },
            activeColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final isReady = order.status == OrderStatus.readyForPickup;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
                      '#${order.orderNumber.substring(order.orderNumber.length - 6)}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    MonoLabel(order.status.value.toUpperCase()),
                  ],
                ),
                if (order.paymentMethod == PaymentMethod.cash)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.warning),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const MonoLabel('COD', color: AppTheme.warning),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.borderDark, height: 1),
            const SizedBox(height: 16),
            _infoRow(Icons.person, order.customerName),
            const SizedBox(height: 8),
            _infoRow(Icons.location_on, order.deliveryAddress),
            const SizedBox(height: 8),
            _infoRow(Icons.currency_rupee, 'TOTAL: ₹${order.totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _launchMap(order.deliveryAddress),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.borderDark),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Icon(Icons.map, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _launchPhone(order.customerPhone),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.borderDark),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Icon(Icons.phone, color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: isReady ? 'PICK_UP' : 'COMPLETE',
                    onPressed: () {
                      if (isReady) {
                        _updateStatus(order.id, OrderStatus.outForDelivery);
                      } else {
                        if (order.paymentMethod == PaymentMethod.cash) {
                          _collectCash(order);
                        } else {
                          _updateStatus(order.id, OrderStatus.completed);
                        }
                      }
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

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchMap(String address) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchPhone(String phone) async {
    final url = 'tel:$phone';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
