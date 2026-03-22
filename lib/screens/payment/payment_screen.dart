import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../services/auth_service.dart';
import '../../services/live_simulation_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double amount;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final LatLng? location;

  const PaymentScreen({
    super.key,
    required this.amount,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    this.location,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'ONLINE PAYMENT';
  bool _isProcessing = false;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _createFirestoreOrder(paymentId: response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PAYMENT FAILED: ${response.message ?? "CANCELLED"}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Informational only
  }

  void _startPayment() {
    setState(() => _isProcessing = true);

    if (_selectedMethod == 'CASH ON DELIVERY') {
      _createFirestoreOrder();
      return;
    }

    final auth = context.read<AuthProvider>();
    
    var options = {
      'key': 'rzp_test_RU9lPJQl5wqQFM', // Test key from original app
      'amount': (widget.amount * 100).toInt(),
      'name': 'FOODY VRINDA',
      'description': 'PURE VEG SATTVIK MEAL',
      'prefill': {
        'contact': widget.customerPhone,
        'email': auth.user?.email ?? 'customer@example.com',
        'name': widget.customerName,
      },
      'theme': {'color': '#FF3B30'},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Open Error: $e');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _createFirestoreOrder({String? paymentId}) async {
    try {
      final cart = context.read<CartProvider>();
      final orderService = context.read<OrderService>();
      final auth = context.read<AuthProvider>();
      
      final String? userId = auth.user?.uid;
      
      final orderId = await orderService.createOrder(
        userId: userId ?? 'guest_user',
        shopId: cart.shopId ?? 'main_kitchen',
        customerName: widget.customerName,
        customerPhone: widget.customerPhone,
        deliveryAddress: widget.deliveryAddress,
        cartItems: cart.items,
        totalAmount: cart.total,
        subtotal: cart.subtotal,
        deliveryCharge: cart.deliveryFee,
        gstAmount: cart.tax,
        paymentMethod: _selectedMethod == 'CASH ON DELIVERY' ? PaymentMethod.cash : PaymentMethod.online,
        paymentId: paymentId,
        customerLatitude: widget.location?.latitude,
        customerLongitude: widget.location?.longitude,
      );

      // Start simulation
      LiveSimulationService(orderService).startSimulation(orderId);

      cart.clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: orderId)),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Order Creation Error: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ORDER FAILED: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 32),
                  const MonoLabel('SELECT PAYMENT MODE'),
                  const SizedBox(height: 12),
                  _paymentOption('ONLINE PAYMENT', Icons.bolt_rounded, 'RAZORPAY SECURE GATEWAY'),
                  _paymentOption('CASH ON DELIVERY', Icons.payments_rounded, 'PAY UPON ARRIVAL'),
                ],
              ),
            ),
            _buildActionArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            'PAYMENT',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return HardShadowCard(
      child: Column(
        children: [
          const MonoLabel('TOTAL REMITTANCE'),
          const SizedBox(height: 12),
          Text(
            '₹${widget.amount.toStringAsFixed(0)}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppTheme.textSecondary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.deliveryAddress.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.monoSmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOption(String title, IconData icon, String subtitle) {
    final selected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.1) : AppTheme.surface,
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.borderDark, width: 2),
          boxShadow: selected ? [AppTheme.redGlowShadow] : [AppTheme.hardShadow],
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppTheme.primary : Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTheme.monoSmall,
                  ),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: PrimaryButton(
        label: _selectedMethod == 'ONLINE PAYMENT' ? 'AUTHORIZE PAYMENT' : 'CONFIRM ORDER',
        isLoading: _isProcessing,
        onPressed: _startPayment,
      ),
    );
  }
}
