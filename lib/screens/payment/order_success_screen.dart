import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/app_theme.dart';
import '../../widgets/industrial_widgets.dart';
import '../home/home_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.pureVeg.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.pureVeg, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.pureVeg.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppTheme.pureVeg,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.borderDark),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?q=80&w=1000&auto=format&fit=crop',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'ORDER PLACED!',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your Sattvik feast is being prepared with care and devotion.',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              HardShadowCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow('ORDER ID', '#VR-99281'),
                    const SizedBox(height: 8),
                    _infoRow('EST. TIME', '25 MINS'),
                    const SizedBox(height: 8),
                    _infoRow('STATUS', 'PREPARING'),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              PrimaryButton(
                label: 'BACK TO FEED',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MonoLabel(label, color: AppTheme.textSecondary),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
