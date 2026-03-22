import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import 'order_success_screen.dart';

class PaymentScreen extends StatelessWidget {
  final double amount;
  const PaymentScreen({super.key, required this.amount});

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
                _paymentTile('Google Pay', Icons.account_balance_wallet, true),
                _paymentTile('PhonePe', Icons.account_balance_wallet, false),
                _paymentTile('BHIM UPI', Icons.account_balance_wallet, false),
                const SizedBox(height: 24),
                _sectionHeader('CARDS'),
                _paymentTile('VISA •••• 4242', Icons.credit_card, false),
                _paymentTile('MASTERCARD •••• 8890', Icons.credit_card, false),
                const SizedBox(height: 24),
                _sectionHeader('OTHER'),
                _paymentTile('Cash on Delivery', Icons.payments, false),
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
            '\$${amount.toStringAsFixed(2)}',
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

  Widget _paymentTile(String title, IconData icon, bool selected) {
    return Container(
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
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: PrimaryButton(
        label: 'COMPLETE PURCHASE',
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
            (route) => false,
          );
        },
      ),
    );
  }
}
