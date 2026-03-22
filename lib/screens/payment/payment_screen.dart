import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../services/live_simulation_service.dart';
import '../../providers/cart_provider.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  const PaymentScreen({super.key, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Google Pay';
  bool _isProcessing = false;

  void _handlePayment() async {
    setState(() => _isProcessing = true);
    
    try {
      final cart = context.read<CartProvider>();
      final orderService = context.read<OrderService>();
      final authService = context.read<AuthService>();
      
      final String? userId = authService.currentUser?.uid;
      
      // Create actual order in Firestore
      final orderId = await orderService.createOrder(
        userId: userId ?? 'guest_user',
        shopId: cart.items.isNotEmpty ? cart.items.first.menuItem.shopId : 'demo_shop',
        customerName: authService.currentUser?.displayName ?? 'Guest User',
        customerPhone: authService.currentUser?.phoneNumber ?? '9199999999',
        deliveryAddress: 'Vrindavan Dham, Sector 7', // Mock address for production-ready demonstration
        cartItems: cart.items,
        totalAmount: cart.total,
        paymentMethod: _selectedMethod == 'Cash on Delivery' ? PaymentMethod.cash : PaymentMethod.online,
      );

      // Start Simulation for "Real-Life" feel
      LiveSimulationService(orderService).startSimulation(orderId);

      // Clear cart on success
      cart.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: orderId)),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('PaymentScreen Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('PAYMENT METHODS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildAmountCard(),
                const SizedBox(height: 24),
                _sectionHeader('UPI MODES'),
                _paymentTile('Google Pay', Icons.account_balance_wallet),
                _paymentTile('PhonePe', Icons.account_balance_wallet),
                _paymentTile('BHIM UPI', Icons.account_balance_wallet),
                const SizedBox(height: 24),
                _sectionHeader('CARDS'),
                _paymentTile('VISA •••• 4242', Icons.credit_card),
                _paymentTile('MASTERCARD •••• 8890', Icons.credit_card),
                const SizedBox(height: 24),
                _sectionHeader('OTHER'),
                _paymentTile('Cash on Delivery', Icons.payments),
              ],
            ),
          ),
          _buildPayButton(context),
        ],
      ),
    );
  }

  Widget _buildAmountCard() {
    return HardShadowCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'TOTAL PAYABLE',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: AppTheme.textSecondary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${widget.amount.toStringAsFixed(0)}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: MonoLabel(title, color: AppTheme.textSecondary, fontSize: 11),
    );
  }

  Widget _paymentTile(String title, IconData icon) {
    final selected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.borderDark,
            width: selected ? 2 : 1,
          ),
        ),
        child: ListTile(
          leading: Icon(icon, color: selected ? AppTheme.primary : Colors.white),
          title: Text(
            title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: Colors.white,
            ),
          ),
          trailing: selected
              ? const Icon(Icons.check_circle, color: AppTheme.primary)
              : const Icon(Icons.circle_outlined, color: AppTheme.borderDark),
        ),
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: PrimaryButton(
        label: _selectedMethod == 'Cash on Delivery' ? 'PLACE ORDER' : 'COMPLETE PURCHASE',
        isLoading: _isProcessing,
        onPressed: _handlePayment,
      ),
    );
  }
}
