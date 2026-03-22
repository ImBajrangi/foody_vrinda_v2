import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../payment/payment_screen.dart';
import '../../config/lottie_assets.dart';
import '../../widgets/animations.dart';
import '../../widgets/location_picker_dialog.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  LatLng? _deliveryLocation;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.userData?.displayName ?? '');
    _phoneController = TextEditingController(text: auth.userData?.phoneNumber ?? '');
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final LatLng? picked = await showDialog<LatLng>(
      context: context,
      builder: (context) => LocationPickerDialog(initialLocation: _deliveryLocation),
    );

    if (picked != null) {
      setState(() {
        _deliveryLocation = picked;
        _addressController.text = "LOCATION SELECTED: ${picked.latitude.toStringAsFixed(4)}, ${picked.longitude.toStringAsFixed(4)}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildHeader(context),
              if (items.isEmpty)
                Expanded(
                  child: EmptyState(
                    title: 'YOUR CART IS EMPTY',
                    subtitle: 'Add some delicious items to get started!',
                    animationUrl: LottieAssets.emptyCart,
                    onAction: () => Navigator.pop(context),
                    actionLabel: 'EXPLORE MENU',
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildItemsList(cart),
                      const SizedBox(height: 20),
                      _buildDeliveryForm(),
                      const SizedBox(height: 20),
                      _buildOrderSummary(cart),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              if (items.isNotEmpty) _buildCheckoutButton(context, cart),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'CHECKOUT',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          if (Navigator.canPop(context))
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderDark),
                ),
                child: const MonoLabel('BACK', fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemsList(CartProvider cart) {
    return HardShadowCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: AppTheme.borderDark.withValues(alpha: 0.3),
            child: const MonoLabel('YOUR SELECTIONS'),
          ),
          ...cart.items.map((cartItem) {
            final item = cartItem.menuItem;
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '₹${item.price.toStringAsFixed(0)} x ${cartItem.quantity}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _qtyBtn(Icons.remove, () => cart.updateQuantity(item.id, cartItem.quantity - 1)),
                      const SizedBox(width: 12),
                      Text(
                        '${cartItem.quantity}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _qtyBtn(Icons.add, () => cart.addToCart(item)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDeliveryForm() {
    return HardShadowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MonoLabel('DELIVERY DETAILS'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'FULL NAME'),
            validator: (v) => v!.isEmpty ? 'REQUIRED' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(hintText: 'PHONE NUMBER'),
            keyboardType: TextInputType.phone,
            validator: (v) => v!.length < 10 ? 'INVALID PHONE' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(hintText: 'DELIVERY ADDRESS'),
                  maxLines: 2,
                  validator: (v) => v!.isEmpty ? 'REQUIRED' : null,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _pickLocation,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    border: Border.all(color: AppTheme.borderDark),
                    boxShadow: const [AppTheme.hardShadow],
                  ),
                  child: const Icon(Icons.map, color: AppTheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return HardShadowCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _receiptRow('SUBTOTAL', '₹${cart.subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _receiptRow('DELIVERY', '₹${cart.deliveryFee.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _receiptRow('TAX (5%)', '₹${cart.tax.toStringAsFixed(0)}'),
          const Divider(height: 32, color: AppTheme.borderDark),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                '₹${cart.total.toStringAsFixed(0)}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, CartProvider cart) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: PrimaryButton(
        label: 'REVIEW & PAY',
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentScreen(
                  amount: cart.total,
                  customerName: _nameController.text,
                  customerPhone: _phoneController.text,
                  deliveryAddress: _addressController.text,
                  location: _deliveryLocation,
                ),
              ),
            );
          }
        },
      ),
    );
  }

  static Widget _receiptRow(String label, String value) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: AppTheme.textSecondary,
              letterSpacing: 1,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border.all(color: AppTheme.borderDark),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }
}
